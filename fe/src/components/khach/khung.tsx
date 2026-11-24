"use client";

import type { ReactNode } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Bao } from "@/components/tai-khoan/khung-form";
import { loiTaiKhoan } from "@/lib/auth/messages";
import type { ApiFailure } from "@/lib/api/client";
import { ThanhTabKhach } from "./thanh-tab-khach";

export function KhungKhach({ title, children, vien = true }: { title: string; children: ReactNode; vien?: boolean }) {
  return <><main className="mx-auto min-h-dvh max-w-lg space-y-6 px-4 pt-8 pb-[calc(9rem+env(safe-area-inset-bottom))]">
    {vien ? <Card><CardHeader><CardTitle><h1 className="text-2xl">{title}</h1></CardTitle></CardHeader>
      <CardContent className="space-y-6">{children}</CardContent></Card>
      : <div className="min-w-0 space-y-6"><h1 className="text-2xl font-medium">{title}</h1>{children}</div>}
  </main><ThanhTabKhach /></>;
}
export function LoiDocKhach({ error, docLai, readAt }: { error: ApiFailure; docLai: () => void; readAt?: number }) {
  return <Bao loai="loi">{loiTaiKhoan(error)} {readAt ? `Đang hiện bản đọc lúc ${new Date(readAt).toLocaleString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh" })}.` : ""}
    <Button variant="outline" onClick={docLai}>Đọc lại</Button>
  </Bao>;
}
