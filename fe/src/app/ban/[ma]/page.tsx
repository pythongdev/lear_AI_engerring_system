import { backendUrl } from "@/lib/api/backend-url";
import type { components } from "@/lib/api/schema";
import { PhieuKhach } from "../_components/phieu-khach";

export default async function BanPage({ params }: { params: Promise<{ ma: string }> }) {
  const { ma } = await params;
  let table: components["schemas"]["QrTable"] | undefined;
  let initialMenu: components["schemas"]["Menu"] | undefined;
  let loi = "Chưa đọc được dữ liệu. Bạn vui lòng tải lại trang.";
  try {
    const [qr, menu] = await Promise.all([
      fetch(`${backendUrl()}/qr-codes/${encodeURIComponent(ma)}`, { cache: "no-store" }),
      fetch(`${backendUrl()}/menu`, { cache: "no-store" }),
    ]);
    if (!qr.ok) {
      const error = await qr.json();
      loi = qr.status === 404 && error.code === "qr_code_not_current"
        ? "Bạn vui lòng quét lại mã trên bàn." : "Chưa đọc được bàn. Bạn vui lòng tải lại trang.";
    } else if (!menu.ok) {
      loi = "Chưa đọc được menu. Bạn vui lòng tải lại trang.";
    } else {
      table = await qr.json();
      initialMenu = await menu.json();
    }
  } catch { /* Giữ lời lỗi đọc trung tính, không suy ra quán ngừng nhận đơn. */ }
  if (!table || !initialMenu) return <main><p>{loi}</p></main>;
  return <PhieuKhach ma={ma} nhan={table.label} initialMenu={initialMenu} />;
}
