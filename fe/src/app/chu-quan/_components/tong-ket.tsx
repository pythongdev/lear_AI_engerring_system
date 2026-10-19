"use client";
// Trang Tổng kết của chủ quán (P4A-03, shop-facts §8.6). Ngày xem đi trên URL, mặc định là sale_date backend trả —
// không dựng từ đồng hồ máy; mọi số là số backend trả, không cộng trừ (ADR-086); món và người giữ thứ tự backend.

import { useQuery } from "@tanstack/react-query";
import { useRouter, useSearchParams } from "next/navigation";
import { useId, type ReactNode } from "react";

import { Alert, AlertDescription } from "@/components/ui/alert";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

import { useTongQuan } from "./du-lieu-tong-quan";

type TongKet = components["schemas"]["SaleDaySummary"];
const tien = new Intl.NumberFormat("vi-VN");
const gio = new Intl.DateTimeFormat("vi-VN", {
  timeZone: "Asia/Ho_Chi_Minh", hour: "2-digit", minute: "2-digit", second: "2-digit", hourCycle: "h23",
});
function ngayBan(ngay: string) { return ngay.split("-").reverse().join("/"); }

function Muc({ ten, children }: { ten: string; children: ReactNode }) {
  const id = useId();
  return <section aria-labelledby={id}><Card className="h-full">
    <CardHeader><CardTitle><h2 id={id}>{ten}</h2></CardTitle></CardHeader>
    <CardContent className="space-y-3">{children}</CardContent>
  </Card></section>;
}

export function TrangTongKet() {
  const router = useRouter();
  const thamSo = useSearchParams();
  const tongQuan = useTongQuan();
  // Ngày mặc định chỉ đến từ backend; tham số có mặt được gửi nguyên để backend kiểm tra.
  const ngay = thamSo.get("ngay") ?? tongQuan.data?.sale_date;
  const api = useApi();
  const query = useQuery<TongKet, ApiFailure>({
    queryKey: ["sale-day-summary", ngay],
    enabled: ngay !== undefined,
    queryFn: async () => {
      const r = await call(api.GET("/sale-days/{sale_date}/summary", {
        params: { path: { sale_date: ngay! } },
      }));
      if (!r.ok) throw r.failure;
      return r.data;
    },
  });
  const loiNgay = query.error?.kind === "rejected" && query.error.status === 400 && query.error.code === "invalid_request";
  const data = loiNgay ? undefined : query.data;
  // Lỗi tổng quan chỉ chặn trang khi cần nó để biết ngày; có ngày trên URL thì chỉ mục nhắc kiểm tra thiếu đối chiếu.
  const loi = query.isError || (ngay === undefined && tongQuan.isError);

  return <div className="mx-auto w-full max-w-6xl space-y-6 p-4 sm:p-6">
    <h1 className="text-2xl font-semibold">Tổng kết</h1>
    <div className="space-y-2">
      <Label htmlFor="ngay-ban">Ngày bán</Label>
      <Input id="ngay-ban" type="date" value={ngay ?? ""} className="w-auto"
        onChange={(event) => {
          if (event.target.value) router.push(`/chu-quan/tong-ket?ngay=${event.target.value}`);
        }} />
    </div>
    {query.isPending && !loi && <p role="status">Đang đọc tổng kết…</p>}
    {loi && <Alert role="alert"><AlertDescription>
      {loiNgay ? "Ngày không hợp lệ. Hãy chọn lại ngày bán."
        : !query.isError ? "Không đọc được ngày bán hiện tại. Hãy thử lại."
        : data ? "Không đọc được tổng kết mới. Đang hiện bản đọc trước của ngày bán đã chọn."
          : "Không đọc được tổng kết. Hãy thử lại."}
    </AlertDescription></Alert>}
    {data && <div className="grid gap-4 md:grid-cols-2">
      <Muc ten="Doanh thu">
        <dl className="space-y-2">
          <div><dt>Phiên bàn</dt><dd>{tien.format(data.revenue.table_session_vnd)} đ</dd></div>
          <div><dt>Đơn lẻ</dt><dd>{tien.format(data.revenue.standalone_vnd)} đ</dd></div>
          <div><dt>Hoàn tiền</dt><dd>{tien.format(data.revenue.refunds_vnd)} đ</dd></div>
          <div className="font-semibold"><dt>Tổng</dt><dd>{tien.format(data.revenue.total_vnd)} đ</dd></div>
        </dl>
        <p>{data.revenue.reconciliation_status === null ? "Chưa đối soát"
          : data.revenue.reconciliation_status === "reconciled" ? "Đã đối soát" : "Đã mở lại đối soát"}</p>
        {data.revenue.paper_entries_pending > 0 && <p>{data.revenue.paper_entries_pending} mục sổ giấy còn chờ</p>}
      </Muc>
      <Muc ten="Món bán chạy">
        {data.best_sellers.items.length === 0 && data.best_sellers.combos.length === 0 && <p>Chưa bán món nào trong ngày.</p>}
        <div role="group" aria-label="Món">
          <h3 className="font-medium">Món</h3>
          <ul>{data.best_sellers.items.map((item) => <li key={item.menu_item_id}>{item.name}: {item.quantity}</li>)}</ul>
        </div>
        <div role="group" aria-label="Combo">
          <h3 className="font-medium">Combo</h3>
          <ul>{data.best_sellers.combos.map((item) => <li key={item.menu_combo_id}>{item.name}: {item.quantity}</li>)}</ul>
        </div>
      </Muc>
      <Muc ten="Hiệu suất nhân viên">
        <ul className="space-y-4">{data.staff.map((person) => <li key={person.person_id}>
          <h3 className="font-medium">{person.display_name}</h3>
          <p>{person.worked ? "Có đi làm" : "Không đi làm"}</p>
          <p>Đơn ghi ở quầy: {person.counter_orders}</p>
          <p>Lần đi giao: {person.deliveries}</p>
          <p>Lần huỷ: {person.cancellations}</p>
          <p>Lần hoàn tiền: {person.refunds}</p>
        </li>)}</ul>
      </Muc>
      <Muc ten="Cảnh báo sắp hết">
        <p>Kết quả hiện tại, đọc lúc {gio.format(new Date(data.supply_reminders.read_at))}.
          {tongQuan.data && ngay !== tongQuan.data.sale_date && ` Đây không phải của ngày ${ngayBan(ngay!)}.`}</p>
        {!tongQuan.data && <p>Chưa đọc được ngày bán hiện tại để đối chiếu với ngày đang xem.</p>}
        {data.supply_reminders.items.length === 0 ? <p>Máy chưa nhắc kiểm tra nguyên liệu nào.</p>
          : <ul>{data.supply_reminders.items.map((item) => <li key={item.supply_item_id}>{item.name}</li>)}</ul>}
      </Muc>
    </div>}
  </div>;
}
