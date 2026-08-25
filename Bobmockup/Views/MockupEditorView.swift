//
//  MockupEditorView.swift
//  Bobmockup
//
//  L'éditeur. Le canevas est un puits neutre : l'interface ne prend jamais
//  la couleur du visuel, sinon on ne peut plus juger cette couleur.
//  La barre d'action porte une seule action pleine, l'irréversible.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct MockupEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var purchaseManager = PurchaseManager.shared
    @State private var store = ProjectStore.shared
    @State private var vm = MockupEditorViewModel()

    /// Projet à rouvrir, ou disposition à créer.
    var project: MockupProject?
    var layout: CreationLayout = .single

    @State private var didLoad = false
    @State private var undoFlash = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                canvas
                filmstrip
                actionBar
            }
            .background(DS.Palette.base.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .toolbarBackground(DS.Palette.base, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(DS.Palette.safelight)
        .onAppear { load() }
        .onDisappear { vm.saveNow() }
        .modifier(EditorSheets(vm: vm, purchaseManager: purchaseManager, store: store))
    }

    private func load() {
        guard !didLoad else { return }
        didLoad = true
        if let project { vm.open(project, store: store) }
        else { vm.start(layout: layout, store: store) }
    }

    // MARK: - Barre de navigation

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                vm.saveNow()
                dismiss()
            } label: {
                DSIcon(name: "xmark", size: 18)
                    .foregroundStyle(DS.Palette.ink2)
            }
            .buttonStyle(.plain)
            .dsHitTarget()
            .accessibilityLabel("Fermer l'éditeur")
            .accessibilityHint("Enregistre le projet et revient à l'atelier")
        }

        ToolbarItem(placement: .principal) {
            VStack(spacing: 1) {
                Text(vm.projectName)
                    .dsBodyStrong()
                    .foregroundStyle(DS.Palette.ink)
                Text(vm.exportSizePreset.dimensionLabel)
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)
            }
            .accessibilityElement(children: .combine)
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            Button { performUndo() } label: {
                DSIcon(name: "arrow.uturn.backward", size: 18)
                    .foregroundStyle(vm.canUndo ? DS.Palette.ink2 : DS.Palette.ink3.opacity(0.5))
            }
            .buttonStyle(.plain)
            .disabled(!vm.canUndo)
            .accessibilityLabel("Annuler")

            Button { performRedo() } label: {
                DSIcon(name: "arrow.uturn.forward", size: 18)
                    .foregroundStyle(vm.canRedo ? DS.Palette.ink2 : DS.Palette.ink3.opacity(0.5))
            }
            .buttonStyle(.plain)
            .disabled(!vm.canRedo)
            .accessibilityLabel("Rétablir")
        }
    }

    private func performUndo() {
        vm.undo()
        flashCanvas()
    }

    private func performRedo() {
        vm.redo()
        flashCanvas()
    }

    /// L'utilisateur regarde son visuel, pas l'interface : annuler fait
    /// clignoter le filet du canevas plutôt que d'animer le contenu.
    private func flashCanvas() {
        withAnimation(DS.Motion.lightOn) { undoFlash = true }
        Task {
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(DS.Motion.lightOff) { undoFlash = false }
        }
    }

    // MARK: - Canevas

    private var canvas: some View {
        GeometryReader { geo in
            // La première passe de layout peut donner une géométrie nulle :
            // sans plancher à zéro, la place disponible devient négative et
            // l'appareil se retrouve avec une largeur négative.
            let available = CGSize(width: max(0, geo.size.width - DS.Space.x5 * 2),
                                   height: max(0, geo.size.height - DS.Space.x5 * 2 - 24))
            let ratio = vm.exportSizePreset.size.width / vm.exportSizePreset.size.height
            let width = min(available.width, available.height * ratio)
            let factor = width / vm.exportSizePreset.size.width

            ZStack {
                DSCanvasWell()
                    .ignoresSafeArea(edges: .horizontal)

                if factor > 0 {
                    VStack(spacing: DS.Space.x3) {
                        ExportComposition(spec: vm.composition, scaleFactor: factor)
                            .overlay(
                                Rectangle()
                                    .stroke(undoFlash ? DS.Palette.safelight : Color.black.opacity(0.35),
                                            lineWidth: undoFlash ? 2 : 1)
                            )
                            .shadow(color: .black.opacity(0.45), radius: 18, y: 10)
                            .overlay(DSCropMarks())

                        Text("Zone d'export \(vm.exportSizePreset.dimensionLabel)")
                            .dsLabel()
                            .foregroundStyle(DS.Palette.ink3)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                DS.Haptics.light()
                vm.showCaptureSourceMenu = true
            }
            .accessibilityElement()
            .accessibilityLabel(vm.screenshots.isEmpty ? "Canevas vide" : "Aperçu du tirage")
            .accessibilityHint("Touchez pour ajouter ou remplacer une capture")
            .accessibilityAddTraits(.isButton)
        }
    }

    // MARK: - Bande de captures (mode Série et Duo)

    @ViewBuilder
    private var filmstrip: some View {
        if vm.maxScreenshots > 1 {
            VStack(alignment: .leading, spacing: DS.Space.x2) {
                HStack {
                    Text("Écrans")
                        .dsLabel()
                        .foregroundStyle(DS.Palette.ink3)
                    Spacer()
                    Text("\(vm.screenshots.count) sur \(vm.maxScreenshots)")
                        .dsNumeric()
                        .foregroundStyle(DS.Palette.ink3)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Space.x2) {
                        ForEach(Array(vm.screenshots.enumerated()), id: \.offset) { index, image in
                            FilmstripCell(image: image,
                                          index: index,
                                          isActive: index == vm.activeScreenshot,
                                          onSelect: {
                                              withAnimation(DS.Motion.select) { vm.activeScreenshot = index }
                                              DS.Haptics.light()
                                          },
                                          onRemove: { vm.removeScreenshot(at: index) })
                        }

                        if vm.canAddScreenshot {
                            Button {
                                DS.Haptics.light()
                                vm.showCaptureSourceMenu = true
                            } label: {
                                DSIcon(name: "plus", size: 18)
                                    .foregroundStyle(DS.Palette.ink2)
                                    .frame(width: 44, height: 64)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DS.Radius.control)
                                            .stroke(DS.Palette.lineStrong, style: StrokeStyle(lineWidth: 1, dash: [3, 3]))
                                    )
                            }
                            .accessibilityLabel("Ajouter un écran")
                        }
                    }
                    .padding(.horizontal, DS.Space.screen)
                }
                .padding(.horizontal, -DS.Space.screen)
            }
            .padding(.horizontal, DS.Space.screen)
            .padding(.vertical, DS.Space.x3)
            .background(DS.Palette.base)
        }
    }

    // MARK: - Barre d'action

    private var actionBar: some View {
        HStack(spacing: DS.Space.x2) {
            Button {
                DS.Haptics.light()
                vm.showCaptureSourceMenu = true
            } label: {
                Label {
                    Text("Capture")
                } icon: {
                    DSIcon(name: "photo", size: 18)
                }
                .labelStyle(ActionBarLabelStyle())
            }
            .buttonStyle(DSQuietButton())
            .accessibilityHint("Ajoute ou remplace la capture affichée dans l'appareil")

            Button {
                DS.Haptics.light()
                vm.showControlPanel = true
            } label: {
                Label {
                    Text("Réglages")
                } icon: {
                    DSIcon(name: "slider.horizontal.3", size: 18)
                }
                .labelStyle(ActionBarLabelStyle())
            }
            .buttonStyle(DSQuietButton())

            Button {
                vm.attemptExport(purchaseManager: purchaseManager)
            } label: {
                HStack(spacing: DS.Space.x2) {
                    DSIcon(name: "square.and.arrow.up", size: 16)
                    Text("Exporter")
                }
            }
            .buttonStyle(DSPillButton())
            .accessibilityLabel("Exporter le tirage")
        }
        .padding(.horizontal, DS.Space.x4)
        .padding(.vertical, DS.Space.x3)
        .dsChassisBar()
    }
}

// MARK: - Sous-composants

private struct ActionBarLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 7) {
            configuration.icon
            configuration.title
        }
    }
}

private struct FilmstripCell: View {
    let image: UIImage
    let index: Int
    let isActive: Bool
    let onSelect: () -> Void
    let onRemove: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control))
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.control)
                        .stroke(isActive ? DS.Palette.safelight : DS.Palette.line,
                                lineWidth: isActive ? 2 : 1)
                )
                .overlay(alignment: .bottomLeading) {
                    Text(String(format: "%02d", index + 1))
                        .dsLabel()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 3)
                        .background(Color.black.opacity(0.55))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .padding(3)
                }
        }
        .accessibilityLabel("Écran \(index + 1)")
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
        .contextMenu {
            Button(role: .destructive, action: onRemove) {
                Label("Retirer cet écran", systemImage: "trash")
            }
        }
    }
}

// MARK: - Feuilles et alertes

private struct EditorSheets: ViewModifier {
    @Bindable var vm: MockupEditorViewModel
    let purchaseManager: PurchaseManager
    let store: ProjectStore

    func body(content: Content) -> some View {
        content
            .confirmationDialog("Ajouter une capture", isPresented: $vm.showCaptureSourceMenu, titleVisibility: .visible) {
                Button("Photothèque") { vm.showPhotoPicker = true }
                Button("Fichiers") { vm.showFileImporter = true }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("D'où vient l'image à placer dans l'appareil ?")
            }
            .photosPicker(isPresented: $vm.showPhotoPicker, selection: $vm.selectedPhotoItem, matching: .images)
            .onChange(of: vm.selectedPhotoItem) { _, _ in
                Task { await vm.loadPhotoFromPicker() }
            }
            .fileImporter(isPresented: $vm.showFileImporter,
                          allowedContentTypes: [.image],
                          allowsMultipleSelection: false) { result in
                if case .success(let urls) = result, let url = urls.first {
                    vm.loadImageFromFile(url: url)
                }
            }
            .sheet(isPresented: $vm.showControlPanel) {
                ControlPanelView(vm: vm)
                    .presentationDetents([.fraction(0.62), .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(DS.Palette.chassis)
            }
            .sheet(isPresented: $vm.showExportSheet) {
                ExportSheetView(vm: vm, purchaseManager: purchaseManager, store: store)
                    .presentationDetents([.large])
                    .presentationBackground(DS.Palette.base)
            }
            .sheet(isPresented: $vm.showPremiumUpgrade) {
                PremiumUpgradeView(purchaseManager: purchaseManager)
            }
            .sheet(item: $vm.filesToShare) { item in
                ShareSheet(items: item.urls)
            }
            .alert("Compteur épuisé", isPresented: $vm.showConversionLimitAlert) {
                Button("Ouvrir l'atelier") { vm.showPremiumUpgrade = true }
                Button("Plus tard", role: .cancel) { }
            } message: {
                Text("Vos \(PurchaseManager.freeConversionsLimit) tirages gratuits sont utilisés. Vos projets restent intacts.")
            }
    }
}

// MARK: - Feuille de partage système

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var onComplete: (() -> Void)? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.completionWithItemsHandler = { _, completed, _, _ in
            if completed { onComplete?() }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    MockupEditorView()
}
