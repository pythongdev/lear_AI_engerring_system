"use client";

import { useId, useRef, useState } from "react";
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
    <Button ref={nutMo} type="button" className="fixed right-4 bottom-4 z-40" aria-expanded={mo}
      aria-controls={mo ? `${id}-bang` : undefined} onClick={() => { setDaMo(true); setMo(true); }}>Hỏi quán</Button>
    {daMo && <section id={`${id}-bang`} role="dialog" aria-modal={false} aria-labelledby={`${id}-tieu-de`} hidden={!mo}
      className="fixed right-4 bottom-16 z-40 max-h-[calc(100dvh-5rem)] w-80 max-w-[calc(100vw-2rem)] space-y-4 overflow-y-auto rounded-xl border bg-background p-4 text-foreground shadow-lg"
      onKeyDown={(e) => { if (e.key === "Escape") { e.preventDefault(); e.stopPropagation(); dong(); } }}>
      <div className="flex items-center justify-between gap-3">
        <h2 id={`${id}-tieu-de`} className="font-semibold">Hỏi quán</h2>
        <Button type="button" variant="ghost" onClick={dong} aria-label="Đóng hỏi quán">Đóng</Button>
      </div>
      <HoiQuan mo={mo} />
    </section>}
  </>;
}
