//
//  BackgroundStyle.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//

import SwiftUI

enum BackgroundStyle: String, CaseIterable, Identifiable {
    case solid = "Couleur unie"
    case gradient = "Dégradé"
    case mesh = "Mesh"
    case image = "Image"
    
    var id: String { rawValue }
}

struct GradientPreset: Identifiable {
    let id = UUID()
    let name: String
    let colors: [Color]
    
    static let presets: [GradientPreset] = [
        GradientPreset(name: "Sunset", colors: [.orange, .pink, .purple]),
        GradientPreset(name: "Ocean", colors: [.cyan, .blue, .indigo]),
        GradientPreset(name: "Forest", colors: [.green, .mint, .teal]),
        GradientPreset(name: "Fire", colors: [.red, .orange, .yellow]),
        GradientPreset(name: "Night", colors: [.purple, .indigo, .black]),
        GradientPreset(name: "Cotton Candy", colors: [.pink, .purple, .blue]),
        GradientPreset(name: "Mint", colors: [.mint, .teal, .cyan]),
        GradientPreset(name: "Peach", colors: [.orange, .pink, .white]),
    ]
}

struct ColorPreset: Identifiable {
    let id = UUID()
    let color: Color
    
    static let presets: [ColorPreset] = [
        ColorPreset(color: .white),
        ColorPreset(color: .black),
        ColorPreset(color: Color(red: 0.95, green: 0.95, blue: 0.97)),
        ColorPreset(color: Color(red: 0.1, green: 0.1, blue: 0.15)),
        ColorPreset(color: .blue),
        ColorPreset(color: .purple),
        ColorPreset(color: .pink),
        ColorPreset(color: .orange),
        ColorPreset(color: .green),
        ColorPreset(color: .teal),
        ColorPreset(color: .indigo),
        ColorPreset(color: .mint),
    ]
}
