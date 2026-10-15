import { describe, expect, it } from "vitest";

import { UPSTREAM_UNREACHABLE_HEADER, call, createApi } from "./client";

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}

const quote = { body: { lines: [{ menu_item_id: 1, quantity: 1, option_ids: [7, 7] }] } };

describe("lớp gọi API đọc lời từ chối theo hình Error của hợp đồng", () => {
  it("lời từ chối mẫu của POST /price-quotes ra đúng mã và trường", async () => {
    const api = createApi({
      baseUrl: "http://fe.test/api",
      fetch: async () => json(422, { code: "option_combination_invalid", field: "lines[0].option_ids" }),
    });

    const result = await call(api.POST("/price-quotes", quote));

    expect(result).toEqual({
      ok: false,
      failure: {
        kind: "rejected",
        status: 422,
        code: "option_combination_invalid",
        field: "lines[0].option_ids",
      },
    });
  });

  it("mã không có trong ErrorCode của hợp đồng là phản hồi lạ hình, không là lời từ chối", async () => {
    const api = createApi({
      baseUrl: "http://fe.test/api",
      fetch: async () => json(409, { code: "khong_co_trong_hop_dong" }),
    });

    const result = await call(api.GET("/menu"));

    expect(result).toEqual({ ok: false, failure: { kind: "unexpected", status: 409 } });
  });

  it("thân không phải JSON cũng là phản hồi lạ hình", async () => {
    const api = createApi({
      baseUrl: "http://fe.test/api",
      fetch: async () => new Response("bad gateway", { status: 500 }),
    });

    const result = await call(api.GET("/menu"));

    expect(result).toEqual({ ok: false, failure: { kind: "unexpected", status: 500 } });
  });

  it("mất kết nối là không có phản hồi", async () => {
    const api = createApi({
      baseUrl: "http://fe.test/api",
      fetch: async () => {
        throw new TypeError("fetch failed");
      },
    });

    const result = await call(api.POST("/price-quotes", quote));

    expect(result).toEqual({ ok: false, failure: { kind: "no_response" } });
  });

  it("tầng chuyển tiếp báo không nối được backend là không có phản hồi", async () => {
    const api = createApi({
      baseUrl: "http://fe.test/api",
      fetch: async () => new Response(null, { status: 502, headers: { [UPSTREAM_UNREACHABLE_HEADER]: "1" } }),
    });

    const result = await call(api.GET("/menu"));

    expect(result).toEqual({ ok: false, failure: { kind: "no_response" } });
  });
});

describe("lớp gọi API để cookie phiên làm danh tính (ADR-109 điểm 6)", () => {
  it("không gửi header danh tính nào, và để trình duyệt gửi cookie cùng origin", async () => {
    let seen: Request | undefined;
    const api = createApi({
      baseUrl: "http://fe.test/api",
      fetch: async (request) => {
        seen = request;
        return json(200, []);
      },
    });
    await call(api.GET("/people"));
    expect(seen?.headers.get("X-Person-Id")).toBeNull();
    expect(seen?.credentials).toBe("same-origin");
  });

  it("thành công trả nguyên thân backend", async () => {
    const api = createApi({ baseUrl: "http://fe.test/api", fetch: async () => json(200, []) });

    expect(await call(api.GET("/people"))).toEqual({ ok: true, data: [] });
  });
});
