import type { Metadata, Viewport } from "next";
import "./globals.css";
import "./v2.css";
import "./brand.css";
import "./connected-test.css";
import "./gmail-pilot.css";

export const metadata: Metadata = {
  title: "FAIT. — Pilote Gmail OAuth",
  description: "Pilote réel Gmail OAuth de l’assistant quotidien connecté FAIT.",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#FAF7F2",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="fr">
      <body>{children}</body>
    </html>
  );
}
