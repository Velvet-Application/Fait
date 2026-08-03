"use client";

import { useMemo, useState } from "react";

type TabId = "home" | "cases" | "intake" | "notifications" | "profile";
type CaseStatus = "À traiter" | "En cours" | "Besoin de vous" | "Fait";
type IntakeStep = "start" | "analysis" | "plan" | "validation" | "done";

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
    title: "Demande de justificatif CAF",
    organization: "CAF du Nord",
    subject: "Cyril Gay",
    status: "Besoin de vous",
    nextAction: "Valider la réponse préparée",
    dueDate: "12 août 2026",
    updatedAt: "Aujourd’hui à 11:42",
    category: "Courrier administratif",
  },
  {
    id: "assurance-auto",
    title: "Renégociation assurance auto",
    organization: "Assureur Démo",
    subject: "Véhicule familial",
    status: "En cours",
    nextAction: "Attendre la proposition commerciale",
    dueDate: "20 août 2026",
    updatedAt: "Hier à 17:05",
    category: "Contrat",
  },
  {
    id: "controle-technique",
    title: "Contrôle technique",
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
    title: "Résiliation abonnement Internet",
    organization: "Opérateur Démo",
    subject: "Logement principal",
    status: "Fait",
    nextAction: "Aucune action requise",
    dueDate: "Clôturé le 30 juillet 2026",
    updatedAt: "30 juillet 2026",
    category: "Contrat",
  },
];

const navItems: Array<{ id: TabId; label: string; icon: IconName }> = [
  { id: "home", label: "Accueil", icon: "home" },
  { id: "cases", label: "Dossiers", icon: "folder" },
  { id: "intake", label: "Confier", icon: "plus" },
  { id: "notifications", label: "Notifications", icon: "bell" },
  { id: "profile", label: "Profil", icon: "user" },
];

type IconName = "home" | "folder" | "plus" | "bell" | "user" | "check" | "arrow" | "document" | "clock" | "shield" | "mail" | "camera" | "text" | "mic";

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

  const paths: Record<IconName, React.ReactNode> = {
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
    camera: <><path d="M4 8h3l1.5-2h7L17 8h3v11H4z"/><circle cx="12" cy="13" r="3.5"/></>,
    text: <><path d="M4 6h16"/><path d="M8 6v12"/><path d="M16 6v12"/><path d="M6 18h4"/><path d="M14 18h4"/></>,
    mic: <><rect x="9" y="3" width="6" height="11" rx="3"/><path d="M5 11a7 7 0 0 0 14 0"/><path d="M12 18v3"/></>,
  };

  return <svg {...common}>{paths[name]}</svg>;
}

function TrustSeal({ compact = false }: { compact?: boolean }) {
  return (
    <div className={compact ? "trust-seal trust-seal--compact" : "trust-seal"} aria-hidden="true">
      <Icon name="check" size={compact ? 18 : 25} />
    </div>
  );
}

function StatusPill({ status }: { status: CaseStatus }) {
  return <span className={`status status--${status.toLowerCase().replaceAll(" ", "-").replaceAll("à", "a")}`}>{status}</span>;
}

function CaseCard({ item, onOpen }: { item: CaseItem; onOpen: (id: string) => void }) {
  return (
    <button className="case-card" onClick={() => onOpen(item.id)} type="button">
      <div className="case-card__icon"><Icon name="document" size={21} /></div>
      <div className="case-card__body">
        <div className="case-card__topline">
          <span className="eyebrow">{item.organization}</span>
          <StatusPill status={item.status} />
        </div>
        <h3>{item.title}</h3>
        <p>{item.nextAction}</p>
        <div className="case-card__meta">
          <span><Icon name="clock" size={15} /> {item.dueDate}</span>
          <span>{item.updatedAt}</span>
        </div>
      </div>
      <span className="case-card__arrow"><Icon name="arrow" size={19} /></span>
    </button>
  );
}

function SectionHeader({ title, action }: { title: string; action?: string }) {
  return (
    <div className="section-header">
      <h2>{title}</h2>
      {action ? <button type="button" className="text-button">{action}</button> : null}
    </div>
  );
}

export function FaitWebApp() {
  const [activeTab, setActiveTab] = useState<TabId>("home");
  const [selectedCaseId, setSelectedCaseId] = useState(cases[0].id);
  const [intakeStep, setIntakeStep] = useState<IntakeStep>("start");
  const [correctedDate, setCorrectedDate] = useState("2026-08-12");
  const [validationChecked, setValidationChecked] = useState(false);
  const [offline, setOffline] = useState(false);

  const selectedCase = useMemo(
    () => cases.find((item) => item.id === selectedCaseId) ?? cases[0],
    [selectedCaseId],
  );

  function openCase(id: string) {
    setSelectedCaseId(id);
    setActiveTab("cases");
  }

  function startIntake() {
    setIntakeStep("analysis");
    setValidationChecked(false);
  }

  function resetIntake() {
    setIntakeStep("start");
    setValidationChecked(false);
  }

  return (
    <div className="app-shell">
      <aside className="sidebar">
        <div className="brand">
          <TrustSeal />
          <div>
            <strong>FAIT.</strong>
            <span>Vous demandez. C’est fait.</span>
          </div>
        </div>

        <nav className="side-nav" aria-label="Navigation principale">
          {navItems.map((item) => (
            <button
              className={activeTab === item.id ? "side-nav__item is-active" : "side-nav__item"}
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              type="button"
            >
              <Icon name={item.icon} size={21} />
              <span>{item.label}</span>
              {item.id === "notifications" ? <span className="nav-badge">2</span> : null}
            </button>
          ))}
        </nav>

        <div className="sidebar__footer">
          <div className="privacy-note">
            <Icon name="shield" size={20} />
            <div><strong>Prototype sécurisé</strong><span>Données fictives uniquement</span></div>
          </div>
          <button type="button" className="profile-mini" onClick={() => setActiveTab("profile")}>
            <span className="avatar">CG</span>
            <span><strong>Cyril</strong><small>Compte de démonstration</small></span>
          </button>
        </div>
      </aside>

      <main className="main-panel">
        <header className="topbar">
          <div className="mobile-brand"><TrustSeal compact /><strong>FAIT.</strong></div>
          <div className="topbar__context">
            <span className="prototype-chip">Prototype web</span>
            <label className="offline-control">
              <input checked={offline} onChange={(event) => setOffline(event.target.checked)} type="checkbox" />
              <span>Simuler hors ligne</span>
            </label>
          </div>
        </header>

        {offline ? (
          <div className="offline-banner" role="status">
            <Icon name="shield" size={18} /> Mode hors ligne simulé : consultation disponible, actions engageantes bloquées.
          </div>
        ) : null}

        <div className="workspace">
          {activeTab === "home" ? (
            <HomeView onOpenCase={openCase} onStart={() => { setActiveTab("intake"); resetIntake(); }} />
          ) : null}
          {activeTab === "cases" ? (
            <CasesView selectedCase={selectedCase} selectedCaseId={selectedCaseId} onSelect={setSelectedCaseId} />
          ) : null}
          {activeTab === "intake" ? (
            <IntakeView
              step={intakeStep}
              correctedDate={correctedDate}
              validationChecked={validationChecked}
              offline={offline}
              onCorrectDate={setCorrectedDate}
              onValidationChange={setValidationChecked}
              onStart={startIntake}
              onStep={setIntakeStep}
              onReset={resetIntake}
              onViewCase={() => { setSelectedCaseId("caf-2026"); setActiveTab("cases"); }}
            />
          ) : null}
          {activeTab === "notifications" ? <NotificationsView onOpenCase={openCase} /> : null}
          {activeTab === "profile" ? <ProfileView /> : null}
        </div>
      </main>

      <nav className="mobile-nav" aria-label="Navigation mobile">
        {navItems.map((item) => (
          <button
            key={item.id}
            type="button"
            className={activeTab === item.id ? `mobile-nav__item is-active ${item.id === "intake" ? "is-primary" : ""}` : `mobile-nav__item ${item.id === "intake" ? "is-primary" : ""}`}
            onClick={() => setActiveTab(item.id)}
          >
            <Icon name={item.icon} size={item.id === "intake" ? 24 : 20} />
            <span>{item.label}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}

function HomeView({ onOpenCase, onStart }: { onOpenCase: (id: string) => void; onStart: () => void }) {
  const needsAttention = cases.filter((item) => item.status === "Besoin de vous");
  const activeCases = cases.filter((item) => item.status === "En cours" || item.status === "À traiter");

  return (
    <div className="page-stack">
      <section className="hero-card">
        <div>
          <span className="eyebrow">Bonjour Cyril</span>
          <h1>Qu’est-ce qu’on règle aujourd’hui&nbsp;?</h1>
          <p>Transmettez un courrier, un contrat ou une échéance. FAIT. transforme le sujet en prochaines actions claires.</p>
          <button className="primary-button" onClick={onStart} type="button"><Icon name="plus" size={20} /> Confier quelque chose</button>
        </div>
        <div className="hero-seal"><TrustSeal /><span>Clair</span><span>Contrôlé</span><span>Suivi</span></div>
      </section>

      <section className="metrics-grid" aria-label="Résumé des dossiers">
        <article className="metric-card"><span>Besoin de vous</span><strong>1</strong><small>Validation avant le 12 août</small></article>
        <article className="metric-card"><span>En cours</span><strong>2</strong><small>Suivis automatiquement</small></article>
        <article className="metric-card"><span>Fait ce mois-ci</span><strong>4</strong><small>Avec preuve enregistrée</small></article>
      </section>

      <section>
        <SectionHeader title="Besoin de vous" />
        <div className="cards-list">
          {needsAttention.map((item) => <CaseCard item={item} key={item.id} onOpen={onOpenCase} />)}
        </div>
      </section>

      <section>
        <SectionHeader title="À suivre" action="Voir tous les dossiers" />
        <div className="cards-grid">
          {activeCases.map((item) => <CaseCard item={item} key={item.id} onOpen={onOpenCase} />)}
        </div>
      </section>
    </div>
  );
}

function CasesView({ selectedCase, selectedCaseId, onSelect }: { selectedCase: CaseItem; selectedCaseId: string; onSelect: (id: string) => void }) {
  return (
    <div className="page-stack">
      <div className="page-heading">
        <div><span className="eyebrow">Suivi centralisé</span><h1>Vos dossiers</h1><p>Chaque sujet conserve ses sources, ses actions et sa preuve finale.</p></div>
        <div className="segmented-control" aria-label="Filtrer les dossiers"><button className="is-active" type="button">Tous</button><button type="button">En cours</button><button type="button">Terminés</button></div>
      </div>

      <div className="cases-layout">
        <section className="case-list-panel" aria-label="Liste des dossiers">
          <div className="search-box"><span aria-hidden="true">⌕</span><input aria-label="Rechercher un dossier" placeholder="Rechercher un dossier ou un organisme" /></div>
          <div className="compact-case-list">
            {cases.map((item) => (
              <button className={selectedCaseId === item.id ? "compact-case is-selected" : "compact-case"} key={item.id} onClick={() => onSelect(item.id)} type="button">
                <div><span className="eyebrow">{item.organization}</span><strong>{item.title}</strong><small>{item.nextAction}</small></div>
                <StatusPill status={item.status} />
              </button>
            ))}
          </div>
        </section>

        <article className="case-detail">
          <div className="case-detail__header">
            <div className="case-detail__icon"><Icon name="document" size={25} /></div>
            <div><span className="eyebrow">{selectedCase.category}</span><h2>{selectedCase.title}</h2><p>{selectedCase.organization} · {selectedCase.subject}</p></div>
            <StatusPill status={selectedCase.status} />
          </div>

          <div className="next-action-box">
            <span className="eyebrow">Prochaine action</span>
            <strong>{selectedCase.nextAction}</strong>
            <p>Échéance : {selectedCase.dueDate}</p>
            {selectedCase.status === "Besoin de vous" ? <button className="primary-button" type="button">Examiner et valider</button> : null}
          </div>

          <SectionHeader title="Étapes" />
          <ol className="timeline">
            <li className="is-done"><span><Icon name="check" size={15} /></span><div><strong>Document reçu</strong><small>Source enregistrée et horodatée</small></div></li>
            <li className="is-done"><span><Icon name="check" size={15} /></span><div><strong>Analyse vérifiée</strong><small>Informations extraites et corrigées</small></div></li>
            <li className="is-current"><span>3</span><div><strong>Validation de la réponse</strong><small>Votre accord est nécessaire</small></div></li>
            <li><span>4</span><div><strong>Envoi et suivi</strong><small>Prévu après votre validation</small></div></li>
          </ol>

          <div className="detail-grid">
            <div><span className="eyebrow">Dernière mise à jour</span><strong>{selectedCase.updatedAt}</strong></div>
            <div><span className="eyebrow">Preuve</span><strong>{selectedCase.status === "Fait" ? "Confirmation disponible" : "À venir"}</strong></div>
          </div>
        </article>
      </div>
    </div>
  );
}

function IntakeView({
  step,
  correctedDate,
  validationChecked,
  offline,
  onCorrectDate,
  onValidationChange,
  onStart,
  onStep,
  onReset,
  onViewCase,
}: {
  step: IntakeStep;
  correctedDate: string;
  validationChecked: boolean;
  offline: boolean;
  onCorrectDate: (value: string) => void;
  onValidationChange: (value: boolean) => void;
  onStart: () => void;
  onStep: (step: IntakeStep) => void;
  onReset: () => void;
  onViewCase: () => void;
}) {
  if (step === "start") {
    const methods: Array<{ icon: IconName; title: string; detail: string }> = [
      { icon: "camera", title: "Photographier un courrier", detail: "Prendre une photo depuis votre smartphone" },
      { icon: "document", title: "Importer un document", detail: "PDF ou image depuis votre appareil" },
      { icon: "mail", title: "Coller un e-mail", detail: "Copier le message reçu" },
      { icon: "text", title: "Écrire une demande", detail: "Décrire simplement la situation" },
      { icon: "mic", title: "Dicter une demande", detail: "Parler naturellement à FAIT." },
    ];

    return (
      <div className="page-stack intake-narrow">
        <div className="page-heading"><div><span className="eyebrow">Point d’entrée universel</span><h1>Confier quelque chose</h1><p>Choisissez le moyen le plus simple. Nous vous demanderons uniquement les informations manquantes.</p></div></div>
        <div className="intake-methods">
          {methods.map((method, index) => (
            <button className={index === 0 ? "intake-method is-featured" : "intake-method"} key={method.title} onClick={onStart} type="button">
              <span><Icon name={method.icon} size={25} /></span><div><strong>{method.title}</strong><small>{method.detail}</small></div><Icon name="arrow" size={19} />
            </button>
          ))}
        </div>
        <div className="trust-message"><Icon name="shield" size={20} /><p><strong>Vous gardez le contrôle.</strong> Le document de cette démonstration est fictif et aucune action réelle ne sera envoyée.</p></div>
      </div>
    );
  }

  if (step === "analysis") {
    return (
      <div className="page-stack">
        <FlowProgress current={1} />
        <div className="page-heading"><div><span className="eyebrow">Analyse terminée</span><h1>Voici ce que FAIT. a compris</h1><p>Vérifiez les informations importantes avant de construire le plan d’action.</p></div></div>
        <div className="analysis-layout">
          <div className="document-preview">
            <div className="paper-sheet"><div className="paper-logo">CAF</div><div className="paper-line width-50"/><div className="paper-line width-75"/><div className="paper-line"/><div className="paper-line width-85"/><div className="paper-highlight">Merci de transmettre votre justificatif avant le 12 août 2026.</div><div className="paper-line"/><div className="paper-line width-65"/></div>
            <span>Courrier_demo_CAF.pdf · Document fictif</span>
          </div>
          <div className="analysis-card">
            <label><span>Organisme</span><input defaultValue="CAF du Nord" /></label>
            <label><span>Objet</span><input defaultValue="Demande de justificatif de domicile" /></label>
            <label className="field-warning"><span>Date limite <em>À vérifier</em></span><input type="date" value={correctedDate} onChange={(event) => onCorrectDate(event.target.value)} /><small>Source : paragraphe surligné du courrier</small></label>
            <label><span>Personne concernée</span><input defaultValue="Cyril Gay" /></label>
            <div className="summary-box"><span className="eyebrow">Résumé simple</span><p>La CAF demande un justificatif de domicile récent. Sans réponse avant la date indiquée, le traitement du dossier peut être suspendu.</p></div>
          </div>
        </div>
        <FlowActions secondary="Recommencer" onSecondary={onReset} primary="Continuer vers le plan d’action" onPrimary={() => onStep("plan")} />
      </div>
    );
  }

  if (step === "plan") {
    return (
      <div className="page-stack intake-narrow">
        <FlowProgress current={2} />
        <div className="page-heading"><div><span className="eyebrow">Plan proposé</span><h1>Quatre étapes pour terminer</h1><p>Vous savez précisément ce que FAIT. prépare et ce qui nécessite votre intervention.</p></div></div>
        <ol className="plan-list">
          <PlanItem number="1" title="Choisir le justificatif" detail="Vous sélectionnez une facture récente déjà disponible." owner="Vous" />
          <PlanItem number="2" title="Préparer la réponse" detail="FAIT. génère un message clair avec la référence du dossier." owner="FAIT." />
          <PlanItem number="3" title="Vérifier et valider" detail="Vous contrôlez le destinataire, le contenu et la pièce jointe." owner="Vous" />
          <PlanItem number="4" title="Suivre la réponse" detail="FAIT. conserve la preuve et propose une relance si nécessaire." owner="FAIT." />
        </ol>
        <div className="plan-summary"><div><span>Échéance de sécurité</span><strong>10 août 2026</strong></div><div><span>Coût estimé</span><strong>0 €</strong></div><div><span>Durée utilisateur</span><strong>2 minutes</strong></div></div>
        <FlowActions secondary="Modifier l’analyse" onSecondary={() => onStep("analysis")} primary="Accepter ce plan" onPrimary={() => onStep("validation")} />
      </div>
    );
  }

  if (step === "validation") {
    return (
      <div className="page-stack intake-narrow">
        <FlowProgress current={3} />
        <div className="page-heading"><div><span className="eyebrow">Validation sensible</span><h1>Vérifiez avant de confirmer</h1><p>Cette validation porte sur un contenu figé. Toute modification importante demandera un nouvel accord.</p></div></div>
        <div className="validation-card">
          <div className="validation-row"><span>Action</span><strong>Envoyer une réponse administrative simulée</strong></div>
          <div className="validation-row"><span>Destinataire</span><strong>CAF du Nord — adresse de démonstration</strong></div>
          <div className="validation-row"><span>Message</span><p>Bonjour, veuillez trouver ci-joint le justificatif demandé pour le dossier de démonstration FAIT.</p></div>
          <div className="validation-row"><span>Pièce jointe</span><strong>Justificatif_domicile_demo.pdf</strong></div>
          <div className="validation-row"><span>Conséquence</span><strong>Action simulée, sans envoi réel</strong></div>
        </div>
        <label className="confirmation-check"><input checked={validationChecked} onChange={(event) => onValidationChange(event.target.checked)} type="checkbox" /><span>J’ai vérifié le destinataire, le message et la pièce jointe.</span></label>
        {offline ? <div className="inline-alert">La validation est bloquée en mode hors ligne simulé.</div> : null}
        <FlowActions secondary="Revenir au plan" onSecondary={() => onStep("plan")} primary="Valider l’action simulée" onPrimary={() => onStep("done")} primaryDisabled={!validationChecked || offline} />
      </div>
    );
  }

  return (
    <div className="completion-screen">
      <TrustSeal />
      <span className="eyebrow">Dossier finalisé</span>
      <h1>C’est fait.</h1>
      <p>L’action a été simulée avec succès. La preuve, le contenu validé et l’historique sont désormais rattachés au dossier.</p>
      <div className="proof-card"><Icon name="check" size={22} /><div><strong>Preuve de démonstration</strong><span>Confirmation n° FAIT-DEMO-20260803</span><small>Horodatée le 3 août 2026 à 13:28</small></div></div>
      <div className="completion-actions"><button className="primary-button" onClick={onViewCase} type="button">Voir le dossier</button><button className="secondary-button" onClick={onReset} type="button">Confier autre chose</button></div>
    </div>
  );
}

function FlowProgress({ current }: { current: number }) {
  return (
    <div className="flow-progress" aria-label={`Étape ${current} sur 3`}>
      {[1, 2, 3].map((step) => <span className={step <= current ? "is-active" : ""} key={step}><i />{step === 1 ? "Comprendre" : step === 2 ? "Planifier" : "Valider"}</span>)}
    </div>
  );
}

function FlowActions({ secondary, primary, onSecondary, onPrimary, primaryDisabled = false }: { secondary: string; primary: string; onSecondary: () => void; onPrimary: () => void; primaryDisabled?: boolean }) {
  return <div className="flow-actions"><button className="secondary-button" onClick={onSecondary} type="button">{secondary}</button><button className="primary-button" disabled={primaryDisabled} onClick={onPrimary} type="button">{primary}<Icon name="arrow" size={18} /></button></div>;
}

function PlanItem({ number, title, detail, owner }: { number: string; title: string; detail: string; owner: string }) {
  return <li><span className="plan-number">{number}</span><div><strong>{title}</strong><p>{detail}</p></div><span className={owner === "FAIT." ? "owner owner--fait" : "owner"}>{owner}</span></li>;
}

function NotificationsView({ onOpenCase }: { onOpenCase: (id: string) => void }) {
  return (
    <div className="page-stack intake-narrow">
      <div className="page-heading"><div><span className="eyebrow">Alertes utiles uniquement</span><h1>Notifications</h1><p>Chaque alerte mène directement à l’action attendue.</p></div><button className="text-button" type="button">Tout marquer comme lu</button></div>
      <div className="notification-list">
        <button type="button" onClick={() => onOpenCase("caf-2026")} className="notification-item is-new"><span className="notification-icon"><Icon name="shield" size={20} /></span><div><strong>Votre validation est nécessaire</strong><p>La réponse à la CAF est prête à être vérifiée.</p><small>Il y a 8 minutes</small></div></button>
        <button type="button" onClick={() => onOpenCase("controle-technique")} className="notification-item is-new"><span className="notification-icon"><Icon name="clock" size={20} /></span><div><strong>Échéance à anticiper</strong><p>Le contrôle technique arrive à expiration dans un mois.</p><small>Aujourd’hui à 09:15</small></div></button>
        <button type="button" onClick={() => onOpenCase("internet")} className="notification-item"><span className="notification-icon"><Icon name="check" size={20} /></span><div><strong>Dossier terminé</strong><p>La résiliation Internet est confirmée et la preuve est disponible.</p><small>30 juillet 2026</small></div></button>
      </div>
    </div>
  );
}

function ProfileView() {
  return (
    <div className="page-stack">
      <div className="page-heading"><div><span className="eyebrow">Compte de démonstration</span><h1>Profil et foyer</h1><p>Les informations réutilisables permettent d’éviter les ressaisies, toujours sous votre contrôle.</p></div></div>
      <div className="profile-grid">
        <section className="profile-card profile-card--identity"><span className="avatar avatar--large">CG</span><div><h2>Cyril Gay</h2><p>Compte principal · Hauts-de-France</p><span className="verified"><Icon name="check" size={14} /> Adresse e-mail vérifiée</span></div><button className="secondary-button" type="button">Modifier</button></section>
        <section className="profile-card"><SectionHeader title="Mon foyer" /><div className="setting-row"><span className="setting-icon">C</span><div><strong>Céline</strong><small>Membre du foyer</small></div><button type="button">Gérer</button></div><div className="setting-row"><span className="setting-icon">I</span><div><strong>Inès</strong><small>Enfant du foyer</small></div><button type="button">Gérer</button></div><button className="text-button" type="button">+ Ajouter une personne</button></section>
        <section className="profile-card"><SectionHeader title="Biens suivis" /><div className="setting-row"><span className="setting-icon">⌂</span><div><strong>Logement principal</strong><small>Adresse de démonstration</small></div><button type="button">Gérer</button></div><div className="setting-row"><span className="setting-icon">V</span><div><strong>Peugeot 3008</strong><small>Véhicule familial</small></div><button type="button">Gérer</button></div></section>
        <section className="profile-card"><SectionHeader title="Sécurité et données" /><div className="security-list"><button type="button"><Icon name="shield" size={20} /><span><strong>Confidentialité</strong><small>Conservation et autorisations</small></span><Icon name="arrow" size={17} /></button><button type="button"><Icon name="document" size={20} /><span><strong>Exporter mes données</strong><small>Archive structurée et documents</small></span><Icon name="arrow" size={17} /></button><button type="button"><Icon name="user" size={20} /><span><strong>Appareils connectés</strong><small>1 navigateur de démonstration</small></span><Icon name="arrow" size={17} /></button></div></section>
      </div>
    </div>
  );
}
