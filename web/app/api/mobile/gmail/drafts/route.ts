import { NextRequest, NextResponse } from "next/server";
import { createGmailDraft } from "@/lib/gmail";
import {
  ensureFreshGoogleSession,
  GOOGLE_SCOPE_COMPOSE,
} from "@/lib/google-oauth";
import { hasGoogleScope } from "@/lib/google-session";
import {
  mobileSessionResponse,
  readMobileSession,
} from "@/lib/mobile-google";

export const runtime = "nodejs";

export async function POST(request: NextRequest) {
  const stored = readMobileSession(request);
  if (!stored) return NextResponse.json({ error: "mobile_session_required" }, { status: 401 });
  if (!hasGoogleScope(stored, GOOGLE_SCOPE_COMPOSE)) {
    return NextResponse.json({ error: "gmail_compose_permission_required" }, { status: 403 });
  }

  try {
    const body = await request.json() as {
      to?: string;
      subject?: string;
      body?: string;
      threadId?: string;
      inReplyTo?: string;
    };
    if (!body.to || !body.subject || !body.body) {
      return NextResponse.json({ error: "draft_fields_required" }, { status: 400 });
    }

    const fresh = await ensureFreshGoogleSession(request.nextUrl.origin, stored);
    const draft = await createGmailDraft(fresh.session.accessToken, {
      to: body.to,
      subject: body.subject,
      body: body.body,
      threadId: body.threadId,
      inReplyTo: body.inReplyTo,
    });
    return mobileSessionResponse({ draft }, fresh.session);
  } catch (error) {
    return NextResponse.json({
      error: "gmail_draft_failed",
      detail: error instanceof Error ? error.message : "Erreur inconnue",
    }, { status: 502 });
  }
}
