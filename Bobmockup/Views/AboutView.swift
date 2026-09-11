//
//  AboutView.swift
//  Bobmockup
//
//  Réglages et mentions. Les drapeaux emoji sont remplacés par un glyphe
//  monoline et le code de langue en chiffres tabulaires : une seule
//  famille d'icônes dans toute l'application.
//

import SwiftUI
import StoreKit

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @AppStorage("appLanguage") private var appLanguage = "fr"
    @State private var showGuide = false

    private static let privacyURL = URL(string: "https://boboul-cloud.github.io/bobmockup/privacy.html")
    private static let termsURL = URL(string: "https://boboul-cloud.github.io/bobmockup/terms.html")
    private static let contactEmail = URL(string: "mailto:bob.oulhen@gmail.com")
    private static let appStoreURL = URL(string: "https://apps.apple.com/app/bobmockup/id123456789")

    private let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.x6) {
                    VStack(alignment: .leading, spacing: DS.Space.x2) {
                        Text("BOBMOCKUP")
                            .font(.system(size: 26, weight: .black).width(.expanded))
                            .tracking(1.3)
                            .foregroundStyle(DS.Palette.ink)
                        Text("Version \(appVersion)")
                            .dsNumeric()
                            .foregroundStyle(DS.Palette.ink3)
                    }
                    .padding(.top, DS.Space.x5)

                    section("Langue") {
                        HStack(spacing: DS.Space.x3) {
                            DSIcon(name: "globe", size: 20)
                                .foregroundStyle(DS.Palette.ink2)
                            Text(appLanguage == "fr" ? "Français" : "English")
                                .dsBodyStrong()
                                .foregroundStyle(DS.Palette.ink)
                            Spacer()
                            DSSegmented(items: ["fr", "en"],
                                        selection: $appLanguage,
                                        label: { $0.uppercased() })
                                .frame(width: 116)
                        }
                        .padding(.horizontal, DS.Space.x4)
                        .frame(minHeight: 64)
                    }

                    section("Prise en main") {
                        Button { showGuide = true } label: {
                            rowContent("Mode d'emploi", icon: "book", external: false)
                        }
                        .buttonStyle(.plain)
                    }

                    section("Informations légales") {
                        linkRow("Confidentialité", icon: "hand.raised", url: Self.privacyURL, external: true)
                        Divider().overlay(DS.Palette.line)
                        linkRow("Conditions d'utilisation", icon: "doc.text", url: Self.termsURL, external: true)
                    }

                    section("Support") {
                        linkRow("Écrire à l'auteur", icon: "envelope", url: Self.contactEmail, external: true)
                        Divider().overlay(DS.Palette.line)
                        Button { requestAppReview() } label: {
                            rowContent("Noter l'application", icon: "star", external: false)
                        }
                        .buttonStyle(.plain)
                        if let url = Self.appStoreURL {
                            Divider().overlay(DS.Palette.line)
                            ShareLink(item: url) {
                                rowContent("Partager Bobmockup", icon: "square.and.arrow.up", external: false)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    VStack(alignment: .leading, spacing: DS.Space.x1) {
                        Text("Robert Oulhen, Rennes.")
                            .dsCaption()
                            .foregroundStyle(DS.Palette.ink2)
                        Text("© 2026 Bobmockup. Tous droits réservés.")
                            .dsCaption()
                            .foregroundStyle(DS.Palette.ink3)
                    }
                    .padding(.top, DS.Space.x2)
                }
                .padding(.horizontal, DS.Space.screen)
                .padding(.bottom, DS.Space.x7)
            }
            .background(DS.Palette.base.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("À propos").dsLabel().foregroundStyle(DS.Palette.ink3)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        DSIcon(name: "xmark", size: 18).foregroundStyle(DS.Palette.ink2)
                    }
                    .buttonStyle(.plain)
                    .dsHitTarget()
                        .accessibilityLabel("Fermer")
                }
            }
            .toolbarBackground(DS.Palette.base, for: .navigationBar)
        }
        .tint(DS.Palette.safelight)
        .sheet(isPresented: $showGuide) { UserGuideView() }
    }

    // MARK: - Composition

    private func section<Content: View>(_ title: LocalizedStringKey,
                                        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: title)
            VStack(spacing: 0) { content() }
                .dsCard()
        }
    }

    private func linkRow(_ title: LocalizedStringKey, icon: String,
                         url: URL?, external: Bool) -> some View {
        Button {
            if let url { openURL(url) }
        } label: {
            rowContent(title, icon: icon, external: external)
        }
        .buttonStyle(.plain)
        .disabled(url == nil)
    }

    private func rowContent(_ title: LocalizedStringKey, icon: String, external: Bool) -> some View {
        HStack(spacing: DS.Space.x3) {
            DSIcon(name: icon, size: 20)
                .foregroundStyle(DS.Palette.ink2)
            Text(title)
                .dsBodyStrong()
                .foregroundStyle(DS.Palette.ink)
            Spacer()
            DSIcon(name: external ? "arrow.up.right" : "chevron.right", size: 14)
                .foregroundStyle(DS.Palette.ink3)
        }
        .padding(.horizontal, DS.Space.x4)
        .frame(minHeight: 56)
        .contentShape(Rectangle())
    }

    @MainActor
    private func requestAppReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        AppStore.requestReview(in: scene)
    }
}

#Preview {
    AboutView()
}
