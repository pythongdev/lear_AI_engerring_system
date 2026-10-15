import type { Metadata } from "next";

import { FormDangNhap } from "@/components/tai-khoan/form-dang-nhap";

export const metadata: Metadata = { title: "Đăng nhập" };

export default function Page() {
  return <FormDangNhap />;
}
