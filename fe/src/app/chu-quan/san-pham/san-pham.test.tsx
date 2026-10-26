// Test hồi quy P4A-04 — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: danh sách món là đúng thứ backend trả từ GET /menu-categories, kể cả món ngừng bán và món chưa xếp; trang không
// cộng, không tính thử giá (ADR-086 — giá món do backend tính từ thành phần) — T-234 (chủ repo 2026-10-23) cho trang bày
// giá đọc từ GET /menu, đúng từng tổ hợp backend trả. T-238 (chủ repo 2026-10-23) thêm ngăn *Cập nhật* mỗi món: đổi tên,
// chuyển danh mục, đổi giá gốc thành phần, ngừng bán — hồi quy I-018 phía FE (mọi lệnh cập nhật mang lý do, thiếu lý do
// không gửi) và I-013 (FE không gửi giá món, chỉ giá gốc chủ quán gõ); ghi chờ backend xác nhận rồi đọc lại, không ghi
// tay cache (ADR-102 điểm 2); lời từ chối có field gắn đúng ô; bấm gửi hai lần chỉ gửi một lệnh (fe-02 §3).
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";

import Page from "./page";

type MenuCategoryList = components["schemas"]["MenuCategoryList"];
type MenuCategory = components["schemas"]["MenuCategory"];
type Menu = components["schemas"]["Menu"];
type PriceQuote = components["schemas"]["PriceQuote"];

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/chu-quan/san-pham",
  useSearchParams: () => new URLSearchParams(),
}));

afterEach(cleanup);

function danhMuc(id: number, name: string, items: MenuCategory["items"]): MenuCategory {
  return {
    menu_category_id: id, name, person_id: 1, person_name: "Chủ", created_at: "2026-10-16T01:00:00Z",
    hidden_at: null, hidden_by_person_id: null, hidden_by_name: null, items,
  };
}

// Cố ý không theo id hay chữ cái: trang giữ thứ tự backend, không tự xếp.
const mau: MenuCategoryList = {
  categories: [
    danhMuc(2, "Bánh cuốn", [
      { menu_item_id: 11, item_name: "Bánh cuốn trứng", components: bangGia(11).lines[0].components, discontinued: false },
      { menu_item_id: 10, item_name: "Bánh cuốn thịt", components: [], discontinued: true },
    ]),
    danhMuc(1, "Đồ uống", []),
  ],
  uncategorized_items: [{ menu_item_id: 20, item_name: "Chả quế", components: bangGia(20).lines[0].components, discontinued: false }],
};

// Món ngừng bán (10) không có trong GET /menu; giá là số backend trả, trang không cộng.
const menuMau: Menu = {
  items: [
    {
      menu_item_id: 11, item_name: "Bánh cuốn trứng",
      option_groups: [{ option_group_id: 5, option_group_name: "Nhân", prerequisite_option_ids: [], options: [
        { menu_option_id: 51, option_name: "Thịt", is_default: true },
        { menu_option_id: 52, option_name: "Chay", is_default: false },
      ] }],
      prices: [{ option_ids: [51], unit_price_vnd: 35000 }, { option_ids: [52], unit_price_vnd: 30000 }],
    },
    { menu_item_id: 20, item_name: "Chả quế", option_groups: [], prices: [{ option_ids: [], unit_price_vnd: 10000 }] },
  ],
  combos: [],
};

// Thành phần đọc qua POST /price-quotes như trang Menu & giá (hợp đồng không có đường đọc thành phần riêng).
function bangGia(id: number): PriceQuote {
  const line = id === 11
    ? {
      menu_item_id: 11, item_name: "Bánh cuốn trứng", quantity: 1, unit_price_vnd: 35000, line_total_vnd: 35000,
      components: [
        { menu_component_id: 101, component_name: "Bánh cuốn", quantity: 3, takes_filling: true, base_price_vnd: 10000 },
        { menu_component_id: 102, component_name: "Trứng", quantity: 1, takes_filling: false, base_price_vnd: 5000 },
      ],
      options: [{ menu_option_id: 51, option_group_name: "Nhân", option_name: "Thịt", surcharge_vnd: 0 }],
    }
    : {
      menu_item_id: 20, item_name: "Chả quế", quantity: 1, unit_price_vnd: 10000, line_total_vnd: 10000,
      components: [{ menu_component_id: 103, component_name: "Chả quế", quantity: 1, takes_filling: false, base_price_vnd: 10000 }],
      options: [],
    };
  return { lines: [line], total_vnd: line.line_total_vnd };
}

type TraLoi = { status: number; body?: unknown };
function moTrang(tl: { doc?: (lan: number) => TraLoi; menu?: (lan: number) => TraLoi; ghi?: (g: GoiDen) => TraLoi } = {}) {
  let lan = 0;
  let lanMenu = 0;
  return voiBackend(<Page />, (g) => {
    if (g.method === "GET" && g.path === "/menu-categories") {
      lan += 1;
      return tl.doc ? tl.doc(lan) : { status: 200, body: mau };
    }
    if (g.method === "GET" && g.path === "/menu") {
      lanMenu += 1;
      return tl.menu ? tl.menu(lanMenu) : { status: 200, body: menuMau };
    }
    if (g.method === "POST" && g.path === "/price-quotes") {
      return { status: 200, body: bangGia((g.body as { lines: { menu_item_id: number }[] }).lines[0].menu_item_id) };
    }
    if (g.method !== "GET") {
      return tl.ghi ? tl.ghi(g) : { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    }
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}
const soLanDoc = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/menu-categories").length;
const soLanDocGia = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/menu").length;
// Tính thử là lời đọc đi bằng POST, không phải lệnh ghi.
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET" && x.path !== "/price-quotes");
const soLanThu = (g: GoiDen[]) => g.filter((x) => x.path === "/price-quotes").length;

// Ngăn Cập nhật của một món: bấm nút ở cột Thao tác.
async function moCapNhat(ten: string) {
  fireEvent.click(await screen.findByRole("button", { name: `Cập nhật ${ten}` }));
  return screen.findByRole("dialog", { name: `Cập nhật ${ten}` });
}

// Mỗi món một dòng bảng; dòng đầu là dòng tiêu đề cột.
function tenMon(vung: HTMLElement) {
  return within(vung).getAllByRole("row").slice(1).map((tr) => tr.textContent ?? "");
}
function dongMon(vung: HTMLElement, ten: string) {
  const dong = within(vung).getAllByRole("row").find((tr) => within(tr).queryAllByRole("cell")[0]?.textContent?.startsWith(ten));
  if (!dong) throw new Error("Không thấy dòng " + ten);
  return dong;
}
const gia = (so: string) => new RegExp(so.replace(".", "\\.") + "\\s?đ");

// Thêm món nằm trong ngăn bên phải: bấm nút ở đầu trang để mở.
async function formThem() {
  fireEvent.click(await screen.findByRole("button", { name: "Thêm món" }));
  return screen.findByRole("form", { name: "Thêm món" });
}
function go(o: HTMLElement, nhan: string, giaTri: string) {
  fireEvent.change(within(o).getByLabelText(nhan), { target: { value: giaTri } });
}
function dienThanhPhan(f: HTMLElement, i: number, ten: string, gia: string, soLuong: string) {
  go(f, `Tên thành phần ${i}`, ten);
  go(f, `Giá gốc thành phần ${i} (đồng)`, gia);
  go(f, `Số lượng thành phần ${i}`, soLuong);
}
function dienMonHopLe(f: HTMLElement) {
  go(f, "Tên món", "Bánh cuốn chay");
  fireEvent.change(within(f).getByLabelText("Danh mục"), { target: { value: "1" } });
  dienThanhPhan(f, 1, "Bánh cuốn chay", "30000", "1");
}
const oSai = (o: HTMLElement, nhan: string) => within(o).getByLabelText(nhan).getAttribute("aria-invalid");

describe("trang sản phẩm — danh sách", () => {
  it("bày món theo danh mục đúng thứ backend, kể cả món ngừng bán và món chưa xếp; chỉ đọc /menu-categories và /menu", async () => {
    const goi = moTrang();
    const banhCuon = await screen.findByRole("region", { name: "Bánh cuốn" });
    const ten = tenMon(banhCuon);
    expect(ten).toHaveLength(2);
    expect(ten[0]).toContain("Bánh cuốn trứng");
    expect(ten[1]).toContain("Bánh cuốn thịt");
    expect(ten[0]).not.toContain("Ngừng bán");
    expect(ten[1]).toContain("Ngừng bán");
    expect(within(screen.getByRole("region", { name: "Đồ uống" })).getByText(/Chưa có món/)).toBeTruthy();
    expect(tenMon(screen.getByRole("region", { name: "Chưa xếp danh mục" }))[0]).toContain("Chả quế");
    // Thứ tự danh mục cũng là của backend.
    const doUong = screen.getByRole("region", { name: "Đồ uống" });
    expect(banhCuon.compareDocumentPosition(doUong) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    await waitFor(() => expect(soLanDocGia(goi)).toBe(1));
    expect(goi.map((g) => `${g.method} ${g.path}`).sort()).toEqual(["GET /menu", "GET /menu-categories"]);
  });

  it("đầu trang có số món; bảng có cột Món · Danh mục · Trạng thái · Giá · Thành phần · Thao tác", async () => {
    moTrang();
    const banhCuon = await screen.findByRole("region", { name: "Bánh cuốn" });
    expect(screen.getByRole("heading", { level: 1 }).textContent ?? "").toMatch(/Sản phẩm\s*3 món/);
    expect(within(banhCuon).getAllByRole("columnheader").map((th) => th.textContent))
      .toEqual(["Món", "Danh mục", "Trạng thái", "Giá", "Thành phần", "Thao tác"]);
    const trung = dongMon(banhCuon, "Bánh cuốn trứng");
    const o = within(trung).getAllByRole("cell").map((td) => td.textContent ?? "");
    expect(o[1]).toBe("Bánh cuốn");
    expect(o[2]).toBe("Đang bán");
    expect(o[2]).not.toMatch(/Ngừng bán/);
    expect(dongMon(banhCuon, "Bánh cuốn thịt").textContent ?? "").toMatch(/Ngừng bán/);
    const chaQue = within(dongMon(screen.getByRole("region", { name: "Chưa xếp danh mục" }), "Chả quế")).getAllByRole("cell");
    expect(chaQue[1].textContent).toBe("Chưa xếp");
  });

  it("giá: đúng từng tổ hợp GET /menu trả kèm tên lựa chọn; món ngừng bán không có giá; không tính thử", async () => {
    const goi = moTrang();
    const banhCuon = await screen.findByRole("region", { name: "Bánh cuốn" });
    await waitFor(() => expect(within(dongMon(banhCuon, "Bánh cuốn trứng")).getAllByRole("cell")[3].textContent ?? "").toMatch(gia("35.000")));
    const oTrung = within(dongMon(banhCuon, "Bánh cuốn trứng")).getAllByRole("cell")[3].textContent ?? "";
    expect(oTrung).toMatch(/Thịt/);
    expect(oTrung).toMatch(/Chay/);
    expect(oTrung).toMatch(gia("30.000"));
    // Không cộng, không chọn thay: không có số nào ngoài hai giá backend trả.
    expect(oTrung.match(/\d+(\.\d{3})*/g)).toEqual(["35.000", "30.000"]);
    expect(within(dongMon(banhCuon, "Bánh cuốn thịt")).getAllByRole("cell")[3].textContent).toBe("—");
    const chaQue = within(dongMon(screen.getByRole("region", { name: "Chưa xếp danh mục" }), "Chả quế")).getAllByRole("cell");
    expect(chaQue[3].textContent ?? "").toMatch(gia("10.000"));
    expect(goi.some((g) => g.path === "/price-quotes")).toBe(false);
  });

  it("món đang bán mà /menu không có: ô giá nói chưa có giá", async () => {
    moTrang({ menu: () => ({ status: 200, body: { items: [], combos: [] } }) });
    const banhCuon = await screen.findByRole("region", { name: "Bánh cuốn" });
    await waitFor(() => expect(within(dongMon(banhCuon, "Bánh cuốn trứng")).getAllByRole("cell")[3].textContent).toBe("Chưa có giá"));
  });

  it("/menu đọc lỗi: bảng món vẫn hiện, ô giá nói chưa đọc được giá", async () => {
    moTrang({ menu: () => ({ status: 500, body: { code: "internal_error" } }) });
    const banhCuon = await screen.findByRole("region", { name: "Bánh cuốn" });
    await waitFor(() => expect(within(dongMon(banhCuon, "Bánh cuốn trứng")).getAllByRole("cell")[3].textContent).toBe("Chưa đọc được giá"));
    expect(tenMon(banhCuon)).toHaveLength(2);
  });

  it("ngoài ngăn chỉ có nút Cập nhật mỗi món; không nút xoá; chưa mở ngăn thì không tính thử", async () => {
    const goi = moTrang();
    const banhCuon = await screen.findByRole("region", { name: "Bánh cuốn" });
    expect(within(dongMon(banhCuon, "Bánh cuốn trứng")).getByRole("button", { name: "Cập nhật Bánh cuốn trứng" })).toBeTruthy();
    expect(screen.queryByRole("button", { name: /xoá|xóa|ngừng bán|giá|Đổi tên/i })).toBeNull();
    expect(soLanThu(goi)).toBe(0);
  });

  it("đọc lỗi: báo không đọc được, không bày form thêm món", async () => {
    moTrang({ doc: () => ({ status: 500, body: { code: "internal_error" } }) });
    await waitFor(() => expect(screen.getByRole("alert").textContent ?? "").toMatch(/Chưa đọc được danh sách món/));
    expect(screen.queryByRole("form", { name: "Thêm món" })).toBeNull();
  });

  it("chưa có danh mục nào: nói phải thêm danh mục trước, không có nút thêm món", async () => {
    moTrang({ doc: () => ({ status: 200, body: { categories: [], uncategorized_items: [] } }) });
    expect(await screen.findByText(/Chưa có danh mục/)).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Thêm món" })).toBeNull();
  });
});

describe("trang sản phẩm — thêm món", () => {
  it("gửi đúng thân hợp đồng, số là số nguyên; xong thì báo theo tên backend trả, đọc lại danh sách, xoá form", async () => {
    const goi = moTrang({ ghi: () => ({ status: 201, body: { menu_item_id: 30, name: "Bánh cuốn chay" } }) });
    const f = await formThem();
    // Danh mục chọn được là các danh mục backend trả, theo thứ tự ấy.
    const chon = within(f).getByLabelText("Danh mục") as HTMLSelectElement;
    expect([...chon.options].filter((o) => o.value !== "").map((o) => [o.value, o.textContent]))
      .toEqual([["2", "Bánh cuốn"], ["1", "Đồ uống"]]);
    dienMonHopLe(f);
    fireEvent.click(within(f).getByRole("checkbox", { name: "Thành phần 1 nhận nhân" }));
    fireEvent.click(within(f).getByRole("button", { name: "Thêm thành phần" }));
    dienThanhPhan(f, 2, "Hành phi", "0", "2");
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món" }));

    expect(await screen.findByText("Đã thêm món Bánh cuốn chay.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "POST", path: "/menu-items",
      body: {
        name: "Bánh cuốn chay", menu_category_id: 1,
        components: [
          { name: "Bánh cuốn chay", base_price_vnd: 30000, quantity: 1, takes_filling: true },
          { name: "Hành phi", base_price_vnd: 0, quantity: 2, takes_filling: false },
        ],
      },
    }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
    // Đọc lại cả giá để món mới có giá; ngăn vẫn mở, form đã xoá để thêm tiếp.
    await waitFor(() => expect(soLanDocGia(goi)).toBe(2));
    expect((within(f).getByLabelText("Tên món") as HTMLInputElement).value).toBe("");
    // Không gọi tính thử: giá chỉ là số GET /menu trả.
    expect(goi.some((g) => g.path === "/price-quotes")).toBe(false);
  });

  it("bỏ được thành phần thêm sau, không bỏ được thành phần duy nhất", async () => {
    moTrang();
    const f = await formThem();
    expect(within(f).queryByRole("button", { name: "Bỏ thành phần 1" })?.hasAttribute("disabled") ?? true).toBe(true);
    fireEvent.click(within(f).getByRole("button", { name: "Thêm thành phần" }));
    expect(within(f).getByLabelText("Tên thành phần 2")).toBeTruthy();
    fireEvent.click(within(f).getByRole("button", { name: "Bỏ thành phần 2" }));
    expect(within(f).queryByLabelText("Tên thành phần 2")).toBeNull();
  });

  it("thiếu tên, danh mục hoặc giá: không gửi, đánh dấu đúng ô", async () => {
    const goi = moTrang();
    const f = await formThem();
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món" }));
    await waitFor(() => expect(oSai(f, "Tên món")).toBe("true"));
    expect(oSai(f, "Danh mục")).toBe("true");
    expect(oSai(f, "Giá gốc thành phần 1 (đồng)")).toBe("true");
    go(f, "Tên món", "Bánh cuốn chay");
    fireEvent.change(within(f).getByLabelText("Danh mục"), { target: { value: "1" } });
    dienThanhPhan(f, 1, "Bánh cuốn chay", "-1", "1");
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món" }));
    await waitFor(() => expect(oSai(f, "Giá gốc thành phần 1 (đồng)")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("tên món trùng (409): lỗi gắn ô Tên món, giữ nguyên dữ liệu đã nhập", async () => {
    moTrang({ ghi: () => ({ status: 409, body: { code: "menu_item_name_conflict" } }) });
    const f = await formThem();
    dienMonHopLe(f);
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món" }));
    await waitFor(() => expect(oSai(f, "Tên món")).toBe("true"));
    expect(f.textContent ?? "").toMatch(/trùng/);
    expect((within(f).getByLabelText("Tên món") as HTMLInputElement).value).toBe("Bánh cuốn chay");
  });

  it("lời từ chối có field components[1].quantity gắn đúng ô Số lượng thành phần 2", async () => {
    moTrang({ ghi: () => ({ status: 400, body: { code: "invalid_request", field: "components[1].quantity" } }) });
    const f = await formThem();
    dienMonHopLe(f);
    fireEvent.click(within(f).getByRole("button", { name: "Thêm thành phần" }));
    dienThanhPhan(f, 2, "Hành phi", "0", "1");
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món" }));
    await waitFor(() => expect(oSai(f, "Số lượng thành phần 2")).toBe("true"));
    expect(oSai(f, "Số lượng thành phần 1")).not.toBe("true");
  });

  it("danh mục vừa bị ẩn (409 menu_category_hidden): báo và đọc lại danh sách", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_category_hidden" } }) });
    const f = await formThem();
    dienMonHopLe(f);
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/không còn dùng được/));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("phản hồi lạ: nói chưa xác nhận được kết quả, giữ dữ liệu, không tự gửi lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 500, body: { khong: "phai Error" } }) });
    const f = await formThem();
    dienMonHopLe(f);
    fireEvent.click(within(f).getByRole("button", { name: "Thêm món" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/chưa xác nhận được kết quả/i));
    expect((within(f).getByLabelText("Tên món") as HTMLInputElement).value).toBe("Bánh cuốn chay");
    expect(ghi(goi)).toHaveLength(1);
  });

  it("bấm gửi hai lần liền chỉ gửi một lệnh", async () => {
    const goi = moTrang({ ghi: () => ({ status: 201, body: { menu_item_id: 30, name: "Bánh cuốn chay" } }) });
    const f = await formThem();
    dienMonHopLe(f);
    const nut = within(f).getByRole("button", { name: "Thêm món" });
    fireEvent.click(nut);
    fireEvent.click(nut);
    expect(await screen.findByText("Đã thêm món Bánh cuốn chay.")).toBeTruthy();
    expect(ghi(goi)).toHaveLength(1);
  });
});

describe("trang sản phẩm — đổi tên món", () => {
  async function moDoiTen(ten: string) {
    const ngan = await moCapNhat(ten);
    return within(ngan).getByRole("form", { name: `Đổi tên ${ten}` });
  }

  it("tên cũ điền sẵn; thiếu lý do thì không gửi", async () => {
    const goi = moTrang();
    const f = await moDoiTen("Bánh cuốn trứng");
    expect((within(f).getByLabelText("Tên mới") as HTMLInputElement).value).toBe("Bánh cuốn trứng");
    go(f, "Tên mới", "Bánh cuốn trứng gà");
    go(f, "Lý do", "   ");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu tên" }));
    await waitFor(() => expect(oSai(f, "Lý do")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("gửi tên và lý do tới đúng món, báo theo tên backend trả, đọc lại danh sách", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: { menu_item_id: 11, name: "Bánh cuốn trứng gà" } }) });
    const f = await moDoiTen("Bánh cuốn trứng");
    go(f, "Tên mới", "Bánh cuốn trứng gà");
    go(f, "Lý do", "Ghi rõ trứng gà");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu tên" }));
    expect(await screen.findByText("Đã đổi tên thành Bánh cuốn trứng gà.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "PUT", path: "/menu-items/11", body: { name: "Bánh cuốn trứng gà", reason: "Ghi rõ trứng gà" },
    }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
    await waitFor(() => expect(soLanDocGia(goi)).toBe(2));
    // Lưu xong ngăn vẫn mở để cập nhật tiếp.
    expect(screen.getByRole("dialog", { name: "Cập nhật Bánh cuốn trứng" })).toBeTruthy();
  });

  it("món ngừng bán vẫn đổi tên, chuyển danh mục được; không có phần ngừng bán, không đổi giá ở đây", async () => {
    const goi = moTrang();
    const ngan = await moCapNhat("Bánh cuốn thịt");
    expect(within(ngan).getByRole("form", { name: "Đổi tên Bánh cuốn thịt" })).toBeTruthy();
    expect(within(ngan).getByRole("form", { name: "Chuyển danh mục Bánh cuốn thịt" })).toBeTruthy();
    expect(within(ngan).queryByRole("form", { name: /^Ngừng bán/ })).toBeNull();
    expect(ngan.textContent ?? "").toMatch(/Món đã ngừng bán\. Chưa có cách bán lại\./);
    expect(ngan.textContent ?? "").toMatch(/không đổi giá ở đây/);
    expect(within(ngan).queryByRole("form", { name: /^Giá gốc/ })).toBeNull();
    expect(soLanThu(goi)).toBe(0);
  });

  it("tên trùng (409): lỗi gắn ô Tên mới", async () => {
    moTrang({ ghi: () => ({ status: 409, body: { code: "menu_item_name_conflict" } }) });
    const f = await moDoiTen("Chả quế");
    go(f, "Tên mới", "Bánh cuốn trứng");
    go(f, "Lý do", "thử");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu tên" }));
    await waitFor(() => expect(oSai(f, "Tên mới")).toBe("true"));
    expect(f.textContent ?? "").toMatch(/trùng/);
  });
});

describe("trang sản phẩm — chuyển danh mục", () => {
  async function formDanhMuc(ten: string) {
    const ngan = await moCapNhat(ten);
    return within(ngan).getByRole("form", { name: `Chuyển danh mục ${ten}` });
  }

  it("chọn được danh mục khác đang hiện, theo thứ backend; chuyển cần lý do, thiếu thì không gửi", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: danhMuc(1, "Đồ uống", []) }) });
    const f = await formDanhMuc("Bánh cuốn trứng");
    const chon = within(f).getByLabelText("Danh mục mới") as HTMLSelectElement;
    expect([...chon.options].filter((o) => o.value !== "").map((o) => [o.value, o.textContent])).toEqual([["1", "Đồ uống"]]);
    fireEvent.change(chon, { target: { value: "1" } });
    go(f, "Lý do chuyển", "   ");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu danh mục" }));
    await waitFor(() => expect(oSai(f, "Lý do chuyển")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
    go(f, "Lý do chuyển", "Xếp lại menu");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu danh mục" }));
    expect(await screen.findByText("Đã chuyển Bánh cuốn trứng sang Đồ uống.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "PUT", path: "/menu-items/11/category", body: { menu_category_id: 1, reason: "Xếp lại menu" },
    }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("món chưa xếp: xếp lần đầu không hỏi lý do, thân lệnh chỉ có menu_category_id", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: danhMuc(2, "Bánh cuốn", []) }) });
    const f = await formDanhMuc("Chả quế");
    expect(within(f).queryByLabelText("Lý do chuyển")).toBeNull();
    const chon = within(f).getByLabelText("Danh mục mới") as HTMLSelectElement;
    expect([...chon.options].filter((o) => o.value !== "").map((o) => o.value)).toEqual(["2", "1"]);
    fireEvent.change(chon, { target: { value: "2" } });
    fireEvent.click(within(f).getByRole("button", { name: "Lưu danh mục" }));
    expect(await screen.findByText("Đã chuyển Chả quế sang Bánh cuốn.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "PUT", path: "/menu-items/20/category", body: { menu_category_id: 2 } }]);
  });

  it("chưa chọn danh mục: không gửi, đánh dấu ô Danh mục mới", async () => {
    const goi = moTrang();
    const f = await formDanhMuc("Bánh cuốn trứng");
    go(f, "Lý do chuyển", "thử");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu danh mục" }));
    await waitFor(() => expect(oSai(f, "Danh mục mới")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("danh mục đích vừa bị ẩn (409 menu_category_hidden): báo trong form và đọc lại danh sách", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_category_hidden" } }) });
    const f = await formDanhMuc("Bánh cuốn trứng");
    fireEvent.change(within(f).getByLabelText("Danh mục mới"), { target: { value: "1" } });
    go(f, "Lý do chuyển", "thử");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu danh mục" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/không còn dùng được/));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });
});

describe("trang sản phẩm — giá gốc thành phần", () => {
  async function formGia(mon: string, thanhPhan: string) {
    const ngan = await moCapNhat(mon);
    return within(ngan).findByRole("form", { name: `Giá gốc ${thanhPhan}` });
  }

  it("liệt kê thành phần đọc qua tính thử với tổ hợp đầu của món; có lời nhắc giá dùng chung", async () => {
    const goi = moTrang();
    const ngan = await moCapNhat("Bánh cuốn trứng");
    expect(await within(ngan).findByRole("form", { name: "Giá gốc Bánh cuốn" })).toBeTruthy();
    expect(within(ngan).getByRole("form", { name: "Giá gốc Trứng" })).toBeTruthy();
    expect(ngan.textContent ?? "").toMatch(/mọi món dùng chung thành phần này đổi giá theo/);
    const thu = goi.filter((g) => g.path === "/price-quotes");
    expect(thu).toHaveLength(1);
    expect(thu[0].body).toEqual({ lines: [{ menu_item_id: 11, quantity: 1, option_ids: [51] }] });
    // Giá gốc hiện tại điền sẵn đúng số backend trả.
    const f = within(ngan).getByRole("form", { name: "Giá gốc Bánh cuốn" });
    expect((within(f).getByLabelText("Giá gốc mới (đồng)") as HTMLInputElement).value).toBe("10000");
  });

  it("gửi đúng giá gốc chủ quán gõ và lý do, không gửi giá món; xong thì đọc lại menu, danh sách và tính thử", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: { menu_component_id: 102, base_price_vnd: 6000 } }) });
    const f = await formGia("Bánh cuốn trứng", "Trứng");
    go(f, "Giá gốc mới (đồng)", "6000");
    go(f, "Lý do đổi giá", "Trứng lên giá");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu giá" }));
    expect(await screen.findByText("Đã đổi giá gốc Trứng.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "PUT", path: "/menu-components/102/base-price", body: { base_price_vnd: 6000, reason: "Trứng lên giá" },
    }]);
    await waitFor(() => expect(soLanDocGia(goi)).toBe(2));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
    await waitFor(() => expect(soLanThu(goi)).toBe(2));
  });

  it("thiếu lý do, giá âm hoặc không nguyên: không gửi, đánh dấu đúng ô", async () => {
    const goi = moTrang();
    const f = await formGia("Bánh cuốn trứng", "Trứng");
    go(f, "Giá gốc mới (đồng)", "6000");
    go(f, "Lý do đổi giá", " ");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu giá" }));
    await waitFor(() => expect(oSai(f, "Lý do đổi giá")).toBe("true"));
    go(f, "Lý do đổi giá", "thử");
    for (const sai of ["-1", "1500.5", "abc"]) {
      go(f, "Giá gốc mới (đồng)", sai);
      fireEvent.click(within(f).getByRole("button", { name: "Lưu giá" }));
      await waitFor(() => expect(oSai(f, "Giá gốc mới (đồng)")).toBe("true"));
    }
    expect(ghi(goi)).toEqual([]);
  });

  it("lời từ chối có field base_price_vnd gắn ô Giá gốc mới", async () => {
    moTrang({ ghi: () => ({ status: 400, body: { code: "invalid_request", field: "base_price_vnd" } }) });
    const f = await formGia("Bánh cuốn trứng", "Trứng");
    go(f, "Giá gốc mới (đồng)", "6000");
    go(f, "Lý do đổi giá", "thử");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu giá" }));
    await waitFor(() => expect(oSai(f, "Giá gốc mới (đồng)")).toBe("true"));
  });

  it("bấm lưu giá hai lần liền chỉ gửi một lệnh", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: { menu_component_id: 102, base_price_vnd: 6000 } }) });
    const f = await formGia("Bánh cuốn trứng", "Trứng");
    go(f, "Giá gốc mới (đồng)", "6000");
    go(f, "Lý do đổi giá", "thử");
    const nut = within(f).getByRole("button", { name: "Lưu giá" });
    fireEvent.click(nut);
    fireEvent.click(nut);
    expect(await screen.findByText("Đã đổi giá gốc Trứng.")).toBeTruthy();
    expect(ghi(goi)).toHaveLength(1);
  });
});

describe("trang sản phẩm — ngừng bán", () => {
  async function formNgung(ten: string) {
    const ngan = await moCapNhat(ten);
    return within(ngan).getByRole("form", { name: `Ngừng bán ${ten}` });
  }

  it("thiếu lý do thì không gửi; có lý do thì gửi đúng thân, báo và đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: { menu_item_id: 11, discontinued_at: "2026-10-23T05:00:00Z" } }) });
    const f = await formNgung("Bánh cuốn trứng");
    fireEvent.click(within(f).getByRole("button", { name: "Ngừng bán" }));
    await waitFor(() => expect(oSai(f, "Lý do ngừng bán")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
    go(f, "Lý do ngừng bán", "Hết mùa");
    fireEvent.click(within(f).getByRole("button", { name: "Ngừng bán" }));
    expect(await screen.findByText("Đã ngừng bán Bánh cuốn trứng.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "POST", path: "/menu-items/11/discontinuation", body: { reason: "Hết mùa" },
    }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
    await waitFor(() => expect(soLanDocGia(goi)).toBe(2));
  });

  it("món đã ngừng bán ở backend (409 menu_item_discontinued): báo và đọc lại danh sách", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_item_discontinued" } }) });
    const f = await formNgung("Bánh cuốn trứng");
    go(f, "Lý do ngừng bán", "Hết mùa");
    fireEvent.click(within(f).getByRole("button", { name: "Ngừng bán" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/đã ngừng bán/i));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });
});

describe("T-257 — thêm thành phần", () => {
  async function moForm() {
    await moCapNhat("Bánh cuốn trứng");
    return screen.findByRole("form", { name: "Thêm thành phần" });
  }
  it("I013: cột Thành phần dùng danh mục, không tính thử lúc tải", async () => {
    const goi = moTrang();
    expect(await screen.findByText("Bánh cuốn ×3")).toBeTruthy();
    expect(screen.getAllByRole("columnheader", { name: "Thành phần" }).length).toBeGreaterThan(0);
    expect(soLanThu(goi)).toBe(0);
  });
  it("I013: chọn thành phần từ món khác, chỉ gửi id và số lượng; bấm hai lần một lệnh, xong đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 201, body: { menu_item_id: 11, menu_component_id: 103, quantity: 2 } }) });
    const f = await moForm();
    go(f, "Thành phần", "103"); go(f, "Số lượng thành phần", "2"); go(f, "Lý do thêm thành phần", "  bổ sung  ");
    fireEvent.submit(f); fireEvent.submit(f);
    await screen.findByText("Đã thêm thành phần.");
    expect(ghi(goi)).toHaveLength(1);
    expect(ghi(goi)[0]).toMatchObject({ method: "POST", path: "/menu-items/11/components", body: {
      menu_component_id: 103, quantity: 2, reason: "bổ sung",
    } });
    expect(soLanDoc(goi)).toBeGreaterThan(1); expect(soLanDocGia(goi)).toBeGreaterThan(1);
  });
  it("I018: tạo mới bắt buộc trạm và lý do, rồi gửi đúng giá gốc chủ quán nhập", async () => {
    const goi = moTrang({ ghi: () => ({ status: 201, body: { menu_item_id: 11, menu_component_id: 104, quantity: 1 } }) });
    const f = await moForm();
    go(f, "Thành phần", "new"); go(f, "Tên thành phần mới", "  Rau  "); go(f, "Giá gốc (đồng)", "2000");
    fireEvent.submit(f);
    await waitFor(() => expect(oSai(f, "Trạm")).toBe("true"));
    expect(oSai(f, "Lý do thêm thành phần")).toBe("true"); expect(ghi(goi)).toHaveLength(0);
    go(f, "Trạm", "canh"); go(f, "Lý do thêm thành phần", "thêm rau"); fireEvent.submit(f);
    await screen.findByText("Đã thêm thành phần.");
    expect(ghi(goi)[0].body).toEqual({ quantity: 1, reason: "thêm rau", component: {
      name: "Rau", base_price_vnd: 2000, takes_filling: false, station_code: "canh",
    } });
  });
  it("QC14: từ chối có field gắn đúng ô", async () => {
    const goi = moTrang({ ghi: () => ({ status: 400, body: { code: "invalid_request", field: "component.station_code" } }) });
    const f = await moForm();
    go(f, "Thành phần", "new"); go(f, "Tên thành phần mới", "Rau"); go(f, "Giá gốc (đồng)", "2000");
    go(f, "Trạm", "canh"); go(f, "Lý do thêm thành phần", "thêm rau"); fireEvent.submit(f);
    await waitFor(() => expect(oSai(f, "Trạm")).toBe("true")); expect(ghi(goi)).toHaveLength(1);
  });
});
