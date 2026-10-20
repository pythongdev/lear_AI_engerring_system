// Vỏ khung (P4-06): gác phiên một chỗ và giữ luồng /counter/events — luồng quầy là dấu hiệu quán còn nhìn thấy (ADR-097 điểm 4)
// ở layout để đổi trang con không đóng mở lại luồng.
import type { ReactNode } from "react";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";
import { BaoMatKetNoi, TinHieuProvider } from "@/lib/realtime/tin-hieu";
import { TuNhaDonHen } from "./_components/tu-nha-don-hen";

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <KhungTheoVai khung="/quay">
      <TinHieuProvider duong="/counter/events">
        <BaoMatKetNoi />
        <TuNhaDonHen />
        {children}
      </TinHieuProvider>
    </KhungTheoVai>
  );
}
