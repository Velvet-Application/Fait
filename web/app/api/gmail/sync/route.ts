import { NextRequest, NextResponse } from "next/server";
import { syncUsefulGmailMessages } from "@/lib/gmail";
import {
  ensureFreshGoogleSession,
  GOOGLE_SCOPE_READONLY,
} from "@/lib/google-oauth";
import {
  decodeGoogleSession,
  encodeGoogleSession,
  GOOGLE_SESSION_COOKIE,
  hasGoogleScope,
  secureCookieOptions,
} from "@/lib/google-session";

export const runtime = "nodejs";
export const maxDuration = 30;

export async function POST(request: NextRequest) {
  const stored = decodeGoogleSession(request.cookies.get(GOOGLE_SESSION_COOKIE)?.value);
  if (!stored) return NextResponse.json({ error: "google_not_connected" }, { status: 401 });
  if (!hasGoogleScope(stored, GOOGLE_SCOPE_READONLY)) {
    return NextResponse.json({ error: "gmail_read_permission_required" }, { status: 403 });
  }

  try {
    const fresh = await ensureFreshGoogleSession(request.nextUrl.origin, stored);
    const sync = await syncUsefulGmailMessages(fresh.session.accessToken, fresh.session.historyId);
    const updated = {
      ...fresh.session,
      historyId: sync.historyId || fresh.session.historyId,
      lastSyncAt: new Date().toISOString(),
    };
    const response = NextResponse.json({
      items: sync.items,
      mode: sync.mode,
      historyId: updated.historyId ?? null,
      lastSyncAt: updated.lastSyncAt,
    });
    response.cookies.set(
      GOOGLE_SESSION_COOKIE,
      encodeGoogleSession(updated),
      secureCookieOptions(30 * 24 * 60 * 60),
    );
    return response;
  } catch (error) {
    return NextResponse.json({
      error: "gmail_sync_failed",
      detail: error instanceof Error ? error.message : "Erreur inconnue",
    }, { status: 502 });
  }
}
