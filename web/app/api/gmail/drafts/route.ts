import { NextRequest, NextResponse } from "next/server";
import { createGmailDraft } from "@/lib/gmail";
import {
  ensureFreshGoogleSession,
  GOOGLE_SCOPE_COMPOSE,
} from "@/lib/google-oauth";
import {
  decodeGoogleSession,
  encodeGoogleSession,
  GOOGLE_SESSION_COOKIE,
  hasGoogleScope,
  secureCookieOptions,
} from "@/lib/google-session";

export const runtime = "nodejs";

function isValidEmail(value: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

export async function POST(request: NextRequest) {
  const stored = decodeGoogleSession(request.cookies.get(GOOGLE_SESSION_COOKIE)?.value);
  if (!stored) return NextResponse.json({ error: "google_not_connected" }, { status: 401 });
  if (!hasGoogleScope(stored, GOOGLE_SCOPE_COMPOSE)) {
    return NextResponse.json({ error: "gmail_compose_permission_required" }, { status: 403 });
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const input = body as {
    to?: string;
    subject?: string;
    body?: string;
    threadId?: string;
    inReplyTo?: string;
  };
  if (!input.to || !isValidEmail(input.to) || !input.subject || !input.body) {
    return NextResponse.json({ error: "invalid_draft_payload" }, { status: 400 });
  }
  if (input.subject.length > 250 || input.body.length > 100_000) {
    return NextResponse.json({ error: "draft_payload_too_large" }, { status: 413 });
  }

  try {
    const fresh = await ensureFreshGoogleSession(request.nextUrl.origin, stored);
    const draft = await createGmailDraft(fresh.session.accessToken, {
      to: input.to,
      subject: input.subject,
      body: input.body,
      threadId: input.threadId,
      inReplyTo: input.inReplyTo,
    });
    const response = NextResponse.json({
      created: true,
      draft,
      sent: false,
      policy: "FAIT. ne possède aucun endpoint d’envoi dans ce pilote.",
    });
    if (fresh.refreshed) {
      response.cookies.set(
        GOOGLE_SESSION_COOKIE,
        encodeGoogleSession(fresh.session),
        secureCookieOptions(30 * 24 * 60 * 60),
      );
    }
    return response;
  } catch (error) {
    return NextResponse.json({
      error: "gmail_draft_failed",
      detail: error instanceof Error ? error.message : "Erreur inconnue",
    }, { status: 502 });
  }
}
