import type { Metadata } from "next";
import { Suspense } from "react";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";
import { TrangGiaoViec } from "@/app/chu-quan/_components/giao-viec";

export const metadata: Metadata = { title: "Giao việc" };

// T-212: POS giao việc từ quầy — cùng trang với chủ quán; backend chặn theo lớp quay_hoac_chu_quan.
export default function Page() {
  return <KhungTheoVai khung="/quay">
    <Suspense fallback={<p role="status">Đang mở trang giao việc…</p>}><TrangGiaoViec /></Suspense>
  </KhungTheoVai>;
}
