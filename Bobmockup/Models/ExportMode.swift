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
    case appStore65  = "Dépôt 6,5 pouces"
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
        case .appStore65:  "1242 × 2688"
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
        case .appStore65:
            "La cote 6,5 pouces du dépôt, 1242 × 2688 au pixel près : le format choisi dans l'éditeur est ignoré pour ce tirage. La couche alpha se règle ci-dessous, et App Store Connect n'en accepte aucune."
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
        case .appStore65:  "square"
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
        case .appStore65:  "Dépôt 6,5 tiré"
        case .pdf:         "PDF tiré"
        case .clipboard:   "Copié"
        }
    }

    /// Certains tirages imposent leur cote et ignorent le format de l'éditeur :
    /// un dépôt 6,5 pouces n'est valable qu'en 1242 × 2688, au pixel près.
    var forcedExportSize: ExportSizePreset? {
        switch self {
        case .appStore65: .iphone65
        default: nil
        }
    }

    /// La couche alpha se décide au tirage, pas dans le code : c'est une
    /// option offerte sur tous les modes. Un PDF est la seule exception —
    /// il n'a pas de couche alpha à conserver ou à jeter, c'est un fait du
    /// format, pas un choix qu'on retirerait à l'utilisateur.
    var allowsAlphaChoice: Bool { self != .pdf }

    /// Le réglage que le mode appelle naturellement, adopté quand on
    /// bascule dessus. L'utilisateur reste libre de le contredire ensuite.
    ///
    /// Seul le détourage réclame la transparence : elle est sa raison d'être.
    /// Tout le reste part aplati, parce qu'App Store Connect refuse toute
    /// capture porteuse d'une couche alpha, même entièrement opaque.
    var naturalAlpha: Bool { self == .transparent }

    /// Vrai si ce réglage d'alpha rend le tirage irrecevable au dépôt.
    /// Sert à avertir, jamais à empêcher.
    func warnsAboutAppStore(includeAlpha: Bool) -> Bool {
        guard allowsAlphaChoice, includeAlpha else { return false }
        return self == .series || self == .batch || self == .appStore65
    }

    /// Vrai si ce réglage vide le mode de son sens — un détourage aplati
    /// n'est plus un détourage.
    func warnsAboutLostTransparency(includeAlpha: Bool) -> Bool {
        self == .transparent && !includeAlpha
    }

    /// Nombre de fichiers produits, pour annoncer le coût avant de tirer.
    func fileCount(for layout: CreationLayout) -> Int {
        switch self {
        case .single, .transparent, .appStore65, .pdf, .clipboard: 1
        case .series: 5
        case .batch: ExportSizePreset.batchSet.count
        }
    }

    var requiresPremium: Bool {
        switch self {
        case .single, .clipboard, .appStore65: false
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
