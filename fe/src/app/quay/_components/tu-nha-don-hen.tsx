"use client";

import { useEffect, useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";

export function TuNhaDonHen({ chuKyMs = 20_000 }: { chuKyMs?: number }) {
  const api = useApi();
  const qc = useQueryClient();
  const [loi, setLoi] = useState(false);
  useEffect(() => {
    let daRoi = false;
    let dangGui = false;
    const controller = new AbortController();
    async function nha() {
      if (dangGui || daRoi) return;
      dangGui = true;
      try {
        const r = await call(api.POST("/preorder-releases", { body: {}, signal: controller.signal }));
        if (daRoi) return;
        if (!r.ok || !Array.isArray(r.data?.released_order_ids)) {
          setLoi(true);
          return;
        }
        setLoi(false);
        if (r.data.released_order_ids.length > 0) await qc.invalidateQueries();
      } finally { dangGui = false; }
    }
    void nha();
    const hen = setInterval(() => { void nha(); }, chuKyMs);
    return () => { daRoi = true; clearInterval(hen); controller.abort(); };
  }, [api, qc, chuKyMs]);
  return loi ? <Alert variant="destructive"><AlertDescription>Chưa nhả được đơn hẹn xuống bếp… Máy sẽ gọi lại theo chu kỳ.</AlertDescription></Alert> : null;
}
