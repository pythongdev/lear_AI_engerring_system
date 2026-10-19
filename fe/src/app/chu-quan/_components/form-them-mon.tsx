"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type FormEvent } from "react";
import { Controller, useFieldArray, useForm, type FieldPath } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { loiSanPham, oBiTuChoi, useThemMon, type DanhSachMon, type ThemMon } from "./du-lieu-san-pham";

const ten = z.string().trim().min(1, "Nhập tên.");
const so = z.number({ error: "Nhập số nguyên." }).int("Nhập số nguyên.");
const schema = z.object({ name: ten, menu_category_id: so.min(1, "Chọn danh mục."), components: z.array(z.object({
  name: ten, base_price_vnd: so.min(0, "Giá không được âm."), quantity: so.min(1, "Nhập số từ 1 trở lên."), takes_filling: z.boolean(),
})).min(1, "Cần ít nhất một thành phần.") });
const thanhPhanMoi = () => ({ name: "", base_price_vnd: NaN, quantity: 1, takes_filling: false });
const macDinh = () => ({ name: "", menu_category_id: NaN, components: [thanhPhanMoi()] });

export function FormThemMon({ categories }: { categories: DanhSachMon["categories"] }) {
  const id = useId();
  const luu = useThemMon();
  const chot = useRef(false);
  const [thongBao, setThongBao] = useState<string | null>(null);
  const form = useForm<ThemMon>({ resolver: zodResolver(schema), defaultValues: macDinh() });
  const { fields, append, remove } = useFieldArray({ control: form.control, name: "components" });
  const ban = form.formState.isSubmitting || luu.isPending;
  const cacO: FieldPath<ThemMon>[] = ["name", "menu_category_id", "components", ...fields.flatMap((_, i) =>
    ([`components.${i}.name`, `components.${i}.base_price_vnd`, `components.${i}.quantity`, `components.${i}.takes_filling`] as const))];

  async function gui(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (chot.current) return;
    chot.current = true;
    try {
      await form.handleSubmit(async (body) => {
        setThongBao(null);
        const r = await luu.mutateAsync(body);
        if (r.ok) {
          form.reset(macDinh());
          setThongBao(`Đã thêm món ${r.data.name}.`);
          return;
        }
        const message = loiSanPham(r.failure);
        const o = cacO.find((o) => o === oBiTuChoi(r.failure));
        if (o) form.setError(o, { type: "server", message });
        else setThongBao(message);
      })(event);
    } finally { chot.current = false; }
  }

  function oNhap(o: FieldPath<ThemMon>, nhan: string, min?: number) {
    const loi = form.getFieldState(o, form.formState).error?.message;
    return <Field data-invalid={!!loi}>
      <FieldLabel htmlFor={`${id}-${o}`}>{nhan}</FieldLabel>
      <Input id={`${id}-${o}`} type={min === undefined ? "text" : "number"} min={min} step={min === undefined ? undefined : 1}
        aria-invalid={!!loi} aria-describedby={loi ? `${id}-${o}-loi` : undefined}
        {...form.register(o, { valueAsNumber: min !== undefined })} />
      {loi && <FieldError id={`${id}-${o}-loi`}>{loi}</FieldError>}
    </Field>;
  }
  const loiDanhMuc = form.formState.errors.menu_category_id?.message;
  return <form aria-label="Thêm món" onSubmit={gui} noValidate className="space-y-4">
    <h2 className="text-lg font-semibold">Thêm món</h2>
    <fieldset disabled={ban} className="space-y-4">
      {oNhap("name", "Tên món")}
      <Field data-invalid={!!loiDanhMuc}>
        <FieldLabel htmlFor={`${id}-danh-muc`}>Danh mục</FieldLabel>
        <select id={`${id}-danh-muc`} className="h-9 w-full rounded-md border bg-background px-3"
          aria-invalid={!!loiDanhMuc} aria-describedby={loiDanhMuc ? `${id}-danh-muc-loi` : undefined}
          {...form.register("menu_category_id", { valueAsNumber: true })}>
          <option value="">Chọn danh mục</option>
          {categories.map((c) => <option key={c.menu_category_id} value={c.menu_category_id}>{c.name}</option>)}
        </select>
        {loiDanhMuc && <FieldError id={`${id}-danh-muc-loi`}>{loiDanhMuc}</FieldError>}
      </Field>
      {fields.map((f, i) => <fieldset key={f.id} className="space-y-3 rounded-md border p-4">
        <legend>Thành phần {i + 1}</legend>
        {oNhap(`components.${i}.name`, `Tên thành phần ${i + 1}`)}
        {oNhap(`components.${i}.base_price_vnd`, `Giá gốc thành phần ${i + 1} (đồng)`, 0)}
        {oNhap(`components.${i}.quantity`, `Số lượng thành phần ${i + 1}`, 1)}
        <Controller control={form.control} name={`components.${i}.takes_filling`} render={({ field, fieldState }) =>
          <Field data-invalid={!!fieldState.error}>
            <FieldLabel htmlFor={`${id}-nhan-${i}`}>Thành phần {i + 1} nhận nhân</FieldLabel>
            <Checkbox id={`${id}-nhan-${i}`} checked={field.value} onCheckedChange={(v) => field.onChange(v === true)}
              ref={field.ref} onBlur={field.onBlur} disabled={ban} aria-invalid={!!fieldState.error}
              aria-describedby={fieldState.error ? `${id}-nhan-${i}-loi` : undefined} />
            {fieldState.error && <FieldError id={`${id}-nhan-${i}-loi`}>{fieldState.error.message}</FieldError>}
          </Field>} />
        <Button type="button" variant="outline" disabled={fields.length === 1 || ban} onClick={() => remove(i)}>Bỏ thành phần {i + 1}</Button>
      </fieldset>)}
      {form.formState.errors.components?.message && <FieldError>{form.formState.errors.components.message}</FieldError>}
      <Button type="button" variant="outline" onClick={() => append(thanhPhanMoi())}>Thêm thành phần</Button>
    </fieldset>
    {thongBao && <Alert role="status"><AlertDescription>{thongBao}</AlertDescription></Alert>}
    <Button type="submit" disabled={ban}>{ban ? "Đang lưu…" : "Thêm món"}</Button>
  </form>;
}
