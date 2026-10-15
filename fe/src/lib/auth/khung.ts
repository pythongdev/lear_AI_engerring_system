// Khung màn theo người đã đăng nhập (P4-04, ADR-109 điểm 3): vai chỉ chọn khung mặc định, KHÔNG mở quyền —
// quyền vẫn do backend đọc từ trực quầy và cờ chủ quán. Màn ẩn nút là tiện, không phải bảo vệ.
import type { components } from "@/lib/api/schema";

export type Session = components["schemas"]["Session"];
export type Khung = "/chu-quan" | "/quay" | "/tram";

export function khungCua(s: Pick<Session, "is_owner" | "role_code">): Khung {
  if (s.is_owner) return "/chu-quan";
  if (s.role_code === "quay") return "/quay";
  return "/tram";
}

/** Đi đâu ngay sau khi đăng nhập: mật khẩu tạm buộc đổi trước (ADR-109 điểm 9). */
export function sauDangNhap(s: Session): Khung | "/doi-mat-khau" {
  return s.must_change_password ? "/doi-mat-khau" : khungCua(s);
}
