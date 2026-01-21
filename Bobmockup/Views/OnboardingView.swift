//
//  OnboardingView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 21/01/2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "iphone.gen3",
            iconColors: [.blue, .purple],
            title: "Bienvenue sur Bobmockup",
            subtitle: "Créez de superbes mockups professionnels pour vos applications en quelques secondes"
        ),
        OnboardingPage(
            icon: "photo.badge.plus",
            iconColors: [.orange, .pink],
            title: "Importez vos captures",
            subtitle: "Sélectionnez vos captures d'écran depuis votre bibliothèque photo ou vos fichiers"
        ),
        OnboardingPage(
            icon: "slider.horizontal.3",
            iconColors: [.purple, .indigo],
            title: "Personnalisez tout",
            subtitle: "Choisissez parmi plusieurs appareils, fonds, textes et effets pour un rendu unique"
        ),
        OnboardingPage(
            icon: "square.and.arrow.up",
            iconColors: [.green, .mint],
            title: "Exportez et partagez",
            subtitle: "Téléchargez vos mockups en haute qualité, prêts pour l'App Store"
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.08, blue: 0.2)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)
                
                // Buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        // Bouton Commencer
                        Button {
                            completeOnboarding()
                        } label: {
                            HStack {
                                Text("Commencer")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        .accessibilityLabel("Commencer à utiliser l'application")
                        .accessibilityHint("Termine la présentation et ouvre l'application")
                    } else {
                        // Bouton Suivant
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            HStack {
                                Text("Suivant")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                        }
                        .accessibilityLabel("Page suivante")
                        .accessibilityHint("Affiche la page suivante de la présentation")
                    }
                    
                    // Bouton Passer
                    if currentPage < pages.count - 1 {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Passer")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .accessibilityLabel("Passer la présentation")
                        .accessibilityHint("Termine la présentation et ouvre l'application directement")
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

struct OnboardingPage {
    let icon: String
    let iconColors: [Color]
    let title: String
    let subtitle: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: page.iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: page.iconColors[0].opacity(0.5), radius: 30, x: 0, y: 10)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(.white)
            }
            .accessibilityHidden(true)
            
            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
