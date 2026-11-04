import type { Metadata } from "next";
import Image from "next/image";
import Link from "next/link";

export const metadata: Metadata = {
  title: "Giới thiệu quán",
  description: "Bánh cuốn Bà Thanh Cao Bằng tại Phú Diễn, Bắc Từ Liêm, Hà Nội. Giờ bán 06:00–11:00.",
};

export default async function GioiThieuPage({ searchParams }: {
  searchParams: Promise<{ ban?: string }>;
}) {
  const { ban } = await searchParams;
  const veMenu = ban ? `/ban/${encodeURIComponent(ban)}` : "/dat-mon";

  return <main className="min-h-dvh bg-[#f8f2e9] text-[#2d2119] dark:bg-[#1b1613] dark:text-[#f8f2e9]">
    <div className="mx-auto max-w-3xl px-5 pb-16 pt-6 sm:px-8">
      <Link href={veMenu} className="inline-flex min-h-11 items-center text-sm font-medium text-[#9a4c25] underline underline-offset-4 dark:text-[#ffc091]">← Về thực đơn</Link>
      <div className="mt-5 overflow-hidden rounded-3xl bg-white shadow-[0_16px_50px_#52351a1a] dark:bg-[#2a211c]">
        <Image src="/images/gioi-thieu/banh-cuon-ba-thanh.png" alt="Minh họa bánh cuốn cùng bát canh, rau ăn kèm và quất" width={1264} height={841} priority className="aspect-[3/2] w-full object-cover" />
        <div className="px-6 pb-9 pt-7 sm:px-10">
          <p className="text-xs font-semibold uppercase tracking-[.2em] text-[#a6532b] dark:text-[#ffc091]">Chào mừng bạn đến quán</p>
          <h1 className="mt-3 text-3xl font-bold leading-tight sm:text-4xl">Bánh cuốn Bà Thanh Cao Bằng</h1>
          <p className="mt-5 max-w-2xl text-base leading-7 text-[#5b4a3e] dark:text-[#ddd0c3]">Ghé quán vào buổi sáng để thưởng thức bánh cuốn. Bạn có thể xem thực đơn và gọi món ngay tại bàn.</p>
          <div className="mt-8 grid gap-4 sm:grid-cols-2">
            <section className="rounded-2xl bg-[#f8f2e9] p-5 dark:bg-[#382d26]">
              <h2 className="text-sm font-semibold uppercase tracking-wide text-[#9a4c25] dark:text-[#ffc091]">Địa chỉ</h2>
              <p className="mt-2 leading-6">Số 14B6, ngõ 332 Hoàng Công Chất, Phú Diễn, Bắc Từ Liêm, Hà Nội.</p>
            </section>
            <section className="rounded-2xl bg-[#f8f2e9] p-5 dark:bg-[#382d26]">
              <h2 className="text-sm font-semibold uppercase tracking-wide text-[#9a4c25] dark:text-[#ffc091]">Giờ bán</h2>
              <p className="mt-2 leading-6">06:00–11:00 hằng ngày, trừ dịp Tết âm lịch. Quán sẽ thông báo ngày nghỉ Tết từng năm.</p>
            </section>
          </div>
          <p className="mt-7 text-sm text-[#5b4a3e] dark:text-[#ddd0c3]">Liên hệ quán: <a href="tel:0382688666" className="font-semibold text-[#9a4c25] underline underline-offset-4 dark:text-[#ffc091]">0382 688 666</a></p>
          <p className="mt-4 text-xs text-[#806e61] dark:text-[#c6b4a3]">Ảnh minh họa món ăn.</p>
          <Link href={veMenu} className="mt-8 inline-flex min-h-12 items-center justify-center rounded-xl bg-[#ac5223] px-6 font-semibold text-white hover:bg-[#8d4019] focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#ac5223]">Xem thực đơn</Link>
        </div>
      </div>
    </div>
  </main>;
}
