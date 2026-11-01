"use client";

import { useEffect, useRef, useState } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { useQueryClient } from "@tanstack/react-query";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { loiTaiKhoan } from "@/lib/auth/messages";
import { KHOA_KHACH } from "@/lib/khach/session";
import { KhungKhach } from "./khung";

export const LINK_KHONG_HOP_LE = "Link xác nhận không còn dùng được. Đăng nhập rồi bấm Gửi lại thư xác nhận.";
export function XacNhanGmail() {
  const token = useSearchParams().get("ma");
  const api = useApi(); const qc = useQueryClient();
  const started = useRef(false);
  const [message, setMessage] = useState<string | null>(null);
  useEffect(() => {
    if (!token || started.current) return;
    started.current = true;
    void (async () => {
      const r = await call(api.POST("/customer-email-verifications", { body: { token } }));
      if (r.ok) {
        setMessage("Đã xác nhận Gmail.");
        await qc.invalidateQueries({ queryKey: KHOA_KHACH });
      } else if (r.failure.kind === "rejected" && r.failure.code === "verification_invalid") {
        setMessage(LINK_KHONG_HOP_LE);
      } else if (r.failure.kind === "rejected" && r.failure.code === "email_taken") {
        setMessage("Gmail này đã thuộc một tài khoản khác.");
      } else setMessage(loiTaiKhoan(r.failure));
    })();
  }, [api, qc, token]);
  return <KhungKhach title="Xác nhận Gmail">
    <p role="status">{!token ? LINK_KHONG_HOP_LE : message ?? "Đang xác nhận Gmail…"}</p>
    <Link href="/khach/tai-khoan">Về tài khoản</Link>
  </KhungKhach>;
}
