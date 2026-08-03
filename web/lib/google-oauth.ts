import type { GoogleOAuthMode, GoogleSession } from "@/lib/google-session";

export const GOOGLE_SCOPE_READONLY = "https://www.googleapis.com/auth/gmail.readonly";
export const GOOGLE_SCOPE_COMPOSE = "https://www.googleapis.com/auth/gmail.compose";

const IDENTITY_SCOPES = ["openid", "email", "profile"];

function getGoogleConfig(origin: string) {
  const clientId = process.env.GOOGLE_CLIENT_ID;
  const clientSecret = process.env.GOOGLE_CLIENT_SECRET;
  if (!clientId || !clientSecret) {
    throw new Error("GOOGLE_CLIENT_ID et GOOGLE_CLIENT_SECRET sont requis.");
  }
  const redirectUri = process.env.GOOGLE_OAUTH_REDIRECT_URI || `${origin}/api/google/oauth/callback`;
  return { clientId, clientSecret, redirectUri };
}

export function isGoogleConfigured(): boolean {
  return Boolean(
    process.env.GOOGLE_CLIENT_ID &&
      process.env.GOOGLE_CLIENT_SECRET &&
      process.env.FAIT_SESSION_SECRET,
  );
}

export function buildGoogleAuthorizationUrl(
  origin: string,
  state: string,
  mode: GoogleOAuthMode,
): URL {
  const { clientId, redirectUri } = getGoogleConfig(origin);
  const requestedScopes = mode === "compose"
    ? [...IDENTITY_SCOPES, GOOGLE_SCOPE_COMPOSE]
    : [...IDENTITY_SCOPES, GOOGLE_SCOPE_READONLY];

  const url = new URL("https://accounts.google.com/o/oauth2/v2/auth");
  url.searchParams.set("client_id", clientId);
  url.searchParams.set("redirect_uri", redirectUri);
  url.searchParams.set("response_type", "code");
  url.searchParams.set("scope", requestedScopes.join(" "));
  url.searchParams.set("state", state);
  url.searchParams.set("access_type", "offline");
  url.searchParams.set("include_granted_scopes", "true");
  url.searchParams.set("prompt", "consent");
  return url;
}

type GoogleTokenResponse = {
  access_token: string;
  expires_in: number;
  refresh_token?: string;
  scope?: string;
  token_type: string;
  id_token?: string;
};

export async function exchangeGoogleCode(
  origin: string,
  code: string,
): Promise<GoogleTokenResponse> {
  const { clientId, clientSecret, redirectUri } = getGoogleConfig(origin);
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      code,
      grant_type: "authorization_code",
      redirect_uri: redirectUri,
    }),
    cache: "no-store",
  });
  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`Échange OAuth refusé (${response.status}) : ${detail.slice(0, 300)}`);
  }
  return response.json() as Promise<GoogleTokenResponse>;
}

export async function fetchGoogleIdentity(accessToken: string): Promise<{
  email?: string;
  name?: string;
  picture?: string;
}> {
  const response = await fetch("https://www.googleapis.com/oauth2/v2/userinfo", {
    headers: { Authorization: `Bearer ${accessToken}` },
    cache: "no-store",
  });
  if (!response.ok) return {};
  const identity = await response.json() as {
    email?: string;
    name?: string;
    picture?: string;
  };
  return identity;
}

export function mergeGoogleSession(
  previous: GoogleSession | null,
  token: GoogleTokenResponse,
  identity: { email?: string; name?: string; picture?: string },
): GoogleSession {
  const scopes = new Set<string>(previous?.scopes ?? []);
  for (const scope of (token.scope ?? "").split(" ").filter(Boolean)) scopes.add(scope);
  return {
    accessToken: token.access_token,
    refreshToken: token.refresh_token || previous?.refreshToken,
    expiresAt: Date.now() + Math.max(60, token.expires_in - 60) * 1000,
    scopes: [...scopes],
    email: identity.email || previous?.email,
    name: identity.name || previous?.name,
    picture: identity.picture || previous?.picture,
    historyId: previous?.historyId,
    lastSyncAt: previous?.lastSyncAt,
  };
}

export async function ensureFreshGoogleSession(
  origin: string,
  session: GoogleSession,
): Promise<{ session: GoogleSession; refreshed: boolean }> {
  if (session.expiresAt > Date.now() + 30_000) return { session, refreshed: false };
  if (!session.refreshToken) throw new Error("La connexion Google doit être renouvelée.");

  const { clientId, clientSecret } = getGoogleConfig(origin);
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      refresh_token: session.refreshToken,
      grant_type: "refresh_token",
    }),
    cache: "no-store",
  });
  if (!response.ok) {
    const detail = await response.text();
    throw new Error(`Actualisation OAuth impossible (${response.status}) : ${detail.slice(0, 200)}`);
  }
  const token = await response.json() as GoogleTokenResponse;
  return {
    refreshed: true,
    session: {
      ...session,
      accessToken: token.access_token,
      expiresAt: Date.now() + Math.max(60, token.expires_in - 60) * 1000,
      scopes: token.scope ? [...new Set([...session.scopes, ...token.scope.split(" ")])] : session.scopes,
    },
  };
}

export async function revokeGoogleSession(session: GoogleSession): Promise<void> {
  const token = session.refreshToken || session.accessToken;
  try {
    await fetch(`https://oauth2.googleapis.com/revoke?token=${encodeURIComponent(token)}`, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      cache: "no-store",
    });
  } catch {
    // La suppression locale reste prioritaire même si Google est temporairement indisponible.
  }
}
