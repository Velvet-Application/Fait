import { randomBytes } from "node:crypto";
import { NextRequest, NextResponse } from "next/server";
import { buildGoogleAuthorizationUrl, isGoogleConfigured } from "@/lib/google-oauth";
import {
  GOOGLE_OAUTH_MODE_COOKIE,
  GOOGLE_OAUTH_STATE_COOKIE,
  type GoogleOAuthMode,
  secureCookieOptions,
} from "@/lib/google-session";

export const runtime = "nodejs";

export async function GET(request: NextRequest) {
  const mode = request.nextUrl.searchParams.get("mode") === "compose" ? "compose" : "read";
  if (!isGoogleConfigured()) {
    return NextResponse.redirect(new URL("/?gmail=not-configured", request.url));
  }

  const state = randomBytes(32).toString("base64url");
  const authorizationUrl = buildGoogleAuthorizationUrl(request.nextUrl.origin, state, mode as GoogleOAuthMode);
  const response = NextResponse.redirect(authorizationUrl);
  response.cookies.set(GOOGLE_OAUTH_STATE_COOKIE, state, secureCookieOptions(10 * 60));
  response.cookies.set(GOOGLE_OAUTH_MODE_COOKIE, mode, secureCookieOptions(10 * 60));
  return response;
}
