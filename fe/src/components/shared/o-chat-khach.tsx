"use client";

import { useId, useRef, useState } from "react";
import { MessageCircle, X } from "lucide-react";
import { usePathname } from "next/navigation";
import { Button } from "@/components/ui/button";
import { usePhienKhach } from "@/lib/khach/session";
import { HoiQuan } from "./hoi-quan";

export function OChatKhach() {
  const path = usePathname();
  if (process.env.NEXT_PUBLIC_CHAT_ENABLED !== "true" || ["/quay", "/tram", "/chu-quan"].some((p) => path?.startsWith(p))) return null;
  return <OChatTheoKhach />;
}
function OChatTheoKhach() {
  const phien = usePhienKhach();
  return <VoOChatKhach key={phien.data?.customer_account_id ?? "khach-vang"} />;
}
function VoOChatKhach() {
  const [mo, setMo] = useState(false);
  const [daMo, setDaMo] = useState(false);
  const nutMo = useRef<HTMLButtonElement>(null);
  const id = useId();
  function dong() { setMo(false); nutMo.current?.focus(); }
  return <>
    <button ref={nutMo} type="button"
      className="fixed right-4 bottom-[calc(1rem+env(safe-area-inset-bottom))] z-50 flex size-14 items-center justify-center rounded-full bg-[#EA6A0C] text-white shadow-lg hover:bg-[#C95A0A] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#EA6A0C]"
      aria-label="Trợ lý bánh cuốn" title="Trợ lý bánh cuốn" aria-expanded={mo}
      aria-controls={mo ? `${id}-bang` : undefined} onClick={() => { if (mo) dong(); else { setDaMo(true); setMo(true); } }}>
      {mo ? <X className="size-7" aria-hidden="true" /> : <MessageCircle className="size-7" aria-hidden="true" />}
    </button>
    {daMo && <section id={`${id}-bang`} role="dialog" aria-modal={false} aria-labelledby={`${id}-tieu-de`} hidden={!mo}
      className="fixed right-4 bottom-[calc(5.5rem+env(safe-area-inset-bottom))] z-50 max-h-[calc(100dvh-7rem)] w-80 max-w-[calc(100vw-2rem)] space-y-4 overflow-y-auto rounded-xl border bg-background p-4 text-foreground shadow-lg"
      onKeyDown={(e) => { if (e.key === "Escape") { e.preventDefault(); e.stopPropagation(); dong(); } }}>
      <div className="flex items-center justify-between gap-3">
        <h2 id={`${id}-tieu-de`} className="font-semibold">Trợ lý bánh cuốn</h2>
        <Button type="button" variant="ghost" onClick={dong} aria-label="Đóng trợ lý bánh cuốn">Đóng</Button>
      </div>
      <HoiQuan mo={mo} />
    </section>}
  </>;
}
