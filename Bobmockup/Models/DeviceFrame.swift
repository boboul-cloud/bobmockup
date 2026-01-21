//
//  DeviceFrame.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//

import SwiftUI

enum DeviceType: String, CaseIterable, Identifiable {
    case iPhone15Pro = "iPhone 15 Pro"
    case iPhone15 = "iPhone 15"
    case iPadPro = "iPad Pro"
    case macBookPro = "MacBook Pro"
    
    var id: String { rawValue }
    
    var aspectRatio: CGFloat {
        switch self {
        case .iPhone15Pro, .iPhone15:
            return 19.5 / 9
        case .iPadPro:
            return 4.3 / 3
        case .macBookPro:
            return 16 / 10
        }
    }
    
    var cornerRadius: CGFloat {
        switch self {
        case .iPhone15Pro, .iPhone15:
            return 55
        case .iPadPro:
            return 20
        case .macBookPro:
            return 10
        }
    }
    
    var bezelWidth: CGFloat {
        switch self {
        case .iPhone15Pro:
            return 18
        case .iPhone15:
            return 20
        case .iPadPro:
            return 20
        case .macBookPro:
            return 15
        }
    }
    
    var frameColor: Color {
        switch self {
        case .iPhone15Pro:
            return Color(red: 0.2, green: 0.2, blue: 0.25)
        case .iPhone15:
            return Color(red: 0.1, green: 0.1, blue: 0.1)
        case .iPadPro:
            return Color(red: 0.15, green: 0.15, blue: 0.15)
        case .macBookPro:
            return Color(red: 0.75, green: 0.75, blue: 0.78)
        }
    }
    
    var icon: String {
        switch self {
        case .iPhone15Pro, .iPhone15:
            return "iphone"
        case .iPadPro:
            return "ipad"
        case .macBookPro:
            return "laptopcomputer"
        }
    }
}

struct MockupProject: Identifiable {
    let id = UUID()
    var deviceType: DeviceType
    var screenshot: UIImage?
    var backgroundColor: Color
    var shadowEnabled: Bool
    var shadowRadius: CGFloat
    var rotation3D: Double
    var scale: CGFloat
    
    init(
        deviceType: DeviceType = .iPhone15Pro,
        screenshot: UIImage? = nil,
        backgroundColor: Color = .white,
        shadowEnabled: Bool = true,
        shadowRadius: CGFloat = 30,
        rotation3D: Double = 0,
        scale: CGFloat = 0.8
    ) {
        self.deviceType = deviceType
        self.screenshot = screenshot
        self.backgroundColor = backgroundColor
        self.shadowEnabled = shadowEnabled
        self.shadowRadius = shadowRadius
        self.rotation3D = rotation3D
        self.scale = scale
    }
}
