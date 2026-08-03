import type { Metadata, Viewport } from "next";
import "./globals.css";
import "./v2.css";
import "./brand.css";
import "./connected-test.css";

export const metadata: Metadata = {
  title: "FAIT. — Assistant quotidien connecté",
  description: "Environnement de test du facilitateur de vie quotidienne FAIT.",
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
