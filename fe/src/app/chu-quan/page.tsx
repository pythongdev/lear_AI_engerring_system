import type { Metadata } from "next";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";

export const metadata: Metadata = { title: "Chủ quán" };

export default function Page() {
  return (
    <KhungTheoVai khung="/chu-quan">
      <p>Màn chủ quán (menu, đối soát) dựng ở P4-05 trở đi; trang admin ở P4A-01…P4A-11.</p>
    </KhungTheoVai>
  );
}
