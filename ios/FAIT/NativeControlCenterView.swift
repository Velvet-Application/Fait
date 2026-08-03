import SwiftUI

struct NativeControlCenterView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @EnvironmentObject private var integrations: NativeIntegrationController
    @EnvironmentObject private var security: AppSecurityController
    @Environment(\.dismiss) private var dismiss
    @State private var calendarConsent = false
    @State private var draftConsent = false

    private var nextAppointment: ConnectedSignal? {
        environment.signals.first(where: { $0.kind == .appointment })
    }

    private var contractSignal: ConnectedSignal? {
        environment.signals.first(where: { $0.kind == .contract })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SERVICES NATIFS IPHONE")
                            .font(.caption2.bold())
                            .tracking(1.1)
                            .foregroundStyle(FAITColor.trustGreen)
                        Text("Connecter et protéger FAIT.")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(FAITColor.oliveCharcoal)
                        Text("Les autorisations sont demandées au moment utile. Les e-mails ne sont jamais envoyés automatiquement.")
                            .foregroundStyle(.secondary)
                    }

                    NativeConnectionCard()
                    FaceIDSettingsCard()

                    VStack(alignment: .leading, spacing: 14) {
                        Label("Calendrier iPhone", systemImage: "calendar.badge.plus")
                            .font(.headline)
                            .foregroundStyle(FAITColor.oliveCharcoal)
                        if let appointment = nextAppointment {
                            Text(appointment.title)
                                .font(.subheadline.weight(.semibold))
                            Text(appointment.dueDate?.formatted(date: .long, time: .shortened) ?? "Date à vérifier")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ConsentToggle(
                                isOn: $calendarConsent,
                                text: "J’ai vérifié la date et j’autorise l’ajout de ce rendez-vous au calendrier de l’iPhone."
                            )
                            Button {
                                Task {
                                    if await integrations.addToDeviceCalendar(signal: appointment, environment: environment) {
                                        calendarConsent = false
                                    }
                                }
                            } label: {
                                Label("Ajouter au calendrier", systemImage: "calendar.badge.checkmark")
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(!calendarConsent || integrations.isWorking)
                            .opacity(calendarConsent ? 1 : 0.5)
                        } else {
                            Text("Aucun rendez-vous détecté pour le moment.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(17)
                    .glassCard(cornerRadius: 23)

                    VStack(alignment: .leading, spacing: 14) {
                        Label("Brouillon Gmail", systemImage: "square.and.pencil")
                            .font(.headline)
                            .foregroundStyle(FAITColor.oliveCharcoal)
                        if let contract = contractSignal {
                            Text(contract.title)
                                .font(.subheadline.weight(.semibold))
                            Text("FAIT. créera uniquement un brouillon dans Gmail. L’envoi restera manuel depuis Gmail.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ConsentToggle(
                                isOn: $draftConsent,
                                text: "J’autorise la création du brouillon après vérification du destinataire et du contenu."
                            )
                            Button {
                                Task {
                                    let recipient = contract.metadata["replyTo"] ?? contract.sender
                                    let subject = "Re: \(contract.title)"
                                    let body = contract.metadata["suggestedReply"] ?? "Bonjour,\n\nJ’ai pris connaissance de votre message. Merci de me confirmer les conditions applicables et les solutions disponibles.\n\nCordialement,\nCyril"
                                    if await integrations.createGmailDraft(
                                        signal: contract,
                                        recipient: recipient,
                                        subject: subject,
                                        body: body,
                                        environment: environment
                                    ) {
                                        draftConsent = false
                                    }
                                }
                            } label: {
                                Label("Créer le brouillon", systemImage: "envelope.badge")
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                            .disabled(!draftConsent || integrations.isWorking)
                            .opacity(draftConsent ? 1 : 0.5)
                        } else {
                            Text("Aucun e-mail nécessitant une réponse n’a été détecté.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(17)
                    .glassCard(cornerRadius: 23)

                    WidgetInformationCard()

                    Label(
                        "Face ID est géré par le Secure Enclave. FAIT. ne reçoit jamais vos données biométriques.",
                        systemImage: "lock.shield.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(FAITColor.trustGreen)
                    .padding(.bottom, 20)
                }
                .padding(20)
            }
            .background(FAITColor.warmWhite)
            .navigationTitle("Centre iPhone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
}
