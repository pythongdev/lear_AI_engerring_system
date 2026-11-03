"use client";

import { useIsMutating } from "@tanstack/react-query";
import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useRef, useState, type ReactNode } from "react";
import { useForm } from "react-hook-form";
import { useRouter, useSearchParams } from "next/navigation";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogTitle } from "@/components/ui/dialog";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";
import { useTongQuan } from "./du-lieu-tong-quan";
import { useLoaiChi, useKhoanChi, useThemLoaiChi, useGhiKhoanChi, useSuaKhoanChi,
  useThemKhoanCon, useDoiTenLoai, useDoiTenKhoanCon, useXoaLoai, useXoaKhoanCon, useXoaKhoanChi,
  loiKhoanChi, oLoiKhoanChi, type KieuKhoanChi } from "./du-lieu-khoan-chi";
import "./khoan-chi.css";

const loi = { loi: loiKhoanChi, oLoi: oLoiKhoanChi };
const them = z.object({ name: chuMenu, paid_from_till: z.enum(["ket", "rieng"], { error: "Chọn nguồn tiền." }) });
const ghi = z.object({ expense_category_id: soMenu, expense_item_id: z.string(), amount_vnd: soMenu, paid_date: chuMenu, reason: z.string() });
const sua = ghi.extend({ reason: chuMenu });
const doiTen = z.object({ name: chuMenu, reason: chuMenu });
const lyDo = z.object({ reason: chuMenu });
type Loai = KieuKhoanChi["ExpenseCategory"];
type Khoan = KieuKhoanChi["Expense"];
type Con = KieuKhoanChi["ExpenseItem"];
type DuLieu = KieuKhoanChi["Expenses"];
type Mo = { kind: "tao"; category?: number; item?: number } | { kind: "sua"; entry: Khoan } | { kind: "them-loai" } |
  { kind: "them-con"; category: Loai } | { kind: "ten-loai"; category: Loai } | { kind: "ten-con"; item: Con } |
  { kind: "xoa-loai"; category: Loai } | { kind: "xoa-con"; item: Con } | { kind: "xoa-chi"; entry: Khoan };
const tien = new Intl.NumberFormat("vi-VN");
const money = (n: number) => `${tien.format(n)} đ`;
const nguonTien = (ket: boolean) => ket ? "Trả từ két" : "Tiền riêng";
const ngay = (s: string) => s.split("-").reverse().join("/");
const title = (m: Mo) => ({ tao: "Ghi khoản chi", sua: "Sửa khoản chi", "them-loai": "Thêm mục chi", "them-con": "Thêm khoản con", "ten-loai": "Sửa mục chi", "ten-con": "Sửa khoản con", "xoa-loai": "Xoá mục chi", "xoa-con": "Xoá khoản con", "xoa-chi": "Xoá khoản chi" })[m.kind];

function ThemLoai({ bao, dong }: { bao: (s: string) => void; dong: () => void }) {
  const luu = useThemLoaiChi();
  const id = useId();
  const form = useForm<z.infer<typeof them>>({ resolver: zodResolver(them), defaultValues: { name: "" } });
  const error = form.formState.errors.paid_from_till?.message;
  return <FormMenu {...loi} form={form} ten="Thêm loại chi" nut="Thêm loại chi" cacO={["name", "paid_from_till"]} dong={dong}
    gui={({ name, paid_from_till }) => luu.mutateAsync({ name, paid_from_till: paid_from_till === "ket" })}
    daLuu={() => { bao("Đã thêm loại chi."); dong(); }}>
    <OMenu form={form} o="name" nhan="Tên loại chi" />
    <Field data-invalid={!!error}><FieldLabel htmlFor={id}>Nguồn tiền</FieldLabel>
      <select id={id} defaultValue="" {...form.register("paid_from_till")} aria-invalid={!!error} aria-describedby={error ? `${id}-loi` : undefined}>
        <option value="">Chọn nguồn tiền</option><option value="ket">Trả từ két</option><option value="rieng">Tiền riêng</option>
      </select>{error && <FieldError id={`${id}-loi`}>{error}</FieldError>}
    </Field>
  </FormMenu>;
}
function FormKhoan({ khoan, category, item, loai, dong, bao }: { khoan?: Khoan; category?: number; item?: number; loai: Loai[]; dong: () => void; bao: (s: string) => void }) {
  const tao = useGhiKhoanChi();
  const doi = useSuaKhoanChi(khoan?.expense_id ?? 0);
  const id = useId();
  const form = useForm<z.infer<typeof sua>>({ resolver: zodResolver((khoan ? sua : ghi).superRefine((value, ctx) => {
    if (!khoan && !value.expense_item_id && (loai.find((l) => l.expense_category_id === value.expense_category_id)?.items?.length ?? 0) > 0) {
      ctx.addIssue({ code: "custom", path: ["expense_item_id"], message: "Chọn nguyên liệu / sản phẩm." });
    }
  })), defaultValues: {
    expense_category_id: khoan?.expense_category_id ?? category, expense_item_id: String(khoan?.expense_item_id ?? item ?? ""), amount_vnd: khoan?.amount_vnd, paid_date: khoan?.paid_date ?? "", reason: "",
  } });
  // The selected category controls the item menu; changing it clears the old association.
  // eslint-disable-next-line react-hooks/incompatible-library
  const selected = form.watch("expense_category_id");
  const selectedLoai = loai.find((l) => l.expense_category_id === selected);
  const items = selectedLoai?.items ?? [];
  const dateError = form.formState.errors.paid_date?.message;
  return <FormMenu {...loi} form={form} ten={khoan ? "Sửa khoản chi" : "Ghi khoản chi"} nut="Lưu khoản chi"
    cacO={["expense_category_id", "expense_item_id", "amount_vnd", "paid_date", "reason"]} dong={dong}
    gui={async ({ reason, expense_item_id, ...body }) => {
      const data = { ...body, ...(expense_item_id ? { expense_item_id: Number(expense_item_id) } : khoan ? { expense_item_id: null } : {}) };
      const r = await (khoan ? doi.mutateAsync({ ...data, reason }) : tao.mutateAsync(data));
      return r;
    }} daLuu={() => { bao(khoan ? "Đã sửa khoản chi." : "Đã ghi khoản chi."); dong(); }}>
    <Field data-invalid={!!form.formState.errors.expense_category_id}><FieldLabel htmlFor={`${id}-loai`}>Loại chi</FieldLabel>
      <select id={`${id}-loai`} {...form.register("expense_category_id", { valueAsNumber: true, onChange: () => form.setValue("expense_item_id", "") })} aria-invalid={!!form.formState.errors.expense_category_id} aria-describedby={form.formState.errors.expense_category_id ? `${id}-loai-error` : undefined}>
        <option value="">Chọn loại chi</option>{loai.map((l) => <option value={l.expense_category_id} key={l.expense_category_id}>{l.name}</option>)}
      </select>{form.formState.errors.expense_category_id && <FieldError id={`${id}-loai-error`}>{form.formState.errors.expense_category_id.message}</FieldError>}
    </Field>
    {items.length > 0 && <Field data-invalid={!!form.formState.errors.expense_item_id}><FieldLabel htmlFor={`${id}-con`}>Nguyên liệu / sản phẩm</FieldLabel><select id={`${id}-con`} {...form.register("expense_item_id")} aria-invalid={!!form.formState.errors.expense_item_id} aria-describedby={form.formState.errors.expense_item_id ? `${id}-con-error` : undefined}>
      <option value="">{khoan ? "Không chọn khoản con" : "Chọn nguyên liệu / sản phẩm"}</option>{items.map((i) => <option key={i.expense_item_id} value={i.expense_item_id}>{i.name}</option>)}
    </select>{form.formState.errors.expense_item_id && <FieldError id={`${id}-con-error`}>{form.formState.errors.expense_item_id.message}</FieldError>}</Field>}
    <OMenu form={form} o="amount_vnd" nhan="Số tiền (đồng)" so />
    <Field data-invalid={!!dateError}><FieldLabel htmlFor={`${id}-ngay`}>Ngày chi</FieldLabel><Input id={`${id}-ngay`} type="date" {...form.register("paid_date")} aria-invalid={!!dateError} aria-describedby={dateError ? `${id}-ngay-error` : undefined} />{dateError && <FieldError id={`${id}-ngay-error`}>{dateError}</FieldError>}</Field>
    {selectedLoai && <p className="kc-muted">Nguồn tiền: {nguonTien(selectedLoai.paid_from_till)}</p>}
    {khoan && <OMenu form={form} o="reason" nhan="Lý do" />}
  </FormMenu>;
}
function ThemCon({ category, dong, bao }: { category: Loai; dong: () => void; bao: (s: string) => void }) {
  const luu = useThemKhoanCon();
  const schema = z.object({ name: chuMenu });
  const form = useForm<z.infer<typeof schema>>({ resolver: zodResolver(schema), defaultValues: { name: "" } });
  return <FormMenu {...loi} form={form} ten="Thêm khoản con" nut="Thêm vào mục" dong={dong} cacO={["name"]}
    gui={(p) => luu.mutateAsync({ ...p, expense_category_id: category.expense_category_id })}
    daLuu={() => { bao("Đã thêm khoản con. Chọn Ghi chi để nhập tiền và ngày mua."); dong(); }}>
    <p className="kc-muted">Mục chi: {category.name}</p><OMenu form={form} o="name" nhan="Tên nguyên liệu / sản phẩm" />
  </FormMenu>;
}
function DoiTen({ target, data, dong, bao, suaTien }: { target: Extract<Mo, { kind: "ten-loai" | "ten-con" }>; data?: DuLieu; dong: () => void; bao: (s: string) => void; suaTien: (k: Khoan) => void }) {
  const busy = useIsMutating({ mutationKey: ["expense-write"] }) > 0;
  const category = target.kind === "ten-loai" ? target.category : undefined;
  const item = target.kind === "ten-con" ? target.item : undefined;
  const doiLoai = useDoiTenLoai(category?.expense_category_id ?? 0);
  const doiCon = useDoiTenKhoanCon(item?.expense_item_id ?? 0);
  const name = category?.name ?? item!.name;
  const form = useForm<z.infer<typeof doiTen>>({ resolver: zodResolver(doiTen), defaultValues: { name, reason: "" } });
  const records = data?.expenses.filter((k) => category ? k.expense_category_id === category.expense_category_id : k.expense_item_id === item!.expense_item_id) ?? [];
  records.sort((a, b) => b.paid_date.localeCompare(a.paid_date) || b.expense_id - a.expense_id);
  return <><FormMenu<z.infer<typeof doiTen>, Loai | Con> {...loi} form={form} ten="Đổi tên" nut="Lưu tên" dong={dong} cacO={["name", "reason"]}
    gui={(p) => category ? doiLoai.mutateAsync(p) : doiCon.mutateAsync(p)} daLuu={() => { bao("Đã đổi tên; giữ nguyên các khoản chi và số tiền."); dong(); }}>
    <OMenu form={form} o="name" nhan="Tên mới" /><OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu><section className="kc-history"><h3>Sửa tiền đã ghi</h3><p className="kc-muted">Các khoản trong khoảng ngày và bộ lọc đang chọn. Lưu tên trước khi chọn sửa tiền.</p>
    {records.length ? records.map((k) => <div className="kc-history-row" key={k.expense_id}><div><strong>{k.item_name || k.category_name}</strong><small>{ngay(k.paid_date)} · {k.person_name}</small></div><strong className="kc-money">{money(k.amount_vnd)}</strong><Button variant="outline" disabled={busy} onClick={() => {
      if (form.getValues("name").trim() !== name) { form.setError("name", { message: "Hãy lưu tên trước khi chọn sửa tiền." }); return; }
      suaTien(k);
    }}>Sửa tiền</Button></div>) : <p className="kc-muted">Chưa có khoản chi nào trong khoảng này.</p>}
  </section></>;
}
function Xoa({ target, dong, bao }: { target: Extract<Mo, { kind: "xoa-loai" | "xoa-con" | "xoa-chi" }>; dong: () => void; bao: (s: string) => void }) {
  const xoaLoai = useXoaLoai(target.kind === "xoa-loai" ? target.category.expense_category_id : 0);
  const xoaCon = useXoaKhoanCon(target.kind === "xoa-con" ? target.item.expense_item_id : 0);
  const xoaChi = useXoaKhoanChi(target.kind === "xoa-chi" ? target.entry.expense_id : 0);
  const form = useForm<z.infer<typeof lyDo>>({ resolver: zodResolver(lyDo), defaultValues: { reason: "" } });
  const name = target.kind === "xoa-loai" ? target.category.name : target.kind === "xoa-con" ? target.item.name : `${target.entry.item_name || target.entry.category_name} · ${money(target.entry.amount_vnd)} · ${ngay(target.entry.paid_date)}`;
  return <FormMenu {...loi} form={form} ten="Xác nhận xoá" nut="Xác nhận xoá" dong={dong} cacO={["reason"]}
    gui={(p) => target.kind === "xoa-loai" ? xoaLoai.mutateAsync(p) : target.kind === "xoa-con" ? xoaCon.mutateAsync(p) : xoaChi.mutateAsync(p)}
    daLuu={() => { bao("Đã xoá và cập nhật danh sách."); dong(); }}>
    <p>Xoá {name}?</p><p className="kc-muted">Thao tác giữ lại lịch sử. Mục và khoản con còn khoản chi sẽ bị chặn, kể cả khoản ngoài bộ lọc. Khoản chi của ngày đã đối soát không thể xoá.</p>
    <OMenu form={form} o="reason" nhan="Lý do xoá" />
  </FormMenu>;
}
function TrangThai({ query, ten, daGhi = false }: { query: { isPending: boolean; isError: boolean; isFetching: boolean; fetchStatus: string; dataUpdatedAt: number }; ten: string; daGhi?: boolean }) {
  return <>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : `Đang đọc ${ten}…`}</p>}
    {query.isError && <p role="alert">Chưa đọc được {ten}. {query.dataUpdatedAt > 0 && `Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`} {daGhi && "Đã ghi, chưa cập nhật được dữ liệu."}</p>}
    {!query.isPending && query.isFetching && <p role="status">Đang đọc lại {ten}…</p>}
  </>;
}
function MucChi({ category, data, from, to, selectedCategory, source, mo }: { category: Loai; data?: DuLieu; from?: string; to?: string; selectedCategory: string | null; source: string | null; mo: (m: Mo) => void }) {
  const [expanded, setExpanded] = useState(true);
  const [visible, setVisible] = useState(true);
  const [dates, setDates] = useState({ from: "", to: "" });
  const local = !!(dates.from || dates.to);
  const localFrom = dates.from && from ? (dates.from > from ? dates.from : from) : from;
  const localTo = dates.to && to ? (dates.to < to ? dates.to : to) : to;
  const invalid = !!(localFrom && localTo && localFrom > localTo);
  const query = useKhoanChi(local && !invalid ? localFrom : undefined, local && !invalid ? localTo : undefined, String(category.expense_category_id), source);
  const id = useId();
  const matches = !selectedCategory || Number(selectedCategory) === category.expense_category_id;
  const result = invalid || !matches ? undefined : local ? query.data : data;
  const total = result?.category_totals?.find((t) => t.expense_category_id === category.expense_category_id)?.total_vnd;
  return <article className="kc-category"><div className="kc-row"><h3>{category.name}</h3><Button variant="outline" aria-expanded={expanded} aria-controls={`${id}-body`} onClick={() => setExpanded(!expanded)}>{expanded ? "Ẩn mục" : "Hiện mục"}</Button></div>
    <small className="kc-muted">{(category.items ?? []).length} khoản con · {nguonTien(category.paid_from_till)}</small>
    <div id={`${id}-body`} hidden={!expanded}><div className="kc-actions kc-catalog-actions"><Button variant="outline" onClick={() => mo({ kind: "ten-loai", category })}>Sửa mục</Button><Button variant="outline" className="kc-danger" onClick={() => mo({ kind: "xoa-loai", category })}>Xoá mục</Button></div>
      <section className="kc-items"><div className="kc-row kc-items-head"><h4>Nguyên liệu / sản phẩm</h4><Button variant="outline" aria-expanded={visible} aria-controls={`${id}-items`} onClick={() => setVisible(!visible)}>{visible ? "Ẩn khoản con" : "Hiện khoản con"}</Button></div>
        <div className="kc-local-filter"><div className="kc-two"><Field><FieldLabel htmlFor={`${id}-from`}>Từ ngày · {category.name}</FieldLabel><Input id={`${id}-from`} type="date" value={dates.from} onChange={(e) => setDates({ ...dates, from: e.target.value })} /></Field><Field><FieldLabel htmlFor={`${id}-to`}>Đến ngày · {category.name}</FieldLabel><Input id={`${id}-to`} type="date" value={dates.to} onChange={(e) => setDates({ ...dates, to: e.target.value })} /></Field></div><small className="kc-muted">Lọc riêng mục này, trong phạm vi bộ lọc chung.</small>{invalid && <p role="alert">Ngày bắt đầu phải trước hoặc bằng ngày kết thúc, trong khoảng ngày chung.</p>}<Button variant="outline" onClick={() => setDates({ from: "", to: "" })}>Xoá lọc ngày</Button>{local && !invalid && <TrangThai query={query} ten="tổng theo mục" />}</div>
        <ul id={`${id}-items`} hidden={!visible}>{(category.items ?? []).length ? category.items!.map((item) => {
          const itemTotal = result?.item_totals?.find((t) => t.expense_item_id === item.expense_item_id);
          return <li key={item.expense_item_id}><div className="kc-item-copy"><strong>{item.name}</strong><small>{itemTotal?.last_paid_date ? `Ngày chi gần nhất: ${ngay(itemTotal.last_paid_date)}` : "Chưa có khoản chi trong khoảng ngày chọn"}</small></div><strong className="kc-money">{result || invalid || !matches ? money(itemTotal?.total_vnd ?? 0) : "—"}</strong><div className="kc-actions"><Button variant="outline" onClick={() => mo({ kind: "ten-con", item })}>Sửa</Button><Button variant="outline" className="kc-danger" onClick={() => mo({ kind: "xoa-con", item })}>Xoá</Button><Button variant="outline" onClick={() => mo({ kind: "tao", category: category.expense_category_id, item: item.expense_item_id })}>Ghi chi</Button></div></li>;
        }) : <li className="kc-muted">Chưa có khoản con. Thêm để bắt đầu theo dõi.</li>}</ul>
        <div className="kc-row kc-item-total"><span>Tổng chi trong kỳ</span><strong>{total === undefined && !invalid && matches && (local ? query.isPending || query.isError : !data) ? "—" : money(total ?? 0)}</strong></div><footer><Button variant="outline" onClick={() => mo({ kind: "them-con", category })}>＋ Thêm khoản con</Button></footer>
      </section>
    </div>
  </article>;
}
export function TrangKhoanChi() {
  const params = useSearchParams();
  const router = useRouter();
  const tongQuan = useTongQuan();
  const loai = useLoaiChi();
  const from = params.get("tu") ?? tongQuan.data?.sale_date;
  const to = params.get("den") ?? tongQuan.data?.sale_date;
  const query = useKhoanChi(from, to, params.get("loai"), params.get("nguon"));
  const [opened, setOpened] = useState<Mo | null>(null);
  const [ledger, setLedger] = useState(true);
  const [bao, setBao] = useState("");
  const focus = useRef<HTMLElement | null>(null);
  const heading = useRef<HTMLHeadingElement>(null);
  const busy = useIsMutating({ mutationKey: ["expense-write"] }) > 0;
  const id = useId();
  const close = () => setOpened(null);
  function open(m: Mo) { focus.current = document.activeElement instanceof HTMLElement ? document.activeElement : null; setOpened(m); }
  function loc(changes: Record<string, string>) {
    const next = new URLSearchParams(params.toString());
    Object.entries(changes).forEach(([key, value]) => { if (value) next.set(key, value); else next.delete(key); });
    router.replace(`/chu-quan/khoan-chi${next.size ? `?${next}` : ""}`);
  }
  const fields = [{ key: "tu", field: "from", label: "Từ ngày", value: from }, { key: "den", field: "to", label: "Đến ngày", value: to },
    { key: "loai", field: "expense_category_id", label: "Lọc loại chi", value: params.get("loai") }, { key: "nguon", field: "paid_from_till", label: "Lọc nguồn", value: params.get("nguon") }];
  const days = from && to ? Math.round((Date.parse(`${to}T00:00:00Z`) - Date.parse(`${from}T00:00:00Z`)) / 86400000) + 1 : 0;
  const categories = loai.data?.expense_categories ?? [];
  const grouped = new Map<number, Khoan[]>();
  query.data?.expenses.slice().sort((a, b) => b.paid_date.localeCompare(a.paid_date) || b.expense_id - a.expense_id).forEach((k) => grouped.set(k.expense_category_id, [...(grouped.get(k.expense_category_id) ?? []), k]));
  return <div className="kc-page">
    <header className="kc-row kc-header"><div><p className="kc-eyebrow">HÀNG &amp; TIỀN</p><h1 ref={heading} tabIndex={-1}>Khoản chi</h1><p className="kc-muted">Theo dõi từng khoản, rõ từng nguồn tiền.</p></div><div className="kc-actions"><Button variant="outline" onClick={() => open({ kind: "them-loai" })}>＋ Thêm mục chi</Button><Button disabled={!categories.length} onClick={() => open({ kind: "tao" })}>Ghi khoản chi</Button></div></header>
    <section className="kc-period" aria-label="Tổng tiền theo khoảng ngày"><h2>Tổng tiền theo khoảng ngày</h2><p className="kc-muted">Chọn nhanh số ngày, tính cả ngày kết thúc trong bộ lọc. Có thể sửa Từ ngày / Đến ngày bên dưới.</p><div className="kc-actions">{[7, 10, 14, 30].map((n) => <Button key={n} variant="outline" disabled={!to || Number.isNaN(Date.parse(`${to}T00:00:00Z`))} aria-pressed={days === n} onClick={() => { if (!to) return; const d = new Date(`${to}T00:00:00Z`); d.setUTCDate(d.getUTCDate() - n + 1); loc({ tu: d.toISOString().slice(0, 10), den: to }); }}>{({ 7: "1 tuần · 7 ngày", 10: "10 ngày", 14: "2 tuần · 14 ngày", 30: "30 ngày" })[n]}</Button>)}</div><p className="kc-muted">{days > 0 && from && to ? `${ngay(from)} – ${ngay(to)} · ${days} ngày · Tổng tiền áp dụng bộ lọc loại chi và nguồn tiền` : "Chọn khoảng ngày hợp lệ để xem tổng tiền."}</p></section>
    <section className="kc-overview" aria-label="Tổng chi trong kỳ"><small>Tổng chi trong kỳ</small><strong>{query.data ? money(query.data.total_vnd) : "—"}</strong><small>{query.data ? `${query.data.expenses.length} khoản chi theo bộ lọc` : "Đang chờ dữ liệu"}</small></section>
    <section className="kc-categories" aria-label="Loại chi"><div className="kc-row"><div><h2>Mục chi &amp; sản phẩm</h2><p className="kc-muted">Chọn từng nguyên liệu hoặc sản phẩm khi ghi khoản chi.</p></div><Button variant="outline" disabled={loai.isFetching} onClick={() => void loai.refetch()}>Đọc lại loại chi</Button></div><TrangThai query={loai} ten="loại chi" daGhi={bao.startsWith("Đã ")} />
      {loai.data && (categories.length ? <div className="kc-category-grid" role="list" aria-label="Danh sách loại chi">{categories.map((l) => <div role="listitem" key={l.expense_category_id}><MucChi category={l} data={query.data} from={from} to={to} selectedCategory={params.get("loai")} source={params.get("nguon")} mo={open} /></div>)}</div> : <p>Chưa có loại chi nào.</p>)}
    </section>
    <section className="kc-filter" aria-label="Bộ lọc sổ khoản chi"><div className="kc-row"><h2>Sổ khoản chi</h2><Button variant="outline" onClick={() => loc({ tu: "", den: "", loai: "", nguon: "" })}>Đặt lại bộ lọc</Button></div>
      {(params.get("tu") === null || params.get("den") === null) && <><TrangThai query={tongQuan} ten="ngày bán" />{tongQuan.isError && <Button variant="outline" onClick={() => void tongQuan.refetch()}>Đọc lại ngày bán</Button>}</>}
      <div className="kc-filters">{fields.map((f) => { const error = query.error?.kind === "rejected" && query.error.field === f.field ? loiKhoanChi(query.error) : undefined; const props = { id: `${id}-${f.key}`, value: f.value ?? "", onChange: (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => loc({ [f.key]: e.target.value }), "aria-invalid": !!error, "aria-describedby": error ? `${id}-${f.key}-loi` : undefined }; return <Field key={f.key} data-invalid={!!error}><FieldLabel htmlFor={props.id}>{f.label}</FieldLabel>{f.key === "tu" || f.key === "den" ? <Input {...props} type="date" /> : <select {...props}><option value="">Tất cả</option>{f.key === "loai" ? categories.map((l) => <option key={l.expense_category_id} value={l.expense_category_id}>{l.name}</option>) : <><option value="ket">Trả từ két</option><option value="rieng">Tiền riêng</option></>}</select>}{error && <FieldError id={`${id}-${f.key}-loi`}>{error}</FieldError>}</Field>; })}</div>
      {from !== undefined && to !== undefined && <><TrangThai query={query} ten="khoản chi" daGhi={bao.startsWith("Đã ")} /><Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại khoản chi</Button></>}
    </section>
    <section className="kc-ledger" aria-label="Các khoản chi"><div className="kc-row kc-section-head"><h2>Các khoản chi</h2><div className="kc-actions"><small className="kc-muted">Đơn vị: đồng</small><Button variant="outline" aria-expanded={ledger} aria-controls={`${id}-ledger`} onClick={() => setLedger(!ledger)}>{ledger ? "Ẩn" : "Hiện"}</Button></div></div><div id={`${id}-ledger`} hidden={!ledger}>
      {query.data && (query.data.expenses.length === 0 ? <p className="kc-empty">Không có khoản chi nào trong khoảng này.</p> : <div className="kc-table-wrap"><table><thead><tr><th>Ngày chi</th><th>Nguyên liệu / sản phẩm</th><th>Nguồn tiền</th><th className="kc-amount">Số tiền</th><th>Người ghi</th><th>Thao tác</th></tr></thead>{Array.from(grouped, ([category, entries]) => <tbody key={category}><tr className="kc-group"><th colSpan={6} scope="rowgroup"><div className="kc-row"><span>{entries[0].category_name} <small>· {entries.length} khoản chi</small></span><strong className="kc-money">{query.data!.category_totals?.find((t) => t.expense_category_id === category) ? money(query.data!.category_totals!.find((t) => t.expense_category_id === category)!.total_vnd) : "—"}</strong></div></th></tr>{entries.map((k) => <tr key={k.expense_id}><td className="kc-date">{ngay(k.paid_date)}</td><td><strong>{k.item_name || k.category_name}</strong>{!k.item_name && <small className="kc-muted">Chưa chọn khoản con</small>}</td><td><span className={`kc-badge${k.paid_from_till ? "" : " kc-personal"}`}>{nguonTien(k.paid_from_till)}</span></td><td className="kc-amount">{money(k.amount_vnd)}</td><td className="kc-who">{k.person_name}</td><td className="kc-edit"><div className="kc-actions"><Button variant="outline" onClick={() => open({ kind: "sua", entry: k })}>Sửa</Button><Button variant="outline" className="kc-danger" onClick={() => open({ kind: "xoa-chi", entry: k })}>Xoá</Button></div></td></tr>)}</tbody>)}</table></div>)}
    </div></section><p role="status" aria-live="polite" className="kc-feedback">{bao}</p>
    <Dialog open={opened !== null} onOpenChange={(v) => { if (!v && !busy) close(); }}><DialogContent showCloseButton={false} className="kc-dialog" aria-describedby={undefined} onCloseAutoFocus={(e) => { e.preventDefault(); (focus.current?.isConnected ? focus.current : heading.current)?.focus(); }} onInteractOutside={(e) => e.preventDefault()} onEscapeKeyDown={(e) => { if (busy) e.preventDefault(); }}>
      {opened && <><div className="kc-row"><DialogTitle>{title(opened)}</DialogTitle><Button variant="ghost" aria-label="Đóng" disabled={busy} onClick={close}>×</Button></div><DialogDescription className="sr-only">Nhập thông tin và lưu thay đổi.</DialogDescription><NoiDungHopThoai key={JSON.stringify(opened)} opened={opened} categories={categories} data={query.data} bao={setBao} dong={close} suaTien={(entry) => setOpened({ kind: "sua", entry })} /></>}
    </DialogContent></Dialog>
  </div>;
}
function NoiDungHopThoai({ opened, categories, data, bao, dong, suaTien }: { opened: Mo; categories: Loai[]; data?: DuLieu; bao: (s: string) => void; dong: () => void; suaTien: (k: Khoan) => void }): ReactNode {
  switch (opened.kind) {
    case "tao": return <FormKhoan category={opened.category} item={opened.item} loai={categories} dong={dong} bao={bao} />;
    case "sua": return <FormKhoan khoan={opened.entry} loai={categories} dong={dong} bao={bao} />;
    case "them-loai": return <ThemLoai dong={dong} bao={bao} />;
    case "them-con": return <ThemCon category={opened.category} dong={dong} bao={bao} />;
    case "ten-loai": case "ten-con": return <DoiTen target={opened} data={data} dong={dong} bao={bao} suaTien={suaTien} />;
    default: return <Xoa target={opened} dong={dong} bao={bao} />;
  }
}
