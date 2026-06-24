import type { Metadata } from "next";
import "@/styles/globals.css";

export const metadata: Metadata = {
  title: "E2E デモ — ボタンでモーダル",
  description: "Next.js + Playwright E2E と Claude 自動修正のサンプル",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  );
}
