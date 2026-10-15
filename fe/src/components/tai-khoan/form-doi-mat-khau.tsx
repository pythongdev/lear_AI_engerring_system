"use client";
// Đổi mật khẩu (P4-04): bắt buộc khi đang dùng mật khẩu tạm chủ quán đặt (`must_change_password`, ADR-109
// điểm 9). Backend kết thúc mọi phiên sau khi đổi ⇒ màn đưa về đăng nhập.
import { useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { loiTaiKhoan } from "@/lib/auth/messages";
import { usePhien } from "@/lib/auth/session";

import { Bao, NutGui, TheTaiKhoan, Truong } from "./khung-form";

export function FormDoiMatKhau() {
  const api = useApi();
  const qc = useQueryClient();
  const router = useRouter();
  const phien = usePhien();
  const [cu, setCu] = useState("");
  const [moi, setMoi] = useState("");
  const [loi, setLoi] = useState<string | null>(null);
  const [dangGui, setDangGui] = useState(false);
  const batBuoc = phien.data?.ok === true && phien.data.data.must_change_password;

  async function gui(e: FormEvent) {
    e.preventDefault();
    if (moi.length < 8) {
      setLoi("Mật khẩu cần ít nhất 8 ký tự.");
      return;
    }
    setDangGui(true);
    const r = await call(api.POST("/accounts/current/password", { body: { current_password: cu, new_password: moi } }));
    setDangGui(false);
    if (!r.ok) {
      setLoi(loiTaiKhoan(r.failure, { invalid_credentials: "Mật khẩu hiện tại không đúng." }));
      return;
    }
    qc.clear();
    router.replace("/dang-nhap");
  }

  return (
    <TheTaiKhoan tieuDe="Đổi mật khẩu">
      {batBuoc ? <Bao loai="tin">Bạn đang dùng mật khẩu tạm của chủ quán — đặt mật khẩu riêng trước khi làm việc.</Bao> : null}
      <form onSubmit={gui} className="flex flex-col gap-3">
        <Truong id="current_password" nhan="Mật khẩu hiện tại" type="password" autoComplete="current-password" required value={cu} onChange={(e) => setCu(e.target.value)} />
        <Truong id="new_password" nhan="Mật khẩu mới (ít nhất 8 ký tự)" type="password" autoComplete="new-password" required value={moi} onChange={(e) => setMoi(e.target.value)} />
        {loi ? <Bao loai="loi">{loi}</Bao> : null}
        <NutGui dangGui={dangGui}>Đổi mật khẩu</NutGui>
      </form>
    </TheTaiKhoan>
  );
}
