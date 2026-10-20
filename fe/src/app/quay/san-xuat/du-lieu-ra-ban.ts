import type { ApiFailure } from "@/lib/api/client";

export function loiRaBan(f: ApiFailure) {
  if (f.kind === "no_response") return "Chưa xác nhận được kết quả. Hãy đọc lại bảng để kiểm tra trước khi ghi tiếp.";
  if (f.kind === "unexpected") return "Phản hồi không đúng hợp đồng. Chưa xác nhận được kết quả.";
  if (f.code.endsWith("_not_found")) return "Dữ liệu không còn. Đang đọc lại bảng.";
  switch (f.code) {
    case "served_quantity_exceeds_made": return "Số ra bàn vượt số đã làm. Đang đọc lại bảng.";
    case "delivery_served_mark_undecided": return "Chưa có quy tắc ghi ra bàn cho đơn giao tận nơi.";
    case "not_on_counter_duty": return "Bạn chưa đứng quầy. Hãy đứng quầy trước khi ghi ra bàn.";
    case "unauthenticated": return "Phiên đăng nhập đã hết. Hãy đăng nhập lại.";
    case "invalid_request": return "Dữ liệu chưa hợp lệ. Hãy kiểm tra lại.";
    default: return "Không ghi được ra bàn. Mã: " + f.code;
  }
}
