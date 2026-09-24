//
//  ExportComposition.swift
//  Bobmockup
//
//  La composition rendue, à l'échelle de l'export comme à l'échelle de
//  l'aperçu. Un seul code de rendu : ce que l'aperçu montre est
//  littéralement ce que le tirage produit.
//

import SwiftUI

// MARK: - Spécification

/// L'état complet d'une composition, indépendant de toute vue.
/// C'est ce que le service de tirage reçoit, et ce que l'aperçu affiche.
struct CompositionSpec {
    var layout: CreationLayout = .single
    var exportSize: ExportSizePreset = .iphone67
    /// Portrait ou paysage : le cadre pivote, et l'appareil avec lui.
    var orientation: FrameOrientation = .portrait

    var backgroundStyle: BackgroundStyle = .gradient
    var solidColor: Color = .white
    var gradientColors: [Color] = GradientPreset.presets[0].colors
    var backgroundImage: UIImage?
    /// Supprime le fond et ne garde que l'appareil, ombre en couche alpha.
    var transparentBackground: Bool = false

    var captionText: String = ""
    /// L'accroche du second écran d'un panorama.
    var captionText2: String = ""
    var captionFontSize: CGFloat = 48
    var captionFontName: String = "System"
    var captionColor: Color = .white
    var captionPadding: CGFloat = 20
    var captionPosition: CaptionPosition = .top

    var deviceType: DeviceType = .iPhone15Pro
    var deviceColor: DeviceColor = .naturalTitanium
    var shadowEnabled: Bool = true
    var shadowRadius: CGFloat = 30
    var scale: CGFloat = 0.8
    var rotation3D: Double = 0
    /// En Duo, chaque appareil pivote dans le plan de l'image, sur son
    /// propre centre, du même angle : la paire s'incline sans se déplacer.
    var pivot: Double = 0
    var deviceXOffset: CGFloat = 0
    var deviceYOffset: CGFloat = 0
    var showStatusBar: Bool = false

    var badges: [MockupBadge] = []
    var badgeScale: CGFloat = 1.0

    /// Toutes les captures du projet. En mode Série, une par écran.
    var screenshots: [UIImage] = []
    /// L'écran rendu pour cette passe.
    var activeScreenshotIndex: Int = 0

    var screenshot: UIImage? {
        guard screenshots.indices.contains(activeScreenshotIndex) else { return screenshots.first }
        return screenshots[activeScreenshotIndex]
    }

    /// En Duo, chaque appareil garde sa capture quel que soit l'écran
    /// sélectionné : l'appareil de premier plan montre la première, celui
    /// d'arrière-plan la seconde. Suivre l'écran actif affichait la même
    /// capture dans les deux dès qu'on sélectionnait la seconde.
    var primaryScreenshot: UIImage? {
        layout == .duo ? screenshots.first : screenshot
    }

    /// La capture du second appareil, en mode Duo.
    var secondaryScreenshot: UIImage? {
        screenshots.count > 1 ? screenshots[1] : screenshots.first
    }

    /// L'accroche d'un écran de panorama.
    func caption(forPanel index: Int) -> String {
        index == 0 ? captionText : captionText2
    }

    // MARK: Géométrie

    /// Le cadre de référence : les grandeurs réglées en pixels sont
    /// exprimées pour lui, dans son orientation.
    static let referenceFrame = CGSize(width: 1290, height: 2796)

    /// La cote d'un écran, orientation comprise.
    var frameSize: CGSize { exportSize.size(for: orientation) }

    var panelCount: Int { layout.panelCount }

    /// Toute la surface composée d'un seul tenant : les écrans d'un
    /// panorama posés côte à côte, sans marge entre eux.
    var canvasSize: CGSize {
        CGSize(width: frameSize.width * CGFloat(panelCount), height: frameSize.height)
    }

    /// Rapport entre ce cadre et le cadre de référence. Corps du texte,
    /// marges, ombre et décalages suivent la cote : le même visuel tiré en
    /// 6,1 pouces ou en iPad garde ses proportions au lieu de ses pixels.
    var frameUnit: CGFloat {
        let short = min(frameSize.width, frameSize.height)
        let long = max(frameSize.width, frameSize.height)
        return min(short / Self.referenceFrame.width, long / Self.referenceFrame.height)
    }

    /// L'appareil est couché : paysage demandé, et appareil qui pivote.
    var deviceIsLandscape: Bool {
        orientation == .landscape && deviceType.rotatesWithOrientation
    }

    /// La cote annoncée : celle d'un écran, précédée du nombre d'écrans
    /// quand le tirage en compte plusieurs.
    var dimensionLabel: String {
        let label = exportSize.dimensionLabel(for: orientation)
        return panelCount > 1 ? "\(panelCount) × \(label)" : label
    }
}

// MARK: - Composition

struct ExportComposition: View {
    let spec: CompositionSpec
    /// Rapport entre la taille de rendu et la taille d'export réelle.
    /// 1 pour un tirage, < 1 pour un aperçu.
    var scaleFactor: CGFloat = 1

    /// Un facteur nul, négatif ou non fini produirait des dimensions de cadre
    /// invalides jusque dans le rendu de l'appareil. On ne le laisse pas passer.
    private var factor: CGFloat {
        guard scaleFactor.isFinite, scaleFactor > 0 else { return 1 }
        return scaleFactor
    }

    /// Un écran, à l'échelle du rendu.
    private var panel: CGSize {
        CGSize(width: spec.frameSize.width * factor,
               height: spec.frameSize.height * factor)
    }

    /// Toute la surface, à l'échelle du rendu.
    private var canvas: CGSize {
        CGSize(width: panel.width * CGFloat(spec.panelCount), height: panel.height)
    }

    /// Un pixel du cadre de référence, à l'échelle du rendu.
    private var unit: CGFloat { factor * spec.frameUnit }

    var body: some View {
        ZStack {
            if !spec.transparentBackground { background }

            if spec.panelCount > 1 {
                panorama
            } else {
                arrangement(hasCaption: !spec.captionText.isEmpty) {
                    captionLine(spec.captionText)
                } content: {
                    deviceGroup
                }
            }
        }
        .frame(width: canvas.width, height: canvas.height)
        .clipped()
    }

    // MARK: Mise en place

    /// L'accroche au-dessus, au milieu ou au-dessous de l'appareil. Une
    /// seule mise en place pour l'épreuve et pour le panorama : un écran de
    /// panorama se lit exactement comme une épreuve simple.
    private func arrangement<Caption: View, Content: View>(
        hasCaption: Bool,
        @ViewBuilder caption: () -> Caption,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: 30 * unit) {
            if hasCaption && spec.captionPosition == .top {
                caption().padding(.top, 100 * unit)
                Spacer(minLength: 0)
            } else if hasCaption && spec.captionPosition == .center {
                Spacer(minLength: 0)
                caption()
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 0)
            }

            content()

            if hasCaption && spec.captionPosition == .bottom {
                Spacer(minLength: 0)
                caption().padding(.bottom, 100 * unit)
            } else {
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: Panorama

    /// Chaque écran porte son accroche, calée comme dans une épreuve
    /// simple. L'appareil est posé une seule fois sur toute la surface,
    /// centré sur la jointure : une moitié tombe dans chaque écran.
    /// La place d'accroche retient la plus haute des deux, pour que
    /// l'appareil ne recouvre ni l'une ni l'autre.
    private var panorama: some View {
        let captions = (0..<spec.panelCount).map(spec.caption(forPanel:))
        let hasCaption = captions.contains { !$0.isEmpty }

        return ZStack {
            HStack(spacing: 0) {
                ForEach(captions.indices, id: \.self) { index in
                    arrangement(hasCaption: hasCaption) {
                        captionSlot(captions, showing: index)
                    } content: {
                        deviceGroup.hidden()
                    }
                    .frame(width: panel.width, height: panel.height)
                }
            }

            arrangement(hasCaption: hasCaption) {
                captionSlot(captions, showing: nil)
            } content: {
                deviceGroup
            }
            .frame(width: canvas.width, height: canvas.height)
        }
    }

    /// Réserve la hauteur de la plus haute des accroches, et montre
    /// par-dessus celle de l'écran demandé.
    private func captionSlot(_ captions: [String], showing index: Int?) -> some View {
        let alignment: Alignment = switch spec.captionPosition {
        case .top: .top
        case .center: .center
        case .bottom: .bottom
        }
        return ZStack(alignment: alignment) {
            ForEach(captions.indices, id: \.self) { i in
                captionLine(captions[i]).hidden()
            }
            if let index, !captions[index].isEmpty {
                captionLine(captions[index])
            }
        }
        .frame(width: panel.width)
    }

    // MARK: Appareils

    private var deviceGroup: some View {
        ZStack {
            devices
            if !spec.badges.isEmpty {
                BadgeOverlayView(badges: spec.badges,
                                 scaleFactor: unit,
                                 badgeScale: spec.badgeScale)
                    .frame(width: badgeBox.width, height: badgeBox.height)
            }
        }
        .offset(x: spec.deviceXOffset * unit, y: spec.deviceYOffset * unit)
    }

    /// La boîte où se posent les pastilles, dans l'orientation du cadre.
    private var badgeBox: CGSize {
        panel.width <= panel.height
            ? CGSize(width: panel.width * 0.8, height: panel.height * 0.5)
            : CGSize(width: panel.width * 0.5, height: panel.height * 0.8)
    }

    @ViewBuilder
    private var devices: some View {
        switch spec.layout {
        case .duo:
            // Le pivot vient après la rotation 3D : l'appareil tourne d'abord
            // sur son axe vertical, puis s'incline sur son centre. Pivoter
            // chaque appareil plutôt que la paire les garde à leur place.
            HStack(spacing: -panel.width * 0.10) {
                device(screenshot: spec.secondaryScreenshot, scale: spec.scale * 0.78)
                    .rotation3DEffect(.degrees(spec.rotation3D + 8), axis: (x: 0, y: 1, z: 0))
                    .rotationEffect(.degrees(spec.pivot))
                    .zIndex(0)
                device(screenshot: spec.primaryScreenshot, scale: spec.scale)
                    .rotationEffect(.degrees(spec.pivot))
                    .zIndex(1)
            }
        default:
            device(screenshot: spec.screenshot, scale: spec.scale)
        }
    }

    private func device(screenshot: UIImage?, scale: CGFloat) -> some View {
        let upright = deviceUprightWidth
        return DeviceFrameView(
            deviceType: spec.deviceType,
            screenshot: screenshot,
            shadowEnabled: spec.shadowEnabled,
            shadowRadius: spec.shadowRadius * unit * 2,
            rotation3D: spec.rotation3D,
            deviceColor: spec.deviceColor,
            showStatusBar: spec.showStatusBar,
            isLandscape: spec.deviceIsLandscape,
            baseWidth: upright,
            frameThickness: upright * 15 / 630
        )
        .scaleEffect(max(0.1, scale))
    }

    /// Part de l'écran qu'occupe l'appareil à l'échelle 100 % : 630 pixels
    /// sur 1290, la mesure historique du cadre 6,7 pouces.
    private static let footprint: CGFloat = 630 / 1290

    /// La largeur de l'appareil d'aplomb, avant l'échelle. L'appareil tient
    /// dans une boîte proportionnelle à l'écran : il suit la cote au lieu
    /// de garder 630 pixels partout — ce qui le faisait déborder d'une
    /// bande 16:9 et le réduisait à un timbre dans un cadre iPad.
    private var deviceUprightWidth: CGFloat {
        let box = CGSize(width: panel.width * Self.footprint,
                         height: panel.height * Self.footprint)
        let upright = spec.deviceType.aspectRatio
        let shown = spec.deviceIsLandscape ? 1 / upright : upright
        let shownWidth = min(box.width, box.height / shown)
        return spec.deviceIsLandscape ? shownWidth * shown : shownWidth
    }

    // MARK: Texte

    private func captionLine(_ text: String) -> some View {
        Text(text)
            .font(spec.captionFontName == "System"
                  ? .system(size: spec.captionFontSize * unit, weight: .black).width(.expanded)
                  : .custom(spec.captionFontName, fixedSize: spec.captionFontSize * unit).weight(.bold))
            .foregroundColor(spec.captionColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, spec.captionPadding * unit * 3)
    }

    // MARK: Fond

    /// Le fond couvre toute la surface d'un seul tenant : d'un écran de
    /// panorama à l'autre, le dégradé ou l'image se poursuit sans raccord.
    @ViewBuilder
    private var background: some View {
        switch spec.backgroundStyle {
        case .solid:
            spec.solidColor
        case .gradient, .mesh:
            LinearGradient(colors: spec.gradientColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        case .image:
            if let image = spec.backgroundImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: canvas.width, height: canvas.height)
                    .clipped()
            } else {
                spec.gradientColors.first ?? Color.gray
            }
        }
    }
}
