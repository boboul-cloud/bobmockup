//
//  MockupEditorView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct TransferableImage: Transferable {
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return TransferableImage(image: uiImage)
        }
    }
    
    enum TransferError: Error {
        case importFailed
    }
}

// Wrapper pour rendre UIImage identifiable (nécessaire pour sheet(item:))
struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct MockupEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseManager = PurchaseManager.shared
    
    @State private var selectedDevice: DeviceType = .iPhone15Pro
    @State private var backgroundStyle: BackgroundStyle = .gradient
    @State private var solidColor: Color = .white
    @State private var gradientColors: [Color] = [.purple, .pink, .orange]
    @State private var backgroundImage: UIImage?
    @State private var shadowEnabled: Bool = true
    @State private var shadowRadius: CGFloat = 30
    @State private var rotation3D: Double = 0
    @State private var scale: CGFloat = 0.8
    @State private var screenshot: UIImage?
    
    @State private var captionText: String = ""
    @State private var captionColor: Color = .white
    @State private var captionFontSize: CGFloat = 48
    @State private var captionFontName: String = "System"
    @State private var captionPadding: CGFloat = 20
    
    @State private var showControlPanel = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var imageToShare: IdentifiableImage?
    @State private var showPremiumUpgrade = false
    @State private var showConversionLimitAlert = false
    @State private var showFileImporter = false
    @State private var showPhotoPicker = false
    @State private var showDevicePhotoSourceMenu = false
    @State private var isExporting = false
    @State private var showExportSuccess = false
    
    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("Éditeur")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Fermer") {
                            dismiss()
                        }
                    }
                }
                .alert("Limite atteinte", isPresented: $showConversionLimitAlert) {
                    Button("Passer Premium") { showPremiumUpgrade = true }
                    Button("Annuler", role: .cancel) { }
                } message: {
                    Text("Vous avez utilisé vos \(PurchaseManager.freeConversionsLimit) conversions gratuites.")
                }
                .sheet(isPresented: $showPremiumUpgrade) {
                    PremiumUpgradeView(purchaseManager: purchaseManager)
                }
                .sheet(item: $imageToShare) { item in
                    ShareSheet(items: [item.image]) {
                        resetAfterExport()
                    }
                }
                .sheet(isPresented: $showControlPanel) {
                    controlPanelSheet
                }
                .onChange(of: selectedPhotoItem) { oldValue, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            screenshot = image
                        }
                    }
                }
                .fileImporter(
                    isPresented: $showFileImporter,
                    allowedContentTypes: [.image],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let urls):
                        if let url = urls.first {
                            loadImageFromFile(url: url)
                        }
                    case .failure(let error):
                        print("Erreur lors de la sélection du fichier: \(error.localizedDescription)")
                    }
                }
                .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        }
    }
    
    private var mainContent: some View {
        ZStack {
            // Fond personnalisable
            BackgroundView(
                style: backgroundStyle,
                solidColor: solidColor,
                gradientColors: gradientColors,
                backgroundImage: backgroundImage
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Zone du device
                if !captionText.isEmpty {
                    Text(captionText)
                        .font(captionFontName == "System" 
                              ? .system(size: captionFontSize * 0.5, weight: .bold, design: .rounded) 
                              : .custom(captionFontName, size: captionFontSize * 0.5))
                        .fontWeight(.bold)
                        .foregroundColor(captionColor)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, captionPadding)
                }
                
                // Device cliquable pour ajouter une capture
                DeviceFrameView(
                    deviceType: selectedDevice,
                    screenshot: screenshot,
                    shadowEnabled: shadowEnabled,
                    shadowRadius: shadowRadius,
                    rotation3D: rotation3D
                )
                .scaleEffect(0.55)
                .frame(height: 450)
                .contentShape(Rectangle())
                .onTapGesture {
                    showDevicePhotoSourceMenu = true
                }
                .accessibilityLabel(screenshot == nil ? "Ajouter une capture d'écran" : "Modifier la capture d'écran")
                .accessibilityHint("Touchez pour importer une image à afficher dans l'appareil")
                .accessibilityAddTraits(.isButton)
                .confirmationDialog("Ajouter une capture", isPresented: $showDevicePhotoSourceMenu, titleVisibility: .visible) {
                    Button("Bibliothèque photo") {
                        showPhotoPicker = true
                    }
                    Button("Fichiers") {
                        showFileImporter = true
                    }
                    Button("Annuler", role: .cancel) { }
                }
                
                Spacer()
                
                // Barre d'action
                actionBar
            }
            .padding(.top, 20)
        }
    }
    
    private var actionBar: some View {
        HStack(spacing: 0) {
            // Bouton Photo avec menu de source
            Menu {
                // Option Bibliothèque photo
                Button {
                    showPhotoPicker = true
                } label: {
                    Label("Bibliothèque photo", systemImage: "photo.on.rectangle")
                }
                
                // Option Fichiers
                Button {
                    showFileImporter = true
                } label: {
                    Label("Fichiers", systemImage: "folder")
                }
            } label: {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        Image(systemName: "photo.badge.plus")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    Text("Photo")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Ajouter une capture d'écran")
            .accessibilityHint("Ouvre le menu pour importer une image depuis la bibliothèque ou les fichiers")
            
            // Bouton Réglages
            Button {
                showControlPanel = true
            } label: {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    Text("Réglages")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Ouvrir les réglages")
            .accessibilityHint("Ouvre le panneau de personnalisation pour modifier l'appareil, le fond et les effets")
            
            // Bouton Exporter
            Button {
                attemptExport()
            } label: {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        if isExporting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                    }
                    Text(isExporting ? "Export..." : "Exporter")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .disabled(isExporting)
            .frame(maxWidth: .infinity)
            .accessibilityLabel(isExporting ? "Export en cours" : "Exporter le mockup")
            .accessibilityHint("Génère une image haute qualité du mockup et ouvre le menu de partage")
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var controlPanelSheet: some View {
        NavigationStack {
            ControlPanelView(
                selectedDevice: $selectedDevice,
                backgroundStyle: $backgroundStyle,
                solidColor: $solidColor,
                gradientColors: $gradientColors,
                backgroundImage: $backgroundImage,
                shadowEnabled: $shadowEnabled,
                shadowRadius: $shadowRadius,
                rotation3D: $rotation3D,
                scale: $scale,
                captionText: $captionText,
                captionColor: $captionColor,
                captionFontSize: $captionFontSize,
                captionFontName: $captionFontName,
                captionPadding: $captionPadding
            )
            .navigationTitle("Personnalisation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        showControlPanel = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func attemptExport() {
        if purchaseManager.canConvert {
            generateAndShareImage()
        } else {
            showConversionLimitAlert = true
        }
    }
    
    @MainActor
    private func generateAndShareImage() {
        isExporting = true
        _ = purchaseManager.useConversion()
        
        let exportSize = CGSize(width: 1080, height: 1920)
        
        // Capturer les valeurs actuelles en tant que copies locales
        let currentScreenshot = screenshot
        let currentBackgroundImage = backgroundImage
        let currentBackgroundStyle = backgroundStyle
        let currentSolidColor = solidColor
        let currentGradientColors = gradientColors
        let currentCaptionText = captionText
        let currentCaptionFontSize = captionFontSize
        let currentCaptionFontName = captionFontName
        let currentCaptionColor = captionColor
        let currentCaptionPadding = captionPadding
        let currentSelectedDevice = selectedDevice
        let currentShadowEnabled = shadowEnabled
        let currentShadowRadius = shadowRadius
        let currentScale = scale
        let currentRotation3D = rotation3D
        
        // Créer la vue d'export avec un background opaque
        let exportView = ExportableView(
            exportSize: exportSize,
            backgroundStyle: currentBackgroundStyle,
            solidColor: currentSolidColor,
            gradientColors: currentGradientColors,
            backgroundImage: currentBackgroundImage,
            captionText: currentCaptionText,
            captionFontSize: currentCaptionFontSize,
            captionFontName: currentCaptionFontName,
            captionColor: currentCaptionColor,
            captionPadding: currentCaptionPadding,
            deviceType: currentSelectedDevice,
            screenshot: currentScreenshot,
            shadowEnabled: currentShadowEnabled,
            shadowRadius: currentShadowRadius,
            scale: currentScale,
            rotation3D: currentRotation3D
        )
        
        // Utiliser ImageRenderer (iOS 16+) pour un rendu fiable
        let renderer = ImageRenderer(content: exportView)
        renderer.scale = 1.0  // Échelle 1:1 pour la taille exacte
        renderer.proposedSize = ProposedViewSize(width: exportSize.width, height: exportSize.height)
        
        if let uiImage = renderer.uiImage {
            self.imageToShare = IdentifiableImage(image: uiImage)
        }
        isExporting = false
    }
    
    private func loadImageFromFile(url: URL) {
        // Accéder au fichier en toute sécurité
        guard url.startAccessingSecurityScopedResource() else {
            print("Impossible d'accéder au fichier")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data) {
                screenshot = image
            }
        } catch {
            print("Erreur lors du chargement de l'image: \(error.localizedDescription)")
        }
    }
    
    private func resetAfterExport() {
        screenshot = nil
        captionText = ""
        selectedPhotoItem = nil
        imageToShare = nil
    }
}

// Vue dédiée pour l'export - garantit un rendu complet
struct ExportableView: View {
    let exportSize: CGSize
    let backgroundStyle: BackgroundStyle
    let solidColor: Color
    let gradientColors: [Color]
    let backgroundImage: UIImage?
    let captionText: String
    let captionFontSize: CGFloat
    let captionFontName: String
    let captionColor: Color
    let captionPadding: CGFloat
    let deviceType: DeviceType
    let screenshot: UIImage?
    let shadowEnabled: Bool
    let shadowRadius: CGFloat
    let scale: CGFloat
    let rotation3D: Double
    
    var body: some View {
        ZStack {
            // Fond opaque obligatoire
            backgroundLayer
            
            VStack(spacing: 40) {
                if !captionText.isEmpty {
                    Text(captionText)
                        .font(captionFontName == "System" 
                              ? .system(size: captionFontSize, weight: .bold, design: .rounded) 
                              : .custom(captionFontName, size: captionFontSize))
                        .fontWeight(.bold)
                        .foregroundColor(captionColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, captionPadding * 3)
                        .padding(.top, 100)
                }
                
                Spacer()
                
                ExportDeviceView(
                    deviceType: deviceType,
                    screenshot: screenshot,
                    shadowEnabled: shadowEnabled,
                    shadowRadius: shadowRadius * 2,
                    scale: scale,
                    rotation3D: rotation3D
                )
                
                Spacer()
            }
        }
        .frame(width: exportSize.width, height: exportSize.height)
        .clipped()
    }
    
    @ViewBuilder
    private var backgroundLayer: some View {
        switch backgroundStyle {
        case .solid:
            solidColor
        case .gradient, .mesh:
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        case .image:
            if let bgImage = backgroundImage {
                Image(uiImage: bgImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: exportSize.width, height: exportSize.height)
                    .clipped()
            } else {
                Color.gray
            }
        }
    }
}

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

struct ExportDeviceView: View {
    let deviceType: DeviceType
    let screenshot: UIImage?
    let shadowEnabled: Bool
    let shadowRadius: CGFloat
    let scale: CGFloat
    let rotation3D: Double
    
    private var frameWidth: CGFloat { 630 }
    private var frameThickness: CGFloat { 18 }
    private var frameHeight: CGFloat { frameWidth * deviceType.aspectRatio }
    private var screenWidth: CGFloat { frameWidth - deviceType.bezelWidth * 2 }
    private var screenHeight: CGFloat { frameHeight - deviceType.bezelWidth * 2 }
    
    var body: some View {
        ZStack {
            // Couche 1 : Contour extérieur métallique
            RoundedRectangle(cornerRadius: deviceType.cornerRadius + 6)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.45),
                            Color(white: 0.25),
                            Color(white: 0.35),
                            Color(white: 0.20)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: frameWidth + frameThickness, height: frameHeight + frameThickness)
            
            // Couche 2 : Deuxième niveau du contour
            RoundedRectangle(cornerRadius: deviceType.cornerRadius + 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.30),
                            Color(white: 0.15),
                            Color(white: 0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: frameWidth + 10, height: frameHeight + 10)
            
            // Couche 3 : Cadre principal
            RoundedRectangle(cornerRadius: deviceType.cornerRadius + 2)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(white: 0.18),
                            Color(white: 0.08),
                            Color(white: 0.12)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: frameWidth + 5, height: frameHeight + 5)
            
            // Cadre intérieur noir
            RoundedRectangle(cornerRadius: deviceType.cornerRadius)
                .fill(Color(white: 0.05))
                .frame(width: frameWidth, height: frameHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: deviceType.cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            
            // Bezel autour de l'écran
            RoundedRectangle(cornerRadius: deviceType.cornerRadius - 6)
                .fill(Color.black)
                .frame(width: screenWidth + 4, height: screenHeight + 4)
            
            // Écran
            RoundedRectangle(cornerRadius: deviceType.cornerRadius - 8)
                .fill(Color.black)
                .frame(width: screenWidth, height: screenHeight)
            
            if let screenshot = screenshot {
                Image(uiImage: screenshot)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth, height: screenHeight)
                    .clipShape(RoundedRectangle(cornerRadius: deviceType.cornerRadius - 8))
            }
            
            // Dynamic Island pour iPhone 15 Pro
            if deviceType == .iPhone15Pro {
                ExportDynamicIslandView()
                    .offset(y: -frameHeight / 2 + 68)
            }
            
            // Encoche pour iPhone 15
            if deviceType == .iPhone15 {
                Capsule().fill(Color.black).frame(width: 160, height: 43).offset(y: -frameHeight / 2 + 55)
            }
            
            // Home indicator
            if deviceType == .iPhone15Pro || deviceType == .iPhone15 {
                Capsule().fill(Color.white.opacity(0.25)).frame(width: 170, height: 6).offset(y: frameHeight / 2 - 30)
            }
            
            // Boutons latéraux pour iPhone
            if deviceType == .iPhone15Pro || deviceType == .iPhone15 {
                // Bouton Power (côté droit)
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(white: 0.50),
                                Color(white: 0.30),
                                Color(white: 0.40)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 6, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                    .offset(x: frameWidth / 2 + frameThickness / 2 + 2, y: -60)
                
                // Boutons Volume (côté gauche)
                VStack(spacing: 15) {
                    // Action button / Mute
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(white: 0.40),
                                    Color(white: 0.30),
                                    Color(white: 0.50)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 6, height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                    
                    // Volume +
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(white: 0.40),
                                    Color(white: 0.30),
                                    Color(white: 0.50)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 6, height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                    
                    // Volume -
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(white: 0.40),
                                    Color(white: 0.30),
                                    Color(white: 0.50)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 6, height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                }
                .offset(x: -frameWidth / 2 - frameThickness / 2 - 2, y: -85)
            }
        }
        .rotation3DEffect(
            .degrees(rotation3D),
            axis: (x: 0, y: 1, z: 0),
            anchor: .center,
            anchorZ: 0,
            perspective: 0.5
        )
        .shadow(
            color: shadowEnabled ? .black.opacity(0.5) : .clear,
            radius: shadowRadius,
            x: rotation3D * 0.5,
            y: shadowRadius / 3
        )
        .scaleEffect(max(0.1, scale))
    }
}

// Dynamic Island for export
struct ExportDynamicIslandView: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.black)
                .frame(width: 160, height: 48)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.05, green: 0.05, blue: 0.1)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 10
                    )
                )
                .frame(width: 18, height: 18)
                .overlay(
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .offset(x: -1, y: -1)
                )
                .offset(x: 50)
        }
    }
}

#Preview {
    MockupEditorView()
}
