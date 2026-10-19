import type { Metadata } from "next";
import { Suspense } from "react";
import { TrangKhoanChi } from "../_components/khoan-chi";

export const metadata: Metadata = { title: "Khoản chi" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang đọc khoản chi…</p>}><TrangKhoanChi /></Suspense>;
}
