// Test hồi quy P4A-05 (danh mục) — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: danh mục và món là đúng thứ backend trả từ GET /menu-categories (cùng khoá query với trang Sản phẩm); trang
// không gieo sẵn nhóm nào — chủ quán tự đặt (P4A-05 "Không lấy từ PAGES_INDEX"); không có nút xoá — ẩn có lý do, món
// về "Chưa xếp danh mục"; đổi tên và chuyển món từ danh mục khác bắt buộc lý do, xếp món chưa có danh mục thì không gửi
// lý do (hợp đồng PUT /menu-items/{id}/category); ghi chờ backend xác nhận rồi đọc lại, không ghi tay cache (ADR-102
// điểm 2); lời từ chối gắn đúng ô; bấm gửi hai lần chỉ gửi một lệnh (fe-02 §3).
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";

import Page from "./page";

type MenuCategoryList = components["schemas"]["MenuCategoryList"];
type MenuCategory = components["schemas"]["MenuCategory"];

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/chu-quan/danh-muc",
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
      { menu_item_id: 11, item_name: "Bánh cuốn trứng", discontinued: false, components: [] },
      { menu_item_id: 10, item_name: "Bánh cuốn thịt", discontinued: true, components: [] },
    ]),
    danhMuc(1, "Đồ uống", []),
  ],
  uncategorized_items: [{ menu_item_id: 20, item_name: "Chả quế", discontinued: false, components: [] }],
};

type TraLoi = { status: number; body?: unknown };
function moTrang(tl: { doc?: (lan: number) => TraLoi; ghi?: (g: GoiDen) => TraLoi } = {}) {
  let lan = 0;
  return voiBackend(<Page />, (g) => {
    if (g.method === "GET" && g.path === "/menu-categories") {
      lan += 1;
      return tl.doc ? tl.doc(lan) : { status: 200, body: mau };
    }
    if (g.method !== "GET") return tl.ghi ? tl.ghi(g) : { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    return { status: 599, body: { code: "khong_co_trong_hop_dong" } };
  });
}
const soLanDoc = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/menu-categories").length;
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");

function go(o: HTMLElement, nhan: string, giaTri: string) {
  fireEvent.change(within(o).getByLabelText(nhan), { target: { value: giaTri } });
}
const oSai = (o: HTMLElement, nhan: string) => within(o).getByLabelText(nhan).getAttribute("aria-invalid");
async function mo(nhanNut: string) {
  fireEvent.click(await screen.findByRole("button", { name: nhanNut }));
  return screen.getByRole("form", { name: nhanNut });
}
const danhMucMau = (b: MenuCategory) => ({ ...b, items: [] });

describe("trang danh mục — danh sách", () => {
  it("bày danh mục và món đúng thứ backend, kể cả món ngừng bán và món chưa xếp; chỉ đọc /menu-categories", async () => {
    const goi = moTrang();
    const banhCuon = await screen.findByRole("region", { name: "Bánh cuốn" });
    const ten = within(banhCuon).getAllByRole("listitem").map((li) => li.textContent ?? "");
    expect(ten).toHaveLength(2);
    expect(ten[0]).toContain("Bánh cuốn trứng");
    expect(ten[1]).toContain("Bánh cuốn thịt");
    expect(ten[1]).toContain("Ngừng bán");
    const doUong = screen.getByRole("region", { name: "Đồ uống" });
    expect(within(doUong).getByText(/Chưa có món/)).toBeTruthy();
    expect(banhCuon.compareDocumentPosition(doUong) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(within(screen.getByRole("region", { name: "Chưa xếp danh mục" })).getByText(/Chả quế/)).toBeTruthy();
    expect(goi.map((g) => `${g.method} ${g.path}`)).toEqual(["GET /menu-categories"]);
  });

  it("không có nút xoá; nhóm Chưa xếp danh mục không đổi tên hay ẩn được", async () => {
    moTrang();
    await screen.findByRole("region", { name: "Bánh cuốn" });
    expect(screen.queryByRole("button", { name: /xoá|xóa/i })).toBeNull();
    expect(screen.queryByRole("button", { name: /Chưa xếp danh mục/ })).toBeNull();
  });

  it("chưa có danh mục: không gieo sẵn nhóm nào, vẫn cho thêm danh mục", async () => {
    moTrang({ doc: () => ({ status: 200, body: { categories: [], uncategorized_items: [] } }) });
    expect(await screen.findByText(/Chưa có danh mục/)).toBeTruthy();
    expect(screen.getByRole("form", { name: "Thêm danh mục" })).toBeTruthy();
    // Vùng duy nhất được phép là nhóm "Chưa xếp danh mục" — không danh mục nào trang tự bày.
    const vung = screen.queryAllByRole("region").map((r) => within(r).queryByRole("heading")?.textContent);
    expect(vung.filter((t) => t !== "Chưa xếp danh mục")).toEqual([]);
  });

  it("đọc lỗi: báo không đọc được, không bày form", async () => {
    moTrang({ doc: () => ({ status: 500, body: { code: "internal_error" } }) });
    await waitFor(() => expect(screen.getByRole("alert").textContent ?? "").toMatch(/Chưa đọc được danh mục/));
    expect(screen.queryByRole("form", { name: "Thêm danh mục" })).toBeNull();
  });
});

describe("trang danh mục — thêm", () => {
  it("gửi đúng thân hợp đồng; xong báo theo tên backend trả, đọc lại, xoá ô", async () => {
    const goi = moTrang({ ghi: () => ({ status: 201, body: danhMucMau(danhMuc(3, "Món thêm", [])) }) });
    const f = await screen.findByRole("form", { name: "Thêm danh mục" });
    go(f, "Tên danh mục", "  Món thêm ");
    fireEvent.click(within(f).getByRole("button", { name: "Thêm danh mục" }));
    expect(await screen.findByText("Đã thêm danh mục Món thêm.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "POST", path: "/menu-categories", body: { name: "Món thêm" } }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
    expect((within(f).getByLabelText("Tên danh mục") as HTMLInputElement).value).toBe("");
  });

  it("tên rỗng: không gửi, đánh dấu ô", async () => {
    const goi = moTrang();
    const f = await screen.findByRole("form", { name: "Thêm danh mục" });
    go(f, "Tên danh mục", "   ");
    fireEvent.click(within(f).getByRole("button", { name: "Thêm danh mục" }));
    await waitFor(() => expect(oSai(f, "Tên danh mục")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("tên trùng (409 menu_category_name_taken): lỗi gắn ô Tên danh mục, giữ chữ đã nhập", async () => {
    moTrang({ ghi: () => ({ status: 409, body: { code: "menu_category_name_taken" } }) });
    const f = await screen.findByRole("form", { name: "Thêm danh mục" });
    go(f, "Tên danh mục", "Đồ uống");
    fireEvent.click(within(f).getByRole("button", { name: "Thêm danh mục" }));
    await waitFor(() => expect(oSai(f, "Tên danh mục")).toBe("true"));
    expect(f.textContent ?? "").toMatch(/trùng/);
    expect((within(f).getByLabelText("Tên danh mục") as HTMLInputElement).value).toBe("Đồ uống");
  });

  it("phản hồi lạ: nói chưa xác nhận được kết quả, không tự gửi lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 500, body: { khong: "phai Error" } }) });
    const f = await screen.findByRole("form", { name: "Thêm danh mục" });
    go(f, "Tên danh mục", "Món thêm");
    fireEvent.click(within(f).getByRole("button", { name: "Thêm danh mục" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/chưa xác nhận được kết quả/i));
    expect(ghi(goi)).toHaveLength(1);
  });

  it("bấm gửi hai lần liền chỉ gửi một lệnh", async () => {
    const goi = moTrang({ ghi: () => ({ status: 201, body: danhMucMau(danhMuc(3, "Món thêm", [])) }) });
    const f = await screen.findByRole("form", { name: "Thêm danh mục" });
    go(f, "Tên danh mục", "Món thêm");
    const nut = within(f).getByRole("button", { name: "Thêm danh mục" });
    fireEvent.click(nut);
    fireEvent.click(nut);
    expect(await screen.findByText("Đã thêm danh mục Món thêm.")).toBeTruthy();
    expect(ghi(goi)).toHaveLength(1);
  });
});

describe("trang danh mục — đổi tên và ẩn", () => {
  it("đổi tên: tên cũ điền sẵn; thiếu lý do thì không gửi", async () => {
    const goi = moTrang();
    const f = await mo("Đổi tên danh mục Bánh cuốn");
    expect((within(f).getByLabelText("Tên mới") as HTMLInputElement).value).toBe("Bánh cuốn");
    go(f, "Lý do", "  ");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu tên" }));
    await waitFor(() => expect(oSai(f, "Lý do")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("đổi tên: gửi tên và lý do tới đúng danh mục, báo theo tên backend trả, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: danhMucMau(danhMuc(2, "Bánh cuốn nóng", [])) }) });
    const f = await mo("Đổi tên danh mục Bánh cuốn");
    go(f, "Tên mới", "Bánh cuốn nóng");
    go(f, "Lý do", "Rõ hơn");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu tên" }));
    expect(await screen.findByText("Đã đổi tên danh mục thành Bánh cuốn nóng.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "PUT", path: "/menu-categories/2", body: { name: "Bánh cuốn nóng", reason: "Rõ hơn" },
    }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("đổi tên trùng (409): lỗi gắn ô Tên mới", async () => {
    moTrang({ ghi: () => ({ status: 409, body: { code: "menu_category_name_taken" } }) });
    const f = await mo("Đổi tên danh mục Đồ uống");
    go(f, "Tên mới", "Bánh cuốn");
    go(f, "Lý do", "thử");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu tên" }));
    await waitFor(() => expect(oSai(f, "Tên mới")).toBe("true"));
  });

  it("danh mục vừa bị ẩn ở nơi khác (409 menu_category_hidden): báo và đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_category_hidden" } }) });
    const f = await mo("Đổi tên danh mục Đồ uống");
    go(f, "Tên mới", "Nước");
    go(f, "Lý do", "thử");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu tên" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/không còn dùng được/));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("ẩn: nói rõ món sẽ về Chưa xếp danh mục; bắt buộc lý do; gửi đúng thân, đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: { ...danhMucMau(danhMuc(2, "Bánh cuốn", [])), hidden_at: "2026-10-19T01:00:00Z" } }) });
    const f = await mo("Ẩn danh mục Bánh cuốn");
    expect(f.textContent ?? "").toMatch(/Chưa xếp danh mục/);
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận ẩn" }));
    await waitFor(() => expect(oSai(f, "Lý do")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
    go(f, "Lý do", "Gộp nhóm");
    fireEvent.click(within(f).getByRole("button", { name: "Xác nhận ẩn" }));
    expect(await screen.findByText("Đã ẩn danh mục Bánh cuốn.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "POST", path: "/menu-categories/2/hiding", body: { reason: "Gộp nhóm" } }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });
});

describe("trang danh mục — xếp và chuyển món", () => {
  it("món chưa xếp: chọn danh mục đích, lý do để trống thì thân chỉ có menu_category_id; đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: danhMucMau(danhMuc(1, "Đồ uống", [])) }) });
    const f = await mo("Xếp danh mục Chả quế");
    const chon = within(f).getByLabelText("Danh mục đích") as HTMLSelectElement;
    expect([...chon.options].filter((o) => o.value !== "").map((o) => [o.value, o.textContent]))
      .toEqual([["2", "Bánh cuốn"], ["1", "Đồ uống"]]);
    fireEvent.change(chon, { target: { value: "1" } });
    fireEvent.click(within(f).getByRole("button", { name: "Lưu" }));
    expect(await screen.findByText("Đã xếp Chả quế vào Đồ uống.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{ method: "PUT", path: "/menu-items/20/category", body: { menu_category_id: 1 } }]);
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  // Món của danh mục đã ẩn cũng nằm ở "Chưa xếp danh mục" nhưng dòng xếp cũ còn, nên backend coi là chuyển và đòi lý
  // do (PUT /menu-items/{id}/category; chạy thật 2026-10-19 trả 400 field=reason). Phản hồi đọc không phân biệt hai
  // trường hợp ⇒ món chưa xếp luôn có ô Lý do không bắt buộc, và lời đòi lý do gắn vào ô ấy.
  it("món chưa xếp thuộc danh mục đã ẩn (400 field=reason): lỗi gắn ô Lý do; điền rồi gửi kèm lý do", async () => {
    let lan = 0;
    const goi = moTrang({ ghi: () => (++lan === 1
      ? { status: 400, body: { code: "invalid_request", field: "reason" } }
      : { status: 200, body: danhMucMau(danhMuc(1, "Đồ uống", [])) }) });
    const f = await mo("Xếp danh mục Chả quế");
    fireEvent.change(within(f).getByLabelText("Danh mục đích"), { target: { value: "1" } });
    fireEvent.click(within(f).getByRole("button", { name: "Lưu" }));
    await waitFor(() => expect(oSai(f, "Lý do")).toBe("true"));
    go(f, "Lý do", "Danh mục cũ đã ẩn");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu" }));
    expect(await screen.findByText("Đã xếp Chả quế vào Đồ uống.")).toBeTruthy();
    expect(ghi(goi)).toEqual([
      { method: "PUT", path: "/menu-items/20/category", body: { menu_category_id: 1 } },
      { method: "PUT", path: "/menu-items/20/category", body: { menu_category_id: 1, reason: "Danh mục cũ đã ẩn" } },
    ]);
  });

  it("món đã có danh mục: đích không gồm danh mục hiện tại; bắt buộc lý do; gửi kèm lý do", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: danhMucMau(danhMuc(1, "Đồ uống", [])) }) });
    const f = await mo("Chuyển danh mục Bánh cuốn trứng");
    const chon = within(f).getByLabelText("Danh mục đích") as HTMLSelectElement;
    expect([...chon.options].filter((o) => o.value !== "").map((o) => o.value)).toEqual(["1"]);
    fireEvent.change(chon, { target: { value: "1" } });
    fireEvent.click(within(f).getByRole("button", { name: "Lưu" }));
    await waitFor(() => expect(oSai(f, "Lý do")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
    go(f, "Lý do", "Xếp lại");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu" }));
    expect(await screen.findByText("Đã chuyển Bánh cuốn trứng sang Đồ uống.")).toBeTruthy();
    expect(ghi(goi)).toEqual([{
      method: "PUT", path: "/menu-items/11/category", body: { menu_category_id: 1, reason: "Xếp lại" },
    }]);
  });

  it("chưa chọn đích: không gửi, đánh dấu ô Danh mục đích", async () => {
    const goi = moTrang();
    const f = await mo("Xếp danh mục Chả quế");
    fireEvent.click(within(f).getByRole("button", { name: "Lưu" }));
    await waitFor(() => expect(oSai(f, "Danh mục đích")).toBe("true"));
    expect(ghi(goi)).toEqual([]);
  });

  it("đích vừa bị ẩn (409 menu_category_hidden): báo và đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_category_hidden" } }) });
    const f = await mo("Xếp danh mục Chả quế");
    fireEvent.change(within(f).getByLabelText("Danh mục đích"), { target: { value: "1" } });
    fireEvent.click(within(f).getByRole("button", { name: "Lưu" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/không còn dùng được/));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });

  it("món đã ở đích (409 menu_item_already_in_category): báo và đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_item_already_in_category" } }) });
    const f = await mo("Xếp danh mục Chả quế");
    fireEvent.change(within(f).getByLabelText("Danh mục đích"), { target: { value: "1" } });
    fireEvent.click(within(f).getByRole("button", { name: "Lưu" }));
    await waitFor(() => expect(f.textContent ?? "").toMatch(/đã ở danh mục này/));
    await waitFor(() => expect(soLanDoc(goi)).toBe(2));
  });
});
