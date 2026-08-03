import { NextRequest, NextResponse } from "next/server";
import { syncUsefulGmailMessages } from "@/lib/gmail";
import {
  ensureFreshGoogleSession,
  GOOGLE_SCOPE_READONLY,
} from "@/lib/google-oauth";
import { hasGoogleScope } from "@/lib/google-session";
import {
  mobileSessionResponse,
  readMobileSession,
} from "@/lib/mobile-google";

export const runtime = "nodejs";
export const maxDuration = 30;

export async function POST(request: NextRequest) {
  const stored = readMobileSession(request);
  if (!stored) return NextResponse.json({ error: "mobile_session_required" }, { status: 401 });
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
    return mobileSessionResponse({
      items: sync.items,
      mode: sync.mode,
      historyId: updated.historyId ?? null,
      lastSyncAt: updated.lastSyncAt,
    }, updated);
  } catch (error) {
    return NextResponse.json({
      error: "gmail_sync_failed",
      detail: error instanceof Error ? error.message : "Erreur inconnue",
    }, { status: 502 });
  }
}
