"use client";

import { useEffect, useSyncExternalStore } from "react";
import { Moon, Sun } from "lucide-react";
import { Button } from "@/components/ui/button";
import { doiGiaoDien, khoiTaoGiaoDien } from "@/lib/giao-dien";

function theoDoi(thayDoi: () => void) {
  window.addEventListener("giao-dien", thayDoi);
  return () => window.removeEventListener("giao-dien", thayDoi);
}
const docGiaoDien = () => document.documentElement.classList.contains("dark");
const giaoDienServer = () => false;

// `noi`: nút nổi góc dưới của root layout, tự ẩn khi trang có nút ở thanh đầu (T-230).
export function ChuyenGiaoDien({ noi = false }: { noi?: boolean }) {
  const toi = useSyncExternalStore(theoDoi, docGiaoDien, giaoDienServer);
  useEffect(() => {
    khoiTaoGiaoDien();
    window.dispatchEvent(new Event("giao-dien"));
  }, []);

  return (
    <Button
      type="button"
      variant="outline"
      size={noi ? "icon" : "icon-sm"}
      data-giao-dien={noi ? "noi" : "dau"}
      className={noi ? "fixed bottom-4 left-4 z-40 shadow-sm [body:has([data-giao-dien=dau])_&]:hidden" : undefined}
      aria-label={toi ? "Chuyển sang giao diện sáng" : "Chuyển sang giao diện tối"}
      onClick={doiGiaoDien}
    >
      {toi ? <Sun className="size-4" aria-hidden="true" /> : <Moon className="size-4" aria-hidden="true" />}
    </Button>
  );
}
