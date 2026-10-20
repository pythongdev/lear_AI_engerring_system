import type { Metadata } from "next";
import Link from "next/link";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";

export const metadata: Metadata = { title: "Quầy" };

export default function Page() {
  return (
    <KhungTheoVai khung="/quay">
      <p>Màn quầy (hàng chờ, nhận đơn, thu tiền) dựng ở các bước sau của pha 4.</p>
      {/* T-212: POS giao việc và ghi đào tạo từ quầy (U-089 · U-090); cùng trang với chủ quán. */}
      <nav aria-label="Việc ở quầy" className="mt-4 flex gap-4">
        <Link className="underline" href="/quay/giao-viec">Giao việc</Link>
        <Link className="underline" href="/quay/dao-tao">Đào tạo</Link>
      </nav>
    </KhungTheoVai>
  );
}
