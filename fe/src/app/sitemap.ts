import type { MetadataRoute } from "next";
import { PUBLIC_ROUTES, siteUrl } from "@/lib/seo";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = siteUrl();
  return baseUrl ? PUBLIC_ROUTES.map((path) => ({ url: `${baseUrl}${path}` })) : [];
}
