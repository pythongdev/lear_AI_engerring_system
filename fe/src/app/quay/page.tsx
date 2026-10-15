import type { Metadata } from "next";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";

export const metadata: Metadata = { title: "Quầy" };

export default function Page() {
  return (
    <KhungTheoVai khung="/quay">
      <p>Màn quầy (hàng chờ, nhận đơn, thu tiền) dựng ở các bước sau của pha 4.</p>
    </KhungTheoVai>
  );
}
