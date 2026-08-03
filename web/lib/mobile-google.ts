import { NextRequest, NextResponse } from "next/server";
import {
  decodeGoogleSession,
  encodeGoogleSession,
  type GoogleSession,
} from "@/lib/google-session";
import { fetchGoogleIdentity, mergeGoogleSession } from "@/lib/google-oauth";

export const MOBILE_SESSION_HEADER = "x-fait-session";

function getGoogleServerConfig() {
  const clientId = process.env.GOOGLE_CLIENT_ID;
  const clientSecret = process.env.GOOGLE_CLIENT_SECRET;
  if (!clientId || !clientSecret) {
    throw new Error("GOOGLE_CLIENT_ID et GOOGLE_CLIENT_SECRET sont requis.");
  }
  return { clientId, clientSecret };
}

type GoogleTokenResponse = {
  access_token: string;
  expires_in: number;
  refresh_token?: string;
  scope?: string;
  token_type: string;
  id_token?: string;
};

export async function exchangeMobileAuthorizationCode(
  code: string,
  previous: GoogleSession | null,
): Promise<GoogleSession> {
  const { clientId, clientSecret } = getGoogleServerConfig();
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      code,
      grant_type: "authorization_code",
      redirect_uri: "",
    }),
    cache: "no-store",
  });

  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`Échange OAuth mobile refusé (${response.status}) : ${detail.slice(0, 300)}`);
  }

  const token = await response.json() as GoogleTokenResponse;
  const identity = await fetchGoogleIdentity(token.access_token);
  return mergeGoogleSession(previous, token, identity);
}

export function readMobileSession(request: NextRequest): GoogleSession | null {
  const authorization = request.headers.get("authorization") ?? "";
  const token = authorization.startsWith("Bearer ") ? authorization.slice(7).trim() : "";
  return decodeGoogleSession(token);
}

export function mobileSessionResponse(
  payload: Record<string, unknown>,
  session: GoogleSession,
  status = 200,
): NextResponse {
  const sessionToken = encodeGoogleSession(session);
  const response = NextResponse.json({
    ...payload,
    sessionToken,
    sessionExpiresAt: session.expiresAt,
  }, { status });
  response.headers.set(MOBILE_SESSION_HEADER, sessionToken);
  response.headers.set("Cache-Control", "no-store");
  return response;
}
