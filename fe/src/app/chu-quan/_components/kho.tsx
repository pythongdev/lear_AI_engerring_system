"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import Link from "next/link";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { FormMenu, OMenu, chuMenu } from "./form-menu";
import { useKho, useDatTiLeKho, loiKho, oLoiKho, khongConNguyenLieu, type NguyenLieuKho, type DatTiLeKho } from "./du-lieu-kho";

const goiY = "Nhập số từ 0 đến 1, dùng dấu chấm, tối đa 6 chữ số lẻ, ví dụ 0.2.";
const schema = z.object({
  reminder_ratio: z.string().trim().regex(/^(0(\.[0-9]{1,6})?|1(\.0{1,6})?)$/, goiY),
  reason: chuMenu,
});
function NhanNhac({ thu }: { thu: NguyenLieuKho }) {
  if (thu.check_reminder === true) return <p><strong className="rounded-md bg-destructive px-2 py-1 text-white">Nhắc POS kiểm tra</strong></p>;
  if (thu.check_reminder === false) return <p>Không nhắc</p>;
  switch (thu.reminder_status) {
    case "no_purchase": return <p>Máy chưa tính nhắc: chưa có lần mua</p>;
    case "latest_purchase_zero": return <p>Máy chưa tính nhắc: lần mua gần nhất bằng 0</p>;
    case "usage_before_first_purchase": return <p>Máy chưa tính nhắc: có số dùng trước lần mua đầu</p>;
    default: return <p>Máy chưa tính nhắc</p>;
  }
}
function Thu({ thu, bao }: { thu: NguyenLieuKho; bao: (s: string) => void }) {
  const [mo, setMo] = useState(false);
  const luu = useDatTiLeKho(thu.supply_item_id);
  const form = useForm<DatTiLeKho>({ resolver: zodResolver(schema), defaultValues: { reminder_ratio: thu.reminder_ratio, reason: "" } });
  const donVi = thu.purchase_unit ?? "Chưa có đơn vị";
  return <li className="space-y-3 rounded-md border p-4">
    <h2 className="text-lg font-semibold">{thu.name}</h2>
    <p>{donVi}</p>
    <dl className="space-y-2">
      <div><dt>Tổng mua vào</dt><dd>{thu.purchased_total} {donVi}</dd></div>
      <div><dt>Tổng đã dùng</dt><dd>{thu.used_total} {donVi}</dd></div>
      <div><dt>Mua vào trừ đã dùng</dt><dd>{thu.balance} {donVi}</dd></div>
      <div><dt>Lần nhập gần nhất</dt><dd>{thu.latest_purchase_date === null || thu.latest_purchase_measure === null
        ? "Chưa có lần mua" : `${thu.latest_purchase_date.split("-").reverse().join("/")} · ${thu.latest_purchase_measure} ${donVi}`}</dd></div>
      <div><dt>Tỉ lệ nhắc</dt><dd>{thu.reminder_ratio}</dd></div>
    </dl>
    <p className="text-sm text-muted-foreground">tỉ phần của lần nhập gần nhất, từ 0 đến 1</p>
    <NhanNhac thu={thu} />
    <Link className="underline" href={`/chu-quan/nguyen-lieu?thu=${thu.supply_item_id}`}>Mở sổ</Link>
    {!mo ? <div><Button variant="outline" aria-label={`Đặt tỉ lệ ${thu.name}`} onClick={() => {
      form.reset({ reminder_ratio: thu.reminder_ratio, reason: "" }); setMo(true);
    }}>Đặt tỉ lệ</Button></div> : <FormMenu form={form} ten={`Đặt tỉ lệ ${thu.name}`} nut="Lưu tỉ lệ"
      cacO={["reminder_ratio", "reason"]} loi={loiKho} oLoi={oLoiKho} dong={() => setMo(false)}
      gui={async (body) => {
        const r = await luu.mutateAsync(body);
        if (!r.ok && khongConNguyenLieu(r.failure)) bao(loiKho(r.failure));
        return r;
      }} daLuu={() => { bao("Đã đặt tỉ lệ."); setMo(false); }}>
      <OMenu form={form} o="reminder_ratio" nhan="Tỉ lệ nhắc" />
      <p>{goiY}</p>
      <OMenu form={form} o="reason" nhan="Lý do (bắt buộc)" />
    </FormMenu>}
  </li>;
}
export function TrangKho() {
  const query = useKho();
  const [thongBao, bao] = useState("");
  return <div className="mx-auto w-full max-w-4xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Kho</h1>
    {query.isPending && <p role="status">{query.fetchStatus === "paused" ? "Đang chờ kết nối." : "Đang đọc kho…"}</p>}
    {query.isError && <Alert role="alert"><AlertDescription>Chưa đọc được kho.
      {query.data && ` Đang hiện bản đọc trước, lúc ${new Date(query.dataUpdatedAt).toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" })}.`}
      {thongBao === "Đã đặt tỉ lệ." && " Đã ghi, chưa cập nhật được dữ liệu."}
    </AlertDescription></Alert>}
    <Button variant="outline" disabled={query.isFetching} onClick={() => void query.refetch()}>Đọc lại kho</Button>
    {thongBao && <p role="status">{thongBao}</p>}
    {query.data && <>
      {query.isFetching && <p role="status">Đang đọc lại kho…</p>}
      {query.data.supply_items.length === 0 ? <p>Chưa có nguyên liệu nào.</p> :
        <ul aria-label="Kho nguyên liệu" className="space-y-4">{query.data.supply_items.map((thu) => <Thu key={thu.supply_item_id} thu={thu} bao={bao} />)}</ul>}
    </>}
  </div>;
}
