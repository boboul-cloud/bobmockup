# 🚀 Guide de Déploiement GitHub pour Bobmockup

## Étape 1 : Créer le repository sur GitHub

1. Allez sur [github.com/new](https://github.com/new)
2. Configurez le repository :
   - **Repository name** : `bobmockup`
   - **Description** : `📱 Créez des mockups professionnels pour l'App Store en quelques secondes`
   - **Visibility** : Public (ou Private si vous préférez)
   - ⚠️ Ne cochez PAS "Add a README file" (on l'a déjà)
   - ⚠️ Ne cochez PAS "Add .gitignore" (on l'a déjà)
   - ⚠️ Ne cochez PAS "Choose a license" (on l'a déjà)
3. Cliquez sur **Create repository**

## Étape 2 : Pousser le code sur GitHub

Exécutez ces commandes dans le Terminal :

```bash
cd /Users/robertoulhen/Desktop/Bobmockup/Bobmockup

# Ajouter le remote GitHub (remplacez par votre username)
git remote add origin https://github.com/robertoulhen/bobmockup.git

# Pousser le code
git branch -M main
git push -u origin main
```

## Étape 3 : Activer GitHub Pages (site web)

1. Allez dans **Settings** > **Pages**
2. Source : **Deploy from a branch**
3. Branch : `main`
4. Folder : `/docs`
5. Cliquez **Save**

Votre site sera disponible à : `https://robertoulhen.github.io/bobmockup/`

### Configuration domaine personnalisé (optionnel)

Pour utiliser `bobmockup.app` :

1. Dans **Settings** > **Pages** > **Custom domain** : entrez `bobmockup.app`
2. Ajoutez ces enregistrements DNS chez votre registrar :

```
Type    Nom     Valeur
A       @       185.199.108.153
A       @       185.199.109.153
A       @       185.199.110.153
A       @       185.199.111.153
CNAME   www     robertoulhen.github.io
```

3. Créez le fichier CNAME :

```bash
echo "bobmockup.app" > docs/CNAME
git add docs/CNAME
git commit -m "chore: add CNAME for custom domain"
git push
```

## Étape 4 : Configurer les topics

1. Allez sur la page du repository
2. Cliquez sur ⚙️ à côté de "About"
3. Ajoutez les topics :
   - `ios`
   - `swift`
   - `swiftui`
   - `mockup`
   - `app-store`
   - `iphone`
   - `design`

## Étape 5 : Créer une Release

1. Allez dans **Releases** > **Create a new release**
2. Tag : `v1.0.0`
3. Title : `v1.0.0 - Première version`
4. Description :
```markdown
## 🎉 Première version de Bobmockup !

### Fonctionnalités
- 📱 Support iPhone 15 Pro, iPhone 15, iPad Pro, MacBook Pro
- 🎨 Fonds personnalisés (couleurs, dégradés, mesh, images)
- ✨ Effets visuels (ombres, rotation 3D, échelle)
- 📝 Textes et légendes personnalisables
- 📤 Export haute qualité 1080x1920
- 💎 Version Premium avec achats intégrés
- 👋 Onboarding pour nouveaux utilisateurs
- ♿ Accessibilité complète (VoiceOver)

### Installation
Téléchargez sur l'[App Store](https://apps.apple.com/app/bobmockup/id6758100933)
```
5. Cliquez **Publish release**

## Étape 6 : Mettre à jour les URLs

Une fois le repository créé, mettez à jour les URLs dans l'app :

### Dans AboutView.swift
- Remplacez `https://bobmockup.app/privacy` par `https://robertoulhen.github.io/bobmockup/privacy.html`
- Remplacez `https://bobmockup.app/terms` par `https://robertoulhen.github.io/bobmockup/terms.html`

(Ou gardez les URLs actuelles si vous configurez le domaine personnalisé)

### Dans PremiumBenefitsView.swift
- Mêmes URLs à mettre à jour

## ✅ Checklist finale

- [ ] Repository créé sur GitHub
- [ ] Code poussé
- [ ] GitHub Pages activé
- [ ] Site web fonctionnel
- [ ] Topics ajoutés
- [ ] Release v1.0.0 créée
- [ ] URLs mises à jour dans l'app (si nécessaire)
- [ ] App soumise sur l'App Store

## 📚 Ressources

- [Documentation GitHub Pages](https://docs.github.com/en/pages)
- [App Store Connect](https://appstoreconnect.apple.com)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

---

Bonne chance pour la soumission ! 🚀
