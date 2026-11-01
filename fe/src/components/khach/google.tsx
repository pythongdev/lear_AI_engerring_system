"use client";

import Script from "next/script";
import { useCallback, useEffect, useRef, useState } from "react";
import { call } from "@/lib/api/client";
import { useApi } from "@/lib/api/provider";
import { loiTaiKhoan } from "@/lib/auth/messages";
import { Bao } from "@/components/tai-khoan/khung-form";

type Credential = { credential: string };
declare global {
  interface Window {
    google?: { accounts: { id: {
      initialize(options: { client_id: string; callback: (response: Credential) => void }): void;
      renderButton(element: HTMLElement, options: { text: "continue_with"; locale: "vi"; theme: "outline"; size: "large" }): void;
    } } };
  }
}
const EMAIL_TAKEN = "Gmail này đã có tài khoản đặt bằng mật khẩu. Hãy đăng nhập bằng mật khẩu.";
export function GoogleKhach({ success }: { success: () => Promise<void> }) {
  const clientID = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID;
  const api = useApi();
  const element = useRef<HTMLDivElement>(null);
  const busy = useRef(false);
  const active = useRef(false);
  const [pending, setPending] = useState(false);
  const [error, setError] = useState("");
  const latest = useRef({ api, success });
  useEffect(() => { latest.current = { api, success }; }, [api, success]);
  const initialize = useCallback(() => {
    if (!clientID || !element.current || !window.google) return;
    window.google.accounts.id.initialize({ client_id: clientID, callback: async ({ credential }) => {
      if (!active.current || busy.current) return;
      busy.current = true; setPending(true); setError("");
      try {
        const result = await call(latest.current.api.POST("/customer-sessions/google", { body: { credential } }));
        if (!active.current) return;
        if (result.ok) await latest.current.success();
        else setError(loiTaiKhoan(result.failure, { email_taken: EMAIL_TAKEN }));
      } finally {
        busy.current = false;
        if (active.current) setPending(false);
      }
    } });
    element.current.replaceChildren();
    window.google.accounts.id.renderButton(element.current, { text: "continue_with", locale: "vi", theme: "outline", size: "large" });
  }, [clientID]);
  useEffect(() => { active.current = true; initialize(); return () => { active.current = false; }; }, [initialize]);
  if (!clientID) return null;
  return <div className="space-y-3">
    <Script id="google-identity-services" src="https://accounts.google.com/gsi/client" onReady={initialize}
      onError={() => setError("Chưa tải được nút Google. Vui lòng thử lại sau.")} />
    <div ref={element} aria-label="Tiếp tục với Google" aria-busy={pending} className={pending ? "pointer-events-none opacity-60" : ""} />
    {pending && <p role="status">Đang đăng nhập…</p>}
    {error && <Bao loai="loi">{error}</Bao>}
    <p className="text-center text-sm text-muted-foreground">hoặc</p>
  </div>;
}
