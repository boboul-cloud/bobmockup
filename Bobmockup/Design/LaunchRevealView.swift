//
//  LaunchRevealView.swift
//  Bobmockup
//
//  « La révélation » — l'image latente qui remonte dans le bain.
//  1 080 ms au total. Jamais bloquante : l'accueil est monté derrière dès
//  la première image, cette vue n'est qu'un calque. Sautable d'un toucher.
//  Rejouée une seule fois par lancement à froid.
//

import SwiftUI

struct LaunchRevealView: View {
    @Binding var isFinished: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var haloOpacity: Double = 0
    @State private var markOpacity: Double = 0
    @State private var tracking: CGFloat = 9
    @State private var ruleWidth: CGFloat = 0
    @State private var markScale: CGFloat = 1

    private let wordmark = "BOBMOCKUP"
    private let ruleFullWidth: CGFloat = 190

    var body: some View {
        ZStack {
            DS.Palette.well
                .ignoresSafeArea()

            RadialGradient(colors: [DS.Palette.safelight.opacity(0.30), .clear],
                           center: UnitPoint(x: 0.5, y: 0.22),
                           startRadius: 0, endRadius: 420)
                .opacity(haloOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: DS.Space.x3) {
                Text(wordmark)
                    .font(.system(size: 26, weight: .black).width(.expanded))
                    .tracking(tracking)
                    // La chasse se resserre : c'est là qu'est la révélation,
                    // pas dans un fondu.
                    .padding(.leading, tracking)
                    .foregroundStyle(DS.Palette.ink)

                Rectangle()
                    .fill(DS.Palette.safelight)
                    .frame(width: ruleWidth, height: 1)
            }
            .opacity(markOpacity)
            .scaleEffect(markScale)

            VStack {
                Spacer()
                Text("Touchez pour passer")
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)
                    .padding(.bottom, DS.Space.x9)
            }
            .opacity(markOpacity * 0.8)
        }
        .contentShape(Rectangle())
        .onTapGesture { skip() }
        .accessibilityElement()
        .accessibilityLabel("Bobmockup")
        .accessibilityHint("Touchez pour passer l'animation d'ouverture")
        .accessibilityAddTraits(.isButton)
        .task { await play() }
    }

    private func play() async {
        guard !reduceMotion else {
            withAnimation(.easeOut(duration: 0.20)) { markOpacity = 1; ruleWidth = ruleFullWidth; tracking = 0.5 }
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.easeIn(duration: 0.20)) { isFinished = true }
            return
        }

        // 60 → 380 ms : le safelight s'allume.
        try? await Task.sleep(for: .milliseconds(60))
        withAnimation(.easeOut(duration: 0.32)) { haloOpacity = 1 }

        // 180 → 620 ms : le mot-marque remonte, sa chasse se resserre.
        try? await Task.sleep(for: .milliseconds(120))
        withAnimation(.easeOut(duration: 0.44)) { markOpacity = 1; tracking = 0.5 }

        // 420 → 900 ms : le filet se trace.
        try? await Task.sleep(for: .milliseconds(240))
        withAnimation(.easeInOut(duration: 0.48)) { ruleWidth = ruleFullWidth }

        // 700 → 920 ms : la lampe refroidit, plus lentement qu'elle ne s'est allumée.
        try? await Task.sleep(for: .milliseconds(280))
        withAnimation(.easeIn(duration: 0.22)) { haloOpacity = 0 }

        // 820 → 1 080 ms : le mot s'efface, l'accueil est déjà là.
        try? await Task.sleep(for: .milliseconds(120))
        guard !isFinished else { return }
        withAnimation(.easeIn(duration: 0.26)) { markOpacity = 0; markScale = 0.94 }
        try? await Task.sleep(for: .milliseconds(260))
        isFinished = true
    }

    private func skip() {
        guard !isFinished else { return }
        withAnimation(.easeIn(duration: 0.18)) {
            markOpacity = 0
            haloOpacity = 0
        }
        isFinished = true
    }
}

#Preview {
    LaunchRevealView(isFinished: .constant(false))
}
