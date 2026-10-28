"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useRef, useState } from "react";
import { useForm, type DefaultValues, type FieldPath, type FieldValues } from "react-hook-form";
import { z } from "zod";
import { Bao, NutGui, Truong } from "@/components/tai-khoan/khung-form";
import type { ApiResult } from "@/lib/api/client";
import { loiTaiKhoan } from "@/lib/auth/messages";
import { hetPhien, useChuyenDangNhap } from "@/lib/khach/session";

export type O<T extends FieldValues> = { name: FieldPath<T>; label: string; type?: string; autoComplete?: string };
export function FormKhach<T extends FieldValues>({ schema, defaults, fields, submit, success, label, protectedForm = false }: {
  schema: z.ZodType<T, T>; defaults: DefaultValues<T>; fields: O<T>[];
  submit: (v: T) => Promise<ApiResult<unknown>>; success: () => Promise<string | void> | string | void;
  label: string; protectedForm?: boolean;
}) {
  const form = useForm<T>({ resolver: zodResolver(schema), defaultValues: defaults });
  const lock = useRef(false);
  const [busy, setBusy] = useState(false);
  const [redirect, setRedirect] = useState(false);
  const [notice, setNotice] = useState<{ loai: "tin" | "loi"; text: string } | null>(null);
  useChuyenDangNhap(redirect);
  const gui = async (v: T) => {
    if (lock.current) return;
    lock.current = true; setBusy(true); setNotice(null);
    try {
      const r = await submit(v);
      if (!r.ok) {
        if (protectedForm && hetPhien(r.failure)) { setRedirect(true); return; }
        const text = loiTaiKhoan(r.failure);
        const field = r.failure.kind === "rejected" ? r.failure.field : undefined;
        if (field && fields.some((f) => f.name === field)) {
          form.setError(field as FieldPath<T>, { message: text });
        }
        setNotice({ loai: "loi", text }); return;
      }
      const text = await success();
      if (text) setNotice({ loai: "tin", text });
    } finally { lock.current = false; setBusy(false); }
  };
  return <form onSubmit={(event) => { void form.handleSubmit(gui)(event); }} noValidate className="space-y-4">
    {fields.map((f) => <Truong key={f.name} id={f.name} nhan={f.label} type={f.type} autoComplete={f.autoComplete}
      loi={form.getFieldState(f.name, form.formState).error?.message} {...form.register(f.name)} />)}
    {notice && <Bao loai={notice.loai}>{notice.text}</Bao>}
    <NutGui dangGui={busy}>{label}</NutGui>
  </form>;
}
export const matKhau = z.string().min(8, "Mật khẩu cần ít nhất 8 ký tự.");
export const batBuoc = z.string().refine((v) => !!v.trim(), "Vui lòng nhập thông tin.");
