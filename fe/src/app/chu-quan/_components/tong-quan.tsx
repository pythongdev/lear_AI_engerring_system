"use client";
// Trang Tổng quan của chủ quán (P4A-02, shop-facts §8.6). Mọi số là số backend trả — frontend chỉ định dạng, không
// cộng trừ (ADR-086); tiền tạm tính không bao giờ bày như doanh thu đã đối soát; mục unavailable nói đúng lý do.

import { useId, type ReactNode } from "react";

import { Alert, AlertDescription } from "@/components/ui/alert";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import type { components } from "@/lib/api/schema";

import { useTongQuan } from "./du-lieu-tong-quan";
import { FormToiThieu } from "./form-toi-thieu";

// Múi giờ quán: master_plan/shop-facts.md §1.
const MUI_GIO_QUAN = "Asia/Ho_Chi_Minh";
const gio = new Intl.DateTimeFormat("vi-VN", { timeZone: MUI_GIO_QUAN, hour: "2-digit", minute: "2-digit", second: "2-digit", hourCycle: "h23" });
const tien = new Intl.NumberFormat("vi-VN");
function dinhDangGio(moc: string) { return gio.format(new Date(moc)); }
function ngayBan(ngay: string) { return ngay.split("-").reverse().join("/"); }

function Muc({ ten, children }: { ten: string; children: ReactNode }) {
  const id = useId();
  return <section aria-labelledby={id}><Card className="h-full">
    <CardHeader><CardTitle><h2 id={id}>{ten}</h2></CardTitle></CardHeader>
    <CardContent className="space-y-3">{children}</CardContent>
  </Card></section>;
}

function ChuaCo({ muc }: { muc: components["schemas"]["OverviewUnavailable"] }) {
  const lyDo = {
    daily_minimum_missing: "Chưa nhập số tối thiểu của ngày",
    workers_present_missing: "POS chưa khai số người đang làm",
  };
  return <p>{lyDo[muc.reason]}</p>;
}

function CacPhan({ data }: { data: components["schemas"]["OverviewPortions"] }) {
  return <>
    <p className="text-sm text-muted-foreground">Mốc nguồn: {dinhDangGio(data.read_at)}</p>
    {([ ["in_store", "Tại quán"], ["online", "Giao hàng online"] ] as const).map(([nhom, ten]) => (
      <div role="group" aria-label={ten} key={nhom}>
        <h3 className="font-medium">{ten}</h3>
        <ul className="space-y-1">{data.rows.filter((row) => row.group === nhom).map((row, index) => (
          <li key={index}>{row.component_name} × {row.quantity}</li>
        ))}</ul>
      </div>
    ))}
  </>;
}

export function TrangTongQuan() {
  const query = useTongQuan();
  const data = query.data;
  return <div className="mx-auto w-full max-w-6xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Tổng quan</h1>
    {query.isPending && <p role="status">Đang đọc tổng quan…</p>}
    {query.isError && <Alert role="alert"><AlertDescription>
      {data ? `Không đọc được bản mới. Đang hiện bản đọc lúc ${dinhDangGio(data.read_at)} của ngày bán ${ngayBan(data.sale_date)}.` : "Không đọc được tổng quan."}
    </AlertDescription></Alert>}
    {data && <>
      <div><p>Ngày bán {ngayBan(data.sale_date)}</p><p>Đọc lúc {dinhDangGio(data.read_at)}</p></div>
      <div className="grid gap-4 md:grid-cols-2">
        <Muc ten={data.serving_guests.name}><p>{data.serving_guests.quantity} bàn đang phục vụ</p></Muc>
        <Muc ten="Đã ra"><CacPhan data={data.served_portions} /></Muc>
        <Muc ten="Còn thiếu"><CacPhan data={data.missing_portions} /></Muc>
        <Muc ten={data.sales_progress.name}>{data.sales_progress.status === "available"
          ? <p>{data.sales_progress.served_banh} / {data.sales_progress.minimum_banh} bánh</p>
          : <ChuaCo muc={data.sales_progress} />}</Muc>
        <Muc ten={data.provisional_sales.name}>
          <p className="text-xl font-semibold">{tien.format(data.provisional_sales.amount_vnd)} đ</p>
          <p>Tiền bán tạm tính, chưa đối soát.</p>
        </Muc>
        <Muc ten={data.workers_present.name}>{data.workers_present.status === "available"
          ? <p>{data.workers_present.worker_count} người</p>
          : <ChuaCo muc={data.workers_present} />}</Muc>
        <Muc ten="Còn thiếu gì">
          <h3 className="font-medium">Nguyên liệu</h3>
          <ul className="space-y-2">{data.shortages.supplies.items.map((item) => <li key={item.supply_item_id}>
            <p>{item.name}</p><p>Còn {item.balance} {item.purchase_unit}</p>
            {item.check_reminder === true && <p>Nên kiểm tra</p>}
            {item.check_reminder === null && <p>Chưa đủ dữ liệu để nhắc</p>}
          </li>)}</ul>
          <h3 className="font-medium">{data.shortages.workers.name}</h3>
          {data.shortages.workers.status === "unavailable" ? <ChuaCo muc={data.shortages.workers} />
            : <p>{data.shortages.workers.short ? `Thiếu ${data.shortages.workers.missing_workers} người` : "Không thiếu người"}</p>}
          <h3 className="font-medium">Món</h3>
          <ul>{data.shortages.menu_items.items.map((item, index) => <li key={index}>
            {item.name}: khách đặt {item.ordered}, đã ra {item.served}
          </li>)}</ul>
        </Muc>
      </div>
      <FormToiThieu key={data.sale_date} data={data} />
    </>}
  </div>;
}
