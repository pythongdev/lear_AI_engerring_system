// Lớp gọi API duy nhất của fe/ (QC-18; docs/product/4-fe/01-khung-fe.md §3).
// Kiểu đường gọi, thân gửi, thân trả và danh sách mã lỗi đều đọc từ ./schema — file sinh từ
// docs/product/3-be/openapi.yaml bằng `npm run gen:api`, không sửa tay.
import createClient, { type Client } from "openapi-fetch";

import { errorCodeValues, type components, type paths } from "./schema";

export type ErrorCode = components["schemas"]["ErrorCode"];

// Tầng chuyển tiếp của Next trả status này kèm header này khi không nối được backend —
// phân biệt với một lời từ chối thật của backend (backend không bao giờ đặt header ấy).
export const UPSTREAM_UNREACHABLE_HEADER = "x-banhcuon-upstream-unreachable";

/**
 * Ba hình thất bại, theo 01-hop-dong-api.md §3 và ADR-102 điểm 1 · 2:
 * - `rejected`: backend từ chối bằng hình `Error`; màn chọn chữ theo `code`, không theo status.
 * - `no_response`: không có phản hồi của backend. Với lệnh ghi đây là *chưa rõ kết quả*, không là *thất bại*.
 * - `unexpected`: có phản hồi nhưng không đúng hình hợp đồng (mã lạ, thân không phải `Error`).
 */
export type ApiFailure =
  | { kind: "rejected"; status: number; code: ErrorCode; field?: string }
  | { kind: "no_response" }
  | { kind: "unexpected"; status: number };

export type ApiResult<T> = { ok: true; data: T } | { ok: false; failure: ApiFailure };

const knownCodes: ReadonlySet<string> = new Set(errorCodeValues);

function isErrorCode(value: unknown): value is ErrorCode {
  return typeof value === "string" && knownCodes.has(value);
}

/** Đọc một phản hồi không thành công thành `ApiFailure`. */
export function readFailure(response: Response, body: unknown): ApiFailure {
  if (response.headers.get(UPSTREAM_UNREACHABLE_HEADER) !== null) {
    return { kind: "no_response" };
  }
  if (typeof body === "object" && body !== null && "code" in body && isErrorCode(body.code)) {
    const field = "field" in body && typeof body.field === "string" ? body.field : undefined;
    return field === undefined
      ? { kind: "rejected", status: response.status, code: body.code }
      : { kind: "rejected", status: response.status, code: body.code, field };
  }
  return { kind: "unexpected", status: response.status };
}

/**
 * Chờ một lời gọi của `ApiClient` và trả `ApiResult`. Không thử lại — lệnh ghi không thử lại ngầm,
 * đường đọc không thử lại lời từ chối có `code` (ADR-102 điểm 2); thử lại đường đọc là việc của
 * thư viện truy vấn ở tầng trên.
 */
export async function call<T>(
  pending: Promise<{ data?: T; error?: unknown; response: Response }>,
): Promise<ApiResult<T>> {
  let settled: { data?: T; error?: unknown; response: Response };
  try {
    settled = await pending;
  } catch {
    return { ok: false, failure: { kind: "no_response" } };
  }
  const { data, error, response } = settled;
  if (!response.ok) {
    return { ok: false, failure: readFailure(response, error) };
  }
  return { ok: true, data: data as T };
}

export type ApiClient = Client<paths>;

export type ApiOptions = {
  /** Trình duyệt: "/api" (tầng chuyển tiếp của Next). Server: `backendUrl()`. */
  baseUrl: string;
  fetch?: (input: Request) => Promise<Response>;
};

/**
 * Danh tính đi bằng cookie phiên `HttpOnly` (ADR-109 điểm 6): trình duyệt tự gửi tới `/api` cùng origin,
 * code không đọc, không cất mã phiên. Không còn header chọn tên.
 */
export function createApi({ baseUrl, fetch }: ApiOptions): ApiClient {
  // cache "no-store": dữ liệu server chỉ được giữ ở cache của TanStack Query (ADR-102 điểm 3).
  return createClient<paths>({
    baseUrl,
    cache: "no-store",
    credentials: "same-origin",
    ...(fetch ? { fetch } : {}),
  });
}
