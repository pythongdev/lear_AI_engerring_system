import type { Metadata } from "next";
import { Suspense } from "react";
import { TrangGiaoViec } from "../_components/giao-viec";

export const metadata: Metadata = { title: "Giao việc" };

export default function Page() {
  return <Suspense fallback={<p role="status">Đang mở trang giao việc…</p>}><TrangGiaoViec /></Suspense>;
}
