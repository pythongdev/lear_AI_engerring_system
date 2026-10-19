"use client";

// Dùng cùng mẫu Field, RHF và chốt submit của form-doi-ten-mon cho các form danh mục/combo.
import { useId, useRef, useState, type FormEvent, type ReactNode } from "react";
import type { FieldPath, FieldValues, UseFormReturn } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import type { ApiResult } from "@/lib/api/client";
import { loiMenu, oLoiMenu } from "./du-lieu-danh-muc-combo";

export const chuMenu = z.string().trim().min(1, "Không được để trống.");
export const soMenu = z.number({ error: "Nhập số nguyên dương." }).int("Nhập số nguyên.").positive("Nhập số từ 1 trở lên.");

export function OMenu<T extends FieldValues>({ form, o, nhan, so = false, options }: {
  form: UseFormReturn<T>; o: FieldPath<T>; nhan: string; so?: boolean;
  options?: { id: number; ten: string }[];
}) {
  const id = useId();
  const loi = form.getFieldState(o, form.formState).error?.message;
  const props = { id, "aria-invalid": !!loi, "aria-describedby": loi ? `${id}-loi` : undefined,
    ...form.register(o, { valueAsNumber: so || options !== undefined }) };
  return <Field data-invalid={!!loi}>
    <FieldLabel htmlFor={id}>{nhan}</FieldLabel>
    {options ? <select {...props} className="h-9 w-full rounded-md border bg-background px-3">
      <option value="">Chọn {nhan.toLowerCase()}</option>
      {options.map((v) => <option key={v.id} value={v.id}>{v.ten}</option>)}
    </select> : <Input {...props} type={so ? "number" : "text"} min={so ? 1 : undefined} step={so ? 1 : undefined} />}
    {loi && <FieldError id={`${id}-loi`}>{loi}</FieldError>}
  </Field>;
}

export function FormMenu<T extends FieldValues, R>({ form, ten, nut, gui, cacO, daLuu, dong, children }: {
  form: UseFormReturn<T>; ten: string; nut: string; gui: (body: T) => Promise<ApiResult<R>>;
  cacO: FieldPath<T>[]; daLuu: (data: R) => string | void; dong?: () => void; children: ReactNode;
}) {
  const chot = useRef(false);
  const [thongBao, setThongBao] = useState<string | null>(null);
  const ban = form.formState.isSubmitting;
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async (body) => {
        setThongBao(null);
        const r = await gui(body);
        if (r.ok) { setThongBao(daLuu(r.data) ?? null); return; }
        const message = loiMenu(r.failure);
        const o = cacO.find((o) => o === oLoiMenu(r.failure));
        if (o) form.setError(o, { type: "server", message });
        else setThongBao(message);
      })(event);
    } finally { chot.current = false; }
  }
  return <form aria-label={ten} onSubmit={submit} noValidate className="space-y-4">
    <fieldset disabled={ban} className="space-y-4">{children}</fieldset>
    {thongBao && <Alert role="status"><AlertDescription>{thongBao}</AlertDescription></Alert>}
    <div className="flex gap-2">
      <Button type="submit" disabled={ban}>{ban ? "Đang lưu…" : nut}</Button>
      {dong && <Button type="button" variant="outline" disabled={ban} onClick={dong}>Huỷ</Button>}
    </div>
  </form>;
}
