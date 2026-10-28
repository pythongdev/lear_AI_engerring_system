"use client";

import Link from "next/link";
import type { ReactNode } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Bao } from "@/components/tai-khoan/khung-form";
import { loiTaiKhoan } from "@/lib/auth/messages";
import type { ApiFailure } from "@/lib/api/client";

export function KhungKhach({ title, children }: { title: string; children: ReactNode }) {
  return <main className="mx-auto min-h-dvh max-w-lg space-y-6 px-4 py-8">
    <nav aria-label="Điều hướng khách" className="flex flex-wrap gap-4 text-sm">
      <Link href="/dat-mon">Đặt món</Link><Link href="/khach/don">Đơn đã đặt</Link><Link href="/khach/tai-khoan">Tài khoản</Link>
    </nav>
    <Card><CardHeader><CardTitle><h1 className="text-2xl">{title}</h1></CardTitle></CardHeader>
      <CardContent className="space-y-6">{children}</CardContent></Card>
  </main>;
}
export function LoiDocKhach({ error, docLai, readAt }: { error: ApiFailure; docLai: () => void; readAt?: number }) {
  return <Bao loai="loi">{loiTaiKhoan(error)} {readAt ? `Đang hiện bản đọc lúc ${new Date(readAt).toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" })}.` : ""}
    <Button variant="outline" onClick={docLai}>Đọc lại</Button>
  </Bao>;
}
