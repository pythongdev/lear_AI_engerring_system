// Tầng chuyển tiếp cùng origin (ADR-102 điểm 6): trình duyệt gọi /api/<đường gọi của hợp đồng>,
// server Next gọi backend ở backendUrl() và trả nguyên status, thân và các header cần.
// - Không cache: chạy cho từng request, fetch "no-store".
// - Không đệm: thân backend đi thẳng ra trình duyệt dưới dạng luồng — luồng text/event-stream
//   của quầy và trạm đi qua đây (compress tắt ở next.config.ts).
// - Trình duyệt đi thì lời gọi lên backend cũng huỷ (request.signal) — ADR-097 điểm 4 cần backend
//   thấy luồng quầy đóng; P4-06 chứng minh trên app thật.
// - Đường dẫn lấy nguyên từ URL, không giải mã rồi mã hoá lại, để giữ %2F trong mã QR (QC-12).
import { UPSTREAM_UNREACHABLE_HEADER } from "@/lib/api/client";
import { backendUrl } from "@/lib/api/backend-url";

export const dynamic = "force-dynamic";

const PREFIX = "/api";

// Cookie: phiên đăng nhập banhcuon_phien (ADR-109 điểm 6). Origin: backend chặn cửa ghi khác nguồn
// (middleware.CungNguon) — Origin của trình duyệt đi nguyên lên. Last-Event-ID: nối lại luồng SSE.
// X-Person-Id (chọn tên) đã gỡ ở T-190: không chuyển.
const REQUEST_HEADERS = ["accept", "content-type", "cookie", "origin", "last-event-id"];
// Allow: lời 405 của QC-12.
const RESPONSE_HEADERS = ["content-type", "cache-control", "allow"];

async function forward(request: Request): Promise<Response> {
  const incoming = new URL(request.url);
  const target = backendUrl() + incoming.pathname.slice(PREFIX.length) + incoming.search;

  const headers = new Headers();
  for (const name of REQUEST_HEADERS) {
    const value = request.headers.get(name);
    if (value !== null) headers.set(name, value);
  }

  const hasBody = request.method !== "GET" && request.method !== "HEAD";
  let upstream: Response;
  try {
    upstream = await fetch(target, {
      method: request.method,
      headers,
      body: hasBody ? await request.arrayBuffer() : undefined,
      signal: request.signal,
      cache: "no-store",
      redirect: "manual",
    });
  } catch {
    return new Response(null, {
      status: 502,
      headers: { [UPSTREAM_UNREACHABLE_HEADER]: "1", "cache-control": "no-store" },
    });
  }

  const out = new Headers();
  for (const name of RESPONSE_HEADERS) {
    const value = upstream.headers.get(name);
    if (value !== null) out.set(name, value);
  }
  // Set-Cookie: mỗi dòng đi riêng — gộp bằng dấu phẩy làm hỏng thuộc tính Expires.
  for (const cookie of upstream.headers.getSetCookie()) out.append("set-cookie", cookie);
  if (!out.has("cache-control")) out.set("cache-control", "no-store");
  out.set("x-accel-buffering", "no");
  return new Response(upstream.body, { status: upstream.status, headers: out });
}

export { forward as GET, forward as HEAD, forward as POST, forward as PUT, forward as PATCH, forward as DELETE };
