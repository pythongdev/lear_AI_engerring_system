import { backendUrl } from "@/lib/api/backend-url";
import { readFailure, type ApiFailure } from "@/lib/api/client";
import { TheoDoiMon } from "../../_components/theo-doi-mon";
import type { TienDoBan } from "../../_components/du-lieu-theo-doi";

export default async function TheoDoiPage({ params }: { params: Promise<{ ma: string }> }) {
  const { ma } = await params;
  let initialData: TienDoBan | undefined;
  let initialFailure: ApiFailure | undefined;
  try {
    const response = await fetch(`${backendUrl()}/qr-codes/${encodeURIComponent(ma)}/progress`, { cache: "no-store" });
    const body = await response.json();
    if (response.ok) initialData = body;
    else initialFailure = readFailure(response, body);
  } catch {
    initialFailure = { kind: "no_response" };
  }
  return <TheoDoiMon ma={ma} initialData={initialData} initialFailure={initialFailure} />;
}
