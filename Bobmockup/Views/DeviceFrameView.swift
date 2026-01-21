//
//  DeviceFrameView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//

import SwiftUI

struct DeviceFrameView: View {
    let deviceType: DeviceType
    let screenshot: UIImage?
    let shadowEnabled: Bool
    let shadowRadius: CGFloat
    var rotation3D: Double = 0
    
    private let frameWidth: CGFloat = 510
    private let frameThickness: CGFloat = 14 // Épaisseur du contour
    
    private var frameHeight: CGFloat {
        frameWidth * deviceType.aspectRatio
    }
    
    private var screenWidth: CGFloat {
        frameWidth - deviceType.bezelWidth * 2
    }
    
    private var screenHeight: CGFloat {
        frameHeight - deviceType.bezelWidth * 2
    }
    
    var body: some View {
        ZStack {
            // Couche 1 : Contour extérieur métallique (le plus large)
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
                .frame(width: frameWidth + 8, height: frameHeight + 8)
            
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
                .frame(width: frameWidth + 4, height: frameHeight + 4)
            
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
            
            // Screenshot
            if let screenshot = screenshot {
                Image(uiImage: screenshot)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth, height: screenHeight)
                    .clipShape(RoundedRectangle(cornerRadius: deviceType.cornerRadius - 8))
            } else {
                Color.clear
                    .frame(width: screenWidth, height: screenHeight)
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.4))
                            Text("Ajouter une capture")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    )
            }
            
            // Dynamic Island pour iPhone 15 Pro
            if deviceType == .iPhone15Pro {
                DynamicIslandView()
                    .offset(y: -frameHeight / 2 + 55)
            }
            
            // Encoche pour iPhone 15
            if deviceType == .iPhone15 {
                Capsule()
                    .fill(Color.black)
                    .frame(width: 130, height: 35)
                    .offset(y: -frameHeight / 2 + 45)
            }
            
            // Home indicator
            if deviceType == .iPhone15Pro || deviceType == .iPhone15 {
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 140, height: 5)
                    .offset(y: frameHeight / 2 - 25)
            }
            
            // Boutons latéraux pour iPhone
            if deviceType == .iPhone15Pro || deviceType == .iPhone15 {
                // Bouton Power (côté droit)
                RoundedRectangle(cornerRadius: 3)
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
                    .frame(width: 5, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                    )
                    .offset(x: frameWidth / 2 + frameThickness / 2 + 2, y: -50)
                
                // Boutons Volume (côté gauche)
                VStack(spacing: 12) {
                    // Action button / Mute
                    RoundedRectangle(cornerRadius: 3)
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
                        .frame(width: 5, height: 35)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                    
                    // Volume +
                    RoundedRectangle(cornerRadius: 3)
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
                        .frame(width: 5, height: 55)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                    
                    // Volume -
                    RoundedRectangle(cornerRadius: 3)
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
                        .frame(width: 5, height: 55)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        )
                }
                .offset(x: -frameWidth / 2 - frameThickness / 2 - 2, y: -70)
            }
            
            // MacBook keyboard base
            if deviceType == .macBookPro {
                MacBookBaseView(frameWidth: frameWidth)
                    .offset(y: frameHeight / 2 + 15)
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
    }
}

// Dynamic Island
struct DynamicIslandView: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.black)
                .frame(width: 130, height: 38)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.1, green: 0.1, blue: 0.2),
                            Color(red: 0.05, green: 0.05, blue: 0.1)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 8
                    )
                )
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 6, height: 6)
                        .offset(x: -1, y: -1)
                )
                .offset(x: 40)
        }
    }
}

struct MacBookBaseView: View {
    let frameWidth: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.78, blue: 0.8),
                            Color(red: 0.7, green: 0.7, blue: 0.72)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: frameWidth * 1.1, height: 25)
            
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: 80, height: 8)
                .offset(y: 5)
        }
    }
}

#Preview {
    VStack {
        DeviceFrameView(
            deviceType: .iPhone15Pro,
            screenshot: nil,
            shadowEnabled: true,
            shadowRadius: 30,
            rotation3D: 0
        )
        .scaleEffect(0.5)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(
        LinearGradient(
            colors: [.purple, .pink, .orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
