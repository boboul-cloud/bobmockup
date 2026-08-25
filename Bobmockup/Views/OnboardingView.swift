//
//  OnboardingView.swift
//  Bobmockup
//
//  Quatre pages. La numérotation est portée par le contenu — c'est une
//  vraie séquence — et l'illustration est un diagramme monoline, pas une
//  pastille de dégradé.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            art: .frame,
            title: "Un atelier, pas un filtre",
            body: "Bobmockup tire vos captures comme un labo tire une photo : cadre exact, fond maîtrisé, cotes affichées. Ce que vous voyez est ce qui sort."),
        OnboardingPage(
            art: .capture,
            title: "Votre capture, à la bonne place",
            body: "Photothèque ou Fichiers. L'image se cale au pixel dans l'écran de l'appareil, encoche et coins arrondis compris."),
        OnboardingPage(
            art: .controls,
            title: "Des courses, pas des curseurs",
            body: "Ombre, rotation, échelle : chaque réglage a un cran de rappel. Un retour franc sous le doigt marque le retour au neutre."),
        OnboardingPage(
            art: .modes,
            title: "Six façons de tirer",
            body: "Un écran, une série App Store complète, un lot de toutes les tailles, un PNG détouré, un PDF vectoriel. Le tirage s'adapte au dépôt.")
    ]

    private var isLast: Bool { page == pages.count - 1 }

    var body: some View {
        VStack(spacing: DS.Space.x6) {
            OnboardingArt(kind: pages[page].art)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(DS.Palette.ink3)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DS.Space.x3) {
                Text("Étape \(String(format: "%02d", page + 1)) — \(String(format: "%02d", pages.count))")
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)

                Text(pages[page].title)
                    .dsDisplayL()
                    .foregroundStyle(DS.Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text(pages[page].body)
                    .dsBody()
                    .foregroundStyle(DS.Palette.ink2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Une barre de progression segmentée, pas des points :
            // elle dit où l'on en est, pas seulement combien il en reste.
            HStack(spacing: DS.Space.x1) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(index <= page ? DS.Palette.safelight : DS.Palette.lineStrong)
                        .frame(height: 2)
                }
            }
            .accessibilityElement()
            .accessibilityLabel("Page \(page + 1) sur \(pages.count)")

            HStack(spacing: DS.Space.x2) {
                if !isLast {
                    Button("Passer") { complete() }
                        .buttonStyle(DSGhostButton())
                        .accessibilityHint("Termine la présentation et ouvre l'atelier")
                }

                Button {
                    DS.Haptics.light()
                    if isLast { complete() }
                    else {
                        withAnimation(DS.Motion.respectful(DS.Motion.surface, reduceMotion: reduceMotion)) {
                            page += 1
                        }
                    }
                } label: {
                    HStack(spacing: DS.Space.x2) {
                        Text(isLast ? "Entrer dans l'atelier" : "Suivant")
                        DSIcon(name: "arrow.right", size: 16)
                    }
                }
                .buttonStyle(DSPillButton(expands: true))
            }
        }
        .padding(.horizontal, DS.Space.screen)
        .padding(.bottom, DS.Space.x5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Palette.base.ignoresSafeArea())
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 24)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    withAnimation(DS.Motion.respectful(DS.Motion.surface, reduceMotion: reduceMotion)) {
                        if value.translation.width < 0, page < pages.count - 1 { page += 1 }
                        if value.translation.width > 0, page > 0 { page -= 1 }
                    }
                }
        )
    }

    private func complete() {
        DS.Haptics.light()
        hasCompletedOnboarding = true
    }
}

struct OnboardingPage {
    enum Art { case frame, capture, controls, modes }
    let art: Art
    let title: LocalizedStringKey
    let body: LocalizedStringKey
}

/// Diagrammes monoline. Un seul style de trait dans toute l'application.
struct OnboardingArt: View {
    let kind: OnboardingPage.Art

    var body: some View {
        Canvas { context, size in
            let shading = GraphicsContext.Shading.color(.primary)
            var path = Path()
            let w = size.width, h = size.height
            let s = min(w, h)

            switch kind {
            case .frame:
                let fw = s * 0.30, fh = s * 0.72
                let frame = CGRect(x: (w - fw) / 2, y: (h - fh) / 2, width: fw, height: fh)
                path.addRoundedRect(in: frame, cornerSize: CGSize(width: 9, height: 9))
                path.addRoundedRect(in: frame.insetBy(dx: fw * 0.18, dy: fh * 0.20),
                                    cornerSize: CGSize(width: 3, height: 3))
                // repères de coupe : la promesse du cadre exact
                let m = frame.insetBy(dx: -s * 0.18, dy: -s * 0.06)
                let t = s * 0.07
                for corner in [(m.minX, m.minY, 1.0, 1.0), (m.maxX, m.minY, -1.0, 1.0),
                               (m.minX, m.maxY, 1.0, -1.0), (m.maxX, m.maxY, -1.0, -1.0)] {
                    path.move(to: CGPoint(x: corner.0, y: corner.1))
                    path.addLine(to: CGPoint(x: corner.0 + t * corner.2, y: corner.1))
                    path.move(to: CGPoint(x: corner.0, y: corner.1))
                    path.addLine(to: CGPoint(x: corner.0, y: corner.1 + t * corner.3))
                }

            case .capture:
                let iw = s * 0.52, ih = s * 0.38
                let img = CGRect(x: w / 2 - iw * 0.92, y: h / 2 - ih * 0.95, width: iw, height: ih)
                path.addRoundedRect(in: img, cornerSize: CGSize(width: 5, height: 5))
                path.move(to: CGPoint(x: img.minX + 4, y: img.maxY - ih * 0.22))
                path.addLine(to: CGPoint(x: img.minX + iw * 0.34, y: img.maxY - ih * 0.55))
                path.addLine(to: CGPoint(x: img.maxX - 6, y: img.maxY - 4))
                path.addEllipse(in: CGRect(x: img.minX + iw * 0.16, y: img.minY + ih * 0.16,
                                           width: 9, height: 9))
                let dw = s * 0.30, dh = s * 0.54
                path.addRoundedRect(in: CGRect(x: w / 2 + s * 0.04, y: h / 2 - dh * 0.34,
                                               width: dw, height: dh),
                                    cornerSize: CGSize(width: 8, height: 8))

            case .controls:
                for i in 0..<3 {
                    let y = h / 2 + CGFloat(i - 1) * s * 0.20
                    path.move(to: CGPoint(x: w * 0.14, y: y))
                    path.addLine(to: CGPoint(x: w * 0.86, y: y))
                    let knobX = w * (i == 0 ? 0.48 : i == 1 ? 0.68 : 0.36)
                    path.addEllipse(in: CGRect(x: knobX - 9, y: y - 9, width: 18, height: 18))
                    // le cran de rappel
                    path.move(to: CGPoint(x: w * 0.5, y: y - s * 0.045))
                    path.addLine(to: CGPoint(x: w * 0.5, y: y - s * 0.02))
                }

            case .modes:
                let fw = s * 0.13, fh = s * 0.30, gap = s * 0.05
                let total = fw * 4 + gap * 3
                for i in 0..<4 {
                    path.addRoundedRect(in: CGRect(x: (w - total) / 2 + CGFloat(i) * (fw + gap),
                                                   y: h / 2 - s * 0.34, width: fw, height: fh),
                                        cornerSize: CGSize(width: 3, height: 3))
                }
                path.move(to: CGPoint(x: w / 2, y: h / 2 + s * 0.02))
                path.addLine(to: CGPoint(x: w / 2, y: h / 2 + s * 0.22))
                path.move(to: CGPoint(x: w / 2 - s * 0.06, y: h / 2 + s * 0.15))
                path.addLine(to: CGPoint(x: w / 2, y: h / 2 + s * 0.22))
                path.addLine(to: CGPoint(x: w / 2 + s * 0.06, y: h / 2 + s * 0.15))
                path.addRoundedRect(in: CGRect(x: w / 2 - s * 0.22, y: h / 2 + s * 0.26,
                                               width: s * 0.44, height: s * 0.10),
                                    cornerSize: CGSize(width: 3, height: 3))
            }

            context.stroke(path, with: shading,
                           style: StrokeStyle(lineWidth: 1.4, lineCap: .round, lineJoin: .round))
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
