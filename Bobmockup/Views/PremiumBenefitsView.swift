//
//  PremiumBenefitsView.swift
//  Bobmockup
//
//  L'état Premium, après achat. Un relevé, pas une célébration.
//

import SwiftUI

struct PremiumBenefitsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseManager = PurchaseManager.shared
    @State private var isRestoring = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.x7) {
                    VStack(alignment: .leading, spacing: DS.Space.x4) {
                        HStack(spacing: 6) {
                            DSIcon(name: "checkmark.seal", size: 14)
                            Text("Actif")
                                .dsLabel()
                        }
                        .foregroundStyle(DS.Palette.paper)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(DS.Palette.paperWash, in: RoundedRectangle(cornerRadius: DS.Radius.control))

                        Text("Atelier illimité")
                            .dsDisplayL()
                            .foregroundStyle(DS.Palette.ink)

                        Text("Le compteur d'épreuves est désactivé. Tous les modes de tirage et toutes les dispositions sont accessibles.")
                            .dsBody()
                            .foregroundStyle(DS.Palette.ink2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, DS.Space.x5)

                    VStack(alignment: .leading, spacing: DS.Space.x3) {
                        DSSectionLabel(text: "Relevé")
                        HStack(alignment: .bottom, spacing: DS.Space.x4) {
                            Text("\(purchaseManager.conversionsUsed)")
                                .dsDisplayXL()
                                .foregroundStyle(DS.Palette.ink)
                            Text("épreuves tirées depuis l'installation")
                                .dsLabel()
                                .foregroundStyle(DS.Palette.ink3)
                                .padding(.bottom, 8)
                        }
                    }

                    VStack(alignment: .leading, spacing: DS.Space.x3) {
                        DSSectionLabel(text: "Inclus")
                        VStack(spacing: 0) {
                            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                                PremiumFeatureRow(icon: item.icon, title: item.title, detail: item.detail)
                                if index != items.count - 1 {
                                    Divider().overlay(DS.Palette.line)
                                }
                            }
                        }
                        .dsCard()
                    }

                    VStack(spacing: DS.Space.x2) {
                        Button {
                            Task {
                                isRestoring = true
                                await purchaseManager.restorePurchases()
                                isRestoring = false
                                restoreMessage = purchaseManager.isPremium
                                    ? "Achat restauré." : "Aucun achat à restaurer sur ce compte."
                            }
                        } label: {
                            if isRestoring { ProgressView() } else { Text("Restaurer un achat") }
                        }
                        .buttonStyle(DSGhostButton(expands: true))

                        if let restoreMessage {
                            Text(restoreMessage)
                                .dsCaption()
                                .foregroundStyle(DS.Palette.ink2)
                        }
                    }
                }
                .padding(.horizontal, DS.Space.screen)
                .padding(.bottom, DS.Space.x7)
            }
            .background(DS.Palette.base.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
    }

    private var items: [(icon: String, title: LocalizedStringKey, detail: LocalizedStringKey)] {
        [("square.on.square", "Tirages illimités", "Plus de compteur d'épreuves"),
         ("square.stack.3d.down.right", "Export par lot", "Les quatre tailles App Store d'un coup"),
         ("square.dashed", "Détourage", "PNG transparent, ombre en couche alpha"),
         ("doc", "PDF vectoriel", "Cadre, texte et ombre restent vectoriels"),
         ("rectangle.on.rectangle", "Séries et bandes", "Cinq écrans liés, bandeaux paysage")]
    }
}

#Preview {
    PremiumBenefitsView()
}
