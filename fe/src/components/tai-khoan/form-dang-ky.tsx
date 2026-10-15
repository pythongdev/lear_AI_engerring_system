"use client";
// Màn tự đăng ký (P4-04, ADR-109 điểm 2): tài khoản mới ở trạng thái chờ chủ quán duyệt, chưa đăng nhập được.
import { zodResolver } from "@hookform/resolvers/zod";
import Link from "next/link";
import { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { loiTaiKhoan } from "@/lib/auth/messages";

import { Bao, NutGui, TheTaiKhoan, Truong } from "./khung-form";

const schema = z.object({
  username: z
    .string()
    .trim()
    .toLowerCase()
    .regex(/^[a-z0-9._-]{3,32}$/, "3–32 ký tự: chữ không dấu, số, dấu chấm, gạch dưới, gạch ngang."),
  email: z.string().trim().toLowerCase().email("Gmail chưa đúng dạng."),
  display_name: z.string().trim().min(1, "Nhập tên để chủ quán nhận ra bạn."),
  password: z.string().min(8, "Mật khẩu cần ít nhất 8 ký tự."),
});

export function FormDangKy() {
  const api = useApi();
  const [ketQua, setKetQua] = useState<{ loai: "loi" | "tin"; chu: string } | null>(null);
  const [dangGui, setDangGui] = useState(false);
  const form = useForm<z.infer<typeof schema>>({
    resolver: zodResolver(schema),
    defaultValues: { username: "", email: "", display_name: "", password: "" },
  });
  const e = form.formState.errors;

  const gui = form.handleSubmit(async (vao) => {
    setDangGui(true);
    const r = await call(api.POST("/accounts", { body: vao }));
    setDangGui(false);
    setKetQua(
      r.ok
        ? { loai: "tin", chu: "Đã gửi đăng ký. Chờ chủ quán duyệt rồi đăng nhập bằng tên và mật khẩu vừa đặt." }
        : { loai: "loi", chu: loiTaiKhoan(r.failure) },
    );
    if (r.ok) form.reset();
  });

  return (
    <TheTaiKhoan tieuDe="Đăng ký tài khoản">
      <form onSubmit={gui} className="flex flex-col gap-3" noValidate>
        <Truong id="username" nhan="Tên đăng nhập" autoComplete="username" loi={e.username?.message} {...form.register("username")} />
        <Truong id="email" nhan="Gmail (để đặt lại mật khẩu)" type="email" autoComplete="email" loi={e.email?.message} {...form.register("email")} />
        <Truong id="display_name" nhan="Tên hiển thị" autoComplete="name" loi={e.display_name?.message} {...form.register("display_name")} />
        <Truong id="password" nhan="Mật khẩu (ít nhất 8 ký tự)" type="password" autoComplete="new-password" loi={e.password?.message} {...form.register("password")} />
        {ketQua ? <Bao loai={ketQua.loai}>{ketQua.chu}</Bao> : null}
        <NutGui dangGui={dangGui}>Đăng ký</NutGui>
      </form>
      <Button variant="link" className="self-start px-0" asChild>
        <Link href="/dang-nhap">Đã có tài khoản — đăng nhập</Link>
      </Button>
    </TheTaiKhoan>
  );
}
