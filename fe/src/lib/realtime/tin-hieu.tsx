"use client";
// Lớp realtime chung (P4-06, ADR-097, ADR-102 điểm 1 · 2): luồng SSE chỉ là tín hiệu ĐỌC LẠI — hello · changed làm mất
// hiệu lực mọi query, heartbeat chỉ giữ mốc còn sống; không ghi dữ liệu kèm tín hiệu vào cache. Đứt, lỗi, hay im quá
// hetHoiSauMs (mặc định 2,5 nhịp heartbeat) ⇒ banner và tự nối lại (1–10 giây). Rời màn ⇒ huỷ lời gọi để backend thấy
// luồng quầy đóng. Đường đọc sống còn kéo theo poll_interval_seconds (tuyChonKeo), kể cả khi luồng sống.

import { useQueryClient } from "@tanstack/react-query";
import { createContext, useContext, useEffect, useState, type ReactNode } from "react";

import { Alert, AlertDescription } from "@/components/ui/alert";
import { useApi } from "@/lib/api/provider";

type TrangThai = "dang-noi" | "song" | "dut";
const TinHieu = createContext<TrangThai>("dang-noi");
const choNoiLai = (lan: number) => Math.min(1000 * 2 ** (lan - 1), 10_000);

type DuLieuKeo = { poll_interval_seconds: number };
export function chuKyKeoMs(data: DuLieuKeo | undefined) {
  return (data?.poll_interval_seconds ?? 20) * 1000;
}

export function tuyChonKeo() {
  return {
    refetchInterval: (query: { state: { data: DuLieuKeo | undefined } }) => chuKyKeoMs(query.state.data),
    refetchIntervalInBackground: true,
  };
}

export function TinHieuProvider({ children, duong, noiLaiSauMs = choNoiLai, hetHoiSauMs = 25_000 }: {
  children: ReactNode;
  duong: "/counter/events" | "/production-board/events";
  noiLaiSauMs?: (lan: number) => number;
  hetHoiSauMs?: number;
}) {
  const api = useApi();
  const qc = useQueryClient();
  const [trangThai, setTrangThai] = useState<TrangThai>("dang-noi");

  useEffect(() => {
    let daRoi = false;
    let lan = 0;
    let henNoi: ReturnType<typeof setTimeout> | undefined;
    let huyLuot = () => {};

    function noi() {
      if (daRoi) return;
      const controller = new AbortController();
      let reader: ReadableStreamDefaultReader<Uint8Array> | undefined;
      let daDung = false;
      let hetHoi: ReturnType<typeof setTimeout> | undefined;
      const dung = () => {
        daDung = true;
        clearTimeout(hetHoi);
        controller.abort();
        void reader?.cancel().catch(() => {});
      };
      huyLuot = dung;
      const dut = () => {
        if (daDung || daRoi) return;
        dung();
        setTrangThai("dut");
        henNoi = setTimeout(noi, noiLaiSauMs(++lan));
      };
      const conSong = () => {
        clearTimeout(hetHoi);
        hetHoi = setTimeout(dut, hetHoiSauMs);
      };
      conSong(); // Kể cả request chưa trả header cũng phải có hạn chờ.

      void (async () => {
        try {
          const r = await api.GET(duong, {
            parseAs: "stream", signal: controller.signal,
            headers: { Accept: "text/event-stream" },
          });
          if (daDung || daRoi) {
            void r.data?.cancel().catch(() => {});
            return;
          }
          if (r.response.status !== 200 || !r.data) { dut(); return; }
          reader = r.data.getReader();
          const decoder = new TextDecoder();
          let dong = "";
          let suKien = "";
          let sauCR = false;
          const docDong = () => {
            if (dong === "") {
              if (["hello", "changed", "heartbeat"].includes(suKien)) conSong();
              if (suKien === "hello") { lan = 0; setTrangThai("song"); }
              if (suKien === "hello" || suKien === "changed") void qc.invalidateQueries();
              suKien = "";
            } else if (dong.startsWith("event:")) {
              suKien = dong.slice(6).replace(/^ /, "");
            }
            dong = "";
          };
          while (!daDung && !daRoi) {
            const { value, done } = await reader.read();
            if (daDung || daRoi) break;
            if (done) { dut(); break; }
            // Giữ dòng và UTF-8 dở giữa các mẩu; nhận LF, CRLF và CR của SSE.
            for (const kyTu of decoder.decode(value, { stream: true })) {
              if (sauCR && kyTu === "\n") { sauCR = false; continue; }
              sauCR = kyTu === "\r";
              if (kyTu === "\r" || kyTu === "\n") docDong();
              else dong += kyTu;
            }
          }
        } catch { dut(); }
        finally { reader?.releaseLock(); }
      })();
    }
    noi();
    return () => {
      daRoi = true;
      clearTimeout(henNoi);
      huyLuot();
    };
  }, [api, qc, duong, noiLaiSauMs, hetHoiSauMs]);

  return <TinHieu.Provider value={trangThai}>{children}</TinHieu.Provider>;
}

export function BaoMatKetNoi() {
  const trangThai = useContext(TinHieu);
  if (trangThai !== "dut") return null;
  return (
    <Alert variant="destructive" className="sticky top-0 z-50">
      <AlertDescription>Mất kết nối trực tiếp. Đang tự nối lại.</AlertDescription>
    </Alert>
  );
}
