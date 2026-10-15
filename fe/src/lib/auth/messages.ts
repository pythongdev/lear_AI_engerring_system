// Chữ cho từng lời từ chối của các cửa tài khoản — chọn theo `code`, không theo status (01-khung-fe.md §3.1).
import type { ApiFailure, ErrorCode } from "@/lib/api/client";

const CHU: Partial<Record<ErrorCode, string>> = {
  invalid_credentials: "Sai tên đăng nhập hoặc mật khẩu.",
  login_temporarily_blocked: "Đăng nhập sai 5 lần liền — tài khoản tạm khoá 15 phút, thử lại sau.",
  username_taken: "Tên đăng nhập này đã có người dùng.",
  email_taken: "Gmail này đã gắn với một tài khoản khác.",
  password_too_short: "Mật khẩu cần ít nhất 8 ký tự.",
  reset_token_invalid: "Mã đặt lại sai, đã dùng rồi, hoặc đã quá 30 phút. Xin mã mới.",
  unauthenticated: "Phiên đăng nhập đã hết. Đăng nhập lại.",
  cross_origin_write: "Yêu cầu không đến từ trang của quán nên bị chặn.",
  invalid_request: "Thông tin chưa hợp lệ — kiểm tra lại các ô.",
};

/** Lời bày cho người dùng. `no_response` của lệnh ghi là *chưa rõ kết quả*, không phải thất bại (ADR-102 điểm 2). */
export function loiTaiKhoan(failure: ApiFailure, rieng: Partial<Record<ErrorCode, string>> = {}): string {
  if (failure.kind === "no_response") {
    return "Không nối được máy chủ — chưa rõ yêu cầu đã tới chưa. Kiểm tra lại trước khi bấm lần nữa.";
  }
  if (failure.kind === "rejected") {
    return rieng[failure.code] ?? CHU[failure.code] ?? `Máy chủ từ chối (${failure.code}).`;
  }
  return "Máy chủ trả lời lạ — báo cho chủ quán.";
}
