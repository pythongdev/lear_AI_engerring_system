"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { Heart, ReceiptText, UserRound, UtensilsCrossed } from "lucide-react";

export const MUC_TAB_KHACH = [
  { nhan: "Đặt món", href: "/dat-mon", bieuTuong: UtensilsCrossed, tienTo: ["/dat-mon"] },
  { nhan: "Đơn đã đặt", href: "/khach/don", bieuTuong: ReceiptText, tienTo: ["/khach/don"] },
  {
    nhan: "Tài khoản", href: "/khach/tai-khoan", bieuTuong: UserRound,
    tienTo: ["/khach/tai-khoan", "/khach/dang-nhap", "/khach/dang-ky", "/khach/quen-mat-khau", "/khach/dat-lai-mat-khau", "/khach/xac-nhan-gmail"],
  },
  { nhan: "Yêu thích", href: "/khach/yeu-thich", bieuTuong: Heart, tienTo: ["/khach/yeu-thich"] },
] as const;

export function coThanhTabKhach(path: string | null): boolean {
  return path === "/dat-mon" || path?.startsWith("/khach/") === true;
}

export function ThanhTabKhach() {
  const path = usePathname();
  return <nav aria-label="Điều hướng khách" data-component="ThanhTabKhach"
    className="fixed inset-x-0 bottom-0 z-40 border-t bg-background pb-[env(safe-area-inset-bottom)]">
    <div className="mx-auto grid max-w-lg grid-cols-4">
      {MUC_TAB_KHACH.map(({ nhan, href, bieuTuong: BieuTuong, tienTo }) => {
        const dangMo = tienTo.some((p) => path === p || path?.startsWith(`${p}/`));
        return <Link key={href} href={href} aria-current={dangMo ? "page" : undefined}
          className={`flex min-h-14 flex-col items-center justify-center gap-1 text-[11px] ${dangMo ? "text-[#EA6A0C] dark:text-[#FF7A1A]" : "text-muted-foreground"}`}>
          <BieuTuong className="size-5" aria-hidden="true" />
          <span>{nhan}</span>
        </Link>;
      })}
    </div>
  </nav>;
}
