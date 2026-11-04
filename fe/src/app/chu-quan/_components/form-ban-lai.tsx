"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type FormEvent } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { loiSanPham, oBiTuChoi, useBanLai, type Mon } from "./du-lieu-san-pham";

const schema = z.object({ reason: z.string().trim().min(1, "Nhập lý do bán lại.") });

export function FormBanLai({ mon }: { mon: Mon }) {
  const id = useId();
  const luu = useBanLai(mon.menu_item_id);
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
        if (r.ok) { setDaLuu(`Đã bán lại ${mon.item_name}.`); return; }
        const message = loiSanPham(r.failure);
        if (oBiTuChoi(r.failure) === "reason") form.setError("reason", { message });
        else setLoi(message);
      })(e);
    } finally { chot.current = false; }
  }
  const message = form.formState.errors.reason?.message;
  if (!mon.discontinued) return <>
    {loi && <p role="alert">{loi}</p>}
    {daLuu && <p role="status">{daLuu}</p>}
  </>;
  return <form aria-label={`Bán lại ${mon.item_name}`} onSubmit={gui} noValidate className="space-y-3">
      <fieldset disabled={ban}>
        <Field data-invalid={!!message}>
          <FieldLabel htmlFor={id}>Lý do bán lại</FieldLabel>
          <Input id={id} aria-invalid={!!message} aria-describedby={message ? `${id}-loi` : undefined} {...form.register("reason")} />
          {message && <FieldError id={`${id}-loi`}>{message}</FieldError>}
        </Field>
      </fieldset>
      <Button className="sp-primary" type="submit" disabled={ban}>Bán lại</Button>
    {loi && <p role="alert">{loi}</p>}
    {daLuu && <p role="status">{daLuu}</p>}
  </form>;
}
