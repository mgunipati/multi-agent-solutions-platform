import type { ReactNode } from "react";
import "./globals.css";

export const metadata = {
  title: "Multi-Agent Solutions",
  description: "Governed platform for enterprise agentic solutions",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
