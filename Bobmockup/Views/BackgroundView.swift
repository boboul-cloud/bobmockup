//
//  BackgroundView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//

import SwiftUI

struct BackgroundView: View {
    let style: BackgroundStyle
    let solidColor: Color
    let gradientColors: [Color]
    var backgroundImage: UIImage? = nil
    
    var body: some View {
        switch style {
        case .solid:
            solidColor
        case .gradient:
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .mesh:
            MeshGradientView(colors: gradientColors)
        case .image:
            if let image = backgroundImage {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            } else {
                Color.gray.opacity(0.3)
            }
        }
    }
}

struct MeshGradientView: View {
    let colors: [Color]
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(colors[index % colors.count].opacity(0.7))
                        .frame(
                            width: geometry.size.width * 0.8,
                            height: geometry.size.width * 0.8
                        )
                        .blur(radius: 80)
                        .offset(
                            x: CGFloat.random(in: -100...100) + (animate ? 20 : -20),
                            y: CGFloat.random(in: -200...200) + (animate ? -30 : 30)
                        )
                        .animation(
                            .easeInOut(duration: 4)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.5),
                            value: animate
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colors.first?.opacity(0.3) ?? .white)
            .onAppear {
                animate = true
            }
        }
    }
}

#Preview {
    BackgroundView(
        style: .gradient,
        solidColor: .blue,
        gradientColors: [.purple, .pink, .orange],
        backgroundImage: nil
    )
}
