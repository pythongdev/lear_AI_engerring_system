import type { Metadata } from "next";

import { FormQuenMatKhau } from "@/components/tai-khoan/form-quen-mat-khau";

export const metadata: Metadata = { title: "Quên mật khẩu" };

export default function Page() {
  return <FormQuenMatKhau />;
}
