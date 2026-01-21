//
//  PremiumUpgradeView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 16/01/2026.
//

import SwiftUI
import StoreKit

struct PremiumUpgradeView: View {
    @Bindable var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessView = false
    @State private var showPurchaseConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.05, blue: 0.2),
                        Color(red: 0.2, green: 0.1, blue: 0.3),
                        Color(red: 0.1, green: 0.15, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if showSuccessView {
                    // Vue de succès
                    PurchaseSuccessView(onDismiss: { dismiss() })
                } else {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Header
                            VStack(spacing: 16) {
                                // Logo Premium
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.yellow, .orange],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .shadow(color: .orange.opacity(0.5), radius: 20)
                                    
                                    Image(systemName: "crown.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.white)
                                }
                            .padding(.top, 40)
                            
                            Text("Bobmockup Premium")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Débloquez des conversions illimitées")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Stats actuelles
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "photo.stack")
                                    .foregroundColor(.orange)
                                Text("Conversions utilisées")
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text("\(purchaseManager.conversionsUsed) / \(PurchaseManager.freeConversionsLimit)")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            
                            // Barre de progression
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.2))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(
                                            width: geo.size.width * min(CGFloat(purchaseManager.conversionsUsed) / CGFloat(PurchaseManager.freeConversionsLimit), 1.0),
                                            height: 12
                                        )
                                }
                            }
                            .frame(height: 12)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal)
                        
                        // Avantages Premium
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Avantages Premium")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                PremiumFeatureRow(
                                    icon: "infinity",
                                    title: "Conversions illimitées",
                                    description: "Exportez autant de mockups que vous voulez"
                                )
                                
                                PremiumFeatureRow(
                                    icon: "bolt.fill",
                                    title: "Achat unique",
                                    description: "Payez une fois, profitez pour toujours"
                                )
                                
                                PremiumFeatureRow(
                                    icon: "heart.fill",
                                    title: "Soutenez le développeur",
                                    description: "Aidez à améliorer l'application"
                                )
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Boutons d'achat
                        VStack(spacing: 16) {
                            // Prix
                            if let product = purchaseManager.products.first {
                                Text(product.displayPrice)
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Achat unique • Sans abonnement")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                            } else {
                                Text("1,99 €")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                #if DEBUG
                                Text("Mode Test • Achat simulé")
                                    .font(.subheadline)
                                    .foregroundColor(.orange.opacity(0.8))
                                #else
                                Text("Achat unique • Sans abonnement")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                #endif
                            }
                            
                            // Bouton Acheter
                            Button {
                                Task {
                                    await purchaseManager.purchase()
                                }
                            } label: {
                                HStack {
                                    if purchaseManager.purchaseState == .purchasing || purchaseManager.purchaseState == .loading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "crown.fill")
                                        Text("Passer Premium")
                                            .fontWeight(.bold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [.orange, .pink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .orange.opacity(0.4), radius: 10, y: 5)
                            }
                            .disabled(purchaseManager.purchaseState == .purchasing)
                            .padding(.horizontal)
                            .accessibilityLabel("Acheter Bobmockup Premium")
                            .accessibilityHint("Effectue l'achat unique pour débloquer les conversions illimitées")
                            
                            // Restaurer achats
                            Button {
                                Task {
                                    await purchaseManager.restorePurchases()
                                }
                            } label: {
                                Text("Restaurer mes achats")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                    .underline()
                            }
                            .padding(.top, 8)
                            .accessibilityLabel("Restaurer mes achats")
                            .accessibilityHint("Restaure un achat Premium effectué précédemment")
                            
                            // Message d'erreur
                            if case .failed(let message) = purchaseManager.purchaseState {
                                Text(message)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.top, 8)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .confirmationDialog(
                "Confirmer l'achat",
                isPresented: $showPurchaseConfirmation,
                titleVisibility: .visible
            ) {
                Button("Acheter pour 1,99 €") {
                    Task {
                        await purchaseManager.purchase()
                    }
                }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Bobmockup Premium\nConversions illimitées\n\n[Environnement de test]")
            }
            .onChange(of: purchaseManager.purchaseState) { _, newState in
                if newState == .success {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showSuccessView = true
                    }
                }
            }
        }
    }
}

// MARK: - Purchase Success View

struct PurchaseSuccessView: View {
    let onDismiss: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animation de succès
            ZStack {
                // Cercles animés
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(Color.green.opacity(0.3 - Double(i) * 0.1), lineWidth: 2)
                        .frame(width: animate ? CGFloat(150 + i * 50) : 100, height: animate ? CGFloat(150 + i * 50) : 100)
                        .scaleEffect(animate ? 1.2 : 0.8)
                        .opacity(animate ? 0 : 1)
                        .animation(
                            .easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.3),
                            value: animate
                        )
                }
                
                // Couronne
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: .green.opacity(0.5), radius: 30)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(animate ? 1 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animate)
            }
            
            VStack(spacing: 16) {
                Text("Félicitations ! 🎉")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Vous êtes maintenant Premium")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                
                Text("Profitez de conversions illimitées\npour créer des mockups incroyables !")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: animate)
            
            Spacer()
            
            // Bouton continuer
            Button(action: onDismiss) {
                Text("C'est parti ! 🚀")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .green.opacity(0.4), radius: 10, y: 5)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
            .opacity(animate ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.6), value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// Badge Premium à afficher dans la toolbar
struct PremiumBadgeView: View {
    var purchaseManager: PurchaseManager
    @Binding var showUpgrade: Bool
    
    var body: some View {
        Button {
            if !purchaseManager.isPremium {
                showUpgrade = true
            }
        } label: {
            if purchaseManager.isPremium {
                // Badge Premium
                HStack(spacing: 4) {
                    Image(systemName: "crown.fill")
                        .font(.caption)
                    Text("PRO")
                        .font(.caption.bold())
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.2))
                )
            } else {
                // Compteur de conversions
                HStack(spacing: 4) {
                    Image(systemName: "photo.stack")
                        .font(.caption)
                    Text("\(purchaseManager.remainingFreeConversions)")
                        .font(.caption.bold())
                }
                .foregroundColor(purchaseManager.remainingFreeConversions > 3 ? .primary : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .stroke(purchaseManager.remainingFreeConversions > 3 ? Color.gray.opacity(0.3) : Color.orange, lineWidth: 1)
                )
            }
        }
        .disabled(purchaseManager.isPremium)
    }
}

#Preview {
    PremiumUpgradeView(purchaseManager: PurchaseManager.shared)
}
