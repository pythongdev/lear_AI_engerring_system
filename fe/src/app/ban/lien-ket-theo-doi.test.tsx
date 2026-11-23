import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";
import { PhieuKhach } from "./_components/phieu-khach";
import { clientBackend, menuMau } from "./mau-khach";

vi.mock("next/navigation", () => ({ useRouter: () => ({ push: vi.fn() }), usePathname: () => "/ban/ma-4", useSearchParams: () => new URLSearchParams() }));
afterEach(() => { cleanup(); useNhapKhach.getState().xoaHet(); });
function mo(ma?: string) {
  const backend = clientBackend(undefined, () => ({ status: 201, body: { total_vnd: 71000, sales_order_id: 70 } }));
  render(<ApiProvider fetch={backend.fetch}><PhieuKhach ma={ma} nhan="4" initialMenu={menuMau} /></ApiProvider>);
}
it("T372: QR có link ở header, gửi thành công thêm link ngay dưới lời báo", async () => {
  mo("ma-4");
  const header = screen.getByRole("heading", { name: "Bàn 4" }).closest("header")!;
  expect(within(header).getByRole("link", { name: "Theo dõi món" }).getAttribute("href")).toBe("/ban/ma-4/theo-doi");
  fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
  const gui = screen.getByRole("button", { name: "Đặt món" }) as HTMLButtonElement;
  await waitFor(() => expect(gui.disabled).toBe(false));
  fireEvent.click(gui);
  fireEvent.click(screen.getByRole("button", { name: "Đồng ý đặt món" }));
  const bao = await screen.findByText("Đã gửi lượt gọi · tổng 71.000đ");
  expect(within(bao).getByRole("link", { name: "Theo dõi món" }).getAttribute("href")).toBe("/ban/ma-4/theo-doi");
  expect(screen.getAllByRole("link", { name: "Theo dõi món" })).toHaveLength(2);
});
it("T372: chế độ /dat-mon không có link Theo dõi món cả trước và sau khi gửi", async () => {
  mo();
  expect(screen.queryByRole("link", { name: "Theo dõi món" })).toBeNull();
  fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
  fireEvent.click(screen.getByRole("radio", { name: "Giao tận nơi" }));
  fireEvent.change(screen.getByRole("textbox", { name: "Số điện thoại" }), { target: { value: "0900000000" } });
  fireEvent.change(screen.getByRole("textbox", { name: "Địa chỉ giao" }), { target: { value: "Địa chỉ thử" } });
  const gui = screen.getByRole("button", { name: "Đặt đơn" }) as HTMLButtonElement;
  await waitFor(() => expect(gui.disabled).toBe(false));
  fireEvent.click(gui);
  await screen.findByText("Đã đặt đơn 70 · tổng 71.000đ");
  expect(screen.queryByRole("link", { name: "Theo dõi món" })).toBeNull();
});
