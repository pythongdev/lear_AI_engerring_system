"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type FormEvent } from "react";
import { useForm, useWatch } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { loiSanPham, oBiTuChoi, useThemThanhPhan, type Mon } from "./du-lieu-san-pham";

const tram = ["quay", "trang_banh", "gap_banh", "canh", "don_ban"] as const;
const schema = z.object({
  choice: z.string().min(1, "Chọn thành phần."),
  quantity: z.string().refine((v) => /^\d+$/.test(v) && Number(v) >= 1 && Number(v) <= 2147483647, "Nhập số nguyên từ 1 đến 2147483647."),
  reason: z.string().trim().min(1, "Nhập lý do thêm thành phần."),
  name: z.string().trim(), base_price_vnd: z.string(), takes_filling: z.boolean(), station_code: z.string(),
}).superRefine((v, ctx) => {
  if (v.choice !== "new") return;
  if (!v.name) ctx.addIssue({ code: "custom", path: ["name"], message: "Nhập tên thành phần." });
  if (!/^\d+$/.test(v.base_price_vnd) || !Number.isSafeInteger(Number(v.base_price_vnd)))
    ctx.addIssue({ code: "custom", path: ["base_price_vnd"], message: "Nhập số nguyên không âm." });
  if (!tram.some((t) => t === v.station_code)) ctx.addIssue({ code: "custom", path: ["station_code"], message: "Chọn trạm." });
});
type Values = z.infer<typeof schema>;

export function FormThemThanhPhan({ mon, components }: { mon: Mon; components: Mon["components"] }) {
  const id = useId();
  const luu = useThemThanhPhan(mon.menu_item_id);
  const chot = useRef(false);
  const [loi, setLoi] = useState<string | null>(null);
  const [daLuu, setDaLuu] = useState(false);
  const form = useForm<Values>({ resolver: zodResolver(schema), defaultValues: {
    choice: "", quantity: "1", reason: "", name: "", base_price_vnd: "", takes_filling: false, station_code: "",
  } });
  const moi = useWatch({ control: form.control, name: "choice" }) === "new";
  const ban = form.formState.isSubmitting || luu.isPending;
  async function gui(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async (v) => {
        setLoi(null); setDaLuu(false);
        const chung = { quantity: Number(v.quantity), reason: v.reason };
        const r = await luu.mutateAsync(v.choice === "new" ? { ...chung, component: {
          name: v.name, base_price_vnd: Number(v.base_price_vnd), takes_filling: v.takes_filling,
          station_code: v.station_code as typeof tram[number],
        } } : { ...chung, menu_component_id: Number(v.choice) });
        if (r.ok) { setDaLuu(true); form.reset(); return; }
        const message = loiSanPham(r.failure);
        let o = oBiTuChoi(r.failure)?.replace(/^component\./, "");
        if (r.failure.kind === "rejected" && r.failure.code === "menu_component_name_conflict") o = "name";
        if (o === "menu_component_id") o = "choice";
        if (o && ["choice", "quantity", "reason", "name", "base_price_vnd", "takes_filling", "station_code"].includes(o))
          form.setError(o as keyof Values, { message });
        else setLoi(message);
      })(e);
    } finally { chot.current = false; }
  }
  function field(o: keyof Values, label: string, control?: React.ReactNode) {
    const message = form.formState.errors[o]?.message;
    return <Field data-invalid={!!message}>
      <FieldLabel htmlFor={`${id}-${o}`}>{label}</FieldLabel>
      {control ?? <Input id={`${id}-${o}`} aria-invalid={!!message} {...form.register(o)} />}
      {message && <FieldError>{message}</FieldError>}
    </Field>;
  }
  return <form aria-label="Thêm thành phần" onSubmit={gui} noValidate className="space-y-3">
    <h2>Thêm thành phần</h2>
    <fieldset disabled={ban} className="space-y-3">
      {field("choice", "Thành phần", <select id={`${id}-choice`} aria-invalid={!!form.formState.errors.choice} {...form.register("choice")}>
        <option value="">Chọn thành phần</option>
        {components.map((c) => <option key={c.menu_component_id} value={c.menu_component_id}>{c.component_name}</option>)}
        <option value="new">Tạo thành phần mới</option>
      </select>)}
      {moi && <>
        {field("name", "Tên thành phần mới")}
        {field("base_price_vnd", "Giá gốc (đồng)")}
        {field("takes_filling", "Nhận nhân", <input type="checkbox" id={`${id}-takes_filling`} {...form.register("takes_filling")} />)}
        {field("station_code", "Trạm", <select id={`${id}-station_code`} aria-invalid={!!form.formState.errors.station_code} {...form.register("station_code")}>
          <option value="">Chọn trạm</option>
          {tram.map((t, i) => <option key={t} value={t}>{["Quầy", "Tráng bánh", "Gấp bánh", "Canh", "Dọn bàn"][i]}</option>)}
        </select>)}
      </>}
      {field("quantity", "Số lượng thành phần")}
      {field("reason", "Lý do thêm thành phần")}
    </fieldset>
    {loi && <p role="alert">{loi}</p>}
    {daLuu && <p role="status">Đã thêm thành phần.</p>}
    <Button type="submit" className="sp-primary" disabled={ban}>Thêm thành phần</Button>
  </form>;
}
