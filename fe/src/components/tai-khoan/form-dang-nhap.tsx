"use client";
// Màn đăng nhập (P4-04, ADR-109 điểm 7): "Đăng nhập tại quầy" là mốc đổi người C36 — backend mở trực quầy cùng
// giao dịch với phiên. Thành công thì đi khung theo vai, hoặc màn đổi mật khẩu khi đang dùng mật khẩu tạm.
import { zodResolver } from "@hookform/resolvers/zod";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Controller, useForm } from "react-hook-form";
import { z } from "zod";

import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Field, FieldLabel } from "@/components/ui/field";
import { sauDangNhap } from "@/lib/auth/khung";
import { loiTaiKhoan } from "@/lib/auth/messages";
import { useDangNhap } from "@/lib/auth/session";

import { Bao, NutGui, TheTaiKhoan, Truong } from "./khung-form";

const schema = z.object({
  username: z.string().trim().min(1, "Nhập tên đăng nhập."),
  password: z.string().min(1, "Nhập mật khẩu."),
  at_counter: z.boolean(),
});

export function FormDangNhap() {
  const router = useRouter();
  const dangNhap = useDangNhap();
  const [loi, setLoi] = useState<string | null>(null);
  const form = useForm<z.infer<typeof schema>>({
    resolver: zodResolver(schema),
    defaultValues: { username: "", password: "", at_counter: false },
  });

  const gui = form.handleSubmit(async (vao) => {
    setLoi(null);
    const r = await dangNhap.mutateAsync(vao);
    if (!r.ok) {
      setLoi(loiTaiKhoan(r.failure));
      return;
    }
    router.replace(sauDangNhap(r.data));
  });

  return (
    <TheTaiKhoan tieuDe="Đăng nhập">
      <form onSubmit={gui} className="flex flex-col gap-3" noValidate>
        <Truong id="username" nhan="Tên đăng nhập" autoComplete="username" loi={form.formState.errors.username?.message} {...form.register("username")} />
        <Truong id="password" nhan="Mật khẩu" type="password" autoComplete="current-password" loi={form.formState.errors.password?.message} {...form.register("password")} />
        <Controller
          control={form.control}
          name="at_counter"
          render={({ field }) => (
            <Field orientation="horizontal">
              <Checkbox id="at_counter" name={field.name} checked={field.value} onCheckedChange={(v) => field.onChange(v === true)} onBlur={field.onBlur} ref={field.ref} />
              <FieldLabel htmlFor="at_counter" className="font-normal">
                Đăng nhập tại quầy (bắt đầu đứng quầy)
              </FieldLabel>
            </Field>
          )}
        />
        {loi ? <Bao loai="loi">{loi}</Bao> : null}
        <NutGui dangGui={dangNhap.isPending}>Đăng nhập</NutGui>
      </form>
      <nav className="flex justify-between">
        <Button variant="link" className="px-0" asChild>
          <Link href="/dang-ky">Đăng ký tài khoản</Link>
        </Button>
        <Button variant="link" className="px-0" asChild>
          <Link href="/quen-mat-khau">Quên mật khẩu</Link>
        </Button>
      </nav>
    </TheTaiKhoan>
  );
}
