"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useState } from "react";
import { useFieldArray, useForm } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { FieldError } from "@/components/ui/field";
import { useSanPham, type Mon } from "./du-lieu-san-pham";
import { useCombo, useLapCombo, useDoiGiaCombo, useAnCombo, tienMenu, type KieuMenu } from "./du-lieu-danh-muc-combo";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";

type Combo = KieuMenu["MenuCombo"];
type Bao = (message: string) => void;
const lapSchema = z.object({ name: chuMenu, price_vnd: soMenu,
  items: z.array(z.object({ menu_item_id: soMenu, quantity: soMenu })).min(1, "Cần ít nhất một món."),
}).superRefine((body, ctx) => {
  const daChon = new Set<number>();
  body.items.forEach((item, i) => {
    if (daChon.has(item.menu_item_id)) ctx.addIssue({ code: "custom", path: ["items", i, "menu_item_id"], message: "Món bị trùng. Hãy chọn món khác." });
    daChon.add(item.menu_item_id);
  });
});
const giaSchema = z.object({ price_vnd: soMenu, reason: chuMenu });
const anSchema = z.object({ reason: chuMenu });
const monMoi = () => ({ menu_item_id: NaN, quantity: 1 });
const macDinh = () => ({ name: "", price_vnd: NaN, items: [monMoi()] });

function FormLapCombo({ mon, bao }: { mon: Mon[]; bao: Bao }) {
  const luu = useLapCombo();
  const form = useForm<KieuMenu["CreateMenuCombo"]>({ resolver: zodResolver(lapSchema), defaultValues: macDinh() });
  const { fields, append, remove } = useFieldArray({ control: form.control, name: "items" });
  return <FormMenu form={form} ten="Lập combo" nut="Lập combo" gui={luu.mutateAsync}
    cacO={["name", "price_vnd", "items", ...fields.flatMap((_, i) => [`items.${i}.menu_item_id`, `items.${i}.quantity`] as const)]}
    daLuu={(data) => { form.reset(macDinh()); bao(`Đã lập combo ${data.name}.`); }}>
    <h2 className="text-lg font-semibold">Lập combo</h2>
    <OMenu form={form} o="name" nhan="Tên combo" />
    <OMenu form={form} o="price_vnd" nhan="Giá combo (đồng)" so />
    {fields.map((f, i) => <fieldset key={f.id} className="space-y-3 rounded-md border p-4">
      <legend>Món {i + 1}</legend>
      <OMenu form={form} o={`items.${i}.menu_item_id`} nhan={`Món ${i + 1}`}
        options={mon.map((m) => ({ id: m.menu_item_id, ten: m.item_name }))} />
      <OMenu form={form} o={`items.${i}.quantity`} nhan={`Số suất món ${i + 1}`} so />
      <Button type="button" variant="outline" disabled={fields.length === 1 || form.formState.isSubmitting}
        onClick={() => remove(i)}>Bỏ món {i + 1}</Button>
    </fieldset>)}
    {form.formState.errors.items?.message && <FieldError>{form.formState.errors.items.message}</FieldError>}
    <Button type="button" variant="outline" onClick={() => append(monMoi())}>Thêm món vào combo</Button>
  </FormMenu>;
}
function FormDoiGiaCombo({ c, dong, bao }: { c: Combo; dong: () => void; bao: Bao }) {
  const luu = useDoiGiaCombo(c.menu_combo_id);
  const form = useForm<KieuMenu["UpdateMenuComboPrice"]>({ resolver: zodResolver(giaSchema), defaultValues: { price_vnd: c.price_vnd, reason: "" } });
  return <FormMenu form={form} ten={`Đổi giá ${c.name}`} nut="Lưu giá" gui={luu.mutateAsync}
    cacO={["price_vnd", "reason"]} dong={dong} daLuu={(data) => { bao(`Đã đổi giá ${data.name} thành ${tienMenu(data.price_vnd)}.`); dong(); }}>
    <OMenu form={form} o="price_vnd" nhan="Giá mới (đồng)" so />
    <OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function FormAnCombo({ c, dong, bao }: { c: Combo; dong: () => void; bao: Bao }) {
  const luu = useAnCombo(c.menu_combo_id);
  const form = useForm<KieuMenu["HideMenuCombo"]>({ resolver: zodResolver(anSchema), defaultValues: { reason: "" } });
  return <FormMenu form={form} ten={`Ẩn ${c.name}`} nut="Xác nhận ẩn" gui={luu.mutateAsync}
    cacO={["reason"]} dong={dong} daLuu={(data) => { bao(`Đã ẩn combo ${data.name}.`); dong(); }}>
    <OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function TheCombo({ c, bao }: { c: Combo; bao: Bao }) {
  const id = useId();
  const [sua, setSua] = useState<"gia" | "an" | null>(null);
  return <section aria-labelledby={id}><Card>
    <CardHeader><CardTitle><h2 id={id}>{c.name}</h2></CardTitle></CardHeader>
    <CardContent className="space-y-4">
      <p>{tienMenu(c.price_vnd)}</p>
      <ul>{c.items.map((mon) => <li key={mon.menu_item_id} className="space-y-2 border-b py-3 last:border-0">
        <p>{mon.item_name} × {mon.quantity}{mon.discontinued && <span className="ml-2 text-sm text-muted-foreground">Ngừng bán</span>}</p>
        {mon.surcharges.map((s) => <p key={s.menu_option_id} className="text-sm text-muted-foreground">
          {s.option_group_name} · {s.option_name}: {tienMenu(s.surcharge_vnd)}
        </p>)}
      </li>)}</ul>
      {!sua && <div className="flex gap-2">
        <Button variant="outline" aria-label={`Đổi giá ${c.name}`} onClick={() => setSua("gia")}>Đổi giá</Button>
        <Button variant="outline" aria-label={`Ẩn ${c.name}`} onClick={() => setSua("an")}>Ẩn</Button>
      </div>}
      {sua === "gia" && <FormDoiGiaCombo c={c} dong={() => setSua(null)} bao={bao} />}
      {sua === "an" && <FormAnCombo c={c} dong={() => setSua(null)} bao={bao} />}
    </CardContent>
  </Card></section>;
}
export function TrangCombo() {
  const query = useCombo();
  const sanPham = useSanPham();
  const [thongBao, bao] = useState<string | null>(null);
  const data = query.data;
  const mon = sanPham.data && [...sanPham.data.categories.flatMap((c) => c.items), ...sanPham.data.uncategorized_items]
    .filter((m) => !m.discontinued);
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Combo</h1>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh sách combo…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách combo.
      {data ? ` Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.` : " Hãy thử lại."}
      {thongBao && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
    <Button variant="outline" disabled={query.isFetching || sanPham.isFetching}
      onClick={() => { void query.refetch(); void sanPham.refetch(); }}>Đọc lại danh sách</Button>
    {thongBao && <p role="status">{thongBao}</p>}
    {data && <>
      {query.isFetching && <p role="status">Đang đọc lại danh sách combo…</p>}
      {data.combos.length === 0 && <p>Chưa có combo.</p>}
      {data.combos.map((c) => <TheCombo key={c.menu_combo_id} c={c} bao={bao} />)}
      {sanPham.isPending && <p role="status">{sanPham.fetchStatus === "paused" ? "Đang chờ kết nối để đọc món." : "Đang đọc danh sách món…"}</p>}
      {sanPham.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách món.
        {sanPham.data && ` Đang hiện bản đọc trước, lúc ${new Date(sanPham.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`}
      </AlertDescription></Alert>}
      {mon && <Card><CardContent><FormLapCombo mon={mon} bao={bao} /></CardContent></Card>}
    </>}
  </div>;
}
