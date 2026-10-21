import { backendUrl } from "@/lib/api/backend-url";
import type { components } from "@/lib/api/schema";
import { PhieuKhach } from "../ban/_components/phieu-khach";

export default async function DatMonPage() {
  let initialMenu: components["schemas"]["Menu"] | undefined;
  try {
    const response = await fetch(`${backendUrl()}/menu`, { cache: "no-store" });
    if (response.ok) initialMenu = await response.json();
  } catch { /* Lỗi đọc không quyết định quán có nhận đơn hay không. */ }
  if (!initialMenu) return <main><p>Chưa đọc được menu. Bạn vui lòng tải lại trang.</p></main>;
  return <PhieuKhach initialMenu={initialMenu} />;
}
