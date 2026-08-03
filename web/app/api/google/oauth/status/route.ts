import { NextRequest, NextResponse } from "next/server";
import {
  GOOGLE_SCOPE_COMPOSE,
  GOOGLE_SCOPE_READONLY,
  isGoogleConfigured,
} from "@/lib/google-oauth";
import {
  decodeGoogleSession,
  GOOGLE_SESSION_COOKIE,
  hasGoogleScope,
} from "@/lib/google-session";

export const runtime = "nodejs";

export async function GET(request: NextRequest) {
  const session = decodeGoogleSession(request.cookies.get(GOOGLE_SESSION_COOKIE)?.value);
  return NextResponse.json({
    configured: isGoogleConfigured(),
    connected: Boolean(session),
    email: session?.email ?? null,
    name: session?.name ?? null,
    picture: session?.picture ?? null,
    canRead: session ? hasGoogleScope(session, GOOGLE_SCOPE_READONLY) : false,
    canCompose: session ? hasGoogleScope(session, GOOGLE_SCOPE_COMPOSE) : false,
    scopes: session?.scopes ?? [],
    lastSyncAt: session?.lastSyncAt ?? null,
  }, { headers: { "Cache-Control": "no-store" } });
}
