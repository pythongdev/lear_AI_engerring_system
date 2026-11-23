"use client";

import { useIsMutating } from "@tanstack/react-query";
import { zodResolver } from "@hookform/resolvers/zod";
import { Fragment, useId, useRef, useState, type FormEvent, type ReactNode } from "react";
import { useForm } from "react-hook-form";
import { useRouter, useSearchParams } from "next/navigation";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogTitle } from "@/components/ui/dialog";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";
import { useTongQuan } from "./du-lieu-tong-quan";
import { useLoaiChi, useKhoanChi, useLichSuKhoanCon, useThemLoaiChi, useGhiKhoanChi, useSuaKhoanChi,
  useThemKhoanCon, useThemKhoanConCoLuong, useLichSuSuaTien, useDoiTenLoai, useDoiTenKhoanCon, useXoaLoai, useXoaKhoanCon, useXoaKhoanChi,
  loiKhoanChi, oLoiKhoanChi, type KieuKhoanChi } from "./du-lieu-khoan-chi";
import { useNguyenLieu, useSoCacNguyenLieu, useSoNguyenLieu, useDatDonVi, useGhiConSo, useSuaConSo,
  loiNguyenLieu, oLoiNguyenLieu, type KieuNguyenLieu } from "./du-lieu-nguyen-lieu";
import { useDatTiLeKho, loiKho } from "./du-lieu-kho";
import { useXepNguyenLieu, useDungLaiKhoanCon, useChuyenMucKhoanCon } from "./du-lieu-khoan-chi";
import "./khoan-chi.css";

const loi = { loi: loiKhoanChi, oLoi: oLoiKhoanChi };
const them = z.object({ name: chuMenu, paid_from_till: z.enum(["ket", "rieng"], { error: "Chọn nguồn tiền." }), tracks_supply: z.enum(["co", "khong"], { error: "Chọn có theo dõi lượng hay không." }) });
const ghi = z.object({ expense_category_id: soMenu, expense_item_id: z.string(), amount_vnd: soMenu, paid_date: chuMenu, received_date: z.string(), reason: z.string() });
const sua = ghi.extend({ reason: chuMenu });
const doiTen = z.object({ name: chuMenu, reason: chuMenu });
const lyDo = z.object({ reason: chuMenu });
const conSo = z.string().trim().regex(/^(0|[1-9][0-9]{0,8})(\.[0-9]{1,3})?$/, "Nhập số không âm, tối đa 9 chữ số nguyên; dùng dấu chấm, tối đa 3 chữ số lẻ.");
const tiLe = z.string().trim().regex(/^(0(\.[0-9]{1,6})?|1(\.0{1,6})?)$/, "Nhập số từ 0 đến 1, dùng dấu chấm, tối đa 6 chữ số lẻ.");
const ghiLuong = z.object({ entry_date: chuMenu, kind: z.enum(["purchased", "used"], { error: "Chọn loại con số." }), measure: conSo });
const suaLuong = z.object({ measure: conSo, reason: chuMenu });
const datDonVi = z.object({ purchase_unit: chuMenu });
const datTiLe = z.object({ reminder_ratio: tiLe, reason: chuMenu });
const chonMuc = z.object({ expense_category_id: z.string().min(1, "Chọn mục chi.") });
const chuyenMuc = chonMuc.extend({ reason: chuMenu });
type Loai = KieuKhoanChi["ExpenseCategory"];
type Khoan = KieuKhoanChi["Expense"];
type Con = KieuKhoanChi["ExpenseItem"];
type DuLieu = KieuKhoanChi["Expenses"];
type NguyenLieu = KieuNguyenLieu["SupplyItem"];
type DongSo = KieuNguyenLieu["SupplyDayEntry"];
type Mo = { kind: "tao"; category?: number; item?: number } | { kind: "sua"; entry: Khoan } | { kind: "them-loai" } |
  { kind: "them-con"; category: Loai } | { kind: "ten-loai"; category: Loai } | { kind: "ten-con"; item: Con } |
  { kind: "xoa-loai"; category: Loai } | { kind: "xoa-con"; item: Con } | { kind: "xoa-chi"; entry: Khoan } |
  { kind: "ghi-luong" | "dat-don-vi" | "dat-ti-le" | "chuyen-muc" | "xep-muc" | "dung-lai"; supply: NguyenLieu } |
  { kind: "sua-luong"; supply: NguyenLieu; entry: DongSo };
const tien = new Intl.NumberFormat("vi-VN");
const money = (n: number) => `${tien.format(n)} đ`;
const nguonTien = (ket: boolean) => ket ? "Trả từ két" : "Tiền riêng";
const ngay = (s: string) => s.split("-").reverse().join("/");
const luong = (s: string) => s.replaceAll(".", ",");
function uocTinh(item: NguyenLieu) {
  switch (item.usage_estimate.status) {
    case "ready": return item.usage_estimate.days_left === "0.0" ? "Dưới 0,1 ngày" : `Khoảng ${luong(item.usage_estimate.days_left ?? "")} ngày`;
    case "out_by_ledger": return item.purchased_total === "0" && item.used_total === "0" ? "Chưa nhập" : "Hết theo sổ";
    case "no_usage": return "Chưa ghi ngày dùng";
    case "zero_usage": return "Chưa tính được (dùng 0)";
  }
}
function luongCon(item: NguyenLieu) {
  return item.purchased_total === "0" && item.used_total === "0" ? "Chưa nhập" : `${luong(item.balance)}${item.purchase_unit ? ` ${item.purchase_unit}` : ""}`;
}
function theoNgay(expenses: Khoan[]) {
  const groups = new Map<string, Khoan[]>();
  expenses.slice().sort((a, b) => b.paid_date.localeCompare(a.paid_date) || b.expense_id - a.expense_id)
    .forEach((expense) => {
      const entries = groups.get(expense.paid_date) ?? [];
      entries.push(expense);
      groups.set(expense.paid_date, entries);
    });
  return groups;
}
function bayNgayCuoi(s: string) {
  const date = new Date(`${s}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() - 6);
  return date.toISOString().slice(0, 10);
}
function baMuoiNgayCuoi(s: string) {
  const date = new Date(`${s}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() - 29);
  return date.toISOString().slice(0, 10);
}
const title = (m: Mo) => m.kind === "xoa-con" && m.item.supply_item_id ? "Ngừng dùng" : ({ tao: "Ghi khoản chi", sua: "Sửa khoản chi", "them-loai": "Thêm mục chi", "them-con": "Thêm khoản con", "ten-loai": "Sửa mục chi", "ten-con": "Sửa khoản con", "xoa-loai": "Xoá mục chi", "xoa-con": "Xoá khoản con", "xoa-chi": "Xoá khoản chi", "ghi-luong": "Ghi lượng", "sua-luong": "Sửa con số", "dat-don-vi": "Đặt đơn vị", "dat-ti-le": "Đặt tỉ lệ nhắc", "chuyen-muc": "Chuyển mục", "xep-muc": "Xếp vào mục", "dung-lai": "Dùng lại" })[m.kind];

function ThemLoai({ loai, bao, dong }: { loai: Loai[]; bao: (s: string) => void; dong: () => void }) {
  const luu = useThemLoaiChi();
  const id = useId();
  const form = useForm<z.infer<typeof them>>({ resolver: zodResolver(them), defaultValues: { name: "" } });
  const error = form.formState.errors.paid_from_till?.message;
  const trackError = form.formState.errors.tracks_supply?.message;
  return <><ul aria-label="Các mục chi hiện có" className="kc-existing-categories">{loai.map((l) => <li key={l.expense_category_id}>{l.name} · {nguonTien(l.paid_from_till)}{l.tracks_supply && " · Theo dõi lượng"}</li>)}</ul>
  <FormMenu {...loi} form={form} ten="Thêm loại chi" nut="Thêm loại chi" cacO={["name", "paid_from_till", "tracks_supply"]} dong={dong}
    gui={({ name, paid_from_till, tracks_supply }) => luu.mutateAsync({ name, paid_from_till: paid_from_till === "ket", tracks_supply: tracks_supply === "co" })}
    daLuu={() => { bao("Đã thêm loại chi."); dong(); }}>
    <OMenu form={form} o="name" nhan="Tên loại chi" />
    <Field data-invalid={!!error}><FieldLabel htmlFor={id}>Nguồn tiền</FieldLabel>
      <select id={id} defaultValue="" {...form.register("paid_from_till")} aria-invalid={!!error} aria-describedby={error ? `${id}-loi` : undefined}>
        <option value="">Chọn nguồn tiền</option><option value="ket">Trả từ két</option><option value="rieng">Tiền riêng</option>
      </select>{error && <FieldError id={`${id}-loi`}>{error}</FieldError>}
    </Field>
    <Field data-invalid={!!trackError}><FieldLabel htmlFor={`${id}-track`}>Theo dõi lượng</FieldLabel>
      <select id={`${id}-track`} defaultValue="" {...form.register("tracks_supply")} aria-invalid={!!trackError} aria-describedby={trackError ? `${id}-track-loi` : undefined}>
        <option value="">Chọn có hay không</option><option value="co">Có — nguyên liệu, theo dõi lượng</option><option value="khong">Không</option>
      </select>{trackError && <FieldError id={`${id}-track-loi`}>{trackError}</FieldError>}
    </Field>
  </FormMenu></>;
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
    expense_category_id: khoan?.expense_category_id ?? category, expense_item_id: String(khoan?.expense_item_id ?? item ?? ""), amount_vnd: khoan?.amount_vnd, paid_date: khoan?.paid_date ?? "", received_date: khoan?.received_date ?? "", reason: "",
  } });
  // The selected category controls the item menu; changing it clears the old association.
  // eslint-disable-next-line react-hooks/incompatible-library
  const selected = form.watch("expense_category_id");
  const selectedLoai = loai.find((l) => l.expense_category_id === selected);
  const items = selectedLoai?.items ?? [];
  const dateError = form.formState.errors.paid_date?.message;
  return <FormMenu {...loi} form={form} ten={khoan ? "Sửa khoản chi" : "Ghi khoản chi"} nut="Lưu khoản chi"
    cacO={["expense_category_id", "expense_item_id", "amount_vnd", "paid_date", "received_date", "reason"]} dong={dong}
    gui={async ({ reason, expense_item_id, received_date, ...body }) => {
      const data = { ...body, ...(expense_item_id ? { expense_item_id: Number(expense_item_id) } : khoan ? { expense_item_id: null } : {}), ...(selectedLoai?.tracks_supply && received_date ? { received_date } : {}) };
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
    {selectedLoai?.tracks_supply && <Field><FieldLabel htmlFor={`${id}-nhap`}>Ngày nhập hàng</FieldLabel><Input id={`${id}-nhap`} type="date" {...form.register("received_date")} /><small className="kc-muted">Ngày hàng về; có thể khác ngày chi tiền.</small></Field>}
    {selectedLoai && <p className="kc-muted">Nguồn tiền: {nguonTien(selectedLoai.paid_from_till)}</p>}
    {khoan && <OMenu form={form} o="reason" nhan="Lý do" />}
  </FormMenu>;
}
function ThemCon({ category, dong, bao }: { category: Loai; dong: () => void; bao: (s: string) => void }) {
  const luu = useThemKhoanCon();
  const luuCoLuong = useThemKhoanConCoLuong();
  const luuTien = useGhiKhoanChi();
  const [createdId, setCreatedId] = useState<number | null>(null);
  const [createdName, setCreatedName] = useState("");
  const schema = z.object({ name: chuMenu, amount_vnd: z.string().refine((s) => !s || (Number.isSafeInteger(Number(s)) && Number(s) > 0), "Nhập số nguyên dương."), paid_date: z.string(), received_date: z.string() })
    .superRefine((value, ctx) => {
      if (createdId !== null && !value.amount_vnd) ctx.addIssue({ code: "custom", path: ["amount_vnd"], message: "Nhập số tiền để hoàn tất khoản chi của khoản con đã thêm." });
      if (value.amount_vnd && !value.paid_date) ctx.addIssue({ code: "custom", path: ["paid_date"], message: "Chọn ngày chi khi ghi tiền." });
    });
  const form = useForm<z.infer<typeof schema>>({ resolver: zodResolver(schema), defaultValues: { name: "", amount_vnd: "", paid_date: "", received_date: "" } });
  const [uncertain, setUncertain] = useState(false);
  const [message, setMessage] = useState("");
  const lock = useRef(false);
  const id = useId();
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (lock.current || uncertain) return;
    lock.current = true;
    try {
      await form.handleSubmit(async ({ name, amount_vnd, paid_date, received_date }) => {
        setMessage("");
        const expense = amount_vnd ? { amount_vnd: Number(amount_vnd), paid_date, ...(category.tracks_supply && received_date ? { received_date } : {}) } : undefined;
        if (category.tracks_supply) {
          const r = await luuCoLuong.mutateAsync({ expense_category_id: category.expense_category_id, name, ...(expense ? { expense } : {}) });
          if (!r.ok) {
            if (oLoiKhoanChi(r.failure) === "name") form.setError("name", { type: "server", message: loiKhoanChi(r.failure) });
            else setMessage(loiKhoanChi(r.failure));
            if (r.failure.kind !== "rejected") setUncertain(true);
            return;
          }
          bao(expense ? `Đã thêm khoản con ${name} và đã ghi khoản chi.` : `Đã thêm khoản con ${name}.`);
          dong();
          return;
        }
        let itemId = createdId;
        if (itemId === null) {
          const r = await luu.mutateAsync({ expense_category_id: category.expense_category_id, name });
          if (!r.ok) {
            if (oLoiKhoanChi(r.failure) === "name") form.setError("name", { type: "server", message: loiKhoanChi(r.failure) });
            else setMessage(loiKhoanChi(r.failure));
            if (r.failure.kind !== "rejected") setUncertain(true);
            return;
          }
          itemId = r.data.expense_item_id;
          setCreatedId(itemId);
          setCreatedName(name);
        }
        if (!expense) { bao(`Đã thêm khoản con ${name}.`); dong(); return; }
        const r = await luuTien.mutateAsync({ expense_category_id: category.expense_category_id, expense_item_id: itemId, amount_vnd: expense.amount_vnd, paid_date: expense.paid_date });
        if (!r.ok) {
          if (r.failure.kind === "rejected") setMessage(`Đã thêm khoản con ${createdName || name}, nhưng chưa ghi được khoản chi: ${loiKhoanChi(r.failure).replace(/[.!?]$/, "")}. Sửa rồi bấm lại để chỉ ghi khoản chi.`);
          else { setMessage(`Đã thêm khoản con ${createdName || name}. Chưa xác nhận được khoản chi — hãy đóng hộp, đọc lại khoản chi rồi ghi lại nếu chưa có.`); setUncertain(true); }
          return;
        }
        bao(`Đã ghi khoản chi cho khoản con ${createdName || name}.`);
        dong();
      })(event);
    } finally { lock.current = false; }
  }
  const busy = form.formState.isSubmitting;
  const dateError = form.formState.errors.paid_date?.message;
  return <form aria-label="Thêm khoản con" onSubmit={submit} noValidate className="space-y-4">
    <fieldset disabled={busy} className="space-y-4">
      <p className="kc-muted">Mục chi: {category.name}</p><Field data-invalid={!!form.formState.errors.name}><FieldLabel htmlFor={`${id}-name`}>Tên nguyên liệu / sản phẩm</FieldLabel><Input id={`${id}-name`} readOnly={createdId !== null} {...form.register("name")} aria-invalid={!!form.formState.errors.name} aria-describedby={form.formState.errors.name ? `${id}-name-error` : undefined} />{form.formState.errors.name && <FieldError id={`${id}-name-error`}>{form.formState.errors.name.message}</FieldError>}</Field>
      <Field data-invalid={!!form.formState.errors.amount_vnd}><FieldLabel htmlFor={`${id}-amount`}>Tiền mua sản phẩm (đồng, không bắt buộc)</FieldLabel><Input id={`${id}-amount`} type="number" min="1" step="1" {...form.register("amount_vnd")} aria-invalid={!!form.formState.errors.amount_vnd} />{form.formState.errors.amount_vnd && <FieldError>{form.formState.errors.amount_vnd.message}</FieldError>}</Field>
      <Field data-invalid={!!dateError}><FieldLabel htmlFor={`${id}-date`}>Ngày chi</FieldLabel><Input id={`${id}-date`} type="date" {...form.register("paid_date")} aria-invalid={!!dateError} aria-describedby={dateError ? `${id}-date-error` : undefined} />{dateError && <FieldError id={`${id}-date-error`}>{dateError}</FieldError>}</Field>
      {category.tracks_supply && <Field><FieldLabel htmlFor={`${id}-received`}>Ngày nhập hàng</FieldLabel><Input id={`${id}-received`} type="date" {...form.register("received_date")} /><small className="kc-muted">Ngày hàng về; chỉ cần khi ghi tiền mua nguyên liệu.</small></Field>}
    </fieldset>
    {message && <p role="status">{message}</p>}
    <div className="flex gap-2"><Button type="submit" disabled={busy || uncertain}>{busy ? "Đang lưu…" : "Thêm vào mục"}</Button><Button type="button" variant="outline" disabled={busy} onClick={dong}>Huỷ</Button></div>
  </form>;
}
function DoiTen({ target, dong, bao, suaTien }: { target: Extract<Mo, { kind: "ten-loai" | "ten-con" }>; dong: () => void; bao: (s: string) => void; suaTien: (k: Khoan) => void }) {
  const busy = useIsMutating({ mutationKey: ["expense-write"] }) > 0;
  const category = target.kind === "ten-loai" ? target.category : undefined;
  const item = target.kind === "ten-con" ? target.item : undefined;
  const doiLoai = useDoiTenLoai(category?.expense_category_id ?? 0);
  const doiCon = useDoiTenKhoanCon(item?.expense_item_id ?? 0);
  const name = category?.name ?? item!.name;
  const form = useForm<z.infer<typeof doiTen>>({ resolver: zodResolver(doiTen), defaultValues: { name, reason: "" } });
  const id = useId();
  const lastDate = category?.last_paid_date ?? item?.last_paid_date;
  const history = useLichSuSuaTien(category ? { expense_category_id: category.expense_category_id } : { expense_item_id: item!.expense_item_id }, lastDate ? bayNgayCuoi(lastDate) : "", lastDate ?? "", !!lastDate);
  const records = history.data?.expenses.slice().sort((a, b) => b.paid_date.localeCompare(a.paid_date) || b.expense_id - a.expense_id) ?? [];
  return <><FormMenu<z.infer<typeof doiTen>, Loai | Con> {...loi} form={form} ten="Đổi tên" nut="Lưu tên" dong={dong} cacO={["name", "reason"]}
    gui={(p) => category ? doiLoai.mutateAsync(p) : doiCon.mutateAsync(p)} daLuu={() => { bao("Đã đổi tên; giữ nguyên các khoản chi và số tiền."); dong(); }}>
    <OMenu form={form} o="name" nhan="Tên mới" /><OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu><section className="kc-history" aria-labelledby={id}><h3 id={id}>Sửa tiền đã ghi</h3><p className="kc-muted">Các khoản trong bảy ngày tới lần chi gần nhất, trên mọi bộ lọc. Lưu tên trước khi chọn sửa tiền.</p>
    {!lastDate ? <p className="kc-muted">{category ? "Mục này chưa có lần chi nào." : "Khoản con này chưa có lần chi nào."}</p> : history.isError ? <p role="alert">Chưa đọc được lịch sử chi. Hãy thử đọc lại.</p> : history.isPending ? <p role="status">Đang đọc lịch sử chi…</p> : records.length ? records.map((k) => <div className="kc-history-row" key={k.expense_id}><div><strong>{k.item_name || k.category_name}</strong><small>{ngay(k.paid_date)} · {k.person_name}</small></div><strong className="kc-money">{money(k.amount_vnd)}</strong><Button variant="outline" disabled={busy} onClick={() => {
      if (form.getValues("name").trim() !== name) { form.setError("name", { message: "Hãy lưu tên trước khi chọn sửa tiền." }); return; }
      suaTien(k);
    }}>Sửa tiền</Button></div>) : <p className="kc-muted">Chưa có khoản chi nào trong bảy ngày này.</p>}
  </section></>;
}
function Xoa({ target, dong, bao }: { target: Extract<Mo, { kind: "xoa-loai" | "xoa-con" | "xoa-chi" }>; dong: () => void; bao: (s: string) => void }) {
  const xoaLoai = useXoaLoai(target.kind === "xoa-loai" ? target.category.expense_category_id : 0);
  const xoaCon = useXoaKhoanCon(target.kind === "xoa-con" ? target.item.expense_item_id : 0);
  const xoaChi = useXoaKhoanChi(target.kind === "xoa-chi" ? target.entry.expense_id : 0);
  const form = useForm<z.infer<typeof lyDo>>({ resolver: zodResolver(lyDo), defaultValues: { reason: "" } });
  const name = target.kind === "xoa-loai" ? target.category.name : target.kind === "xoa-con" ? target.item.name : `${target.entry.item_name || target.entry.category_name} · ${money(target.entry.amount_vnd)} · ${ngay(target.entry.paid_date)}`;
  const stopping = target.kind === "xoa-con" && !!target.item.supply_item_id;
  return <FormMenu {...loi} form={form} ten={stopping ? "Ngừng dùng" : "Xác nhận xoá"} nut={stopping ? "Ngừng dùng" : "Xác nhận xoá"} dong={dong} cacO={["reason"]}
    gui={(p) => target.kind === "xoa-loai" ? xoaLoai.mutateAsync(p) : target.kind === "xoa-con" ? xoaCon.mutateAsync(p) : xoaChi.mutateAsync(p)}
    daLuu={() => { bao(stopping ? `Đã ngừng dùng ${name}.` : "Đã xoá và cập nhật danh sách."); dong(); }}>
    {stopping ? <p>Ngừng dùng {name}? Lịch sử tiền và lượng được giữ; có thể dùng lại sau.</p> : <><p>Xoá {name}?</p><p className="kc-muted">Thao tác giữ lại lịch sử. Mục và khoản con còn khoản chi sẽ bị chặn, kể cả khoản ngoài bộ lọc. Khoản chi của ngày đã đối soát không thể xoá.</p></>}
    <OMenu form={form} o="reason" nhan={stopping ? "Lý do" : "Lý do xoá"} />
  </FormMenu>;
}
function TrangThai({ query, ten, daGhi = false }: { query: { isPending: boolean; isError: boolean; isFetching: boolean; fetchStatus: string; dataUpdatedAt: number }; ten: string; daGhi?: boolean }) {
  return <>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : `Đang đọc ${ten}…`}</p>}
    {query.isError && <p role="alert">Chưa đọc được {ten}. {query.dataUpdatedAt > 0 && `Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`} {daGhi && "Đã ghi, chưa cập nhật được dữ liệu."}</p>}
    {!query.isPending && query.isFetching && <p role="status">Đang đọc lại {ten}…</p>}
  </>;
}
function LichSuKhoanCon({ item, opened }: { item: Con; opened: boolean }) {
  const fallback = item.last_paid_date ? { from: bayNgayCuoi(item.last_paid_date), to: item.last_paid_date } : { from: "", to: "" };
  const [chosen, setChosen] = useState<{ from: string; to: string } | null>(null);
  const dates = chosen ?? fallback;
  const id = useId();
  const query = useLichSuKhoanCon(item.expense_item_id, dates.from, dates.to, opened && !!item.last_paid_date);
  const missing = !dates.from || !dates.to;
  const invalid = !missing && dates.from > dates.to;
  const rows = query.data?.expenses.slice().sort((a, b) => b.paid_date.localeCompare(a.paid_date) || b.expense_id - a.expense_id) ?? [];
  return <section className="kc-item-history" aria-label={`Lịch sử chi ${item.name}`}>
    <div className="kc-two"><Field><FieldLabel htmlFor={`${id}-from`}>Từ ngày</FieldLabel><Input id={`${id}-from`} type="date" value={dates.from} disabled={!item.last_paid_date} onChange={(e) => setChosen({ ...dates, from: e.target.value })} /></Field>
      <Field><FieldLabel htmlFor={`${id}-to`}>Đến ngày</FieldLabel><Input id={`${id}-to`} type="date" value={dates.to} disabled={!item.last_paid_date} onChange={(e) => setChosen({ ...dates, to: e.target.value })} /></Field></div>
    <Button variant="outline" disabled={!item.last_paid_date} onClick={() => setChosen(null)}>Xem lại 7 ngày</Button>
    {!item.last_paid_date ? <p className="kc-muted">Khoản con này chưa có lần chi nào.</p> : missing ? <p role="alert">Chọn cả Từ ngày và Đến ngày.</p> : invalid ? <p role="alert">Từ ngày phải trước hoặc bằng Đến ngày.</p> : <>
      {query.isError ? <p role="alert">Chưa đọc được lịch sử chi. Hãy thử đọc lại.</p> : query.isPending ? <p role="status">Đang đọc lịch sử chi…</p> : rows.length ? <>
        <p>{rows.length} lần chi từ {ngay(dates.from)} đến {ngay(dates.to)}.</p>
        <div className="kc-table-wrap"><table className="kc-data-table kc-history-table" aria-label={`Ngày đã chi ${item.name}`}><thead><tr><th>Ngày chi</th><th>Số tiền · người ghi</th></tr></thead><tbody>{rows.map((entry) => <tr key={entry.expense_id}><td>{ngay(entry.paid_date)}</td><td>{money(entry.amount_vnd)} · {entry.person_name}</td></tr>)}</tbody></table></div>
      </> : <p className="kc-muted">Chưa có lần chi nào trong khoảng ngày đã chọn.</p>}
    </>}
  </section>;
}
function DongKhoanCon({ item, category, result, entries, mo }: { item: Con; category: Loai; result?: DuLieu; entries: Khoan[]; mo: (m: Mo) => void }) {
  const [expanded, setExpanded] = useState(false);
  const [historyOpen, setHistoryOpen] = useState(false);
  const id = useId();
  const total = result?.item_totals?.find((t) => t.expense_item_id === item.expense_item_id);
  const count = entries.filter((entry) => entry.expense_item_id === item.expense_item_id).length;
  return <><tr><td><button type="button" className="kc-item-name" aria-expanded={expanded} aria-controls={`${id}-detail`} onClick={() => setExpanded(!expanded)}>{item.name}</button></td><td>{total?.last_paid_date ? ngay(total.last_paid_date) : "Chưa chi trong kỳ"}</td><td className="kc-amount">{result ? money(total?.total_vnd ?? 0) : "—"}</td></tr>
    <tr id={`${id}-detail`} className="kc-item-detail-row" hidden={!expanded}><td colSpan={3}>{expanded && <div className="kc-item-detail"><dl><div><dt>Nguồn tiền</dt><dd>{nguonTien(category.paid_from_till)}</dd></div><div><dt>Số lần chi trong kỳ</dt><dd>{count} lần</dd></div><div><dt>Tổng chi trong kỳ</dt><dd>{result ? money(total?.total_vnd ?? 0) : "—"}</dd></div></dl>
      {total?.last_paid_date && <small className="kc-muted">Ngày chi gần nhất: {ngay(total.last_paid_date)}</small>}
      <div className="kc-actions"><Button variant="outline" onClick={() => mo({ kind: "ten-con", item })}>Sửa tên</Button><Button variant="outline" className="kc-danger" onClick={() => mo({ kind: "xoa-con", item })}>Xoá</Button><Button variant="outline" onClick={() => mo({ kind: "tao", category: category.expense_category_id, item: item.expense_item_id })}>Ghi chi</Button><Button variant="outline" aria-expanded={historyOpen} aria-controls={`${id}-history`} onClick={() => setHistoryOpen(!historyOpen)}>Lịch sử chi</Button></div>
      <div id={`${id}-history`} hidden={!historyOpen}><LichSuKhoanCon item={item} opened={historyOpen} /></div>
    </div>}</td></tr></>;
}
function BangNgayMuc({ category, result }: { category: Loai; result?: DuLieu }) {
  const entries = result?.expenses.filter((entry) => entry.expense_category_id === category.expense_category_id) ?? [];
  return <div className="kc-table-wrap"><table className="kc-data-table kc-day-table" aria-label={`Chi theo ngày của ${category.name}`}><thead><tr><th>Ngày chi</th><th>Các khoản chi trong ngày</th></tr></thead><tbody>{entries.length ? Array.from(theoNgay(entries), ([date, day]) => <tr key={date}><td>{ngay(date)}</td><td><ul className="kc-day-list">{day.map((entry) => <li key={entry.expense_id}><span>{entry.item_name || "Chưa chọn khoản con"}</span> <strong>{money(entry.amount_vnd)}</strong> <span>· {entry.person_name}</span></li>)}</ul></td></tr>) : <tr><td colSpan={2}>Chưa có khoản chi trong phạm vi này.</td></tr>}</tbody></table></div>;
}
function LichSuSuDung({ item, supplyId }: { item: Con; supplyId: number }) {
  const id = useId();
  const query = useSoNguyenLieu(supplyId, true, Infinity);
  const used = query.data?.entries.filter((entry) => entry.kind === "used").sort((a, b) => b.entry_date.localeCompare(a.entry_date)) ?? [];
  const latest = used[0]?.entry_date ?? "";
  const fallback = { from: latest ? bayNgayCuoi(latest) : "", to: latest };
  const [chosen, setChosen] = useState<{ from: string; to: string } | null>(null);
  const dates = chosen ?? fallback;
  const missing = !!latest && (!dates.from || !dates.to);
  const invalid = !missing && !!dates.from && !!dates.to && dates.from > dates.to;
  const rows = used.filter((entry) => entry.entry_date >= dates.from && entry.entry_date <= dates.to);
  return <section className="kc-item-history" aria-label={`Lịch sử sử dụng ${item.name}`}>
    {query.isError ? <p role="alert">Chưa đọc được sổ của {item.name}. Hãy thử đọc lại.</p> : query.isPending ? <p role="status">Đang đọc sổ của {item.name}…</p> : <>
      <div className="kc-two"><Field><FieldLabel htmlFor={`${id}-from`}>Từ ngày</FieldLabel><Input id={`${id}-from`} type="date" value={dates.from} onChange={(e) => setChosen({ ...dates, from: e.target.value })} /></Field>
        <Field><FieldLabel htmlFor={`${id}-to`}>Đến ngày</FieldLabel><Input id={`${id}-to`} type="date" value={dates.to} onChange={(e) => setChosen({ ...dates, to: e.target.value })} /></Field></div>
      <Button variant="outline" onClick={() => setChosen(null)}>Xem lại 7 ngày</Button>
      {!latest ? <p className="kc-muted">Chưa có lần sử dụng nào.</p> : missing ? <p role="alert">Chọn cả Từ ngày và Đến ngày.</p> : invalid ? <p role="alert">Từ ngày phải trước hoặc bằng Đến ngày.</p> : <>
        <p>{rows.length} lần dùng từ {ngay(dates.from)} đến {ngay(dates.to)}.</p>
        <div className="kc-table-wrap"><table className="kc-data-table kc-history-table" aria-label={`Ngày đã dùng ${item.name}`}><thead><tr><th>Ngày dùng</th><th>Lượng đã dùng</th></tr></thead><tbody>{rows.map((entry) => <tr key={entry.supply_day_entry_id}><td>{ngay(entry.entry_date)}</td><td>{luong(entry.measure)}{query.data.purchase_unit ? ` ${query.data.purchase_unit}` : ""}</td></tr>)}</tbody></table></div>
      </>}
    </>}
  </section>;
}
function SoLuong({ supply, mo }: { supply: NguyenLieu; mo: (m: Mo) => void }) {
  const query = useSoNguyenLieu(supply.supply_item_id, true, Infinity);
  return <section className="kc-item-history" aria-label={`Sổ lượng ${supply.name}`}>
    {query.isError ? <p role="alert">Chưa đọc được sổ của {supply.name}. Hãy thử đọc lại.</p> : query.isPending ? <p role="status">Đang đọc sổ của {supply.name}…</p> : query.data.entries.length === 0 ? <p>Chưa ghi con số nào.</p> :
      <div className="kc-table-wrap kc-ledger-wrap"><table className="kc-data-table kc-supply-ledger" aria-label={`Các con số của ${supply.name}`}><thead><tr><th>Ngày</th><th>Loại</th><th>Con số</th><th>Người ghi</th><th>Sửa</th></tr></thead><tbody>
        {query.data.entries.map((entry) => <tr key={entry.supply_day_entry_id}><td>{ngay(entry.entry_date)}</td><td>{entry.kind === "purchased" ? "Mua vào" : "Đã dùng"}</td><td>{luong(entry.measure)}{query.data.purchase_unit ? ` ${query.data.purchase_unit}` : ""}</td><td>{entry.person_name}</td><td><Button variant="outline" aria-label={`Sửa con số ${entry.kind === "purchased" ? "Mua vào" : "Đã dùng"} ngày ${ngay(entry.entry_date)}`} onClick={() => mo({ kind: "sua-luong", supply, entry })}>Sửa</Button></td></tr>)}
      </tbody></table></div>}
  </section>;
}
function DongNguyenLieu({ item, supply, result, category, expanded, toggle, mo }: { item: Con; supply?: NguyenLieu; result?: DuLieu; category: Loai; expanded: boolean; toggle: () => void; mo: (m: Mo) => void }) {
  const [historyOpen, setHistoryOpen] = useState(false);
  const [ledgerOpen, setLedgerOpen] = useState(false);
  const id = useId();
  const itemTotal = result?.item_totals?.find((t) => t.expense_item_id === item.expense_item_id);
  return <Fragment><tr><td><button type="button" className="kc-item-name" aria-expanded={expanded} aria-controls={`${id}-detail`} onClick={toggle}>{item.name}</button></td><td>{supply ? uocTinh(supply) : "—"}</td><td>{supply ? luongCon(supply) : "—"}</td></tr>
    <tr id={`${id}-detail`} className="kc-item-detail-row" hidden={!expanded}><td colSpan={3}>{expanded && <div className="kc-item-detail"><dl>
      <div><dt>Ngày nhập gần nhất</dt><dd>{supply?.latest_purchase_date ? ngay(supply.latest_purchase_date) : supply ? "Chưa ghi" : "—"}</dd></div>
      <div><dt>Đã dùng gần đây</dt><dd>{supply ? supply.usage_estimate.usage_days === 0 ? "Chưa ghi ngày dùng" : `${luong(supply.usage_estimate.used_in_window)}${supply.purchase_unit ? ` ${supply.purchase_unit}` : ""} trong ${supply.usage_estimate.usage_days} ngày có ghi gần nhất` : "—"}</dd></div>
      <div><dt>Tổng chi trong kỳ</dt><dd>{result ? money(itemTotal?.total_vnd ?? 0) : "—"}</dd></div>
      <div><dt>Đơn vị mua</dt><dd>{supply ? supply.purchase_unit ?? "Chưa có đơn vị" : "—"}</dd></div>
      <div><dt>Tổng mua vào</dt><dd>{supply ? `${luong(supply.purchased_total)}${supply.purchase_unit ? ` ${supply.purchase_unit}` : ""}` : "—"}</dd></div>
      <div><dt>Tổng đã dùng</dt><dd>{supply ? `${luong(supply.used_total)}${supply.purchase_unit ? ` ${supply.purchase_unit}` : ""}` : "—"}</dd></div>
      <div><dt>Lượng nhập gần nhất</dt><dd>{supply ? supply.latest_purchase_measure === null ? "Chưa có lần mua" : `${luong(supply.latest_purchase_measure)}${supply.purchase_unit ? ` ${supply.purchase_unit}` : ""}` : "—"}</dd></div>
      <div><dt>Tỉ lệ nhắc</dt><dd>{supply ? luong(supply.reminder_ratio) : "—"}</dd></div>
      <div><dt>Nhắc kiểm tra</dt><dd>{supply ? `${supply.check_reminder ? "Nhắc POS kiểm tra" : "Không nhắc"}${supply.reminder_status === "no_purchase" ? " · chưa có lần mua" : supply.reminder_status === "latest_purchase_zero" ? " · lần mua gần nhất bằng 0" : supply.reminder_status === "usage_before_first_purchase" ? " · có số dùng trước lần mua đầu" : ""}` : "—"}</dd></div>
    </dl><div className="kc-actions"><Button variant="outline" onClick={() => mo({ kind: "ten-con", item })}>Sửa tên</Button><Button variant="outline" className="kc-danger" onClick={() => mo({ kind: "xoa-con", item })}>Ngừng dùng</Button><Button variant="outline" onClick={() => mo({ kind: "tao", category: category.expense_category_id, item: item.expense_item_id })}>Ghi mua</Button><Button variant="outline" aria-expanded={historyOpen} aria-controls={`${id}-history`} onClick={() => setHistoryOpen(!historyOpen)}>Lịch sử sử dụng</Button></div>
      {supply && <div className="kc-actions"><Button variant="outline" onClick={() => mo({ kind: "ghi-luong", supply })}>Ghi lượng</Button><Button variant="outline" aria-expanded={ledgerOpen} aria-controls={`${id}-ledger`} onClick={() => setLedgerOpen(!ledgerOpen)}>Sổ lượng</Button><Button variant="outline" onClick={() => mo({ kind: "dat-ti-le", supply })}>Đặt tỉ lệ nhắc</Button><Button variant="outline" onClick={() => mo({ kind: "chuyen-muc", supply })}>Chuyển mục</Button>{supply.purchase_unit === null && <Button variant="outline" onClick={() => mo({ kind: "dat-don-vi", supply })}>Đặt đơn vị</Button>}</div>}
      <div id={`${id}-history`} hidden={!historyOpen}>{historyOpen && item.supply_item_id && <LichSuSuDung item={item} supplyId={item.supply_item_id} />}</div>
      <div id={`${id}-ledger`} hidden={!ledgerOpen}>{ledgerOpen && supply && <SoLuong supply={supply} mo={mo} />}</div>
    </div>}</td></tr></Fragment>;
}
function BangNguyenLieu({ category, result, visible, id, active, toggle, mo }: { category: Loai; result?: DuLieu; visible: boolean; id: string; active: number | null; toggle: (itemId: number) => void; mo: (m: Mo) => void }) {
  const query = useNguyenLieu();
  const byId = new Map(query.data?.supply_items.map((supply) => [supply.supply_item_id, supply]));
  const readable = !query.isPending && !query.isError;
  return <div id={`${id}-items`} hidden={!visible}>
    {query.isError && <p className="kc-supply-error" role="alert">Chưa đọc được sổ nguyên liệu. Hãy thử đọc lại.</p>}
    <div className="kc-table-wrap"><table className="kc-data-table kc-item-table kc-supply-table" aria-label={`Nguyên liệu trong ${category.name}`}><thead><tr><th>Nguyên liệu</th><th>Ước tính còn dùng</th><th>Lượng còn lại</th></tr></thead><tbody>
      {(category.items ?? []).length ? category.items!.map((item) => <DongNguyenLieu key={item.expense_item_id} item={item} supply={readable && item.supply_item_id ? byId.get(item.supply_item_id) : undefined} result={result} category={category} expanded={active === item.expense_item_id} toggle={() => toggle(item.expense_item_id)} mo={mo} />) : <tr><td colSpan={3}>Chưa có khoản con. Thêm để bắt đầu theo dõi.</td></tr>}
    </tbody></table></div>
    <p className="kc-forecast-note">Ước tính tính từ sổ nguyên liệu, chỉ để xem và không thay lời nhắc kiểm hàng.</p>
  </div>;
}
function ChonNguyenLieu({ items, id, value, change }: { items: Con[]; id: string; value: string; change: (value: string) => void }) {
  return <Field><FieldLabel htmlFor={id}>Xem nguyên liệu</FieldLabel><select id={id} value={value} onChange={(e) => change(e.target.value)}>
    <option value="">Tất cả nguyên liệu</option>{items.map((item) => <option key={item.expense_item_id} value={String(item.expense_item_id)}>{item.name}</option>)}
  </select></Field>;
}
function LichSuSuDungMuc({ category, visible, setVisible, selected, setSelected }: { category: Loai; visible: boolean; setVisible: (v: boolean) => void; selected: string; setSelected: (v: string) => void }) {
  const id = useId();
  const items = category.items ?? [];
  const linked = items.filter((item) => item.supply_item_id !== null);
  const queries = useSoCacNguyenLieu(linked.map((item) => item.supply_item_id!), visible);
  const failed = items.filter((item) => item.supply_item_id === null || queries[linked.indexOf(item)]?.isError);
  const pending = queries.some((query) => query.isPending);
  const groups = new Map<string, { item: Con; measure: string; unit: string | null; key: number }[]>();
  if (!failed.length && !pending) {
    linked.forEach((item, index) => {
      if (selected && selected !== String(item.expense_item_id)) return;
      const detail = queries[index].data;
      detail?.entries.filter((entry) => entry.kind === "used").forEach((entry) => {
        const day = groups.get(entry.entry_date) ?? [];
        day.push({ item, measure: entry.measure, unit: detail.purchase_unit, key: entry.supply_day_entry_id });
        groups.set(entry.entry_date, day);
      });
    });
  }
  const days = Array.from(groups).sort(([a], [b]) => b.localeCompare(a));
  const selectedName = items.find((item) => String(item.expense_item_id) === selected)?.name;
  return <section className="kc-category-history" aria-labelledby={`${id}-title`}>
    <div className="kc-row kc-history-head"><h5 id={`${id}-title`} tabIndex={-1}>Lịch sử sử dụng nguyên liệu</h5>
      <Button variant="outline" aria-label={`${visible ? "Ẩn" : "Hiện"} lịch sử sử dụng nguyên liệu`} aria-expanded={visible} aria-controls={`${id}-body`} onClick={() => setVisible(!visible)}>{visible ? "Ẩn" : "Hiện"}</Button></div>
    <div id={`${id}-body`} hidden={!visible} className="kc-history-body">
      <ChonNguyenLieu items={items} id={`${id}-filter`} value={selected} change={setSelected} />
      {failed.length ? <p role="alert">Chưa đọc được sổ của {failed.map((item) => item.name).join(", ")}. Hãy thử đọc lại.</p>
        : pending ? <p role="status">Đang đọc lịch sử sử dụng nguyên liệu…</p>
        : days.length ? <div className="kc-table-wrap"><table className="kc-data-table kc-history-table" aria-label={`Ngày dùng nguyên liệu trong ${category.name}`}><thead><tr><th>Ngày dùng</th><th>Đã dùng trong ngày</th></tr></thead><tbody>
          {days.map(([date, entries]) => <tr key={date}><td>{ngay(date)}</td><td><ul className="kc-day-list">{entries.sort((a, b) => a.item.name.localeCompare(b.item.name, "vi") || a.key - b.key).map((entry) => <li key={`${entry.item.expense_item_id}-${entry.key}`}>{entry.item.name} {luong(entry.measure)}{entry.unit ? ` ${entry.unit}` : ""}</li>)}</ul></td></tr>)}
        </tbody></table></div>
        : <p className="kc-muted">{selectedName ? `Chưa có ngày dùng nào được ghi cho ${selectedName}.` : "Chưa có ngày dùng nào được ghi."}</p>}
    </div>
  </section>;
}
function LichSuMuaHangMuc({ category, visible, setVisible, heading }: { category: Loai; visible: boolean; setVisible: (v: boolean) => void; heading: React.RefObject<HTMLHeadingElement | null> }) {
  const id = useId();
  const [selected, setSelected] = useState("");
  const [chosen, setChosen] = useState<{ from: string; to: string } | null>(null);
  const dates = chosen ?? { from: category.last_paid_date ? baMuoiNgayCuoi(category.last_paid_date) : "", to: category.last_paid_date ?? "" };
  const missing = !dates.from || !dates.to;
  const invalid = !missing && dates.from > dates.to;
  const query = useLichSuSuaTien({ expense_category_id: category.expense_category_id }, dates.from, dates.to, visible && !!category.last_paid_date && !invalid);
  const rows = query.data?.expenses.filter((entry) => !selected || String(entry.expense_item_id) === selected)
    .sort((a, b) => {
      if (a.received_date === null) return b.received_date === null ? b.paid_date.localeCompare(a.paid_date) || b.expense_id - a.expense_id : 1;
      if (b.received_date === null) return -1;
      return b.received_date.localeCompare(a.received_date) || b.paid_date.localeCompare(a.paid_date) || b.expense_id - a.expense_id;
    }) ?? [];
  const groups = new Map<string | null, Khoan[]>();
  rows.forEach((entry) => { const day = groups.get(entry.received_date) ?? []; day.push(entry); groups.set(entry.received_date, day); });
  const selectedName = category.items?.find((item) => String(item.expense_item_id) === selected)?.name;
  return <section className="kc-category-history" aria-labelledby={`${id}-title`}>
    <div className="kc-row kc-history-head"><h5 id={`${id}-title`} ref={heading} tabIndex={-1}>Lịch sử mua hàng</h5>
      <Button variant="outline" aria-label={`${visible ? "Ẩn" : "Hiện"} lịch sử mua hàng`} aria-expanded={visible} aria-controls={`${id}-body`} onClick={() => setVisible(!visible)}>{visible ? "Ẩn" : "Hiện"}</Button></div>
    <div id={`${id}-body`} hidden={!visible} className="kc-history-body">
      <ChonNguyenLieu items={category.items ?? []} id={`${id}-filter`} value={selected} change={setSelected} />
      <div className="kc-two"><Field><FieldLabel htmlFor={`${id}-from`}>Từ ngày</FieldLabel><Input id={`${id}-from`} type="date" value={dates.from} disabled={!category.last_paid_date} onChange={(e) => setChosen({ ...dates, from: e.target.value })} /></Field>
        <Field><FieldLabel htmlFor={`${id}-to`}>Đến ngày</FieldLabel><Input id={`${id}-to`} type="date" value={dates.to} disabled={!category.last_paid_date} onChange={(e) => setChosen({ ...dates, to: e.target.value })} /></Field></div>
      {!category.last_paid_date ? <p className="kc-muted">Mục này chưa có lần mua nào.</p>
        : missing ? <p role="alert">Chọn cả Từ ngày và Đến ngày.</p>
        : invalid ? <p role="alert">Từ ngày phải trước hoặc bằng Đến ngày.</p>
        : query.isError ? <p role="alert">Chưa đọc được lịch sử mua hàng. Hãy thử đọc lại.</p>
        : query.isPending ? <p role="status">Đang đọc lịch sử mua hàng…</p>
        : rows.length ? <div className="kc-table-wrap"><table className="kc-data-table kc-history-table" aria-label={`Các lần mua theo ngày nhập trong ${category.name}`}><thead><tr><th>Ngày nhập hàng</th><th>Các lần mua trong ngày</th></tr></thead><tbody>
          {Array.from(groups, ([date, entries]) => <tr key={date ?? "none"}><td>{date ? ngay(date) : "Chưa ghi ngày nhập"}</td><td><ul className="kc-day-list">{entries.map((entry) => <li key={entry.expense_id}>{entry.item_name || "Chưa chọn nguyên liệu"} {money(entry.amount_vnd)} Ngày chi: {ngay(entry.paid_date)} · Người ghi: {entry.person_name}</li>)}</ul></td></tr>)}
        </tbody></table></div>
        : <p className="kc-muted">{selectedName ? `Chưa có lần mua nào được ghi trong khoảng này cho ${selectedName}.` : "Chưa có lần mua nào được ghi trong khoảng này."}</p>}
    </div>
  </section>;
}
function MucChi({ category, data, from, to, selectedCategory, source, mo }: { category: Loai; data?: DuLieu; from?: string; to?: string; selectedCategory: string | null; source: string | null; mo: (m: Mo) => void }) {
  const [expanded, setExpanded] = useState(true);
  const [visible, setVisible] = useState(true);
  const [dateFilterOpen, setDateFilterOpen] = useState(false);
  const [dates, setDates] = useState({ from: "", to: "" });
  const [active, setActive] = useState<number | null>(null);
  const [usageSelected, setUsageSelected] = useState("");
  const [usageVisible, setUsageVisible] = useState(true);
  const [purchaseVisible, setPurchaseVisible] = useState(true);
  const purchaseHeading = useRef<HTMLHeadingElement>(null);
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
      <section className="kc-items"><div className="kc-row kc-items-head"><h4>Nguyên liệu / sản phẩm</h4><div className="kc-actions">
        {category.tracks_supply && <Button variant="outline" className="kc-history-jump" onClick={() => { setPurchaseVisible(true); purchaseHeading.current?.scrollIntoView?.(); purchaseHeading.current?.focus(); }}>Lịch sử mua hàng ↓</Button>}
        <Button variant="outline" aria-expanded={visible} aria-controls={`${id}-items`} onClick={() => setVisible(!visible)}>{visible ? "Ẩn khoản con" : "Hiện khoản con"}</Button>
        <Button variant="outline" aria-expanded={dateFilterOpen} aria-controls={`${id}-dates`} onClick={() => setDateFilterOpen(!dateFilterOpen)}>Lọc ngày{local ? " · Đang lọc" : ""}</Button>
      </div></div>
        <div id={`${id}-dates`} className="kc-local-filter" role="group" aria-label={`Lọc ngày ${category.name}`} hidden={!dateFilterOpen}><div className="kc-two"><Field><FieldLabel htmlFor={`${id}-from`}>Từ ngày · {category.name}</FieldLabel><Input id={`${id}-from`} type="date" value={dates.from} onChange={(e) => setDates({ ...dates, from: e.target.value })} /></Field><Field><FieldLabel htmlFor={`${id}-to`}>Đến ngày · {category.name}</FieldLabel><Input id={`${id}-to`} type="date" value={dates.to} onChange={(e) => setDates({ ...dates, to: e.target.value })} /></Field></div><small className="kc-muted">Lọc riêng mục này, trong phạm vi bộ lọc chung.</small>{invalid && <p role="alert">Ngày bắt đầu phải trước hoặc bằng ngày kết thúc, trong khoảng ngày chung.</p>}<Button variant="outline" onClick={() => setDates({ from: "", to: "" })}>Xoá lọc ngày</Button>{local && !invalid && <TrangThai query={query} ten="tổng theo mục" />}</div>
        {!category.tracks_supply && <BangNgayMuc category={category} result={result} />}
        {category.tracks_supply ? <><BangNguyenLieu category={category} result={result} visible={visible} id={id} active={active} toggle={(itemId) => { const next = active === itemId ? null : itemId; setActive(next); setUsageSelected(next === null ? "" : String(next)); }} mo={mo} />
          <div className="kc-category-histories"><LichSuSuDungMuc category={category} visible={usageVisible} setVisible={setUsageVisible} selected={usageSelected} setSelected={setUsageSelected} />
            <LichSuMuaHangMuc category={category} visible={purchaseVisible} setVisible={setPurchaseVisible} heading={purchaseHeading} /></div></> : <div id={`${id}-items`} hidden={!visible} className="kc-table-wrap"><table className="kc-data-table kc-item-table" aria-label={`Khoản con trong ${category.name}`}><thead><tr><th>Khoản con</th><th>Ngày chi gần nhất</th><th>Tổng chi trong kỳ</th></tr></thead><tbody>{(category.items ?? []).length ? category.items!.map((item) => <DongKhoanCon key={item.expense_item_id} item={item} category={category} result={result} entries={result?.expenses ?? []} mo={mo} />) : <tr><td colSpan={3}>Chưa có khoản con. Thêm để bắt đầu theo dõi.</td></tr>}</tbody></table></div>}
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
  const nguyenLieu = useNguyenLieu();
  const from = params.get("tu") ?? tongQuan.data?.sale_date;
  const to = params.get("den") ?? tongQuan.data?.sale_date;
  const query = useKhoanChi(from, to, params.get("loai"), params.get("nguon"));
  const [opened, setOpened] = useState<Mo | null>(null);
  const [ledger, setLedger] = useState(true);
  const [filtersOpen, setFiltersOpen] = useState(true);
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
  const supplies = !nguyenLieu.isPending && !nguyenLieu.isError ? nguyenLieu.data?.supply_items ?? [] : [];
  const chuaXep = supplies.filter((s) => s.expense_item_id === null && s.stopped_at === null);
  const daNgung = supplies.filter((s) => s.stopped_at !== null);
  const grouped = theoNgay(query.data?.expenses ?? []);
  return <div className="kc-page">
    <header className="kc-row kc-header"><div><p className="kc-eyebrow">HÀNG &amp; TIỀN</p><h1 ref={heading} tabIndex={-1}>Khoản chi</h1><p className="kc-muted">Theo dõi từng khoản, rõ từng nguồn tiền.</p></div><div className="kc-actions"><Button variant="outline" onClick={() => open({ kind: "them-loai" })}>＋ Thêm mục chi</Button><Button disabled={!categories.length} onClick={() => open({ kind: "tao" })}>Ghi khoản chi</Button></div></header>
    <section className="kc-period" aria-label="Tổng tiền theo khoảng ngày">
      <div className="kc-period-top"><h2>Tổng tiền theo khoảng ngày</h2><p className="kc-muted" aria-live="polite">{days > 0 && from && to ? `${ngay(from)} – ${ngay(to)} · ${days} ngày` : "Chọn khoảng ngày hợp lệ để xem tổng tiền."}</p></div>
      <div className="kc-period-buttons" role="group" aria-label="Chọn nhanh khoảng ngày, tính cả ngày kết thúc">{[7, 10, 14, 30].map((n) => <Button key={n} variant="outline" disabled={!to || Number.isNaN(Date.parse(`${to}T00:00:00Z`))} aria-pressed={days === n} onClick={() => { if (!to) return; const d = new Date(`${to}T00:00:00Z`); d.setUTCDate(d.getUTCDate() - n + 1); loc({ tu: d.toISOString().slice(0, 10), den: to }); }}>{n} ngày</Button>)}</div>
    </section>
    <section className="kc-overview" aria-label="Tổng chi trong kỳ"><small>Tổng chi trong kỳ</small><strong>{query.data ? money(query.data.total_vnd) : "—"}</strong><small>{query.data ? `${query.data.expenses.length} khoản chi theo bộ lọc` : "Đang chờ dữ liệu"}</small></section>
    <section className="kc-categories" aria-label="Loại chi"><div className="kc-row"><div><h2>Mục chi &amp; sản phẩm</h2><p className="kc-muted">Chọn từng nguyên liệu hoặc sản phẩm khi ghi khoản chi.</p></div><Button variant="outline" disabled={loai.isFetching} onClick={() => void loai.refetch()}>Đọc lại loại chi</Button></div><TrangThai query={loai} ten="loại chi" daGhi={bao.startsWith("Đã ")} />
      {loai.data && (categories.length ? <div className="kc-category-list" role="list" aria-label="Danh sách loại chi">{categories.map((l) => <div role="listitem" key={l.expense_category_id}><MucChi category={l} data={query.data} from={from} to={to} selectedCategory={params.get("loai")} source={params.get("nguon")} mo={open} /></div>)}</div> : <p>Chưa có loại chi nào.</p>)}
      {chuaXep.length > 0 && <section className="kc-supply-group" aria-labelledby={`${id}-unlinked`}><h3 id={`${id}-unlinked`}>Nguyên liệu chưa xếp mục</h3><ul>{chuaXep.map((s) => <li key={s.supply_item_id}><span>{s.name}{s.purchase_unit ? ` · ${s.purchase_unit}` : ""}</span><Button variant="outline" aria-label={`Xếp ${s.name} vào mục`} onClick={() => open({ kind: "xep-muc", supply: s })}>Xếp vào mục</Button></li>)}</ul></section>}
      {daNgung.length > 0 && <section className="kc-supply-group" aria-labelledby={`${id}-stopped`}><h3 id={`${id}-stopped`}>Nguyên liệu đã ngừng dùng</h3><ul>{daNgung.map((s) => { const oldCategory = categories.find((c) => c.expense_category_id === s.expense_category_id); return <li key={s.supply_item_id}><span>{s.name}{oldCategory ? ` · ${oldCategory.name}` : ""}</span>{s.expense_item_id !== null && <Button variant="outline" aria-label={`Dùng lại ${s.name}`} onClick={() => open({ kind: "dung-lai", supply: s })}>Dùng lại</Button>}</li>; })}</ul></section>}
    </section>
    <section className="kc-filter" aria-label="Bộ lọc sổ khoản chi"><div className="kc-row kc-section-head"><h2>Sổ khoản chi</h2><Button variant="outline" aria-expanded={filtersOpen} aria-controls={`${id}-filters`} onClick={() => setFiltersOpen(!filtersOpen)}>{filtersOpen ? "Ẩn" : "Hiện"}</Button></div>
      <div id={`${id}-filters`} className="kc-filter-body" hidden={!filtersOpen}>
      {(params.get("tu") === null || params.get("den") === null) && <><TrangThai query={tongQuan} ten="ngày bán" />{tongQuan.isError && <Button variant="outline" onClick={() => void tongQuan.refetch()}>Đọc lại ngày bán</Button>}</>}
      <div className="kc-filters">{fields.map((f) => { const error = query.error?.kind === "rejected" && query.error.field === f.field ? loiKhoanChi(query.error) : undefined; const props = { id: `${id}-${f.key}`, value: f.value ?? "", onChange: (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => loc({ [f.key]: e.target.value }), "aria-invalid": !!error, "aria-describedby": error ? `${id}-${f.key}-loi` : undefined }; return <Field key={f.key} data-invalid={!!error}><FieldLabel htmlFor={props.id}>{f.label}</FieldLabel>{f.key === "tu" || f.key === "den" ? <Input {...props} type="date" /> : <select {...props}><option value="">Tất cả</option>{f.key === "loai" ? categories.map((l) => <option key={l.expense_category_id} value={l.expense_category_id}>{l.name}</option>) : <><option value="ket">Trả từ két</option><option value="rieng">Tiền riêng</option></>}</select>}{error && <FieldError id={`${id}-${f.key}-loi`}>{error}</FieldError>}</Field>; })}</div>
      {from !== undefined && to !== undefined && <TrangThai query={query} ten="khoản chi" daGhi={bao.startsWith("Đã ")} />}
      <div className="kc-actions"><Button variant="outline" onClick={() => loc({ tu: "", den: "", loai: "", nguon: "" })}>Đặt lại bộ lọc</Button>{from !== undefined && to !== undefined && <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại khoản chi</Button>}</div>
      {query.data && <div className="kc-table-wrap"><table className="kc-data-table kc-summary-table" aria-label="Tổng chi theo ngày"><thead><tr><th>Ngày chi</th><th>Số khoản chi</th><th>Tổng chi</th></tr></thead><tbody>{query.data.day_totals.length ? query.data.day_totals.map((day) => <tr key={day.paid_date}><td>{ngay(day.paid_date)}</td><td>{day.expense_count} khoản</td><td className="kc-amount">{money(day.total_vnd)}</td></tr>) : <tr><td colSpan={3}>Không có khoản chi trong phạm vi này.</td></tr>}</tbody></table></div>}
      </div>
    </section>
    <section className="kc-ledger" aria-label="Các khoản chi"><div className="kc-row kc-section-head"><h2>Các khoản chi</h2><Button variant="outline" aria-expanded={ledger} aria-controls={`${id}-ledger`} onClick={() => setLedger(!ledger)}>{ledger ? "Ẩn" : "Hiện"}</Button></div><div id={`${id}-ledger`} hidden={!ledger}>
      <p className="kc-muted kc-ledger-unit">Đơn vị: đồng</p>
      {query.data && (query.data.expenses.length === 0 ? <p className="kc-empty">Không có khoản chi nào trong khoảng này.</p> : <div className="kc-table-wrap"><table className="kc-data-table kc-day-table" aria-label="Các khoản chi theo ngày"><thead><tr><th>Ngày chi</th><th>Các khoản chi trong ngày</th></tr></thead><tbody>{Array.from(grouped, ([date, entries]) => <tr key={date}><td>{ngay(date)}</td><td><ul className="kc-day-list">{entries.map((k) => <li key={k.expense_id}><strong>{k.category_name}: {k.item_name || "Chưa chọn khoản con"}</strong> <span className={`kc-badge${k.paid_from_till ? "" : " kc-personal"}`}>{nguonTien(k.paid_from_till)}</span> <span>{money(k.amount_vnd)}</span> <span>· </span><span>{k.person_name}</span><span className="kc-actions"><Button variant="outline" aria-label={`Sửa ${k.item_name || k.category_name} ngày ${ngay(k.paid_date)}`} onClick={() => open({ kind: "sua", entry: k })}>Sửa</Button><Button variant="outline" className="kc-danger" aria-label={`Xoá ${k.item_name || k.category_name} ngày ${ngay(k.paid_date)}`} onClick={() => open({ kind: "xoa-chi", entry: k })}>Xoá</Button></span></li>)}</ul></td></tr>)}</tbody></table></div>)}
    </div></section><p role="status" aria-live="polite" className="kc-feedback">{bao}</p>
    <Dialog open={opened !== null} onOpenChange={(v) => { if (!v && !busy) close(); }}><DialogContent showCloseButton={false} className="kc-dialog" aria-describedby={undefined} onCloseAutoFocus={(e) => { e.preventDefault(); (focus.current?.isConnected ? focus.current : heading.current)?.focus(); }} onInteractOutside={(e) => e.preventDefault()} onEscapeKeyDown={(e) => { if (busy) e.preventDefault(); }}>
      {opened && <><div className="kc-row"><DialogTitle>{title(opened)}</DialogTitle><Button variant="ghost" aria-label="Đóng" disabled={busy} onClick={close}>×</Button></div><DialogDescription className="sr-only">Nhập thông tin và lưu thay đổi.</DialogDescription><NoiDungHopThoai key={JSON.stringify(opened)} opened={opened} categories={categories} bao={setBao} dong={close} suaTien={(entry) => setOpened({ kind: "sua", entry })} /></>}
    </DialogContent></Dialog>
  </div>;
}
function FormGhiLuong({ supply, bao, dong }: { supply: NguyenLieu; bao: (s: string) => void; dong: () => void }) {
  const luu = useGhiConSo();
  const form = useForm<z.infer<typeof ghiLuong>>({ resolver: zodResolver(ghiLuong), defaultValues: { entry_date: "", measure: "" } });
  const id = useId();
  const dateError = form.formState.errors.entry_date?.message;
  const kindError = form.formState.errors.kind?.message;
  return <FormMenu form={form} ten={`Ghi lượng ${supply.name}`} nut="Lưu con số" cacO={["entry_date", "kind", "measure"]} loi={loiNguyenLieu} oLoi={oLoiNguyenLieu} dong={dong}
    gui={(body) => luu.mutateAsync({ ...body, supply_item_id: supply.supply_item_id })} daLuu={() => { bao(`Đã ghi con số cho ${supply.name}.`); dong(); }}>
    <Field data-invalid={!!dateError}><FieldLabel htmlFor={`${id}-date`}>Ngày</FieldLabel><Input id={`${id}-date`} type="date" {...form.register("entry_date")} aria-invalid={!!dateError} aria-describedby={dateError ? `${id}-date-error` : undefined} />{dateError && <FieldError id={`${id}-date-error`}>{dateError}</FieldError>}</Field>
    <Field data-invalid={!!kindError}><FieldLabel htmlFor={`${id}-kind`}>Loại</FieldLabel><select id={`${id}-kind`} defaultValue="" {...form.register("kind")} aria-invalid={!!kindError} aria-describedby={kindError ? `${id}-kind-error` : undefined}><option value="">Chọn loại</option><option value="purchased">Mua vào</option><option value="used">Đã dùng</option></select>{kindError && <FieldError id={`${id}-kind-error`}>{kindError}</FieldError>}</Field>
    <OMenu form={form} o="measure" nhan="Con số" /><p className="kc-muted">Dùng dấu chấm, tối đa 3 chữ số lẻ.</p>
  </FormMenu>;
}
function FormSuaLuong({ supply, entry, bao, dong }: { supply: NguyenLieu; entry: DongSo; bao: (s: string) => void; dong: () => void }) {
  const luu = useSuaConSo(entry.supply_day_entry_id);
  const form = useForm<z.infer<typeof suaLuong>>({ resolver: zodResolver(suaLuong), defaultValues: { measure: entry.measure, reason: "" } });
  return <FormMenu form={form} ten={`Sửa con số ${supply.name}`} nut="Lưu con số" cacO={["measure", "reason"]} loi={loiNguyenLieu} oLoi={oLoiNguyenLieu} dong={dong}
    gui={luu.mutateAsync} daLuu={() => { bao(`Đã sửa con số cho ${supply.name}.`); dong(); }}>
    <OMenu form={form} o="measure" nhan="Con số" /><p className="kc-muted">Dùng dấu chấm, tối đa 3 chữ số lẻ.</p><OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function FormDatDonVi({ supply, bao, dong }: { supply: NguyenLieu; bao: (s: string) => void; dong: () => void }) {
  const luu = useDatDonVi(supply.supply_item_id);
  const form = useForm<z.infer<typeof datDonVi>>({ resolver: zodResolver(datDonVi), defaultValues: { purchase_unit: "" } });
  return <FormMenu form={form} ten={`Đặt đơn vị ${supply.name}`} nut="Lưu đơn vị" cacO={["purchase_unit"]} loi={loiNguyenLieu} oLoi={oLoiNguyenLieu} dong={dong}
    gui={luu.mutateAsync} daLuu={() => { bao(`Đã đặt đơn vị cho ${supply.name}.`); dong(); }}><OMenu form={form} o="purchase_unit" nhan="Đơn vị mua" /></FormMenu>;
}
function FormDatTiLe({ supply, bao, dong }: { supply: NguyenLieu; bao: (s: string) => void; dong: () => void }) {
  const luu = useDatTiLeKho(supply.supply_item_id);
  const form = useForm<z.infer<typeof datTiLe>>({ resolver: zodResolver(datTiLe), defaultValues: { reminder_ratio: supply.reminder_ratio, reason: "" } });
  return <FormMenu form={form} ten={`Đặt tỉ lệ nhắc ${supply.name}`} nut="Lưu tỉ lệ" cacO={["reminder_ratio", "reason"]} loi={loiKho} oLoi={oLoiNguyenLieu} dong={dong}
    gui={luu.mutateAsync} daLuu={() => { bao(`Đã đặt tỉ lệ nhắc cho ${supply.name}.`); dong(); }}><OMenu form={form} o="reminder_ratio" nhan="Tỉ lệ nhắc" /><p className="kc-muted">Dùng dấu chấm, từ 0 đến 1, tối đa 6 chữ số lẻ.</p><OMenu form={form} o="reason" nhan="Lý do" /></FormMenu>;
}
function FormChuyenMuc({ supply, categories, bao, dong }: { supply: NguyenLieu; categories: Loai[]; bao: (s: string) => void; dong: () => void }) {
  const luu = useChuyenMucKhoanCon(supply.expense_item_id ?? 0);
  const current = categories.find((c) => c.expense_category_id === supply.expense_category_id);
  const choices = categories.filter((c) => c.tracks_supply && c.expense_category_id !== supply.expense_category_id && current && c.paid_from_till === current.paid_from_till);
  const form = useForm<z.infer<typeof chuyenMuc>>({ resolver: zodResolver(chuyenMuc), defaultValues: { expense_category_id: "", reason: "" } });
  const id = useId();
  const error = form.formState.errors.expense_category_id?.message;
  if (!choices.length || supply.expense_item_id === null) return <p>Không có mục theo dõi lượng nào khác cùng nguồn tiền.</p>;
  return <FormMenu form={form} ten={`Chuyển mục ${supply.name}`} nut="Chuyển mục" cacO={["expense_category_id", "reason"]} {...loi} dong={dong}
    gui={({ expense_category_id, reason }) => luu.mutateAsync({ expense_category_id: Number(expense_category_id), reason })}
    daLuu={() => { const chosen = choices.find((c) => c.expense_category_id === Number(form.getValues("expense_category_id"))); bao(`Đã chuyển ${supply.name} sang ${chosen?.name ?? "mục đã chọn"}.`); dong(); }}>
    <Field data-invalid={!!error}><FieldLabel htmlFor={id}>Chuyển sang mục</FieldLabel><select id={id} defaultValue="" {...form.register("expense_category_id")} aria-invalid={!!error} aria-describedby={error ? `${id}-error` : undefined}><option value="">Chọn mục</option>{choices.map((c) => <option key={c.expense_category_id} value={c.expense_category_id}>{c.name}</option>)}</select>{error && <FieldError id={`${id}-error`}>{error}</FieldError>}</Field><OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function FormXepMuc({ supply, categories, bao, dong }: { supply: NguyenLieu; categories: Loai[]; bao: (s: string) => void; dong: () => void }) {
  const luu = useXepNguyenLieu();
  const choices = categories.filter((c) => c.tracks_supply);
  const form = useForm<z.infer<typeof chonMuc>>({ resolver: zodResolver(chonMuc), defaultValues: { expense_category_id: "" } });
  const id = useId();
  const error = form.formState.errors.expense_category_id?.message;
  if (!choices.length) return <p>Chưa có mục chi theo dõi lượng. Hãy thêm mục chi có theo dõi lượng trước.</p>;
  return <FormMenu form={form} ten={`Xếp ${supply.name} vào mục`} nut="Xếp vào mục" cacO={["expense_category_id"]} {...loi} dong={dong}
    gui={({ expense_category_id }) => luu.mutateAsync({ expense_category_id: Number(expense_category_id), supply_item_id: supply.supply_item_id })}
    daLuu={() => { const chosen = choices.find((c) => c.expense_category_id === Number(form.getValues("expense_category_id"))); bao(`Đã xếp ${supply.name} vào ${chosen?.name ?? "mục đã chọn"}.`); dong(); }}>
    <Field data-invalid={!!error}><FieldLabel htmlFor={id}>Mục chi</FieldLabel><select id={id} defaultValue="" {...form.register("expense_category_id")} aria-invalid={!!error} aria-describedby={error ? `${id}-error` : undefined}><option value="">Chọn mục chi</option>{choices.map((c) => <option key={c.expense_category_id} value={c.expense_category_id}>{c.name}</option>)}</select>{error && <FieldError id={`${id}-error`}>{error}</FieldError>}</Field>
  </FormMenu>;
}
function FormDungLai({ supply, categories, bao, dong }: { supply: NguyenLieu; categories: Loai[]; bao: (s: string) => void; dong: () => void }) {
  const luu = useDungLaiKhoanCon(supply.expense_item_id ?? 0);
  const form = useForm<z.infer<typeof lyDo>>({ resolver: zodResolver(lyDo), defaultValues: { reason: "" } });
  const category = categories.find((c) => c.expense_category_id === supply.expense_category_id);
  return <FormMenu form={form} ten={`Dùng lại ${supply.name}`} nut="Dùng lại" cacO={["reason"]} {...loi} dong={dong}
    gui={luu.mutateAsync} daLuu={() => { bao(`Đã dùng lại ${supply.name}.`); dong(); }}>
    <p>Dùng lại {supply.name}? Thứ trở về {category?.name ?? "mục cũ"} cùng toàn bộ lịch sử.</p><OMenu form={form} o="reason" nhan="Lý do" />
  </FormMenu>;
}
function NoiDungHopThoai({ opened, categories, bao, dong, suaTien }: { opened: Mo; categories: Loai[]; bao: (s: string) => void; dong: () => void; suaTien: (k: Khoan) => void }): ReactNode {
  switch (opened.kind) {
    case "ghi-luong": return <FormGhiLuong supply={opened.supply} bao={bao} dong={dong} />;
    case "sua-luong": return <FormSuaLuong supply={opened.supply} entry={opened.entry} bao={bao} dong={dong} />;
    case "dat-don-vi": return <FormDatDonVi supply={opened.supply} bao={bao} dong={dong} />;
    case "dat-ti-le": return <FormDatTiLe supply={opened.supply} bao={bao} dong={dong} />;
    case "chuyen-muc": return <FormChuyenMuc supply={opened.supply} categories={categories} bao={bao} dong={dong} />;
    case "xep-muc": return <FormXepMuc supply={opened.supply} categories={categories} bao={bao} dong={dong} />;
    case "dung-lai": return <FormDungLai supply={opened.supply} categories={categories} bao={bao} dong={dong} />;
    case "tao": return <FormKhoan category={opened.category} item={opened.item} loai={categories} dong={dong} bao={bao} />;
    case "sua": return <FormKhoan khoan={opened.entry} loai={categories} dong={dong} bao={bao} />;
    case "them-loai": return <ThemLoai loai={categories} dong={dong} bao={bao} />;
    case "them-con": return <ThemCon category={opened.category} dong={dong} bao={bao} />;
    case "ten-loai": case "ten-con": return <DoiTen target={opened} dong={dong} bao={bao} suaTien={suaTien} />;
    default: return <Xoa target={opened} dong={dong} bao={bao} />;
  }
}
