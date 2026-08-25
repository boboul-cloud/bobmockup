//
//  PremiumUpgradeView.swift
//  Bobmockup
//
//  Le paywall. Pas de couronne dorée ni de dégradé : l'accent Premium est
//  le papier baryté, le ton chaud du tirage réussi.
//

import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @Bindable var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccess = false

    private var priceLabel: String {
        purchaseManager.products.first?.displayPrice ?? "14,99 €"
    }

    var body: some View {
        ZStack {
            DS.Palette.base.ignoresSafeArea()

            if showSuccess {
                PurchaseSuccessView { dismiss() }
                    .transition(.opacity)
            } else {
                content
            }
        }
        .animation(DS.Motion.surface, value: showSuccess)
        .tint(DS.Palette.safelight)
        .onChange(of: purchaseManager.purchaseState) { _, state in
            if state == .success {
                DS.Haptics.success()
                showSuccess = true
            }
        }
        .task { if purchaseManager.products.isEmpty { await purchaseManager.loadProducts() } }
    }

    private var content: some View {
        VStack(spacing: 0) {
            HStack {
                Button { dismiss() } label: { DSIcon(name: "xmark", size: 18) }
                    .dsHitTarget()
                    .foregroundStyle(DS.Palette.ink2)
                    .accessibilityLabel("Fermer")
                Spacer()
                Text("Abonnement")
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)
                Spacer()
                Color.clear.frame(width: DS.hit, height: DS.hit)
            }
            .padding(.horizontal, DS.Space.x4)
            .padding(.top, DS.Space.x3)

            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.x7) {
                    VStack(alignment: .leading, spacing: DS.Space.x4) {
                        HStack(spacing: 6) {
                            DSIcon(name: "checkmark.seal", size: 14)
                            Text("Atelier illimité")
                                .dsLabel()
                        }
                        .foregroundStyle(DS.Palette.paper)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(DS.Palette.paperWash, in: RoundedRectangle(cornerRadius: DS.Radius.control))

                        Text("Le compteur s'arrête ici.")
                            .dsDisplayL()
                            .foregroundStyle(DS.Palette.ink)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(usageSentence)
                            .dsBody()
                            .foregroundStyle(DS.Palette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, DS.Space.x6)

                    VStack(alignment: .leading, spacing: DS.Space.x3) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(priceLabel)
                                .dsDisplayM()
                                .foregroundStyle(DS.Palette.paper)
                            Spacer()
                            Text("Achat unique")
                                .dsLabel()
                                .foregroundStyle(DS.Palette.paper)
                        }
                        Text("Pas d'abonnement, pas de renouvellement. Vous payez une fois, l'atelier reste ouvert.")
                            .dsCaption()
                            .foregroundStyle(DS.Palette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(DS.Space.x5)
                    .background(DS.Palette.paperWash, in: RoundedRectangle(cornerRadius: DS.Radius.card))
                    .overlay(RoundedRectangle(cornerRadius: DS.Radius.card).stroke(DS.Palette.paper, lineWidth: 1))

                    VStack(alignment: .leading, spacing: DS.Space.x3) {
                        DSSectionLabel(text: "Ce que ça débloque")
                        VStack(spacing: 0) {
                            ForEach(Array(benefits.enumerated()), id: \.offset) { index, benefit in
                                PremiumFeatureRow(icon: benefit.icon,
                                                  title: benefit.title,
                                                  detail: benefit.detail)
                                if index != benefits.count - 1 {
                                    Divider().overlay(DS.Palette.line)
                                }
                            }
                        }
                        .dsCard()
                    }

                    VStack(spacing: DS.Space.x2) {
                        Button {
                            Task { await purchaseManager.purchase() }
                        } label: {
                            if purchaseManager.purchaseState == .purchasing {
                                ProgressView().tint(DS.Palette.onSafelight)
                            } else {
                                Text("Ouvrir l'atelier — \(priceLabel)")
                            }
                        }
                        .buttonStyle(DSPillButton(expands: true))
                        .disabled(purchaseManager.purchaseState == .purchasing)

                        Button("Restaurer un achat") {
                            Task { await purchaseManager.restorePurchases() }
                        }
                        .dsCaption()
                        .foregroundStyle(DS.Palette.safelight)
                        .frame(minHeight: DS.hit)

                        if case .failed(let message) = purchaseManager.purchaseState {
                            DSNote(icon: "exclamationmark.triangle", text: LocalizedStringKey(message))
                        }

                        Text("Paiement via l'App Store. Aucune donnée ne quitte votre appareil.")
                            .dsCaption()
                            .foregroundStyle(DS.Palette.ink3)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, DS.Space.screen)
                .padding(.bottom, DS.Space.x7)
            }
        }
    }

    private var usageSentence: LocalizedStringKey {
        "Vous avez tiré \(purchaseManager.conversionsUsed) épreuves sur \(PurchaseManager.freeConversionsLimit). Passez à l'atelier illimité et gardez la main sur les formats, la résolution et le détourage."
    }

    private var benefits: [(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey)] {
        [("square.on.square", "Tirages illimités", "Plus de compteur d'épreuves"),
         ("square.stack.3d.down.right", "Export par lot", "Les quatre tailles App Store d'un coup"),
         ("square.dashed", "Détourage et PDF", "PNG transparent, PDF vectoriel"),
         ("rectangle.on.rectangle", "Séries et bandes", "Cinq écrans liés, bandeaux paysage")]
    }
}

// MARK: - Ligne d'avantage

struct PremiumFeatureRow: View {
    let icon: String
    let title: LocalizedStringKey
    let detail: LocalizedStringKey

    var body: some View {
        HStack(spacing: DS.Space.x3) {
            DSIcon(name: icon, size: 20)
                .foregroundStyle(DS.Palette.ink2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .dsBodyStrong()
                    .foregroundStyle(DS.Palette.ink)
                Text(detail)
                    .dsCaption()
                    .foregroundStyle(DS.Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, DS.Space.x4)
        .frame(minHeight: 56)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Réussite d'achat

struct PurchaseSuccessView: View {
    let onDismiss: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var flash: Double = 0

    var body: some View {
        ZStack {
            DS.Palette.base.ignoresSafeArea()
            DS.Palette.paper.opacity(flash).ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: DS.Space.x5) {
                DSIcon(name: "checkmark.seal", size: 32)
                    .foregroundStyle(DS.Palette.paper)
                Text("L'atelier est ouvert")
                    .dsDisplayL()
                    .foregroundStyle(DS.Palette.ink)
                    .multilineTextAlignment(.center)
                Text("Le compteur est désactivé. Tous les modes de tirage sont accessibles.")
                    .dsBody()
                    .foregroundStyle(DS.Palette.ink2)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Button("Revenir à l'atelier", action: onDismiss)
                    .buttonStyle(DSPillButton(expands: true))
                    .padding(.top, DS.Space.x2)
            }
            .padding(.horizontal, DS.Space.x7)
        }
        .onAppear {
            guard !reduceMotion else { return }
            flash = 0.55
            withAnimation(.easeIn(duration: 0.35)) { flash = 0 }
        }
    }
}

#Preview {
    PremiumUpgradeView(purchaseManager: PurchaseManager.shared)
}
