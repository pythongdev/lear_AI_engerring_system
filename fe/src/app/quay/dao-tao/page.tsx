import type { Metadata } from "next";
import { Suspense } from "react";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";
import { TrangDaoTao } from "@/app/chu-quan/_components/dao-tao";

export const metadata: Metadata = { title: "Đào tạo" };

// T-212: POS ghi nhận xét và gắn hướng dẫn từ quầy — cùng trang với chủ quán; backend chặn theo lớp quay_hoac_chu_quan.
export default function Page() {
  return <KhungTheoVai khung="/quay">
    <Suspense fallback={<p role="status">Đang đọc đào tạo…</p>}><TrangDaoTao /></Suspense>
  </KhungTheoVai>;
}
