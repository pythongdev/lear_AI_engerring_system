import type { Metadata } from "next";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";

export const metadata: Metadata = { title: "Trạm" };

export default function Page() {
  return (
    <KhungTheoVai khung="/tram">
      <p>Bảng trạm chỉ xem dựng ở các bước sau của pha 4.</p>
    </KhungTheoVai>
  );
}
