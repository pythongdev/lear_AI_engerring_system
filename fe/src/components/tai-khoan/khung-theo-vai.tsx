"use client";
// Khung theo vai (P4-04): gác lối vào khung quầy · chủ quán · trạm theo phiên đăng nhập. Đây là TIỆN, không phải
// bảo vệ — mọi cửa vẫn do backend chặn theo lớp quyền (02-vai-va-quyen.md); khung chỉ chọn màn mặc định.
import { useRouter } from "next/navigation";
import { useEffect, type ReactNode } from "react";

import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { khungCua, type Khung } from "@/lib/auth/khung";
import { loiTaiKhoan } from "@/lib/auth/messages";
import { useDangXuat, usePhien } from "@/lib/auth/session";

const TEN_KHUNG: Record<Khung, string> = { "/chu-quan": "Chủ quán", "/quay": "Quầy", "/tram": "Trạm (chỉ xem)" };

export function KhungTheoVai({ khung, children }: { khung: Khung; children: ReactNode }) {
  const router = useRouter();
  const phien = usePhien();
  const dangXuat = useDangXuat();
  const r = phien.data;
  const s = r?.ok ? r.data : null;
  const diDau = r === null ? "/dang-nhap" : s?.must_change_password ? "/doi-mat-khau" : s && khungCua(s) !== khung ? khungCua(s) : null;

  useEffect(() => {
    if (diDau) router.replace(diDau);
  }, [diDau, router]);

  if (phien.isPending || diDau) return <p className="p-6">Đang mở…</p>;
  if (r && !r.ok)
    return (
      <Alert variant="destructive" className="m-6 w-auto">
        <AlertDescription>{loiTaiKhoan(r.failure)}</AlertDescription>
      </Alert>
    );
  if (!s) return null;

  return (
    <div className="min-h-dvh">
      <header className="flex items-center justify-between gap-4 border-b p-3">
        <span className="font-medium">{TEN_KHUNG[khung]}</span>
        <span className="text-sm">
          {s.display_name}
          {s.counter_duty_id ? " · đang đứng quầy" : ""}
        </span>
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={dangXuat.isPending}
          onClick={async () => {
            await dangXuat.mutateAsync();
            router.replace("/dang-nhap");
          }}
        >
          Đăng xuất
        </Button>
      </header>
      <main className="p-6">{children}</main>
    </div>
  );
}
