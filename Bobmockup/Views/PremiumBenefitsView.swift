//
//  PremiumBenefitsView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 21/01/2026.
//

import SwiftUI

struct PremiumBenefitsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.92, blue: 0.98),
                        Color(red: 0.98, green: 0.95, blue: 0.97),
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header avec couronne
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, Color(red: 0.9, green: 0.6, blue: 0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .orange.opacity(0.4), radius: 20)
                                
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Passez à Premium")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            
                            Text("Débloquez toutes les fonctionnalités")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            // Badge Premium actif
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("Premium actif")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.green.opacity(0.15))
                            )
                        }
                        .padding(.top, 20)
                        
                        // Section Avantages Premium
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Avantages Premium")
                                .font(.title3.bold())
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                BenefitRow(
                                    icon: "infinity",
                                    iconColor: .blue,
                                    title: "Conversions illimitées",
                                    description: "Exportez autant de mockups que vous voulez"
                                )
                                
                                Divider().padding(.leading, 72)
                                
                                BenefitRow(
                                    icon: "iphone.gen3",
                                    iconColor: .green,
                                    title: "Tous les appareils",
                                    description: "iPhone, iPad, MacBook et plus encore"
                                )
                                
                                Divider().padding(.leading, 72)
                                
                                BenefitRow(
                                    icon: "paintpalette.fill",
                                    iconColor: .purple,
                                    title: "Fonds personnalisés",
                                    description: "Dégradés, mesh, images de fond"
                                )
                                
                                Divider().padding(.leading, 72)
                                
                                BenefitRow(
                                    icon: "textformat",
                                    iconColor: .orange,
                                    title: "Textes et légendes",
                                    description: "Ajoutez des titres à vos mockups"
                                )
                                
                                Divider().padding(.leading, 72)
                                
                                BenefitRow(
                                    icon: "wand.and.stars",
                                    iconColor: .pink,
                                    title: "Effets avancés",
                                    description: "Ombres, rotation 3D, mise à l'échelle"
                                )
                                
                                Divider().padding(.leading, 72)
                                
                                BenefitRow(
                                    icon: "square.and.arrow.up",
                                    iconColor: .teal,
                                    title: "Export haute qualité",
                                    description: "Images 1080x1920 prêtes pour l'App Store"
                                )
                                
                                Divider().padding(.leading, 72)
                                
                                BenefitRow(
                                    icon: "heart.fill",
                                    iconColor: .red,
                                    title: "Soutenez le développement",
                                    description: "Aidez à améliorer l'application"
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                            )
                            .padding(.horizontal)
                        }
                        
                        // Carte Premium à vie
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Premium à vie")
                                        .font(.headline)
                                    Text("Paiement unique - Accès à vie")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.pink.opacity(0.5), lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.pink.opacity(0.05))
                                    )
                            )
                        }
                        .padding(.horizontal)
                        
                        // Bouton Restaurer
                        Button {
                            // Déjà premium, pas d'action nécessaire
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                Text("Restaurer les achats")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                        
                        // Liens légaux
                        HStack(spacing: 24) {
                            Button {
                                openURL(URL(string: "https://bobmockup.app/terms")!)
                            } label: {
                                Text("Conditions")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                            
                            Button {
                                openURL(URL(string: "https://bobmockup.app/privacy")!)
                            } label: {
                                Text("Confidentialité")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    PremiumBenefitsView()
}
