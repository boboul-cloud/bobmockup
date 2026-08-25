//
//  DesignSystem.swift
//  Bobmockup
//
//  Direction artistique « Chambre Noire ».
//  Source unique des couleurs, de la typographie, des espacements et des
//  modificateurs réutilisables. Aucune vue ne doit déclarer une couleur,
//  une taille de police ou une marge en dur.
//
//  Trois règles tiennent le système :
//  1. Un seul accent — le safelight. Il ne décore jamais : il signale
//     l'élément manipulé, l'état actif, ou l'action irréversible.
//  2. Aucune couleur d'interface dans le canevas. Le canevas est neutre,
//     c'est la seule surface où l'utilisateur juge une couleur.
//  3. Seul le mockup projette une ombre. La profondeur de l'interface
//     vient de la valeur des surfaces, pas d'ombres portées.
//

import SwiftUI
import UIKit

enum DS {

    // MARK: - Couleur

    /// Construit une couleur qui bascule seule entre les deux thèmes.
    private static func dyn(_ light: UInt32, _ dark: UInt32) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
    }

    enum Palette {
        /// Fond d'application, le plus profond.
        static let base      = dyn(0xF4F2ED, 0x0E0F10)
        /// Barres, panneaux, feuilles modales.
        static let chassis   = dyn(0xFBFAF7, 0x17181A)
        /// Cartes, champs, lignes de liste.
        static let raised    = dyn(0xFFFFFF, 0x202225)
        /// Puits : le canevas, les champs enfoncés.
        static let well      = dyn(0xE8E5DE, 0x08090A)

        /// Filets et séparateurs — décoratifs, non soumis au contraste texte.
        static let line      = dyn(0xDDD9D0, 0x2C2F33)
        /// Bordure d'un contrôle porteur de sens.
        static let lineStrong = dyn(0xBFB9AC, 0x3D4145)

        /// Texte principal. Blanc cassé en sombre, jamais #FFF pur. 16:1 / 17:1
        static let ink       = dyn(0x16171A, 0xF2F1EE)
        /// Texte secondaire, légendes. 5.9:1 / 8.2:1
        static let ink2      = dyn(0x5C5E5A, 0xA9AAA7)
        /// Texte tertiaire, unités, désactivé. 5.0:1 / 5.7:1
        static let ink3      = dyn(0x676964, 0x8A8C89)

        /// L'accent unique. 5.4:1 sur papier / 5.8:1 sur graphite.
        static let safelight = dyn(0xB8301A, 0xFF4D2E)
        /// Texte posé SUR le safelight. Mesuré : le blanc échoue en sombre (2.9:1).
        static let onSafelight = dyn(0xFFFFFF, 0x0E0F10)
        /// Remplissage d'état actif et halo.
        static var safelightWash: Color { safelight.opacity(0.12) }

        /// Papier baryté — réservé à Premium et à la réussite d'un tirage.
        static let paper     = dyn(0x7A5C22, 0xE8E2D4)
        static var paperWash: Color { paper.opacity(0.12) }

        /// Damier du canevas. Neutre par construction.
        static let checkerA  = dyn(0xDEDAD2, 0x141517)
        static let checkerB  = dyn(0xE8E5DE, 0x0F1012)
    }

    // MARK: - Espacement — base 4 pt, échelle fermée

    enum Space {
        static let x1: CGFloat = 4
        static let x2: CGFloat = 8
        static let x3: CGFloat = 12
        static let x4: CGFloat = 16
        static let x5: CGFloat = 20
        static let x6: CGFloat = 24
        static let x7: CGFloat = 32
        static let x8: CGFloat = 40
        static let x9: CGFloat = 56

        /// Marge latérale d'écran.
        static let screen: CGFloat = 20
        /// Gouttière entre éléments d'une même grille.
        static let gutter: CGFloat = 12
    }

    // MARK: - Rayons — 4 valeurs, plus la pilule

    enum Radius {
        /// Le canevas et l'aperçu d'export. Une épreuve n'a pas de coins arrondis.
        static let canvas: CGFloat = 0
        static let control: CGFloat = 6
        static let card: CGFloat = 12
        static let sheet: CGFloat = 20
    }

    /// Zone tactile minimale imposée par les HIG.
    static let hit: CGFloat = 44

    // MARK: - Durées et courbes

    enum Motion {
        static let surface  = Animation.spring(response: 0.34, dampingFraction: 0.86)
        static let select   = Animation.spring(response: 0.24, dampingFraction: 0.78)
        static let detent   = Animation.spring(response: 0.18, dampingFraction: 0.90)
        static let tab      = Animation.spring(response: 0.28, dampingFraction: 0.85)
        /// Le safelight s'allume vite…
        static let lightOn  = Animation.easeOut(duration: 0.14)
        /// …et s'éteint lentement. Une lampe met plus de temps à refroidir.
        static let lightOff = Animation.easeIn(duration: 0.22)

        /// Remplace les ressorts par un fondu court quand l'utilisateur
        /// a demandé moins de mouvement.
        static func respectful(_ animation: Animation, reduceMotion: Bool) -> Animation {
            reduceMotion ? .easeOut(duration: 0.18) : animation
        }
    }

    // MARK: - Retour haptique

    enum Haptics {
        static func light()  { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
        static func medium() { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
        static func heavy()  { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
        /// Le seul haptique franc de l'app : le cran de rappel d'une course.
        static func detent() { UIImpactFeedbackGenerator(style: .rigid).impactOccurred() }
        static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
        static func error()   { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    }
}

// MARK: - Typographie

extension DS {

    /// Famille d'affichage optionnelle. Laissez `nil` pour utiliser
    /// San Francisco en chasse étendue (iOS 16+), qui fournit déjà le
    /// contraste de graisse recherché sans embarquer de fichier.
    /// Pour passer à Archivo Expanded : ajoutez le .ttf au bundle,
    /// déclarez-le dans UIAppFonts et mettez son nom PostScript ici.
    static let displayFamily: String? = nil

    /// Spécification typographique complète d'un rôle.
    struct TypeSpec {
        var size: CGFloat
        var weight: Font.Weight
        var width: Font.Width
        var relativeTo: UIFont.TextStyle
        var tracking: CGFloat = 0
        var lineSpacingRatio: CGFloat = 0
        var uppercase: Bool = false
        /// Plafond de mise à l'échelle. Un chiffre de 56 pt ne peut pas
        /// doubler sans faire éclater la mise en page.
        var maxCategory: UIContentSizeCategory? = nil
        var useDisplayFamily: Bool = false

        func scaledSize(for typeSize: DynamicTypeSize) -> CGFloat {
            var category = typeSize.contentSizeCategory
            if let cap = maxCategory, category > cap { category = cap }
            let traits = UITraitCollection(preferredContentSizeCategory: category)
            return UIFontMetrics(forTextStyle: relativeTo)
                .scaledValue(for: size, compatibleWith: traits)
        }

        func font(for typeSize: DynamicTypeSize) -> Font {
            let s = scaledSize(for: typeSize)
            if useDisplayFamily, let family = DS.displayFamily {
                return .custom(family, fixedSize: s).weight(weight)
            }
            return .system(size: s, weight: weight).width(width)
        }

        func lineSpacing(for typeSize: DynamicTypeSize) -> CGFloat {
            lineSpacingRatio * scaledSize(for: typeSize)
        }
    }

    enum Typo {
        /// Le nombre héros. Plafonné, sinon il casse la barre.
        static let displayXL = TypeSpec(size: 56, weight: .black, width: .expanded,
                                        relativeTo: .largeTitle, tracking: -1.1,
                                        maxCategory: .accessibilityMedium, useDisplayFamily: true)
        /// Titre d'écran.
        static let displayL  = TypeSpec(size: 30, weight: .black, width: .expanded,
                                        relativeTo: .title1, tracking: -0.3,
                                        maxCategory: .accessibilityLarge, useDisplayFamily: true)
        /// Titre de section modale.
        static let displayM  = TypeSpec(size: 22, weight: .bold, width: .expanded,
                                        relativeTo: .title2, useDisplayFamily: true)
        /// Titre de carte.
        static let title     = TypeSpec(size: 17, weight: .semibold, width: .standard,
                                        relativeTo: .headline, tracking: -0.17)
        static let body      = TypeSpec(size: 15, weight: .regular, width: .standard,
                                        relativeTo: .body, lineSpacingRatio: 0.20)
        static let bodyStrong = TypeSpec(size: 15, weight: .semibold, width: .standard,
                                         relativeTo: .body, lineSpacingRatio: 0.20)
        static let caption   = TypeSpec(size: 13, weight: .regular, width: .standard,
                                        relativeTo: .footnote, lineSpacingRatio: 0.12)
        /// La signature du système : l'étiquette gravée, en capitales espacées.
        static let label     = TypeSpec(size: 10, weight: .semibold, width: .standard,
                                        relativeTo: .caption2, tracking: 1.0,
                                        uppercase: true, maxCategory: .accessibilityMedium)
        /// Cotes et valeurs. Chiffres tabulaires : la valeur ne tremble pas
        /// sous le doigt pendant qu'on fait glisser une course.
        static let numeric   = TypeSpec(size: 13, weight: .semibold, width: .standard,
                                        relativeTo: .footnote, tracking: 0.13)
    }
}

private struct DSTypeModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var typeSize
    let spec: DS.TypeSpec
    let monospacedDigits: Bool

    func body(content: Content) -> some View {
        content
            .font(monospacedDigits ? spec.font(for: typeSize).monospacedDigit()
                                   : spec.font(for: typeSize))
            .tracking(spec.tracking)
            .lineSpacing(spec.lineSpacing(for: typeSize))
            .textCase(spec.uppercase ? .uppercase : nil)
    }
}

extension View {
    func dsType(_ spec: DS.TypeSpec, monospacedDigits: Bool = false) -> some View {
        modifier(DSTypeModifier(spec: spec, monospacedDigits: monospacedDigits))
    }

    func dsDisplayXL() -> some View { dsType(DS.Typo.displayXL, monospacedDigits: true) }
    func dsDisplayL()  -> some View { dsType(DS.Typo.displayL) }
    func dsDisplayM()  -> some View { dsType(DS.Typo.displayM) }
    func dsTitle()     -> some View { dsType(DS.Typo.title) }
    func dsBody()      -> some View { dsType(DS.Typo.body) }
    func dsBodyStrong() -> some View { dsType(DS.Typo.bodyStrong) }
    func dsCaption()   -> some View { dsType(DS.Typo.caption) }
    func dsLabel()     -> some View { dsType(DS.Typo.label) }
    func dsNumeric()   -> some View { dsType(DS.Typo.numeric, monospacedDigits: true) }
}

// MARK: - Surfaces

extension View {
    /// E1 — carte ou ligne de liste.
    func dsCard(radius: CGFloat = DS.Radius.card) -> some View {
        background(DS.Palette.raised, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(DS.Palette.line, lineWidth: 1)
            )
    }

    /// E2 — barre d'action : châssis, filet supérieur, aucune ombre.
    func dsChassisBar() -> some View {
        background(alignment: .top) {
            ZStack(alignment: .top) {
                DS.Palette.chassis
                DS.Palette.line.frame(height: 1)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    /// Cible tactile de 44 pt garantie, quel que soit le visuel.
    func dsHitTarget(_ size: CGFloat = DS.hit) -> some View {
        frame(minWidth: size, minHeight: size)
            .contentShape(Rectangle())
    }
}

// MARK: - Boutons

/// L'action irréversible. C'est le seul bouton plein de l'application.
struct DSPillButton: ButtonStyle {
    var expands: Bool = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsBodyStrong()
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundStyle(isEnabled ? DS.Palette.onSafelight : DS.Palette.ink3)
            .padding(.horizontal, DS.Space.x5)
            .frame(minHeight: DS.hit)
            .frame(maxWidth: expands ? .infinity : nil)
            .background(isEnabled ? DS.Palette.safelight : DS.Palette.raised, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(DS.Motion.select, value: configuration.isPressed)
    }
}

/// L'action secondaire : contour, jamais de remplissage coloré.
struct DSGhostButton: ButtonStyle {
    var expands: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsBody()
            .foregroundStyle(DS.Palette.ink)
            .padding(.horizontal, DS.Space.x4)
            .frame(minHeight: DS.hit)
            .frame(maxWidth: expands ? .infinity : nil)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                    .fill(configuration.isPressed ? DS.Palette.raised : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                    .stroke(DS.Palette.lineStrong, lineWidth: 1)
            )
    }
}

/// L'action de barre : discrète, texte + icône monoline.
struct DSQuietButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .dsCaption()
            .foregroundStyle(configuration.isPressed ? DS.Palette.ink : DS.Palette.ink2)
            .frame(maxWidth: .infinity, minHeight: DS.hit)
            .background(
                RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                    .fill(configuration.isPressed ? DS.Palette.raised : Color.clear)
            )
    }
}

// MARK: - Composants partagés

/// L'étiquette d'atelier : capitales espacées, filet qui court jusqu'au bord.
struct DSSectionLabel: View {
    let text: LocalizedStringKey

    var body: some View {
        HStack(spacing: DS.Space.x2) {
            Text(text)
                .dsLabel()
                .foregroundStyle(DS.Palette.ink3)
            Rectangle()
                .fill(DS.Palette.line)
                .frame(height: 1)
        }
        .accessibilityAddTraits(.isHeader)
    }
}

/// Icône monoline. Un seul style dans toute l'application :
/// contour = inactif, plein = actif. Trois tailles optiques, pas une de plus.
struct DSIcon: View {
    let name: String
    var size: CGFloat = 20
    var active: Bool = false

    var body: some View {
        Image(systemName: active ? "\(name).fill" : name)
            .font(.system(size: size, weight: .regular))
            .symbolRenderingMode(.monochrome)
            .frame(width: size, height: size)
    }
}

/// Le puits neutre. Un damier de 8 pt : la seule surface honnête pour
/// juger une couleur, parce qu'elle n'en a aucune.
struct DSCanvasWell: View {
    var square: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            let cols = Int(ceil(geo.size.width / square))
            let rows = Int(ceil(geo.size.height / square))
            ZStack {
                DS.Palette.checkerB
                Path { path in
                    for r in 0..<max(rows, 1) {
                        for c in 0..<max(cols, 1) where (r + c).isMultiple(of: 2) {
                            path.addRect(CGRect(x: CGFloat(c) * square, y: CGFloat(r) * square,
                                                width: square, height: square))
                        }
                    }
                }
                .fill(DS.Palette.checkerA)
            }
        }
        .drawingGroup()
        .accessibilityHidden(true)
    }
}

/// Repères de coupe. Ils ne décorent pas : ils délimitent la zone
/// réellement exportée, exactement comme sur une épreuve d'imprimeur.
struct DSCropMarks: View {
    var length: CGFloat = 11
    var inset: CGFloat = 9

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            Path { p in
                // haut gauche
                p.move(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: length, y: 0))
                p.move(to: CGPoint(x: 0, y: 0)); p.addLine(to: CGPoint(x: 0, y: length))
                // haut droit
                p.move(to: CGPoint(x: w, y: 0)); p.addLine(to: CGPoint(x: w - length, y: 0))
                p.move(to: CGPoint(x: w, y: 0)); p.addLine(to: CGPoint(x: w, y: length))
                // bas gauche
                p.move(to: CGPoint(x: 0, y: h)); p.addLine(to: CGPoint(x: length, y: h))
                p.move(to: CGPoint(x: 0, y: h)); p.addLine(to: CGPoint(x: 0, y: h - length))
                // bas droit
                p.move(to: CGPoint(x: w, y: h)); p.addLine(to: CGPoint(x: w - length, y: h))
                p.move(to: CGPoint(x: w, y: h)); p.addLine(to: CGPoint(x: w, y: h - length))
            }
            .stroke(DS.Palette.ink3, lineWidth: 1)
            .opacity(0.55)
        }
        .padding(-inset)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

// MARK: - Utilitaires

extension UIColor {
    fileprivate convenience init(hex: UInt32) {
        self.init(red:   CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue:  CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension DynamicTypeSize {
    var contentSizeCategory: UIContentSizeCategory {
        switch self {
        case .xSmall: .extraSmall
        case .small: .small
        case .medium: .medium
        case .large: .large
        case .xLarge: .extraLarge
        case .xxLarge: .extraExtraLarge
        case .xxxLarge: .extraExtraExtraLarge
        case .accessibility1: .accessibilityMedium
        case .accessibility2: .accessibilityLarge
        case .accessibility3: .accessibilityExtraLarge
        case .accessibility4: .accessibilityExtraExtraLarge
        case .accessibility5: .accessibilityExtraExtraExtraLarge
        @unknown default: .large
        }
    }
}
