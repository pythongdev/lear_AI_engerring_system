import type { Metadata } from "next";
import { Suspense } from "react";

import { TrangTongKet } from "../_components/tong-ket";

export const metadata: Metadata = { title: "Tổng kết" };

export default function Page() {
  return <Suspense fallback={<p role="status">Đang đọc tổng kết…</p>}><TrangTongKet /></Suspense>;
}
