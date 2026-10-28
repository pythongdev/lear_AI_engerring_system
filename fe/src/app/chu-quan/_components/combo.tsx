"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { useFieldArray, useForm } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { Dialog, DialogContent, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { mucChuQuan } from "./muc-chu-quan";
import "./combo.css";
import { FieldError } from "@/components/ui/field";
import { useSanPham, type Mon } from "./du-lieu-san-pham";
import { useCombo, useLapCombo, useDoiGiaCombo, useAnCombo, useDatPhuThuCombo, tienMenu, type KieuMenu } from "./du-lieu-danh-muc-combo";
import { useTopping, type NhomTopping } from "./du-lieu-topping";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";
import { AnhSanPham } from "./anh-san-pham";

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

function FormLapCombo({ mon, bao, dong }: { mon: Mon[]; bao: Bao; dong: () => void }) {
  const luu = useLapCombo();
  const form = useForm<KieuMenu["CreateMenuCombo"]>({ resolver: zodResolver(lapSchema), defaultValues: macDinh() });
  const { fields, append, remove } = useFieldArray({ control: form.control, name: "items" });
  return <FormMenu form={form} ten="Lập combo" nut="Lập combo" gui={luu.mutateAsync} dong={dong}
    cacO={["name", "price_vnd", "items", ...fields.flatMap((_, i) => [`items.${i}.menu_item_id`, `items.${i}.quantity`] as const)]}
    daLuu={(data) => { form.reset(macDinh()); bao(`Đã lập combo ${data.name}.`); dong(); }}>
    <OMenu form={form} o="name" nhan="Tên combo" />
    <OMenu form={form} o="price_vnd" nhan="Giá combo (đồng)" so />
    <div><h3 className="cb-form-heading">Thành phần combo</h3><p className="cb-muted">Chọn món và số suất cho từng thành phần.</p></div>
    {fields.map((f, i) => <fieldset key={f.id} className="cb-ingredient">
      <legend className="sr-only">Món {i + 1}</legend>
      <OMenu form={form} o={`items.${i}.menu_item_id`} nhan={`Món ${i + 1}`}
        options={mon.map((m) => ({ id: m.menu_item_id, ten: m.item_name }))} />
      <OMenu form={form} o={`items.${i}.quantity`} nhan={`Số suất món ${i + 1}`} so />
      <Button type="button" variant="outline" aria-label={`Bỏ món ${i + 1}`} disabled={fields.length === 1 || form.formState.isSubmitting}
        onClick={() => remove(i)}>×</Button>
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
function ThanhPhan({ c }: { c: Combo }) {
  return <ul className="cb-components">{c.items.map((mon) => <li key={mon.menu_item_id}>
    <span>{mon.item_name} × {mon.quantity}</span>
    {mon.discontinued && <small>Ngừng bán</small>}
    {mon.surcharges.map((s) => <small key={s.menu_option_id}>{s.option_group_name} · {s.option_name}: {tienMenu(s.surcharge_vnd)}</small>)}
  </li>)}</ul>;
}
function DieuHuongCombo() {
  const nhom = [
    { ten: "Hôm nay", routes: ["/chu-quan", "/chu-quan/van-hanh", "/chu-quan/tong-ket"] },
    { ten: "Thực đơn", routes: ["/chu-quan/san-pham", "/chu-quan/menu-gia", "/chu-quan/danh-muc", "/chu-quan/combo", "/chu-quan/topping"] },
    { ten: "Con người", routes: ["/chu-quan/nhan-vien", "/chu-quan/giao-viec", "/chu-quan/dao-tao"] },
    { ten: "Hàng & tiền", routes: ["/chu-quan/nguyen-lieu", "/chu-quan/kho", "/chu-quan/khoan-chi"] },
  ];
  return <nav className="cb-nav" aria-label="Trang chủ quán">
    <Link className="cb-brand" href="/chu-quan"><b>BT</b><span>Bánh cuốn Bà Thanh<small>Chủ quán</small></span></Link>
    {nhom.map((n) => <details key={n.ten}><summary>{n.ten}</summary><div>{n.routes.map((r) => {
      const muc = mucChuQuan.find((m) => m.route === r)!;
      return <Link key={r} href={r} aria-current={r === "/chu-quan/combo" ? "page" : undefined}>{muc.nhan}</Link>;
    })}</div></details>)}
  </nav>;
}
export function TrangCombo() {
  const query = useCombo();
  const sanPham = useSanPham();
  const topping = useTopping();
  const [thongBao, bao] = useState<string | null>(null);
  const [loc, setLoc] = useState("all");
  const [tim, setTim] = useState("");
  const [chon, setChon] = useState<number | null>(null);
  const [sua, setSua] = useState<"lap" | "gia" | "an" | "phu-thu" | null>(null);
  const data = query.data;
  const combos = data?.combos ?? [];
  const hien = combos.filter((c) => (loc === "all" || (c.hidden_at !== null) === (loc === "hidden")) && c.name.toLocaleLowerCase("vi").includes(tim.trim().toLocaleLowerCase("vi")));
  const c = hien.find((c) => c.menu_combo_id === chon) ?? hien[0];
  const mon = sanPham.data && [...sanPham.data.categories.flatMap((c) => c.items), ...sanPham.data.uncategorized_items].filter((m) => !m.discontinued);
  const dong = () => setSua(null);
  return <div className="combo-shell"><DieuHuongCombo /><div className="cb-page">
    <header className="cb-header"><div><p className="cb-eyebrow">THỰC ĐƠN / COMBO</p><h1>Combo</h1><p className="cb-muted">Ghép những món ngon thành một lựa chọn trọn vẹn.</p></div>
      <div className="cb-actions"><Button variant="outline" disabled={query.isFetching || sanPham.isFetching} onClick={() => { void query.refetch(); void sanPham.refetch(); void topping.refetch(); }}>↻ Đọc lại</Button><Button disabled={!mon} onClick={() => setSua("lap")}>＋ Lập combo</Button></div>
    </header>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh sách combo…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách combo.
      {data ? ` Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.` : " Hãy thử lại."}
      {thongBao && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
    {thongBao && <p className="cb-feedback" role="status">{thongBao}</p>}
    {data && <>
      {query.isFetching && <p role="status">Đang đọc lại danh sách combo…</p>}
      <section className="cb-overview" aria-label="Tóm tắt danh sách">
        <article><small>Tổng combo</small><strong>{combos.length}</strong><p>Trong danh sách combo</p></article>
        <article className="cb-attention"><small>Đang hiển thị</small><strong>{combos.filter((c) => c.hidden_at === null).length}</strong><p>Có trong thực đơn</p></article>
        <article><small>Đang ẩn</small><strong>{combos.filter((c) => c.hidden_at !== null).length}</strong><p>Tạm ẩn khỏi thực đơn</p></article>
      </section>
      <div className="cb-layout"><section aria-label="Danh sách combo">
        <div className="cb-toolbar"><div className="cb-tabs" aria-label="Lọc combo">{[["all", "Tất cả"], ["visible", "Hiển thị"], ["hidden", "Đã ẩn"]].map(([id, ten]) => <button key={id} aria-pressed={loc === id} onClick={() => setLoc(id)}>{ten}</button>)}</div><input type="search" aria-label="Tìm tên combo" placeholder="Tìm tên combo…" value={tim} onChange={(e) => setTim(e.target.value)} /></div>
        <div className="cb-list">{hien.map((item) => <section className="cb-item" aria-label={item.name} key={item.menu_combo_id} data-selected={c?.menu_combo_id === item.menu_combo_id}>
          <button className="cb-select" aria-label={`Xem ${item.name}`} aria-pressed={c?.menu_combo_id === item.menu_combo_id} onClick={() => { setChon(item.menu_combo_id); dong(); }}>
            <AnhSanPham ten={item.name} combo className="cb-photo" />
            <span className="cb-row"><span className="cb-badge">{item.hidden_at ? "Đã ẩn" : "Hiển thị"}</span></span>
            <span className="cb-name">{item.name}</span>
          </button>
          <ThanhPhan c={item} /><div className="cb-total"><small>Giá combo</small><strong className="cb-price">{tienMenu(item.price_vnd)}</strong></div>
        </section>)}</div>
        {hien.length === 0 && <p className="cb-empty">{combos.length === 0 ? "Chưa có combo." : "Không có combo phù hợp."}</p>}
      </section><aside className="cb-detail" aria-label="Chi tiết combo">{c ? <>
        <AnhSanPham key={c.menu_combo_id} ten={c.name} combo className="cb-photo" /><h2>{c.name}</h2><span className="cb-badge">{c.hidden_at ? "Đã ẩn" : "Đang hiển thị"}</span>
        <p className="cb-price">{tienMenu(c.price_vnd)}</p><h3>THÀNH PHẦN COMBO</h3><ThanhPhan c={c} />
        {c.hidden_at === null && <div className="cb-actions"><Button aria-label={`Đổi giá ${c.name}`} onClick={() => setSua("gia")}>Đổi giá</Button><Button variant="outline" aria-label={`Ẩn ${c.name}`} onClick={() => setSua("an")}>Ẩn combo</Button>{topping.data && <Button variant="outline" aria-label={`Đặt phụ thu ${c.name}`} onClick={() => setSua("phu-thu")}>Đặt phụ thu</Button>}</div>}
      </> : <p className="cb-muted">Chọn một combo để xem chi tiết.</p>}</aside></div>
    </>}
    {sanPham.isPending && <p role="status">{sanPham.fetchStatus === "paused" ? "Đang chờ kết nối để đọc món." : "Đang đọc danh sách món…"}</p>}
    {sanPham.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách món.
      {sanPham.data && ` Đang hiện bản đọc trước, lúc ${new Date(sanPham.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`}
    </AlertDescription></Alert>}
    <Dialog open={sua !== null} onOpenChange={(open) => { if (!open) dong(); }}><DialogContent className="cb-dialog" showCloseButton={false}>
      <div className="cb-row"><div><p className="cb-eyebrow">COMBO</p><DialogTitle>{sua === "lap" ? "Lập combo" : sua === "gia" ? "Đổi giá combo" : sua === "an" ? "Ẩn combo" : "Đặt phụ thu combo"}</DialogTitle></div><button aria-label="Đóng hộp thoại" onClick={dong}>×</button></div>
      <DialogDescription>{sua === "lap" ? "Chọn món và số suất. Giá combo được nhập riêng." : c?.name}</DialogDescription>
      {sua === "lap" && mon && <FormLapCombo mon={mon} bao={bao} dong={dong} />}
      {sua === "gia" && c && <FormDoiGiaCombo key={c.menu_combo_id} c={c} dong={dong} bao={bao} />}
      {sua === "an" && c && <FormAnCombo key={c.menu_combo_id} c={c} dong={dong} bao={bao} />}
      {sua === "phu-thu" && c && topping.data && <FormDatPhuThu key={c.menu_combo_id} c={c} nhom={topping.data.option_groups} dong={dong} bao={bao} />}
    </DialogContent></Dialog>
  </div></div>;
}
