"use client";

import { useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";

type ViewId = "home" | "cases" | "intake" | "detected" | "profile";
type IconName = "home" | "folder" | "plus" | "spark" | "user" | "mail" | "refresh" | "calendar" | "document" | "check" | "link" | "shield" | "arrow" | "invoice" | "clock" | "logout";
type Category = "invoice" | "appointment" | "contract" | "administrative";

type GoogleStatus = {
  configured: boolean;
  connected: boolean;
  email: string | null;
  name: string | null;
  picture: string | null;
  canRead: boolean;
  canCompose: boolean;
  scopes: string[];
  lastSyncAt: string | null;
};

type DetectedItem = {
  id: string;
  threadId: string;
  messageIdHeader?: string;
  from: string;
  fromEmail: string;
  subject: string;
  snippet: string;
  receivedAt: string;
  category: Category;
  confidence: number;
  amount?: string;
  dateText?: string;
  timeText?: string;
  suggestedAction: string;
  dossierTitle: string;
  suggestedReply: string;
  gmailUrl: string;
};

type Dossier = {
  id: string;
  title: string;
  source: string;
  category: Category;
  nextAction: string;
  createdAt: string;
};

type AgendaEvent = {
  id: string;
  title: string;
  dateText: string;
  timeText?: string;
  source: string;
  createdAt: string;
};

type DraftEditor = {
  item: DetectedItem;
  to: string;
  subject: string;
  body: string;
};

const EMPTY_STATUS: GoogleStatus = {
  configured: false,
  connected: false,
  email: null,
  name: null,
  picture: null,
  canRead: false,
  canCompose: false,
  scopes: [],
  lastSyncAt: null,
};

const dockItems: Array<{ id: ViewId; label: string; icon: IconName }> = [
  { id: "home", label: "Accueil", icon: "home" },
  { id: "cases", label: "Dossiers", icon: "folder" },
  { id: "intake", label: "Confier", icon: "plus" },
  { id: "detected", label: "Détecté", icon: "spark" },
  { id: "profile", label: "Profil", icon: "user" },
];

function Icon({ name, size = 22 }: { name: IconName; size?: number }) {
  const common = {
    width: size,
    height: size,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
    "aria-hidden": true,
  };
  const paths: Record<IconName, ReactNode> = {
    home: <><path d="m3 10 9-7 9 7"/><path d="M5 9.5V21h14V9.5"/><path d="M9 21v-7h6v7"/></>,
    folder: <><path d="M3 6.5h6l2 2h10v9.5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M3 10h18"/></>,
    plus: <><path d="M12 5v14"/><path d="M5 12h14"/></>,
    spark: <><path d="m12 3 1.4 4.1L17.5 8.5l-4.1 1.4L12 14l-1.4-4.1-4.1-1.4 4.1-1.4z"/><path d="m18.5 14 .8 2.2 2.2.8-2.2.8-.8 2.2-.8-2.2-2.2-.8 2.2-.8z"/></>,
    user: <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></>,
    mail: <><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m4 7 8 6 8-6"/></>,
    refresh: <><path d="M20 7v5h-5"/><path d="M4 17v-5h5"/><path d="M6.1 9A7 7 0 0 1 18 6l2 2M18 15a7 7 0 0 1-11.9 3L4 16"/></>,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 10h18"/></>,
    document: <><path d="M6 3h8l4 4v14H6z"/><path d="M14 3v5h5"/><path d="M9 13h6M9 17h6"/></>,
    check: <path d="m5 12 4 4L19 6"/>,
    link: <><path d="M10 13a5 5 0 0 0 7.1.1l2-2a5 5 0 0 0-7.1-7.1l-1.1 1.1"/><path d="M14 11a5 5 0 0 0-7.1-.1l-2 2A5 5 0 0 0 12 20l1.1-1.1"/></>,
    shield: <><path d="M12 3 4.5 6v5.5c0 4.8 3.2 7.7 7.5 9.5 4.3-1.8 7.5-4.7 7.5-9.5V6z"/><path d="m8.5 12 2.2 2.2 4.8-5"/></>,
    arrow: <><path d="M5 12h14"/><path d="m14 7 5 5-5 5"/></>,
    invoice: <><path d="M6 3h12v18l-3-2-3 2-3-2-3 2z"/><path d="M9 8h6M9 12h6M9 16h3"/></>,
    clock: <><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>,
    logout: <><path d="M10 17l5-5-5-5M15 12H3"/><path d="M14 3h5a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-5"/></>,
  };
  return <svg {...common}>{paths[name]}</svg>;
}

function Brand() {
  return <img className="gp-brand-logo" src="/brand/fait-logo.svg" alt="FAIT. — Vous demandez. C’est fait." />;
}

function categoryMeta(category: Category): { label: string; icon: IconName } {
  if (category === "invoice") return { label: "Facture", icon: "invoice" };
  if (category === "appointment") return { label: "Rendez-vous", icon: "calendar" };
  if (category === "contract") return { label: "Contrat", icon: "document" };
  return { label: "Démarche", icon: "folder" };
}

function formatDate(value: string): string {
  try {
    return new Intl.DateTimeFormat("fr-FR", { dateStyle: "medium", timeStyle: "short" }).format(new Date(value));
  } catch {
    return value;
  }
}

async function readJson<T>(response: Response): Promise<T> {
  const data = await response.json() as T & { error?: string; detail?: string };
  if (!response.ok) throw new Error(data.detail || data.error || `Erreur ${response.status}`);
  return data;
}

export function FaitGmailPilot() {
  const [view, setView] = useState<ViewId>("home");
  const [status, setStatus] = useState<GoogleStatus>(EMPTY_STATUS);
  const [items, setItems] = useState<DetectedItem[]>([]);
  const [dossiers, setDossiers] = useState<Dossier[]>([]);
  const [agenda, setAgenda] = useState<AgendaEvent[]>([]);
  const [loadingStatus, setLoadingStatus] = useState(true);
  const [syncing, setSyncing] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [draft, setDraft] = useState<DraftEditor | null>(null);
  const [creatingDraft, setCreatingDraft] = useState(false);

  const appointments = useMemo(() => items.filter((item) => item.category === "appointment"), [items]);

  useEffect(() => {
    const storedDossiers = window.localStorage.getItem("fait_gmail_pilot_dossiers");
    const storedAgenda = window.localStorage.getItem("fait_gmail_pilot_agenda");
    if (storedDossiers) setDossiers(JSON.parse(storedDossiers) as Dossier[]);
    if (storedAgenda) setAgenda(JSON.parse(storedAgenda) as AgendaEvent[]);

    const params = new URLSearchParams(window.location.search);
    const gmail = params.get("gmail");
    if (gmail === "connected") setNotice("Gmail est connecté en lecture seule.");
    if (gmail === "compose-connected") setNotice("La création de brouillons Gmail est autorisée.");
    if (gmail === "not-configured") setError("Les identifiants OAuth Google ne sont pas encore configurés dans Vercel.");
    if (gmail === "error") setError(`Connexion Google refusée : ${params.get("reason") || "erreur inconnue"}`);
    if (gmail) window.history.replaceState({}, "", window.location.pathname);

    void refreshStatus();
  }, []);

  useEffect(() => {
    window.localStorage.setItem("fait_gmail_pilot_dossiers", JSON.stringify(dossiers));
  }, [dossiers]);

  useEffect(() => {
    window.localStorage.setItem("fait_gmail_pilot_agenda", JSON.stringify(agenda));
  }, [agenda]);

  async function refreshStatus() {
    setLoadingStatus(true);
    try {
      const response = await fetch("/api/google/oauth/status", { cache: "no-store" });
      setStatus(await readJson<GoogleStatus>(response));
    } catch (statusError) {
      setError(statusError instanceof Error ? statusError.message : "Statut Google indisponible");
    } finally {
      setLoadingStatus(false);
    }
  }

  async function synchronize() {
    setSyncing(true);
    setError(null);
    try {
      const response = await fetch("/api/gmail/sync", { method: "POST" });
      const result = await readJson<{ items: DetectedItem[]; mode: string; lastSyncAt: string }>(response);
      setItems(result.items);
      setStatus((current) => ({ ...current, lastSyncAt: result.lastSyncAt }));
      setNotice(`${result.items.length} message(s) utile(s) détecté(s). Synchronisation ${result.mode === "incremental" ? "incrémentale" : "complète"}.`);
      setView("detected");
    } catch (syncError) {
      setError(syncError instanceof Error ? syncError.message : "Synchronisation impossible");
    } finally {
      setSyncing(false);
    }
  }

  function createDossier(item: DetectedItem) {
    if (dossiers.some((entry) => entry.id === item.id)) {
      setNotice("Ce message est déjà rattaché à un dossier.");
      return;
    }
    setDossiers((current) => [{
      id: item.id,
      title: item.dossierTitle,
      source: `Gmail · ${item.from}`,
      category: item.category,
      nextAction: item.suggestedAction,
      createdAt: new Date().toISOString(),
    }, ...current]);
    setNotice("Le dossier a été créé localement dans FAIT.");
  }

  function addToAgenda(item: DetectedItem) {
    if (!item.dateText) {
      setError("Aucune date suffisamment fiable n’a été détectée dans ce message.");
      return;
    }
    if (agenda.some((event) => event.id === item.id)) {
      setNotice("Ce rendez-vous existe déjà dans l’agenda FAIT.");
      return;
    }
    setAgenda((current) => [{
      id: item.id,
      title: item.subject,
      dateText: item.dateText || "Date à confirmer",
      timeText: item.timeText,
      source: `Gmail · ${item.from}`,
      createdAt: new Date().toISOString(),
    }, ...current]);
    createDossier(item);
    setNotice("Le rendez-vous a été ajouté à l’agenda interne FAIT. Aucun calendrier externe n’a été modifié.");
  }

  function openDraft(item: DetectedItem) {
    setDraft({
      item,
      to: item.fromEmail,
      subject: item.subject.toLowerCase().startsWith("re:") ? item.subject : `Re: ${item.subject}`,
      body: item.suggestedReply,
    });
  }

  async function saveDraft() {
    if (!draft) return;
    setCreatingDraft(true);
    setError(null);
    try {
      const response = await fetch("/api/gmail/drafts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          to: draft.to,
          subject: draft.subject,
          body: draft.body,
          threadId: draft.item.threadId,
          inReplyTo: draft.item.messageIdHeader,
        }),
      });
      const result = await readJson<{ draft: { id: string }; sent: boolean }>(response);
      createDossier(draft.item);
      setDraft(null);
      setNotice(`Brouillon Gmail créé (${result.draft.id}). Aucun e-mail n’a été envoyé.`);
    } catch (draftError) {
      setError(draftError instanceof Error ? draftError.message : "Création du brouillon impossible");
    } finally {
      setCreatingDraft(false);
    }
  }

  async function disconnect() {
    await fetch("/api/google/oauth/disconnect", { method: "POST" });
    setStatus(EMPTY_STATUS);
    setItems([]);
    setNotice("La connexion Google a été révoquée et la session locale supprimée.");
  }

  return (
    <div className="gp-shell">
      <div className="gp-ambient gp-ambient--one" aria-hidden="true" />
      <div className="gp-ambient gp-ambient--two" aria-hidden="true" />

      <header className="gp-topbar">
        <button className="gp-brand" type="button" onClick={() => setView("home")}><Brand /></button>
        <div className="gp-environment"><span /> Pilote Gmail OAuth · environnement test</div>
        <div className="gp-top-actions">
          <button type="button" onClick={() => setView("profile")}><Icon name="link" size={18}/>{status.connected ? status.email : "Connexions"}</button>
          <button className="gp-avatar" type="button" onClick={() => setView("profile")}>{status.picture ? <img src={status.picture} alt=""/> : "CG"}</button>
        </div>
      </header>

      {(notice || error) ? <div className={`gp-toast ${error ? "is-error" : ""}`}><Icon name={error ? "shield" : "check"} size={18}/><span>{error || notice}</span><button type="button" onClick={() => { setError(null); setNotice(null); }}>×</button></div> : null}

      <main className="gp-main">
        {view === "home" ? <Home
          status={status}
          loadingStatus={loadingStatus}
          syncing={syncing}
          items={items}
          agenda={agenda}
          onSync={synchronize}
          onConnect={() => { window.location.href = "/api/google/oauth/start?mode=read"; }}
          onNavigate={setView}
        /> : null}
        {view === "detected" ? <Detected
          items={items}
          status={status}
          syncing={syncing}
          onSync={synchronize}
          onDossier={createDossier}
          onAgenda={addToAgenda}
          onDraft={openDraft}
        /> : null}
        {view === "cases" ? <Cases dossiers={dossiers}/> : null}
        {view === "intake" ? <Intake onSync={synchronize} connected={status.connected}/> : null}
        {view === "profile" ? <Profile status={status} onDisconnect={disconnect} onRefresh={refreshStatus}/> : null}
      </main>

      <nav className="gp-dock" aria-label="Navigation principale">
        {dockItems.map((item) => <button key={item.id} type="button" className={`${view === item.id ? "is-active" : ""} ${item.id === "intake" ? "is-primary" : ""}`} onClick={() => setView(item.id)}><span><Icon name={item.icon} size={item.id === "intake" ? 24 : 20}/>{item.id === "detected" && items.length ? <i>{items.length}</i> : null}</span><small>{item.label}</small></button>)}
      </nav>

      {draft ? <DraftModal
        editor={draft}
        canCompose={status.canCompose}
        creating={creatingDraft}
        onChange={setDraft}
        onClose={() => setDraft(null)}
        onAuthorize={() => { window.location.href = "/api/google/oauth/start?mode=compose"; }}
        onSave={saveDraft}
      /> : null}
    </div>
  );
}

function Home({ status, loadingStatus, syncing, items, agenda, onSync, onConnect, onNavigate }: {
  status: GoogleStatus;
  loadingStatus: boolean;
  syncing: boolean;
  items: DetectedItem[];
  agenda: AgendaEvent[];
  onSync: () => void;
  onConnect: () => void;
  onNavigate: (view: ViewId) => void;
}) {
  return <div className="gp-page gp-home">
    <section className="gp-hero">
      <span className="gp-kicker">Premier circuit réel</span>
      <h1>Votre quotidien commence à se ranger tout seul.</h1>
      <p>FAIT. lit uniquement la boîte Gmail que vous autorisez, repère les messages utiles et vous propose la prochaine action. Rien n’est envoyé automatiquement.</p>
      <div className="gp-hero-actions">
        {!status.connected ? <button className="gp-primary" type="button" disabled={loadingStatus || !status.configured} onClick={onConnect}><Icon name="mail" size={20}/>Connecter Gmail en lecture seule</button> : <button className="gp-primary" type="button" disabled={syncing || !status.canRead} onClick={onSync}><Icon name="refresh" size={20}/>{syncing ? "Analyse en cours…" : "Analyser les nouveaux e-mails"}</button>}
        <button className="gp-secondary" type="button" onClick={() => onNavigate("profile")}><Icon name="shield" size={19}/>Voir les autorisations</button>
      </div>
      {!status.configured ? <div className="gp-config-warning"><Icon name="shield" size={18}/><span>Le code est prêt. Les variables Google doivent encore être ajoutées dans Vercel pour activer la connexion.</span></div> : null}
      <div className="gp-trust-row"><span><Icon name="check" size={15}/>Lecture séparée</span><span><Icon name="check" size={15}/>Brouillons autorisés à part</span><span><Icon name="check" size={15}/>Aucun endpoint d’envoi</span></div>
    </section>

    <section className="gp-overview">
      <article><span>Connexion</span><strong>{status.connected ? "Gmail relié" : "À connecter"}</strong><small>{status.email || "OAuth Google côté serveur"}</small></article>
      <article><span>Détecté</span><strong>{items.length}</strong><small>Messages utiles dans la dernière analyse</small></article>
      <article><span>Agenda FAIT.</span><strong>{agenda.length}</strong><small>Événements locaux, non synchronisés</small></article>
    </section>

    <section className="gp-section">
      <div className="gp-section-heading"><div><span className="gp-kicker">Ce qui mérite votre attention</span><h2>{items.length ? "FAIT. a préparé la suite." : "La boîte intelligente est prête."}</h2></div><button type="button" onClick={() => onNavigate("detected")}>Tout voir <Icon name="arrow" size={17}/></button></div>
      {items.length ? <div className="gp-preview-grid">{items.slice(0, 3).map((item) => <SignalCard key={item.id} item={item} compact onOpen={() => onNavigate("detected")}/>)}</div> : <div className="gp-empty"><Icon name="spark" size={28}/><h3>Aucune analyse réelle pour le moment</h3><p>Connectez Gmail puis lancez une première synchronisation manuelle. FAIT. ne lit rien avant cette action.</p></div>}
    </section>

    <section className="gp-agenda-strip">
      <div><span className="gp-kicker">Agenda interne</span><h2>Les rendez-vous restent reliés à leur source.</h2></div>
      {agenda.length ? <div className="gp-agenda-items">{agenda.slice(0, 3).map((event) => <article key={event.id}><Icon name="calendar" size={20}/><span><strong>{event.title}</strong><small>{event.dateText}{event.timeText ? ` · ${event.timeText}` : ""}</small></span></article>)}</div> : <p>Les rendez-vous ajoutés depuis Gmail apparaîtront ici avant toute synchronisation iPhone ou Android.</p>}
    </section>
  </div>;
}

function Detected({ items, status, syncing, onSync, onDossier, onAgenda, onDraft }: {
  items: DetectedItem[];
  status: GoogleStatus;
  syncing: boolean;
  onSync: () => void;
  onDossier: (item: DetectedItem) => void;
  onAgenda: (item: DetectedItem) => void;
  onDraft: (item: DetectedItem) => void;
}) {
  return <div className="gp-page">
    <section className="gp-page-title"><span className="gp-kicker">Boîte intelligente</span><h1>Les messages utiles, séparés du bruit.</h1><p>Chaque proposition reste liée au message source et doit être confirmée avant de modifier Gmail ou l’agenda.</p><button className="gp-secondary" type="button" disabled={!status.canRead || syncing} onClick={onSync}><Icon name="refresh" size={18}/>{syncing ? "Synchronisation…" : "Rechercher les nouveautés"}</button></section>
    {items.length ? <div className="gp-signal-list">{items.map((item) => <SignalCard key={item.id} item={item} onDossier={() => onDossier(item)} onAgenda={() => onAgenda(item)} onDraft={() => onDraft(item)}/>)}</div> : <div className="gp-empty"><Icon name="mail" size={30}/><h3>Aucun message utile chargé</h3><p>Lancez une synchronisation après avoir autorisé la lecture Gmail.</p></div>}
  </div>;
}

function SignalCard({ item, compact = false, onOpen, onDossier, onAgenda, onDraft }: {
  item: DetectedItem;
  compact?: boolean;
  onOpen?: () => void;
  onDossier?: () => void;
  onAgenda?: () => void;
  onDraft?: () => void;
}) {
  const meta = categoryMeta(item.category);
  return <article className={`gp-signal ${compact ? "is-compact" : ""}`}>
    <div className="gp-signal-icon"><Icon name={meta.icon} size={22}/></div>
    <div className="gp-signal-body">
      <div className="gp-signal-meta"><span>{meta.label}</span><span>Confiance {item.confidence}%</span><span>{formatDate(item.receivedAt)}</span></div>
      <h3>{item.subject}</h3>
      <p>{item.snippet || item.suggestedAction}</p>
      <div className="gp-signal-facts">{item.amount ? <span>{item.amount}</span> : null}{item.dateText ? <span>{item.dateText}{item.timeText ? ` · ${item.timeText}` : ""}</span> : null}<a href={item.gmailUrl} target="_blank" rel="noreferrer">Voir la source Gmail</a></div>
      {compact ? <button className="gp-text-button" type="button" onClick={onOpen}>Examiner <Icon name="arrow" size={16}/></button> : <div className="gp-signal-actions"><button type="button" onClick={onDossier}><Icon name="folder" size={17}/>Créer le dossier</button>{item.category === "appointment" ? <button type="button" onClick={onAgenda}><Icon name="calendar" size={17}/>Ajouter à l’agenda</button> : null}<button type="button" onClick={onDraft}><Icon name="mail" size={17}/>Préparer une réponse</button></div>}
    </div>
  </article>;
}

function Cases({ dossiers }: { dossiers: Dossier[] }) {
  return <div className="gp-page"><section className="gp-page-title"><span className="gp-kicker">Mémoire du quotidien</span><h1>Les messages deviennent des dossiers suivis.</h1><p>Dans ce pilote, les dossiers sont conservés localement dans le navigateur. Le futur backend assurera la synchronisation sécurisée multi-appareils.</p></section>{dossiers.length ? <div className="gp-case-grid">{dossiers.map((dossier) => <article key={dossier.id}><span className="gp-case-icon"><Icon name={categoryMeta(dossier.category).icon} size={21}/></span><div><small>{categoryMeta(dossier.category).label} · {formatDate(dossier.createdAt)}</small><h3>{dossier.title}</h3><p>{dossier.nextAction}</p><span>{dossier.source}</span></div></article>)}</div> : <div className="gp-empty"><Icon name="folder" size={30}/><h3>Aucun dossier réel créé</h3><p>Depuis l’onglet Détecté, choisissez un message puis confirmez « Créer le dossier ».</p></div>}</div>;
}

function Intake({ connected, onSync }: { connected: boolean; onSync: () => void }) {
  return <div className="gp-page gp-intake"><section className="gp-page-title"><span className="gp-kicker">Le point d’entrée reste ouvert</span><h1>Confier quelque chose manuellement.</h1><p>La détection Gmail complète l’usage initial de FAIT. Elle ne remplace jamais la possibilité de déposer un document ou d’expliquer une situation.</p></section><div className="gp-intake-options"><button type="button"><Icon name="document" size={24}/><span><strong>Déposer un document</strong><small>Prochaine étape du pilote</small></span></button><button type="button" onClick={connected ? onSync : undefined}><Icon name="mail" size={24}/><span><strong>Analyser Gmail</strong><small>{connected ? "Rechercher maintenant" : "Connexion requise"}</small></span></button><button type="button"><Icon name="plus" size={24}/><span><strong>Décrire une situation</strong><small>Parcours manuel conservé</small></span></button></div></div>;
}

function Profile({ status, onDisconnect, onRefresh }: { status: GoogleStatus; onDisconnect: () => void; onRefresh: () => void }) {
  return <div className="gp-page"><section className="gp-page-title"><span className="gp-kicker">Connexions et autorisations</span><h1>Vous voyez exactement ce que FAIT. peut faire.</h1><p>La lecture Gmail et la création de brouillons sont demandées séparément. La permission de composition accordée par Google permet techniquement l’envoi, mais ce pilote ne contient volontairement aucun endpoint d’envoi.</p></section><section className="gp-connection-card"><div className="gp-service-icon"><Icon name="mail" size={26}/></div><div className="gp-connection-main"><span>Google Gmail</span><h2>{status.connected ? status.email : "Non connecté"}</h2><p>{status.connected ? `Dernière synchronisation : ${status.lastSyncAt ? formatDate(status.lastSyncAt) : "jamais"}` : "Connexion OAuth côté serveur avec révocation immédiate."}</p></div><span className={`gp-connection-state ${status.connected ? "is-on" : ""}`}>{status.connected ? "Connecté" : "Inactif"}</span></section><div className="gp-permission-grid"><article><Icon name="mail" size={22}/><span><strong>Lecture Gmail</strong><small>Messages et paramètres en lecture seule</small></span><b className={status.canRead ? "is-on" : ""}>{status.canRead ? "Accordée" : "Non accordée"}</b>{!status.canRead ? <a href="/api/google/oauth/start?mode=read">Autoriser</a> : null}</article><article><Icon name="document" size={22}/><span><strong>Création de brouillons</strong><small>Demandée uniquement lors du premier brouillon</small></span><b className={status.canCompose ? "is-on" : ""}>{status.canCompose ? "Accordée" : "Non accordée"}</b>{!status.canCompose ? <a href="/api/google/oauth/start?mode=compose">Autoriser</a> : null}</article><article><Icon name="shield" size={22}/><span><strong>Envoi automatique</strong><small>Aucun endpoint n’existe dans le pilote</small></span><b>Bloqué</b></article><article><Icon name="calendar" size={22}/><span><strong>Calendriers externes</strong><small>Agenda FAIT. local uniquement</small></span><b>Non connecté</b></article></div><div className="gp-profile-actions"><button className="gp-secondary" type="button" onClick={onRefresh}><Icon name="refresh" size={17}/>Actualiser</button>{status.connected ? <button className="gp-danger" type="button" onClick={onDisconnect}><Icon name="logout" size={17}/>Révoquer Google</button> : null}</div></div>;
}

function DraftModal({ editor, canCompose, creating, onChange, onClose, onAuthorize, onSave }: {
  editor: DraftEditor;
  canCompose: boolean;
  creating: boolean;
  onChange: (editor: DraftEditor) => void;
  onClose: () => void;
  onAuthorize: () => void;
  onSave: () => void;
}) {
  return <div className="gp-modal-backdrop" role="presentation" onMouseDown={(event) => { if (event.target === event.currentTarget) onClose(); }}><section className="gp-modal" role="dialog" aria-modal="true" aria-label="Préparer un brouillon Gmail"><header><div><span className="gp-kicker">Brouillon Gmail</span><h2>Préparer sans envoyer.</h2></div><button type="button" onClick={onClose}>×</button></header><div className="gp-policy"><Icon name="shield" size={18}/><span>La seule action disponible est <strong>Créer le brouillon</strong>. L’envoi reste entièrement dans Gmail.</span></div><label><span>Destinataire</span><input value={editor.to} onChange={(event) => onChange({ ...editor, to: event.target.value })}/></label><label><span>Objet</span><input value={editor.subject} onChange={(event) => onChange({ ...editor, subject: event.target.value })}/></label><label><span>Message</span><textarea rows={10} value={editor.body} onChange={(event) => onChange({ ...editor, body: event.target.value })}/></label><footer><button className="gp-secondary" type="button" onClick={onClose}>Annuler</button>{canCompose ? <button className="gp-primary" type="button" disabled={creating} onClick={onSave}><Icon name="document" size={18}/>{creating ? "Création…" : "Créer dans les brouillons Gmail"}</button> : <button className="gp-primary" type="button" onClick={onAuthorize}><Icon name="link" size={18}/>Autoriser les brouillons</button>}</footer></section></div>;
}
