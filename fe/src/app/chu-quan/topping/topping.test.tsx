// Test trang Topping (T-210) — Claude viết cùng lượt dựng trang. Giữ: nhóm và lựa chọn là đúng thứ backend trả từ
// GET /option-groups; phụ thu bày là mức cho mỗi phần nhận nhân, màn không tính giá; thêm lựa chọn gửi tên, phụ thu và
// các nhóm được tích; ẩn · bật lại bắt buộc lý do; mặc định không có nút ẩn; ghi xong đọc lại; lời từ chối gắn đúng ô.
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";

import Page from "./page";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/chu-quan/topping",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(cleanup);

const mau: components["schemas"]["OptionGroupsAdmin"] = { option_groups: [
  { option_group_id: 1, name: "Nhân", prerequisite_option_ids: [], options: [
    { menu_option_id: 1, name: "Chay", surcharge_vnd: 0, is_default: false, hidden_at: null },
    { menu_option_id: 2, name: "Thịt", surcharge_vnd: 1000, is_default: true, hidden_at: null },
    { menu_option_id: 5, name: "Thịt + nấm", surcharge_vnd: 1000, is_default: false, hidden_at: "2026-10-19T03:00:00Z" },
  ] },
  { option_group_id: 2, name: "Lượng nhân", prerequisite_option_ids: [2, 5], options: [
    { menu_option_id: 3, name: "Thường", surcharge_vnd: 0, is_default: true, hidden_at: null },
    { menu_option_id: 4, name: "Nhiều nhân", surcharge_vnd: 1000, is_default: false, hidden_at: null },
  ] },
] };
type TraLoi = { status: number; body?: unknown };
function moTrang(ghi?: (g: GoiDen) => TraLoi) {
  return voiBackend(<Page />, (g) => {
    if (g.method === "GET" && g.path === "/option-groups") return { status: 200, body: mau };
    if (g.method !== "GET" && ghi) return ghi(g);
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}
const soLanDoc = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/option-groups").length;
const cacGhi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");
const nhom = async (ten: string) => (await screen.findByRole("heading", { name: ten })).closest("section") as HTMLElement;

describe("trang topping", () => {
  it("bày nhóm, lựa chọn, phụ thu mỗi phần, mặc định, đã ẩn và nhóm được mở", async () => {
    moTrang();
    const n = await nhom("Nhân");
    expect(within(n).getByText(/Thịt · \+1\.000 đ mỗi phần nhận nhân/)).toBeTruthy();
    expect(within(n).getAllByText("Mặc định")).toHaveLength(1);
    expect(within(n).getByText("Đã ẩn")).toBeTruthy();
    expect(within(n).getAllByText("Cho chọn Lượng nhân")).toHaveLength(2);
    expect(within(n).queryByRole("button", { name: "Ẩn Thịt" })).toBeNull();
    expect(within(n).getByRole("button", { name: "Ẩn Chay" })).toBeTruthy();
    expect(within(n).getByRole("button", { name: "Bật lại Thịt + nấm" })).toBeTruthy();
  });

  it("thêm lựa chọn gửi tên, phụ thu, nhóm được tích; xong thì đọc lại", async () => {
    const goi = moTrang(() => ({ status: 201, body: { menu_option_id: 9, option_group_id: 1, name: "Thịt + chả", surcharge_vnd: 2000 } }));
    const n = await nhom("Nhân");
    const f = within(n).getByRole("form", { name: "Thêm lựa chọn vào Nhân" });
    fireEvent.change(within(f).getByLabelText("Tên lựa chọn"), { target: { value: " Thịt + chả " } });
    fireEvent.change(within(f).getByLabelText("Phụ thu mỗi phần nhận nhân (đồng)"), { target: { value: "2000" } });
    fireEvent.click(within(f).getByLabelText("Lượng nhân"));
    fireEvent.submit(f);
    await screen.findByText("Đã thêm Thịt + chả vào Nhân.");
    expect(cacGhi(goi)).toEqual([{ method: "POST", path: "/option-groups/1/options",
      body: { name: "Thịt + chả", surcharge_vnd: 2000, enables_option_group_ids: [2] } }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("trùng tên: lời gắn ô Tên lựa chọn", async () => {
    moTrang(() => ({ status: 409, body: { code: "menu_option_name_taken" } }));
    const n = await nhom("Lượng nhân");
    const f = within(n).getByRole("form", { name: "Thêm lựa chọn vào Lượng nhân" });
    fireEvent.change(within(f).getByLabelText("Tên lựa chọn"), { target: { value: "Thường" } });
    fireEvent.change(within(f).getByLabelText("Phụ thu mỗi phần nhận nhân (đồng)"), { target: { value: "0" } });
    fireEvent.submit(f);
    await waitFor(() => expect(within(f).getByLabelText("Tên lựa chọn").getAttribute("aria-invalid")).toBe("true"));
    expect(f.textContent).toMatch(/đã có lựa chọn cùng tên/);
  });

  it("ẩn bắt buộc lý do; gửi đúng đường gọi; bật lại dùng đường unhiding", async () => {
    const goi = moTrang(() => ({ status: 200, body: { menu_option_id: 1 } }));
    const n = await nhom("Nhân");
    fireEvent.click(within(n).getByRole("button", { name: "Ẩn Chay" }));
    const f = within(n).getByRole("form", { name: "Ẩn Chay" });
    fireEvent.submit(f);
    await waitFor(() => expect(within(f).getByLabelText("Lý do").getAttribute("aria-invalid")).toBe("true"));
    expect(cacGhi(goi)).toHaveLength(0);
    fireEvent.change(within(f).getByLabelText("Lý do"), { target: { value: "Hết đồ chay" } });
    fireEvent.submit(f);
    await screen.findByText("Đã ẩn Chay.");
    fireEvent.click(within(n).getByRole("button", { name: "Bật lại Thịt + nấm" }));
    const f2 = within(n).getByRole("form", { name: "Bật lại Thịt + nấm" });
    fireEvent.change(within(f2).getByLabelText("Lý do"), { target: { value: "Có nấm lại" } });
    fireEvent.submit(f2);
    await screen.findByText("Đã bật lại Thịt + nấm.");
    expect(cacGhi(goi)).toEqual([
      { method: "POST", path: "/menu-options/1/hiding", body: { reason: "Hết đồ chay" } },
      { method: "POST", path: "/menu-options/5/unhiding", body: { reason: "Có nấm lại" } },
    ]);
  });
});
