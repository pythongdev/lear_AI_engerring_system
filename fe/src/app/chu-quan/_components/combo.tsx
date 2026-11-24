"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useState } from "react";
import { useFieldArray, useForm } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import "./combo.css";
import { FieldError } from "@/components/ui/field";
import { useSanPham, type Mon } from "./du-lieu-san-pham";
import { useCombo, useLapCombo, useCapNhatCombo, useAnCombo, useDatPhuThuCombo, tienMenu, type KieuMenu } from "./du-lieu-danh-muc-combo";
import { useTopping, type NhomTopping } from "./du-lieu-topping";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";
import { FormAnhCombo } from "./form-anh-combo";
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
const capNhatSchema = lapSchema.safeExtend({ reason: chuMenu });
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
function FormCapNhatCombo({ c, mon, bao, dong }: { c: Combo; mon: Mon[]; bao: Bao; dong: () => void }) {
  const luu = useCapNhatCombo(c.menu_combo_id);
  const form = useForm<KieuMenu["UpdateMenuCombo"]>({ resolver: zodResolver(capNhatSchema), defaultValues: {
    name: c.name, price_vnd: c.price_vnd,
    items: c.items.map((item) => ({ menu_item_id: item.menu_item_id, quantity: item.quantity })), reason: "",
  } });
  const { fields, append, remove } = useFieldArray({ control: form.control, name: "items" });
  const options = [...mon, ...c.items.filter((item) => !mon.some((m) => m.menu_item_id === item.menu_item_id))
    .map((item) => ({ menu_item_id: item.menu_item_id, item_name: `${item.item_name} (ngừng bán)` }))];
  return <FormMenu form={form} ten={`Cập nhật ${c.name}`} nut="Lưu combo" gui={luu.mutateAsync}
    cacO={["name", "price_vnd", "reason", "items", ...fields.flatMap((_, i) => [`items.${i}.menu_item_id`, `items.${i}.quantity`] as const)]}
    dong={dong} daLuu={(data) => { bao(`Đã cập nhật combo ${data.name}. Giá combo ${tienMenu(data.price_vnd)}.`); dong(); }}>
    <p className="cb-muted">Tên, giá và thành phần được lưu cùng lúc. Chỉ cập nhật ngoài giờ bán.</p>
    <OMenu form={form} o="name" nhan="Tên combo" />
    <OMenu form={form} o="price_vnd" nhan="Giá combo (đồng)" so />
    <div><h3 className="cb-form-heading">Thành phần combo</h3><p className="cb-muted">Chọn món và số suất. Bỏ món khỏi danh sách sẽ giữ lịch sử đơn cũ.</p></div>
    {fields.map((f, i) => <fieldset key={f.id} className="cb-ingredient">
      <legend className="sr-only">Món {i + 1}</legend>
      <OMenu form={form} o={`items.${i}.menu_item_id`} nhan={`Món ${i + 1}`}
        options={options.map((m) => ({ id: m.menu_item_id, ten: m.item_name }))} />
      <OMenu form={form} o={`items.${i}.quantity`} nhan={`Số suất món ${i + 1}`} so />
      <Button type="button" variant="outline" aria-label={`Bỏ món ${i + 1}`} disabled={fields.length === 1 || form.formState.isSubmitting}
        onClick={() => remove(i)}>×</Button>
    </fieldset>)}
    {form.formState.errors.items?.message && <FieldError>{form.formState.errors.items.message}</FieldError>}
    <Button type="button" variant="outline" onClick={() => append(monMoi())}>Thêm món vào combo</Button>
    <OMenu form={form} o="reason" nhan="Lý do cập nhật" />
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
export function TrangCombo() {
  const query = useCombo();
  const sanPham = useSanPham();
  const topping = useTopping();
  const [thongBao, bao] = useState<string | null>(null);
  const [loc, setLoc] = useState("all");
  const [tim, setTim] = useState("");
  const [chon, setChon] = useState<number | null>(null);
  const [sua, setSua] = useState<"lap" | "cap-nhat" | "an" | null>(null);
  const data = query.data;
  const combos = data?.combos ?? [];
  const hien = combos.filter((c) => (loc === "all" || (c.hidden_at !== null) === (loc === "hidden")) && c.name.toLocaleLowerCase("vi").includes(tim.trim().toLocaleLowerCase("vi")));
  const c = combos.find((item) => item.menu_combo_id === chon);
  const mon = sanPham.data && [...sanPham.data.categories.flatMap((c) => c.items), ...sanPham.data.uncategorized_items].filter((m) => !m.discontinued);
  const dong = () => setSua(null);
  return <div className="combo-shell">
    <header className="cb-header"><h1>Combo {data && <span className="cb-badge">{combos.length} combo</span>}</h1>
      <div className="cb-actions"><Button variant="outline" disabled={query.isFetching || sanPham.isFetching} onClick={() => { void query.refetch(); void sanPham.refetch(); void topping.refetch(); }}>Đọc lại danh sách</Button><Button disabled={!mon} onClick={() => { setChon(null); setSua("lap"); }}>＋ Lập combo</Button></div>
    </header>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh sách combo…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách combo.
      {data ? ` Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.` : " Hãy thử lại."}
      {thongBao && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
    {thongBao && <p className="cb-feedback" role="status">{thongBao}</p>}
    {data && <>
      {query.isFetching && <p role="status">Đang đọc lại danh sách combo…</p>}
      <section className="cb-panel" aria-label="Danh sách combo">
        <div className="cb-toolbar"><div className="cb-tabs" aria-label="Lọc combo">{[["all", "Tất cả"], ["visible", "Hiển thị"], ["hidden", "Đã ẩn"]].map(([id, ten]) => <button key={id} aria-pressed={loc === id} onClick={() => setLoc(id)}>{ten}</button>)}</div><input type="search" aria-label="Tìm tên combo" placeholder="Tìm tên combo…" value={tim} onChange={(e) => setTim(e.target.value)} /></div>
        {hien.length === 0 ? <p className="cb-empty">{combos.length === 0 ? "Chưa có combo." : "Không có combo phù hợp."}</p> :
          <div className="cb-table-scroll" role="region" aria-label="Bảng combo" tabIndex={0}>
            <table><thead><tr><th scope="col">Combo</th><th scope="col">Trạng thái</th><th scope="col">Giá</th><th scope="col">Thành phần</th><th scope="col">Thao tác</th></tr></thead>
              <tbody>{hien.map((item) => <tr key={item.menu_combo_id}>
                <td><div className="cb-product"><AnhSanPham ten={item.name} imageUrl={item.image_url} anhVersion={query.dataUpdatedAt} combo className="cb-photo" /><span>{item.name}</span></div></td>
                <td>{item.hidden_at ? <span className="cb-badge cb-hidden">Đã ẩn</span> : "Hiển thị"}</td>
                <td><span className="cb-price">{tienMenu(item.price_vnd)}</span></td>
                <td><ThanhPhan c={item} /></td>
                <td><div className="cb-actions"><Button variant="outline" aria-label={`Chi tiết ${item.name}`} onClick={() => { setChon(item.menu_combo_id); dong(); }}>Chi tiết</Button>{item.hidden_at === null && <Button variant="outline" aria-label={`Sửa ${item.name}`} disabled={!mon} onClick={() => { setChon(item.menu_combo_id); setSua("cap-nhat"); }}>Sửa</Button>}</div></td>
              </tr>)}</tbody>
            </table>
          </div>}
      </section>
    </>}
    {sanPham.isPending && <p role="status">{sanPham.fetchStatus === "paused" ? "Đang chờ kết nối để đọc món." : "Đang đọc danh sách món…"}</p>}
    {sanPham.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách món.
      {sanPham.data && ` Đang hiện bản đọc trước, lúc ${new Date(sanPham.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`}
    </AlertDescription></Alert>}
    <Dialog open={!!c && sua === null} onOpenChange={(open) => { if (!open) setChon(null); }}>
      <DialogContent className="cb-dialog cb-drawer" aria-describedby={undefined}>
        {c && <><DialogTitle>Chi tiết {c.name}</DialogTitle>
          <AnhSanPham key={c.menu_combo_id} ten={c.name} imageUrl={c.image_url} anhVersion={query.dataUpdatedAt} combo className="cb-drawer-photo" />
          <div className="cb-drawer-summary"><span className={`cb-badge${c.hidden_at ? " cb-hidden" : ""}`}>{c.hidden_at ? "Đã ẩn" : "Hiển thị"}</span><strong className="cb-price">{tienMenu(c.price_vnd)}</strong></div>
          <section className="cb-drawer-section"><h2>Thành phần combo</h2><ThanhPhan c={c} /></section>
          {c.hidden_at === null && <section className="cb-drawer-section"><h2>Thao tác</h2><div className="cb-actions"><Button disabled={!mon} onClick={() => setSua("cap-nhat")}>Sửa combo</Button><Button variant="outline" aria-label={`Ẩn ${c.name}`} onClick={() => setSua("an")}>Ẩn combo</Button></div></section>}
        </>}
      </DialogContent>
    </Dialog>
    <Dialog open={sua !== null} onOpenChange={(open) => { if (!open) dong(); }}><DialogContent className="cb-dialog" showCloseButton={false}>
      <div className="cb-row"><DialogTitle>{sua === "lap" ? "Lập combo" : sua === "cap-nhat" ? "Sửa combo" : "Ẩn combo"}</DialogTitle><button aria-label="Đóng hộp thoại" onClick={dong}>×</button></div>
      <DialogDescription>{sua === "lap" ? "Chọn món và số suất. Giá combo được nhập riêng." : c?.name}</DialogDescription>
      {sua === "lap" && mon && <FormLapCombo mon={mon} bao={bao} dong={dong} />}
      {sua === "cap-nhat" && c && <div key={c.menu_combo_id} className="cb-edit-sections">
        <section aria-label="Tên, giá và món"><h3>Tên, giá và món</h3>
          {mon && <FormCapNhatCombo c={c} mon={mon} bao={bao} dong={dong} />}
        </section>
        <section aria-label="Ảnh combo"><h3>Ảnh combo</h3><FormAnhCombo c={c} bao={bao} dong={dong} /></section>
        <section aria-label="Phụ thu theo món"><h3>Phụ thu theo món</h3>
          {topping.data ? <FormDatPhuThu c={c} nhom={topping.data.option_groups} dong={dong} bao={bao} />
            : <p role="status">{topping.isError ? "Chưa đọc được lựa chọn phụ thu. Hãy đóng hộp thoại và đọc lại." : "Đang đọc lựa chọn phụ thu…"}</p>}
        </section>
      </div>}
      {sua === "an" && c && <FormAnCombo key={c.menu_combo_id} c={c} dong={dong} bao={bao} />}
    </DialogContent></Dialog>
  </div>;
}
