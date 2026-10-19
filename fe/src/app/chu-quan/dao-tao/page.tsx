import type { Metadata } from "next";
import { Suspense } from "react";
import { TrangDaoTao } from "../_components/dao-tao";

export const metadata: Metadata = { title: "Đào tạo" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang đọc đào tạo…</p>}><TrangDaoTao /></Suspense>;
}
