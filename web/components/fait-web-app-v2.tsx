"use client";

import { useMemo, useState } from "react";
import type { ReactNode } from "react";

type ViewId = "home" | "cases" | "intake" | "notifications" | "profile";
type CaseStatus = "À traiter" | "En cours" | "Besoin de vous" | "Fait";
type IntakeStep = "start" | "analysis" | "plan" | "validation" | "done";
type IconName = "home" | "folder" | "plus" | "bell" | "user" | "check" | "arrow" | "document" | "clock" | "shield" | "mail" | "camera" | "text" | "mic" | "spark" | "chevron";

type CaseItem = {
  id: string;
  title: string;
  organization: string;
  subject: string;
  status: CaseStatus;
  nextAction: string;
  dueDate: string;
  updatedAt: string;
  category: string;
};

const cases: CaseItem[] = [
  {
    id: "caf-2026",
    title: "Justificatif demandé par la CAF",
    organization: "CAF du Nord",
    subject: "Dossier personnel",
    status: "Besoin de vous",
    nextAction: "Vérifier et valider la réponse préparée",
    dueDate: "12 août 2026",
    updatedAt: "Aujourd’hui à 11:42",
    category: "Courrier administratif",
  },
  {
    id: "assurance-auto",
    title: "Renégociation de l’assurance auto",
    organization: "Assureur Démo",
    subject: "Véhicule familial",
    status: "En cours",
    nextAction: "Attendre la nouvelle proposition",
    dueDate: "20 août 2026",
    updatedAt: "Hier à 17:05",
    category: "Contrat",
  },
  {
    id: "controle-technique",
    title: "Contrôle technique à anticiper",
    organization: "Véhicule familial",
    subject: "Peugeot 3008",
    status: "À traiter",
    nextAction: "Choisir un rappel et un créneau",
    dueDate: "4 septembre 2026",
    updatedAt: "1 août 2026",
    category: "Échéance",
  },
  {
    id: "internet",
    title: "Résiliation de l’abonnement Internet",
    organization: "Opérateur Démo",
    subject: "Logement principal",
    status: "Fait",
    nextAction: "Aucune action requise",
    dueDate: "Clôturé le 30 juillet 2026",
    updatedAt: "30 juillet 2026",
    category: "Contrat",
  },
];

const dockItems: Array<{ id: ViewId; label: string; icon: IconName }> = [
  { id: "home", label: "Accueil", icon: "home" },
  { id: "cases", label: "Dossiers", icon: "folder" },
  { id: "intake", label: "Confier", icon: "plus" },
  { id: "notifications", label: "Alertes", icon: "bell" },
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
    chevron: <path d="m9 18 6-6-6-6"/>,
    document: <><path d="M6 3h8l4 4v14H6z"/><path d="M14 3v5h5"/><path d="M9 13h6"/><path d="M9 17h6"/></>,
    clock: <><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></>,
    shield: <><path d="M12 3 4.5 6v5.5c0 4.8 3.2 7.7 7.5 9.5 4.3-1.8 7.5-4.7 7.5-9.5V6z"/><path d="m8.5 12 2.2 2.2 4.8-5"/></>,
    mail: <><rect x="3" y="5" width="18" height="14" rx="2"/><path d="m4 7 8 6 8-6"/></>,
    camera: <><path d="M4 8h3l1.5-2h7L17 8h3v11H4z"/><circle cx="12" cy="13" r="3.5"/></>,
    text: <><path d="M4 6h16"/><path d="M8 6v12"/><path d="M16 6v12"/><path d="M6 18h4"/><path d="M14 18h4"/></>,
    mic: <><rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0"/><path d="M12 18v3"/></>,
    spark: <><path d="m12 3 1.4 4.1L17.5 8.5l-4.1 1.4L12 14l-1.4-4.1-4.1-1.4 4.1-1.4z"/><path d="m18.5 14 .8 2.2 2.2.8-2.2.8-.8 2.2-.8-2.2-2.2-.8 2.2-.8z"/></>,
  };

  return <svg {...common}>{paths[name]}</svg>;
}

function Seal({ small = false }: { small?: boolean }) {
  return <span className={small ? "v2-seal v2-seal--small" : "v2-seal"}><Icon name="check" size={small ? 17 : 24}/></span>;
}

function Status({ value }: { value: CaseStatus }) {
  const slug = value.toLowerCase().replaceAll(" ", "-").replaceAll("à", "a");
  return <span className={`v2-status v2-status--${slug}`}>{value}</span>;
}

export function FaitWebAppV2() {
  const [activeView, setActiveView] = useState<ViewId>("home");
  const [selectedCaseId, setSelectedCaseId] = useState(cases[0].id);
  const [intakeStep, setIntakeStep] = useState<IntakeStep>("start");
  const [correctedDate, setCorrectedDate] = useState("2026-08-12");
  const [validationChecked, setValidationChecked] = useState(false);
  const [offline, setOffline] = useState(false);

  const selectedCase = useMemo(() => cases.find((item) => item.id === selectedCaseId) ?? cases[0], [selectedCaseId]);

  function navigate(view: ViewId) {
    setActiveView(view);
    if (view === "intake" && intakeStep === "done") setIntakeStep("start");
    window.scrollTo({ top: 0, behavior: "smooth" });
  }

  function openCase(id: string) {
    setSelectedCaseId(id);
    navigate("cases");
  }

  return (
    <div className="v2-shell">
      <div className="v2-ambient v2-ambient--one" aria-hidden="true" />
      <div className="v2-ambient v2-ambient--two" aria-hidden="true" />

      <header className="v2-topbar">
        <button className="v2-brand" type="button" onClick={() => navigate("home")}>
          <Seal small />
          <span><strong>FAIT.</strong><small>Votre quotidien, allégé.</small></span>
        </button>

        <div className="v2-topbar__center">
          <span className="v2-live-dot" />
          <span>1 action attend votre accord</span>
        </div>

        <div className="v2-topbar__actions">
          <label className="v2-offline">
            <input checked={offline} onChange={(event) => setOffline(event.target.checked)} type="checkbox" />
            <span>Hors ligne</span>
          </label>
          <button className="v2-avatar" type="button" onClick={() => navigate("profile")} aria-label="Ouvrir le profil">CG</button>
        </div>
      </header>

      {offline ? <div className="v2-offline-banner"><Icon name="shield" size={18}/> Mode hors ligne simulé : consultation disponible, validations suspendues.</div> : null}

      <main className="v2-main">
        {activeView === "home" ? <HomeView onOpenCase={openCase} onStart={() => { setIntakeStep("start"); navigate("intake"); }} /> : null}
        {activeView === "cases" ? <CasesView selectedCase={selectedCase} selectedCaseId={selectedCaseId} onSelect={setSelectedCaseId} /> : null}
        {activeView === "intake" ? (
          <IntakeView
            step={intakeStep}
            correctedDate={correctedDate}
            validationChecked={validationChecked}
            offline={offline}
            onDate={setCorrectedDate}
            onValidation={setValidationChecked}
            onStep={setIntakeStep}
            onReset={() => { setIntakeStep("start"); setValidationChecked(false); }}
            onViewCase={() => { setSelectedCaseId("caf-2026"); navigate("cases"); }}
          />
        ) : null}
        {activeView === "notifications" ? <NotificationsView onOpenCase={openCase} /> : null}
        {activeView === "profile" ? <ProfileView /> : null}
      </main>

      <nav className="v2-dock" aria-label="Navigation principale">
        {dockItems.map((item) => (
          <button
            key={item.id}
            type="button"
            className={`${activeView === item.id ? "is-active" : ""} ${item.id === "intake" ? "is-primary" : ""}`}
            onClick={() => navigate(item.id)}
          >
            <span className="v2-dock__icon"><Icon name={item.icon} size={item.id === "intake" ? 24 : 20}/>{item.id === "notifications" ? <i>2</i> : null}</span>
            <span>{item.label}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}

function HomeView({ onOpenCase, onStart }: { onOpenCase: (id: string) => void; onStart: () => void }) {
  const attention = cases[0];
  return (
    <div className="v2-page v2-home">
      <section className="v2-home-hero">
        <div className="v2-home-hero__copy">
          <span className="v2-kicker">Bonjour Cyril</span>
          <h1>Dites-nous ce qui vous encombre.</h1>
          <p>Un courrier, un contrat, une échéance. Vous le confiez, nous le transformons en étapes claires jusqu’à sa résolution.</p>
        </div>

        <button className="v2-command" type="button" onClick={onStart}>
          <span className="v2-command__symbol"><Icon name="plus" size={26}/></span>
          <span><strong>Confier quelque chose</strong><small>Photo, document, e-mail, texte ou dictée</small></span>
          <span className="v2-command__arrow"><Icon name="arrow" size={22}/></span>
        </button>

        <div className="v2-home-notes" aria-label="Résumé de votre espace">
          <span><strong>1</strong> accord attendu</span>
          <span><strong>2</strong> sujets suivis</span>
          <span><strong>4</strong> démarches terminées ce mois-ci</span>
        </div>
      </section>

      <section className="v2-focus-card">
        <div className="v2-focus-card__intro">
          <span className="v2-kicker">À vous de jouer</span>
          <Status value={attention.status}/>
        </div>
        <div className="v2-focus-card__body">
          <div>
            <span className="v2-meta">{attention.organization} · {attention.category}</span>
            <h2>{attention.title}</h2>
            <p>La réponse est prête. Vérifiez ce qui sera transmis avant la date limite.</p>
          </div>
          <button type="button" onClick={() => onOpenCase(attention.id)}>Examiner <Icon name="arrow" size={18}/></button>
        </div>
        <div className="v2-focus-card__timeline"><span className="is-done">Reçu</span><span className="is-done">Compris</span><span className="is-current">À valider</span><span>À suivre</span></div>
      </section>

      <section className="v2-section">
        <div className="v2-section__heading"><div><span className="v2-kicker">En mouvement</span><h2>Ce qui avance pour vous</h2></div><button type="button" onClick={() => onOpenCase(cases[1].id)}>Tous les dossiers</button></div>
        <div className="v2-story-grid">
          {cases.slice(1).map((item, index) => <StoryCard item={item} index={index} key={item.id} onOpen={onOpenCase}/>) }
        </div>
      </section>
    </div>
  );
}

function StoryCard({ item, index, onOpen }: { item: CaseItem; index: number; onOpen: (id: string) => void }) {
  return (
    <button className={`v2-story-card v2-story-card--${index + 1}`} type="button" onClick={() => onOpen(item.id)}>
      <div><span className="v2-meta">{item.category}</span><Status value={item.status}/></div>
      <h3>{item.title}</h3>
      <p>{item.nextAction}</p>
      <span className="v2-story-card__foot"><span>{item.dueDate}</span><Icon name="chevron" size={18}/></span>
    </button>
  );
}

function CasesView({ selectedCase, selectedCaseId, onSelect }: { selectedCase: CaseItem; selectedCaseId: string; onSelect: (id: string) => void }) {
  return (
    <div className="v2-page">
      <section className="v2-page-title"><span className="v2-kicker">Votre mémoire administrative</span><h1>Les sujets que vous nous avez confiés.</h1><p>Chaque dossier rassemble les documents, les décisions, les prochaines étapes et la preuve finale.</p></section>

      <div className="v2-case-switcher" role="list" aria-label="Choisir un dossier">
        {cases.map((item) => (
          <button className={selectedCaseId === item.id ? "is-selected" : ""} type="button" key={item.id} onClick={() => onSelect(item.id)}>
            <span>{item.organization}</span><strong>{item.title}</strong><Status value={item.status}/>
          </button>
        ))}
      </div>

      <article className="v2-case-stage">
        <div className="v2-case-stage__head">
          <div className="v2-doc-orb"><Icon name="document" size={28}/></div>
          <div><span className="v2-kicker">{selectedCase.category}</span><h2>{selectedCase.title}</h2><p>{selectedCase.organization} · {selectedCase.subject}</p></div>
          <Status value={selectedCase.status}/>
        </div>

        <div className="v2-case-stage__grid">
          <section className="v2-next-step">
            <span className="v2-kicker">La prochaine chose à faire</span>
            <h3>{selectedCase.nextAction}</h3>
            <p>Échéance : {selectedCase.dueDate}</p>
            {selectedCase.status === "Besoin de vous" ? <button type="button">Examiner et valider <Icon name="arrow" size={18}/></button> : null}
          </section>
          <section className="v2-case-facts">
            <div><span>Dernière évolution</span><strong>{selectedCase.updatedAt}</strong></div>
            <div><span>Personne ou bien concerné</span><strong>{selectedCase.subject}</strong></div>
            <div><span>Preuve finale</span><strong>{selectedCase.status === "Fait" ? "Disponible" : "En attente"}</strong></div>
          </section>
        </div>

        <ol className="v2-journey">
          <li className="is-done"><i><Icon name="check" size={14}/></i><span><strong>Reçu</strong><small>Le document est conservé</small></span></li>
          <li className="is-done"><i><Icon name="check" size={14}/></i><span><strong>Compris</strong><small>Les informations ont été vérifiées</small></span></li>
          <li className="is-current"><i>3</i><span><strong>Décider</strong><small>Votre accord est demandé</small></span></li>
          <li><i>4</i><span><strong>Terminer</strong><small>Suivi et preuve de résolution</small></span></li>
        </ol>
      </article>
    </div>
  );
}

function IntakeView({ step, correctedDate, validationChecked, offline, onDate, onValidation, onStep, onReset, onViewCase }: {
  step: IntakeStep;
  correctedDate: string;
  validationChecked: boolean;
  offline: boolean;
  onDate: (value: string) => void;
  onValidation: (value: boolean) => void;
  onStep: (step: IntakeStep) => void;
  onReset: () => void;
  onViewCase: () => void;
}) {
  if (step === "start") return <IntakeStart onStart={() => onStep("analysis")}/>;
  if (step === "analysis") return (
    <div className="v2-page v2-flow-page">
      <FlowHeader step={1} title="Vérifions ce que nous avons compris." text="Les informations importantes restent reliées au document et peuvent être corrigées."/>
      <div className="v2-analysis">
        <div className="v2-paper-wrap"><div className="v2-paper"><strong>CAF</strong><span/><span/><span/><mark>Merci de transmettre votre justificatif avant le 12 août 2026.</mark><span/><span/></div><small>Courrier_demo_CAF.pdf · Document fictif</small></div>
        <div className="v2-form-card">
          <label><span>Organisme</span><input defaultValue="CAF du Nord"/></label>
          <label><span>Objet</span><input defaultValue="Demande de justificatif de domicile"/></label>
          <label className="is-warning"><span>Date limite <em>À vérifier</em></span><input type="date" value={correctedDate} onChange={(event) => onDate(event.target.value)}/><small>Source : passage surligné dans le courrier</small></label>
          <label><span>Personne concernée</span><input defaultValue="Cyril Gay"/></label>
          <div className="v2-summary"><span className="v2-kicker">En clair</span><p>La CAF demande un justificatif récent. Sans réponse avant la date indiquée, le traitement du dossier peut être suspendu.</p></div>
        </div>
      </div>
      <FlowActions secondary="Recommencer" primary="Construire le plan" onSecondary={onReset} onPrimary={() => onStep("plan")}/>
    </div>
  );
  if (step === "plan") return (
    <div className="v2-page v2-flow-page v2-flow-page--narrow">
      <FlowHeader step={2} title="Voilà comment nous allons le terminer." text="Chaque étape indique clairement ce qui dépend de vous et ce qui sera préparé pour vous."/>
      <ol className="v2-plan">
        <PlanItem number="01" owner="Vous" title="Choisir le justificatif" text="Sélectionner une facture récente disponible."/>
        <PlanItem number="02" owner="FAIT." title="Préparer la réponse" text="Composer le message avec la référence du dossier."/>
        <PlanItem number="03" owner="Vous" title="Vérifier et autoriser" text="Contrôler le destinataire, le texte et la pièce jointe."/>
        <PlanItem number="04" owner="FAIT." title="Conserver la preuve" text="Suivre la réponse et archiver la confirmation."/>
      </ol>
      <div className="v2-plan-summary"><span><small>Échéance de sécurité</small><strong>10 août</strong></span><span><small>Coût estimé</small><strong>0 €</strong></span><span><small>Temps demandé</small><strong>2 min</strong></span></div>
      <FlowActions secondary="Modifier l’analyse" primary="Accepter ce plan" onSecondary={() => onStep("analysis")} onPrimary={() => onStep("validation")}/>
    </div>
  );
  if (step === "validation") return (
    <div className="v2-page v2-flow-page v2-flow-page--narrow">
      <FlowHeader step={3} title="Un dernier regard avant votre accord." text="La validation porte exactement sur les éléments ci-dessous. Toute modification importante exigera un nouvel accord."/>
      <div className="v2-validation">
        <ValidationRow label="Action" value="Envoyer une réponse administrative simulée"/>
        <ValidationRow label="Destinataire" value="CAF du Nord — adresse de démonstration"/>
        <ValidationRow label="Message" value="Veuillez trouver ci-joint le justificatif demandé pour le dossier de démonstration FAIT."/>
        <ValidationRow label="Pièce jointe" value="Justificatif_domicile_demo.pdf"/>
        <ValidationRow label="Conséquence" value="Action simulée, sans envoi réel"/>
      </div>
      <label className="v2-consent"><input checked={validationChecked} onChange={(event) => onValidation(event.target.checked)} type="checkbox"/><span>J’ai vérifié le destinataire, le message et la pièce jointe.</span></label>
      {offline ? <div className="v2-inline-alert">La validation est suspendue pendant le mode hors ligne.</div> : null}
      <FlowActions secondary="Revenir au plan" primary="Donner mon accord" onSecondary={() => onStep("plan")} onPrimary={() => onStep("done")} disabled={!validationChecked || offline}/>
    </div>
  );
  return (
    <div className="v2-page v2-complete">
      <Seal/>
      <span className="v2-kicker">Dossier finalisé</span>
      <h1>C’est fait.</h1>
      <p>L’action a été simulée. Le contenu validé, l’historique et la preuve sont désormais réunis dans le dossier.</p>
      <div className="v2-proof"><Icon name="check" size={22}/><span><strong>Confirmation FAIT-DEMO-20260803</strong><small>Horodatée le 3 août 2026 à 14:27</small></span></div>
      <div className="v2-complete__actions"><button type="button" onClick={onViewCase}>Voir le dossier</button><button type="button" onClick={onReset}>Confier autre chose</button></div>
    </div>
  );
}

function IntakeStart({ onStart }: { onStart: () => void }) {
  const methods: Array<{ icon: IconName; title: string; text: string }> = [
    { icon: "camera", title: "Prendre une photo", text: "Un courrier posé devant vous" },
    { icon: "document", title: "Déposer un document", text: "PDF ou image depuis votre appareil" },
    { icon: "mail", title: "Coller un e-mail", text: "Un message reçu à comprendre ou traiter" },
    { icon: "text", title: "Écrire la situation", text: "Quelques mots suffisent pour commencer" },
    { icon: "mic", title: "La raconter", text: "Dicter naturellement ce qui vous préoccupe" },
  ];
  return (
    <div className="v2-page v2-intake-start">
      <section className="v2-page-title"><span className="v2-kicker">Un seul point de départ</span><h1>Comment souhaitez-vous nous le confier ?</h1><p>Choisissez ce qui est le plus simple maintenant. Nous demanderons seulement ce qui manque.</p></section>
      <div className="v2-methods">{methods.map((method, index) => <button className={index === 0 ? "is-featured" : ""} type="button" key={method.title} onClick={onStart}><span><Icon name={method.icon} size={25}/></span><div><strong>{method.title}</strong><small>{method.text}</small></div><Icon name="arrow" size={19}/></button>)}</div>
      <div className="v2-trust-line"><Icon name="shield" size={20}/><span><strong>Rien ne part sans vous.</strong> Vous vérifiez toujours avant une action engageante.</span></div>
    </div>
  );
}

function FlowHeader({ step, title, text }: { step: number; title: string; text: string }) {
  return <header className="v2-flow-header"><div className="v2-progress">{[1,2,3].map((item) => <span className={item <= step ? "is-active" : ""} key={item}><i/>{item === 1 ? "Comprendre" : item === 2 ? "Planifier" : "Autoriser"}</span>)}</div><span className="v2-kicker">Étape {step} sur 3</span><h1>{title}</h1><p>{text}</p></header>;
}

function FlowActions({ secondary, primary, onSecondary, onPrimary, disabled = false }: { secondary: string; primary: string; onSecondary: () => void; onPrimary: () => void; disabled?: boolean }) {
  return <div className="v2-flow-actions"><button type="button" onClick={onSecondary}>{secondary}</button><button type="button" disabled={disabled} onClick={onPrimary}>{primary}<Icon name="arrow" size={18}/></button></div>;
}

function PlanItem({ number, owner, title, text }: { number: string; owner: string; title: string; text: string }) {
  return <li><span className="v2-plan__number">{number}</span><div><span>{owner}</span><strong>{title}</strong><p>{text}</p></div></li>;
}

function ValidationRow({ label, value }: { label: string; value: string }) {
  return <div><span>{label}</span><strong>{value}</strong></div>;
}

function NotificationsView({ onOpenCase }: { onOpenCase: (id: string) => void }) {
  return (
    <div className="v2-page v2-notifications">
      <section className="v2-page-title"><span className="v2-kicker">Juste ce qui compte</span><h1>Les moments où vous devez intervenir.</h1><p>Chaque alerte ouvre directement la décision ou l’information concernée.</p></section>
      <div className="v2-notification-timeline">
        <button type="button" onClick={() => onOpenCase("caf-2026")}><i/><span className="v2-notif-icon"><Icon name="shield" size={21}/></span><div><small>Il y a 8 minutes</small><strong>Votre accord est demandé</strong><p>La réponse à la CAF est prête à être vérifiée.</p></div><Icon name="chevron" size={18}/></button>
        <button type="button" onClick={() => onOpenCase("controle-technique")}><i/><span className="v2-notif-icon"><Icon name="clock" size={21}/></span><div><small>Aujourd’hui à 09:15</small><strong>Une échéance approche</strong><p>Le contrôle technique expire dans un mois.</p></div><Icon name="chevron" size={18}/></button>
        <button type="button" onClick={() => onOpenCase("internet")}><i className="is-muted"/><span className="v2-notif-icon"><Icon name="check" size={21}/></span><div><small>30 juillet 2026</small><strong>Un dossier est terminé</strong><p>La preuve de résiliation est disponible.</p></div><Icon name="chevron" size={18}/></button>
      </div>
    </div>
  );
}

function ProfileView() {
  return (
    <div className="v2-page">
      <section className="v2-page-title"><span className="v2-kicker">Votre espace</span><h1>Ce que FAIT. connaît pour mieux vous aider.</h1><p>Ces informations évitent les ressaisies. Elles restent modifiables et sous votre contrôle.</p></section>
      <section className="v2-profile-identity"><span className="v2-avatar v2-avatar--large">CG</span><div><h2>Cyril Gay</h2><p>Compte principal · Hauts-de-France</p><span><Icon name="check" size={14}/> Adresse e-mail vérifiée</span></div><button type="button">Modifier</button></section>
      <div className="v2-profile-grid">
        <ProfileCard title="Mon foyer" rows={["Céline · Membre du foyer", "Inès · Enfant du foyer"]}/>
        <ProfileCard title="Mes biens" rows={["Logement principal", "Peugeot 3008 · Véhicule familial"]}/>
        <ProfileCard title="Mes documents utiles" rows={["Justificatifs réutilisables", "Pièces d’identité et échéances"]}/>
        <ProfileCard title="Sécurité et données" rows={["Confidentialité et autorisations", "Exporter ou supprimer mes données"]}/>
      </div>
    </div>
  );
}

function ProfileCard({ title, rows }: { title: string; rows: string[] }) {
  return <section className="v2-profile-card"><h3>{title}</h3>{rows.map((row) => <button type="button" key={row}><span>{row}</span><Icon name="chevron" size={17}/></button>)}</section>;
}
