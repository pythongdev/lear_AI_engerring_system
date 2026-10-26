"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type FormEvent } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { useThanhPhanGia, type MonGia } from "./du-lieu-menu-gia";
import { loiSanPham, oBiTuChoi, useDoiGiaThanhPhan } from "./du-lieu-san-pham";

const schema = z.object({
  base_price_vnd: z.string().refine((v) => /^\d+$/.test(v) && Number.isSafeInteger(Number(v)), "Nhập số nguyên không âm."),
  reason: z.string().trim().min(1, "Nhập lý do đổi giá."),
});
type ThanhPhan = NonNullable<ReturnType<typeof useThanhPhanGia>["data"]>[number];

function FormGiaThanhPhan({ thanhPhan }: { thanhPhan: ThanhPhan }) {
  const id = useId();
  const luu = useDoiGiaThanhPhan(thanhPhan.menu_component_id);
  const chot = useRef(false);
  const [daLuu, setDaLuu] = useState<string | null>(null);
  const [loi, setLoi] = useState<string | null>(null);
  const form = useForm<z.infer<typeof schema>>({ resolver: zodResolver(schema),
    defaultValues: { base_price_vnd: String(thanhPhan.base_price_vnd), reason: "" } });
  const ban = form.formState.isSubmitting || luu.isPending;
  async function gui(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async ({ base_price_vnd, reason }) => {
        setLoi(null); setDaLuu(null);
        const r = await luu.mutateAsync({ base_price_vnd: Number(base_price_vnd), reason });
        if (r.ok) { setDaLuu(`Đã đổi giá gốc ${thanhPhan.component_name}.`); return; }
        const message = loiSanPham(r.failure);
        const o = oBiTuChoi(r.failure);
        if (o === "base_price_vnd" || o === "reason") form.setError(o, { message });
        else setLoi(message);
      })(e);
    } finally { chot.current = false; }
  }
  return <form aria-label={`Giá gốc ${thanhPhan.component_name}`} onSubmit={gui} noValidate className="space-y-3">
    <h3>{thanhPhan.component_name}</h3>
    <fieldset disabled={ban} className="space-y-3">
      {([["base_price_vnd", "Giá gốc mới (đồng)"], ["reason", "Lý do đổi giá"]] as const).map(([o, nhan]) => {
        const message = form.formState.errors[o]?.message;
        return <Field key={o} data-invalid={!!message}>
          <FieldLabel htmlFor={`${id}-${o}`}>{nhan}</FieldLabel>
          <Input id={`${id}-${o}`} inputMode={o === "base_price_vnd" ? "numeric" : undefined} aria-invalid={!!message}
            aria-describedby={message ? `${id}-${o}-loi` : undefined} {...form.register(o)} />
          {message && <FieldError id={`${id}-${o}-loi`}>{message}</FieldError>}
        </Field>;
      })}
    </fieldset>
    {loi && <p role="alert">{loi}</p>}
    {daLuu && <p role="status">{daLuu}</p>}
    <Button className="sp-primary" type="submit" disabled={ban}>Lưu giá</Button>
  </form>;
}

export function GiaThanhPhanMon({ monGia }: { monGia: MonGia }) {
  const query = useThanhPhanGia(monGia);
  if (query.isError) return <p role="alert">Chưa đọc được thành phần.</p>;
  if (query.isPending) return <p role="status">Đang đọc thành phần…</p>;
  return query.data.map((tp) => <FormGiaThanhPhan key={tp.menu_component_id} thanhPhan={tp} />);
}
