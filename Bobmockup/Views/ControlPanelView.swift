//
//  ControlPanelView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//

import SwiftUI
import PhotosUI

struct ControlPanelView: View {
    @Binding var selectedDevice: DeviceType
    @Binding var backgroundStyle: BackgroundStyle
    @Binding var solidColor: Color
    @Binding var gradientColors: [Color]
    @Binding var backgroundImage: UIImage?
    @Binding var shadowEnabled: Bool
    @Binding var shadowRadius: CGFloat
    @Binding var rotation3D: Double
    @Binding var scale: CGFloat
    @Binding var captionText: String
    @Binding var captionColor: Color
    @Binding var captionFontSize: CGFloat
    @Binding var captionFontName: String
    @Binding var captionPadding: CGFloat
    
    @State private var showDevicePicker = false
    @State private var showColorPicker = false
    @State private var selectedBackgroundPhotoItem: PhotosPickerItem?
    @State private var selectedTab: ControlTab = .device
    
    enum ControlTab: String, CaseIterable {
        case device = "Appareil"
        case background = "Fond"
        case text = "Texte"
        case effects = "Effets"
        
        var icon: String {
            switch self {
            case .device: return "iphone"
            case .background: return "paintpalette"
            case .text: return "textformat"
            case .effects: return "wand.and.stars"
            }
        }
        
        var gradient: [Color] {
            switch self {
            case .device: return [.blue, .cyan]
            case .background: return [.purple, .pink]
            case .text: return [.orange, .yellow]
            case .effects: return [.green, .mint]
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar personnalisée
            HStack(spacing: 8) {
                ForEach(ControlTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(
                                        selectedTab == tab
                                        ? LinearGradient(colors: tab.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : LinearGradient(colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: tab.icon)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(selectedTab == tab ? .white : .secondary)
                            }
                            
                            Text(tab.rawValue)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == tab ? .primary : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider()
                .padding(.horizontal)
            
            // Contenu de l'onglet
            ScrollView {
                VStack(spacing: 24) {
                    switch selectedTab {
                    case .device:
                        DeviceTabContent(selectedDevice: $selectedDevice)
                    case .background:
                        BackgroundTabContent(
                            backgroundStyle: $backgroundStyle,
                            solidColor: $solidColor,
                            gradientColors: $gradientColors,
                            backgroundImage: $backgroundImage,
                            selectedPhotoItem: $selectedBackgroundPhotoItem
                        )
                    case .text:
                        TextTabContent(
                            captionText: $captionText,
                            captionColor: $captionColor,
                            captionFontSize: $captionFontSize,
                            captionFontName: $captionFontName,
                            captionPadding: $captionPadding
                        )
                    case .effects:
                        EffectsTabContent(
                            shadowEnabled: $shadowEnabled,
                            shadowRadius: $shadowRadius,
                            rotation3D: $rotation3D,
                            scale: $scale
                        )
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
            }
        }
    }
}

// MARK: - Device Tab
struct DeviceTabContent: View {
    @Binding var selectedDevice: DeviceType
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choisissez votre appareil")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(DeviceType.allCases) { device in
                    DeviceButton(
                        device: device,
                        isSelected: selectedDevice == device
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDevice = device
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Background Tab
struct BackgroundTabContent: View {
    @Binding var backgroundStyle: BackgroundStyle
    @Binding var solidColor: Color
    @Binding var gradientColors: [Color]
    @Binding var backgroundImage: UIImage?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Style selector
            VStack(alignment: .leading, spacing: 12) {
                Text("Type d'arrière-plan")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Style", selection: $backgroundStyle) {
                    ForEach(BackgroundStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Content based on style
            Group {
                switch backgroundStyle {
                case .solid:
                    SolidColorPicker(selectedColor: $solidColor)
                case .image:
                    BackgroundImagePicker(
                        backgroundImage: $backgroundImage,
                        selectedPhotoItem: $selectedPhotoItem
                    )
                default:
                    GradientPicker(selectedColors: $gradientColors)
                }
            }
        }
    }
}

// MARK: - Text Tab
struct TextTabContent: View {
    @Binding var captionText: String
    @Binding var captionColor: Color
    @Binding var captionFontSize: CGFloat
    @Binding var captionFontName: String
    @Binding var captionPadding: CGFloat
    @FocusState private var isTextFieldFocused: Bool
    
    private let availableFonts: [(name: String, displayName: String)] = [
        ("System", "Système"),
        ("Arial", "Arial"),
        ("Helvetica Neue", "Helvetica"),
        ("Avenir-Heavy", "Avenir"),
        ("Georgia", "Georgia"),
        ("Futura-Bold", "Futura"),
        ("Didot", "Didot"),
        ("Baskerville", "Baskerville"),
        ("Copperplate", "Copperplate"),
        ("Marker Felt", "Marker Felt"),
        ("Noteworthy-Bold", "Noteworthy"),
        ("Papyrus", "Papyrus")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Text input
            VStack(alignment: .leading, spacing: 8) {
                Text("Votre texte")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 10) {
                    TextField("Entrez votre texte...", text: $captionText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3)
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isTextFieldFocused = false
                        }
                    
                    Button {
                        isTextFieldFocused = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    } label: {
                        Text("OK")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .clipShape(Capsule())
                    }
                }
            }
            
            // Font - Menu déroulant
            VStack(alignment: .leading, spacing: 8) {
                Text("Police")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Menu {
                    ForEach(availableFonts, id: \.name) { font in
                        Button {
                            captionFontName = font.name
                        } label: {
                            HStack {
                                Text(font.displayName)
                                    .font(font.name == "System" ? .body : .custom(font.name, size: 17))
                                if captionFontName == font.name {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(availableFonts.first(where: { $0.name == captionFontName })?.displayName ?? "Système")
                            .font(captionFontName == "System" ? .body : .custom(captionFontName, size: 17))
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                }
                .foregroundColor(.primary)
            }
            
            // Color
            HStack {
                Text("Couleur du texte")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                ColorPicker("", selection: $captionColor)
                    .labelsHidden()
            }
            
            // Size
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Taille")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(captionFontSize)) pt")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                Slider(value: $captionFontSize, in: 24...80, step: 2)
                    .tint(.blue)
            }
            
            // Padding
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Marge")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(captionPadding))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                Slider(value: $captionPadding, in: 10...100, step: 5)
                    .tint(.blue)
            }
        }
    }
}

// MARK: - Effects Tab
struct EffectsTabContent: View {
    @Binding var shadowEnabled: Bool
    @Binding var shadowRadius: CGFloat
    @Binding var rotation3D: Double
    @Binding var scale: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Shadow section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Ombre", systemImage: "shadow")
                        .font(.headline)
                    Spacer()
                    Toggle("", isOn: $shadowEnabled)
                        .labelsHidden()
                }
                
                if shadowEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Intensité")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(Int(shadowRadius))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        Slider(value: $shadowRadius, in: 5...60, step: 1)
                            .tint(.blue)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5)
            )
            
            // 3D Rotation
            VStack(alignment: .leading, spacing: 12) {
                Label("Rotation 3D", systemImage: "rotate.3d")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Angle")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(rotation3D))°")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.purple)
                    }
                    Slider(value: $rotation3D, in: -30...30, step: 1)
                        .tint(.purple)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5)
            )
            
            // Scale
            VStack(alignment: .leading, spacing: 12) {
                Label("Échelle", systemImage: "arrow.up.left.and.arrow.down.right")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Taille")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(scale * 100))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    Slider(value: $scale, in: 0.5...1.0, step: 0.05)
                        .tint(.orange)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5)
            )
        }
    }
}

struct DeviceButton: View {
    let device: DeviceType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: device.icon)
                    .font(.title2)
                Text(device.rawValue)
                    .font(.caption2)
                    .lineLimit(1)
            }
            .frame(width: 80, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .foregroundColor(isSelected ? .blue : .primary)
    }
}

struct SolidColorPicker: View {
    @Binding var selectedColor: Color
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(ColorPreset.presets) { preset in
                Circle()
                    .fill(preset.color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: selectedColor == preset.color ? 3 : 0)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .onTapGesture {
                        withAnimation {
                            selectedColor = preset.color
                        }
                    }
            }
            
            ColorPicker("", selection: $selectedColor)
                .labelsHidden()
                .frame(width: 40, height: 40)
        }
    }
}

struct GradientPicker: View {
    @Binding var selectedColors: [Color]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(GradientPreset.presets) { preset in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: preset.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedColors == preset.colors ? Color.white : Color.clear,
                                    lineWidth: 3
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            withAnimation {
                                selectedColors = preset.colors
                            }
                        }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct BackgroundImagePicker: View {
    @Binding var backgroundImage: UIImage?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 12) {
            if let image = backgroundImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Button {
                        withAnimation {
                            backgroundImage = nil
                            selectedPhotoItem = nil
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, .red)
                    }
                    .padding(8)
                }
            }
            
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text(backgroundImage == nil ? "Choisir une image" : "Changer l'image")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .onChange(of: selectedPhotoItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            backgroundImage = image
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ControlPanelView(
        selectedDevice: .constant(.iPhone15Pro),
        backgroundStyle: .constant(.gradient),
        solidColor: .constant(.white),
        gradientColors: .constant([.purple, .pink]),
        backgroundImage: .constant(nil),
        shadowEnabled: .constant(true),
        shadowRadius: .constant(30),
        rotation3D: .constant(0),
        scale: .constant(0.8),
        captionText: .constant("Mon App"),
        captionColor: .constant(.white),
        captionFontSize: .constant(48),
        captionFontName: .constant("System"),
        captionPadding: .constant(20)
    )
}
