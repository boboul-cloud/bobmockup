//
//  ControlPanelView.swift
//  Bobmockup
//
//  Six onglets, un seul accent. Le rail d'onglets est une ligne
//  d'étiquettes en capitales espacées et un filet safelight qui glisse :
//  plus de six pastilles de six couleurs différentes.
//

import SwiftUI
import PhotosUI

struct ControlPanelView: View {
    @Bindable var vm: MockupEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tab: ControlTab = .device
    @State private var backgroundPhotoItem: PhotosPickerItem?
    @State private var customBadgeText = ""
    @State private var customBadgeStyle: BadgeStyle = .red
    @State private var customBadgePosition: BadgePosition = .topTrailing
    @FocusState private var badgeFieldFocused: Bool

    enum ControlTab: String, CaseIterable, Identifiable {
        case device = "Appareil"
        case background = "Fond"
        case caption = "Texte"
        case effects = "Effets"
        case badges = "Pastilles"
        case frame = "Cadre"

        var id: String { rawValue }
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            tabRail
            Divider().overlay(DS.Palette.line)

            ScrollView {
                Group {
                    switch tab {
                    case .device:     deviceTab
                    case .background: backgroundTab
                    case .caption:    captionTab
                    case .effects:    effectsTab
                    case .badges:     badgesTab
                    case .frame:      frameTab
                    }
                }
                .padding(DS.Space.screen)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(DS.Palette.chassis.ignoresSafeArea())
    }

    // MARK: - En-tête et rail

    private var header: some View {
        HStack {
            Text("Réglages")
                .dsDisplayM()
                .foregroundStyle(DS.Palette.ink)
            Spacer()
            Button { dismiss() } label: { DSIcon(name: "xmark", size: 18) }
                .dsHitTarget()
                .foregroundStyle(DS.Palette.ink2)
                .accessibilityLabel("Fermer les réglages")
        }
        .padding(.horizontal, DS.Space.x4)
        .padding(.top, DS.Space.x3)
    }

    private var tabRail: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Space.x5) {
                    ForEach(ControlTab.allCases) { item in
                        let isSelected = item == tab
                        Button {
                            withAnimation(DS.Motion.tab) { tab = item }
                            DS.Haptics.light()
                            withAnimation { proxy.scrollTo(item.id, anchor: .center) }
                        } label: {
                            VStack(spacing: DS.Space.x3) {
                                Text(item.localizedName)
                                    .dsLabel()
                                    .foregroundStyle(isSelected ? DS.Palette.safelight : DS.Palette.ink3)
                                Rectangle()
                                    .fill(isSelected ? DS.Palette.safelight : .clear)
                                    .frame(height: 2)
                            }
                            .frame(minHeight: DS.hit, alignment: .bottom)
                            .fixedSize(horizontal: true, vertical: false)
                        }
                        .buttonStyle(.plain)
                        .id(item.id)
                        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
                    }
                }
                .padding(.horizontal, DS.Space.screen)
            }
        }
        .padding(.top, DS.Space.x4)
    }

    // MARK: - Appareil

    private var deviceTab: some View {
        VStack(alignment: .leading, spacing: DS.Space.x6) {
            VStack(alignment: .leading, spacing: DS.Space.x3) {
                DSSectionLabel(text: "Appareil")
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Space.x2), count: 4),
                          spacing: DS.Space.x2) {
                    ForEach(DeviceType.allCases) { device in
                        DeviceTile(device: device, isSelected: vm.selectedDevice == device) {
                            vm.saveUndoState()
                            withAnimation(DS.Motion.surface) { vm.selectedDevice = device }
                            DS.Haptics.light()
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: DS.Space.x3) {
                DSSectionLabel(text: "Finition")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Space.x1) {
                        ForEach(vm.selectedDevice.availableColors) { finish in
                            FinishSwatch(finish: finish, isSelected: vm.deviceColor == finish) {
                                vm.saveUndoState()
                                withAnimation(DS.Motion.select) { vm.deviceColor = finish }
                                DS.Haptics.light()
                            }
                        }
                    }
                }
                Text(vm.deviceColor.localizedName)
                    .dsCaption()
                    .foregroundStyle(DS.Palette.ink2)
            }

            Divider().overlay(DS.Palette.line)

            DSToggleRow(title: "Barre de statut",
                        subtitle: "Ajoute 9:41, réseau et batterie en haut de l'écran",
                        isOn: $vm.showStatusBar)

            if vm.showStatusBar {
                DSNote(icon: "exclamationmark.triangle",
                       text: "Si votre capture contient déjà une barre de statut, la laisser activée en créerait une seconde.")
                    .transition(.opacity)
            }

            if vm.showStatusBar && vm.composition.deviceIsLandscape {
                DSNote(text: "En paysage, l'iPhone masque sa barre de statut : elle ne s'affiche qu'en portrait.")
                    .transition(.opacity)
            }
        }
        .animation(DS.Motion.surface, value: vm.showStatusBar)
    }

    // MARK: - Fond

    private var backgroundTab: some View {
        VStack(alignment: .leading, spacing: DS.Space.x6) {
            VStack(alignment: .leading, spacing: DS.Space.x3) {
                DSSectionLabel(text: "Type de fond")
                DSSegmented(items: BackgroundStyle.allCases,
                            selection: Binding(get: { vm.backgroundStyle },
                                               set: { vm.saveUndoState(); vm.backgroundStyle = $0 }),
                            label: \.rawValue)
            }

            switch vm.backgroundStyle {
            case .solid:
                VStack(alignment: .leading, spacing: DS.Space.x3) {
                    DSSectionLabel(text: "Teinte")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Space.x1), count: 5),
                              spacing: DS.Space.x1) {
                        ForEach(ColorPreset.presets) { preset in
                            ColorSwatch(color: preset.color,
                                        name: preset.name,
                                        isSelected: CodableColor(vm.solidColor) == CodableColor(preset.color)) {
                                vm.saveUndoState()
                                withAnimation(DS.Motion.select) { vm.solidColor = preset.color }
                                DS.Haptics.light()
                            }
                        }
                    }
                    ColorPicker("Teinte personnalisée", selection: $vm.solidColor)
                        .dsBody()
                        .foregroundStyle(DS.Palette.ink)
                        .frame(minHeight: DS.hit)
                }

            case .image:
                BackgroundImagePicker(backgroundImage: $vm.backgroundImage,
                                      selectedPhotoItem: $backgroundPhotoItem)

            case .gradient, .mesh:
                VStack(alignment: .leading, spacing: DS.Space.x3) {
                    DSSectionLabel(text: "Bains")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DS.Space.x2) {
                            ForEach(GradientPreset.presets) { preset in
                                BathSwatch(preset: preset,
                                           isSelected: GradientPreset.named(matching: vm.gradientColors)?.name == preset.name) {
                                    vm.applyBath(preset)
                                }
                            }
                        }
                    }
                    Text(GradientPreset.named(matching: vm.gradientColors)?.name ?? "Bain personnalisé")
                        .dsCaption()
                        .foregroundStyle(DS.Palette.ink2)
                }
            }
        }
    }

    // MARK: - Texte

    private var captionTab: some View {
        VStack(alignment: .leading, spacing: DS.Space.x6) {
            if vm.layout.panelCount > 1 {
                VStack(alignment: .leading, spacing: DS.Space.x3) {
                    DSSectionLabel(text: "Accroche — écran 1")
                    captionField("Ce que le premier écran doit dire", text: $vm.captionText)
                }
                VStack(alignment: .leading, spacing: DS.Space.x3) {
                    DSSectionLabel(text: "Accroche — écran 2")
                    captionField("Ce que le second écran doit dire", text: $vm.captionText2)
                    Text("Chaque écran du panorama porte son accroche. L'appareil se cale sur la plus haute des deux, sans en recouvrir aucune.")
                        .dsCaption()
                        .foregroundStyle(DS.Palette.ink3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                VStack(alignment: .leading, spacing: DS.Space.x3) {
                    DSSectionLabel(text: "Accroche")
                    captionField("Ce que la capture doit dire", text: $vm.captionText)
                }
            }

            VStack(alignment: .leading, spacing: DS.Space.x3) {
                DSSectionLabel(text: "Position")
                DSSegmented(items: CaptionPosition.allCases,
                            selection: Binding(get: { vm.captionPosition },
                                               set: { vm.saveUndoState(); vm.captionPosition = $0 }),
                            label: \.rawValue)
            }

            VStack(alignment: .leading, spacing: DS.Space.x3) {
                DSSectionLabel(text: "Caractère")
                Menu {
                    ForEach(CaptionFont.all, id: \.name) { font in
                        Button {
                            vm.saveUndoState()
                            vm.captionFontName = font.name
                        } label: {
                            if vm.captionFontName == font.name {
                                Label(font.display, systemImage: "checkmark")
                            } else {
                                Text(font.display)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(CaptionFont.display(for: vm.captionFontName))
                            .dsBodyStrong()
                            .foregroundStyle(DS.Palette.ink)
                        Spacer()
                        DSIcon(name: "chevron.up.chevron.down", size: 14)
                            .foregroundStyle(DS.Palette.ink3)
                    }
                    .padding(.horizontal, DS.Space.x4)
                    .frame(minHeight: DS.hit)
                    .dsCard()
                }
            }

            DSDetentSlider(title: "Corps",
                           value: Binding(get: { Double(vm.captionFontSize) },
                                          set: { vm.captionFontSize = CGFloat($0) }),
                           range: 24...120, detent: 48, step: 2,
                           format: { "\(Int($0)) pt" },
                           onEditingChanged: { began in if began { vm.saveUndoState() } })

            DSDetentSlider(title: "Marge latérale",
                           value: Binding(get: { Double(vm.captionPadding) },
                                          set: { vm.captionPadding = CGFloat($0) }),
                           range: 0...60, detent: 20, step: 2,
                           format: { "\(Int($0))" },
                           onEditingChanged: { began in if began { vm.saveUndoState() } })

            ColorPicker("Couleur du texte", selection: $vm.captionColor)
                .dsBody()
                .foregroundStyle(DS.Palette.ink)
                .frame(minHeight: DS.hit)
        }
    }

    // MARK: - Effets

    private var effectsTab: some View {
        VStack(alignment: .leading, spacing: DS.Space.x6) {
            DSToggleRow(title: "Ombre portée",
                        subtitle: "Dans l'atelier, seul le mockup projette une ombre",
                        isOn: $vm.shadowEnabled)

            if vm.shadowEnabled {
                DSDetentSlider(title: "Densité de l'ombre",
                               value: Binding(get: { Double(vm.shadowRadius) },
                                              set: { vm.shadowRadius = CGFloat($0) }),
                               range: 0...60, detent: 30,
                               format: { "\(Int($0))" },
                               onEditingChanged: { began in if began { vm.saveUndoState() } })
            }

            DSDetentSlider(title: "Rotation",
                           value: $vm.rotation3D,
                           range: -30...30, detent: 0,
                           format: { "\(Int($0))°" },
                           onEditingChanged: { began in if began { vm.saveUndoState() } })

            DSDetentSlider(title: "Pivot",
                           value: $vm.pivot,
                           range: -30...30, detent: 0,
                           format: { "\(Int($0))°" },
                           onEditingChanged: { began in if began { vm.saveUndoState() } })

            DSNote(text: pivotNote)

            DSDetentSlider(title: "Échelle",
                           value: Binding(get: { Double(vm.scale) * 100 },
                                          set: { vm.scale = CGFloat($0 / 100) }),
                           range: 30...150, detent: 100,
                           format: { "\(Int($0)) %" },
                           onEditingChanged: { began in if began { vm.saveUndoState() } })

            DSDetentSlider(title: "Position horizontale",
                           value: Binding(get: { Double(vm.deviceXOffset) },
                                          set: { vm.deviceXOffset = CGFloat($0) }),
                           range: -600...600, detent: 0, step: 5,
                           format: { "\(Int($0))" },
                           onEditingChanged: { began in if began { vm.saveUndoState() } })

            if vm.layout.panelCount > 1 {
                DSNote(text: "À 0, l'appareil est à cheval sur la jointure : une moitié de l'écran sur chaque tirage. Décalez-le pour en montrer davantage d'un côté.")
            }

            DSDetentSlider(title: "Position verticale",
                           value: Binding(get: { Double(vm.deviceYOffset) },
                                          set: { vm.deviceYOffset = CGFloat($0) }),
                           range: -300...300, detent: 0, step: 5,
                           format: { "\(Int($0))" },
                           onEditingChanged: { began in if began { vm.saveUndoState() } })

            Text("Chaque course a un cran de rappel. Un retour franc sous le doigt marque le retour à la valeur neutre.")
                .dsCaption()
                .foregroundStyle(DS.Palette.ink3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .animation(DS.Motion.surface, value: vm.shadowEnabled)
    }

    /// Ce que le pivot fait réellement, selon la disposition.
    private var pivotNote: LocalizedStringKey {
        if vm.layout == .duo {
            return "Chaque téléphone pivote sur son propre centre, du même angle : les deux restent à leur place."
        }
        if vm.layout.panelCount > 1 {
            return "L'appareil pivote sur son propre centre. Position horizontale à 0, ce centre est sur la jointure."
        }
        return "L'appareil pivote à plat, sur son propre centre."
    }

    private func captionField(_ prompt: LocalizedStringKey, text: Binding<String>) -> some View {
        TextField(prompt, text: text, axis: .vertical)
            .dsBody()
            .foregroundStyle(DS.Palette.ink)
            .lineLimit(1...3)
            .padding(DS.Space.x3)
            .frame(minHeight: DS.hit)
            .background(DS.Palette.well, in: RoundedRectangle(cornerRadius: DS.Radius.control))
            .overlay(RoundedRectangle(cornerRadius: DS.Radius.control).stroke(DS.Palette.line, lineWidth: 1))
            .submitLabel(.done)
    }

    // MARK: - Pastilles

    private var badgesTab: some View {
        VStack(alignment: .leading, spacing: DS.Space.x6) {
            VStack(alignment: .leading, spacing: DS.Space.x3) {
                DSSectionLabel(text: "Pastilles")
                FlowChips(badges: MockupBadge.presets,
                          isActive: { preset in vm.badges.contains { $0.text == preset.text && $0.style == preset.style } },
                          action: { vm.toggleBadge(MockupBadge(text: $0.text, style: $0.style, position: $0.position)) })
                Text("Les couleurs de pastille appartiennent à votre visuel, pas à l'interface.")
                    .dsCaption()
                    .foregroundStyle(DS.Palette.ink3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !vm.badges.isEmpty {
                VStack(alignment: .leading, spacing: DS.Space.x3) {
                    DSSectionLabel(text: "Posées")
                    VStack(spacing: 0) {
                        ForEach(vm.badges) { badge in
                            HStack(spacing: DS.Space.x3) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(badge.style.backgroundColor)
                                    .frame(width: 10, height: 10)
                                Text(badge.text)
                                    .dsBodyStrong()
                                    .foregroundStyle(DS.Palette.ink)
                                Spacer()
                                Text(badge.position.localizedName)
                                    .dsLabel()
                                    .foregroundStyle(DS.Palette.ink3)
                                Button { vm.removeBadge(badge) } label: {
                                    DSIcon(name: "trash", size: 16)
                                        .foregroundStyle(DS.Palette.safelight)
                                }
                                .dsHitTarget()
                                .accessibilityLabel("Retirer la pastille \(badge.text)")
                            }
                            .padding(.horizontal, DS.Space.x4)
                            .frame(minHeight: 52)
                            if badge.id != vm.badges.last?.id {
                                Divider().overlay(DS.Palette.line)
                            }
                        }
                    }
                    .dsCard()

                    DSDetentSlider(title: "Taille des pastilles",
                                   value: Binding(get: { Double(vm.badgeScale) * 100 },
                                                  set: { vm.badgeScale = CGFloat($0 / 100) }),
                                   range: 50...300, detent: 100, step: 5,
                                   format: { "\(Int($0)) %" })
                }
            }

            customBadgeEditor
        }
    }

    // MARK: Pastille personnalisée

    private var isCustomBadgeEmpty: Bool {
        customBadgeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var customBadgeEditor: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Pastille personnalisée")

            TextField("Votre texte", text: $customBadgeText)
                .dsBody()
                .foregroundStyle(DS.Palette.ink)
                .focused($badgeFieldFocused)
                .submitLabel(.done)
                .onSubmit(addCustomBadge)
                .padding(.horizontal, DS.Space.x3)
                .frame(minHeight: DS.hit)
                .background(DS.Palette.well, in: RoundedRectangle(cornerRadius: DS.Radius.control))
                .overlay(RoundedRectangle(cornerRadius: DS.Radius.control).stroke(DS.Palette.line, lineWidth: 1))

            VStack(alignment: .leading, spacing: DS.Space.x2) {
                Text("Couleur")
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)
                HStack(spacing: DS.Space.x1) {
                    ForEach(BadgeStyle.allCases) { style in
                        BadgeStyleSwatch(style: style, isSelected: customBadgeStyle == style) {
                            withAnimation(DS.Motion.select) { customBadgeStyle = style }
                            DS.Haptics.light()
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: DS.Space.x2) {
                Text("Coin")
                    .dsLabel()
                    .foregroundStyle(DS.Palette.ink3)
                DSSegmented(items: BadgePosition.allCases,
                            selection: $customBadgePosition,
                            label: \.shortLabel)
            }

            Button(action: addCustomBadge) {
                HStack(spacing: DS.Space.x2) {
                    DSIcon(name: "plus", size: 16)
                    Text("Poser la pastille")
                }
            }
            .buttonStyle(DSGhostButton(expands: true))
            .disabled(isCustomBadgeEmpty)
            .opacity(isCustomBadgeEmpty ? 0.45 : 1)
        }
    }

    private func addCustomBadge() {
        let text = customBadgeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        badgeFieldFocused = false
        withAnimation(DS.Motion.select) {
            vm.addBadge(MockupBadge(text: text, style: customBadgeStyle, position: customBadgePosition))
            customBadgeText = ""
        }
    }

    // MARK: - Cadre

    private var frameTab: some View {
        VStack(alignment: .leading, spacing: DS.Space.x4) {
            DSSectionLabel(text: "Orientation")

            DSSegmented(items: FrameOrientation.allCases,
                        selection: Binding(get: { vm.orientation },
                                           set: { vm.saveUndoState(); vm.orientation = $0 }),
                        label: \.rawValue)

            if vm.orientation == .landscape {
                DSNote(text: orientationNote)
            }

            DSSectionLabel(text: "Format de sortie")
                .padding(.top, DS.Space.x2)

            VStack(spacing: 0) {
                ForEach(ExportSizePreset.allCases) { preset in
                    let isSelected = vm.exportSizePreset == preset
                    Button {
                        vm.saveUndoState()
                        withAnimation(DS.Motion.select) { vm.exportSizePreset = preset }
                        DS.Haptics.light()
                    } label: {
                        HStack(spacing: DS.Space.x3) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(preset.localizedName)
                                    .dsBodyStrong()
                                    .foregroundStyle(DS.Palette.ink)
                                Text(preset.dimensionLabel(for: vm.orientation))
                                    .dsNumeric()
                                    .foregroundStyle(DS.Palette.ink3)
                            }
                            Spacer()
                            if isSelected {
                                DSIcon(name: "checkmark", size: 16)
                                    .foregroundStyle(DS.Palette.safelight)
                            }
                        }
                        .padding(.horizontal, DS.Space.x4)
                        .frame(minHeight: 56)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(isSelected ? [.isSelected] : [])

                    if preset != ExportSizePreset.allCases.last {
                        Divider().overlay(DS.Palette.line)
                    }
                }
            }
            .dsCard()

            if vm.layout.forcedExportSize != nil {
                DSNote(text: "La disposition « \(vm.layout.rawValue) » impose son format. Changez de disposition pour choisir librement.")
            }
        }
        .animation(DS.Motion.surface, value: vm.orientation)
    }

    /// Ce que le paysage fait réellement, selon l'appareil et le format.
    private var orientationNote: LocalizedStringKey {
        if vm.exportSizePreset.hasFixedOrientation {
            return "Le bandeau est déjà paysage : seul l'appareil se couche."
        }
        if !vm.selectedDevice.rotatesWithOrientation {
            return "Le cadre pivote. Le MacBook, déjà en paysage, reste d'aplomb."
        }
        return "Le cadre et l'appareil pivotent ensemble. Posez une capture paysage : elle remplit l'écran couché."
    }
}

// MARK: - Composants du panneau

private struct DeviceTile: View {
    let device: DeviceType
    let isSelected: Bool
    let action: () -> Void

    private var glyph: String {
        switch device {
        case .iPhone15Pro, .iPhone15: "iphone"
        case .iPadPro: "ipad"
        case .macBookPro: "laptopcomputer"
        }
    }

    private var shortName: String {
        switch device {
        case .iPhone15Pro: "15 PRO"
        case .iPhone15: "15"
        case .iPadPro: "IPAD"
        case .macBookPro: "MACBOOK"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                DSIcon(name: glyph, size: 22)
                Text(shortName)
                    .dsLabel()
            }
            .foregroundStyle(isSelected ? DS.Palette.safelight : DS.Palette.ink2)
            .frame(maxWidth: .infinity, minHeight: 76)
            .background(isSelected ? DS.Palette.safelightWash : DS.Palette.raised,
                        in: RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                    .stroke(isSelected ? DS.Palette.safelight : DS.Palette.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(device.rawValue)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

/// Pastille de finition : 28 pt visibles, 44 pt tactiles.
private struct FinishSwatch: View {
    let finish: DeviceColor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(LinearGradient(stops: finish.frameGradientStops,
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(.black.opacity(0.28), lineWidth: 1))
                .overlay(
                    Circle()
                        .stroke(DS.Palette.safelight, lineWidth: isSelected ? 2 : 0)
                        .padding(-4)
                )
                .frame(width: DS.hit, height: DS.hit)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(finish.rawValue)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

private struct ColorSwatch: View {
    let color: Color
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                .fill(color)
                .frame(height: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                        .stroke(isSelected ? DS.Palette.safelight : DS.Palette.line,
                                lineWidth: isSelected ? 2 : 1)
                )
                .frame(minHeight: DS.hit)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(name)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

/// Couleur de pastille : elle appartient au visuel, pas à l'interface.
/// La sélection, elle, reste marquée au safelight.
private struct BadgeStyleSwatch: View {
    let style: BadgeStyle
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(style.backgroundColor)
                .frame(width: 26, height: 26)
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(DS.Palette.line, lineWidth: 1))
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(DS.Palette.safelight, lineWidth: isSelected ? 2 : 0)
                        .padding(-4)
                )
                .frame(width: DS.hit, height: DS.hit)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(style.rawValue)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

private struct BathSwatch: View {
    let preset: GradientPreset
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                .fill(LinearGradient(colors: preset.colors,
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 56, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                        .stroke(isSelected ? DS.Palette.safelight : DS.Palette.line,
                                lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(preset.name)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

private struct FlowChips: View {
    let badges: [MockupBadge]
    let isActive: (MockupBadge) -> Bool
    let action: (MockupBadge) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: DS.Space.x2)],
                  alignment: .leading, spacing: DS.Space.x2) {
            ForEach(badges) { badge in
                let active = isActive(badge)
                Button { action(badge) } label: {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(badge.style.backgroundColor)
                            .frame(width: 8, height: 8)
                        Text(badge.text)
                            .dsCaption()
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        if active {
                            DSIcon(name: "checkmark", size: 12)
                        }
                    }
                    .foregroundStyle(active ? DS.Palette.safelight : DS.Palette.ink2)
                    .padding(.horizontal, DS.Space.x3)
                    .frame(minHeight: DS.hit)
                    .background(active ? DS.Palette.safelightWash : DS.Palette.raised,
                                in: RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                            .stroke(active ? DS.Palette.safelight : DS.Palette.line, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(active ? [.isSelected] : [])
            }
        }
    }
}

struct BackgroundImagePicker: View {
    @Binding var backgroundImage: UIImage?
    @Binding var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.x3) {
            DSSectionLabel(text: "Image de fond")

            if let image = backgroundImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.card))
                    Button {
                        withAnimation(DS.Motion.select) {
                            backgroundImage = nil
                            selectedPhotoItem = nil
                        }
                    } label: {
                        DSIcon(name: "xmark", size: 14)
                            .foregroundStyle(DS.Palette.onSafelight)
                            .padding(6)
                            .background(DS.Palette.safelight, in: Circle())
                    }
                    .dsHitTarget()
                    .accessibilityLabel("Retirer l'image de fond")
                }
            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack(spacing: DS.Space.x2) {
                    DSIcon(name: "photo", size: 16)
                    Text(backgroundImage == nil ? "Choisir une image" : "Changer l'image")
                }
                .foregroundStyle(DS.Palette.ink)
                .frame(maxWidth: .infinity, minHeight: DS.hit)
                .overlay(
                    RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                        .stroke(DS.Palette.lineStrong, lineWidth: 1)
                )
            }
            .onChange(of: selectedPhotoItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run { backgroundImage = image }
                    }
                }
            }
        }
    }
}

enum CaptionFont {
    static let all: [(name: String, display: String)] = [
        ("System", "Système étendu"),
        ("Avenir-Heavy", "Avenir"),
        ("Futura-Bold", "Futura"),
        ("Georgia-Bold", "Georgia"),
        ("Didot-Bold", "Didot"),
        ("Baskerville-Bold", "Baskerville"),
        ("Copperplate-Bold", "Copperplate"),
        ("HelveticaNeue-Bold", "Helvetica")
    ]

    static func display(for name: String) -> String {
        all.first { $0.name == name }?.display ?? "Système étendu"
    }
}

#Preview {
    ControlPanelView(vm: MockupEditorViewModel())
}
