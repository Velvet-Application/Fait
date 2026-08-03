export type GmailDetectedCategory = "invoice" | "appointment" | "contract" | "administrative";

export type GmailDetectedItem = {
  id: string;
  threadId: string;
  messageIdHeader?: string;
  from: string;
  fromEmail: string;
  subject: string;
  snippet: string;
  receivedAt: string;
  category: GmailDetectedCategory;
  confidence: number;
  amount?: string;
  dateText?: string;
  timeText?: string;
  suggestedAction: string;
  dossierTitle: string;
  suggestedReply: string;
  gmailUrl: string;
};

type GmailHeader = { name: string; value: string };
type GmailPart = {
  mimeType?: string;
  filename?: string;
  body?: { data?: string; size?: number };
  parts?: GmailPart[];
  headers?: GmailHeader[];
};
type GmailMessage = {
  id: string;
  threadId: string;
  historyId?: string;
  internalDate?: string;
  snippet?: string;
  payload?: GmailPart;
};

type GmailProfile = { historyId?: string };

type GmailListResponse = { messages?: Array<{ id: string; threadId: string }> };
type GmailHistoryResponse = {
  history?: Array<{ messagesAdded?: Array<{ message: { id: string; threadId: string } }> }>;
  historyId?: string;
  nextPageToken?: string;
};

async function gmailRequest<T>(
  accessToken: string,
  path: string,
  init?: RequestInit,
): Promise<T> {
  const response = await fetch(`https://gmail.googleapis.com/gmail/v1${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
      ...(init?.headers ?? {}),
    },
    cache: "no-store",
  });
  if (!response.ok) {
    const detail = await response.text();
    const error = new Error(`Gmail API ${response.status}: ${detail.slice(0, 300)}`) as Error & { status?: number };
    error.status = response.status;
    throw error;
  }
  return response.json() as Promise<T>;
}

function header(message: GmailMessage, name: string): string {
  return message.payload?.headers?.find((item) => item.name.toLowerCase() === name.toLowerCase())?.value ?? "";
}

function decodeBase64Url(value?: string): string {
  if (!value) return "";
  try {
    return Buffer.from(value, "base64url").toString("utf8");
  } catch {
    return "";
  }
}

function stripHtml(value: string): string {
  return value
    .replace(/<style[\s\S]*?<\/style>/gi, " ")
    .replace(/<script[\s\S]*?<\/script>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/&nbsp;/gi, " ")
    .replace(/&amp;/gi, "&")
    .replace(/&lt;/gi, "<")
    .replace(/&gt;/gi, ">")
    .replace(/\s+/g, " ")
    .trim();
}

function extractText(part?: GmailPart): string {
  if (!part) return "";
  const own = decodeBase64Url(part.body?.data);
  if (part.mimeType === "text/plain" && own) return own;
  if (part.mimeType === "text/html" && own) return stripHtml(own);
  const children = (part.parts ?? []).map(extractText).filter(Boolean);
  return children.join("\n");
}

function extractEmail(value: string): string {
  const match = value.match(/<([^>]+)>/) || value.match(/[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}/);
  return (match?.[1] || match?.[0] || value).trim();
}

const MONTHS = "janvier|février|fevrier|mars|avril|mai|juin|juillet|août|aout|septembre|octobre|novembre|décembre|decembre";

function extractDateText(text: string): string | undefined {
  const textual = text.match(new RegExp(`\\b\\d{1,2}\\s+(?:${MONTHS})(?:\\s+20\\d{2})?\\b`, "i"));
  if (textual) return textual[0];
  const numeric = text.match(/\b\d{1,2}[\/.\-]\d{1,2}[\/.\-](?:20)?\d{2}\b/);
  return numeric?.[0];
}

function extractTimeText(text: string): string | undefined {
  const match = text.match(/\b(?:[01]?\d|2[0-3])(?:\s?h\s?|:)[0-5]\d\b/i);
  return match?.[0]?.replace(/\s+/g, " ");
}

function extractAmount(text: string): string | undefined {
  const match = text.match(/\b\d{1,5}(?:[\s.]\d{3})*(?:[,.]\d{2})?\s?€\b/);
  return match?.[0];
}

function includesAny(text: string, words: string[]): number {
  return words.reduce((score, word) => score + (text.includes(word) ? 1 : 0), 0);
}

function classify(message: GmailMessage): GmailDetectedItem | null {
  const subject = header(message, "Subject") || "Sans objet";
  const from = header(message, "From") || "Expéditeur inconnu";
  const body = extractText(message.payload).slice(0, 12_000);
  const combined = `${subject} ${message.snippet ?? ""} ${body}`.toLowerCase();

  const scores: Record<GmailDetectedCategory, number> = {
    invoice: includesAny(combined, ["facture", "invoice", "prélèvement", "prelevement", "montant", "échéance de paiement", "à payer", "a payer"]),
    appointment: includesAny(combined, ["rendez-vous", "rendez vous", "rdv", "appointment", "consultation", "convocation", "réservation confirmée", "reservation confirmee"]),
    contract: includesAny(combined, ["contrat", "abonnement", "tarif", "augmentation", "hausse", "résiliation", "resiliation", "renouvellement"]),
    administrative: includesAny(combined, ["justificatif", "document demandé", "document demande", "dossier", "formulaire", "attestation", "démarche", "demarche"]),
  };

  const ranked = (Object.entries(scores) as Array<[GmailDetectedCategory, number]>).sort((a, b) => b[1] - a[1]);
  const [category, score] = ranked[0];
  if (score < 1) return null;

  const confidence = Math.min(98, 62 + score * 9);
  const dateText = extractDateText(combined);
  const timeText = extractTimeText(combined);
  const amount = extractAmount(combined);
  const fromEmail = extractEmail(from);
  const receivedAt = message.internalDate
    ? new Date(Number(message.internalDate)).toISOString()
    : new Date().toISOString();

  const content: Record<GmailDetectedCategory, {
    action: string;
    dossier: string;
    reply: string;
  }> = {
    invoice: {
      action: amount ? `Vérifier la facture de ${amount}` : "Vérifier et classer la facture",
      dossier: `Facture — ${subject}`,
      reply: "Bonjour,\n\nMerci pour votre message. Je vous confirme la bonne réception de la facture.\n\nCordialement,",
    },
    appointment: {
      action: dateText ? `Ajouter le rendez-vous du ${dateText} à l’agenda` : "Vérifier le rendez-vous et l’ajouter à l’agenda",
      dossier: `Rendez-vous — ${subject}`,
      reply: "Bonjour,\n\nMerci pour votre message. Je vous confirme avoir pris connaissance du rendez-vous.\n\nCordialement,",
    },
    contract: {
      action: "Examiner l’impact du contrat et préparer une réponse",
      dossier: `Contrat — ${subject}`,
      reply: "Bonjour,\n\nJ’ai pris connaissance de votre message concernant mon contrat. Merci de me confirmer les conditions applicables et les options disponibles.\n\nCordialement,",
    },
    administrative: {
      action: "Créer un dossier et préparer les pièces demandées",
      dossier: `Démarche — ${subject}`,
      reply: "Bonjour,\n\nMerci pour votre message. Je prépare les éléments demandés et reviendrai vers vous avec les pièces nécessaires.\n\nCordialement,",
    },
  };

  return {
    id: message.id,
    threadId: message.threadId,
    messageIdHeader: header(message, "Message-ID") || header(message, "Message-Id") || undefined,
    from,
    fromEmail,
    subject,
    snippet: stripHtml(message.snippet || body).slice(0, 280),
    receivedAt,
    category,
    confidence,
    amount,
    dateText,
    timeText,
    suggestedAction: content[category].action,
    dossierTitle: content[category].dossier,
    suggestedReply: content[category].reply,
    gmailUrl: `https://mail.google.com/mail/u/0/#inbox/${message.threadId}`,
  };
}

async function getMessages(accessToken: string, ids: string[]): Promise<GmailMessage[]> {
  const unique = [...new Set(ids)].slice(0, 25);
  return Promise.all(unique.map((id) => gmailRequest<GmailMessage>(
    accessToken,
    `/users/me/messages/${encodeURIComponent(id)}?format=full`,
  )));
}

async function fullSync(accessToken: string): Promise<{ messages: GmailMessage[]; historyId?: string }> {
  const query = encodeURIComponent("newer_than:21d in:inbox -category:promotions -category:social");
  const list = await gmailRequest<GmailListResponse>(
    accessToken,
    `/users/me/messages?maxResults=25&q=${query}`,
  );
  const messages = await getMessages(accessToken, (list.messages ?? []).map((item) => item.id));
  const profile = await gmailRequest<GmailProfile>(accessToken, "/users/me/profile");
  return { messages, historyId: profile.historyId };
}

async function incrementalSync(accessToken: string, startHistoryId: string): Promise<{ messages: GmailMessage[]; historyId?: string }> {
  const ids: string[] = [];
  let pageToken: string | undefined;
  let latestHistoryId: string | undefined;
  do {
    const params = new URLSearchParams({
      startHistoryId,
      historyTypes: "messageAdded",
      maxResults: "100",
    });
    if (pageToken) params.set("pageToken", pageToken);
    const history = await gmailRequest<GmailHistoryResponse>(
      accessToken,
      `/users/me/history?${params.toString()}`,
    );
    for (const item of history.history ?? []) {
      for (const added of item.messagesAdded ?? []) ids.push(added.message.id);
    }
    latestHistoryId = history.historyId || latestHistoryId;
    pageToken = history.nextPageToken;
  } while (pageToken && ids.length < 100);

  const messages = await getMessages(accessToken, ids);
  return { messages, historyId: latestHistoryId || startHistoryId };
}

export async function syncUsefulGmailMessages(
  accessToken: string,
  startHistoryId?: string,
): Promise<{ items: GmailDetectedItem[]; historyId?: string; mode: "full" | "incremental" }> {
  let result: { messages: GmailMessage[]; historyId?: string };
  let mode: "full" | "incremental" = "full";
  if (startHistoryId) {
    try {
      result = await incrementalSync(accessToken, startHistoryId);
      mode = "incremental";
    } catch (error) {
      if ((error as Error & { status?: number }).status !== 404) throw error;
      result = await fullSync(accessToken);
    }
  } else {
    result = await fullSync(accessToken);
  }

  const items = result.messages
    .map(classify)
    .filter((item): item is GmailDetectedItem => Boolean(item))
    .sort((a, b) => Date.parse(b.receivedAt) - Date.parse(a.receivedAt));

  return { items, historyId: result.historyId, mode };
}

function safeHeader(value: string): string {
  return value.replace(/[\r\n]+/g, " ").trim();
}

export async function createGmailDraft(
  accessToken: string,
  input: {
    to: string;
    subject: string;
    body: string;
    threadId?: string;
    inReplyTo?: string;
  },
): Promise<{ id: string; messageId?: string; threadId?: string }> {
  const headers = [
    `To: ${safeHeader(input.to)}`,
    `Subject: ${safeHeader(input.subject)}`,
    "Content-Type: text/plain; charset=UTF-8",
    "MIME-Version: 1.0",
  ];
  if (input.inReplyTo) {
    headers.push(`In-Reply-To: ${safeHeader(input.inReplyTo)}`);
    headers.push(`References: ${safeHeader(input.inReplyTo)}`);
  }
  const raw = Buffer.from(`${headers.join("\r\n")}\r\n\r\n${input.body}`, "utf8").toString("base64url");
  const draft = await gmailRequest<{
    id: string;
    message?: { id?: string; threadId?: string };
  }>(accessToken, "/users/me/drafts", {
    method: "POST",
    body: JSON.stringify({
      message: {
        raw,
        ...(input.threadId ? { threadId: input.threadId } : {}),
      },
    }),
  });
  return {
    id: draft.id,
    messageId: draft.message?.id,
    threadId: draft.message?.threadId,
  };
}
