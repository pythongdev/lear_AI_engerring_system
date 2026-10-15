// @vitest-environment node
// Test đỏ của tầng chuyển tiếp khi danh tính đổi từ header chọn tên sang cookie phiên (P4-04; ADR-109
// điểm 6, ADR-102 điểm 6). Viết TRƯỚC code — Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm.
import { afterEach, describe, expect, it, vi } from "vitest";

import { GET, POST } from "./route";

type Seen = { url: string; headers: Headers };

function stubBackend(response: () => Response): Seen[] {
  const seen: Seen[] = [];
  vi.stubGlobal("fetch", async (url: string, init: RequestInit) => {
    seen.push({ url, headers: new Headers(init.headers) });
    return response();
  });
  return seen;
}

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("tầng chuyển tiếp mang phiên đăng nhập đi và về", () => {
  it("chuyển cookie và Origin của trình duyệt lên backend", async () => {
    const seen = stubBackend(() => new Response("{}", { status: 200 }));

    await POST(
      new Request("http://fe.test/api/sessions/current/end", {
        method: "POST",
        headers: { cookie: "banhcuon_phien=abc123", origin: "http://fe.test" },
      }),
    );

    expect(seen).toHaveLength(1);
    expect(seen[0].headers.get("cookie")).toBe("banhcuon_phien=abc123");
    expect(seen[0].headers.get("origin")).toBe("http://fe.test");
  });

  it("trả mọi Set-Cookie của backend về trình duyệt, không gộp", async () => {
    stubBackend(() => {
      const headers = new Headers({ "content-type": "application/json" });
      headers.append("set-cookie", "banhcuon_phien=moi; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=604800");
      headers.append("set-cookie", "khac=1; Path=/");
      return new Response("{}", { status: 201, headers });
    });

    const res = await POST(
      new Request("http://fe.test/api/sessions", { method: "POST", body: "{}", headers: { "content-type": "application/json" } }),
    );

    expect(res.status).toBe(201);
    expect(res.headers.getSetCookie()).toEqual([
      "banhcuon_phien=moi; Path=/; HttpOnly; Secure; SameSite=Strict; Max-Age=604800",
      "khac=1; Path=/",
    ]);
  });

  it("không còn chuyển X-Person-Id — header chọn tên đã bị gỡ", async () => {
    const seen = stubBackend(() => new Response("{}", { status: 200 }));

    await GET(new Request("http://fe.test/api/sessions/current", { headers: { "x-person-id": "1" } }));

    expect(seen[0].headers.get("x-person-id")).toBeNull();
  });
});
