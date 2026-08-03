import { NextRequest, NextResponse } from "next/server";
import { revokeGoogleSession } from "@/lib/google-oauth";
import { readMobileSession } from "@/lib/mobile-google";

export const runtime = "nodejs";

export async function POST(request: NextRequest) {
  const session = readMobileSession(request);
  if (!session) return NextResponse.json({ ok: true });
  await revokeGoogleSession(session);
  return NextResponse.json({ ok: true }, {
    headers: { "Cache-Control": "no-store" },
  });
}
