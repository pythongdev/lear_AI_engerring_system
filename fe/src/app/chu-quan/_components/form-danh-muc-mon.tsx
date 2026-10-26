"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type FormEvent } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { loiSanPham, oBiTuChoi, useChuyenDanhMuc, type DanhSachMon, type Mon } from "./du-lieu-san-pham";

export function FormDanhMucMon({ mon, categories, danhMucId }: {
  mon: Mon; categories: DanhSachMon["categories"]; danhMucId?: number;
}) {
  const id = useId();
  const luu = useChuyenDanhMuc(mon.menu_item_id);
  const chot = useRef(false);
  const [daLuu, setDaLuu] = useState<string | null>(null);
  const [loi, setLoi] = useState<string | null>(null);
  const schema = z.object({
    menu_category_id: z.number({ error: "Chọn danh mục." }).int().min(1, "Chọn danh mục."),
    reason: z.string().trim().refine((v) => danhMucId === undefined || v.length > 0, "Nhập lý do chuyển."),
  });
  const form = useForm<z.infer<typeof schema>>({ resolver: zodResolver(schema), defaultValues: { menu_category_id: NaN, reason: "" } });
  const ban = form.formState.isSubmitting || luu.isPending;
  async function gui(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async ({ menu_category_id, reason }) => {
        setLoi(null); setDaLuu(null);
        const r = await luu.mutateAsync(danhMucId === undefined ? { menu_category_id } : { menu_category_id, reason });
        if (r.ok) { setDaLuu(`Đã chuyển ${mon.item_name} sang ${r.data.name}.`); form.reset(); return; }
        const message = loiSanPham(r.failure);
        const o = oBiTuChoi(r.failure);
        if (o === "menu_category_id" || (o === "reason" && danhMucId !== undefined)) form.setError(o, { message });
        else setLoi(message);
      })(e);
    } finally { chot.current = false; }
  }
  const loiDanhMuc = form.formState.errors.menu_category_id?.message;
  const loiLyDo = form.formState.errors.reason?.message;
  return <form aria-label={`Chuyển danh mục ${mon.item_name}`} onSubmit={gui} noValidate className="space-y-3">
    <fieldset disabled={ban} className="space-y-3">
      <Field data-invalid={!!loiDanhMuc}>
        <FieldLabel htmlFor={`${id}-danh-muc`}>Danh mục mới</FieldLabel>
        <select id={`${id}-danh-muc`} className="h-9 w-full px-3" aria-invalid={!!loiDanhMuc}
          aria-describedby={loiDanhMuc ? `${id}-danh-muc-loi` : undefined} {...form.register("menu_category_id", { valueAsNumber: true })}>
          <option value="">Chọn danh mục</option>
          {categories.filter((c) => c.hidden_at === null && c.menu_category_id !== danhMucId).map((c) =>
            <option key={c.menu_category_id} value={c.menu_category_id}>{c.name}</option>)}
        </select>
        {loiDanhMuc && <FieldError id={`${id}-danh-muc-loi`}>{loiDanhMuc}</FieldError>}
      </Field>
      {danhMucId !== undefined && <Field data-invalid={!!loiLyDo}>
        <FieldLabel htmlFor={`${id}-reason`}>Lý do chuyển</FieldLabel>
        <Input id={`${id}-reason`} aria-invalid={!!loiLyDo} aria-describedby={loiLyDo ? `${id}-reason-loi` : undefined} {...form.register("reason")} />
        {loiLyDo && <FieldError id={`${id}-reason-loi`}>{loiLyDo}</FieldError>}
      </Field>}
    </fieldset>
    {loi && <p role="alert">{loi}</p>}
    {daLuu && <p role="status">{daLuu}</p>}
    <Button className="sp-primary" type="submit" disabled={ban}>Lưu danh mục</Button>
  </form>;
}
