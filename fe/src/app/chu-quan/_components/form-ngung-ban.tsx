"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type FormEvent } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { loiSanPham, oBiTuChoi, useNgungBan, type Mon } from "./du-lieu-san-pham";

const schema = z.object({ reason: z.string().trim().min(1, "Nhập lý do ngừng bán.") });

export function FormNgungBan({ mon }: { mon: Mon }) {
  const id = useId();
  const luu = useNgungBan(mon.menu_item_id);
  const chot = useRef(false);
  const [daLuu, setDaLuu] = useState<string | null>(null);
  const [loi, setLoi] = useState<string | null>(null);
  const form = useForm<z.infer<typeof schema>>({ resolver: zodResolver(schema), defaultValues: { reason: "" } });
  const ban = form.formState.isSubmitting || luu.isPending;
  async function gui(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async (body) => {
        setLoi(null); setDaLuu(null);
        const r = await luu.mutateAsync(body);
        if (r.ok) { setDaLuu(`Đã ngừng bán ${mon.item_name}.`); return; }
        const message = loiSanPham(r.failure);
        if (oBiTuChoi(r.failure) === "reason") form.setError("reason", { message });
        else setLoi(message);
      })(e);
    } finally { chot.current = false; }
  }
  const message = form.formState.errors.reason?.message;
  if (mon.discontinued && !daLuu && !loi && !ban) return <p>Món đã ngừng bán. Chưa có cách bán lại.</p>;
  return <form aria-label={`Ngừng bán ${mon.item_name}`} onSubmit={gui} noValidate className="space-y-3">
    {mon.discontinued ? <p>Món đã ngừng bán. Chưa có cách bán lại.</p> : <>
      <fieldset disabled={ban}>
        <Field data-invalid={!!message}>
          <FieldLabel htmlFor={id}>Lý do ngừng bán</FieldLabel>
          <Input id={id} aria-invalid={!!message} aria-describedby={message ? `${id}-loi` : undefined} {...form.register("reason")} />
          {message && <FieldError id={`${id}-loi`}>{message}</FieldError>}
        </Field>
      </fieldset>
      <Button className="sp-primary" type="submit" disabled={ban}>Ngừng bán</Button>
    </>}
    {loi && <p role="alert">{loi}</p>}
    {daLuu && <p role="status">{daLuu}</p>}
  </form>;
}
