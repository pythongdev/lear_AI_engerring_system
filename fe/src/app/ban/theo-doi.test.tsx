import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { TheoDoiMon } from "./_components/theo-doi-mon";
import type { TienDoBan } from "./_components/du-lieu-theo-doi";
import TheoDoiPage from "./[ma]/theo-doi/page";

afterEach(() => { cleanup(); vi.useRealTimers(); vi.unstubAllGlobals(); });
type Item = components["schemas"]["ServiceBoardItem"];
type Line = components["schemas"]["PriceLine"];
const item = (name: string, ordered: number, served: number, nhan?: string): Item => ({
  menu_component_id: 1, component_name: name, filling_option_ids: [], extra_filling: false,
  options: nhan ? [{ option_group_name: "Nhân", option_name: nhan }] : [], ordered, served, missing: ordered - served,
});
const line = (name: string): Line => ({ menu_item_id: 2, item_name: name, quantity: 2, unit_price_vnd: 1234, line_total_vnd: 2468, components: [], options: [] });
function mau(overrides: Partial<NonNullable<TienDoBan["session"]>> = {}): TienDoBan {
  return { table_label: "Bàn 4", read_at: "2026-11-23T02:42:08Z", session: {
    tables: ["4", "5"], orders_ahead: 3,
    items: [item("Bánh cuốn", 9, 3, "Thịt"), item("Bánh cuốn", 3, 1, "Thịt"), item("Bánh cuốn", 8, 2, "Thịt + mộc nhĩ"),
      item("Trứng chín", 4, 1), item("Trứng tái", 3, 2), item("Trứng vàng", 2, 1), item("Bánh cuốn", 5, 4, "Chay"), item("Giò", 6, 2),
      item("Canh bánh cuốn", 99, 50), item("nước chấm", 88, 44)],
    lines: [line("Đơn đã nhận")], pending_lines: [], served_amount_vnd: 123456, lines_total_vnd: 789012, ...overrides,
  } };
}
function mo(data = mau(), fetch = vi.fn<(req: Request) => Promise<Response>>(async () => Response.json(data))) {
  render(<ApiProvider fetch={fetch}><TheoDoiMon ma="ma-4" initialData={data} /></ApiProvider>);
  return fetch;
}

it("T372: server đọc mã với no-store, lần đầu có bàn ghép và giờ Việt Nam đủ giây", async () => {
  const server = vi.fn(async () => Response.json(mau()));
  vi.stubGlobal("fetch", server);
  const page = await TheoDoiPage({ params: Promise.resolve({ ma: "ma 4" }) });
  expect(server).toHaveBeenCalledWith(expect.stringContaining("/qr-codes/ma%204/progress"), { cache: "no-store" });
  render(<ApiProvider fetch={async () => Response.json(mau())}>{page}</ApiProvider>);
  expect(screen.getByRole("heading", { level: 1, name: "Bàn 4 + Bàn 5" })).toBeTruthy();
  expect(screen.getAllByRole("heading", { level: 1 })).toHaveLength(1);
  expect(screen.getByText("Theo dõi món · Cập nhật lúc 09:42:08 · tự làm mới")).toBeTruthy();
});

it.each([
  [3, "Còn 3 lượt gọi trước bạn đang chờ món"],
  [0, "Không còn lượt nào gọi trước bạn"],
])("T372: orders_ahead %s hiện đúng câu và hai ghi chú", (orders_ahead, text) => {
  mo(mau({ orders_ahead: orders_ahead as number }));
  expect(screen.getByRole("heading", { name: text as string })).toBeTruthy();
  expect(screen.getByText("Chỉ để tham khảo — quán phục vụ theo ai tới trước ăn trước, đôi khi ưu tiên khách vội.")).toBeTruthy();
  expect(screen.getByText("Tính chung lượt tại bàn, mang đi, giao hàng và đặt qua điện thoại.")).toBeTruthy();
});

it("T372: chỉ chờ duyệt, có tên/lựa chọn/số lượng combo, không giá và không tự đặt số lượt", () => {
  mo(mau({ orders_ahead: null, items: [], lines: [], lines_total_vnd: 0,
    pending_lines: [{ ...line("Combo chờ"), menu_combo_id: 3, portions: [{ ...line("Trứng chờ"), options: [{ menu_option_id: 1, option_group_name: "Nhân", option_name: "Nhiều nhân", surcharge_vnd: 10 }] }] }],
  }));
  expect(screen.getByRole("heading", { name: "Quán chưa xác nhận món của bạn" })).toBeTruthy();
  expect(screen.queryByRole("table")).toBeNull();
  const pending = screen.getByRole("region", { name: "Chờ quán xác nhận" });
  expect(pending.textContent).toContain("Combo chờ");
  expect(pending.textContent).toContain("Trứng chờ · Nhiều nhân ×2");
  expect(pending.textContent).not.toMatch(/\d[\d.]*đ/);
  expect(screen.queryByText(/Tính chung lượt/)).toBeNull();
});

it("T372: mọi missing bằng 0 báo nhận đủ, pending rỗng ẩn", () => {
  mo(mau({ orders_ahead: null, items: [item("Giò", 6, 6)] }));
  expect(screen.getByRole("heading", { name: "Bàn bạn đã nhận đủ món" })).toBeTruthy();
  expect(screen.queryByRole("region", { name: "Chờ quán xác nhận" })).toBeNull();
});

it("T372: null khi chưa có mốc không bị diễn giải thành 0 lượt hoặc đã đủ món", () => {
  mo(mau({ orders_ahead: null }));
  expect(screen.queryByRole("region", { name: "Lượt gọi trước" })).toBeNull();
});

it("T372: bảng dùng cột Vận hành, gom đúng ba loại trứng và giò, không đếm canh/nước chấm", () => {
  mo();
  const table = screen.getByRole("table", { name: "Số bánh quán đã nhận" });
  expect(within(table).getAllByRole("columnheader").map((e) => e.textContent)).toEqual(["Tiến độ", "Thịt", "Mộc nhĩ", "Trứng", "Chay", "Giò", "Tiền bánh đã ra"]);
  const rows = within(table).getAllByRole("row");
  const cells = (i: number) => within(rows[i]).getAllByRole("cell").slice(0, 5).map((e) => e.textContent);
  expect(cells(1)).toEqual(["12", "8", "4 chín3 tái2 vàng", "5", "6"]);
  expect(cells(2)).toEqual(["4", "2", "1 chín2 tái1 vàng", "4", "2"]);
  expect(cells(3)).toEqual(["8", "6", "3 chín1 tái1 vàng", "1", "4"]);
  expect(screen.getByText("16 / 40 bánh đã ra")).toBeTruthy();
  expect(screen.getByRole("progressbar").getAttribute("value")).toBe("16");
  expect(screen.getByRole("progressbar").getAttribute("max")).toBe("40");
  expect(screen.getAllByText("123.456đ")).toHaveLength(2);
});

it("T372: đơn thu gọn mặc định, tổng backend và câu tính tiền luôn hiện; mở dùng dòng đã ghi", () => {
  mo();
  const region = screen.getByRole("region", { name: "Đơn đã đặt" });
  const button = within(region).getByRole("button", { name: "Xem đơn đã đặt (1 dòng)" });
  const detail = document.getElementById(button.getAttribute("aria-controls")!)!;
  expect(button.getAttribute("aria-expanded")).toBe("false");
  expect(detail.hidden).toBe(true);
  expect(within(region).getByText("Tổng tiền đơn")).toBeTruthy();
  expect(within(region).getByText("789.012đ")).toBeTruthy();
  expect(within(region).getByText("Món chưa ra thì quầy chưa tính tiền.")).toBeTruthy();
  fireEvent.click(button);
  expect(detail.hidden).toBe(false);
  expect(screen.getByRole("button", { name: "Ẩn đơn đã đặt" }).getAttribute("aria-expanded")).toBe("true");
  expect(within(detail).getByText(/Đơn đã nhận ·.*Số lượng 2 · 2.468đ/)).toBeTruthy();
  fireEvent.click(button);
  expect(detail.hidden).toBe(true);
  expect(screen.getByRole("link", { name: "Gọi thêm món" }).getAttribute("href")).toBe("/ban/ma-4");
});

it.each([null, { ...mau().session!, lines: [], pending_lines: [] }])("T372: chưa gọi khi session null hoặc cả hai mảng dòng rỗng", (session) => {
  mo({ ...mau(), session });
  expect(screen.getByText("Bàn bạn chưa gọi món.")).toBeTruthy();
  expect(screen.getByRole("link", { name: "Xem thực đơn" }).getAttribute("href")).toBe("/ban/ma-4");
  expect(screen.queryByRole("table")).toBeNull();
});

it("T372: 404 ở server mời quét lại mã", async () => {
  const response = () => Response.json({ code: "qr_code_not_current" }, { status: 404 });
  vi.stubGlobal("fetch", vi.fn(async () => response()));
  const page = await TheoDoiPage({ params: Promise.resolve({ ma: "cu" }) });
  render(<ApiProvider fetch={async () => response()}>{page}</ApiProvider>);
  expect(screen.getByText("Bạn vui lòng quét lại mã trên bàn.")).toBeTruthy();
  expect(screen.queryByRole("table")).toBeNull();
});

it("T372: đọc lại nhận mã cũ thì bỏ số cũ và mời quét lại", async () => {
  mo(mau(), vi.fn(async () => Response.json({ code: "qr_code_not_current" }, { status: 404 })));
  expect(await screen.findByText("Bạn vui lòng quét lại mã trên bàn.")).toBeTruthy();
  expect(screen.queryByRole("table")).toBeNull();
});

it("T372: lỗi mạng giữ số cũ và mốc đọc, đọc lại thành công thay số", async () => {
  let loi = true;
  const fetch = vi.fn<(req: Request) => Promise<Response>>(async () => {
    if (loi) throw new TypeError("network");
    return Response.json(mau({ orders_ahead: 1 }));
  });
  mo(mau(), fetch);
  expect(await screen.findByRole("alert")).toBeTruthy();
  expect(screen.getByRole("heading", { name: "Còn 3 lượt gọi trước bạn đang chờ món" })).toBeTruthy();
  expect(screen.getByRole("table")).toBeTruthy();
  loi = false;
  fireEvent.click(screen.getByRole("button", { name: "Đọc lại" }));
  await waitFor(() => expect(screen.queryByRole("alert")).toBeNull());
  expect(screen.getByRole("heading", { name: "Còn 1 lượt gọi trước bạn đang chờ món" })).toBeTruthy();
});

it("T372: refetchInterval 15 000 thực sự gọi lại bằng API", async () => {
  vi.useFakeTimers();
  const fetch = mo();
  await act(async () => { await vi.advanceTimersByTimeAsync(1); });
  expect(fetch).toHaveBeenCalledTimes(1);
  expect(fetch.mock.calls[0][0].url).toBe("http://fe.test/api/qr-codes/ma-4/progress");
  await act(async () => { await vi.advanceTimersByTimeAsync(14_998); });
  expect(fetch).toHaveBeenCalledTimes(1);
  await act(async () => { await vi.advanceTimersByTimeAsync(1); });
  expect(fetch).toHaveBeenCalledTimes(2);
});
