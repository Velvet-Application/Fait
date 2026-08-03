import { createCipheriv, createDecipheriv, createHash, randomBytes } from "node:crypto";

export const GOOGLE_SESSION_COOKIE = "fait_google_session";
export const GOOGLE_OAUTH_STATE_COOKIE = "fait_google_oauth_state";
export const GOOGLE_OAUTH_MODE_COOKIE = "fait_google_oauth_mode";

export type GoogleOAuthMode = "read" | "compose";

export type GoogleSession = {
  accessToken: string;
  refreshToken?: string;
  expiresAt: number;
  scopes: string[];
  email?: string;
  name?: string;
  picture?: string;
  historyId?: string;
  lastSyncAt?: string;
};

function getKey(): Buffer {
  const secret = process.env.FAIT_SESSION_SECRET;
  if (!secret || secret.length < 32) {
    throw new Error("FAIT_SESSION_SECRET doit contenir au moins 32 caractères.");
  }
  return createHash("sha256").update(secret).digest();
}

export function encodeGoogleSession(session: GoogleSession): string {
  const iv = randomBytes(12);
  const cipher = createCipheriv("aes-256-gcm", getKey(), iv);
  const encrypted = Buffer.concat([
    cipher.update(JSON.stringify(session), "utf8"),
    cipher.final(),
  ]);
  const authTag = cipher.getAuthTag();
  return Buffer.concat([iv, authTag, encrypted]).toString("base64url");
}

export function decodeGoogleSession(value?: string | null): GoogleSession | null {
  if (!value) return null;
  try {
    const payload = Buffer.from(value, "base64url");
    if (payload.length < 29) return null;
    const iv = payload.subarray(0, 12);
    const authTag = payload.subarray(12, 28);
    const encrypted = payload.subarray(28);
    const decipher = createDecipheriv("aes-256-gcm", getKey(), iv);
    decipher.setAuthTag(authTag);
    const decrypted = Buffer.concat([
      decipher.update(encrypted),
      decipher.final(),
    ]).toString("utf8");
    const parsed = JSON.parse(decrypted) as GoogleSession;
    if (!parsed.accessToken || !Array.isArray(parsed.scopes)) return null;
    return parsed;
  } catch {
    return null;
  }
}

export function secureCookieOptions(maxAge: number) {
  return {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax" as const,
    path: "/",
    maxAge,
  };
}

export function hasGoogleScope(session: GoogleSession, scope: string): boolean {
  return session.scopes.includes(scope);
}
