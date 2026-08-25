//
//  ExportMode.swift
//  Bobmockup
//
//  Un tirage se décrit sur deux axes indépendants : ce qu'il produit
//  (le mode) et où le résultat atterrit (la destination). Les confondre
//  obligeait à choisir « Photos » ou « Fichiers » au lieu de choisir
//  un contenu, et interdisait par exemple une série rangée dans Fichiers.
//

import SwiftUI

// MARK: - Ce que le tirage produit

enum ExportMode: String, CaseIterable, Identifiable, Codable {
    case single      = "Tirage simple"
    case series      = "Série App Store"
    case batch       = "Toutes les tailles"
    case transparent = "Appareil détouré"
    case pdf         = "PDF vectoriel"
    case clipboard   = "Copier"

    var id: String { rawValue }

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }

    var detail: LocalizedStringKey {
        switch self {
        case .single:      "1 image PNG"
        case .series:      "5 écrans numérotés"
        case .batch:       "6,9 · 6,5 · 6,1 · iPad 13"
        case .transparent: "PNG transparent"
        case .pdf:         "Fichiers uniquement"
        case .clipboard:   "Presse-papiers"
        }
    }

    var note: LocalizedStringKey {
        switch self {
        case .single:
            "Un seul PNG à la taille du cadre, rangé où vous le décidez."
        case .series:
            "Les cinq écrans de la série sont tirés d'un coup, numérotés 01 à 05, prêts pour App Store Connect."
        case .batch:
            "Le même visuel recomposé pour les quatre formats requis. Le cadrage est recalculé, jamais étiré."
        case .transparent:
            "L'appareil seul, fond supprimé, ombre conservée en couche alpha. Pour poser sur un site ou une présentation."
        case .pdf:
            "Cadre, texte et ombre restent vectoriels. Seule la capture est en pixels. Un PDF n'entre pas dans la photothèque : il va toujours dans Fichiers."
        case .clipboard:
            "Copié dans le presse-papiers, à coller directement dans Figma, Slack ou Mail. Rien n'est enregistré."
        }
    }

    var icon: String {
        switch self {
        case .single:      "photo"
        case .series:      "square.on.square"
        case .batch:       "square.stack.3d.down.right"
        case .transparent: "square.dashed"
        case .pdf:         "doc"
        case .clipboard:   "doc.on.doc"
        }
    }

    var successTitle: LocalizedStringKey {
        switch self {
        case .single:      "Épreuve tirée"
        case .series:      "Série tirée"
        case .batch:       "Lot tiré"
        case .transparent: "Détourage tiré"
        case .pdf:         "PDF tiré"
        case .clipboard:   "Copié"
        }
    }

    /// Nombre de fichiers produits, pour annoncer le coût avant de tirer.
    func fileCount(for layout: CreationLayout) -> Int {
        switch self {
        case .single, .transparent, .pdf, .clipboard: 1
        case .series: 5
        case .batch: ExportSizePreset.batchSet.count
        }
    }

    var requiresPremium: Bool {
        switch self {
        case .single, .clipboard: false
        case .series, .batch, .transparent, .pdf: true
        }
    }

    /// Les destinations réellement possibles pour ce mode.
    /// Le presse-papiers n'en a aucune ; un PDF n'entre pas dans la photothèque.
    var destinations: [ExportDestination] {
        switch self {
        case .clipboard: []
        case .pdf: [.files]
        default: ExportDestination.allCases
        }
    }
}

// MARK: - Où le résultat atterrit

enum ExportDestination: String, CaseIterable, Identifiable, Codable {
    case photos = "Photothèque"
    case files  = "Fichiers"

    var id: String { rawValue }

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }

    var icon: String {
        switch self {
        case .photos: "photo.on.rectangle"
        case .files:  "folder"
        }
    }

    /// Formulation utilisée sur l'écran de réussite.
    var pastTense: String {
        switch self {
        case .photos: "dans Photos"
        case .files:  "dans Fichiers"
        }
    }
}
