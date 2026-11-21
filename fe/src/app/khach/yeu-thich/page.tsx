import { Suspense } from "react";
import { YeuThichKhach } from "@/components/khach/yeu-thich";

export const metadata = { title: "Yêu thích" };
export default function Page() {
  return <Suspense fallback={<p role="status">Đang tải…</p>}><YeuThichKhach /></Suspense>;
}
