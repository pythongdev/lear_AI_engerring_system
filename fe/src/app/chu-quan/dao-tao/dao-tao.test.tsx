import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { useSyncExternalStore } from "react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import Page from "./page";

const nav = vi.hoisted(() => ({ search: "", listeners: new Set<() => void>() }));
vi.mock("next/navigation", () => ({
  useSearchParams: () => new URLSearchParams(useSyncExternalStore(
    (fn) => { nav.listeners.add(fn); return () => { nav.listeners.delete(fn); }; }, () => nav.search,
  )),
  useRouter: () => ({ replace: (url: string) => { nav.search = url.split("?")[1] ?? ""; nav.listeners.forEach((fn) => fn()); } }),
  usePathname: () => "/chu-quan/dao-tao", // T-212: trang đọc đường dẫn hiện tại thay vì viết cứng
}));
afterEach(() => { cleanup(); nav.search = ""; vi.restoreAllMocks(); });

type K = components["schemas"];
type Tra = { status: number; body?: unknown };
// Thân multipart ghi lại từ các lần FormData.set (tệp ghi tên tệp): Node treo khi đọc lại File của jsdom bằng req.formData().
const phan: [string, string][] = [];
const setGoc = FormData.prototype.set;
beforeEach(() => {
  phan.length = 0;
  vi.spyOn(FormData.prototype, "set").mockImplementation(function (this: FormData, ...args: [string, string | Blob, string?]) {
    phan.push([args[0], typeof args[1] === "string" ? args[1] : `tệp:${(args[1] as File).name}`]);
    return Reflect.apply(setGoc, this, args.filter((a) => a !== undefined));
  });
});
type GoiDen = { method: string; path: string; body: unknown; multipart: boolean };
function voiBackend(traLoi: (g: GoiDen) => Tra) {
  const goi: GoiDen[] = [];
  render(<ApiProvider fetch={async (req: Request) => {
    const u = new URL(req.url);
    const multipart = (req.headers.get("content-type") ?? "").startsWith("multipart/form-data");
    let body: unknown;
    if (multipart) { body = Object.fromEntries(phan.splice(0)); } else { const text = await req.text(); body = text ? JSON.parse(text) : undefined; }
    const g = { method: req.method, path: u.pathname.replace(/^\/api/, "") + u.search, body, multipart };
    goi.push(g); const r = traLoi(g);
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}><Page /></ApiProvider>);
  return goi;
}
const an = { hidden_at: null, hidden_by_person_id: null, hidden_by_name: null };
const gn = (id: number, remark: string | null, rating: K["TrainingRecord"]["rating"], extra: Partial<K["TrainingRecord"]> = {}): K["TrainingRecord"] => ({
  training_record_id: id, trainee_person_id: 2, trainee_name: "Mai", remark, rating, person_id: 1, person_name: "Chủ Lan",
  created_at: "2026-10-19T02:00:00Z", ...an, ...extra,
});
const ghiNhan = [gn(5, "Cuốn đều tay", "pass"), gn(3, null, "not_yet"), gn(4, "Mới vào", null)];
const hd = (id: number, kind: K["AssignedTaskGuide"]["kind"], body: string | null, extra: Partial<K["AssignedTaskGuide"]> = {}): K["AssignedTaskGuide"] => ({
  assigned_task_guide_id: id, assigned_task_id: 3, kind, body, person_id: 1, person_name: "Chủ Lan", created_at: "2026-10-19T02:00:00Z", ...an, ...extra,
});
const huongDan = [hd(11, "text", "Rửa rau ba lần"), hd(12, "image", null), hd(13, "video", null)];
const people = [{ person_id: 1, display_name: "Chủ Lan", is_owner: true }, { person_id: 2, display_name: "Mai", is_owner: false }];
const viec: K["AssignedTask"] = {
  assigned_task_id: 3, content: "Rửa rau", done: false, assignee_person_id: 2, assignee_name: "Mai", person_id: 1,
  person_name: "Chủ Lan", created_at: "2026-10-19T02:00:00Z", due_at: null, marks: [], ...an,
};
function mo(opts: { ghiNhan?: () => Tra; huongDan?: () => Tra; ghi?: (g: GoiDen) => Tra } = {}) {
  return voiBackend((g) => {
    if (g.method !== "GET") return opts.ghi?.(g) ?? { status: 201, body: g.path.includes("guide") ? huongDan[0] : ghiNhan[0] };
    if (g.path.startsWith("/training-records")) return opts.ghiNhan?.() ?? { status: 200, body: { training_records: ghiNhan } };
    if (g.path === "/people") return { status: 200, body: { people } };
    if (g.path.startsWith("/assigned-tasks/") && g.path.includes("/guides")) return opts.huongDan?.() ?? { status: 200, body: { guides: huongDan } };
    if (g.path.startsWith("/assigned-tasks")) return { status: 200, body: { assigned_tasks: [viec] } };
    return { status: 404, body: { code: "invalid_request" } };
  });
}
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");
const doc = (g: GoiDen[], dau: string) => g.filter((x) => x.method === "GET" && x.path.startsWith(dau));
const go = (f: HTMLElement, ten: string, value: string) => fireEvent.change(within(f).getByLabelText(ten), { target: { value } });
const sai = (f: HTMLElement, ten: string) => within(f).getByLabelText(ten).getAttribute("aria-invalid");
async function formThem() {
  const f = screen.getByRole("form", { name: "Thêm ghi nhận" });
  await within(f).findByRole("option", { name: "Mai" });
  return f;
}
async function formGan() {
  await screen.findByRole("list", { name: "Danh sách hướng dẫn" });
  return screen.getByRole("form", { name: "Gắn hướng dẫn" });
}

describe("Đào tạo — ghi nhận", () => {
  it("bày đúng thứ tự backend với ba nhãn đánh giá; không gửi lọc khi URL trống", async () => {
    const g = mo(); const list = await screen.findByRole("list", { name: "Danh sách ghi nhận" });
    const rows = within(list).getAllByRole("listitem");
    expect(rows.map((r) => r.textContent)).toEqual([
      expect.stringContaining("Cuốn đều tay"), expect.stringContaining("—"), expect.stringContaining("Mới vào"),
    ]);
    expect(within(rows[0]).getByText("Làm được")).toBeTruthy();
    expect(within(rows[1]).getByText("Chưa làm được")).toBeTruthy();
    expect(within(rows[2]).getByText("Chưa đánh giá")).toBeTruthy();
    expect(doc(g, "/training-records")[0].path).toBe("/training-records");
  });
  it("?nguoi=7&an=1 gửi trainee_person_id và include_hidden", async () => {
    nav.search = "nguoi=7&an=1"; const g = mo(); await screen.findByRole("list", { name: "Danh sách ghi nhận" });
    const q = new URLSearchParams(doc(g, "/training-records")[0].path.split("?")[1]);
    expect(Object.fromEntries(q)).toEqual({ trainee_person_id: "7", include_hidden: "true" });
  });
  it("ghi nhận đã ẩn không có nút sửa hay ẩn", async () => {
    mo({ ghiNhan: () => ({ status: 200, body: { training_records: [gn(8, "Cũ", "pass", { hidden_at: "2026-10-19T03:00:00Z", hidden_by_person_id: 1, hidden_by_name: "Chủ Lan" })] } }) });
    expect(await screen.findByText("Đã ẩn bởi Chủ Lan")).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Sửa ghi nhận 8" })).toBeNull();
    expect(screen.queryByRole("button", { name: "Ẩn ghi nhận 8" })).toBeNull();
  });
  it("thêm chỉ nhận xét: thân không có khoá rating, rồi đọc lại", async () => {
    const g = mo(); const f = await formThem();
    go(f, "Người", "2"); go(f, "Nhận xét", "  Cuốn nhanh  "); fireEvent.submit(f);
    await screen.findByText("Đã thêm ghi nhận.");
    expect(ghi(g)).toEqual([expect.objectContaining({ method: "POST", path: "/training-records", body: { trainee_person_id: 2, remark: "Cuốn nhanh" } })]);
    await waitFor(() => expect(doc(g, "/training-records")).toHaveLength(2));
  });
  it("thêm chỉ đánh giá: thân không có khoá remark", async () => {
    const g = mo(); const f = await formThem();
    go(f, "Người", "2"); go(f, "Đánh giá", "not_yet"); fireEvent.submit(f);
    await screen.findByText("Đã thêm ghi nhận.");
    expect(ghi(g)[0].body).toEqual({ trainee_person_id: 2, rating: "not_yet" });
  });
  it("nhận xét trống và chưa đánh giá thì không gửi", async () => {
    const g = mo(); const f = await formThem();
    go(f, "Người", "2"); go(f, "Nhận xét", "   "); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Nhận xét")).toBe("true")); expect(ghi(g)).toHaveLength(0);
  });
  it("sửa gửi đủ hai trường kể cả null và lý do; thiếu lý do không gửi", async () => {
    const g = mo(); fireEvent.click(await screen.findByRole("button", { name: "Sửa ghi nhận 5" }));
    const f = screen.getByRole("form", { name: "Sửa ghi nhận 5" });
    expect((within(f).getByLabelText("Nhận xét") as HTMLTextAreaElement).value).toBe("Cuốn đều tay");
    go(f, "Đánh giá", ""); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Lý do")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    go(f, "Lý do", " Đánh lại "); fireEvent.submit(f); await screen.findByText("Đã sửa ghi nhận.");
    expect(ghi(g)).toEqual([expect.objectContaining({ method: "PUT", path: "/training-records/5", body: { remark: "Cuốn đều tay", rating: null, reason: "Đánh lại" } })]);
  });
  it("ẩn thiếu lý do không gửi; đủ lý do gửi và đọc lại", async () => {
    const g = mo(); fireEvent.click(await screen.findByRole("button", { name: "Ẩn ghi nhận 5" }));
    const f = screen.getByRole("form", { name: "Ẩn ghi nhận 5" }); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Lý do")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    go(f, "Lý do", "Ghi nhầm người"); fireEvent.submit(f); await screen.findByText("Đã ẩn, vết vẫn giữ.");
    expect(ghi(g)[0]).toEqual(expect.objectContaining({ path: "/training-records/5/hiding", body: { reason: "Ghi nhầm người" } }));
    await waitFor(() => expect(doc(g, "/training-records")).toHaveLength(2));
  });
  it("bấm gửi hai lần nhanh chỉ một lời gọi", async () => {
    const g = mo(); const f = await formThem(); go(f, "Người", "2"); go(f, "Nhận xét", "Tốt");
    const b = within(f).getByRole("button", { name: "Thêm ghi nhận" }); fireEvent.click(b); fireEvent.click(b);
    await screen.findByText("Đã thêm ghi nhận."); expect(ghi(g)).toHaveLength(1);
  });
});

describe("Đào tạo — hướng dẫn theo việc", () => {
  it("chưa chọn việc thì không đọc hướng dẫn", async () => {
    const g = mo(); expect(await screen.findByText("Chọn một việc để xem hướng dẫn.")).toBeTruthy();
    expect(g.some((x) => x.path.includes("/guides"))).toBe(false);
  });
  it("?viec=3 đọc đúng đường; ảnh và video có src tệp; ảnh, video không có nút sửa", async () => {
    nav.search = "viec=3"; const g = mo(); const list = await screen.findByRole("list", { name: "Danh sách hướng dẫn" });
    expect(doc(g, "/assigned-tasks/3/guides")[0].path).toBe("/assigned-tasks/3/guides");
    expect(within(list).getByText("Rửa rau ba lần")).toBeTruthy();
    expect(list.querySelector("img")?.getAttribute("src")).toBe("/api/assigned-task-guides/12/file");
    expect(list.querySelector("video")?.getAttribute("src")).toBe("/api/assigned-task-guides/13/file");
    expect(screen.getByRole("button", { name: "Sửa hướng dẫn 11" })).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Sửa hướng dẫn 12" })).toBeNull();
    expect(screen.queryByRole("button", { name: "Sửa hướng dẫn 13" })).toBeNull();
  });
  it("?an-hd=1 gửi include_hidden", async () => {
    nav.search = "viec=3&an-hd=1"; const g = mo(); await screen.findByRole("list", { name: "Danh sách hướng dẫn" });
    expect(doc(g, "/assigned-tasks/3/guides")[0].path).toBe("/assigned-tasks/3/guides?include_hidden=true");
  });
  it.each(["abc", "0", "-1"])("?viec=%s báo không tìm thấy, không đọc hướng dẫn", async (v) => {
    nav.search = `viec=${v}`; const g = mo(); expect(await screen.findByText("Không tìm thấy việc này")).toBeTruthy();
    expect(g.some((x) => x.path.includes("/guides"))).toBe(false);
  });
  it("assigned_task_not_found báo không tìm thấy", async () => {
    nav.search = "viec=3"; mo({ huongDan: () => ({ status: 404, body: { code: "assigned_task_not_found" } }) });
    expect(await screen.findByText("Không tìm thấy việc này")).toBeTruthy();
    expect(screen.queryByRole("form", { name: "Gắn hướng dẫn" })).toBeNull();
  });
  it("gắn chữ gửi multipart có kind, body, không file; rồi đọc lại", async () => {
    nav.search = "viec=3"; const g = mo(); const f = await formGan();
    go(f, "Nội dung hướng dẫn", "  Vớt bánh nhẹ tay  "); fireEvent.submit(f); await screen.findByText("Đã gắn hướng dẫn.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/assigned-tasks/3/guides", multipart: true, body: { kind: "text", body: "Vớt bánh nhẹ tay" } }]);
    await waitFor(() => expect(doc(g, "/assigned-tasks/3/guides")).toHaveLength(2));
  });
  it("gắn ảnh gửi multipart có kind, file, không body; chưa chọn tệp thì không gửi", async () => {
    nav.search = "viec=3"; const g = mo(); const f = await formGan();
    go(f, "Loại", "image"); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Tệp")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    const tep = within(f).getByLabelText("Tệp") as HTMLInputElement;
    expect(tep.getAttribute("accept")).toBe("image/jpeg,image/png,image/webp");
    fireEvent.change(tep, { target: { files: [new File(["png"], "rau.png", { type: "image/png" })] } });
    fireEvent.submit(f); await screen.findByText("Đã gắn hướng dẫn.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/assigned-tasks/3/guides", multipart: true, body: { kind: "image", file: "tệp:rau.png" } }]);
  });
  it("413 file_too_large báo cỡ theo hợp đồng ở ô tệp", async () => {
    nav.search = "viec=3"; const g = mo({ ghi: () => ({ status: 413, body: { code: "file_too_large" } }) }); const f = await formGan();
    go(f, "Loại", "video"); fireEvent.change(within(f).getByLabelText("Tệp"), { target: { files: [new File(["mp4"], "lon.mp4", { type: "video/mp4" })] } });
    fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Tệp")).toBe("true"));
    expect(within(f).getByText("Tệp quá lớn: ảnh tối đa 10 MiB, video tối đa 100 MiB.")).toBeTruthy(); expect(ghi(g)).toHaveLength(1);
  });
  it("sửa chữ cần lý do, gửi {body, reason}", async () => {
    nav.search = "viec=3"; const g = mo(); fireEvent.click(await screen.findByRole("button", { name: "Sửa hướng dẫn 11" }));
    const f = screen.getByRole("form", { name: "Sửa hướng dẫn 11" }); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Lý do")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    go(f, "Lý do", "Rõ hơn"); go(f, "Nội dung hướng dẫn", "Rửa rau bốn lần"); fireEvent.submit(f); await screen.findByText("Đã sửa hướng dẫn.");
    expect(ghi(g)).toEqual([expect.objectContaining({ method: "PUT", path: "/assigned-task-guides/11", body: { body: "Rửa rau bốn lần", reason: "Rõ hơn" } })]);
  });
  it("ẩn hướng dẫn cần lý do", async () => {
    nav.search = "viec=3"; const g = mo(); fireEvent.click(await screen.findByRole("button", { name: "Ẩn hướng dẫn 12" }));
    const f = screen.getByRole("form", { name: "Ẩn hướng dẫn 12" }); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Lý do")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    go(f, "Lý do", "Ảnh mờ"); fireEvent.submit(f); await screen.findByText("Đã ẩn, vết vẫn giữ.");
    expect(ghi(g)[0]).toEqual(expect.objectContaining({ path: "/assigned-task-guides/12/hiding", body: { reason: "Ảnh mờ" } }));
  });
});
