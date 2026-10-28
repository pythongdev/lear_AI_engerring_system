import { Suspense } from "react";
import { DatLaiMatKhauKhach } from "@/components/khach/quen-mat-khau";

export const metadata = { title: "Đặt lại mật khẩu" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang tải…</p>}><DatLaiMatKhauKhach /></Suspense>;
}
