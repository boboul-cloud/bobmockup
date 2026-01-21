//
//  PurchaseManager.swift
//  Bobmockup
//
//  Created by Robert Oulhen on 16/01/2026.
//

import Foundation
import StoreKit
import SwiftUI

@Observable
@MainActor
final class PurchaseManager {
    static let shared = PurchaseManager()
    
    // ID du produit (à configurer dans App Store Connect)
    static let premiumProductID = "com.bobmockup.premium"
    
    // Limite de conversions gratuites
    static let freeConversionsLimit = 10
    
    // État publié
    private(set) var isPremium: Bool = false
    private(set) var conversionsUsed: Int = 0
    private(set) var products: [Product] = []
    private(set) var purchaseState: PurchaseState = .idle
    
    enum PurchaseState: Equatable {
        case idle
        case loading
        case purchasing
        case success
        case failed(String)
    }
    
    // Clés UserDefaults
    private let conversionsKey = "bobmockup_conversions_used"
    private let premiumKey = "bobmockup_is_premium"
    
    private var updateListenerTask: Task<Void, Error>? = nil
    
    var remainingFreeConversions: Int {
        max(0, Self.freeConversionsLimit - conversionsUsed)
    }
    
    var canConvert: Bool {
        isPremium || conversionsUsed < Self.freeConversionsLimit
    }
    
    private init() {
        // Charger l'état sauvegardé
        conversionsUsed = UserDefaults.standard.integer(forKey: conversionsKey)
        isPremium = UserDefaults.standard.bool(forKey: premiumKey)
        
        // Démarrer l'écoute des transactions
        updateListenerTask = listenForTransactions()
        
        // Charger les produits
        Task {
            await loadProducts()
            await checkExistingPurchases()
        }
    }
    
    func cleanup() {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Gestion des conversions
    
    func useConversion() -> Bool {
        guard canConvert else { return false }
        
        if !isPremium {
            conversionsUsed += 1
            UserDefaults.standard.set(conversionsUsed, forKey: conversionsKey)
        }
        return true
    }
    
    // Indique si les produits StoreKit sont disponibles
    var hasProducts: Bool {
        !products.isEmpty
    }
    
    // MARK: - StoreKit
    
    func loadProducts() async {
        purchaseState = .loading
        do {
            products = try await Product.products(for: [Self.premiumProductID])
            purchaseState = .idle
            print("Produits chargés: \(products.count)")
        } catch {
            print("Erreur chargement produits: \(error)")
            purchaseState = .idle // Ne pas bloquer si pas de produits
        }
    }
    
    func purchase() async {
        // Recharger les produits si nécessaire
        if products.isEmpty {
            await loadProducts()
        }
        
        // Si toujours pas de produit, mode test en DEBUG
        guard let product = products.first else {
            #if DEBUG
            // Mode test: simuler l'achat (seulement si StoreKit non configuré)
            print("⚠️ Aucun produit StoreKit - Mode simulation")
            await simulatePurchaseForTesting()
            #else
            purchaseState = .failed("Produit non disponible")
            #endif
            return
        }
        
        purchaseState = .purchasing
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchasedState()
                await transaction.finish()
                purchaseState = .success
                
            case .userCancelled:
                purchaseState = .idle
                
            case .pending:
                purchaseState = .idle
                
            @unknown default:
                purchaseState = .failed("Erreur inconnue")
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }
    
    func restorePurchases() async {
        purchaseState = .loading
        
        do {
            try await AppStore.sync()
            await checkExistingPurchases()
            
            if isPremium {
                purchaseState = .success
            } else {
                purchaseState = .failed("Aucun achat à restaurer")
            }
        } catch {
            purchaseState = .failed("Erreur de restauration: \(error.localizedDescription)")
        }
    }
    
    private func checkExistingPurchases() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == Self.premiumProductID {
                    await updatePurchasedState()
                    return
                }
            }
        }
    }
    
    private func updatePurchasedState() async {
        isPremium = true
        UserDefaults.standard.set(true, forKey: premiumKey)
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updatePurchasedState()
                    await transaction.finish()
                } catch {
                    print("Transaction échouée: \(error)")
                }
            }
        }
    }
    
    // Pour les tests/debug - à supprimer en production
    #if DEBUG
    func resetForTesting() {
        conversionsUsed = 0
        isPremium = false
        UserDefaults.standard.set(0, forKey: conversionsKey)
        UserDefaults.standard.set(false, forKey: premiumKey)
    }
    
    func simulatePremium() {
        isPremium = true
        UserDefaults.standard.set(true, forKey: premiumKey)
        purchaseState = .success
    }
    
    private func simulatePurchaseForTesting() async {
        purchaseState = .purchasing
        // Simuler un délai d'achat
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isPremium = true
        UserDefaults.standard.set(true, forKey: premiumKey)
        purchaseState = .success
    }
    #endif
}

enum StoreError: Error {
    case failedVerification
}
