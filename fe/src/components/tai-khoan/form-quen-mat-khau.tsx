"use client";
// Quên và đặt lại mật khẩu (P4-04, ADR-109 điểm 8): màn luôn nói cùng một câu dù Gmail có tài khoản hay không —
// không để lộ ai làm ở quán. Mã trong thư sống 30 phút, dùng một lần. Thư không đi được (PT-7) ⇒ nhờ chủ quán
// khoá rồi mở lại kèm mật khẩu tạm.
import Link from "next/link";
import { useState, type FormEvent } from "react";

import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { loiTaiKhoan } from "@/lib/auth/messages";

import { Bao, NutGui, TheTaiKhoan, Truong } from "./khung-form";

export const CAU_DA_GUI =
  "Nếu Gmail này gắn với một tài khoản đang hoạt động, mã đặt lại đã được gửi tới đó (hạn 30 phút). " +
  "Không nhận được thư thì nhờ chủ quán đặt mật khẩu tạm.";

export function FormQuenMatKhau() {
  const api = useApi();
  const [email, setEmail] = useState("");
  const [ketQua, setKetQua] = useState<{ loai: "loi" | "tin"; chu: string } | null>(null);
  const [dangGui, setDangGui] = useState(false);

  async function guiMa(e: FormEvent) {
    e.preventDefault();
    setDangGui(true);
    const r = await call(api.POST("/password-reset-requests", { body: { email: email.trim().toLowerCase() } }));
    setDangGui(false);
    setKetQua(r.ok ? { loai: "tin", chu: CAU_DA_GUI } : { loai: "loi", chu: loiTaiKhoan(r.failure) });
  }

  return (
    <TheTaiKhoan tieuDe="Quên mật khẩu">
      <form onSubmit={guiMa} className="flex flex-col gap-3">
        <Truong id="email" nhan="Gmail của tài khoản" type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
        {ketQua ? <Bao loai={ketQua.loai}>{ketQua.chu}</Bao> : null}
        <NutGui dangGui={dangGui}>Gửi mã đặt lại</NutGui>
      </form>
      <FormDatLai />
      <Button variant="link" className="self-start px-0" asChild>
        <Link href="/dang-nhap">Quay lại đăng nhập</Link>
      </Button>
    </TheTaiKhoan>
  );
}

function FormDatLai() {
  const api = useApi();
  const [ma, setMa] = useState("");
  const [moi, setMoi] = useState("");
  const [ketQua, setKetQua] = useState<{ loai: "loi" | "tin"; chu: string } | null>(null);
  const [dangGui, setDangGui] = useState(false);

  async function datLai(e: FormEvent) {
    e.preventDefault();
    if (moi.length < 8) {
      setKetQua({ loai: "loi", chu: "Mật khẩu cần ít nhất 8 ký tự." });
      return;
    }
    setDangGui(true);
    const r = await call(api.POST("/password-resets", { body: { token: ma.trim(), new_password: moi } }));
    setDangGui(false);
    setKetQua(
      r.ok
        ? { loai: "tin", chu: "Đã đặt mật khẩu mới. Mọi phiên cũ đã kết thúc — đăng nhập lại." }
        : { loai: "loi", chu: loiTaiKhoan(r.failure) },
    );
  }

  return (
    <form onSubmit={datLai} className="flex flex-col gap-3">
      <Separator />
      <h2 className="font-medium">Đã có mã trong thư</h2>
      <Truong id="token" nhan="Mã đặt lại" autoComplete="one-time-code" required value={ma} onChange={(e) => setMa(e.target.value)} />
      <Truong id="new_password" nhan="Mật khẩu mới (ít nhất 8 ký tự)" type="password" autoComplete="new-password" required value={moi} onChange={(e) => setMoi(e.target.value)} />
      {ketQua ? <Bao loai={ketQua.loai}>{ketQua.chu}</Bao> : null}
      <NutGui dangGui={dangGui}>Đặt mật khẩu mới</NutGui>
    </form>
  );
}
