# 📱 Bobmockup

<p align="center">
  <img src="docs/assets/icon.png" alt="Bobmockup Logo" width="128" height="128">
</p>

<p align="center">
  <strong>Créez des mockups professionnels pour l'App Store en quelques secondes</strong>
</p>

<p align="center">
  <a href="https://apps.apple.com/app/bobmockup/id6758100933">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg" alt="Download on the App Store" height="50">
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-blue.svg" alt="iOS 17.0+">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/SwiftUI-5.0-purple.svg" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License MIT">
</p>

---

## ✨ Fonctionnalités

- **📱 Plusieurs appareils** - iPhone 15 Pro, iPhone 15, iPad Pro, MacBook Pro
- **🎨 Fonds personnalisés** - Couleurs unies, dégradés, mesh gradients, images
- **✨ Effets avancés** - Ombres portées, rotation 3D, mise à l'échelle
- **📝 Textes et légendes** - Polices personnalisables, couleurs, tailles
- **📤 Export haute qualité** - 1080x1920 pixels, parfait pour l'App Store
- **🔒 Respect de la vie privée** - Tout reste sur votre appareil
- **♿ Accessibilité** - Support complet de VoiceOver

## 📸 Captures d'écran

<p align="center">
  <img src="docs/assets/screenshot1.png" alt="Screenshot 1" width="200">
  <img src="docs/assets/screenshot2.png" alt="Screenshot 2" width="200">
  <img src="docs/assets/screenshot3.png" alt="Screenshot 3" width="200">
</p>

## 🛠️ Technologies utilisées

- **SwiftUI** - Interface utilisateur moderne et réactive
- **Swift 5.9** - Langage de programmation
- **StoreKit 2** - Achats intégrés
- **PhotosUI** - Sélection d'images
- **ImageRenderer** - Export haute qualité

## 📋 Prérequis

- iOS 17.0 ou supérieur
- Xcode 15.0 ou supérieur
- macOS Sonoma ou supérieur (pour le développement)

## 🚀 Installation pour le développement

1. Clonez le repository :
```bash
git clone https://github.com/robertoulhen/bobmockup.git
cd bobmockup
```

2. Ouvrez le projet dans Xcode :
```bash
open Bobmockup.xcodeproj
```

3. Sélectionnez votre simulateur ou appareil cible

4. Lancez l'application (⌘ + R)

## 📁 Structure du projet

```
Bobmockup/
├── BobmockupApp.swift          # Point d'entrée de l'application
├── ContentView.swift           # Vue principale
├── Models/
│   ├── BackgroundStyle.swift   # Modèles de fond
│   ├── DeviceFrame.swift       # Types d'appareils
│   └── PurchaseManager.swift   # Gestion des achats
├── Views/
│   ├── AboutView.swift         # Page À propos
│   ├── BackgroundView.swift    # Vue de fond
│   ├── ControlPanelView.swift  # Panneau de contrôle
│   ├── DeviceFrameView.swift   # Rendu des appareils
│   ├── MockupEditorView.swift  # Éditeur principal
│   ├── OnboardingView.swift    # Écran d'accueil
│   ├── PremiumBenefitsView.swift # Avantages Premium
│   ├── PremiumUpgradeView.swift  # Page d'achat
│   └── ProjectsListView.swift  # Liste des projets
├── Assets.xcassets/            # Ressources graphiques
└── Configuration.storekit      # Configuration StoreKit
```

## 💰 Modèle économique

- **Gratuit** : 10 exportations incluses
- **Premium** : Achat unique pour des exportations illimitées

## 🔒 Confidentialité

Bobmockup respecte votre vie privée :
- ✅ Aucune collecte de données
- ✅ Pas de tracking ou analytics
- ✅ Toutes les opérations sont locales
- ✅ Vos images ne quittent jamais votre appareil

Voir notre [Politique de Confidentialité](https://bobmockup.app/privacy)

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👨‍💻 Auteur

**Robert Oulhen**

- 📧 Email : [bob.oulhen@gmail.com](mailto:bob.oulhen@gmail.com)
- 🌐 Site : [bobmockup.app](https://bobmockup.app)
- 🐙 GitHub : [@robertoulhen](https://github.com/robertoulhen)

## 🙏 Remerciements

- Apple pour SwiftUI et les outils de développement
- La communauté Swift pour l'inspiration et le support

---

<p align="center">
  Développé avec ❤️ par Robert Oulhen
</p>
