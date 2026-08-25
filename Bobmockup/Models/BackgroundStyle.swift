//
//  BackgroundStyle.swift
//  Bobmockup
//

import SwiftUI

enum BackgroundStyle: String, CaseIterable, Identifiable, Codable {
    case solid = "Uni"
    case gradient = "Dégradé"
    case mesh = "Mesh"
    case image = "Image"

    var id: String { rawValue }

    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

/// Les bains. Ce sont les couleurs de l'œuvre, pas celles de l'interface :
/// c'est le seul endroit de l'application où la couleur est libre.
struct GradientPreset: Identifiable {
    let id = UUID()
    let name: String
    let colors: [Color]
    /// Vrai si le bain est clair — le texte de l'accroche doit alors passer en encre.
    let isLight: Bool

    static func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }

    static let presets: [GradientPreset] = [
        GradientPreset(name: "Cyanotype",
                       colors: [rgb(14, 28, 46), rgb(30, 74, 115), rgb(111, 160, 200)], isLight: false),
        GradientPreset(name: "Révélateur",
                       colors: [rgb(26, 18, 16), rgb(91, 36, 23), rgb(192, 74, 36)], isLight: false),
        GradientPreset(name: "Baryté",
                       colors: [rgb(251, 250, 247), rgb(232, 226, 212), rgb(207, 199, 180)], isLight: true),
        GradientPreset(name: "Sépia",
                       colors: [rgb(36, 26, 18), rgb(107, 69, 38), rgb(192, 139, 77)], isLight: false),
        GradientPreset(name: "Encre",
                       colors: [rgb(8, 9, 10), rgb(28, 30, 34), rgb(51, 56, 63)], isLight: false),
        GradientPreset(name: "Sélénium",
                       colors: [rgb(22, 24, 38), rgb(58, 51, 82), rgb(126, 110, 158)], isLight: false),
        GradientPreset(name: "Argentique",
                       colors: [rgb(18, 33, 28), rgb(34, 73, 59), rgb(94, 156, 127)], isLight: false),
        GradientPreset(name: "Aurore",
                       colors: [rgb(43, 20, 34), rgb(140, 47, 74), rgb(226, 138, 106)], isLight: false),
    ]

    /// Le bain le plus proche d'une série de couleurs, pour retrouver
    /// le nom à afficher après rechargement d'un projet.
    static func named(matching colors: [Color]) -> GradientPreset? {
        presets.first { preset in
            preset.colors.count == colors.count &&
            zip(preset.colors, colors).allSatisfy { CodableColor($0) == CodableColor($1) }
        }
    }
}

/// Les fonds unis. Une gamme de gris d'atelier plus quatre teintes franches.
struct ColorPreset: Identifiable {
    let id = UUID()
    let name: String
    let color: Color

    static let presets: [ColorPreset] = [
        ColorPreset(name: "Papier", color: GradientPreset.rgb(244, 242, 237)),
        ColorPreset(name: "Baryté", color: GradientPreset.rgb(232, 226, 212)),
        ColorPreset(name: "Gris 50", color: GradientPreset.rgb(128, 128, 128)),
        ColorPreset(name: "Graphite", color: GradientPreset.rgb(35, 37, 40)),
        ColorPreset(name: "Encre", color: GradientPreset.rgb(14, 15, 16)),
        ColorPreset(name: "Safelight", color: GradientPreset.rgb(255, 77, 46)),
        ColorPreset(name: "Cyan", color: GradientPreset.rgb(30, 74, 115)),
        ColorPreset(name: "Vert-de-gris", color: GradientPreset.rgb(34, 73, 59)),
        ColorPreset(name: "Ocre", color: GradientPreset.rgb(192, 139, 77)),
        ColorPreset(name: "Prune", color: GradientPreset.rgb(58, 51, 82)),
    ]
}
