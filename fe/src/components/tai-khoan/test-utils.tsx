// Dựng màn tài khoản với backend giả cho test (không phải file test — không chạy riêng).
import { render } from "@testing-library/react";
import type { ReactElement } from "react";

import { ApiProvider } from "@/lib/api/provider";

export type GoiDen = { method: string; path: string; body: unknown };

export function voiBackend(ui: ReactElement, traLoi: (g: GoiDen) => { status: number; body?: unknown }) {
  const goi: GoiDen[] = [];
  const fetch = async (req: Request) => {
    const text = await req.text();
    const g = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    const r = traLoi(g);
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), {
      status: r.status,
      headers: { "content-type": "application/json" },
    });
  };
  render(<ApiProvider fetch={fetch}>{ui}</ApiProvider>);
  return goi;
}
