import { Suspense } from "react";
import { DonKhach } from "@/components/khach/don";

export const metadata = { title: "Đơn đã đặt" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang tải…</p>}><DonKhach /></Suspense>;
}
