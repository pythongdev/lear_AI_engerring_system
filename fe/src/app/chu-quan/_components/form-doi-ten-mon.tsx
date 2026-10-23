"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type FormEvent } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { loiSanPham, oBiTuChoi, useDoiTenMon, type DoiTenMon, type Mon } from "./du-lieu-san-pham";

const schema = z.object({ name: z.string().trim().min(1, "Nhập tên mới."), reason: z.string().trim().min(1, "Nhập lý do.") });

export function FormDoiTenMon({ mon, dong, daLuu }: { mon: Mon; dong: () => void; daLuu: (ten: string) => void }) {
  const id = useId();
  const luu = useDoiTenMon(mon.menu_item_id);
  const chot = useRef(false);
  const [thongBao, setThongBao] = useState<string | null>(null);
  const form = useForm<DoiTenMon>({ resolver: zodResolver(schema), defaultValues: { name: mon.item_name, reason: "" } });
  const ban = form.formState.isSubmitting || luu.isPending;
  async function gui(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async (body) => {
        setThongBao(null);
        const r = await luu.mutateAsync(body);
        if (r.ok) { daLuu(r.data.name); return; }
        const message = loiSanPham(r.failure);
        const o = oBiTuChoi(r.failure);
        if (o === "name" || o === "reason") form.setError(o, { type: "server", message });
        else setThongBao(message);
      })(event);
    } finally { chot.current = false; }
  }
  return <form aria-label={`Đổi tên ${mon.item_name}`} onSubmit={gui} noValidate className="space-y-3">
    <fieldset disabled={ban} className="space-y-3">
      {([ ["name", "Tên mới"], ["reason", "Lý do"] ] as const).map(([o, nhan]) => {
        const loi = form.formState.errors[o]?.message;
        return <Field key={o} data-invalid={!!loi}>
          <FieldLabel htmlFor={`${id}-${o}`}>{nhan}</FieldLabel>
          <Input id={`${id}-${o}`} aria-invalid={!!loi} aria-describedby={loi ? `${id}-${o}-loi` : undefined} {...form.register(o)} />
          {loi && <FieldError id={`${id}-${o}-loi`}>{loi}</FieldError>}
        </Field>;
      })}
    </fieldset>
    {thongBao && <Alert role="status"><AlertDescription>{thongBao}</AlertDescription></Alert>}
    <div className="flex gap-2">
      <Button className="sp-primary" type="submit" disabled={ban}>{ban ? "Đang lưu…" : "Lưu tên"}</Button>
      <Button type="button" variant="outline" disabled={ban} onClick={dong}>Huỷ</Button>
    </div>
  </form>;
}
