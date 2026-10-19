// Test hồi quy P4A-05 (combo) — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: giá combo là giá RIÊNG chủ quán đặt (shop-facts §8.9, U-092 đóng 2026-10-14; hợp đồng POST /menu-combos) — trang
// bày đúng price_vnd backend trả, không cộng giá món, không gọi /price-quotes hay /menu (ADR-086); món trong combo chọn
// từ GET /menu-categories (cùng khoá query với trang Sản phẩm), món ngừng bán không chọn được; đổi giá và ẩn bắt buộc
// lý do; đổi giá trong giờ bán bị backend từ chối và trang nói đúng lý do; mức phụ thu theo món chỉ ĐỌC ở bước này;
// ghi chờ backend xác nhận rồi đọc lại, không ghi tay cache (ADR-102 điểm 2); lời từ chối gắn đúng ô; bấm hai lần gửi một lệnh.
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";

import Page from "./page";

type MenuComboList = components["schemas"]["MenuComboList"];
type MenuCombo = components["schemas"]["MenuCombo"];
type MenuCategoryList = components["schemas"]["MenuCategoryList"];

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/chu-quan/combo",
  useSearchParams: () => new URLSearchParams(),
}));

afterEach(cleanup);

function combo(id: number, name: string, price_vnd: number, items: MenuCombo["items"]): MenuCombo {
  return {
    menu_combo_id: id, name, price_vnd, person_id: 1, person_name: "Chủ", created_at: "2026-10-16T01:00:00Z",
    hidden_at: null, hidden_by_person_id: null, hidden_by_name: null, items,
  };
}

// Giá combo cố ý KHÁC mọi phép cộng giá món: trang phải bày đúng số backend trả.
const mauCombo: MenuComboList = {
  combos: [
    combo(5, "Combo Đầy đủ", 45000, [
      { menu_item_id: 11, item_name: "Bánh cuốn trứng", quantity: 2, discontinued: false, surcharges: [
        { menu_option_id: 3, option_group_name: "Nhân", option_name: "Thịt", surcharge_vnd: 2000 },
      ] },
      { menu_item_id: 20, item_name: "Chả quế", quantity: 1, discontinued: true, surcharges: [] },
    ]),
    combo(4, "Combo Chay", 30000, [
      { menu_item_id: 12, item_name: "Bánh cuốn chay", quantity: 1, discontinued: false, surcharges: [] },
    ]),
  ],
};

const mauMon: MenuCategoryList = {
  categories: [{
    menu_category_id: 2, name: "Bánh cuốn", person_id: 1, person_name: "Chủ", created_at: "2026-10-16T01:00:00Z",
    hidden_at: null, hidden_by_person_id: null, hidden_by_name: null, items: [
      { menu_item_id: 11, item_name: "Bánh cuốn trứng", discontinued: false },
      { menu_item_id: 10, item_name: "Bánh cuốn thịt", discontinued: true },
      { menu_item_id: 12, item_name: "Bánh cuốn chay", discontinued: false },
    ],
  }],
  uncategorized_items: [{ menu_item_id: 20, item_name: "Chả quế", discontinued: false }],
};

type TraLoi = { status: number; body?: unknown };
function moTrang(tl: { doc?: (lan: number) => TraLoi; ghi?: (g: GoiDen) => TraLoi } = {}) {
  let lan = 0;
  return voiBackend(<Page />, (g) => {
    if (g.method === "GET" && g.path === "/menu-combos") {
      lan += 1;
      return tl.doc ? tl.doc(lan) : { status: 200, body: mauCombo };
    }
    if (g.method === "GET" && g.path === "/menu-categories") return { status: 200, body: mauMon };
    if (g.method !== "GET") return tl.ghi ? tl.ghi(g) : { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}
const soLanDoc = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/menu-combos").length;
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");

function go(o: HTMLElement, nhan: string, giaTri: string) {
  fireEvent.change(within(o).getByLabelText(nhan), { target: { value: giaTri } });
}
const oSai = (o: HTMLElement, nhan: string) => within(o).getByLabelText(nhan).getAttribute("aria-invalid");
async function mo(nhanNut: string) {
  fireEvent.click(await screen.findByRole("button", { name: nhanNut }));
  return screen.getByRole("form", { name: nhanNut });
}
async function formLap() {
  const f = await screen.findByRole("form", { name: "Lập combo" });
  // Danh sách món đọc xong thì ô chọn món 1 mới có lựa chọn.
  await waitFor(() => expect((within(f).getByLabelText("Món 1") as HTMLSelectElement).options.length).toBeGreaterThan(1));
  return f;
}
function dienComboHopLe(f: HTMLElement) {
  go(f, "Tên combo", "Combo Nhỏ");
  go(f, "Giá combo (đồng)", "35000");
  go(f, "Món 1", "11");
  go(f, "Số suất món 1", "1");
}

describe("trang combo — danh sách", () => {
  it("bày combo đúng thứ backend, giá đúng price_vnd, món kèm số suất, món ngừng bán có nhãn, mức phụ thu chỉ đọc", async () => {
    const goi = moTrang();
    const day = await screen.findByRole("region", { name: "Combo Đầy đủ" });
    expect(day.textContent ?? "").toMatch(/45\.000\s*đ/);
    const mon = within(day).getAllByRole("listitem").map((li) => li.textContent ?? "");
    expect(mon[0]).toMatch(/Bánh cuốn trứng.*×\s*2/);
    expect(mon[0]).toMatch(/Nhân.*Thịt.*2\.000\s*đ/);
    expect(mon[0]).not.toContain("Ngừng bán");
    expect(mon[1]).toContain("Chả quế");
    expect(mon[1]).toContain("Ngừng bán");
    const chay = screen.getByRole("region", { name: "Combo Chay" });
    expect(day.compareDocumentPosition(chay) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(chay.textContent ?? "").toMatch(/30\.000\s*đ/);
    // Không đọc giá món hay tính thử: giá combo là giá riêng backend trả.
    expect(goi.some((g) => g.path === "/price-quotes" || g.path === "/menu")).toBe(false);
  });

  it("không có nút xoá, đổi tên, sửa món hay đặt phụ thu — hợp đồng không có cửa ấy ở bước này", async () => {
    moTrang();
    await screen.findByRole("region", { name: "Combo Đầy đủ" });
    expect(screen.queryByRole("button", { name: /xoá|xóa|đổi tên|sửa món|phụ thu/i })).toBeNull();
  });

  it("chưa có combo: nói chưa có, vẫn cho lập", async () => {
    moTrang({ doc: () => ({ status: 200, body: { combos: [] } }) });
    expect(await screen.findByText(/Chưa có combo/)).toBeTruthy();
    expect(await screen.findByRole("form", { name: "Lập combo" })).toBeTruthy();
  });

  it("đọc lỗi: báo không đọc được", async () => {
    moTrang({ doc: () => ({ status: 500, body: { code: "internal_error" } }) });
    await waitFor(() => expect(screen.getByRole("alert").textContent ?? "").toMatch(/Chưa đọc được danh sách combo/));
  });
});

describe("trang combo — lập", () => {
  it("món chọn được là món còn bán, theo thứ tự backend; gửi đúng thân, số nguyên; xong báo, đọc lại, xoá form", async () => {
    const goi = moTrang({ ghi: () => ({ status: 201, body: combo(6, "Combo Nhỏ", 35000, []) }) });
    const f = await formLap();
    const chon = within(f).getByLabelText("Món 1") as HTMLSelectElement;
    expect([...chon.options].filter((o) => o.value !== "").map((o) => [o.value, o.textContent]))
      .toEqual([["11", "Bánh cuốn trứng"], ["12", "Bánh cuốn chay"], ["20", "Chả quế"]]);
    dienComboHopLe(f);
    go(f, "Số suất món 1", "2");
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món vào combo" }));
    go(f, "Món 2", "20");
    go(f, "Số suất món 2", "1");
    fireEvent.click(within(f).getByRole("button", { name: "Lập combo" }));

    expect(await screen.findByText("Đã lập combo Combo Nhỏ.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "POST", path: "/menu-combos",
      body: { name: "Combo Nhỏ", price_vnd: 35000, items: [
        { menu_item_id: 11, quantity: 2 }, { menu_item_id: 20, quantity: 1 },
      ] },
    }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
    expect((within(f).getByLabelText("Tên combo") as HTMLInputElement).value).toBe("");
  });

  it("bỏ được món thêm sau, không bỏ được món duy nhất", async () => {
    moTrang();
    const f = await formLap();
    expect(within(f).queryByRole("button", { name: "Bỏ món 1" })?.hasAttribute("disabled") ?? true).toBe(true);
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món vào combo" }));
    expect(within(f).getByLabelText("Món 2")).toBeTruthy();
    fireEvent.click(within(f).getByRole("button", { name: "Bỏ món 2" }));
    expect(within(f).queryByLabelText("Món 2")).toBeNull();
  });

  it("thiếu tên, giá không nguyên dương, chưa chọn món: không gửi, đánh dấu đúng ô", async () => {
    const goi = moTrang();
    const f = await formLap();
    go(f, "Giá combo (đồng)", "1500.5");
    fireEvent.click(within(f).getByRole("button", { name: "Lập combo" }));
    await waitFor(() => expect(oSai(f, "Tên combo")).toBe("true"));
    expect(oSai(f, "Giá combo (đồng)")).toBe("true");
    expect(oSai(f, "Món 1")).toBe("true");
    go(f, "Giá combo (đồng)", "0");
    fireEvent.click(within(f).getByRole("button", { name: "Lập combo" }));
    await waitFor(() => expect(oSai(f, "Giá combo (đồng)")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("chọn cùng một món hai lần: không gửi, đánh dấu ô Món 2", async () => {
    const goi = moTrang();
    const f = await formLap();
    dienComboHopLe(f);
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món vào combo" }));
    go(f, "Món 2", "11");
    go(f, "Số suất món 2", "1");
    fireEvent.click(within(f).getByRole("button", { name: "Lập combo" }));
    await waitFor(() => expect(oSai(f, "Món 2")).toBe("true"));
    expect(oSai(f, "Món 1")).not.toBe("true");
    expect(ghi(goi)).toEqual([]);
  });

  it("món vừa ngừng bán (409 menu_item_discontinued, field items[1].menu_item_id): gắn ô Món 2, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_item_discontinued", field: "items[1].menu_item_id" } }) });
    const f = await formLap();
    dienComboHopLe(f);
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món vào combo" }));
    go(f, "Món 2", "20");
    go(f, "Số suất món 2", "1");
    fireEvent.click(within(f).getByRole("button", { name: "Lập combo" }));
    await waitFor(() => expect(oSai(f, "Món 2")).toBe("true"));
    expect(f.textContent ?? "").toMatch(/ngừng bán/);
    await waitFor(() => expect(goi.filter((x) => x.method === "GET" && x.path === "/menu-categories").length).toBe(2));
  });

  it("phản hồi lạ: nói chưa xác nhận được kết quả, giữ dữ liệu, không tự gửi lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 500, body: { khong: "phai Error" } }) });
    const f = await formLap();
    dienComboHopLe(f);
    fireEvent.click(within(f).getByRole("button", { name: "Lập combo" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/chưa xác nhận được kết quả/i));
    expect((within(f).getByLabelText("Tên combo") as HTMLInputElement).value).toBe("Combo Nhỏ");
    expect(ghi(goi)).toHaveLength(1);
  });

  it("bấm gửi hai lần liền chỉ gửi một lệnh", async () => {
    const goi = moTrang({ ghi: () => ({ status: 201, body: combo(6, "Combo Nhỏ", 35000, []) }) });
    const f = await formLap();
    dienComboHopLe(f);
    const nut = within(f).getByRole("button", { name: "Lập combo" });
    fireEvent.click(nut);
    fireEvent.click(nut);
    expect(await screen.findByText("Đã lập combo Combo Nhỏ.")).toBeTruthy();
    expect(ghi(goi)).toHaveLength(1);
  });
});

describe("trang combo — đổi giá và ẩn", () => {
  it("đổi giá: giá cũ điền sẵn; thiếu lý do thì không gửi", async () => {
    const goi = moTrang();
    const f = await mo("Đổi giá Combo Đầy đủ");
    expect((within(f).getByLabelText("Giá mới (đồng)") as HTMLInputElement).value).toBe("45000");
    go(f, "Giá mới (đồng)", "47000");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu giá" }));
    await waitFor(() => expect(oSai(f, "Lý do")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("đổi giá: gửi số nguyên và lý do tới đúng combo, báo theo giá backend trả, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: combo(5, "Combo Đầy đủ", 47000, []) }) });
    const f = await mo("Đổi giá Combo Đầy đủ");
    go(f, "Giá mới (đồng)", "47000");
    go(f, "Lý do", "Giá nguyên liệu tăng");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu giá" }));
    expect(await screen.findByText(/Đã đổi giá Combo Đầy đủ thành 47\.000\s*đ\./)).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "PUT", path: "/menu-combos/5/price", body: { price_vnd: 47000, reason: "Giá nguyên liệu tăng" },
    }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("đổi giá trong giờ bán (409 menu_combo_price_in_sales_hours): nói chỉ đổi được ngoài giờ bán, giữ dữ liệu", async () => {
    moTrang({ ghi: () => ({ status: 409, body: { code: "menu_combo_price_in_sales_hours" } }) });
    const f = await mo("Đổi giá Combo Chay");
    go(f, "Giá mới (đồng)", "32000");
    go(f, "Lý do", "thử");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu giá" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/ngoài giờ bán/));
    expect((within(f).getByLabelText("Giá mới (đồng)") as HTMLInputElement).value).toBe("32000");
  });

  it("combo vừa bị ẩn (409 menu_combo_hidden): báo và đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_combo_hidden" } }) });
    const f = await mo("Đổi giá Combo Chay");
    go(f, "Lý do", "thử");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu giá" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/đã bị ẩn/));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("ẩn: bắt buộc lý do; gửi đúng thân, báo, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: { ...combo(4, "Combo Chay", 30000, []), hidden_at: "2026-10-19T01:00:00Z" } }) });
    const f = await mo("Ẩn Combo Chay");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận ẩn" }));
    await waitFor(() => expect(oSai(f, "Lý do")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
    go(f, "Lý do", "Không bán nữa");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận ẩn" }));
    expect(await screen.findByText("Đã ẩn combo Combo Chay.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "POST", path: "/menu-combos/4/hiding", body: { reason: "Không bán nữa" } }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });
});
