// Dữ liệu mẫu và backend giả cho test màn khách P4-10 (khach-qr.test.tsx · dat-mon.test.tsx) — Claude viết TRƯỚC khi có code.
// Người thi công KHÔNG sửa file này. Ba câu là nguyên văn master_plan/shop-facts.md §6.8 · §6.11 (chủ repo chọn 2026-10-21).
import { vi } from "vitest";

export const CAU_TAM_DUNG = "Quán đang tạm dừng nhận đơn. Bạn vui lòng quay lại sau ít phút hoặc gọi hotline 0382688666 để đặt.";
export const CAU_MAT_KET_NOI = "Quán tạm chưa nhận đơn qua web. Bạn vui lòng gọi hotline 0382688666 để đặt.";
export const CAU_NGOAI_GIO = "Quán mở cửa 6h–11h sáng";

export const menuMau = {
  items: [
    { menu_item_id: 1, item_name: "Bánh cuốn", option_groups: [
      { option_group_id: 5, option_group_name: "Nhân", prerequisite_option_ids: [], options: [
        { menu_option_id: 11, option_name: "Thịt", is_default: true }, { menu_option_id: 12, option_name: "Chay", is_default: false }] },
      { option_group_id: 6, option_group_name: "Lượng nhân", prerequisite_option_ids: [11], options: [
        { menu_option_id: 21, option_name: "Thường", is_default: true }, { menu_option_id: 22, option_name: "Nhiều", is_default: false }] },
    ], prices: [{ option_ids: [11, 21], unit_price_vnd: 35000 }, { option_ids: [11, 22], unit_price_vnd: 40000 }, { option_ids: [12], unit_price_vnd: 30000 }] },
    { menu_item_id: 2, item_name: "Canh", option_groups: [], prices: [{ option_ids: [], unit_price_vnd: 10000 }] },
  ],
  combos: [],
};

export type Goi = { method: string; path: string; body: Record<string, unknown> | undefined };
export type TraLoi = { status: number; body?: unknown } | "mat-mang";
export type Ghi = (g: Goi, lan: number) => TraLoi | Promise<TraLoi>;
type Dap = { status: number; body?: unknown };
const tra = (r: Dap) => new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });

export const baoGia = (tong: number): Dap => ({ status: 200, body: { lines: [], total_vnd: tong } });
// Tổng tính thử theo NỘI DUNG giỏ, cố ý KHÁC mọi phép cộng giá trong menu: màn phải bày đúng số backend trả.
export const tinhTheoGio: Ghi = (g) => {
  const lines = (g.body?.lines ?? []) as { quantity: number }[];
  return baoGia(lines.length === 1 ? 41000 : lines.length === 2 && lines[1].quantity === 3 ? 63000 : 52000);
};
export const QR_BAN_3: Dap = { status: 200, body: { label: "Bàn 3" } };

// Phía server: page gọi thẳng backend bằng fetch toàn cục.
export function serverBackend(qr: Dap = QR_BAN_3) {
  const goi: { url: string; cache: RequestCache | undefined }[] = [];
  vi.stubGlobal("fetch", async (input: RequestInfo | URL, init?: RequestInit) => {
    const url = typeof input === "string" ? input : input instanceof URL ? input.href : input.url;
    goi.push({ url, cache: init?.cache ?? (input instanceof Request ? input.cache : undefined) });
    const path = new URL(url).pathname;
    if (path === "/menu") return tra({ status: 200, body: menuMau });
    if (path.startsWith("/qr-codes/")) return tra(qr);
    return tra({ status: 599, body: { code: "khong_co_trong_hop_dong" } });
  });
  return goi;
}

// Phía trình duyệt: lớp gọi API qua ApiProvider.
export function clientBackend(tinhThu: Ghi = tinhTheoGio, gui?: Ghi, qr: Dap = QR_BAN_3) {
  const goi: Goi[] = [];
  let lanTinh = 0;
  let lanGui = 0;
  const fetch = async (req: Request) => {
    const text = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: TraLoi = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    if (g.path === "/menu") r = { status: 200, body: menuMau };
    else if (g.method === "GET" && g.path.startsWith("/qr-codes/")) r = qr;
    else if (g.path === "/price-quotes") r = await tinhThu(g, ++lanTinh);
    else if (g.method === "POST" && gui) r = await gui(g, ++lanGui);
    if (r === "mat-mang") throw new TypeError("fetch failed");
    return tra(r);
  };
  return { fetch, goi };
}

export const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
// So chuỗi, không dùng regex: check-fe-rules đọc `|` trong regex literal là phép tính với tên tiền.
export const coGia = (body: unknown) => ["price", "total", "vnd", "surcharge"].some((w) => JSON.stringify(body).includes(w));
export const guiDi = (g: Goi[]) => g.filter((x) => x.method === "POST" && x.path !== "/price-quotes");
export const tinhThuDi = (g: Goi[]) => g.filter((x) => x.path === "/price-quotes");
export const sx = (ids: unknown) => [...(ids as number[])].sort((a, b) => a - b);
