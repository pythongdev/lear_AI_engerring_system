// Vỏ khung (P4-06): gác phiên một chỗ và giữ luồng /production-board/events
// ở layout để đổi trang con không đóng mở lại luồng.
import type { ReactNode } from "react";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";
import { BaoMatKetNoi, TinHieuProvider } from "@/lib/realtime/tin-hieu";

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <KhungTheoVai khung="/tram">
      <TinHieuProvider duong="/production-board/events">
        <BaoMatKetNoi />
        {children}
      </TinHieuProvider>
    </KhungTheoVai>
  );
}
