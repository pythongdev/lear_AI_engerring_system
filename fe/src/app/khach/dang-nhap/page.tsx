import { Suspense } from "react";
import { DangNhapKhach } from "@/components/khach/dang-nhap";

export const metadata = { title: "Đăng nhập khách" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang tải…</p>}><DangNhapKhach /></Suspense>;
}
