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
import { useCombo, useLapCombo, useDoiGiaCombo, useAnCombo, useDatPhuThuCombo, tienMenu, type KieuMenu } from "./du-lieu-danh-muc-combo";
import { useTopping, type NhomTopping } from "./du-lieu-topping";
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
// T-211: mức phụ thu theo món của combo (§8.9 lượt bảy · tám). Lựa chọn của mỗi món đọc từ GET /option-groups (menu_item_ids),
// bỏ lựa chọn đã ẩn; ô trống là chưa đặt (hàm giá cộng 0đ); chỉ gửi cặp đã đổi, kèm lý do. Màn không tính giá combo.
type O = { key: string; menu_item_id: number; menu_option_id: number; ten: string; hienCo?: number };
function FormDatPhuThu({ c, nhom, dong, bao }: { c: Combo; nhom: NhomTopping[]; dong: () => void; bao: Bao }) {
  const luu = useDatPhuThuCombo(c.menu_combo_id);
  const cacO: O[] = c.items.flatMap((mon) => nhom.filter((g) => g.menu_item_ids.includes(mon.menu_item_id)).flatMap((g) =>
    g.options.filter((o) => o.hidden_at === null).map((o) => ({
      key: `${mon.menu_item_id}-${o.menu_option_id}`, menu_item_id: mon.menu_item_id, menu_option_id: o.menu_option_id,
      ten: `${mon.item_name} · ${g.name} · ${o.name}`,
      hienCo: mon.surcharges.find((s) => s.menu_option_id === o.menu_option_id)?.surcharge_vnd,
    }))));
  const schema = z.object({ reason: chuMenu, muc: z.record(z.string(), z.string().trim()
    .regex(/^\d*$/, "Nhập số đồng, từ 0 trở lên.")) }).superRefine((body, ctx) => {
    if (!cacO.some((o) => body.muc[o.key] !== "" && Number(body.muc[o.key]) !== o.hienCo))
      ctx.addIssue({ code: "custom", path: ["reason"], message: "Chưa đổi mức nào." });
  });
  const form = useForm<{ reason: string; muc: Record<string, string> }>({ resolver: zodResolver(schema),
    defaultValues: { reason: "", muc: Object.fromEntries(cacO.map((o) => [o.key, o.hienCo === undefined ? "" : String(o.hienCo)])) } });
  const gui = ({ reason, muc }: { reason: string; muc: Record<string, string> }) => luu.mutateAsync({ reason, surcharges: cacO
    .filter((o) => muc[o.key] !== "" && Number(muc[o.key]) !== o.hienCo)
    .map((o) => ({ menu_item_id: o.menu_item_id, menu_option_id: o.menu_option_id, surcharge_vnd: Number(muc[o.key]) })) });
  if (cacO.length === 0) return <p>Các món của combo này không có lựa chọn nào để đặt phụ thu.</p>;
  return <FormMenu form={form} ten={`Đặt phụ thu ${c.name}`} nut="Lưu phụ thu" gui={gui} cacO={["reason"]} dong={dong}
    daLuu={(data) => { bao(`Đã đặt phụ thu cho ${data.name}.`); dong(); }}>
    <p className="text-sm text-muted-foreground">Mức cộng vào giá combo cho mỗi suất chọn lựa chọn ấy; để trống là chưa đặt (cộng 0 đ). Chỉ đặt ngoài giờ bán.</p>
    {cacO.map((o) => <OMenu key={o.key} form={form} o={`muc.${o.key}`} nhan={o.ten} />)}
    <OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function TheCombo({ c, nhom, bao }: { c: Combo; nhom?: NhomTopping[]; bao: Bao }) {
  const id = useId();
  const [sua, setSua] = useState<"gia" | "an" | "phu-thu" | null>(null);
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
        {nhom && <Button variant="outline" aria-label={`Đặt phụ thu ${c.name}`} onClick={() => setSua("phu-thu")}>Đặt phụ thu</Button>}
      </div>}
      {sua === "phu-thu" && nhom && <FormDatPhuThu c={c} nhom={nhom} dong={() => setSua(null)} bao={bao} />}
      {sua === "gia" && <FormDoiGiaCombo c={c} dong={() => setSua(null)} bao={bao} />}
      {sua === "an" && <FormAnCombo c={c} dong={() => setSua(null)} bao={bao} />}
    </CardContent>
  </Card></section>;
}
export function TrangCombo() {
  const query = useCombo();
  const sanPham = useSanPham();
  const topping = useTopping();
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
      {data.combos.map((c) => <TheCombo key={c.menu_combo_id} c={c} nhom={topping.data?.option_groups} bao={bao} />)}
      {sanPham.isPending && <p role="status">{sanPham.fetchStatus === "paused" ? "Đang chờ kết nối để đọc món." : "Đang đọc danh sách món…"}</p>}
      {sanPham.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách món.
        {sanPham.data && ` Đang hiện bản đọc trước, lúc ${new Date(sanPham.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`}
      </AlertDescription></Alert>}
      {mon && <Card><CardContent><FormLapCombo mon={mon} bao={bao} /></CardContent></Card>}
    </>}
  </div>;
}
