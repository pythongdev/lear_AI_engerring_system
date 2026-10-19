import type { Metadata } from "next";
import { TrangNhanVien } from "../_components/nhan-vien";

export const metadata: Metadata = { title: "Nhân viên" };

export default function Page() {
  return <TrangNhanVien />;
}
