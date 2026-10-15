// Mảnh giao diện chung của năm màn tài khoản (P4-04), ghép từ primitive shadcn (ADR-100 điểm 2). Nâng lên dùng chung
// khi có nơi thứ hai (ADR-102 điểm 8).
import type { ComponentProps, ReactNode } from "react";

import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Field, FieldError, FieldLabel } from "@/components/ui/field";
import { Input } from "@/components/ui/input";

export function TheTaiKhoan({ tieuDe, children }: { tieuDe: string; children: ReactNode }) {
  return (
    <main className="mx-auto flex min-h-dvh max-w-sm flex-col justify-center p-6">
      <Card>
        <CardHeader>
          <CardTitle>
            <h1 className="text-xl font-semibold">{tieuDe}</h1>
          </CardTitle>
        </CardHeader>
        <CardContent className="flex flex-col gap-4">{children}</CardContent>
      </Card>
    </main>
  );
}

type TruongProps = ComponentProps<typeof Input> & { nhan: string; loi?: string };

export function Truong({ nhan, loi, id, ...input }: TruongProps) {
  return (
    <Field data-invalid={loi ? true : undefined}>
      <FieldLabel htmlFor={id}>{nhan}</FieldLabel>
      <Input id={id} aria-invalid={loi ? true : undefined} {...input} />
      {loi ? <FieldError>{loi}</FieldError> : null}
    </Field>
  );
}

export function Bao({ loai, children }: { loai: "loi" | "tin"; children: ReactNode }) {
  return (
    <Alert variant={loai === "loi" ? "destructive" : "default"} role={loai === "loi" ? "alert" : "status"}>
      <AlertDescription className={loai === "loi" ? undefined : "text-foreground"}>{children}</AlertDescription>
    </Alert>
  );
}

export function NutGui({ dangGui, children }: { dangGui: boolean; children: ReactNode }) {
  return (
    <Button type="submit" disabled={dangGui}>
      {dangGui ? "Đang gửi…" : children}
    </Button>
  );
}
