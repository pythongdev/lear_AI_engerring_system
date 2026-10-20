// Test hồi quy P4-05 — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ: mọi số tiền là số backend trả — giá mỗi tổ hợp từ GET /menu, thành phần và giá gốc từ POST /price-quotes,
// phụ thu từ GET /option-groups; màn không cộng, không nhân (ADR-086, ADR-102 điểm 3). Ba lệnh sửa và lệnh ngừng
// bán bắt lý do, mở trong hộp thoại; ghi chờ backend xác nhận rồi đọc lại, không ghi tay cache (ADR-102 điểm 2);
// lời từ chối có field gắn đúng ô; bấm hai lần chỉ gửi một lệnh (fe-02 §3); focus vào hộp thoại và trả về nút mở
// (fe-04 §5); ba kiểu chỉ báo tải (fe-02 §1 · §2). Không có nút thêm món hay xoá (kế hoạch pha 4 §7).
import { act, cleanup, fireEvent, screen, waitFor, within, render } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

import Page from "./page";

type Menu = components["schemas"]["Menu"];
type PriceQuote = components["schemas"]["PriceQuote"];
type OptionGroupsAdmin = components["schemas"]["OptionGroupsAdmin"];

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/chu-quan/menu-gia",
  useSearchParams: () => new URLSearchParams(),
}));

afterEach(cleanup);

// Cố ý không theo chữ cái hay id: màn giữ thứ tự backend.
const menuMau: Menu = {
  items: [
    { menu_item_id: 2, item_name: "Chả quế", option_groups: [], prices: [{ option_ids: [], unit_price_vnd: 15000 }] },
    {
      menu_item_id: 1, item_name: "Bánh cuốn",
      option_groups: [{
        option_group_id: 5, option_group_name: "Nhân", prerequisite_option_ids: [],
        options: [
          { menu_option_id: 51, option_name: "Thịt", is_default: true },
          { menu_option_id: 52, option_name: "Chay", is_default: false },
        ],
      }],
      // Hai số không suy được từ nhau bằng phép cộng nào trên màn: màn phải bày đúng số này.
      prices: [{ option_ids: [51], unit_price_vnd: 35000 }, { option_ids: [52], unit_price_vnd: 31000 }],
    },
  ],
  combos: [],
};

function bangGia(id: number, banhCuonGia = 10000): PriceQuote {
  const line = id === 1
    ? {
      menu_item_id: 1, item_name: "Bánh cuốn", quantity: 1, unit_price_vnd: 35000, line_total_vnd: 35000,
      components: [
        { menu_component_id: 101, component_name: "Bánh cuốn", quantity: 3, takes_filling: true, base_price_vnd: banhCuonGia },
        { menu_component_id: 102, component_name: "Giò", quantity: 1, takes_filling: false, base_price_vnd: 5000 },
      ],
      options: [{ menu_option_id: 51, option_group_name: "Nhân", option_name: "Thịt", surcharge_vnd: 2000 }],
    }
    : {
      menu_item_id: 2, item_name: "Chả quế", quantity: 1, unit_price_vnd: 15000, line_total_vnd: 15000,
      components: [{ menu_component_id: 103, component_name: "Chả quế", quantity: 1, takes_filling: false, base_price_vnd: 15000 }],
      options: [],
    };
  return { lines: [line], total_vnd: line.line_total_vnd };
}

const nhomMau: OptionGroupsAdmin = {
  option_groups: [{
    option_group_id: 5, name: "Nhân", menu_item_ids: [1], prerequisite_option_ids: [],
    options: [
      { menu_option_id: 51, name: "Thịt", surcharge_vnd: 2000, is_default: true, hidden_at: null },
      { menu_option_id: 52, name: "Chay", surcharge_vnd: 0, is_default: false, hidden_at: null },
      { menu_option_id: 53, name: "Tôm", surcharge_vnd: 7000, is_default: false, hidden_at: "2026-10-18T02:00:00Z" },
    ],
  }],
};

type Goi = { method: string; path: string; body: unknown };
type TraLoi = { status: number; body?: unknown } | "mat-mang";
type Tl = TraLoi | Promise<TraLoi>;
type XuLy = {
  menu?: (lan: number) => Tl;
  nhom?: (lan: number) => Tl;
  thu?: (menuItemId: number, lan: number) => Tl;
  ghi?: (g: Goi) => Tl;
};

function moTrang(x: XuLy = {}) {
  const goi: Goi[] = [];
  const dem = { menu: 0, nhom: 0, thu: 0 };
  const fetch = async (req: Request) => {
    const text = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: TraLoi;
    if (g.method === "GET" && g.path === "/menu") {
      dem.menu += 1;
      r = await (x.menu ? x.menu(dem.menu) : { status: 200, body: menuMau });
    } else if (g.method === "GET" && g.path === "/option-groups") {
      dem.nhom += 1;
      r = await (x.nhom ? x.nhom(dem.nhom) : { status: 200, body: nhomMau });
    } else if (g.method === "POST" && g.path === "/price-quotes") {
      dem.thu += 1;
      const id = (g.body as { lines: { menu_item_id: number }[] }).lines[0].menu_item_id;
      r = await (x.thu ? x.thu(id, dem.thu) : { status: 200, body: bangGia(id) });
    } else if (g.method !== "GET") {
      r = await (x.ghi ? x.ghi(g) : { status: 599, body: { code: "khong_co_trong_hop_dong" } });
    } else {
      r = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    }
    if (r === "mat-mang") throw new TypeError("fetch failed");
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), {
      status: r.status, headers: { "content-type": "application/json" },
    });
  };
  render(<ApiProvider fetch={fetch}>{<Page />}</ApiProvider>);
  return goi;
}

function hoan<T>() {
  let tra!: (v: T) => void;
  const p = new Promise<T>((r) => { tra = r; });
  return { p, tra };
}

const dem = (g: Goi[], method: string, path: string) => g.filter((x) => x.method === method && x.path === path).length;
const ghiDi = (g: Goi[]) => g.filter((x) => x.method === "PUT" || (x.method === "POST" && x.path !== "/price-quotes"));
const mon = (ten: string) => screen.findByRole("region", { name: ten });
const nhom = (ten: string) => screen.findByRole("region", { name: `Nhóm ${ten}` });

async function moHop(vung: HTMLElement, nut: string) {
  const b = await within(vung).findByRole("button", { name: nut });
  b.focus();
  fireEvent.click(b);
  return { nut: b, hop: await screen.findByRole("dialog") };
}
function go(hop: HTMLElement, nhan: string, giaTri: string) {
  fireEvent.change(within(hop).getByLabelText(nhan), { target: { value: giaTri } });
}
const bam = (hop: HTMLElement, nhan: string) => fireEvent.click(within(hop).getByRole("button", { name: nhan }));

describe("menu & giá — đọc", () => {
  it("bày món đúng thứ GET /menu; giá mỗi tổ hợp là số backend, nhãn là tên lựa chọn", async () => {
    moTrang();
    const cha = await mon("Chả quế");
    const banh = await mon("Bánh cuốn");
    expect(cha.compareDocumentPosition(banh) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    const gia = within(banh).getByRole("list", { name: "Giá bán" });
    const dong = within(gia).getAllByRole("listitem").map((li) => li.textContent ?? "");
    expect(dong).toHaveLength(2);
    expect(dong[0]).toContain("Thịt");
    expect(dong[0]).toContain("35.000đ");
    expect(dong[1]).toContain("Chay");
    expect(dong[1]).toContain("31.000đ");
    expect(within(within(cha).getByRole("list", { name: "Giá bán" })).getByRole("listitem").textContent).toContain("15.000đ");
  });

  it("thành phần đọc từ POST /price-quotes của từng món — một dòng, số lượng 1, tổ hợp đầu tiên backend kê", async () => {
    const goi = moTrang();
    const banh = await mon("Bánh cuốn");
    const tp = await within(banh).findByRole("list", { name: "Thành phần" });
    const dong = within(tp).getAllByRole("listitem").map((li) => li.textContent ?? "");
    expect(dong[0]).toContain("Bánh cuốn");
    expect(dong[0]).toContain("× 3");
    expect(dong[0]).toContain("10.000đ");
    expect(dong[1]).toContain("Giò");
    expect(dong[1]).toContain("5.000đ");
    const thu = goi.filter((g) => g.path === "/price-quotes").map((g) => g.body);
    expect(thu).toHaveLength(2);
    expect(thu).toContainEqual({ lines: [{ menu_item_id: 1, quantity: 1, option_ids: [51] }] });
    expect(thu).toContainEqual({ lines: [{ menu_item_id: 2, quantity: 1, option_ids: [] }] });
  });

  it("phụ thu đọc từ GET /option-groups; lựa chọn đã ẩn có nhãn", async () => {
    moTrang();
    const n = await nhom("Nhân");
    const dong = within(n).getAllByRole("listitem").map((li) => li.textContent ?? "");
    expect(dong[0]).toContain("Thịt");
    expect(dong[0]).toContain("2.000đ");
    expect(dong[1]).toContain("0đ");
    expect(dong[2]).toContain("Tôm");
    expect(dong[2]).toContain("Đã ẩn");
    expect(dong[0]).not.toContain("Đã ẩn");
  });

  it("không có nút thêm món hay xoá — không có cửa", async () => {
    moTrang();
    await mon("Bánh cuốn");
    expect(screen.queryByRole("button", { name: /thêm món|xoá|xóa/i })).toBeNull();
  });

  it("lần đọc đầu: bày khung xương 'Đang tải menu…', chưa có món", async () => {
    const cho = hoan<TraLoi>();
    moTrang({ menu: () => cho.p });
    expect(await screen.findByText("Đang tải menu…")).toBeTruthy();
    expect(screen.queryByRole("region", { name: "Bánh cuốn" })).toBeNull();
    await act(async () => cho.tra({ status: 200, body: menuMau }));
    expect(await mon("Bánh cuốn")).toBeTruthy();
    expect(screen.queryByText("Đang tải menu…")).toBeNull();
  });

  it("đọc menu lỗi: báo không đọc được, không có nút sửa nào", async () => {
    moTrang({ menu: () => ({ status: 500, body: { code: "internal_error" } }) });
    await waitFor(() => expect(screen.getByRole("alert").textContent ?? "").toMatch(/Chưa đọc được menu/));
    expect(screen.queryByRole("button", { name: /Đổi giá gốc|Đổi số lượng|Ngừng bán/ })).toBeNull();
  });

  it("tính thử một món lỗi: món ấy báo chưa đọc được thành phần, món khác vẫn đủ", async () => {
    moTrang({ thu: (id) => id === 1 ? { status: 409, body: { code: "menu_item_discontinued" } } : { status: 200, body: bangGia(id) } });
    const banh = await mon("Bánh cuốn");
    expect(await within(banh).findByText(/Chưa đọc được thành phần/)).toBeTruthy();
    expect(within(banh).queryByRole("button", { name: /Đổi giá gốc/ })).toBeNull();
    const cha = await mon("Chả quế");
    expect(await within(cha).findByRole("button", { name: "Đổi giá gốc Chả quế" })).toBeTruthy();
  });
});

describe("menu & giá — đổi giá gốc", () => {
  it("hộp thoại nhận focus, điền sẵn giá hiện tại; gửi đúng thân; xong thì đóng, trả focus, báo, đọc lại và bày số mới", async () => {
    const goi = moTrang({
      thu: (id, lan) => ({ status: 200, body: bangGia(id, lan > 2 ? 12000 : 10000) }),
      ghi: () => ({ status: 200, body: { menu_component_id: 101, base_price_vnd: 12000 } }),
    });
    const banh = await mon("Bánh cuốn");
    const { nut, hop } = await moHop(banh, "Đổi giá gốc Bánh cuốn");
    expect(hop.getAttribute("aria-labelledby")).toBeTruthy();
    expect(within(hop).getByRole("heading", { name: "Đổi giá gốc Bánh cuốn" })).toBeTruthy();
    await waitFor(() => expect(hop.contains(document.activeElement)).toBe(true));
    expect((within(hop).getByLabelText("Giá gốc mới (đồng)") as HTMLInputElement).value).toBe("10000");
    const menuTruoc = dem(goi, "GET", "/menu");
    go(hop, "Giá gốc mới (đồng)", "12000");
    go(hop, "Lý do", "  giá bột tăng  ");
    bam(hop, "Lưu");

    expect(await screen.findByText("Đã đổi giá gốc Bánh cuốn.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{
      method: "PUT", path: "/menu-components/101/base-price", body: { base_price_vnd: 12000, reason: "giá bột tăng" },
    }]);
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await waitFor(() => expect(document.activeElement).toBe(nut));
    await waitFor(() => expect(dem(goi, "GET", "/menu")).toBeGreaterThan(menuTruoc));
    // Số mới là số backend trả ở lần đọc lại, không phải số vừa gõ được ghi vào màn.
    const tp = within(await mon("Bánh cuốn")).getByRole("list", { name: "Thành phần" });
    await waitFor(() => expect(within(tp).getAllByRole("listitem")[0].textContent).toContain("12.000đ"));
  });

  it("thiếu lý do: không gửi; ô lý do aria-invalid và aria-describedby trỏ tới lời lỗi", async () => {
    const goi = moTrang();
    const { hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    go(hop, "Giá gốc mới (đồng)", "12000");
    go(hop, "Lý do", "   ");
    bam(hop, "Lưu");
    const o = within(hop).getByLabelText("Lý do");
    await waitFor(() => expect(o.getAttribute("aria-invalid")).toBe("true"));
    const loi = document.getElementById(o.getAttribute("aria-describedby") ?? "");
    expect(loi?.textContent).toMatch(/Nhập lý do/);
    expect(ghiDi(goi)).toEqual([]);
  });

  it.each(["12.5", "-1", "abc", "", "12 000"])("giá '%s' không phải số đồng nguyên không âm: không gửi, lỗi ở ô giá", async (v) => {
    const goi = moTrang();
    const { hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    go(hop, "Giá gốc mới (đồng)", v);
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    await waitFor(() => expect(within(hop).getByLabelText("Giá gốc mới (đồng)").getAttribute("aria-invalid")).toBe("true"));
    expect(ghiDi(goi)).toEqual([]);
  });

  it("lời từ chối có field gắn đúng ô: reason ⇒ ô lý do, base_price_vnd ⇒ ô giá", async () => {
    let field = "reason";
    moTrang({ ghi: () => ({ status: 400, body: { code: "invalid_request", message: "x", field } }) });
    let { hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    await waitFor(() => expect(within(hop).getByLabelText("Lý do").getAttribute("aria-invalid")).toBe("true"));
    expect(within(hop).getByLabelText("Giá gốc mới (đồng)").getAttribute("aria-invalid")).not.toBe("true");
    bam(hop, "Huỷ");
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    field = "base_price_vnd";
    ({ hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn"));
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    await waitFor(() => expect(within(hop).getByLabelText("Giá gốc mới (đồng)").getAttribute("aria-invalid")).toBe("true"));
  });

  it("thành phần không còn (404): báo trong hộp thoại và đọc lại menu", async () => {
    const goi = moTrang({ ghi: () => ({ status: 404, body: { code: "menu_component_not_found", message: "x" } }) });
    const { hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    const truoc = dem(goi, "GET", "/menu");
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    expect(await within(hop).findByText(/không còn/i)).toBeTruthy();
    await waitFor(() => expect(dem(goi, "GET", "/menu")).toBeGreaterThan(truoc));
  });

  it("mất phản hồi: nói chưa rõ kết quả, không tự gửi lại", async () => {
    const goi = moTrang({ ghi: () => "mat-mang" });
    const { hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    expect(await within(hop).findByText(/Chưa xác nhận được kết quả/)).toBeTruthy();
    await new Promise((r) => setTimeout(r, 50));
    expect(ghiDi(goi)).toHaveLength(1);
  });

  it("bấm Lưu hai lần: một lệnh; nút tắt và báo đang lưu khi chờ", async () => {
    const cho = hoan<TraLoi>();
    const goi = moTrang({ ghi: () => cho.p });
    const { hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    fireEvent.click(within(hop).getByRole("button", { name: /Lưu|Đang lưu/ }));
    const nut = await within(hop).findByRole("button", { name: "Đang lưu…" });
    expect((nut as HTMLButtonElement).disabled).toBe(true);
    await act(async () => cho.tra({ status: 200, body: { menu_component_id: 101, base_price_vnd: 10000 } }));
    expect(ghiDi(goi)).toHaveLength(1);
  });

  it("Huỷ và phím Escape đóng hộp thoại, trả focus về nút mở, không gửi gì", async () => {
    const goi = moTrang();
    let { nut, hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    bam(hop, "Huỷ");
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await waitFor(() => expect(document.activeElement).toBe(nut));
    ({ nut, hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn"));
    fireEvent.keyDown(hop, { key: "Escape" });
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await waitFor(() => expect(document.activeElement).toBe(nut));
    expect(ghiDi(goi)).toEqual([]);
  });

  it("đang đọc lại sau ghi: giữ bản cũ kèm chỉ báo nhỏ 'Đang cập nhật…'", async () => {
    const cho = hoan<TraLoi>();
    moTrang({
      menu: (lan) => lan === 1 ? { status: 200, body: menuMau } : cho.p,
      ghi: () => ({ status: 200, body: { menu_component_id: 101, base_price_vnd: 12000 } }),
    });
    const { hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    expect(await screen.findByText("Đang cập nhật…")).toBeTruthy();
    expect(screen.getByRole("region", { name: "Bánh cuốn" })).toBeTruthy();
    await act(async () => cho.tra({ status: 200, body: menuMau }));
    await waitFor(() => expect(screen.queryByText("Đang cập nhật…")).toBeNull());
  });

  it("ghi xong mà đọc lại lỗi: nói đã lưu nhưng chưa đọc lại được, không mời gửi lại", async () => {
    moTrang({
      menu: (lan) => lan === 1 ? { status: 200, body: menuMau } : { status: 500, body: { code: "internal_error" } },
      ghi: () => ({ status: 200, body: { menu_component_id: 101, base_price_vnd: 12000 } }),
    });
    const { hop } = await moHop(await mon("Bánh cuốn"), "Đổi giá gốc Bánh cuốn");
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    expect(await screen.findByText(/Đã lưu nhưng chưa đọc lại được/)).toBeTruthy();
  });
});

describe("menu & giá — phụ thu, số lượng thành phần, ngừng bán", () => {
  it("đổi phụ thu: PUT /menu-options/{id}/surcharge đúng thân, rồi đọc lại /option-groups và /menu", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: { menu_option_id: 51, surcharge_vnd: 3000 } }) });
    const { hop } = await moHop(await nhom("Nhân"), "Đổi phụ thu Thịt");
    expect((within(hop).getByLabelText("Phụ thu mới (đồng)") as HTMLInputElement).value).toBe("2000");
    const truoc = { nhom: dem(goi, "GET", "/option-groups"), menu: dem(goi, "GET", "/menu") };
    go(hop, "Phụ thu mới (đồng)", "3000");
    go(hop, "Lý do", "thịt tăng giá");
    bam(hop, "Lưu");
    expect(await screen.findByText("Đã đổi phụ thu Thịt.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "PUT", path: "/menu-options/51/surcharge", body: { surcharge_vnd: 3000, reason: "thịt tăng giá" } }]);
    await waitFor(() => {
      expect(dem(goi, "GET", "/option-groups")).toBeGreaterThan(truoc.nhom);
      expect(dem(goi, "GET", "/menu")).toBeGreaterThan(truoc.menu);
    });
  });

  it("đổi số lượng thành phần: luôn nhắc giờ bán; PUT đúng đường và thân; số lượng < 1 không gửi", async () => {
    const goi = moTrang({ ghi: () => ({ status: 200, body: { menu_item_id: 1, menu_component_id: 101, quantity: 4 } }) });
    const { hop } = await moHop(await mon("Bánh cuốn"), "Đổi số lượng Bánh cuốn");
    expect(within(hop).getByText(/giờ bán/)).toBeTruthy();
    expect((within(hop).getByLabelText("Số lượng mới") as HTMLInputElement).value).toBe("3");
    go(hop, "Số lượng mới", "0");
    go(hop, "Lý do", "suất to hơn");
    bam(hop, "Lưu");
    await waitFor(() => expect(within(hop).getByLabelText("Số lượng mới").getAttribute("aria-invalid")).toBe("true"));
    expect(ghiDi(goi)).toEqual([]);
    go(hop, "Số lượng mới", "4");
    bam(hop, "Lưu");
    expect(await screen.findByText("Đã đổi số lượng Bánh cuốn.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "PUT", path: "/menu-items/1/components/101", body: { quantity: 4, reason: "suất to hơn" } }]);
  });

  it("ngừng bán: bắt lý do, POST discontinuation, đọc lại và món biến khỏi màn", async () => {
    const goi = moTrang({
      menu: (lan) => ({ status: 200, body: lan === 1 ? menuMau : { ...menuMau, items: menuMau.items.filter((i) => i.menu_item_id !== 2) } }),
      ghi: () => ({ status: 200, body: { menu_item_id: 2, discontinued_at: "2026-10-20T03:00:00Z" } }),
    });
    const { hop } = await moHop(await mon("Chả quế"), "Ngừng bán Chả quế");
    bam(hop, "Ngừng bán");
    await waitFor(() => expect(within(hop).getByLabelText("Lý do").getAttribute("aria-invalid")).toBe("true"));
    expect(ghiDi(goi)).toEqual([]);
    go(hop, "Lý do", "hết chả");
    bam(hop, "Ngừng bán");
    expect(await screen.findByText("Đã ngừng bán Chả quế.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/menu-items/2/discontinuation", body: { reason: "hết chả" } }]);
    await waitFor(() => expect(screen.queryByRole("region", { name: "Chả quế" })).toBeNull());
  });

  it("ngừng bán món đã ngừng (409): báo và đọc lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 409, body: { code: "menu_item_discontinued", message: "x" } }) });
    const { hop } = await moHop(await mon("Chả quế"), "Ngừng bán Chả quế");
    const truoc = dem(goi, "GET", "/menu");
    go(hop, "Lý do", "hết chả");
    bam(hop, "Ngừng bán");
    expect(await within(hop).findByText(/đã ngừng bán/i)).toBeTruthy();
    await waitFor(() => expect(dem(goi, "GET", "/menu")).toBeGreaterThan(truoc));
  });

  it("không phải chủ quán (403 owner_only): bày lời backend, không gửi lại", async () => {
    const goi = moTrang({ ghi: () => ({ status: 403, body: { code: "owner_only", message: "x" } }) });
    const { hop } = await moHop(await nhom("Nhân"), "Đổi phụ thu Chay");
    go(hop, "Lý do", "đổi");
    bam(hop, "Lưu");
    expect(await within(hop).findByText(/Chỉ chủ quán/)).toBeTruthy();
    expect(ghiDi(goi)).toHaveLength(1);
  });
});
