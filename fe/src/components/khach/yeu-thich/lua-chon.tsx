"use client";

import { chonNhom } from "@/components/shared/bo-soan-mon";
import type { Menu } from "./du-lieu";

type Nhom = Menu["items"][number]["option_groups"][number];

export function LuaChonDanhSach({ groups, ids, name, disabled, onChange }: {
  groups: Nhom[]; ids: number[]; name: string; disabled?: boolean; onChange: (ids: number[]) => void;
}) {
  return <div className="grid min-w-0 grid-cols-1 gap-2 sm:grid-cols-2">{groups.filter((g) =>
    !g.prerequisite_option_ids.length || g.prerequisite_option_ids.some((v) => ids.includes(v))).map((group) =>
    <label key={group.option_group_id} className="min-w-0 space-y-1 text-sm"><span>{group.option_group_name}</span>
      <select aria-label={`${group.option_group_name} — ${name}`} className="min-h-11 w-full min-w-0 rounded-lg border border-[var(--border)] bg-[var(--card)] px-2"
        disabled={disabled} value={group.options.find((o) => ids.includes(o.menu_option_id))?.menu_option_id ?? ""}
        onChange={(e) => { const option = Number(e.target.value); if (Number.isFinite(option)) onChange(chonNhom(groups,
          [...ids.filter((v) => !group.options.some((o) => o.menu_option_id === v)), option])); }}>
        {group.options.map((o) => <option key={o.menu_option_id} value={o.menu_option_id}>{o.option_name}</option>)}
      </select>
    </label>)}</div>;
}
