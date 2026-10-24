import type { Metadata } from "next";
import { Suspense } from "react";
import { TrangGiaoViec } from "../_components/giao-viec";

export const metadata: Metadata = { title: "Giao việc" };

export default function Page() {
  return (
    <Suspense fallback={<p role="status" className="p-4 sm:p-6">Đang mở trang giao việc…</p>}>
      <TrangGiaoViec />
    </Suspense>
  );
}
