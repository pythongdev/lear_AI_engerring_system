"use client";

import { useId, useRef, useState } from "react";

import { Button } from "@/components/ui/button";
import type { Khung } from "@/lib/auth/khung";
import { HopTin } from "./hop-tin";
import { usePhien } from "@/lib/auth/session";

export function OChat({ khung }: { khung: Khung }) {
  if (process.env.NEXT_PUBLIC_CHAT_ENABLED !== "true") return null;
  return <OChatTheoPhien khung={khung} />;
}

function OChatTheoPhien({ khung }: { khung: Khung }) {
  const phien = usePhien();
  if (phien.isPending || phien.isError || !phien.data?.ok) return null;

  // Đổi người thì tháo toàn bộ state, kể cả nháp và trạng thái mở bảng.
  return <VoOChat key={phien.data.data.person_id} khung={khung} personId={phien.data.data.person_id} />;
}

function VoOChat({ khung, personId }: { khung: Khung; personId: number }) {
  const [mo, setMo] = useState(false);
  const [daMo, setDaMo] = useState(false);
  const nutMo = useRef<HTMLButtonElement>(null);
  const id = useId();

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
        onClick={() => { setDaMo(true); setMo(true); }}
      >
        Mở trò chuyện
      </Button>
      {daMo && (
        <section
          id={`${id}-bang`}
          role="dialog"
          aria-modal={false}
          aria-labelledby={`${id}-tieu-de`}
          hidden={!mo}
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
          <HopTin khung={khung} personId={personId} mo={mo} />
        </section>
      )}
    </>
  );
}
