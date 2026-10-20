import type { Metadata } from "next";
import { Suspense } from "react";

import { TrangGiaoViec } from "@/app/chu-quan/_components/giao-viec";

export const metadata: Metadata = { title: "Giao việc" };

// T-212: POS giao việc từ quầy — cùng trang với chủ quán; backend chặn theo lớp quay_hoac_chu_quan.
export default function Page() {
  return <Suspense fallback={<p role="status">Đang mở trang giao việc…</p>}><TrangGiaoViec /></Suspense>;
}
