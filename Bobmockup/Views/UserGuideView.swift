//
//  UserGuideView.swift
//  Bobmockup
//
//  Le mode d'emploi. Les tableaux de modes, de dispositions et de cotes
//  sont lus dans les énumérations, jamais recopiés : un mode ajouté
//  apparaît ici de lui-même, et le manuel ne peut pas mentir sur une cote.
//  Seul le fil du propos est écrit à la main.
//

import SwiftUI

struct UserGuideView: View {
    @Environment(\.dismiss) private var dismiss

    /// Les étapes du travail, dans l'ordre où on les rencontre.
    private let steps: [Step] = [
        Step(number: 1,
             icon: "square.grid.2x2",
             title: "Choisir une disposition",
             body: "Elle fixe le nombre d'appareils dans le cadre et le nombre d'images produites. Tout reste modifiable ensuite — la disposition n'enferme rien."),
        Step(number: 2,
             icon: "photo.badge.plus",
             title: "Poser la capture",
             body: "Depuis la photothèque ou depuis Fichiers. L'image se cale au pixel dans l'écran de l'appareil, encoche et coins arrondis compris. Aucun recadrage n'est appliqué dans votre dos."),
        Step(number: 3,
             icon: "slider.horizontal.3",
             title: "Régler",
             body: "Fond, ombre, rotation, échelle, légende, badges. Chaque course a un cran de rappel : un retour franc sous le doigt marque le neutre. Un réglage se défait toujours."),
        Step(number: 4,
             icon: "ruler",
             title: "Choisir le format de sortie",
             body: "La cote du cadre et son orientation, portrait ou paysage, annoncées en pixels en haut de l'écran de tirage. C'est elle que vous obtenez, au pixel près."),
        Step(number: 5,
             icon: "square.dashed",
             title: "Décider de la couche alpha",
             body: "Proposée sur tous les modes. Désactivée, le PNG part aplati — c'est ce qu'exige App Store Connect. Activée, la transparence est conservée."),
        Step(number: 6,
             icon: "square.and.arrow.up",
             title: "Tirer",
             body: "Un tirage se décrit sur deux axes indépendants : ce qu'il produit, et où il atterrit. Choisissez l'un puis l'autre.")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.x7) {
                    preamble
                    stepsSection
                    layoutsSection
                    sizesSection
                    modesSection
                    destinationsSection
                    appStoreSection
                    premiumSection
                    colophon
                }
                .padding(.horizontal, DS.Space.screen)
                .padding(.bottom, DS.Space.x7)
            }
            .background(DS.Palette.base.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Mode d'emploi").dsLabel().foregroundStyle(DS.Palette.ink3)
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
    }

    // MARK: - Préambule

    private var preamble: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            Text("Manuel")
                .dsLabel()
                .foregroundStyle(DS.Palette.ink3)
            Text("Tirer une épreuve")
                .dsDisplayL()
                .foregroundStyle(DS.Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text("Bobmockup travaille comme un labo : cadre exact, fond maîtrisé, cotes affichées. Ce que montre l'aperçu est ce qui sort du tirage — il n'y a pas de surprise à l'arrivée.")
                .dsBody()
                .foregroundStyle(DS.Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, DS.Space.x5)
    }

    // MARK: - Les cinq temps

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Le travail, dans l'ordre")

            VStack(spacing: 0) {
                ForEach(steps) { step in
                    HStack(alignment: .top, spacing: DS.Space.x3) {
                        Text(String(format: "%02d", step.number))
                            .dsNumeric()
                            .foregroundStyle(DS.Palette.safelight)
                            .frame(width: 24, alignment: .leading)
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: DS.Space.x1) {
                            HStack(spacing: DS.Space.x2) {
                                DSIcon(name: step.icon, size: 16)
                                    .foregroundStyle(DS.Palette.ink2)
                                Text(step.title)
                                    .dsBodyStrong()
                                    .foregroundStyle(DS.Palette.ink)
                            }
                            Text(step.body)
                                .dsCaption()
                                .foregroundStyle(DS.Palette.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(DS.Space.x4)

                    if step.number != steps.count {
                        Divider().overlay(DS.Palette.line)
                    }
                }
            }
            .dsCard()
        }
    }

    // MARK: - Dispositions

    private var layoutsSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Les dispositions")

            VStack(spacing: 0) {
                ForEach(Array(CreationLayout.allCases.enumerated()), id: \.element.id) { index, layout in
                    row(title: layout.localizedName,
                        trailing: layout.detailText,
                        icon: "rectangle.on.rectangle",
                        locked: layout.requiresPremium)

                    if index != CreationLayout.allCases.count - 1 {
                        Divider().overlay(DS.Palette.line)
                    }
                }
            }
            .dsCard()

            DSNote(text: "La disposition « Bande » impose son format paysage. Les autres vous laissent choisir librement la cote de sortie.")

            DSNote(icon: "rectangle.split.2x1",
                   text: "Panorama : deux écrans qui se suivent. Le fond court de l'un à l'autre et l'appareil est posé à cheval sur la jointure, une moitié sur chaque écran. Le tirage produit deux PNG numérotés 01 et 02 : déposez-les dans cet ordre, l'un à côté de l'autre sur la fiche.")
        }
    }

    // MARK: - Cotes

    private var sizesSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Les cotes de sortie")

            VStack(spacing: 0) {
                ForEach(Array(ExportSizePreset.allCases.enumerated()), id: \.element.id) { index, preset in
                    row(title: preset.localizedName,
                        trailing: preset.dimensionLabel,
                        icon: preset.icon,
                        locked: false)

                    if index != ExportSizePreset.allCases.count - 1 {
                        Divider().overlay(DS.Palette.line)
                    }
                }
            }
            .dsCard()

            DSNote(icon: "ruler",
                   text: "Les quatre premières cotes sont celles qu'App Store Connect réclame. La cote 6,5 pouces — 1242 × 2688 — reste exigée pour les fiches qui la déclarent encore.")

            DSNote(icon: "rectangle.landscape.rotate",
                   text: "En paysage, chaque cote pivote : 1290 × 2796 devient 2796 × 1290 — les cotes paysage qu'accepte App Store Connect. L'iPhone et l'iPad se couchent avec le cadre ; le MacBook, déjà en paysage, reste d'aplomb. Le bouton de rotation, en haut de l'éditeur, bascule d'un geste.")
        }
    }

    // MARK: - Modes de tirage

    private var modesSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Ce que le tirage produit")

            VStack(spacing: 0) {
                ForEach(Array(ExportMode.allCases.enumerated()), id: \.element.id) { index, mode in
                    // Le nom garde sa ligne : « Série App Store » et l'étiquette
                    // se disputaient la largeur et se coupaient l'un l'autre.
                    VStack(alignment: .leading, spacing: DS.Space.x2) {
                        HStack(spacing: DS.Space.x3) {
                            DSIcon(name: mode.icon, size: 18)
                                .foregroundStyle(DS.Palette.ink2)
                            Text(mode.localizedName)
                                .dsBodyStrong()
                                .foregroundStyle(DS.Palette.ink)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: DS.Space.x2)
                            if mode.requiresPremium { premiumTag }
                        }

                        VStack(alignment: .leading, spacing: DS.Space.x1) {
                            Text(mode.detail)
                                .dsLabel()
                                .foregroundStyle(DS.Palette.ink3)
                            Text(mode.note)
                                .dsCaption()
                                .foregroundStyle(DS.Palette.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.leading, 18 + DS.Space.x3)
                    }
                    .padding(DS.Space.x4)

                    if index != ExportMode.allCases.count - 1 {
                        Divider().overlay(DS.Palette.line)
                    }
                }
            }
            .dsCard()
        }
    }

    // MARK: - Destinations

    private var destinationsSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Où le résultat atterrit")

            VStack(spacing: 0) {
                ForEach(Array(ExportDestination.allCases.enumerated()), id: \.element.id) { index, destination in
                    row(title: destination.localizedName,
                        trailing: destination.pastTense,
                        icon: destination.icon,
                        locked: false)

                    if index != ExportDestination.allCases.count - 1 {
                        Divider().overlay(DS.Palette.line)
                    }
                }
            }
            .dsCard()

            DSNote(text: "Deux exceptions tenues par la plateforme, pas par l'application : le presse-papiers n'enregistre rien, et la photothèque iOS n'accepte pas un PDF.")
        }
    }

    // MARK: - Dépôt App Store

    private var appStoreSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Déposer sur App Store Connect")

            VStack(alignment: .leading, spacing: DS.Space.x3) {
                Text("App Store Connect refuse toute capture porteuse d'une couche alpha, même entièrement opaque. C'est le motif de rejet le plus courant, et le plus déroutant : l'image paraît normale partout ailleurs.")
                    .dsCaption()
                    .foregroundStyle(DS.Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("La couche alpha se règle au tirage, sur tous les modes : « Conserver le canal alpha », juste sous le choix du mode. Elle part désactivée, parce que c'est ce que le dépôt exige.")
                    .dsCaption()
                    .foregroundStyle(DS.Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: DS.Space.x3) {
                    alphaCase(icon: "square",
                              title: "Canal désactivé",
                              body: "PNG aplati à trois canaux. C'est le réglage à garder pour tout ce qui part sur App Store Connect.")
                    alphaCase(icon: "square.dashed",
                              title: "Canal activé",
                              body: "PNG à quatre canaux, transparence conservée. Pour poser un appareil détouré sur un site ou une présentation.")
                }
                .padding(.leading, DS.Space.x1)
            }
            .padding(DS.Space.x4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsCard()

            DSNote(text: "Rien n'est interdit : un réglage qui dessert votre intention est signalé au moment du tirage, jamais bloqué. Bobmockup vous avertit, vous décidez.")
        }
    }

    // MARK: - Atelier illimité

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "L'atelier illimité")

            VStack(alignment: .leading, spacing: DS.Space.x3) {
                Text("Un mode réservé n'est jamais caché : il reste visible et désigné comme tel. Vous voyez ce que l'atelier illimité ouvre avant de décider, et l'achat vous est proposé au moment où il sert.")
                    .dsCaption()
                    .foregroundStyle(DS.Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: DS.Space.x2) {
                    ForEach(ExportMode.allCases.filter(\.requiresPremium)) { mode in
                        HStack(spacing: DS.Space.x2) {
                            DSIcon(name: "lock", size: 13)
                                .foregroundStyle(DS.Palette.ink3)
                            Text(mode.localizedName)
                                .dsCaption()
                                .foregroundStyle(DS.Palette.ink)
                        }
                    }
                }
                .padding(.leading, DS.Space.x1)
            }
            .padding(DS.Space.x4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .dsCard()
        }
    }

    private var colophon: some View {
        Text("Un tirage raté ne coûte qu'un geste : refaites-le. Rien n'est écrasé sans que vous l'ayez demandé.")
            .dsCaption()
            .foregroundStyle(DS.Palette.ink3)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, DS.Space.x2)
    }

    // MARK: - Composition

    private func alphaCase(icon: String,
                           title: LocalizedStringKey,
                           body: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: DS.Space.x2) {
            DSIcon(name: icon, size: 14)
                .foregroundStyle(DS.Palette.safelight)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .dsCaption()
                    .foregroundStyle(DS.Palette.ink)
                Text(body)
                    .dsCaption()
                    .foregroundStyle(DS.Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var premiumTag: some View {
        Text("ATELIER")
            .dsLabel()
            .foregroundStyle(DS.Palette.safelight)
            .padding(.horizontal, DS.Space.x2)
            .padding(.vertical, 2)
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(DS.Palette.safelight, lineWidth: 1)
            )
    }

    private func row(title: LocalizedStringKey,
                     trailing: String,
                     icon: String,
                     locked: Bool) -> some View {
        HStack(spacing: DS.Space.x3) {
            DSIcon(name: icon, size: 18)
                .foregroundStyle(DS.Palette.ink2)
            Text(title)
                .dsBodyStrong()
                .foregroundStyle(DS.Palette.ink)
            if locked {
                DSIcon(name: "lock", size: 12)
                    .foregroundStyle(DS.Palette.ink3)
            }
            Spacer(minLength: DS.Space.x2)
            Text(trailing)
                .dsNumeric()
                .foregroundStyle(DS.Palette.ink3)
        }
        .padding(.horizontal, DS.Space.x4)
        .frame(minHeight: 56)
    }

    // MARK: - Modèle

    private struct Step: Identifiable {
        let number: Int
        let icon: String
        let title: LocalizedStringKey
        let body: LocalizedStringKey

        var id: Int { number }
    }
}

#Preview {
    UserGuideView()
}
