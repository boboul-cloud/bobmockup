//
//  MockupProject.swift
//  Bobmockup
//
//  Persistance des projets. L'accueil listait « des projets » alors que
//  rien n'était jamais sauvegardé : fermer l'éditeur détruisait le travail.
//  Un projet est désormais un instantané complet de l'éditeur, écrit sur
//  disque à chaque modification, et rouvrable à l'identique.
//

import SwiftUI
import UIKit

// MARK: - Couleur sérialisable

struct CodableColor: Codable, Equatable, Hashable {
    var red: Double, green: Double, blue: Double, opacity: Double

    /// Init numérique, sans isolation : c'est celui qui sert aux valeurs
    /// par défaut d'un projet, évaluées hors de tout acteur.
    init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        self.red = red; self.green = green; self.blue = blue; self.opacity = opacity
    }

    /// Conversion depuis une `Color`. `Color` conforme à `View`, protocole
    /// isolé au MainActor : lire ses composantes l'est donc aussi. Ce n'est
    /// jamais nécessaire ailleurs — une couleur ne vient que d'une vue.
    @MainActor
    init(_ color: Color) {
        let resolved = color.resolve(in: EnvironmentValues())
        self.init(red: Double(resolved.red),
                  green: Double(resolved.green),
                  blue: Double(resolved.blue),
                  opacity: Double(resolved.opacity))
    }

    /// Le blanc, et le bain par défaut — les mêmes valeurs que
    /// `GradientPreset.presets[0]`, écrites en clair pour rester utilisables
    /// hors du MainActor.
    static let white = CodableColor(red: 1, green: 1, blue: 1)
    static let defaultBath = [
        CodableColor(red: 14 / 255, green: 28 / 255, blue: 46 / 255),
        CodableColor(red: 30 / 255, green: 74 / 255, blue: 115 / 255),
        CodableColor(red: 111 / 255, green: 160 / 255, blue: 200 / 255)
    ]

    @MainActor
    var color: Color { Color(red: red, green: green, blue: blue).opacity(opacity) }
}

extension Array where Element == Color {
    @MainActor
    var codable: [CodableColor] { map { CodableColor($0) } }
}

extension Array where Element == CodableColor {
    @MainActor
    var colors: [Color] { map(\.color) }
}

// MARK: - Projet

struct MockupProject: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var updatedAt: Date = .now

    var layout: CreationLayout = .single
    var orientation: FrameOrientation = .portrait
    var device: DeviceType = .iPhone15Pro
    var deviceColor: DeviceColor = .naturalTitanium

    var backgroundStyle: BackgroundStyle = .gradient
    var solidColor: CodableColor = .white
    var gradientColors: [CodableColor] = CodableColor.defaultBath

    var captionText: String = ""
    /// L'accroche du second écran d'un panorama.
    var captionText2: String = ""
    var captionColor: CodableColor = .white
    var captionFontSize: CGFloat = 48
    var captionFontName: String = "System"
    var captionPadding: CGFloat = 20
    var captionPosition: CaptionPosition = .top

    var shadowEnabled: Bool = true
    var shadowRadius: CGFloat = 30
    var rotation3D: Double = 0
    var scale: CGFloat = 0.8
    var deviceXOffset: CGFloat = 0
    var deviceYOffset: CGFloat = 0
    var showStatusBar: Bool = false

    var badges: [MockupBadge] = []
    var badgeScale: CGFloat = 1.0
    var exportSizePreset: ExportSizePreset = .iphone67

    /// Noms de fichier des captures, dans l'ordre des écrans, relatifs au
    /// dossier des captures. Seule la première était conservée : une série
    /// ou un duo rouvert avait perdu tous ses écrans sauf un.
    var screenshotFiles: [String] = []
    /// L'ancien champ, une seule capture. Relu à l'ouverture des projets
    /// enregistrés avant la conservation de tous les écrans, et toujours
    /// écrit pour qu'une version précédente de l'app retrouve la première.
    var screenshotFile: String?
    var backgroundFile: String?

    static func == (lhs: MockupProject, rhs: MockupProject) -> Bool { lhs.id == rhs.id }

    /// Tous les fichiers du dossier des captures qui appartiennent au projet.
    var assetFiles: Set<String> {
        Set(screenshotFiles + [screenshotFile, backgroundFile].compactMap { $0 })
    }

    /// La cote d'un écran, orientation comprise, précédée du nombre
    /// d'écrans quand le tirage en compte plusieurs d'un seul tenant.
    var dimensionLabel: String {
        let label = exportSizePreset.dimensionLabel(for: orientation)
        return layout.panelCount > 1 ? "\(layout.panelCount) × \(label)" : label
    }
}

// MARK: - Lecture tolérante

extension MockupProject {
    /// Chaque champ absent reprend sa valeur par défaut. Le décodage
    /// synthétisé exige toutes les clés : un champ ajouté dans une mise à
    /// jour aurait rendu illisible l'index entier, et vidé l'atelier.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let base = MockupProject(name: "")
        func read<T: Decodable>(_ key: CodingKeys, _ fallback: T) -> T {
            (try? c.decodeIfPresent(T.self, forKey: key)) ?? fallback
        }
        self.init(name: try c.decode(String.self, forKey: .name))
        id = try c.decode(UUID.self, forKey: .id)
        updatedAt = read(.updatedAt, base.updatedAt)
        layout = read(.layout, base.layout)
        orientation = read(.orientation, base.orientation)
        device = read(.device, base.device)
        deviceColor = read(.deviceColor, base.deviceColor)
        backgroundStyle = read(.backgroundStyle, base.backgroundStyle)
        solidColor = read(.solidColor, base.solidColor)
        gradientColors = read(.gradientColors, base.gradientColors)
        captionText = read(.captionText, base.captionText)
        captionText2 = read(.captionText2, base.captionText2)
        captionColor = read(.captionColor, base.captionColor)
        captionFontSize = read(.captionFontSize, base.captionFontSize)
        captionFontName = read(.captionFontName, base.captionFontName)
        captionPadding = read(.captionPadding, base.captionPadding)
        captionPosition = read(.captionPosition, base.captionPosition)
        shadowEnabled = read(.shadowEnabled, base.shadowEnabled)
        shadowRadius = read(.shadowRadius, base.shadowRadius)
        rotation3D = read(.rotation3D, base.rotation3D)
        scale = read(.scale, base.scale)
        deviceXOffset = read(.deviceXOffset, base.deviceXOffset)
        deviceYOffset = read(.deviceYOffset, base.deviceYOffset)
        showStatusBar = read(.showStatusBar, base.showStatusBar)
        badges = read(.badges, base.badges)
        badgeScale = read(.badgeScale, base.badgeScale)
        exportSizePreset = read(.exportSizePreset, base.exportSizePreset)
        screenshotFile = try? c.decodeIfPresent(String.self, forKey: .screenshotFile)
        backgroundFile = try? c.decodeIfPresent(String.self, forKey: .backgroundFile)
        screenshotFiles = read(.screenshotFiles, [String]())
        if screenshotFiles.isEmpty, let legacy = screenshotFile { screenshotFiles = [legacy] }
    }
}

// MARK: - Magasin

@Observable
@MainActor
final class ProjectStore {
    static let shared = ProjectStore()

    private(set) var projects: [MockupProject] = []

    private let fileManager = FileManager.default

    private var documents: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var indexURL: URL { documents.appendingPathComponent("projects.json") }
    private var assetsDirectory: URL { documents.appendingPathComponent("Captures", isDirectory: true) }

    private init() {
        try? fileManager.createDirectory(at: assetsDirectory, withIntermediateDirectories: true)
        load()
    }

    // MARK: Lecture / écriture

    private func load() {
        guard let data = try? Data(contentsOf: indexURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let decoded = try? decoder.decode([MockupProject].self, from: data) else { return }
        projects = decoded
        sort()
        sweepOrphanAssets()
    }

    /// Efface les captures qu'aucun projet n'emploie. Les versions
    /// précédentes réécrivaient la capture à chaque enregistrement sans
    /// effacer l'ancienne : le dossier en a gardé des copies orphelines.
    /// Ne tourne qu'après une lecture réussie de l'index — sur un index
    /// illisible, tout paraîtrait orphelin.
    private func sweepOrphanAssets() {
        let used = projects.reduce(into: Set<String>()) { $0.formUnion($1.assetFiles) }
        guard let files = try? fileManager.contentsOfDirectory(atPath: assetsDirectory.path) else { return }
        for file in files where !used.contains(file) {
            removeAsset(named: file)
        }
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(projects) else { return }
        try? data.write(to: indexURL, options: .atomic)
    }

    private func sort() {
        projects.sort { $0.updatedAt > $1.updatedAt }
    }

    // MARK: Opérations

    /// Enregistre ou met à jour un projet. Appelé à chaque modification
    /// de l'éditeur : l'utilisateur n'a jamais à penser à sauvegarder.
    /// Les captures que le projet n'emploie plus sont effacées du disque.
    func save(_ project: MockupProject) {
        var updated = project
        updated.updatedAt = .now
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            for file in projects[index].assetFiles.subtracting(updated.assetFiles) {
                removeAsset(named: file)
            }
            projects[index] = updated
        } else {
            projects.insert(updated, at: 0)
        }
        sort()
        persist()
    }

    func delete(_ project: MockupProject) {
        project.assetFiles.forEach(removeAsset(named:))
        projects.removeAll { $0.id == project.id }
        persist()
    }

    func duplicate(_ project: MockupProject) -> MockupProject {
        var copy = project
        copy.id = UUID()
        copy.name = project.name + " (copie)"
        copy.updatedAt = .now
        copy.screenshotFiles = project.screenshotFiles.compactMap(copyAsset(named:))
        copy.screenshotFile = copy.screenshotFiles.first
        if let file = project.backgroundFile { copy.backgroundFile = copyAsset(named: file) }
        projects.insert(copy, at: 0)
        persist()
        return copy
    }

    /// Nom par défaut d'un nouveau projet, numéroté dans l'ordre d'ouverture.
    func defaultName(for layout: CreationLayout) -> String {
        let base: String
        switch layout {
        case .single:  base = "Épreuve"
        case .duo:     base = "Duo"
        case .series:  base = "Série"
        case .panorama: base = "Panorama"
        case .banner:  base = "Bande"
        }
        let existing = projects.filter { $0.name.hasPrefix(base) }.count
        return existing == 0 ? base : "\(base) \(existing + 1)"
    }

    // MARK: Captures

    func writeAsset(_ image: UIImage) -> String? {
        guard let data = image.pngData() else { return nil }
        let name = UUID().uuidString + ".png"
        try? data.write(to: assetsDirectory.appendingPathComponent(name), options: .atomic)
        return name
    }

    func readAsset(named name: String?) -> UIImage? {
        guard let name,
              let data = try? Data(contentsOf: assetsDirectory.appendingPathComponent(name))
        else { return nil }
        return UIImage(data: data)
    }

    private func removeAsset(named name: String) {
        try? fileManager.removeItem(at: assetsDirectory.appendingPathComponent(name))
    }

    private func copyAsset(named name: String) -> String? {
        let source = assetsDirectory.appendingPathComponent(name)
        let newName = UUID().uuidString + ".png"
        let destination = assetsDirectory.appendingPathComponent(newName)
        do { try fileManager.copyItem(at: source, to: destination); return newName }
        catch { return nil }
    }
}

// MARK: - Date relative

extension Date {
    /// « il y a 2 h », « hier », « 12 août » — le format d'un plan de travail.
    var workshopRelative: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            let minutes = max(0, Int(Date.now.timeIntervalSince(self) / 60))
            if minutes < 1 { return "à l'instant" }
            if minutes < 60 { return "il y a \(minutes) min" }
            return "il y a \(minutes / 60) h"
        }
        if calendar.isDateInYesterday(self) { return "Hier" }
        let days = calendar.dateComponents([.day], from: self, to: .now).day ?? 0
        if days < 7 { return "il y a \(days) j" }
        return formatted(.dateTime.day().month(.abbreviated))
    }
}
