import type { Metadata } from "next";

import { FormDoiMatKhau } from "@/components/tai-khoan/form-doi-mat-khau";

export const metadata: Metadata = { title: "Đổi mật khẩu" };

export default function Page() {
  return <FormDoiMatKhau />;
}
