import { NextRequest, NextResponse } from "next/server";
import { decodeGoogleSession } from "@/lib/google-session";
import {
  exchangeMobileAuthorizationCode,
  mobileSessionResponse,
} from "@/lib/mobile-google";

export const runtime = "nodejs";

export async function POST(request: NextRequest) {
  try {
    const body = await request.json() as {
      serverAuthCode?: string;
      previousSessionToken?: string;
    };
    if (!body.serverAuthCode) {
      return NextResponse.json({ error: "server_auth_code_required" }, { status: 400 });
    }

    const previous = decodeGoogleSession(body.previousSessionToken);
    const session = await exchangeMobileAuthorizationCode(body.serverAuthCode, previous);
    return mobileSessionResponse({
      account: {
        email: session.email ?? null,
        name: session.name ?? null,
        picture: session.picture ?? null,
      },
      scopes: session.scopes,
    }, session);
  } catch (error) {
    return NextResponse.json({
      error: "mobile_google_exchange_failed",
      detail: error instanceof Error ? error.message : "Erreur inconnue",
    }, { status: 502 });
  }
}
