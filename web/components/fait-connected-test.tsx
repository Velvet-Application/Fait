"use client";

import { useMemo, useState } from "react";
import type { ReactNode } from "react";

type ViewId = "home" | "cases" | "intake" | "notifications" | "profile";
type IconName = "home" | "folder" | "plus" | "bell" | "user" | "check" | "arrow" | "document" | "clock" | "shield" | "mail" | "calendar" | "invoice" | "link" | "settings" | "spark" | "child" | "send" | "refresh";
type SignalKind = "invoice" | "appointment" | "contract" | "vacation";
type SignalState = "Détecté" | "Préparé" | "À confirmer" | "Synchronisé" | "Fait";
type Overlay = "none" | "draft" | "calendar" | "vacation" | "connections";
type ProfileTab = "identity" | "connections" | "autonomy";

type Signal = {
  id: string;
  kind: SignalKind;
  source: string;
  receivedAt: string;
  title: string;
  summary: string;
  state: SignalState;
  action: string;
  date?: string;
  amount?: string;
};

type AgendaEvent = {
  id: string;
  day: string;
  time: string;
  title: string;
  detail: string;
  source: string;
  synced: boolean;
};

const initialSignals: Signal[] = [
  {
    id: "invoice-energy",
    kind: "invoice",
    source: "Gmail · Énergie Démo",
    receivedAt: "Aujourd’hui à 08:12",
    title: "Facture d’électricité disponible",
    summary: "Montant détecté : 86,40 €. Prélèvement prévu le 14 août. La facture peut être classée dans le dossier Logement.",
    state: "Préparé",
    action: "Vérifier le classement",
    amount: "86,40 €",
    date: "14 août 2026",
  },
  {
    id: "appointment-dentist",
    kind: "appointment",
    source: "Gmail · Cabinet dentaire",
    receivedAt: "Aujourd’hui à 09:03",
    title: "Rendez-vous dentaire confirmé",
    summary: "Rendez-vous détecté le 18 août à 16 h 30. FAIT. propose un rappel 24 h avant et un ajout au calendrier iPhone.",
    state: "À confirmer",
    action: "Ajouter à l’agenda",
    date: "18 août 2026 · 16 h 30",
  },
  {
    id: "contract-internet",
    kind: "contract",
    source: "Gmail · Opérateur Démo",
    receivedAt: "Hier à 18:44",
    title: "Hausse tarifaire de l’abonnement Internet",
    summary: "Le tarif augmente de 4 € par mois à partir de septembre. Un brouillon de demande commerciale est prêt.",
    state: "Préparé",
    action: "Examiner le brouillon",
    amount: "+4 €/mois",
    date: "1 septembre 2026",
  },
  {
    id: "vacation-center",
    kind: "vacation",
    source: "Kiosque Famille · Ville Démo",
    receivedAt: "Anticipé par FAIT.",
    title: "Inscriptions au centre aéré bientôt ouvertes",
    summary: "Les vacances approchent. FAIT. a préparé une simulation d’inscription pour Inès sur la première semaine.",
    state: "À confirmer",
    action: "Vérifier l’inscription",
    amount: "42 € estimés",
    date: "24 au 28 août 2026",
  },
];

const initialEvents: AgendaEvent[] = [
  { id: "evt-1", day: "12", time: "18:00", title: "Échéance CAF", detail: "Dernier contrôle avant envoi", source: "Dossier CAF", synced: true },
  { id: "evt-2", day: "18", time: "16:30", title: "Dentiste", detail: "Cabinet dentaire · Lille", source: "Détecté dans Gmail", synced: false },
  { id: "evt-3", day: "24", time: "08:30", title: "Centre aéré", detail: "Début de la semaine préparée", source: "Kiosque Famille", synced: false },
];

const dockItems: Array<{ id: ViewId; label: string; icon: IconName }> = [
  { id: "home", label: "Accueil", icon: "home" },
  { id: "cases", label: "Dossiers", icon: "folder" },
  { id: "intake", label: "Confier", icon: "plus" },
  { id: "notifications", label: "Détecté", icon: "spark" },
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
    bell: <><path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"/><path d="M10 21h4"/></>,
    user: <><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></>,
    check: <path d="m5 12 4 4L19 6"/>,
    arrow: <><path d="M5 12h14"/><path d="m14 7 5 5-5 5"/></>,
    document: <><path d="M6 3h8l4 4v14H6z"/><path d="M14 3v5h5"/><path d="M9 13h6"/><path d="M9 17h6"/></>,
    clock: <><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>,
    shield: <><path d="M12 3 4.5 6v5.5c0 4.8 3.2 7.7 7.5 9.5 4.3-1.8 7.5-4.7 7.5-9.5V6z"/><path d="m8.5 12 2.2 2.2 4.8-5"/></>,
    mail: <><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m4 7 8 6 8-6"/></>,
    calendar: <><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M7 3v4M17 3v4M3 10h18"/></>,
    invoice: <><path d="M6 3h12v18l-3-2-3 2-3-2-3 2z"/><path d="M9 8h6M9 12h6M9 16h3"/></>,
    link: <><path d="M10 13a5 5 0 0 0 7.1.1l2-2a5 5 0 0 0-7.1-7.1l-1.1 1.1"/><path d="M14 11a5 5 0 0 0-7.1-.1l-2 2A5 5 0 0 0 12 20l1.1-1.1"/></>,
    settings: <><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .34 1.88l.06.06-2.83 2.83-.06-.06A1.7 1.7 0 0 0 15 19.4a1.7 1.7 0 0 0-1 .6 1.7 1.7 0 0 0-.4 1V21h-4v-.1A1.7 1.7 0 0 0 8 19.4a1.7 1.7 0 0 0-1.88.34l-.06.06-2.83-2.83.06-.06A1.7 1.7 0 0 0 3.6 15a1.7 1.7 0 0 0-.6-1 1.7 1.7 0 0 0-1-.4H2v-4h.1A1.7 1.7 0 0 0 3.6 8a1.7 1.7 0 0 0-.34-1.88l-.06-.06 2.83-2.83.06.06A1.7 1.7 0 0 0 8 3.6a1.7 1.7 0 0 0 1-.6 1.7 1.7 0 0 0 .4-1V2h4v.1A1.7 1.7 0 0 0 15 3.6a1.7 1.7 0 0 0 1.88-.34l.06-.06 2.83 2.83-.06.06A1.7 1.7 0 0 0 19.4 8c.1.4.3.7.6 1 .3.2.7.4 1 .4h.1v4H21a1.7 1.7 0 0 0-1.6 1.6Z"/></>,
    spark: <><path d="m12 3 1.4 4.1L17.5 8.5l-4.1 1.4L12 14l-1.4-4.1-4.1-1.4 4.1-1.4z"/><path d="m18.5 14 .8 2.2 2.2.8-2.2.8-.8 2.2-.8-2.2-2.2-.8 2.2-.8z"/></>,
    child: <><circle cx="12" cy="7" r="3"/><path d="M7 21v-4a5 5 0 0 1 10 0v4M8 12l-3 3M16 12l3 3"/></>,
    send: <><path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/></>,
    refresh: <><path d="M20 7v5h-5"/><path d="M4 17v-5h5"/><path d="M6.1 9A7 7 0 0 1 18 6l2 2M18 15a7 7 0 0 1-11.9 3L4 16"/></>,
  };

  return <svg {...common}>{paths[name]}</svg>;
}

function Brand() {
  return <img className="ct-brand-logo" src="/brand/fait-logo.svg" alt="FAIT. — Vous demandez. C’est fait." />;
}

function StateBadge({ value }: { value: SignalState }) {
  const slug = value.toLowerCase().replaceAll(" ", "-").replaceAll("à", "a");
  return <span className={`ct-state ct-state--${slug}`}>{value}</span>;
}

function kindIcon(kind: SignalKind): IconName {
  if (kind === "invoice") return "invoice";
  if (kind === "appointment") return "calendar";
  if (kind === "contract") return "mail";
  return "child";
}

export function FaitConnectedTest() {
  const [activeView, setActiveView] = useState<ViewId>("home");
  const [signals, setSignals] = useState(initialSignals);
  const [events, setEvents] = useState(initialEvents);
  const [overlay, setOverlay] = useState<Overlay>("none");
  const [selectedSignalId, setSelectedSignalId] = useState("appointment-dentist");
  const [profileTab, setProfileTab] = useState<ProfileTab>("connections");
  const [confirmed, setConfirmed] = useState(false);
  const [toast, setToast] = useState<string | null>(null);

  const selectedSignal = useMemo(
    () => signals.find((signal) => signal.id === selectedSignalId) ?? signals[0],
    [signals, selectedSignalId],
  );

  function navigate(view: ViewId) {
    setActiveView(view);
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  function openSignal(signal: Signal) {
    setSelectedSignalId(signal.id);
    setConfirmed(false);
    if (signal.kind === "appointment") setOverlay("calendar");
    else if (signal.kind === "vacation") setOverlay("vacation");
    else setOverlay("draft");
  }

  function finishAction(message: string, signalState: SignalState, eventSync?: boolean) {
    setSignals((current) => current.map((signal) => signal.id === selectedSignal.id ? { ...signal, state: signalState } : signal));
    if (eventSync) setEvents((current) => current.map((event) => event.id === "evt-2" ? { ...event, synced: true } : event));
    setOverlay("none");
    setConfirmed(false);
    setToast(message);
    window.setTimeout(() => setToast(null), 3200);
  }

  return (
    <div className="ct-shell">
      <div className="ct-ambient ct-ambient--one" aria-hidden="true" />
      <div className="ct-ambient ct-ambient--two" aria-hidden="true" />

      <header className="ct-topbar">
        <button type="button" className="ct-brand" onClick={() => navigate("home")}><Brand /></button>
        <div className="ct-pulse"><span /> Environnement test · services simulés</div>
        <div className="ct-top-actions">
          <button type="button" onClick={() => { setProfileTab("connections"); navigate("profile"); }}><Icon name="link" size={18}/> 2 connexions</button>
          <button type="button" className="ct-avatar" onClick={() => navigate("profile")}>CG</button>
        </div>
      </header>

      <main className="ct-main">
        {activeView === "home" ? <HomeView signals={signals} events={events} onOpen={openSignal} onNavigate={navigate} /> : null}
        {activeView === "cases" ? <CasesView signals={signals} onOpen={openSignal} /> : null}
        {activeView === "intake" ? <IntakeView /> : null}
        {activeView === "notifications" ? <DetectedView signals={signals} onOpen={openSignal} /> : null}
        {activeView === "profile" ? <ProfileView tab={profileTab} onTab={setProfileTab} onConnections={() => setOverlay("connections")} /> : null}
      </main>

      <nav className="ct-dock" aria-label="Navigation principale">
        {dockItems.map((item) => (
          <button
            type="button"
            key={item.id}
            className={`${activeView === item.id ? "is-active" : ""} ${item.id === "intake" ? "is-primary" : ""}`}
            onClick={() => navigate(item.id)}
          >
            <span className="ct-dock-icon"><Icon name={item.icon} size={item.id === "intake" ? 24 : 20}/>{item.id === "notifications" ? <i>4</i> : null}</span>
            <span>{item.label}</span>
          </button>
        ))}
      </nav>

      {overlay !== "none" ? (
        <div className="ct-overlay" role="dialog" aria-modal="true" aria-label="Validation de l’action">
          <button className="ct-overlay-backdrop" type="button" aria-label="Fermer" onClick={() => setOverlay("none")} />
          <section className="ct-sheet">
            <button className="ct-sheet-close" type="button" onClick={() => setOverlay("none")} aria-label="Fermer">×</button>
            {overlay === "draft" ? <DraftSheet signal={selectedSignal} confirmed={confirmed} onConfirm={setConfirmed} onFinish={() => finishAction("Le brouillon Gmail simulé a été créé.", "Fait")} /> : null}
            {overlay === "calendar" ? <CalendarSheet signal={selectedSignal} confirmed={confirmed} onConfirm={setConfirmed} onFinish={() => finishAction("Le rendez-vous a été ajouté à l’agenda FAIT. et au calendrier iPhone simulé.", "Synchronisé", true)} /> : null}
            {overlay === "vacation" ? <VacationSheet signal={selectedSignal} confirmed={confirmed} onConfirm={setConfirmed} onFinish={() => finishAction("La réservation simulée du centre aéré est confirmée.", "Fait")} /> : null}
            {overlay === "connections" ? <ConnectionsSheet onClose={() => setOverlay("none")} /> : null}
          </section>
        </div>
      ) : null}

      {toast ? <div className="ct-toast"><Icon name="check" size={18}/>{toast}</div> : null}
    </div>
  );
}

function HomeView({ signals, events, onOpen, onNavigate }: { signals: Signal[]; events: AgendaEvent[]; onOpen: (signal: Signal) => void; onNavigate: (view: ViewId) => void }) {
  return (
    <div className="ct-page ct-home">
      <section className="ct-hero">
        <div className="ct-hero-copy">
          <span className="ct-kicker">Lundi 3 août · 15:01</span>
          <h1>Votre quotidien avance déjà.</h1>
          <p>FAIT. a analysé les éléments autorisés, préparé les prochaines actions et isolé uniquement ce qui demande votre attention.</p>
          <div className="ct-hero-actions">
            <button type="button" onClick={() => onNavigate("notifications")}><Icon name="spark" size={20}/> Voir les 4 éléments détectés</button>
            <button type="button" onClick={() => onNavigate("intake")}>Confier autre chose</button>
          </div>
        </div>
        <div className="ct-hero-orbit">
          <div className="ct-orbit-core"><img src="/brand/fait-symbol.svg" alt=""/><strong>4</strong><span>actions préparées</span></div>
          <span className="ct-orbit-node ct-orbit-node--mail"><Icon name="mail" size={20}/></span>
          <span className="ct-orbit-node ct-orbit-node--calendar"><Icon name="calendar" size={20}/></span>
          <span className="ct-orbit-node ct-orbit-node--invoice"><Icon name="invoice" size={20}/></span>
        </div>
      </section>

      <section className="ct-today-grid">
        <div className="ct-section-heading"><div><span className="ct-kicker">Préparé pour vous</span><h2>Ce qui mérite un regard</h2></div><button type="button" onClick={() => onNavigate("notifications")}>Tout voir</button></div>
        <div className="ct-signal-grid">
          {signals.map((signal) => <SignalCard signal={signal} key={signal.id} onOpen={onOpen} />)}
        </div>
      </section>

      <section className="ct-agenda">
        <div className="ct-agenda-head"><div><span className="ct-kicker">Agenda FAIT.</span><h2>Les prochains repères</h2></div><span>Synchronisation iPhone activée</span></div>
        <div className="ct-agenda-track">
          {events.map((event) => (
            <article key={event.id} className={event.synced ? "is-synced" : ""}>
              <div className="ct-date-block"><strong>{event.day}</strong><span>AOÛT</span></div>
              <div><span>{event.time}</span><h3>{event.title}</h3><p>{event.detail}</p><small>{event.source}</small></div>
              <span className="ct-sync-state">{event.synced ? <><Icon name="check" size={14}/> Synchronisé</> : "À confirmer"}</span>
            </article>
          ))}
        </div>
      </section>
    </div>
  );
}

function SignalCard({ signal, onOpen }: { signal: Signal; onOpen: (signal: Signal) => void }) {
  return (
    <button type="button" className={`ct-signal-card ct-signal-card--${signal.kind}`} onClick={() => onOpen(signal)}>
      <div className="ct-signal-top"><span className="ct-signal-icon"><Icon name={kindIcon(signal.kind)} size={22}/></span><StateBadge value={signal.state}/></div>
      <span className="ct-source">{signal.source}</span>
      <h3>{signal.title}</h3>
      <p>{signal.summary}</p>
      <div className="ct-signal-facts">{signal.date ? <span><Icon name="clock" size={14}/>{signal.date}</span> : null}{signal.amount ? <strong>{signal.amount}</strong> : null}</div>
      <span className="ct-card-action">{signal.action}<Icon name="arrow" size={17}/></span>
    </button>
  );
}

function CasesView({ signals, onOpen }: { signals: Signal[]; onOpen: (signal: Signal) => void }) {
  return (
    <div className="ct-page">
      <section className="ct-page-title"><span className="ct-kicker">Dossiers vivants</span><h1>Tout ce que FAIT. suit pour vous.</h1><p>Les e-mails, échéances, documents et actions restent reliés à leur source et à leur preuve.</p></section>
      <div className="ct-case-list">
        {signals.map((signal, index) => (
          <button type="button" key={signal.id} onClick={() => onOpen(signal)}>
            <span className="ct-case-index">0{index + 1}</span>
            <span className="ct-case-icon"><Icon name={kindIcon(signal.kind)} size={24}/></span>
            <div><span>{signal.source}</span><h2>{signal.title}</h2><p>{signal.summary}</p></div>
            <div className="ct-case-status"><StateBadge value={signal.state}/><span>{signal.action}<Icon name="arrow" size={17}/></span></div>
          </button>
        ))}
      </div>
    </div>
  );
}

function IntakeView() {
  const methods: Array<{ icon: IconName; title: string; text: string }> = [
    { icon: "mail", title: "Transmettre un e-mail", text: "Coller le message ou le retrouver dans une boîte connectée" },
    { icon: "document", title: "Déposer un document", text: "Courrier, facture, contrat ou formulaire" },
    { icon: "calendar", title: "Organiser un rendez-vous", text: "Créer un événement, un rappel ou une échéance" },
    { icon: "child", title: "Préparer une démarche familiale", text: "Cantine, centre aéré, activité ou inscription" },
  ];
  return (
    <div className="ct-page ct-intake">
      <section className="ct-page-title"><span className="ct-kicker">Toujours disponible</span><h1>Confiez ce qui n’a pas encore été détecté.</h1><p>Le point d’entrée manuel reste ouvert, même lorsque les services connectés travaillent en arrière-plan.</p></section>
      <div className="ct-method-grid">{methods.map((method) => <button type="button" key={method.title}><span><Icon name={method.icon} size={25}/></span><div><strong>{method.title}</strong><small>{method.text}</small></div><Icon name="arrow" size={18}/></button>)}</div>
      <div className="ct-safety-note"><Icon name="shield" size={21}/><span><strong>Environnement test.</strong> Aucun message, événement ou formulaire réel n’est envoyé depuis cette version.</span></div>
    </div>
  );
}

function DetectedView({ signals, onOpen }: { signals: Signal[]; onOpen: (signal: Signal) => void }) {
  return (
    <div className="ct-page">
      <section className="ct-page-title"><span className="ct-kicker">Boîte intelligente</span><h1>FAIT. filtre le bruit et prépare l’utile.</h1><p>Chaque élément conserve son service d’origine, son niveau de confiance et l’action proposée.</p></section>
      <div className="ct-detected-list">
        {signals.map((signal) => (
          <button type="button" key={signal.id} onClick={() => onOpen(signal)}>
            <span className={`ct-detected-dot ct-detected-dot--${signal.kind}`} />
            <span className="ct-detected-icon"><Icon name={kindIcon(signal.kind)} size={23}/></span>
            <div><small>{signal.receivedAt} · {signal.source}</small><h2>{signal.title}</h2><p>{signal.summary}</p></div>
            <div><StateBadge value={signal.state}/><span>{signal.action}<Icon name="arrow" size={17}/></span></div>
          </button>
        ))}
      </div>
    </div>
  );
}

function ProfileView({ tab, onTab, onConnections }: { tab: ProfileTab; onTab: (tab: ProfileTab) => void; onConnections: () => void }) {
  return (
    <div className="ct-page">
      <section className="ct-page-title"><span className="ct-kicker">Votre contrôle</span><h1>Profil, connexions et autonomie.</h1><p>Vous choisissez ce que FAIT. peut observer, préparer et exécuter.</p></section>
      <div className="ct-profile-tabs">
        <button type="button" className={tab === "identity" ? "is-active" : ""} onClick={() => onTab("identity")}>Profil</button>
        <button type="button" className={tab === "connections" ? "is-active" : ""} onClick={() => onTab("connections")}>Connexions</button>
        <button type="button" className={tab === "autonomy" ? "is-active" : ""} onClick={() => onTab("autonomy")}>Autonomie</button>
      </div>

      {tab === "identity" ? (
        <div className="ct-profile-panel"><div className="ct-identity-card"><span className="ct-big-avatar">CG</span><div><h2>Cyril Gay</h2><p>Compte principal · Foyer de démonstration</p><span><Icon name="check" size={14}/> Identité vérifiée</span></div><button type="button">Modifier</button></div></div>
      ) : null}

      {tab === "connections" ? (
        <div className="ct-connections-grid">
          <ConnectionCard icon="mail" name="Gmail" account="cyril.demo@gmail.com" status="Connecté" permissions="Lire les nouveaux messages autorisés · Créer des brouillons" active />
          <ConnectionCard icon="calendar" name="Calendrier iPhone" account="Calendrier personnel" status="Connecté" permissions="Ajouter des événements après accord · Lire uniquement les identifiants créés par FAIT." active />
          <ConnectionCard icon="mail" name="Outlook" account="Aucun compte" status="À connecter" permissions="Disponible dans une prochaine phase" />
          <ConnectionCard icon="child" name="Kiosque Famille" account="Ville Démo" status="Simulation" permissions="Aucun identifiant réel enregistré dans ce prototype" />
          <button type="button" className="ct-manage-connections" onClick={onConnections}><Icon name="settings" size={21}/><span><strong>Gérer les autorisations détaillées</strong><small>Permissions, historique, suspension et révocation</small></span><Icon name="arrow" size={18}/></button>
        </div>
      ) : null}

      {tab === "autonomy" ? <AutonomyPanel /> : null}
    </div>
  );
}

function ConnectionCard({ icon, name, account, status, permissions, active = false }: { icon: IconName; name: string; account: string; status: string; permissions: string; active?: boolean }) {
  return <article className={active ? "ct-connection is-active" : "ct-connection"}><span className="ct-connection-icon"><Icon name={icon} size={23}/></span><div><span>{status}</span><h3>{name}</h3><strong>{account}</strong><p>{permissions}</p></div><button type="button">{active ? "Gérer" : "Configurer"}</button></article>;
}

function AutonomyPanel() {
  const rows = [
    { title: "Classer les factures détectées", level: "Agir puis notifier", enabled: true },
    { title: "Créer des rappels internes", level: "Autorisation permanente limitée", enabled: true },
    { title: "Ajouter un rendez-vous au calendrier iPhone", level: "Toujours demander", enabled: false },
    { title: "Préparer les réponses e-mail", level: "Préparer sans envoyer", enabled: true },
    { title: "Envoyer un e-mail", level: "Confirmation renforcée", enabled: false },
    { title: "Valider une réservation payante", level: "Confirmation obligatoire", enabled: false },
  ];
  return <div className="ct-autonomy"><div className="ct-autonomy-intro"><Icon name="shield" size={24}/><div><h2>FAIT. n’a jamais une autonomie globale.</h2><p>Chaque capacité est accordée séparément et peut être retirée immédiatement.</p></div></div>{rows.map((row) => <label key={row.title}><span><strong>{row.title}</strong><small>{row.level}</small></span><input type="checkbox" defaultChecked={row.enabled}/></label>)}</div>;
}

function DraftSheet({ signal, confirmed, onConfirm, onFinish }: { signal: Signal; confirmed: boolean; onConfirm: (value: boolean) => void; onFinish: () => void }) {
  const isInvoice = signal.kind === "invoice";
  return <><span className="ct-kicker">Préparation depuis Gmail</span><h2>{isInvoice ? "Classer la facture détectée" : "Créer le brouillon de réponse"}</h2><p>{signal.summary}</p><div className="ct-review-card">{isInvoice ? <><ReviewRow label="Dossier" value="Logement principal"/><ReviewRow label="Document" value="Facture_energie_aout_2026.pdf"/><ReviewRow label="Montant" value="86,40 €"/><ReviewRow label="Action externe" value="Aucune — classement uniquement"/></> : <><ReviewRow label="Destinataire" value="service.clients@operateur-demo.fr"/><ReviewRow label="Objet" value="Demande de maintien de mon tarif actuel"/><ReviewRow label="Message" value="Bonjour, je souhaite connaître les solutions permettant d’éviter la hausse annoncée sur mon abonnement..."/><ReviewRow label="Action" value="Créer un brouillon Gmail, sans envoi"/></>}</div><label className="ct-confirm"><input type="checkbox" checked={confirmed} onChange={(event) => onConfirm(event.target.checked)}/><span>J’ai vérifié les informations préparées.</span></label><button className="ct-final-action" type="button" disabled={!confirmed} onClick={onFinish}>{isInvoice ? "Confirmer le classement simulé" : "Créer le brouillon Gmail simulé"}<Icon name="send" size={18}/></button></>;
}

function CalendarSheet({ signal, confirmed, onConfirm, onFinish }: { signal: Signal; confirmed: boolean; onConfirm: (value: boolean) => void; onFinish: () => void }) {
  return <><span className="ct-kicker">Rendez-vous détecté</span><h2>Ajouter à l’agenda FAIT.</h2><p>{signal.summary}</p><div className="ct-review-card"><ReviewRow label="Titre" value="Rendez-vous dentaire"/><ReviewRow label="Date" value="18 août 2026 à 16 h 30"/><ReviewRow label="Lieu" value="Cabinet dentaire · Lille"/><ReviewRow label="Rappel" value="24 heures avant"/><ReviewRow label="Calendrier externe" value="Calendrier personnel iPhone"/></div><label className="ct-confirm"><input type="checkbox" checked={confirmed} onChange={(event) => onConfirm(event.target.checked)}/><span>J’autorise cet ajout dans mon calendrier iPhone simulé.</span></label><button className="ct-final-action" type="button" disabled={!confirmed} onClick={onFinish}>Ajouter et synchroniser<Icon name="calendar" size={18}/></button></>;
}

function VacationSheet({ signal, confirmed, onConfirm, onFinish }: { signal: Signal; confirmed: boolean; onConfirm: (value: boolean) => void; onFinish: () => void }) {
  return <><span className="ct-kicker">Démarche familiale préparée</span><h2>Inscription au centre aéré</h2><p>{signal.summary}</p><div className="ct-review-card"><ReviewRow label="Portail" value="Kiosque Famille · Ville Démo"/><ReviewRow label="Enfant" value="Inès"/><ReviewRow label="Période" value="Du 24 au 28 août 2026"/><ReviewRow label="Formule" value="Journée complète avec repas"/><ReviewRow label="Coût estimé" value="42 €"/><ReviewRow label="Compte utilisé" value="Connexion simulée — aucun mot de passe réel"/></div><label className="ct-confirm"><input type="checkbox" checked={confirmed} onChange={(event) => onConfirm(event.target.checked)}/><span>Je confirme les dates, la formule et le coût estimé.</span></label><button className="ct-final-action" type="button" disabled={!confirmed} onClick={onFinish}>Confirmer la réservation simulée<Icon name="check" size={18}/></button></>;
}

function ConnectionsSheet({ onClose }: { onClose: () => void }) {
  return <><span className="ct-kicker">Connexions et autorisations</span><h2>Vous gardez la main sur chaque accès.</h2><p>Ce panneau simule le futur centre de contrôle. Aucun jeton OAuth ni secret réel n’est stocké ici.</p><div className="ct-permission-list"><div><Icon name="mail" size={20}/><span><strong>Gmail</strong><small>Lecture des nouveaux messages autorisés · Création de brouillons</small></span><button type="button">Suspendre</button></div><div><Icon name="calendar" size={20}/><span><strong>Calendrier iPhone</strong><small>Ajout après confirmation · 1 événement synchronisé</small></span><button type="button">Suspendre</button></div><div><Icon name="refresh" size={20}/><span><strong>Historique d’accès</strong><small>Dernière simulation : aujourd’hui à 14:58</small></span><button type="button">Voir</button></div></div><button className="ct-final-action" type="button" onClick={onClose}>Fermer</button></>;
}

function ReviewRow({ label, value }: { label: string; value: string }) {
  return <div><span>{label}</span><strong>{value}</strong></div>;
}
