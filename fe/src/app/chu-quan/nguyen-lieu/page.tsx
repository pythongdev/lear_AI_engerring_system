import type { Metadata } from "next";
import { Suspense } from "react";
import { TrangNguyenLieu } from "../_components/nguyen-lieu";

export const metadata: Metadata = { title: "Nguyên liệu" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang đọc nguyên liệu…</p>}><TrangNguyenLieu /></Suspense>;
}
