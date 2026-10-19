"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { useId, useState } from "react";
import { useForm, type FieldPath, type FieldValues, type UseFormReturn } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { usePhien } from "@/lib/auth/session";
import {
  useTaiKhoan, useNguoi, useDuyet, useTuChoi, useKhoa, useMoLai, loiNhanVien, oLoiNhanVien, tenVai, vaiTram,
  type TaiKhoan, type Nguoi, type Duyet, type MoLai,
} from "./du-lieu-nhan-vien";
import { FormMenu } from "./form-menu";

type Bao = (message: string) => void;
type Sua = "duyet" | "tu-choi" | "khoa" | "mo-lai" | null;
const nhom = [
  { status: "cho_duyet", ten: "Chờ duyệt" },
  { status: "hoat_dong", ten: "Đang làm" },
  { status: "khoa", ten: "Đã khoá" },
  { status: "tu_choi", ten: "Đã từ chối" },
] as const;
const duyetSchema = z.object({
  role_code: z.string().refine((v) => vaiTram.some((vai) => vai.ma === v), "Chọn vai."),
  person_id: z.number().int().positive().optional(),
});
const moLaiSchema = z.object({ temporary_password: z.string().min(8, "Mật khẩu tạm cần ít nhất 8 ký tự.") });
const ngay = (iso: string) => new Date(iso).toLocaleDateString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" });
const loi = { loi: loiNhanVien, oLoi: oLoiNhanVien };

function OChon<T extends FieldValues>({ form, o, nhan, dau, options, so = false }: {
  form: UseFormReturn<T>; o: FieldPath<T>; nhan: string; dau: string; options: { gt: string; ten: string }[]; so?: boolean;
}) {
  const id = useId();
  const sai = form.getFieldState(o, form.formState).error?.message;
  return <Field data-invalid={!!sai}>
    <FieldLabel htmlFor={id}>{nhan}</FieldLabel>
    <select id={id} aria-invalid={!!sai} aria-describedby={sai ? `${id}-loi` : undefined}
      {...form.register(o, so ? { setValueAs: (v: string) => (v === "" ? undefined : Number(v)) } : {})}
      className="h-9 w-full rounded-md border bg-background px-3">
      <option value="">{dau}</option>
      {options.map((v) => <option key={v.gt} value={v.gt}>{v.ten}</option>)}
    </select>
    {sai && <FieldError id={`${id}-loi`}>{sai}</FieldError>}
  </Field>;
}

function FormDuyet({ t, nguoiTrong, dong, bao }: { t: TaiKhoan; nguoiTrong?: Nguoi[]; dong: () => void; bao: Bao }) {
  const luu = useDuyet(t.account_id);
  const form = useForm<Duyet>({ resolver: zodResolver(duyetSchema), defaultValues: { role_code: "", person_id: undefined } });
  return <FormMenu form={form} ten={`Duyệt ${t.display_name}`} nut="Xác nhận duyệt" gui={luu.mutateAsync} {...loi}
    cacO={["role_code", "person_id"]} dong={dong} daLuu={() => { bao(`Đã duyệt ${t.display_name}.`); dong(); }}>
    <OChon form={form} o="role_code" nhan="Vai" dau="Chọn vai" options={vaiTram.map((v) => ({ gt: v.ma, ten: v.ten }))} />
    <OChon form={form} o="person_id" nhan="Người trong quán" so dau={`Tạo người mới: ${t.display_name}`}
      options={(nguoiTrong ?? []).map((p) => ({ gt: String(p.person_id), ten: p.display_name }))} />
    {!nguoiTrong && <p className="text-sm text-muted-foreground">Chưa đọc được danh sách người — chỉ tạo được người mới.</p>}
  </FormMenu>;
}
function FormXacNhan({ ten, nut, loiDan, gui, dong, daLuu }: {
  ten: string; nut: string; loiDan: string; gui: () => ReturnType<ReturnType<typeof useKhoa>["mutateAsync"]>;
  dong: () => void; daLuu: () => void;
}) {
  const form = useForm<Record<string, never>>({ defaultValues: {} });
  return <FormMenu form={form} ten={ten} nut={nut} gui={() => gui()} cacO={[]} dong={dong} daLuu={daLuu} {...loi}>
    <p>{loiDan}</p>
  </FormMenu>;
}
function FormMoLai({ t, dong, bao }: { t: TaiKhoan; dong: () => void; bao: Bao }) {
  const luu = useMoLai(t.account_id);
  const id = useId();
  const form = useForm<MoLai>({ resolver: zodResolver(moLaiSchema), defaultValues: { temporary_password: "" } });
  const sai = form.formState.errors.temporary_password?.message;
  return <FormMenu form={form} ten={`Mở lại ${t.display_name}`} nut="Xác nhận mở lại" gui={luu.mutateAsync} {...loi}
    cacO={["temporary_password"]} dong={dong} daLuu={() => {
      bao(`Đã mở lại tài khoản ${t.display_name}. Người ấy đăng nhập bằng mật khẩu tạm và phải đổi ngay ở lần đăng nhập ấy.`);
      dong();
    }}>
    <p>Đặt một mật khẩu tạm rồi báo cho {t.display_name}.</p>
    <Field data-invalid={!!sai}>
      <FieldLabel htmlFor={id}>Mật khẩu tạm</FieldLabel>
      <Input id={id} type="password" autoComplete="new-password" aria-invalid={!!sai}
        aria-describedby={sai ? `${id}-loi` : undefined} {...form.register("temporary_password")} />
      {sai && <FieldError id={`${id}-loi`}>{sai}</FieldError>}
    </Field>
  </FormMenu>;
}

function TheTaiKhoan({ t, chinhMinh, nguoiTrong, bao }: { t: TaiKhoan; chinhMinh: boolean; nguoiTrong?: Nguoi[]; bao: Bao }) {
  const [sua, setSua] = useState<Sua>(null);
  const tuChoi = useTuChoi(t.account_id);
  const khoa = useKhoa(t.account_id);
  const dong = () => setSua(null);
  const nut = (ma: Exclude<Sua, null>, chu: string) =>
    <Button variant="outline" aria-label={`${chu} ${t.display_name}`} onClick={() => setSua(ma)}>{chu}</Button>;
  return <li className="space-y-3 border-b py-4 last:border-0">
    <h3 className="font-medium">{t.display_name}</h3>
    <p className="text-sm text-muted-foreground">
      Tên đăng nhập: {t.username} · Gmail: {t.email}{t.role_code && ` · Vai: ${tenVai(t.role_code)}`} · Đăng ký ngày {ngay(t.created_at)}
    </p>
    {!sua && <div className="flex gap-2">
      {t.status === "cho_duyet" && <>{nut("duyet", "Duyệt")}{nut("tu-choi", "Từ chối")}</>}
      {t.status === "hoat_dong" && !chinhMinh && nut("khoa", "Khoá")}
      {t.status === "khoa" && nut("mo-lai", "Mở lại")}
    </div>}
    {sua === "duyet" && <FormDuyet t={t} nguoiTrong={nguoiTrong} dong={dong} bao={bao} />}
    {sua === "tu-choi" && <FormXacNhan ten={`Từ chối ${t.display_name}`} nut="Xác nhận từ chối" gui={tuChoi.mutateAsync}
      loiDan={`${t.display_name} sẽ không đăng nhập được; lần đăng ký vẫn được giữ trong danh sách.`} dong={dong}
      daLuu={() => { bao(`Đã từ chối ${t.display_name}.`); dong(); }} />}
    {sua === "khoa" && <FormXacNhan ten={`Khoá ${t.display_name}`} nut="Xác nhận khoá" gui={khoa.mutateAsync}
      loiDan={`Mọi phiên đăng nhập của ${t.display_name} kết thúc ngay; tài khoản vẫn ở danh sách và mở lại được.`} dong={dong}
      daLuu={() => { bao(`Đã khoá tài khoản ${t.display_name}.`); dong(); }} />}
    {sua === "mo-lai" && <FormMoLai t={t} dong={dong} bao={bao} />}
  </li>;
}

function Nhom({ ten, ds, chinhMinh, nguoiTrong, bao }: {
  ten: string; ds: TaiKhoan[]; chinhMinh?: number; nguoiTrong?: Nguoi[]; bao: Bao;
}) {
  const id = useId();
  return <section aria-labelledby={id}><Card><CardContent className="space-y-2">
    <h2 id={id} className="text-lg font-semibold">{ten}</h2>
    {ds.length === 0 ? <p>Không có tài khoản nào.</p> : <ul>{ds.map((t) =>
      <TheTaiKhoan key={t.account_id} t={t} chinhMinh={t.person_id !== null && t.person_id === chinhMinh}
        nguoiTrong={nguoiTrong} bao={bao} />)}</ul>}
  </CardContent></Card></section>;
}

export function TrangNhanVien() {
  const query = useTaiKhoan();
  const nguoi = useNguoi();
  const phien = usePhien();
  const [thongBao, bao] = useState<string | null>(null);
  const data = query.data;
  const chinhMinh = phien.data?.ok ? phien.data.data.person_id : undefined;
  // Gắn được: người chưa có tài khoản và không phải chủ quán — cờ chủ quán không có đường qua màn duyệt (ADR-109 điểm 3).
  const daCo = new Set(data?.accounts.map((t) => t.person_id));
  const nguoiTrong = nguoi.data?.people.filter((p) => !p.is_owner && !daCo.has(p.person_id));
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Nhân viên</h1>
    {(query.isPending || phien.isPending) && !query.isError &&
      <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc danh sách tài khoản…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được danh sách tài khoản.
      {data ? ` Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleTimeString("vi-VN")}.` : " Hãy thử lại."}
      {thongBao && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
    <Button variant="outline" disabled={query.isFetching || nguoi.isFetching}
      onClick={() => { void query.refetch(); void nguoi.refetch(); }}>Đọc lại danh sách</Button>
    {thongBao && <p role="status">{thongBao}</p>}
    {data && !phien.isPending && <>
      {query.isFetching && <p role="status">Đang đọc lại danh sách tài khoản…</p>}
      {nhom.map((n) => <Nhom key={n.status} ten={n.ten} ds={data.accounts.filter((t) => t.status === n.status)}
        chinhMinh={chinhMinh} nguoiTrong={nguoiTrong} bao={bao} />)}
    </>}
  </div>;
}
