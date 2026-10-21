import { loiCombo } from "@/components/shared/bo-soan-mon";
import type { ApiFailure } from "@/lib/api/client";

export const CAU_TAM_DUNG = "Quán đang tạm dừng nhận đơn. Bạn vui lòng quay lại sau ít phút hoặc gọi hotline 0382688666 để đặt.";
export const CAU_MAT_KET_NOI = "Quán tạm chưa nhận đơn qua web. Bạn vui lòng gọi hotline 0382688666 để đặt.";
export const CAU_NGOAI_GIO = "Quán mở cửa 6h–11h sáng";
export const QUET_LAI = "Bạn vui lòng quét lại mã trên bàn.";
export function loiKhach(f: ApiFailure) {
  if (f.kind !== "rejected") return "Chưa xác nhận được kết quả. Bạn có thể bấm Gửi lại.";
  switch (f.code) {
    case "order_intake_paused": return CAU_TAM_DUNG;
    case "outside_selling_hours": return CAU_NGOAI_GIO;
    case "shop_not_seeing_orders": return CAU_MAT_KET_NOI;
    case "qr_code_not_current": return QUET_LAI;
    default: return loiCombo(f.code) ?? "Chưa gửi được phiếu. Bạn vui lòng kiểm tra lại thông tin.";
  }
}
