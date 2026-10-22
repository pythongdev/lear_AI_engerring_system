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

export function ChuyenGiaoDien() {
  const toi = useSyncExternalStore(theoDoi, docGiaoDien, giaoDienServer);
  useEffect(() => {
    khoiTaoGiaoDien();
    window.dispatchEvent(new Event("giao-dien"));
  }, []);

  return (
    <Button
      type="button"
      variant="outline"
      size="icon"
      className="fixed bottom-4 left-4 z-40 shadow-sm"
      aria-label={toi ? "Chuyển sang giao diện sáng" : "Chuyển sang giao diện tối"}
      onClick={doiGiaoDien}
    >
      {toi ? <Sun className="size-4" aria-hidden="true" /> : <Moon className="size-4" aria-hidden="true" />}
    </Button>
  );
}
