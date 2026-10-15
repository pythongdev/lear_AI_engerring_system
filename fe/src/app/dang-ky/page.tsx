import type { Metadata } from "next";

import { FormDangKy } from "@/components/tai-khoan/form-dang-ky";

export const metadata: Metadata = { title: "Đăng ký" };

export default function Page() {
  return <FormDangKy />;
}
