import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { AnhSanPham } from "../_components/anh-san-pham";
import Page from "./page";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/chu-quan/san-pham",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(() => { cleanup(); vi.restoreAllMocks(); });
const phan: [string, string][] = [];
const setGoc = FormData.prototype.set;
beforeEach(() => {
  phan.length = 0;
  vi.spyOn(FormData.prototype, "set").mockImplementation(function (this: FormData, ...args: [string, string | Blob, string?]) {
    phan.push([args[0], typeof args[1] === "string" ? args[1] : (args[1] as File).name]);
    return Reflect.apply(setGoc, this, args.filter((a) => a !== undefined));
  });
});

it("T-307: ảnh của đúng món được gửi multipart cùng lý do, ảnh mới được yêu cầu lại", async () => {
  const calls: { path: string; method: string; contentType?: string; body?: Record<string, string> }[] = [];
  let hasImage = false;
  const fetch = async (req: Request) => {
    const path = new URL(req.url).pathname.replace(/^\/api/, "");
    calls.push({ path, method: req.method, contentType: req.headers.get("content-type") ?? undefined });
    const body = req.method === "PUT" ? Object.fromEntries(phan.splice(0)) : undefined;
    calls[calls.length - 1].body = body;
    if (path === "/menu-categories") return Response.json({ categories: [{
      menu_category_id: 1, name: "Món", person_id: 1, person_name: "Chủ", created_at: "2026-11-06T00:00:00Z",
      hidden_at: null, hidden_by_person_id: null, hidden_by_name: null,
      items: [{ menu_item_id: 11, item_name: "Bánh cuốn", image_url: hasImage ? "/menu-items/11/image" : null, discontinued: false, components: [] }],
    }], uncategorized_items: [] });
    if (path === "/menu") return Response.json({ categories: [], items: [], combos: [] });
    if (path === "/menu-items/11/image" && req.method === "PUT") {
      hasImage = true;
      return Response.json({ menu_item_id: 11, image_url: "/menu-items/11/image" });
    }
    return Response.json({ code: "internal_error" }, { status: 500 });
  };
  render(<ApiProvider fetch={fetch}><Page /></ApiProvider>);
  fireEvent.click(await screen.findByRole("button", { name: "Cập nhật Bánh cuốn" }));
  const form = await screen.findByRole("form", { name: "Cập nhật ảnh Bánh cuốn" });
  const file = new File(["ảnh"], "moi.png", { type: "image/png" });
  fireEvent.change(within(form).getByLabelText(/Ảnh mới/), { target: { files: [file] } });
  fireEvent.change(within(form).getByLabelText("Lý do cập nhật"), { target: { value: "Ảnh mới chụp" } });
  fireEvent.click(within(form).getByRole("button", { name: "Lưu ảnh" }));
  await waitFor(() => expect(calls.find((c) => c.method === "PUT")?.body).toBeDefined());
  const sent = calls.find((c) => c.method === "PUT")!;
  expect(sent.path).toBe("/menu-items/11/image");
  expect(sent.contentType).toMatch(/multipart\/form-data/);
  expect(sent.body).toEqual({ file: "moi.png", reason: "Ảnh mới chụp" });
  expect(await screen.findByText("Đã cập nhật ảnh Bánh cuốn.")).toBeTruthy();
  await waitFor(() => expect(screen.getAllByRole("img", { name: "Bánh cuốn" })
    .some((img) => img.getAttribute("src")?.includes("/api/menu-items/11/image"))).toBe(true));
});

it("T-307: AnhSanPham ưu tiên ảnh tải lên và về ảnh sẵn khi chưa tải", () => {
  const { rerender } = render(<AnhSanPham ten="Bánh cuốn" imageUrl="/menu-items/11/image" />);
  expect(screen.getByRole("img", { name: "Bánh cuốn" }).getAttribute("src")).toContain("/api/menu-items/11/image");
  rerender(<AnhSanPham ten="Bánh cuốn" imageUrl={null} />);
  expect(screen.getByRole("img", { name: "Bánh cuốn" }).getAttribute("src")).toContain("banh-cuon.png");
});
