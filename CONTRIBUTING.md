# Contribuer à Bobmockup

Merci de votre intérêt pour contribuer à Bobmockup ! 🎉

## 📋 Comment contribuer

### Signaler un bug

1. Vérifiez que le bug n'a pas déjà été signalé dans les [Issues](https://github.com/robertoulhen/bobmockup/issues)
2. Créez une nouvelle issue avec le template "Bug Report"
3. Incluez :
   - Description claire du bug
   - Étapes pour reproduire
   - Comportement attendu vs comportement actuel
   - Version de l'app et d'iOS
   - Captures d'écran si pertinent

### Proposer une fonctionnalité

1. Vérifiez que la fonctionnalité n'a pas déjà été proposée
2. Créez une nouvelle issue avec le template "Feature Request"
3. Décrivez clairement :
   - Le problème que cette fonctionnalité résout
   - La solution proposée
   - Les alternatives considérées

### Soumettre du code

1. **Fork** le repository
2. **Créez une branche** pour votre fonctionnalité :
   ```bash
   git checkout -b feature/ma-nouvelle-fonctionnalite
   ```
3. **Faites vos modifications** en suivant les conventions de code
4. **Testez** vos modifications sur simulateur et appareil réel
5. **Committez** avec des messages clairs :
   ```bash
   git commit -m "feat: ajout de la fonctionnalité X"
   ```
6. **Pushez** votre branche :
   ```bash
   git push origin feature/ma-nouvelle-fonctionnalite
   ```
7. **Ouvrez une Pull Request**

## 📝 Conventions de code

### Swift Style Guide

- Utilisez SwiftLint (configuration incluse)
- Suivez les [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Nommez les variables et fonctions de manière descriptive
- Commentez le code complexe

### Structure des fichiers

```swift
//
//  NomDuFichier.swift
//  Bobmockup
//
//  Created by [Votre Nom] on [Date].
//

import SwiftUI

// MARK: - Main View
struct MyView: View {
    // MARK: - Properties
    @State private var property: Type
    
    // MARK: - Body
    var body: some View {
        // ...
    }
    
    // MARK: - Private Methods
    private func myMethod() {
        // ...
    }
}

// MARK: - Preview
#Preview {
    MyView()
}
```

### Commits

Utilisez les [Conventional Commits](https://www.conventionalcommits.org/) :

- `feat:` nouvelle fonctionnalité
- `fix:` correction de bug
- `docs:` documentation
- `style:` formatage (pas de changement de code)
- `refactor:` refactoring
- `test:` ajout de tests
- `chore:` maintenance

## 🧪 Tests

- Testez sur iOS 17+ simulateurs
- Testez sur appareil réel si possible
- Vérifiez l'accessibilité avec VoiceOver
- Testez en mode sombre et clair

## 📜 Licence

En contribuant, vous acceptez que vos contributions soient sous la même licence MIT que le projet.

## 🙋 Questions ?

N'hésitez pas à ouvrir une issue ou à contacter [support@bobmockup.app](mailto:support@bobmockup.app).

Merci de contribuer ! 🚀
