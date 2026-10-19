// Vỏ chung của mọi trang /chu-quan/* (P4A-01): một chỗ gác theo phiên (KhungTheoVai — tiện, không phải bảo vệ;
// backend vẫn chặn theo lớp chu_quan) và thanh điều hướng giữa các trang admin. Không bảng quyền thứ hai.
import type { ReactNode } from "react";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";

import { ThanhDieuHuong } from "./_components/thanh-dieu-huong";

export default function Layout({ children }: { children: ReactNode }) {
  return (
    <KhungTheoVai khung="/chu-quan">
      <ThanhDieuHuong />
      {children}
    </KhungTheoVai>
  );
}
