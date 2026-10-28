import { Suspense } from "react";
import { QuenMatKhauKhach } from "@/components/khach/quen-mat-khau";

export const metadata = { title: "Quên mật khẩu" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang tải…</p>}><QuenMatKhauKhach /></Suspense>;
}
