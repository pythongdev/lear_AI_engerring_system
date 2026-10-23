// Test hồi quy P4A-04 — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: danh sách món là đúng thứ backend trả từ GET /menu-categories, kể cả món ngừng bán và món chưa xếp; trang không
// cộng, không tính thử giá (ADR-086 — giá món do backend tính từ thành phần) — T-234 (chủ repo 2026-10-23) cho trang bày
// giá đọc từ GET /menu, đúng từng tổ hợp backend trả; sửa giá · thành phần · ngừng bán là của P4-05,
// trang này không có nút ấy; ghi chờ backend xác nhận rồi đọc lại, không ghi tay cache (ADR-102 điểm 2); đổi tên bắt
// buộc lý do; lời từ chối có field gắn đúng ô; bấm gửi hai lần chỉ gửi một lệnh (fe-02 §3).
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";

import Page from "./page";

type MenuCategoryList = components["schemas"]["MenuCategoryList"];
type MenuCategory = components["schemas"]["MenuCategory"];
type Menu = components["schemas"]["Menu"];

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
      { menu_item_id: 11, item_name: "Bánh cuốn trứng", discontinued: false },
      { menu_item_id: 10, item_name: "Bánh cuốn thịt", discontinued: true },
    ]),
    danhMuc(1, "Đồ uống", []),
  ],
  uncategorized_items: [{ menu_item_id: 20, item_name: "Chả quế", discontinued: false }],
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
    if ((g.method === "POST" && g.path === "/menu-items") || (g.method === "PUT" && g.path.startsWith("/menu-items/"))) {
      return tl.ghi ? tl.ghi(g) : { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    }
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}
const soLanDoc = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/menu-categories").length;
const soLanDocGia = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/menu").length;
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");

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

  it("đầu trang có số món; bảng có cột Món · Danh mục · Trạng thái · Giá · Thao tác", async () => {
    moTrang();
    const banhCuon = await screen.findByRole("region", { name: "Bánh cuốn" });
    expect(screen.getByRole("heading", { level: 1 }).textContent ?? "").toMatch(/Sản phẩm\s*3 món/);
    expect(within(banhCuon).getAllByRole("columnheader").map((th) => th.textContent))
      .toEqual(["Món", "Danh mục", "Trạng thái", "Giá", "Thao tác"]);
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

  it("không có nút xoá, ngừng bán hay sửa giá — phần ấy của P4-05", async () => {
    moTrang();
    await screen.findByRole("region", { name: "Bánh cuốn" });
    expect(screen.queryByRole("button", { name: /xoá|xóa|ngừng bán|giá/i })).toBeNull();
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
    const nut = await screen.findByRole("button", { name: `Đổi tên ${ten}` });
    fireEvent.click(nut);
    return screen.getByRole("form", { name: `Đổi tên ${ten}` });
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
    // Lưu xong ngăn đóng.
    expect(screen.queryByRole("form", { name: "Đổi tên Bánh cuốn trứng" })).toBeNull();
  });

  it("món ngừng bán vẫn đổi tên được", async () => {
    moTrang();
    expect(await screen.findByRole("button", { name: "Đổi tên Bánh cuốn thịt" })).toBeTruthy();
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
