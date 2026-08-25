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

    var backgroundStyle: BackgroundStyle = .gradient
    var solidColor: Color = .white
    var gradientColors: [Color] = GradientPreset.presets[0].colors
    var backgroundImage: UIImage?
    /// Supprime le fond et ne garde que l'appareil, ombre en couche alpha.
    var transparentBackground: Bool = false

    var captionText: String = ""
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

    /// La capture du second appareil, en mode Duo.
    var secondaryScreenshot: UIImage? {
        screenshots.count > 1 ? screenshots[1] : screenshots.first
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

    private var size: CGSize {
        CGSize(width: spec.exportSize.size.width * factor,
               height: spec.exportSize.size.height * factor)
    }

    var body: some View {
        ZStack {
            if !spec.transparentBackground { background }

            VStack(spacing: 30 * factor) {
                if hasCaption && spec.captionPosition == .top {
                    caption.padding(.top, 100 * factor)
                    Spacer(minLength: 0)
                } else if hasCaption && spec.captionPosition == .center {
                    Spacer(minLength: 0)
                    caption
                    Spacer(minLength: 0)
                } else {
                    Spacer(minLength: 0)
                }

                ZStack {
                    devices
                    if !spec.badges.isEmpty {
                        BadgeOverlayView(badges: spec.badges,
                                         scaleFactor: factor,
                                         badgeScale: spec.badgeScale)
                            .frame(width: size.width * 0.8, height: size.height * 0.5)
                    }
                }
                .offset(y: spec.deviceYOffset * factor)

                if hasCaption && spec.captionPosition == .bottom {
                    Spacer(minLength: 0)
                    caption.padding(.bottom, 100 * factor)
                } else {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    private var hasCaption: Bool { !spec.captionText.isEmpty }

    // MARK: Appareils

    @ViewBuilder
    private var devices: some View {
        switch spec.layout {
        case .duo:
            HStack(spacing: -size.width * 0.10) {
                device(screenshot: spec.secondaryScreenshot, scale: spec.scale * 0.78)
                    .rotation3DEffect(.degrees(spec.rotation3D + 8), axis: (x: 0, y: 1, z: 0))
                    .zIndex(0)
                device(screenshot: spec.screenshot, scale: spec.scale)
                    .zIndex(1)
            }
        default:
            device(screenshot: spec.screenshot, scale: spec.scale)
        }
    }

    private func device(screenshot: UIImage?, scale: CGFloat) -> some View {
        DeviceFrameView(
            deviceType: spec.deviceType,
            screenshot: screenshot,
            shadowEnabled: spec.shadowEnabled,
            shadowRadius: spec.shadowRadius * factor * 2,
            rotation3D: spec.rotation3D,
            deviceColor: spec.deviceColor,
            showStatusBar: spec.showStatusBar,
            baseWidth: 630 * factor,
            frameThickness: 15 * factor
        )
        .scaleEffect(max(0.1, scale))
    }

    // MARK: Texte

    private var caption: some View {
        Text(spec.captionText)
            .font(spec.captionFontName == "System"
                  ? .system(size: spec.captionFontSize * factor, weight: .black).width(.expanded)
                  : .custom(spec.captionFontName, fixedSize: spec.captionFontSize * factor).weight(.bold))
            .foregroundColor(spec.captionColor)
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, spec.captionPadding * factor * 3)
    }

    // MARK: Fond

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
                    .frame(width: size.width, height: size.height)
                    .clipped()
            } else {
                spec.gradientColors.first ?? Color.gray
            }
        }
    }
}
