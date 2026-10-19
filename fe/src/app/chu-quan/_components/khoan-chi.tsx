"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useState } from "react";
import { useForm, type UseFormReturn } from "react-hook-form";
import { useRouter, useSearchParams } from "next/navigation";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { FormMenu, OMenu, chuMenu, soMenu } from "./form-menu";
import { useTongQuan } from "./du-lieu-tong-quan";
import { useLoaiChi, useKhoanChi, useThemLoaiChi, useGhiKhoanChi, useSuaKhoanChi,
  loiKhoanChi, oLoiKhoanChi, type KieuKhoanChi } from "./du-lieu-khoan-chi";

const loi = { loi: loiKhoanChi, oLoi: oLoiKhoanChi };
const them = z.object({ name: chuMenu, paid_from_till: z.enum(["ket", "rieng"], { error: "Chọn nguồn tiền." }) });
const ghi = z.object({ expense_category_id: soMenu, amount_vnd: soMenu, paid_date: chuMenu });
const sua = ghi.extend({ reason: chuMenu });
type Nhap = z.infer<typeof sua>;
type Loai = KieuKhoanChi["ExpenseCategory"];
const tien = new Intl.NumberFormat("vi-VN");
const nguonTien = (ket: boolean) => ket ? "Trả từ két" : "Tiền riêng";

function ThemLoai({ bao }: { bao: (s: string) => void }) {
  const luu = useThemLoaiChi();
  const id = useId();
  const form = useForm<z.infer<typeof them>>({ resolver: zodResolver(them), defaultValues: { name: "" } });
  const error = form.formState.errors.paid_from_till?.message;
  return <FormMenu {...loi} form={form} ten="Thêm loại chi" nut="Thêm loại chi" cacO={["name", "paid_from_till"]}
    gui={({ name, paid_from_till }) => luu.mutateAsync({ name, paid_from_till: paid_from_till === "ket" })}
    daLuu={() => { form.reset(); bao("Đã thêm loại chi."); }}>
    <OMenu form={form} o="name" nhan="Tên loại chi" />
    <Field data-invalid={!!error}><FieldLabel htmlFor={id}>Nguồn tiền</FieldLabel>
      <select id={id} defaultValue="" {...form.register("paid_from_till")} aria-invalid={!!error} aria-describedby={error ? `${id}-loi` : undefined} className="h-9 w-full rounded-md border bg-background px-3">
        <option value="">Chọn nguồn tiền</option><option value="ket">Trả từ két</option><option value="rieng">Tiền riêng</option>
      </select>{error && <FieldError id={`${id}-loi`}>{error}</FieldError>}
    </Field>
  </FormMenu>;
}
function CacO({ form, loai }: { form: UseFormReturn<Nhap>; loai: Loai[] }) {
  const id = useId();
  const error = form.formState.errors.paid_date?.message;
  return <>
    <OMenu form={form} o="expense_category_id" nhan="Loại chi" options={loai.map((l) => ({ id: l.expense_category_id, ten: l.name }))} />
    <OMenu form={form} o="amount_vnd" nhan="Số tiền (đồng)" so />
    <Field data-invalid={!!error}><FieldLabel htmlFor={id}>Ngày chi</FieldLabel>
      <Input id={id} type="date" {...form.register("paid_date")} aria-invalid={!!error} aria-describedby={error ? `${id}-loi` : undefined} />
      {error && <FieldError id={`${id}-loi`}>{error}</FieldError>}
    </Field>
  </>;
}
function FormKhoan({ khoan, loai, dong, bao }: { khoan?: KieuKhoanChi["Expense"]; loai: Loai[]; dong: () => void; bao: (s: string) => void }) {
  const tao = useGhiKhoanChi();
  const doi = useSuaKhoanChi(khoan?.expense_id ?? 0);
  const form = useForm<Nhap>({ resolver: zodResolver(khoan ? sua : ghi.extend({ reason: z.string() })), defaultValues: {
    expense_category_id: khoan?.expense_category_id, amount_vnd: khoan?.amount_vnd, paid_date: khoan?.paid_date ?? "", reason: "",
  } });
  return <FormMenu {...loi} form={form} ten={khoan ? "Sửa khoản chi" : "Ghi khoản chi"} nut="Lưu khoản chi"
    cacO={["expense_category_id", "amount_vnd", "paid_date", "reason"]} dong={dong}
    gui={async ({ reason, ...body }) => {
      const r = await (khoan ? doi.mutateAsync({ ...body, reason }) : tao.mutateAsync(body));
      if (!r.ok && r.failure.kind === "rejected" && r.failure.code === "expense_not_found") bao(loiKhoanChi(r.failure));
      return r;
    }} daLuu={() => { bao(khoan ? "Đã sửa khoản chi." : "Đã ghi khoản chi."); dong(); }}>
    <CacO form={form} loai={loai} />
    {khoan && <OMenu form={form} o="reason" nhan="Lý do" />}
  </FormMenu>;
}
function TrangThai({ query, ten, daGhi = false }: { query: { isPending: boolean; isError: boolean; isFetching: boolean; fetchStatus: string; dataUpdatedAt: number }; ten: string; daGhi?: boolean }) {
  return <>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : `Đang đọc ${ten}…`}</p>}
    {query.isError && <p role="alert">Chưa đọc được {ten}. {query.dataUpdatedAt > 0 && `Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.`} {daGhi && "Đã ghi, chưa cập nhật được dữ liệu."}</p>}
    {!query.isPending && query.isFetching && <p role="status">Đang đọc lại {ten}…</p>}
  </>;
}
export function TrangKhoanChi() {
  const params = useSearchParams();
  const router = useRouter();
  const tongQuan = useTongQuan();
  const loai = useLoaiChi();
  const from = params.get("tu") ?? tongQuan.data?.sale_date;
  const to = params.get("den") ?? tongQuan.data?.sale_date;
  const query = useKhoanChi(from, to, params.get("loai"), params.get("nguon"));
  const [mo, setMo] = useState<number | "tao" | null>(null);
  const [bao, setBao] = useState("");
  const [baoLoai, setBaoLoai] = useState("");
  const id = useId();
  function loc(key: string, value: string) {
    const next = new URLSearchParams(params.toString());
    if (value) next.set(key, value); else next.delete(key);
    router.replace(`/chu-quan/khoan-chi${next.size ? `?${next}` : ""}`);
  }
  const fields = [{ key: "tu", field: "from", label: "Từ ngày", value: from }, { key: "den", field: "to", label: "Đến ngày", value: to },
    { key: "loai", field: "expense_category_id", label: "Lọc loại chi", value: params.get("loai") }, { key: "nguon", field: "paid_from_till", label: "Lọc nguồn", value: params.get("nguon") }];
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Khoản chi</h1>
    <section aria-label="Loại chi" className="space-y-4 rounded-md border p-4"><h2 className="text-xl font-semibold">Loại chi</h2>
      <TrangThai query={loai} ten="loại chi" daGhi={!!baoLoai} />
      <Button variant="outline" disabled={loai.isFetching} onClick={() => void loai.refetch()}>Đọc lại loại chi</Button>
      {baoLoai && <p role="status">{baoLoai}</p>}
      {loai.data && <>{loai.data.expense_categories.length === 0 ? <p>Chưa có loại chi nào.</p> : <ul aria-label="Danh sách loại chi">{loai.data.expense_categories.map((l) => <li key={l.expense_category_id}>{l.name} · {nguonTien(l.paid_from_till)}</li>)}</ul>}
        <ThemLoai bao={setBaoLoai} /></>}
    </section>
    <section aria-label="Các khoản chi" className="space-y-4 rounded-md border p-4">
      <h2 className="text-xl font-semibold">Các khoản chi</h2>
      {(params.get("tu") === null || params.get("den") === null) && <><TrangThai query={tongQuan} ten="ngày bán" />
        {tongQuan.isError && <Button variant="outline" onClick={() => void tongQuan.refetch()}>Đọc lại ngày bán</Button>}</>}
      <div className="grid gap-3 sm:grid-cols-2">{fields.map((f) => {
        const error = query.error?.kind === "rejected" && query.error.field === f.field ? loiKhoanChi(query.error) : undefined;
        const props = { id: `${id}-${f.key}`, value: f.value ?? "", onChange: (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => loc(f.key, e.target.value), "aria-invalid": !!error, "aria-describedby": error ? `${id}-${f.key}-loi` : undefined };
        return <Field key={f.key} data-invalid={!!error}><FieldLabel htmlFor={props.id}>{f.label}</FieldLabel>
          {f.key === "tu" || f.key === "den" ? <Input {...props} type="date" /> : <select {...props} className="h-9 w-full rounded-md border bg-background px-3">
            <option value="">Tất cả</option>{f.key === "loai" ? loai.data?.expense_categories.map((l) => <option key={l.expense_category_id} value={l.expense_category_id}>{l.name}</option>) : <><option value="ket">Trả từ két</option><option value="rieng">Tiền riêng</option></>}
          </select>}{error && <FieldError id={`${id}-${f.key}-loi`}>{error}</FieldError>}
        </Field>;
      })}</div>
      {from !== undefined && to !== undefined && <><TrangThai query={query} ten="khoản chi" daGhi={bao.startsWith("Đã ")} />
        <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại khoản chi</Button></>}
      {bao && <p role="status">{bao}</p>}
      {query.data && <><p>Tổng: {tien.format(query.data.total_vnd)} đ</p>
        {query.data.expenses.length === 0 ? <p>Không có khoản chi nào trong khoảng này.</p> : <ul aria-label="Danh sách khoản chi">{query.data.expenses.map((k) => <li key={k.expense_id} className="space-y-3 border-b py-3">
          <p>{k.paid_date.split("-").reverse().join("/")} · {k.category_name} · {nguonTien(k.paid_from_till)} · {tien.format(k.amount_vnd)} đ · {k.person_name}</p>
          {mo === k.expense_id ? <FormKhoan khoan={k} loai={loai.data?.expense_categories ?? []} dong={() => setMo(null)} bao={setBao} /> : <Button variant="outline" onClick={() => setMo(k.expense_id)}>Sửa</Button>}
        </li>)}</ul>}</>}
      {mo === "tao" ? <FormKhoan loai={loai.data?.expense_categories ?? []} dong={() => setMo(null)} bao={setBao} /> : <Button onClick={() => setMo("tao")}>Ghi khoản chi</Button>}
    </section>
  </div>;
}
