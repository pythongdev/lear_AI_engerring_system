import { isIP } from "node:net";
import type { NextConfig } from "next";

// QC-18 · ADR-102 điểm 3: không cơ chế cache nào của Next bọc dữ liệu server —
// create-next-app 16.4 bật sẵn cacheComponents và partialPrefetching, tắt ở đây.
// compress tắt để tầng chuyển tiếp không đệm luồng text/event-stream (ADR-102 điểm 6 · 7).
// Chỉ phiên make dev-iphone khai IP này; Next vẫn chặn mọi Origin dev khác.
const devIP = process.env.BANHCUON_DEV_IP;
if (devIP && isIP(devIP) !== 4) throw new Error("BANHCUON_DEV_IP phải là IPv4 của Mac");

const nextConfig: NextConfig = {
  ...(devIP ? { allowedDevOrigins: [devIP] } : {}),
  cacheComponents: false,
  partialPrefetching: false,
  compress: false,
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
