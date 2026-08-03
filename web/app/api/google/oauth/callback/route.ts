import { NextRequest, NextResponse } from "next/server";
import {
  exchangeGoogleCode,
  fetchGoogleIdentity,
  mergeGoogleSession,
} from "@/lib/google-oauth";
import {
  decodeGoogleSession,
  encodeGoogleSession,
  GOOGLE_OAUTH_MODE_COOKIE,
  GOOGLE_OAUTH_STATE_COOKIE,
  GOOGLE_SESSION_COOKIE,
  secureCookieOptions,
} from "@/lib/google-session";

export const runtime = "nodejs";

function redirectWithStatus(request: NextRequest, status: string, reason?: string) {
  const url = new URL("/", request.url);
  url.searchParams.set("gmail", status);
  if (reason) url.searchParams.set("reason", reason.slice(0, 120));
  return NextResponse.redirect(url);
}

export async function GET(request: NextRequest) {
  const error = request.nextUrl.searchParams.get("error");
  if (error) return redirectWithStatus(request, "error", error);

  const code = request.nextUrl.searchParams.get("code");
  const state = request.nextUrl.searchParams.get("state");
  const expectedState = request.cookies.get(GOOGLE_OAUTH_STATE_COOKIE)?.value;
  if (!code || !state || !expectedState || state !== expectedState) {
    return redirectWithStatus(request, "error", "state-invalide");
  }

  try {
    const token = await exchangeGoogleCode(request.nextUrl.origin, code);
    const identity = await fetchGoogleIdentity(token.access_token);
    const previous = decodeGoogleSession(request.cookies.get(GOOGLE_SESSION_COOKIE)?.value);
    const session = mergeGoogleSession(previous, token, identity);
    const mode = request.cookies.get(GOOGLE_OAUTH_MODE_COOKIE)?.value || "read";
    const response = redirectWithStatus(request, mode === "compose" ? "compose-connected" : "connected");
    response.cookies.set(GOOGLE_SESSION_COOKIE, encodeGoogleSession(session), secureCookieOptions(30 * 24 * 60 * 60));
    response.cookies.delete(GOOGLE_OAUTH_STATE_COOKIE);
    response.cookies.delete(GOOGLE_OAUTH_MODE_COOKIE);
    return response;
  } catch (oauthError) {
    return redirectWithStatus(
      request,
      "error",
      oauthError instanceof Error ? oauthError.message : "oauth-inconnu",
    );
  }
}
