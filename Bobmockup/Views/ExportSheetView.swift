//
//  ExportSheetView.swift
//  Bobmockup
//
//  Le tirage. Six modes visibles d'un coup — un mode réservé à Premium
//  n'est pas caché, il est désigné comme tel. La progression est réelle,
//  pas une animation qui fait patienter.
//

import SwiftUI

struct ExportSheetView: View {
    @Bindable var vm: MockupEditorViewModel
    let purchaseManager: PurchaseManager
    let store: ProjectStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.flexible(), spacing: DS.Space.x2),
                           GridItem(.flexible(), spacing: DS.Space.x2)]

    var body: some View {
        ZStack {
            DS.Palette.base.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Space.x7) {
                        proof

                        destinationSection

                        VStack(alignment: .leading, spacing: DS.Space.x3) {
                            DSSectionLabel(text: "Mode de tirage")
                            LazyVGrid(columns: columns, spacing: DS.Space.x2) {
                                ForEach(ExportMode.allCases) { mode in
                                    ExportModeTile(
                                        mode: mode,
                                        isSelected: vm.exportMode == mode,
                                        isLocked: vm.isModeLocked(mode, purchaseManager: purchaseManager)
                                    ) {
                                        withAnimation(DS.Motion.select) { vm.exportMode = mode }
                                        DS.Haptics.light()
                                    }
                                }
                            }
                        }

                        DSNote(text: vm.exportMode.note)
                    }
                    .padding(.horizontal, DS.Space.screen)
                    .padding(.bottom, DS.Space.x6)
                }

                footer
            }

            if vm.exportPhase != .idle {
                RevealOverlay(vm: vm, store: store, onClose: { dismiss() })
                    .transition(.opacity)
                    .zIndex(5)
            }
        }
        .animation(DS.Motion.surface, value: vm.exportPhase)
        .tint(DS.Palette.safelight)
    }

    // MARK: - En-tête

    private var header: some View {
        HStack {
            Button { dismiss() } label: { DSIcon(name: "xmark", size: 18) }
                .dsHitTarget()
                .foregroundStyle(DS.Palette.ink2)
                .accessibilityLabel("Fermer")

            Spacer()
            VStack(spacing: 1) {
                Text("Tirage")
                    .dsBodyStrong()
                    .foregroundStyle(DS.Palette.ink)
                Text(vm.exportSizePreset.dimensionLabel)
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)
            }
            Spacer()
            Color.clear.frame(width: DS.hit, height: DS.hit)
        }
        .padding(.horizontal, DS.Space.x4)
        .padding(.top, DS.Space.x3)
        .padding(.bottom, DS.Space.x4)
        .overlay(alignment: .bottom) {
            Rectangle().fill(DS.Palette.line).frame(height: 1)
        }
    }

    // MARK: - Épreuve

    /// L'épreuve n'est qu'un rappel : le grand aperçu est dans l'éditeur.
    /// On la plafonne en hauteur pour que le choix de destination reste
    /// visible sans faire défiler.
    private var proof: some View {
        HStack {
            Spacer()
            let maxHeight: CGFloat = 190
            let size = vm.exportSizePreset.size
            let width = min(240, maxHeight * size.width / size.height)
            let factor = width / size.width
            ExportComposition(spec: vm.composition, scaleFactor: factor)
                .overlay(Rectangle().stroke(Color.black.opacity(0.35), lineWidth: 1))
                .overlay(DSCropMarks())
                .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
            Spacer()
        }
        .padding(.top, DS.Space.x5)
        .accessibilityLabel("Aperçu du tirage")
    }

    // MARK: - Destination

    /// Le choix vaut pour toutes les productions. Deux exceptions tenues
    /// par la plateforme : le presse-papiers n'enregistre rien, et la
    /// photothèque iOS n'accepte pas un PDF.
    @ViewBuilder
    private var destinationSection: some View {
        let allowed = vm.exportMode.destinations

        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Destination")

            if allowed.isEmpty {
                HStack(spacing: DS.Space.x3) {
                    DSIcon(name: "doc.on.doc", size: 20)
                        .foregroundStyle(DS.Palette.ink3)
                    Text("Rien n'est enregistré : le tirage part dans le presse-papiers.")
                        .dsCaption()
                        .foregroundStyle(DS.Palette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, DS.Space.x4)
                .frame(minHeight: 56)
                .dsCard()
            } else {
                HStack(spacing: DS.Space.x2) {
                    ForEach(ExportDestination.allCases) { destination in
                        DestinationTile(
                            destination: destination,
                            isSelected: vm.exportDestination == destination,
                            isAvailable: allowed.contains(destination)
                        ) {
                            guard allowed.contains(destination) else { return }
                            withAnimation(DS.Motion.select) { vm.exportDestination = destination }
                            DS.Haptics.light()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Pied

    private var footer: some View {
        HStack(spacing: DS.Space.x3) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Coût")
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)
                Text(costLabel)
                    .dsNumeric()
                    .foregroundStyle(DS.Palette.ink2)
            }
            Spacer()
            Button {
                Task { await vm.runExport(purchaseManager: purchaseManager) }
            } label: {
                HStack(spacing: DS.Space.x2) {
                    DSIcon(name: "square.and.arrow.up", size: 16)
                    Text(isLocked ? "Débloquer" : "Tirer")
                }
            }
            .buttonStyle(DSPillButton())
            .disabled(vm.isExporting)
        }
        .padding(.horizontal, DS.Space.x4)
        .padding(.vertical, DS.Space.x3)
        .dsChassisBar()
    }

    private var isLocked: Bool { vm.isModeLocked(vm.exportMode, purchaseManager: purchaseManager) }

    private var costLabel: String {
        if isLocked { return "Réservé à l'atelier illimité" }
        let files = vm.exportMode.fileCount(for: vm.layout)
        if purchaseManager.isPremium {
            return files > 1 ? "\(files) fichiers · illimité" : "Illimité"
        }
        let remaining = purchaseManager.remainingFreeConversions
        return files > 1
            ? "\(files) fichiers · 1 tirage sur \(remaining)"
            : "1 tirage sur \(remaining) restants"
    }
}

// MARK: - Tuile de mode

private struct ExportModeTile: View {
    let mode: ExportMode
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DS.Space.x2) {
                HStack {
                    DSIcon(name: mode.icon, size: 20)
                    Spacer()
                    if isLocked {
                        DSIcon(name: "lock", size: 13)
                            .foregroundStyle(DS.Palette.paper)
                    }
                }
                Spacer(minLength: 0)
                Text(mode.localizedName)
                    .dsBodyStrong()
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(mode.detail)
                    .dsLabel()
                    .foregroundStyle(isSelected ? DS.Palette.safelight : DS.Palette.ink3)
            }
            .foregroundStyle(isSelected ? DS.Palette.safelight : DS.Palette.ink)
            .padding(DS.Space.x3)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
            .background(isSelected ? DS.Palette.safelightWash : DS.Palette.raised,
                        in: RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                    .stroke(isSelected ? DS.Palette.safelight : DS.Palette.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.rawValue)
        .accessibilityHint(isLocked ? "Réservé à l'atelier illimité" : "")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Tuile de destination

private struct DestinationTile: View {
    let destination: ExportDestination
    let isSelected: Bool
    let isAvailable: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DS.Space.x2) {
                DSIcon(name: destination.icon, size: 18)
                Text(destination.localizedName)
                    .dsBodyStrong()
                Spacer(minLength: 0)
                if isSelected {
                    DSIcon(name: "checkmark", size: 14)
                }
            }
            .foregroundStyle(isSelected ? DS.Palette.safelight
                             : (isAvailable ? DS.Palette.ink : DS.Palette.ink3))
            .padding(.horizontal, DS.Space.x3)
            .frame(maxWidth: .infinity, minHeight: DS.hit)
            .background(isSelected ? DS.Palette.safelightWash : DS.Palette.raised,
                        in: RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                    .stroke(isSelected ? DS.Palette.safelight : DS.Palette.line, lineWidth: 1)
            )
            .opacity(isAvailable ? 1 : 0.45)
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .accessibilityLabel(destination.rawValue)
        .accessibilityHint(isAvailable ? "" : "Indisponible pour ce mode de tirage")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Révélation du tirage

/// Le tirage en cours, puis la réussite. Le flash papier est le seul
/// moment où l'application s'éclaire : c'est l'épreuve qui sort du bac.
private struct RevealOverlay: View {
    @Bindable var vm: MockupEditorViewModel
    let store: ProjectStore
    let onClose: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var flash: Double = 0

    var body: some View {
        ZStack {
            DS.Palette.base.ignoresSafeArea()
            DS.Palette.paper.opacity(flash).ignoresSafeArea().allowsHitTesting(false)

            VStack(spacing: DS.Space.x5) {
                switch vm.exportPhase {
                case .running(let value):
                    Text("Tirage en cours")
                        .dsLabel()
                        .foregroundStyle(DS.Palette.ink3)
                    Text("\(Int(value * 100)) %")
                        .dsDisplayXL()
                        .foregroundStyle(DS.Palette.ink)
                    ProgressView(value: value)
                        .tint(DS.Palette.safelight)
                        .frame(maxWidth: 220)

                case .done(let summary):
                    DSIcon(name: "checkmark", size: 28)
                        .foregroundStyle(DS.Palette.paper)
                    Text(summary.title)
                        .dsDisplayL()
                        .foregroundStyle(DS.Palette.ink)
                        .multilineTextAlignment(.center)
                    Text(summary.detail)
                        .dsCaption()
                        .foregroundStyle(DS.Palette.ink2)
                        .multilineTextAlignment(.center)

                    VStack(spacing: DS.Space.x2) {
                        Button("Nouvelle épreuve") {
                            vm.startNewProof(store: store)
                            onClose()
                        }
                        .buttonStyle(DSPillButton(expands: true))

                        Button("Revenir à l'éditeur") { vm.dismissExport(); onClose() }
                            .dsCaption()
                            .foregroundStyle(DS.Palette.safelight)
                            .frame(minHeight: DS.hit)
                    }
                    .padding(.top, DS.Space.x2)

                case .failed(let message):
                    DSIcon(name: "exclamationmark.triangle", size: 26)
                        .foregroundStyle(DS.Palette.safelight)
                    Text("Le tirage a échoué")
                        .dsDisplayM()
                        .foregroundStyle(DS.Palette.ink)
                    Text(message)
                        .dsCaption()
                        .foregroundStyle(DS.Palette.ink2)
                        .multilineTextAlignment(.center)
                    Button("Revenir aux réglages") { vm.exportPhase = .idle }
                        .buttonStyle(DSGhostButton())

                case .idle:
                    EmptyView()
                }
            }
            .padding(.horizontal, DS.Space.x7)
        }
        .onChange(of: vm.exportPhase) { _, phase in
            guard case .done = phase, !reduceMotion else { return }
            flash = 0.55
            withAnimation(.easeIn(duration: 0.35)) { flash = 0 }
        }
    }
}
