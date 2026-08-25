//
//  BackgroundView.swift
//  Bobmockup
//
//  Le fond du visuel — jamais celui de l'interface.
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
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
        case .mesh:
            MeshGradientView(colors: gradientColors)
        case .image:
            if let image = backgroundImage {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
            } else {
                gradientColors.first ?? Color.gray
            }
        }
    }
}

struct MeshGradientView: View {
    let colors: [Color]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false
    @State private var offsets: [CGPoint] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<offsets.count, id: \.self) { index in
                    Circle()
                        .fill(colors[index % colors.count].opacity(0.7))
                        .frame(width: geo.size.width * 0.8, height: geo.size.width * 0.8)
                        .blur(radius: 80)
                        .offset(x: offsets[index].x + (animate ? 20 : -20),
                                y: offsets[index].y + (animate ? -30 : 30))
                        .animation(reduceMotion ? nil
                                   : .easeInOut(duration: 4).repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.5),
                                   value: animate)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colors.first?.opacity(0.3) ?? .white)
            .onAppear {
                if offsets.isEmpty {
                    offsets = (0..<5).map { _ in
                        CGPoint(x: .random(in: -100...100), y: .random(in: -200...200))
                    }
                }
                animate = true
            }
        }
    }
}

#Preview {
    BackgroundView(style: .gradient,
                   solidColor: .white,
                   gradientColors: GradientPreset.presets[0].colors)
}
