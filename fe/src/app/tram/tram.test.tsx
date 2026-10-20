// Test hồi quy P4-09 (màn trạm) — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ (ADR-090, ADR-102 điểm 1 dòng Trạm, 05-realtime-va-du-phong.md §1.3): màn trạm CHỈ ĐỌC — không một nút nào; bảng là
// số backend trả từ GET /production-board, gom theo trạm theo thứ tự backend; luôn hiện mốc read_at của lần đọc thành công
// cuối; phân biệt rỗng vì hết việc với rỗng vì không đọc được; đọc lỗi sau khi đã có bản thì giữ bản cũ kèm cảnh báo; tự kéo
// theo poll_interval_seconds backend trả.
import { cleanup, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";

import { bangMau, banMau, menuMau } from "../quay/san-xuat/mau-san-xuat";
import Page from "./page";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/tram",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(cleanup);

type TraLoi = { status: number; body?: unknown };
function mo(bang: (lan: number) => TraLoi = () => ({ status: 200, body: bangMau })) {
  const goi: { method: string; path: string }[] = [];
  let lan = 0;
  const fetch = async (req: Request) => {
    const path = new URL(req.url).pathname.replace(/^\/api/, "");
    goi.push({ method: req.method, path });
    let r: TraLoi = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    if (path === "/production-board") { lan += 1; r = bang(lan); }
    if (path === "/dining-tables") r = { status: 200, body: banMau };
    if (path === "/menu") r = { status: 200, body: menuMau };
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  };
  render(<ApiProvider fetch={fetch}><Page /></ApiProvider>);
  return goi;
}

describe("màn trạm — chỉ đọc", () => {
  it("bày theo trạm đúng thứ backend; số là số backend; tên nhân và nhãn bàn đọc từ /menu và /dining-tables", async () => {
    mo();
    const cuon = await screen.findByRole("region", { name: "Trạm cuon" });
    const canh = screen.getByRole("region", { name: "Trạm canh" });
    expect(cuon.compareDocumentPosition(canh) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    const hang = within(cuon).getAllByRole("listitem")[0].textContent ?? "";
    expect(hang).toContain("Bánh cuốn");
    expect(hang).toContain("Thịt");
    for (const s of ["Gọi 6", "Chờ làm 2", "Đã làm 3", "Đã ra 1", "Thiếu 5"]) expect(hang).toContain(s);
    await waitFor(() => expect(within(cuon).getByText(/Bàn 3/)).toBeTruthy());
    expect(within(cuon).getByText(/Đơn 77/)).toBeTruthy();
    expect(within(canh).getByText(/Nước chấm/)).toBeTruthy();
  });

  it("không có một nút nào — lúc có bảng, lúc rỗng, lúc lỗi", async () => {
    mo();
    await screen.findByRole("region", { name: "Trạm cuon" });
    expect(screen.queryAllByRole("button")).toHaveLength(0);
    cleanup();
    mo(() => ({ status: 200, body: { ...bangMau, rows: [] } }));
    await screen.findByText(/Hết việc/);
    expect(screen.queryAllByRole("button")).toHaveLength(0);
    cleanup();
    mo(() => ({ status: 500, body: { code: "internal_error" } }));
    await screen.findByText(/Không đọc được bảng/);
    expect(screen.queryAllByRole("button")).toHaveLength(0);
  });

  it("luôn hiện mốc của lần đọc thành công", async () => {
    mo();
    expect(await screen.findByText(/Cập nhật lúc/)).toBeTruthy();
  });

  it("rỗng vì hết việc khác rỗng vì không đọc được", async () => {
    mo(() => ({ status: 200, body: { ...bangMau, rows: [] } }));
    expect(await screen.findByText(/Hết việc/)).toBeTruthy();
    expect(screen.queryByText(/Không đọc được bảng/)).toBeNull();
    cleanup();
    mo(() => ({ status: 500, body: { code: "internal_error" } }));
    expect(await screen.findByText(/Không đọc được bảng/)).toBeTruthy();
    expect(screen.queryByText(/Hết việc/)).toBeNull();
    expect(screen.queryByText(/Cập nhật lúc/)).toBeNull();
  });

  it("đọc lỗi sau khi đã có bản: giữ bản cũ, cảnh báo, vẫn hiện mốc cũ; tự kéo theo chu kỳ backend", async () => {
    const goi = mo((lan) => lan === 1
      ? { status: 200, body: { ...bangMau, poll_interval_seconds: 0.05 } }
      : { status: 500, body: { code: "internal_error" } });
    await screen.findByRole("region", { name: "Trạm cuon" });
    expect(await screen.findByText(/Không đọc được bảng mới/, {}, { timeout: 1500 })).toBeTruthy();
    expect(screen.getByRole("region", { name: "Trạm cuon" })).toBeTruthy();
    expect(screen.getByText(/Cập nhật lúc/)).toBeTruthy();
    await waitFor(() => expect(goi.filter((g) => g.path === "/production-board").length).toBeGreaterThanOrEqual(3), { timeout: 1500 });
    expect(goi.filter((g) => g.method !== "GET")).toEqual([]);
  });
});
