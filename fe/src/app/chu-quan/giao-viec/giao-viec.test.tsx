import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { useSyncExternalStore } from "react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import Page from "./page";

const nav = vi.hoisted(() => ({ search: "", listeners: new Set<() => void>() }));
vi.mock("next/navigation", () => ({
  usePathname: () => "/chu-quan/giao-viec",
  useSearchParams: () => new URLSearchParams(useSyncExternalStore(
    (fn) => { nav.listeners.add(fn); return () => { nav.listeners.delete(fn); }; }, () => nav.search,
  )),
  useRouter: () => ({ replace: (url: string) => { nav.search = url.split("?")[1] ?? ""; nav.listeners.forEach((fn) => fn()); } }),
}));
afterEach(() => { cleanup(); nav.search = ""; });
type Viec = components["schemas"]["AssignedTask"];
type TraLoi = { status: number; body?: unknown };
const viec = (id: number, content: string, done: boolean): Viec => ({
  assigned_task_id: id, content, done, assignee_person_id: 2, assignee_name: "Mai", person_id: 1, person_name: "Chủ Lan",
  created_at: "2026-10-19T02:00:00Z", due_at: null, marks: [], hidden_at: null, hidden_by_person_id: null, hidden_by_name: null,
});
const ds = [viec(9, "Lau bàn", false), viec(2, "Rửa rau", true)];
const people = [{ person_id: 1, display_name: "Chủ Lan", is_owner: true }, { person_id: 2, display_name: "Mai", is_owner: false }];
function moTrang(tl: { doc?: (lan: number) => TraLoi; ghi?: () => TraLoi } = {}) {
  let lan = 0;
  return voiBackend(<Page />, (g) => {
    if (g.path === "/assigned-tasks" && g.method === "GET") return tl.doc?.(++lan) ?? { status: 200, body: { assigned_tasks: ds } };
    if (g.path === "/people") return { status: 200, body: { people } };
    if (g.method !== "GET") return tl.ghi?.() ?? { status: 201, body: ds[0] };
    return { status: 404, body: { code: "invalid_request" } };
  });
}
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");
const doc = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/assigned-tasks").length;
const go = (f: HTMLElement, ten: string, value: string) => fireEvent.change(within(f).getByLabelText(ten), { target: { value } });
async function mo(ten: string) {
  fireEvent.click(await screen.findByRole("button", { name: ten }));
  return screen.getByRole("form", { name: ten });
}
const gui = (f: HTMLElement) => fireEvent.submit(f);
const sai = (f: HTMLElement, ten: string) => within(f).getByLabelText(ten).getAttribute("aria-invalid");
async function tao() {
  await screen.findByText("Lau bàn");
  const f = await mo("Giao việc mới");
  go(f, "Nội dung", "  Quét sân  "); go(f, "Người nhận", "1"); go(f, "Hạn hoàn thành *", "2026-10-25T09:30");
  return f;
}

describe("Giao việc", () => {
  it("giữ thứ tự backend, nhãn theo done, người và lúc đánh dấu là phần tử cuối; có hạn hoàn thành, không gọi guides", async () => {
    const marks: Viec["marks"] = [
      { assigned_task_mark_id: 1, mark: "undone", person_id: 3, person_name: "Người trước", created_at: "2026-10-19T03:00:00Z" },
      { assigned_task_mark_id: 2, mark: "done", person_id: 4, person_name: "Người cuối", created_at: "2026-10-19T04:00:00Z" },
    ];
    const g = moTrang({ doc: () => ({ status: 200, body: { assigned_tasks: [{ ...ds[0], marks }, ds[1]] } }) });
    await screen.findByText("Lau bàn");
    const table = screen.getByRole("table");
    expect(within(table).getAllByRole("columnheader").map((h) => h.textContent)).toEqual(["Nội dung công việc", "Người nhận", "Người giao", "Lúc giao", "Trạng thái", "Đánh dấu gần nhất", "Thao tác"]);
    const items = within(table).getAllByRole("row").slice(1);
    expect(items.map((i) => i.querySelector("h2")?.textContent)).toEqual(["Lau bàn", "Rửa rau"]);
    expect(within(items[0]).getByText("Chưa xong")).toBeTruthy();
    expect(within(items[1]).getByText("Đã xong")).toBeTruthy();
    const cells = within(items[0]).getAllByRole("cell");
    expect(within(cells[1]).getByText("Mai")).toBeTruthy();
    expect(cells[2].textContent).toBe("Chủ Lan");
    expect(cells[3].textContent).toContain("09:00:00 19/10/2026");
    expect(items[0].textContent).toContain("Người cuối · 11:00:00 19/10/2026");
    expect(items[0].textContent).not.toContain("Người trước");
    expect(within(items[0]).getByText("Hạn hoàn thành: Chưa có hạn")).toBeTruthy();
    expect(g.some((x) => x.path.includes("/guides"))).toBe(false);
  });
  it("thống kê từ API, tìm nội dung kết hợp trạng thái và báo rỗng", async () => {
    moTrang();
    await screen.findByText("Lau bàn");
    const summary = screen.getByRole("region", { name: "Tóm tắt công việc" });
    expect(Array.from(summary.querySelectorAll("strong"), (el) => el.textContent)).toEqual(["2", "1", "1"]);
    const filters = screen.getByRole("group", { name: "Lọc trạng thái" });
    fireEvent.click(within(filters).getByRole("button", { name: "Đã xong" }));
    expect(screen.queryByText("Lau bàn")).toBeNull();
    expect(screen.getByText("Rửa rau")).toBeTruthy();
    fireEvent.change(screen.getByRole("searchbox"), { target: { value: "LAU" } });
    expect(screen.getByText("Không có công việc phù hợp.")).toBeTruthy();
    fireEvent.click(within(filters).getByRole("button", { name: "Tất cả" }));
    expect(screen.getByText("Lau bàn")).toBeTruthy();
    expect(screen.queryByText("Rửa rau")).toBeNull();
    expect(Array.from(summary.querySelectorAll("strong"), (el) => el.textContent)).toEqual(["2", "1", "1"]);
  });
  it("mở form trong hộp thoại, Escape đóng và trả focus về nút thêm", async () => {
    moTrang();
    const trigger = await screen.findByRole("button", { name: "Giao việc mới" });
    trigger.focus(); fireEvent.click(trigger);
    const dialog = screen.getByRole("dialog", { name: "Thêm công việc" });
    expect(within(dialog).getByRole("textbox", { name: "Nội dung" }).tagName).toBe("TEXTAREA");
    fireEvent.keyDown(dialog, { key: "Escape" });
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await waitFor(() => expect(document.activeElement).toBe(trigger));
  });
  it("sửa hạn hiện giờ Việt Nam và gửi hạn mới cùng lý do", async () => {
    const g = moTrang({ doc: () => ({ status: 200, body: { assigned_tasks: [{ ...ds[0], due_at: "2026-10-25T02:30:00Z" }] } }) });
    const f = await mo("Sửa Lau bàn");
    expect((within(f).getByLabelText("Hạn hoàn thành *") as HTMLInputElement).value).toBe("2026-10-25T09:30");
    go(f, "Hạn hoàn thành *", "2026-10-26T10:45"); go(f, "Lý do", "Đổi ca"); gui(f);
    await screen.findByText("Đã sửa việc.");
    expect(ghi(g)[0].body).toEqual({ content: "Lau bàn", assignee_person_id: 2, due_at: "2026-10-26T10:45:00+07:00", reason: "Đổi ca" });
  });
  it("không được xoá hạn đã có khi sửa", async () => {
    const g = moTrang({ doc: () => ({ status: 200, body: { assigned_tasks: [{ ...ds[0], due_at: "2026-10-25T02:30:00Z" }] } }) });
    const f = await mo("Sửa Lau bàn");
    go(f, "Hạn hoàn thành *", ""); go(f, "Lý do", "Sửa"); gui(f);
    await waitFor(() => expect(sai(f, "Hạn hoàn thành *")).toBe("true"));
    expect(ghi(g)).toEqual([]);
  });
  it("bày danh sách rỗng", async () => {
    moTrang({ doc: () => ({ status: 200, body: { assigned_tasks: [] } }) });
    expect(await screen.findByText("Chưa có việc nào.")).toBeTruthy();
  });
  it("lọc người nhận gửi assignee_person_id, không include_hidden, đổi về mọi người", async () => {
    const urls: URL[] = [];
    render(<ApiProvider fetch={async (req) => {
      const url = new URL(req.url); urls.push(url);
      return new Response(JSON.stringify(url.pathname.endsWith("/people") ? { people } : { assigned_tasks: ds }),
        { status: 200, headers: { "content-type": "application/json" } });
    }}><Page /></ApiProvider>);
    await screen.findByText("Lau bàn");
    fireEvent.change(screen.getByLabelText("Lọc người nhận"), { target: { value: "1" } });
    await waitFor(() => expect(urls.some((u) => u.searchParams.get("assignee_person_id") === "1")).toBe(true));
    expect(nav.search).toBe("assignee_person_id=1");
    fireEvent.change(screen.getByLabelText("Lọc người nhận"), { target: { value: "" } });
    await waitFor(() => expect(urls.filter((u) => u.pathname.endsWith("/assigned-tasks") && !u.search).length).toBe(2));
    expect(urls.some((u) => u.searchParams.has("include_hidden"))).toBe(false);
  });
  it("giao việc cắt khoảng trắng, cho chọn cả chủ quán, gửi đúng thân và đọc lại; bấm hai lần chỉ gửi một", async () => {
    const g = moTrang({ doc: (lan) => ({ status: 200, body: { assigned_tasks: lan === 1 ? ds : [viec(10, "Kết quả đọc lại", false)] } }) });
    const f = await tao(); gui(f); gui(f);
    expect(await screen.findByText("Đã giao việc.")).toBeTruthy();
    expect(ghi(g)).toEqual([{ method: "POST", path: "/assigned-tasks", body: { content: "Quét sân", assignee_person_id: 1, due_at: "2026-10-25T09:30:00+07:00" } }]);
    expect(doc(g)).toBe(2);
    expect(await screen.findByText("Kết quả đọc lại")).toBeTruthy();
  });
  it.each(["Nội dung", "Người nhận", "Hạn hoàn thành *"])("thiếu %s thì không gửi", async (ten) => {
    const g = moTrang(); const f = await tao(); go(f, ten, ten === "Nội dung" ? "   " : ""); gui(f);
    await waitFor(() => expect(sai(f, ten)).toBe("true")); expect(ghi(g)).toEqual([]);
  });
  it("sửa mặc định đúng nội dung và người, thiếu lý do không gửi, đủ gửi đúng thân rồi đọc lại", async () => {
    const g = moTrang(); const f = await mo("Sửa Lau bàn");
    expect((within(f).getByLabelText("Nội dung") as HTMLInputElement).value).toBe("Lau bàn");
    expect((within(f).getByLabelText("Người nhận") as HTMLSelectElement).value).toBe("2");
    gui(f); await waitFor(() => expect(sai(f, "Lý do")).toBe("true")); expect(ghi(g)).toEqual([]);
    go(f, "Nội dung", " Lau ghế "); go(f, "Người nhận", "1"); go(f, "Lý do", " Đổi việc "); gui(f);
    await screen.findByText("Đã sửa việc.");
    expect(ghi(g)).toEqual([{ method: "PUT", path: "/assigned-tasks/9", body: { content: "Lau ghế", assignee_person_id: 1, reason: "Đổi việc" } }]);
    expect(doc(g)).toBe(2);
  });
  it("person_not_found gắn đúng ô người nhận", async () => {
    const g = moTrang({ ghi: () => ({ status: 404, body: { code: "person_not_found" } }) });
    const f = await tao(); gui(f);
    await waitFor(() => expect(sai(f, "Người nhận")).toBe("true")); expect(ghi(g)).toHaveLength(1);
  });
  it.each([["content", "Nội dung"], ["assignee_person_id", "Người nhận"], ["reason", "Lý do"], ["due_at", "Hạn hoàn thành"]])("lỗi field %s gắn đúng ô", async (field, ten) => {
    moTrang({ ghi: () => ({ status: 400, body: { code: "invalid_request", field } }) });
    const f = await mo("Sửa Lau bàn"); go(f, "Lý do", "Đổi việc"); gui(f);
    await waitFor(() => expect(sai(f, ten)).toBe("true"));
  });
  it.each([["Đánh dấu xong", "done", 9], ["Bỏ đánh dấu xong", "undone", 2]])("%s gửi đúng mark, chặn bấm hai lần, đọc lại", async (ten, mark, id) => {
    const g = moTrang(); const nut = await screen.findByRole("button", { name: String(ten) });
    fireEvent.click(nut); fireEvent.click(nut); await screen.findByText("Đã lưu đánh dấu.");
    expect(ghi(g)).toEqual([{ method: "POST", path: `/assigned-tasks/${id}/marks`, body: { mark } }]); expect(doc(g)).toBe(2);
    expect(screen.queryByLabelText("Lý do")).toBeNull();
  });
  it.each(["assigned_task_already_done", "assigned_task_not_done", "assigned_task_not_found", "assigned_task_hidden"])("%s báo trạng thái đổi và đọc lại", async (code) => {
    const g = moTrang({ ghi: () => ({ status: 409, body: { code } }) });
    fireEvent.click(await screen.findByRole("button", { name: "Đánh dấu xong" }));
    await screen.findByText(/Trạng thái việc đã đổi/); expect(doc(g)).toBe(2); expect(ghi(g)).toHaveLength(1);
  });
  it("xoá cần xác nhận và lý do, huỷ không gửi, gửi reason rồi đọc lại để việc biến mất", async () => {
    const g = moTrang({ doc: (lan) => ({ status: 200, body: { assigned_tasks: lan === 1 ? ds : [] } }) });
    let f = await mo("Xoá Lau bàn"); expect(f.textContent).toContain("Việc sẽ biến khỏi danh sách, vết vẫn giữ.");
    expect(ghi(g)).toEqual([]); fireEvent.click(within(f).getByRole("button", { name: "Huỷ" })); expect(ghi(g)).toEqual([]);
    f = await mo("Xoá Lau bàn"); gui(f); await waitFor(() => expect(sai(f, "Lý do")).toBe("true")); expect(ghi(g)).toEqual([]);
    go(f, "Lý do", " Không cần nữa "); gui(f); await screen.findByText("Chưa có việc nào.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/assigned-tasks/9/hiding", body: { reason: "Không cần nữa" } }]); expect(doc(g)).toBe(2);
  });
  it("sửa việc vừa bị ẩn: thông báo còn sau khi đọc lại bỏ dòng việc", async () => {
    const g = moTrang({
      doc: (lan) => ({ status: 200, body: { assigned_tasks: lan === 1 ? ds : [] } }),
      ghi: () => ({ status: 409, body: { code: "assigned_task_hidden" } }),
    });
    const f = await mo("Sửa Lau bàn"); go(f, "Lý do", "Đổi việc"); gui(f);
    await screen.findByText("Chưa có việc nào.");
    expect(await screen.findByText(/Trạng thái việc đã đổi/)).toBeTruthy(); expect(doc(g)).toBe(2);
  });
  it("phản hồi không phải Error: giữ nháp, báo chưa xác nhận, không tự gửi lại", async () => {
    const g = moTrang({ ghi: () => ({ status: 502, body: { message: "proxy error" } }) });
    const f = await tao(); gui(f); await screen.findByText(/Chưa xác nhận được kết quả/);
    expect((within(f).getByLabelText("Nội dung") as HTMLInputElement).value).toBe("  Quét sân  ");
    expect(ghi(g)).toHaveLength(1); expect(doc(g)).toBe(1); expect(screen.getByText("Lau bàn")).toBeTruthy();
  });
  it("ghi thành công nhưng đọc lại lỗi: giữ bản cũ kèm mốc và báo đã ghi chưa cập nhật", async () => {
    const g = moTrang({ doc: (lan) => lan === 1 ? { status: 200, body: { assigned_tasks: ds } } : { status: 403, body: { code: "owner_only" } } });
    const f = await tao(); gui(f); await screen.findByText(/Đã ghi, chưa cập nhật được dữ liệu/);
    expect(screen.getByText("Lau bàn")).toBeTruthy(); expect(screen.getByRole("alert").textContent).toContain("Đang hiện bản đọc trước, lúc");
    expect(ghi(g)).toHaveLength(1);
  });
});
