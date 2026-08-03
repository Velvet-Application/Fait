import type { Metadata, Viewport } from "next";
import "./globals.css";
import "./v2.css";

export const metadata: Metadata = {
  title: "FAIT. — Vous demandez. C’est fait.",
  description: "Prototype web responsive de l’assistant d’exécution du quotidien FAIT.",
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
