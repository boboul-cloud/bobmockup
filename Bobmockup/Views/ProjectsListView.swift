//
//  ProjectsListView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 15/01/2026.
//

import SwiftUI

struct ProjectsListView: View {
    @State private var showEditor = false
    @State private var showPremiumUpgrade = false
    @State private var showPremiumBenefits = false
    @State private var showAbout = false
    @State private var purchaseManager = PurchaseManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                // Bouton Mise à Niveau
                if !purchaseManager.isPremium {
                    upgradeButton
                        .padding(.horizontal)
                }
                
                // Section principale - Créer un mockup
                createButton
                    .padding(.horizontal)
                
                // Bandeau conversions restantes
                premiumBanner
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Bobmockup")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("À propos")
                    .accessibilityHint("Affiche les informations sur l'application et les liens légaux")
                }
            }
            .fullScreenCover(isPresented: $showEditor) {
                MockupEditorView()
            }
            .sheet(isPresented: $showPremiumUpgrade) {
                PremiumUpgradeView(purchaseManager: purchaseManager)
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showPremiumBenefits) {
                PremiumBenefitsView()
            }
        }
    }
    
    // MARK: - Bouton Mise à Niveau
    private var upgradeButton: some View {
        Button {
            showPremiumUpgrade = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "crown.fill")
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                Text("Mise à Niveau")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Passer à Premium")
        .accessibilityHint("Ouvre l'écran pour acheter la version Premium avec conversions illimitées")
    }
    
    // MARK: - Bouton Créer
    private var createButton: some View {
        Button {
            showEditor = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Créer un mockup")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("Importez votre capture d'écran")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Commencer")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
                }
                
                Spacer()
                
                // Illustration
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 60, height: 120)
                        .rotationEffect(.degrees(-8))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 60, height: 120)
                        .rotationEffect(.degrees(8))
                }
            }
            .padding(24)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 24)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Créer un mockup")
        .accessibilityHint("Ouvre l'éditeur pour créer un nouveau mockup")
    }
    
    // MARK: - Bandeau Premium
    private var premiumBanner: some View {
        Group {
            if purchaseManager.isPremium {
                Button {
                    showPremiumBenefits = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text("Premium Actif")
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Premium Actif")
                .accessibilityHint("Affiche les avantages de votre abonnement Premium")
            } else {
                VStack(spacing: 8) {
                    Text("\(purchaseManager.remainingFreeConversions)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    
                    Text("conversions restantes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
}

#Preview {
    ProjectsListView()
}
