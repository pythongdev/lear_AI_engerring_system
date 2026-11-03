"use client";

import { useEffect, useId, useRef, useState } from "react";

import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { usePhien } from "@/lib/auth/session";

export function OChat() {
  if (process.env.NEXT_PUBLIC_CHAT_ENABLED !== "true") return null;
  return <OChatTheoPhien />;
}

function OChatTheoPhien() {
  const phien = usePhien();
  if (phien.isPending || phien.isError || !phien.data?.ok) return null;

  // Đổi người thì tháo toàn bộ state, kể cả nháp và trạng thái mở bảng.
  return <VoOChat key={phien.data.data.person_id} />;
}

function VoOChat() {
  const [mo, setMo] = useState(false);
  const [nhap, setNhap] = useState("");
  const nutMo = useRef<HTMLButtonElement>(null);
  const oNhap = useRef<HTMLInputElement>(null);
  const id = useId();

  useEffect(() => {
    if (mo) oNhap.current?.focus();
  }, [mo]);

  function dong() {
    setMo(false);
    nutMo.current?.focus();
  }

  return (
    <>
      <Button
        ref={nutMo}
        type="button"
        className="fixed right-4 bottom-4 z-40"
        aria-expanded={mo}
        aria-controls={mo ? `${id}-bang` : undefined}
        onClick={() => setMo(true)}
      >
        Mở trò chuyện
      </Button>
      {mo && (
        <section
          id={`${id}-bang`}
          role="dialog"
          aria-modal={false}
          aria-labelledby={`${id}-tieu-de`}
          aria-describedby={`${id}-huong-dan`}
          className="fixed right-4 bottom-16 z-40 max-h-[calc(100dvh-5rem)] w-80 max-w-[calc(100vw-2rem)] space-y-4 overflow-y-auto rounded-xl border bg-background p-4 text-foreground shadow-lg"
          onKeyDown={(event) => {
            if (event.key === "Escape") {
              event.preventDefault();
              event.stopPropagation();
              dong();
            }
          }}
        >
          <div className="flex items-center justify-between gap-3">
            <h2 id={`${id}-tieu-de`} className="font-semibold">Trò chuyện</h2>
            <Button type="button" variant="ghost" onClick={dong} aria-label="Đóng trò chuyện">
              Đóng
            </Button>
          </div>
          <p id={`${id}-huong-dan`} className="text-sm text-muted-foreground">
            Chat chưa nối. Hãy dùng màn thao tác tay.
          </p>
          <div className="space-y-2">
            <label htmlFor={`${id}-nhap`} className="text-sm">Nháp trò chuyện</label>
            <Input
              ref={oNhap}
              id={`${id}-nhap`}
              autoComplete="off"
              value={nhap}
              onChange={(event) => setNhap(event.target.value)}
            />
          </div>
        </section>
      )}
    </>
  );
}
