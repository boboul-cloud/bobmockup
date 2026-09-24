//
//  MockupEditorViewModel.swift
//  Bobmockup
//
//  Toute la logique de l'éditeur. La chaîne de rendu passe désormais par
//  CompositionSpec / ExportService : l'aperçu et le tirage partagent le
//  même code, et le projet est sauvegardé à chaque modification.
//

import SwiftUI
import PhotosUI

// MARK: - Instantané pour annuler / rétablir

private struct EditorSnapshot {
    let orientation: FrameOrientation
    let selectedDevice: DeviceType
    let deviceColor: DeviceColor
    let backgroundStyle: BackgroundStyle
    let solidColor: Color
    let gradientColors: [Color]
    let shadowEnabled: Bool
    let shadowRadius: CGFloat
    let rotation3D: Double
    let pivot: Double
    let scale: CGFloat
    let captionText: String
    let captionText2: String
    let captionColor: Color
    let captionFontSize: CGFloat
    let captionFontName: String
    let captionPadding: CGFloat
    let captionPosition: CaptionPosition
    let deviceXOffset: CGFloat
    let deviceYOffset: CGFloat
    let showStatusBar: Bool
    let badges: [MockupBadge]
    let badgeScale: CGFloat
    let exportSizePreset: ExportSizePreset
    let screenshots: [UIImage]
}

@Observable
@MainActor
final class MockupEditorViewModel {

    // MARK: - Projet

    private(set) var projectID: UUID = UUID()
    var projectName: String = "Épreuve" { didSet { scheduleSave() } }
    var layout: CreationLayout = .single {
        didSet {
            if let forced = layout.forcedExportSize { exportSizePreset = forced }
            scheduleSave()
        }
    }

    /// Portrait ou paysage. Le cadre pivote, et l'appareil avec lui.
    var orientation: FrameOrientation = .portrait { didSet { scheduleSave() } }

    // MARK: - Appareil

    var selectedDevice: DeviceType = .iPhone15Pro {
        didSet {
            if !selectedDevice.availableColors.contains(deviceColor) {
                deviceColor = selectedDevice.availableColors.first ?? .naturalTitanium
            }
            scheduleSave()
        }
    }
    var deviceColor: DeviceColor = .naturalTitanium { didSet { scheduleSave() } }

    // MARK: - Fond

    var backgroundStyle: BackgroundStyle = .gradient { didSet { scheduleSave() } }
    var solidColor: Color = ColorPreset.presets[0].color { didSet { scheduleSave() } }
    var gradientColors: [Color] = GradientPreset.presets[0].colors { didSet { scheduleSave() } }
    var backgroundImage: UIImage?

    // MARK: - Effets

    var shadowEnabled: Bool = true { didSet { scheduleSave() } }
    var shadowRadius: CGFloat = 30 { didSet { scheduleSave() } }
    var rotation3D: Double = 0 { didSet { scheduleSave() } }
    /// En Duo, l'inclinaison de chaque appareil sur son centre.
    var pivot: Double = 0 { didSet { scheduleSave() } }
    var scale: CGFloat = 0.8 { didSet { scheduleSave() } }
    var deviceXOffset: CGFloat = 0 { didSet { scheduleSave() } }
    var deviceYOffset: CGFloat = 0 { didSet { scheduleSave() } }

    // MARK: - Captures

    /// En mode Série, une capture par écran. Ailleurs, seule la première sert.
    var screenshots: [UIImage] = []
    var activeScreenshot: Int = 0

    var screenshot: UIImage? {
        screenshots.indices.contains(activeScreenshot) ? screenshots[activeScreenshot] : screenshots.first
    }

    var maxScreenshots: Int { layout == .series ? 5 : (layout == .duo ? 2 : 1) }
    var canAddScreenshot: Bool { screenshots.count < maxScreenshots }

    // MARK: - Accroche

    var captionText: String = "" { didSet { scheduleSave() } }
    /// L'accroche du second écran d'un panorama.
    var captionText2: String = "" { didSet { scheduleSave() } }
    var captionColor: Color = .white { didSet { scheduleSave() } }
    var captionFontSize: CGFloat = 48 { didSet { scheduleSave() } }
    var captionFontName: String = "System" { didSet { scheduleSave() } }
    var captionPadding: CGFloat = 20 { didSet { scheduleSave() } }
    var captionPosition: CaptionPosition = .top { didSet { scheduleSave() } }

    var showStatusBar: Bool = false { didSet { scheduleSave() } }

    // MARK: - Pastilles

    var badges: [MockupBadge] = [] { didSet { scheduleSave() } }
    var badgeScale: CGFloat = 1.0 { didSet { scheduleSave() } }

    // MARK: - Tirage

    var exportSizePreset: ExportSizePreset = .iphone67 { didSet { scheduleSave() } }
    var exportMode: ExportMode = .single {
        didSet {
            guard oldValue != exportMode else { return }
            // Un mode qui n'accepte pas la destination courante la ramène
            // sur la première qu'il autorise.
            if let allowed = exportMode.destinations.first,
               !exportMode.destinations.contains(exportDestination) {
                exportDestination = allowed
            }
            // Le mode propose son réglage d'alpha ; il ne l'impose pas.
            // L'utilisateur peut le contredire juste après.
            includeAlpha = exportMode.naturalAlpha
        }
    }
    /// Photothèque ou Fichiers — le choix vaut pour toutes les productions.
    var exportDestination: ExportDestination = .photos

    /// Conserver la couche alpha du PNG. Proposé sur tous les modes :
    /// c'est un choix de tirage, pas une propriété du mode. Le défaut part
    /// aplati, parce qu'un dépôt App Store refuse toute couche alpha.
    var includeAlpha: Bool = false

    /// Le réglage réellement appliqué. Un PDF n'a pas de couche alpha à
    /// conserver : la question ne se pose pas pour lui.
    var effectiveIncludeAlpha: Bool {
        exportMode.allowsAlphaChoice ? includeAlpha : false
    }

    // MARK: - État d'interface

    var showControlPanel = false
    var selectedPhotoItem: PhotosPickerItem?
    var showPremiumUpgrade = false
    var showConversionLimitAlert = false
    var showFileImporter = false
    var showPhotoPicker = false
    var showCaptureSourceMenu = false
    var showExportSheet = false
    var showResetConfirmation = false

    enum ExportPhase: Equatable {
        case idle
        case running(Double)
        case done(ExportSummary)
        case failed(String)
    }

    struct ExportSummary: Equatable {
        var title: LocalizedStringKey
        var detail: String
        var fileURLs: [URL] = []
    }

    var exportPhase: ExportPhase = .idle
    var isExporting: Bool { if case .running = exportPhase { return true }; return false }

    /// Les tirages rangés dans Fichiers passent par la feuille de partage —
    /// c'est là que se trouve « Enregistrer dans Fichiers », et c'est elle
    /// qui accepte plusieurs fichiers d'un coup pour une série ou un lot.
    var filesToShare: IdentifiableURLs?

    // MARK: - Annuler / rétablir

    private var undoStack: [EditorSnapshot] = []
    private var redoStack: [EditorSnapshot] = []
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    private var isRestoring = false
    /// Tant que le projet n'a pas été ouvert ou créé, aucune modification
    /// ne doit être écrite : sinon un éditeur simplement instancié
    /// déposerait un projet fantôme dans l'atelier.
    private var hasStarted = false
    private var saveTask: Task<Void, Never>?

    /// Les images du projet déjà écrites sur disque, et sous quel nom.
    /// Une image n'est encodée qu'une fois : chaque enregistrement
    /// réécrivait sinon toutes les captures sous un nouveau nom — un PNG
    /// pleine taille par réglage touché, jamais effacé.
    private var writtenAssets: [(image: UIImage, file: String)] = []

    // MARK: - Cycle de vie du projet

    func start(layout: CreationLayout, store: ProjectStore) {
        self.isRestoring = true
        self.projectID = UUID()
        self.layout = layout
        self.projectName = store.defaultName(for: layout)
        if let forced = layout.forcedExportSize { exportSizePreset = forced }
        self.isRestoring = false
        self.hasStarted = true
        scheduleSave()
    }

    func open(_ project: MockupProject, store: ProjectStore) {
        isRestoring = true
        projectID = project.id
        projectName = project.name
        layout = project.layout
        orientation = project.orientation
        selectedDevice = project.device
        deviceColor = project.deviceColor
        backgroundStyle = project.backgroundStyle
        solidColor = project.solidColor.color
        gradientColors = project.gradientColors.colors
        captionText = project.captionText
        captionText2 = project.captionText2
        captionColor = project.captionColor.color
        captionFontSize = project.captionFontSize
        captionFontName = project.captionFontName
        captionPadding = project.captionPadding
        captionPosition = project.captionPosition
        shadowEnabled = project.shadowEnabled
        shadowRadius = project.shadowRadius
        rotation3D = project.rotation3D
        pivot = project.pivot
        scale = project.scale
        deviceXOffset = project.deviceXOffset
        deviceYOffset = project.deviceYOffset
        showStatusBar = project.showStatusBar
        badges = project.badges
        badgeScale = project.badgeScale
        exportSizePreset = project.exportSizePreset
        writtenAssets.removeAll()
        screenshots = project.screenshotFiles.compactMap { file in
            guard let image = store.readAsset(named: file) else { return nil }
            writtenAssets.append((image, file))
            return image
        }
        activeScreenshot = 0
        backgroundImage = store.readAsset(named: project.backgroundFile)
        if let image = backgroundImage, let file = project.backgroundFile {
            writtenAssets.append((image, file))
        }
        undoStack.removeAll(); redoStack.removeAll()
        isRestoring = false
        hasStarted = true
    }

    private func snapshotForStore(_ store: ProjectStore) -> MockupProject {
        var project = MockupProject(name: projectName)
        project.id = projectID
        project.layout = layout
        project.orientation = orientation
        project.device = selectedDevice
        project.deviceColor = deviceColor
        project.backgroundStyle = backgroundStyle
        project.solidColor = CodableColor(solidColor)
        project.gradientColors = gradientColors.codable
        project.captionText = captionText
        project.captionText2 = captionText2
        project.captionColor = CodableColor(captionColor)
        project.captionFontSize = captionFontSize
        project.captionFontName = captionFontName
        project.captionPadding = captionPadding
        project.captionPosition = captionPosition
        project.shadowEnabled = shadowEnabled
        project.shadowRadius = shadowRadius
        project.rotation3D = rotation3D
        project.pivot = pivot
        project.scale = scale
        project.deviceXOffset = deviceXOffset
        project.deviceYOffset = deviceYOffset
        project.showStatusBar = showStatusBar
        project.badges = badges
        project.badgeScale = badgeScale
        project.exportSizePreset = exportSizePreset
        project.screenshotFiles = screenshots.compactMap { assetFile(for: $0, store: store) }
        project.screenshotFile = project.screenshotFiles.first
        project.backgroundFile = backgroundImage.flatMap { assetFile(for: $0, store: store) }
        // Le registre ne garde que ce que le projet emploie : le magasin
        // efface le reste du disque, et une image rendue par « annuler »
        // sera réécrite sous un nouveau nom.
        let used = project.assetFiles
        writtenAssets.removeAll { !used.contains($0.file) }
        return project
    }

    /// Le fichier d'une image : celui déjà écrit, ou un nouveau.
    private func assetFile(for image: UIImage, store: ProjectStore) -> String? {
        if let known = writtenAssets.first(where: { $0.image === image }) { return known.file }
        guard let file = store.writeAsset(image) else { return nil }
        writtenAssets.append((image, file))
        return file
    }

    /// Écriture différée : l'utilisateur qui fait glisser une course
    /// ne déclenche pas cinquante écritures disque.
    private func scheduleSave() {
        guard hasStarted, !isRestoring else { return }
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(600))
            guard !Task.isCancelled, let self else { return }
            self.saveNow()
        }
    }

    func saveNow() {
        guard hasStarted else { return }
        let store = ProjectStore.shared
        store.save(snapshotForStore(store))
    }

    // MARK: - Composition

    /// La cote réellement tirée. Un mode qui impose son format — le dépôt
    /// 6,5 pouces — l'emporte sur le format choisi dans l'éditeur, et c'est
    /// cette cote-là que la feuille de tirage doit annoncer.
    var effectiveExportSize: ExportSizePreset {
        exportMode.forcedExportSize ?? exportSizePreset
    }

    /// La composition telle qu'elle sera tirée, cote du mode comprise.
    /// L'aperçu de la feuille de tirage doit montrer le vrai cadrage.
    var exportComposition: CompositionSpec {
        var spec = composition
        spec.exportSize = effectiveExportSize
        return spec
    }

    var composition: CompositionSpec {
        var spec = CompositionSpec()
        spec.layout = layout
        spec.exportSize = exportSizePreset
        spec.orientation = orientation
        spec.backgroundStyle = backgroundStyle
        spec.solidColor = solidColor
        spec.gradientColors = gradientColors
        spec.backgroundImage = backgroundImage
        spec.captionText = captionText
        spec.captionText2 = captionText2
        spec.captionFontSize = captionFontSize
        spec.captionFontName = captionFontName
        spec.captionColor = captionColor
        spec.captionPadding = captionPadding
        spec.captionPosition = captionPosition
        spec.deviceType = selectedDevice
        spec.deviceColor = deviceColor
        spec.shadowEnabled = shadowEnabled
        spec.shadowRadius = shadowRadius
        spec.scale = scale
        spec.rotation3D = rotation3D
        spec.pivot = pivot
        spec.deviceXOffset = deviceXOffset
        spec.deviceYOffset = deviceYOffset
        spec.showStatusBar = showStatusBar
        spec.badges = badges
        spec.badgeScale = badgeScale
        spec.screenshots = screenshots
        spec.activeScreenshotIndex = activeScreenshot
        return spec
    }

    // MARK: - Annuler / rétablir

    private func makeSnapshot() -> EditorSnapshot {
        EditorSnapshot(
            orientation: orientation,
            selectedDevice: selectedDevice, deviceColor: deviceColor,
            backgroundStyle: backgroundStyle, solidColor: solidColor,
            gradientColors: gradientColors, shadowEnabled: shadowEnabled,
            shadowRadius: shadowRadius, rotation3D: rotation3D, pivot: pivot, scale: scale,
            captionText: captionText, captionText2: captionText2, captionColor: captionColor,
            captionFontSize: captionFontSize, captionFontName: captionFontName,
            captionPadding: captionPadding, captionPosition: captionPosition,
            deviceXOffset: deviceXOffset, deviceYOffset: deviceYOffset, showStatusBar: showStatusBar,
            badges: badges, badgeScale: badgeScale,
            exportSizePreset: exportSizePreset, screenshots: screenshots)
    }

    func saveUndoState() {
        undoStack.append(makeSnapshot())
        if undoStack.count > 30 { undoStack.removeFirst() }
        redoStack.removeAll()
    }

    func undo() {
        guard let snapshot = undoStack.popLast() else { return }
        redoStack.append(makeSnapshot())
        apply(snapshot)
        DS.Haptics.light()
    }

    func redo() {
        guard let snapshot = redoStack.popLast() else { return }
        undoStack.append(makeSnapshot())
        apply(snapshot)
        DS.Haptics.light()
    }

    private func apply(_ s: EditorSnapshot) {
        isRestoring = true
        orientation = s.orientation
        selectedDevice = s.selectedDevice
        deviceColor = s.deviceColor
        backgroundStyle = s.backgroundStyle
        solidColor = s.solidColor
        gradientColors = s.gradientColors
        shadowEnabled = s.shadowEnabled
        shadowRadius = s.shadowRadius
        rotation3D = s.rotation3D
        pivot = s.pivot
        scale = s.scale
        captionText = s.captionText
        captionText2 = s.captionText2
        captionColor = s.captionColor
        captionFontSize = s.captionFontSize
        captionFontName = s.captionFontName
        captionPadding = s.captionPadding
        captionPosition = s.captionPosition
        deviceXOffset = s.deviceXOffset
        deviceYOffset = s.deviceYOffset
        showStatusBar = s.showStatusBar
        badges = s.badges
        badgeScale = s.badgeScale
        exportSizePreset = s.exportSizePreset
        screenshots = s.screenshots
        activeScreenshot = min(activeScreenshot, max(0, screenshots.count - 1))
        isRestoring = false
        scheduleSave()
    }

    // MARK: - Orientation

    func toggleOrientation() {
        saveUndoState()
        orientation = orientation.toggled
        DS.Haptics.light()
    }

    // MARK: - Bains

    func applyBath(_ preset: GradientPreset) {
        saveUndoState()
        gradientColors = preset.colors
        if backgroundStyle == .solid { solidColor = preset.colors.first ?? .white }
        // L'accroche doit rester lisible : encre sur bain clair, blanc sinon.
        captionColor = preset.isLight ? Color(red: 0.086, green: 0.090, blue: 0.102) : .white
        DS.Haptics.light()
    }

    // MARK: - Pastilles

    /// Pose une pastille. Une pastille personnalisée s'ajoute toujours :
    /// contrairement aux préréglages, deux pastilles peuvent porter le même
    /// texte dans deux coins différents.
    func addBadge(_ badge: MockupBadge) {
        saveUndoState()
        badges.append(badge)
        DS.Haptics.light()
    }

    func toggleBadge(_ badge: MockupBadge) {
        saveUndoState()
        if let existing = badges.first(where: { $0.text == badge.text && $0.style == badge.style }) {
            badges.removeAll { $0.id == existing.id }
        } else {
            badges.append(badge)
        }
        DS.Haptics.light()
    }

    func removeBadge(_ badge: MockupBadge) {
        saveUndoState()
        badges.removeAll { $0.id == badge.id }
        DS.Haptics.light()
    }

    // MARK: - Captures

    func addScreenshot(_ image: UIImage) {
        saveUndoState()
        if canAddScreenshot {
            screenshots.append(image)
            activeScreenshot = screenshots.count - 1
        } else {
            screenshots[activeScreenshot] = image
        }
        DS.Haptics.light()
        scheduleSave()
    }

    func removeScreenshot(at index: Int) {
        guard screenshots.indices.contains(index) else { return }
        saveUndoState()
        screenshots.remove(at: index)
        activeScreenshot = min(activeScreenshot, max(0, screenshots.count - 1))
        scheduleSave()
    }

    func loadImageFromFile(url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return }
        addScreenshot(image)
    }

    func loadPhotoFromPicker() async {
        guard let item = selectedPhotoItem,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        addScreenshot(image)
        selectedPhotoItem = nil
    }

    // MARK: - Tirage

    /// Un mode réservé à Premium n'est pas caché : il est visible, désigné
    /// comme tel, et proposer l'achat au moment où il sert est plus honnête
    /// que de le faire disparaître.
    func isModeLocked(_ mode: ExportMode, purchaseManager: PurchaseManager) -> Bool {
        mode.requiresPremium && !purchaseManager.isPremium
    }

    func attemptExport(purchaseManager: PurchaseManager) {
        guard !screenshots.isEmpty else {
            DS.Haptics.error()
            showCaptureSourceMenu = true
            return
        }
        if purchaseManager.canConvert {
            DS.Haptics.medium()
            showExportSheet = true
        } else {
            DS.Haptics.error()
            showConversionLimitAlert = true
        }
    }

    func runExport(purchaseManager: PurchaseManager) async {
        if isModeLocked(exportMode, purchaseManager: purchaseManager) {
            showPremiumUpgrade = true
            return
        }
        guard purchaseManager.canConvert else {
            DS.Haptics.error()
            showConversionLimitAlert = true
            return
        }

        DS.Haptics.heavy()
        exportPhase = .running(0)

        do {
            let result = try await ExportService.run(mode: exportMode,
                                                     destination: exportDestination,
                                                     composition: composition,
                                                     includeAlpha: effectiveIncludeAlpha) { value in
                self.exportPhase = .running(value)
            }
            _ = purchaseManager.useConversion()
            if !result.fileURLs.isEmpty { filesToShare = IdentifiableURLs(urls: result.fileURLs) }
            exportPhase = .done(ExportSummary(title: exportMode.successTitle,
                                              detail: result.detail,
                                              fileURLs: result.fileURLs))
            DS.Haptics.success()
        } catch {
            exportPhase = .failed(error.localizedDescription)
            DS.Haptics.error()
        }
    }

    func dismissExport() {
        exportPhase = .idle
        showExportSheet = false
    }

    func startNewProof(store: ProjectStore) {
        saveNow()
        screenshots.removeAll()
        activeScreenshot = 0
        captionText = ""
        captionText2 = ""
        badges.removeAll()
        // Le fond est conservé, mais la nouvelle épreuve l'écrit sous son
        // propre nom : effacer l'ancien projet ne doit pas le lui retirer.
        writtenAssets.removeAll()
        undoStack.removeAll()
        redoStack.removeAll()
        projectID = UUID()
        projectName = store.defaultName(for: layout)
        exportPhase = .idle
        showExportSheet = false
    }
}

// MARK: - Enveloppes identifiables

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct IdentifiableURLs: Identifiable {
    let id = UUID()
    let urls: [URL]
}
