"use client";

import { useInfiniteQuery } from "@tanstack/react-query";
import { DongMonDaGhi } from "@/components/shared/dong-mon-da-ghi";
import { Button } from "@/components/ui/button";
import { call, type ApiFailure } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { hetPhien, useChuyenDangNhap } from "@/lib/khach/session";
import { KhungKhach, LoiDocKhach } from "./khung";

const trangThai: Record<string, string> = { pending_confirmation: "Chờ xác nhận", confirmed: "Đã xác nhận", rejected: "Đã từ chối", cancelled: "Đã huỷ", completed: "Hoàn tất", in_progress: "Đang làm", delivered: "Đã giao" };
export function DonKhach() {
  const api = useApi();
  const don = useInfiniteQuery({ queryKey: ["customer-accounts", "current", "orders"], initialPageParam: undefined as number | undefined,
    queryFn: async ({ pageParam }) => {
      const r = await call(api.GET("/customer-accounts/current/orders", { params: { query: { before_id: pageParam } } }));
      if (!r.ok) throw r.failure;
      return r.data;
    }, getNextPageParam: (p) => p.next_before_id ?? undefined, retry: false,
  });
  const error = don.error as ApiFailure | null;
  useChuyenDangNhap(hetPhien(error));
  return <KhungKhach title="Đơn đã đặt">
    {don.isPending && <p role="status">Đang tải đơn…</p>}
    {error && !hetPhien(error) && <LoiDocKhach error={error} docLai={() => void don.refetch()} readAt={don.dataUpdatedAt} />}
    {!hetPhien(error) && don.data && <>
      {don.data.pages[0].orders.length === 0 && <p>Bạn chưa có đơn nào gắn với tài khoản này.</p>}
      {don.data.pages.flatMap((p) => p.orders).map((d) => <section key={d.sales_order_id} aria-label={`Đơn ${d.sales_order_id}`} className="space-y-2 border-b pb-4">
        <h2 className="font-semibold">Đơn {d.sales_order_id}</h2>
        <p><time dateTime={d.created_at}>{new Date(d.created_at).toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" })}</time></p>
        <p>{d.channel_code === "delivery" ? "Giao tận nơi" : d.channel_code === "pickup" ? "Đến lấy" : d.channel_code} · {trangThai[d.status] ?? d.status}</p>
        <DongMonDaGhi lines={d.lines} total={d.total_vnd} />
      </section>)}
      {don.hasNextPage && <Button disabled={don.isFetching} onClick={() => void don.fetchNextPage()}>{don.isFetchingNextPage ? "Đang tải…" : "Xem thêm"}</Button>}
    </>}
  </KhungKhach>;
}
