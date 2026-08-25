//
//  DeviceFrameView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//  Refactorisé le 06/02/2026 — Design premium + couleurs + barre de statut
//

import SwiftUI

// MARK: - Device Frame View

struct DeviceFrameView: View {
    let deviceType: DeviceType
    let screenshot: UIImage?
    let shadowEnabled: Bool
    let shadowRadius: CGFloat
    var rotation3D: Double = 0
    var deviceColor: DeviceColor = .naturalTitanium
    var showStatusBar: Bool = false
    
    var baseWidth: CGFloat = 510
    var frameThickness: CGFloat = 12
    
    // MARK: - Computed
    
    /// Primitive de rendu appelée pendant des passes de layout où la
    /// géométrie n'est pas encore connue. Une largeur nulle, négative ou non
    /// finie produirait des dimensions de cadre invalides.
    private var w: CGFloat {
        guard baseWidth.isFinite, baseWidth > 0 else { return 1 }
        return baseWidth
    }
    
    private var frameHeight: CGFloat { w * deviceType.aspectRatio }
    private var bw: CGFloat { deviceType.bezelWidth * r }
    private var screenWidth: CGFloat { w - bw * 2 }
    private var screenHeight: CGFloat { frameHeight - bw * 2 }
    private var r: CGFloat { w / 510.0 }
    private var cr: CGFloat { deviceType.cornerRadius * r }
    
    var body: some View {
        ZStack {
            switch deviceType {
            case .iPhone15Pro: iPhoneProBody
            case .iPhone15: iPhoneBody
            case .iPadPro: iPadBody
            case .macBookPro: macBookBody
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
            color: shadowEnabled ? .black.opacity(0.45) : .clear,
            radius: shadowRadius,
            x: rotation3D * 0.5,
            y: shadowRadius / 3
        )
    }
    
    // MARK: - iPhone 15 Pro
    
    private var iPhoneProBody: some View {
        ZStack {
            // Contour titane
            RoundedRectangle(cornerRadius: cr + 5 * r)
                .fill(
                    LinearGradient(
                        stops: deviceColor.frameGradientStops,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: w + frameThickness, height: frameHeight + frameThickness)
            
            // Reflet bord
            RoundedRectangle(cornerRadius: cr + 5 * r)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.45),
                            Color.white.opacity(0.08),
                            Color.clear,
                            Color.white.opacity(0.05),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5 * r
                )
                .frame(width: w + frameThickness, height: frameHeight + frameThickness)
            
            // Chanfrein
            RoundedRectangle(cornerRadius: cr + 2 * r)
                .fill(
                    LinearGradient(
                        colors: [Color(white: 0.22), Color(white: 0.10), Color(white: 0.16)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: w + 4 * r, height: frameHeight + 4 * r)
            
            // Corps
            RoundedRectangle(cornerRadius: cr)
                .fill(Color(white: 0.04))
                .frame(width: w, height: frameHeight)
            
            RoundedRectangle(cornerRadius: cr)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), Color.white.opacity(0.03), Color.white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
                .frame(width: w, height: frameHeight)
            
            screenContent
            
            // Status bar
            if showStatusBar {
                StatusBarOverlay(sizeRatio: r, screenWidth: screenWidth)
                    .offset(y: -screenHeight / 2 + 14 * r)
            }
            
            dynamicIslandPro.offset(y: -frameHeight / 2 + 50 * r)
            homeIndicator
            proSideButtons
            screenGlare
        }
    }
    
    // MARK: - iPhone 15
    
    private var iPhoneBody: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cr + 5 * r)
                .fill(
                    LinearGradient(
                        stops: deviceColor.frameGradientStops,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: w + frameThickness, height: frameHeight + frameThickness)
            
            RoundedRectangle(cornerRadius: cr + 5 * r)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.25), Color.white.opacity(0.05), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2 * r
                )
                .frame(width: w + frameThickness, height: frameHeight + frameThickness)
            
            RoundedRectangle(cornerRadius: cr + 2 * r)
                .fill(Color(white: 0.08))
                .frame(width: w + 4 * r, height: frameHeight + 4 * r)
            
            RoundedRectangle(cornerRadius: cr)
                .fill(Color(white: 0.04))
                .frame(width: w, height: frameHeight)
            
            RoundedRectangle(cornerRadius: cr)
                .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                .frame(width: w, height: frameHeight)
            
            screenContent
            
            if showStatusBar {
                StatusBarOverlay(sizeRatio: r, screenWidth: screenWidth)
                    .offset(y: -screenHeight / 2 + 14 * r)
            }
            
            notch.offset(y: -frameHeight / 2 + 42 * r)
            homeIndicator
            standardSideButtons
            screenGlare
        }
    }
    
    // MARK: - iPad Pro
    
    private var iPadBody: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cr + 4 * r)
                .fill(
                    LinearGradient(
                        stops: deviceColor.frameGradientStops,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: w + frameThickness, height: frameHeight + frameThickness)
            
            RoundedRectangle(cornerRadius: cr + 4 * r)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                .frame(width: w + frameThickness, height: frameHeight + frameThickness)
            
            RoundedRectangle(cornerRadius: cr)
                .fill(Color(white: 0.03))
                .frame(width: w, height: frameHeight)
            
            screenContent
            screenGlare
        }
    }
    
    // MARK: - MacBook Pro
    
    private var macBookBody: some View {
        let macGradient = deviceColor.frameGradientStops
        return ZStack {
            RoundedRectangle(cornerRadius: cr + 4 * r)
                .fill(
                    LinearGradient(stops: macGradient, startPoint: .top, endPoint: .bottom)
                )
                .frame(width: w + frameThickness, height: frameHeight + frameThickness)
            
            RoundedRectangle(cornerRadius: cr + 4 * r)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.8)
                .frame(width: w + frameThickness, height: frameHeight + frameThickness)
            
            RoundedRectangle(cornerRadius: cr)
                .fill(Color(white: 0.03))
                .frame(width: w, height: frameHeight)
            
            screenContent
            screenGlare
            
            // Webcam
            Circle()
                .fill(Color(white: 0.12))
                .frame(width: 8 * r, height: 8 * r)
                .overlay(
                    Circle().fill(Color(white: 0.06)).frame(width: 4 * r, height: 4 * r)
                )
                .offset(y: -frameHeight / 2 + 10 * r)
            
            MacBookBaseView(frameWidth: w, sizeRatio: r, deviceColor: deviceColor)
                .offset(y: frameHeight / 2 + 15 * r)
        }
    }
    
    // MARK: - Screen Content
    
    private var screenContent: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cr - 8 * r)
                .fill(Color.black)
                .frame(width: screenWidth, height: screenHeight)
            
            if let screenshot = screenshot {
                Image(uiImage: screenshot)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth, height: screenHeight)
                    .clipShape(RoundedRectangle(cornerRadius: cr - 8 * r))
            } else {
                Color.clear
                    .frame(width: screenWidth, height: screenHeight)
                    .overlay(
                        VStack(spacing: 14 * r) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.06))
                                    .frame(width: 90 * r, height: 90 * r)
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 36 * r, weight: .light))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                            Text("Ajouter une capture")
                                .font(.system(size: 15 * r, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    )
            }
        }
    }
    
    // MARK: - Screen Glare
    
    private var screenGlare: some View {
        RoundedRectangle(cornerRadius: cr - 8 * r)
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.white.opacity(0.08), location: 0),
                        .init(color: Color.white.opacity(0.02), location: 0.3),
                        .init(color: Color.clear, location: 0.5),
                        .init(color: Color.clear, location: 1),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: screenWidth, height: screenHeight)
            .allowsHitTesting(false)
    }
    
    // MARK: - Dynamic Island
    
    private var dynamicIslandPro: some View {
        ZStack {
            Capsule().fill(Color.black)
                .frame(width: 126 * r, height: 37 * r)
            Capsule().stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                .frame(width: 126 * r, height: 37 * r)
            Capsule().fill(
                LinearGradient(colors: [Color.white.opacity(0.04), Color.clear], startPoint: .top, endPoint: .bottom)
            ).frame(width: 126 * r, height: 37 * r).clipShape(Capsule())
            
            HStack(spacing: 0) {
                Spacer()
                ZStack {
                    Circle().fill(Color(white: 0.08)).frame(width: 16 * r, height: 16 * r)
                    Circle().fill(
                        RadialGradient(
                            colors: [Color(red: 0.08, green: 0.08, blue: 0.18), Color(red: 0.04, green: 0.04, blue: 0.10)],
                            center: .center, startRadius: 0, endRadius: 6 * r
                        )
                    ).frame(width: 12 * r, height: 12 * r)
                    Circle().fill(Color.white.opacity(0.12)).frame(width: 4 * r, height: 4 * r)
                        .offset(x: -1.5 * r, y: -1.5 * r)
                    Circle().fill(Color.blue.opacity(0.25)).frame(width: 2.5 * r, height: 2.5 * r)
                        .offset(x: 2 * r, y: 2 * r)
                }
                .offset(x: -14 * r)
            }
            .frame(width: 126 * r)
        }
    }
    
    // MARK: - Notch
    
    private var notch: some View {
        ZStack {
            Capsule().fill(Color.black).frame(width: 125 * r, height: 34 * r)
            Capsule().stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                .frame(width: 125 * r, height: 34 * r)
            
            Circle().fill(Color(white: 0.07)).frame(width: 14 * r, height: 14 * r)
                .overlay(
                    Circle().fill(
                        RadialGradient(colors: [Color(red: 0.06, green: 0.06, blue: 0.14), Color(red: 0.03, green: 0.03, blue: 0.08)],
                                       center: .center, startRadius: 0, endRadius: 5 * r)
                    ).frame(width: 10 * r, height: 10 * r)
                )
                .overlay(
                    Circle().fill(Color.white.opacity(0.12)).frame(width: 3 * r, height: 3 * r)
                        .offset(x: -1 * r, y: -1 * r)
                )
                .offset(x: 28 * r)
            
            Capsule().fill(Color(white: 0.10)).frame(width: 30 * r, height: 5 * r)
                .offset(x: -10 * r)
        }
    }
    
    // MARK: - Home Indicator
    
    private var homeIndicator: some View {
        Group {
            if deviceType == .iPhone15Pro || deviceType == .iPhone15 {
                Capsule()
                    .fill(Color.white.opacity(0.22))
                    .frame(width: 135 * r, height: 5 * r)
                    .offset(y: frameHeight / 2 - 22 * r)
            }
        }
    }
    
    // MARK: - Side Buttons (Pro)
    
    private var proSideButtons: some View {
        let btnColors = deviceColor.buttonGradientColors
        return ZStack {
            sideButton(width: 4.5 * r, height: 30 * r, colors: btnColors)
                .offset(x: -w / 2 - frameThickness / 2 - 1, y: -125 * r)
            sideButton(width: 4.5 * r, height: 52 * r, colors: btnColors)
                .offset(x: -w / 2 - frameThickness / 2 - 1, y: -60 * r)
            sideButton(width: 4.5 * r, height: 52 * r, colors: btnColors)
                .offset(x: -w / 2 - frameThickness / 2 - 1, y: 8 * r)
            sideButton(width: 4.5 * r, height: 75 * r, colors: btnColors)
                .offset(x: w / 2 + frameThickness / 2 + 1, y: -50 * r)
        }
    }
    
    // MARK: - Side Buttons (Standard)
    
    private var standardSideButtons: some View {
        let btnColors = deviceColor.buttonGradientColors
        return ZStack {
            sideButton(width: 4 * r, height: 28 * r, colors: btnColors)
                .offset(x: -w / 2 - frameThickness / 2 - 1, y: -125 * r)
            sideButton(width: 4 * r, height: 50 * r, colors: btnColors)
                .offset(x: -w / 2 - frameThickness / 2 - 1, y: -60 * r)
            sideButton(width: 4 * r, height: 50 * r, colors: btnColors)
                .offset(x: -w / 2 - frameThickness / 2 - 1, y: 8 * r)
            sideButton(width: 4 * r, height: 70 * r, colors: btnColors)
                .offset(x: w / 2 + frameThickness / 2 + 1, y: -50 * r)
        }
    }
    
    private func sideButton(width: CGFloat, height: CGFloat, colors: [Color]) -> some View {
        RoundedRectangle(cornerRadius: 2.5 * r)
            .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 2.5 * r)
                    .stroke(
                        LinearGradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.08)],
                                       startPoint: .top, endPoint: .bottom),
                        lineWidth: 0.5
                    )
            )
    }
}

// MARK: - Status Bar Overlay

struct StatusBarOverlay: View {
    let sizeRatio: CGFloat
    let screenWidth: CGFloat
    
    var body: some View {
        HStack {
            // Heure
            Text("9:41")
                .font(.system(size: 14 * sizeRatio, weight: .semibold))
                .foregroundColor(.white)
            
            Spacer()
            
            // Icônes droite
            HStack(spacing: 5 * sizeRatio) {
                // Signal cellulaire
                Image(systemName: "cellularbars")
                    .font(.system(size: 12 * sizeRatio, weight: .medium))
                
                // WiFi
                Image(systemName: "wifi")
                    .font(.system(size: 12 * sizeRatio, weight: .medium))
                
                // Batterie
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2 * sizeRatio)
                        .stroke(Color.white, lineWidth: 0.8)
                        .frame(width: 22 * sizeRatio, height: 10 * sizeRatio)
                    
                    RoundedRectangle(cornerRadius: 1.5 * sizeRatio)
                        .fill(Color.white)
                        .frame(width: 18 * sizeRatio, height: 7 * sizeRatio)
                        .offset(x: 1.5 * sizeRatio)
                    
                    // Terminaison batterie
                    RoundedRectangle(cornerRadius: 0.5 * sizeRatio)
                        .fill(Color.white)
                        .frame(width: 1.5 * sizeRatio, height: 4 * sizeRatio)
                        .offset(x: 22.5 * sizeRatio)
                }
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 28 * sizeRatio)
        .frame(width: screenWidth)
        .allowsHitTesting(false)
    }
}

// MARK: - Export Device View

struct ExportDeviceView: View {
    let deviceType: DeviceType
    let screenshot: UIImage?
    let shadowEnabled: Bool
    let shadowRadius: CGFloat
    let scale: CGFloat
    let rotation3D: Double
    var deviceColor: DeviceColor = .naturalTitanium
    var showStatusBar: Bool = false
    
    var body: some View {
        DeviceFrameView(
            deviceType: deviceType,
            screenshot: screenshot,
            shadowEnabled: shadowEnabled,
            shadowRadius: shadowRadius,
            rotation3D: rotation3D,
            deviceColor: deviceColor,
            showStatusBar: showStatusBar,
            baseWidth: 630,
            frameThickness: 15
        )
        .scaleEffect(max(0.1, scale))
    }
}

// MARK: - MacBook Base

struct MacBookBaseView: View {
    let frameWidth: CGFloat
    var sizeRatio: CGFloat = 1.0
    var deviceColor: DeviceColor = .silver
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        stops: deviceColor.frameGradientStops,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: frameWidth * 1.1, height: 25 * sizeRatio)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                .frame(width: frameWidth * 1.1, height: 25 * sizeRatio)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(white: 0.55))
                .frame(width: 80 * sizeRatio, height: 6 * sizeRatio)
                .offset(y: -4 * sizeRatio)
        }
    }
}

// MARK: - Badge Overlay

struct BadgeOverlayView: View {
    let badges: [MockupBadge]
    let scaleFactor: CGFloat
    var badgeScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ForEach(badges) { badge in
                badgeView(badge)
            }
        }
    }
    
    private func badgeView(_ badge: MockupBadge) -> some View {
        let s = scaleFactor * badgeScale
        return Text(badge.text)
            .font(.system(size: 14 * s, weight: .bold, design: .rounded))
            .foregroundColor(badge.style.textColor)
            .padding(.horizontal, 12 * s)
            .padding(.vertical, 6 * s)
            .background(
                Capsule()
                    .fill(badge.style.backgroundColor)
                    .shadow(color: .black.opacity(0.3), radius: 4 * badgeScale, x: 0, y: 2 * badgeScale)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: badge.position.alignment)
            .padding(20 * scaleFactor)
    }
}

// MARK: - Previews

#Preview("iPhone 15 Pro — Titane Naturel") {
    DeviceFrameView(
        deviceType: .iPhone15Pro,
        screenshot: nil,
        shadowEnabled: true,
        shadowRadius: 30,
        deviceColor: .naturalTitanium,
        showStatusBar: true
    )
    .scaleEffect(0.5)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(LinearGradient(colors: [.purple, .pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("iPhone 15 Pro — Titane Bleu") {
    DeviceFrameView(
        deviceType: .iPhone15Pro,
        screenshot: nil,
        shadowEnabled: true,
        shadowRadius: 30,
        deviceColor: .blueTitanium,
        showStatusBar: true
    )
    .scaleEffect(0.5)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(LinearGradient(colors: [.cyan, .blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
}

#Preview("iPhone 15 — Rose") {
    DeviceFrameView(
        deviceType: .iPhone15,
        screenshot: nil,
        shadowEnabled: true,
        shadowRadius: 30,
        deviceColor: .pink
    )
    .scaleEffect(0.5)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(LinearGradient(colors: [.pink, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
}
