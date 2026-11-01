import { Suspense } from "react";
import { XacNhanGmail } from "@/components/khach/xac-nhan-gmail";

export default function Page() {
  return <Suspense fallback={<p>Đang tải…</p>}><XacNhanGmail /></Suspense>;
}
