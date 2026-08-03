import { NextRequest, NextResponse } from "next/server";
import { revokeGoogleSession } from "@/lib/google-oauth";
import {
  decodeGoogleSession,
  GOOGLE_SESSION_COOKIE,
} from "@/lib/google-session";

export const runtime = "nodejs";

export async function POST(request: NextRequest) {
  const session = decodeGoogleSession(request.cookies.get(GOOGLE_SESSION_COOKIE)?.value);
  if (session) await revokeGoogleSession(session);
  const response = NextResponse.json({ disconnected: true });
  response.cookies.delete(GOOGLE_SESSION_COOKIE);
  return response;
}
