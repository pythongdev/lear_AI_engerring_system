"use client";

import { useId } from "react";
import { LuaChonThe } from "@/app/ban/_components/lua-chon-the";
import type { Menu } from "./du-lieu";

type Nhom = Menu["items"][number]["option_groups"][number];

// Chỉ đổi chữ hiển thị; giữ khớp nhãn của thuc-don-khach.tsx.
const nhanNhom = (groups: Nhom[]) => groups.map((g) => ({ ...g, options: g.options.map((o) => ({
  ...o, option_name: g.option_group_name === "Lượng nhân" && o.option_name === "Thường" ? "Vừa" : g.option_group_name === "Lượng nhân" && o.option_name === "Nhiều nhân" ? "Nhiều" : o.option_name,
})) }));

export function LuaChonDanhSach({ groups, ids, name, disabled, onChange }: {
  groups: Nhom[]; ids: number[]; name: string; disabled?: boolean; onChange: (ids: number[]) => void;
}) {
  // Mỗi hình món có nhóm radio riêng, kể cả khi tên món trùng nhau.
  const id = useId();
  return <fieldset className="yt-options" aria-label={`Lựa chọn ${name}`} disabled={disabled}>
    <LuaChonThe groups={nhanNhom(groups)} ids={ids} name={id} onChange={onChange} />
  </fieldset>;
}
