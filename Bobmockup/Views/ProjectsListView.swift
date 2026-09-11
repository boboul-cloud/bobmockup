//
//  ProjectsListView.swift
//  Bobmockup
//
//  L'atelier. L'écran listait « des projets » alors que rien n'était
//  sauvegardé : il en affiche maintenant de vrais, et les vignettes
//  montrent le rendu plutôt qu'un carré de dégradé décoratif.
//

import SwiftUI

struct ProjectsListView: View {
    @State private var purchaseManager = PurchaseManager.shared
    @State private var store = ProjectStore.shared

    @State private var newLayout: CreationLayout?
    @State private var openedProject: MockupProject?
    @State private var showPremium = false
    @State private var showBenefits = false
    @State private var showAbout = false
    @State private var showGuide = false
    @State private var projectToDelete: MockupProject?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Space.x7) {
                    intro
                    layouts
                    if !store.projects.isEmpty { projects }
                    counter
                }
                .padding(.bottom, DS.Space.x7)
            }
            .background(DS.Palette.base.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("BOBMOCKUP")
                        .font(.system(size: 14, weight: .black).width(.expanded))
                        .tracking(0.85)
                        .foregroundStyle(DS.Palette.ink)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button { showGuide = true } label: {
                        DSIcon(name: "book", size: 20)
                            .foregroundStyle(DS.Palette.ink2)
                    }
                    .buttonStyle(.plain)
                    .dsHitTarget()
                    .accessibilityLabel("Mode d'emploi")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAbout = true } label: {
                        DSIcon(name: "info.circle", size: 20)
                            .foregroundStyle(DS.Palette.ink2)
                    }
                    .buttonStyle(.plain)
                    .dsHitTarget()
                    .accessibilityLabel("À propos")
                }
            }
            .toolbarBackground(DS.Palette.base, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(DS.Palette.safelight)
        .fullScreenCover(item: $newLayout) { layout in
            MockupEditorView(layout: layout)
        }
        .fullScreenCover(item: $openedProject) { project in
            MockupEditorView(project: project)
        }
        .sheet(isPresented: $showPremium) { PremiumUpgradeView(purchaseManager: purchaseManager) }
        .sheet(isPresented: $showBenefits) { PremiumBenefitsView() }
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(isPresented: $showGuide) { UserGuideView() }
        .confirmationDialog("Supprimer ce projet ?",
                            isPresented: Binding(get: { projectToDelete != nil },
                                                 set: { if !$0 { projectToDelete = nil } }),
                            titleVisibility: .visible) {
            Button("Supprimer", role: .destructive) {
                if let project = projectToDelete { store.delete(project) }
                projectToDelete = nil
            }
            Button("Annuler", role: .cancel) { projectToDelete = nil }
        } message: {
            Text("Le projet et sa capture seront effacés définitivement.")
        }
    }

    // MARK: - Introduction

    private var intro: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            Text("Atelier")
                .dsLabel()
                .foregroundStyle(DS.Palette.ink3)
            Text("Nouvelle épreuve")
                .dsDisplayL()
                .foregroundStyle(DS.Palette.ink)
            Text("Choisissez une disposition. Tout reste modifiable ensuite.")
                .dsCaption()
                .foregroundStyle(DS.Palette.ink2)
        }
        .padding(.horizontal, DS.Space.screen)
        .padding(.top, DS.Space.x6)
    }

    // MARK: - Dispositions

    private var layouts: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Space.x2) {
                ForEach(CreationLayout.allCases) { layout in
                    LayoutTile(layout: layout,
                               isLocked: layout.requiresPremium && !purchaseManager.isPremium) {
                        DS.Haptics.medium()
                        if layout.requiresPremium && !purchaseManager.isPremium {
                            showPremium = true
                        } else {
                            newLayout = layout
                        }
                    }
                }
            }
            .padding(.horizontal, DS.Space.screen)
        }
    }

    // MARK: - Projets

    private var projects: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Sur le fil")
                .padding(.horizontal, DS.Space.screen)

            VStack(spacing: 0) {
                ForEach(store.projects) { project in
                    Button {
                        DS.Haptics.light()
                        openedProject = project
                    } label: {
                        ProjectRow(project: project, store: store)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            openedProject = store.duplicate(project)
                        } label: {
                            Label("Dupliquer", systemImage: "plus.square.on.square")
                        }
                        Button(role: .destructive) {
                            projectToDelete = project
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }

                    if project.id != store.projects.last?.id {
                        Divider().overlay(DS.Palette.line)
                    }
                }
            }
            .dsCard()
            .padding(.horizontal, DS.Space.screen)
        }
    }

    // MARK: - Compteur d'épreuves

    private var counter: some View {
        VStack(alignment: .leading, spacing: DS.Space.x4) {
            DSSectionLabel(text: "Compteur d'épreuves")

            if purchaseManager.isPremium {
                Button { showBenefits = true } label: {
                    HStack(spacing: DS.Space.x3) {
                        DSIcon(name: "checkmark.seal", size: 20)
                            .foregroundStyle(DS.Palette.paper)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Atelier illimité")
                                .dsBodyStrong()
                                .foregroundStyle(DS.Palette.ink)
                            Text("Compteur désactivé")
                                .dsCaption()
                                .foregroundStyle(DS.Palette.ink2)
                        }
                        Spacer()
                        DSIcon(name: "chevron.right", size: 14)
                            .foregroundStyle(DS.Palette.ink3)
                    }
                    .padding(.horizontal, DS.Space.x4)
                    .frame(minHeight: 64)
                    .dsCard()
                }
                .buttonStyle(.plain)
            } else {
                HStack(alignment: .bottom, spacing: DS.Space.x4) {
                    Text("\(purchaseManager.remainingFreeConversions)")
                        .dsDisplayXL()
                        .foregroundStyle(DS.Palette.ink)

                    VStack(alignment: .leading, spacing: DS.Space.x2) {
                        // Une pellicule, pas une barre de progression :
                        // on compte des vues, pas un pourcentage.
                        HStack(spacing: 3) {
                            ForEach(0..<PurchaseManager.freeConversionsLimit, id: \.self) { index in
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(index < purchaseManager.conversionsUsed
                                          ? DS.Palette.safelight : DS.Palette.raised)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(index < purchaseManager.conversionsUsed
                                                    ? DS.Palette.safelight : DS.Palette.line, lineWidth: 1)
                                    )
                                    .frame(height: 26)
                            }
                        }
                        Text("Tirages gratuits restants sur \(PurchaseManager.freeConversionsLimit)")
                            .dsLabel()
                            .foregroundStyle(DS.Palette.ink3)
                    }
                    .padding(.bottom, 6)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(purchaseManager.remainingFreeConversions) tirages gratuits restants sur \(PurchaseManager.freeConversionsLimit)")

                Button { showPremium = true } label: {
                    HStack(spacing: DS.Space.x3) {
                        DSIcon(name: "checkmark.seal", size: 20)
                            .foregroundStyle(DS.Palette.paper)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Atelier illimité")
                                .dsBodyStrong()
                                .foregroundStyle(DS.Palette.ink)
                            Text("Tirages sans compteur, formats pro, détourage et PDF")
                                .dsCaption()
                                .foregroundStyle(DS.Palette.ink2)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        DSIcon(name: "chevron.right", size: 14)
                            .foregroundStyle(DS.Palette.ink3)
                    }
                    .padding(DS.Space.x4)
                    .dsCard()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DS.Space.screen)
    }
}

// MARK: - Tuile de disposition

private struct LayoutTile: View {
    let layout: CreationLayout
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DS.Space.x3) {
                ZStack(alignment: .topTrailing) {
                    CreationLayoutDiagram(layout: layout, side: 52)
                        .foregroundStyle(DS.Palette.ink2)
                        .frame(maxWidth: .infinity)
                    if isLocked {
                        DSIcon(name: "lock", size: 12)
                            .foregroundStyle(DS.Palette.paper)
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(layout.localizedName)
                        .dsCaption()
                        .foregroundStyle(DS.Palette.ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: 34, alignment: .topLeading)
                    Text(layout.detail)
                        .dsLabel()
                        .foregroundStyle(DS.Palette.ink3)
                }
            }
            .padding(DS.Space.x3)
            .frame(width: 118, alignment: .leading)
            .dsCard()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(layout.rawValue)
        .accessibilityHint(isLocked ? "Réservé à l'atelier illimité" : "Ouvre l'éditeur avec cette disposition")
    }
}

// MARK: - Ligne de projet

/// La vignette est un rendu réel de la composition : elle annonce le
/// résultat au lieu de représenter une catégorie.
private struct ProjectRow: View {
    let project: MockupProject
    let store: ProjectStore

    private var thumbnailSize: CGSize {
        project.exportSizePreset.isLandscape ? CGSize(width: 46, height: 30) : CGSize(width: 30, height: 46)
    }

    var body: some View {
        HStack(spacing: DS.Space.x3) {
            ProjectThumbnail(project: project, size: thumbnailSize)

            VStack(alignment: .leading, spacing: 3) {
                Text(project.name)
                    .dsBodyStrong()
                    .foregroundStyle(DS.Palette.ink)
                    .lineLimit(1)
                Text(project.subtitle)
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)
            }

            Spacer(minLength: DS.Space.x2)

            Text(project.updatedAt.workshopRelative)
                .dsNumeric()
                .foregroundStyle(DS.Palette.ink3)
        }
        .padding(.horizontal, DS.Space.x4)
        .frame(minHeight: 64)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

private struct ProjectThumbnail: View {
    let project: MockupProject
    let size: CGSize

    var body: some View {
        ZStack {
            background
            RoundedRectangle(cornerRadius: 2)
                .fill(.black.opacity(0.55))
                .overlay(RoundedRectangle(cornerRadius: 2).stroke(.white.opacity(0.25), lineWidth: 0.5))
                .frame(width: size.width * 0.44, height: size.height * 0.62)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(DS.Palette.line, lineWidth: 1))
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var background: some View {
        switch project.backgroundStyle {
        case .solid:
            project.solidColor.color
        default:
            LinearGradient(colors: project.gradientColors.colors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

#Preview {
    ProjectsListView()
}
