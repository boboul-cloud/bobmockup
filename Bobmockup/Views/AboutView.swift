//
//  AboutView.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 21/01/2026.
//

import SwiftUI
import StoreKit

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    private let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }()
    
    var body: some View {
        NavigationStack {
            List {
                // En-tête avec logo
                Section {
                    VStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "iphone.gen3")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        .accessibilityHidden(true)
                        
                        VStack(spacing: 4) {
                            Text("Bobmockup")
                                .font(.title.bold())
                            
                            Text("Version \(appVersion)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .listRowBackground(Color.clear)
                }
                
                // Liens légaux
                Section("Informations légales") {
                    Button {
                        openURL(URL(string: "https://boboul-cloud.github.io/bobmockup/privacy.html")!)
                    } label: {
                        HStack {
                            Label("Politique de confidentialité", systemImage: "hand.raised.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityLabel("Politique de confidentialité")
                    .accessibilityHint("Ouvre la politique de confidentialité dans Safari")
                    
                    Button {
                        openURL(URL(string: "https://boboul-cloud.github.io/bobmockup/terms.html")!)
                    } label: {
                        HStack {
                            Label("Conditions d'utilisation", systemImage: "doc.text.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityLabel("Conditions d'utilisation")
                    .accessibilityHint("Ouvre les conditions d'utilisation dans Safari")
                }
                
                // Support
                Section("Support") {
                    Button {
                        openURL(URL(string: "mailto:bob.oulhen@gmail.com")!)
                    } label: {
                        HStack {
                            Label("Nous contacter", systemImage: "envelope.fill")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .accessibilityLabel("Nous contacter par email")
                    .accessibilityHint("Ouvre l'application Mail pour envoyer un message")
                    
                    Button {
                        requestAppReview()
                    } label: {
                        Label("Noter l'application", systemImage: "star.fill")
                    }
                    .accessibilityLabel("Noter l'application")
                    .accessibilityHint("Ouvre la fenêtre pour noter l'application sur l'App Store")
                    
                    ShareLink(item: URL(string: "https://apps.apple.com/app/bobmockup/id123456789")!) {
                        Label("Partager l'app", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Partager l'application")
                    .accessibilityHint("Ouvre le menu de partage pour recommander l'app")
                }
                
                // Crédits
                Section("Crédits") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Développé avec ❤️ par Robert Oulhen")
                            .font(.subheadline)
                        Text("© 2026 Bobmockup. Tous droits réservés.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("À propos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    @MainActor
    private func requestAppReview() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        AppStore.requestReview(in: scene)
    }
}

#Preview {
    AboutView()
}
