//
//  DSDetentSlider.swift
//  Bobmockup
//
//  Une course, pas un curseur. Chaque réglage continu a une valeur neutre
//  et un cran de rappel : la valeur s'y accroche et un retour haptique
//  franc — le seul de l'application — marque le passage.
//  Bâti sur le Slider natif pour garder VoiceOver « ajustable » et le
//  comportement système au doigt.
//

import SwiftUI

struct DSDetentSlider: View {
    let title: LocalizedStringKey
    @Binding var value: Double
    let range: ClosedRange<Double>
    /// La valeur neutre. Le remplissage part d'elle, pas du bord gauche :
    /// on lit d'un coup de combien on s'en est écarté.
    var detent: Double
    var step: Double = 1
    var format: (Double) -> String
    var onEditingChanged: (Bool) -> Void = { _ in }

    @State private var isSnapped = false

    private var snapWindow: Double { (range.upperBound - range.lowerBound) * 0.035 }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.x2) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .dsBody()
                    .foregroundStyle(DS.Palette.ink)
                Spacer(minLength: DS.Space.x3)
                Text(format(value))
                    .dsNumeric()
                    .foregroundStyle(DS.Palette.safelight)
                    .animation(nil, value: value)
            }

            Slider(value: Binding(get: { value }, set: { apply($0) }),
                   in: range,
                   step: step,
                   onEditingChanged: onEditingChanged)
                .tint(DS.Palette.safelight)
                .overlay(alignment: .leading) { detentMark }
                .frame(minHeight: DS.hit)
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(format(value))
    }

    /// Le repère du cran, tracé sous la course.
    private var detentMark: some View {
        GeometryReader { geo in
            let fraction = (detent - range.lowerBound) / (range.upperBound - range.lowerBound)
            // Le bouton du Slider natif occupe ~28 pt : on garde la même marge
            // des deux côtés pour que le repère tombe exactement sous lui.
            let inset: CGFloat = 14
            let x = inset + (geo.size.width - inset * 2) * fraction
            Rectangle()
                .fill(DS.Palette.ink3)
                .frame(width: 1, height: 8)
                .position(x: x, y: geo.size.height - 2)
                .opacity(0.7)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func apply(_ newValue: Double) {
        if abs(newValue - detent) < snapWindow {
            if !isSnapped {
                isSnapped = true
                DS.Haptics.detent()
            }
            if value != detent { value = detent }
        } else {
            isSnapped = false
            value = newValue
        }
    }
}

// MARK: - Sélecteur segmenté

/// Un segmenté aux tokens de l'atelier. Le segment actif est une surface
/// plus claire, jamais une pastille colorée.
struct DSSegmented<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    let label: (Item) -> String

    var body: some View {
        HStack(spacing: 2) {
            ForEach(items, id: \.self) { item in
                let isSelected = item == selection
                Button {
                    withAnimation(DS.Motion.select) { selection = item }
                    DS.Haptics.light()
                } label: {
                    // Les libellés sont des clés du catalogue : passés tels
                    // quels, « Haut » ou « Dégradé » restaient en français
                    // dans l'interface anglaise.
                    Text(LocalizedStringKey(label(item)))
                        .dsCaption()
                        .foregroundStyle(isSelected ? DS.Palette.ink : DS.Palette.ink2)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(isSelected ? DS.Palette.raised : Color.clear)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .padding(3)
        .background(DS.Palette.well, in: RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous)
                .stroke(DS.Palette.line, lineWidth: 1)
        )
        .frame(minHeight: DS.hit)
    }
}

// MARK: - Interrupteur

struct DSToggleRow: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: DS.Space.x3) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .dsBodyStrong()
                    .foregroundStyle(DS.Palette.ink)
                if let subtitle {
                    Text(subtitle)
                        .dsCaption()
                        .foregroundStyle(DS.Palette.ink2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: DS.Space.x3)
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DS.Palette.safelight)
        }
        .frame(minHeight: DS.hit)
    }
}

// MARK: - Encart d'avertissement

/// Un encart au filet safelight. Il ne crie pas : il souligne.
struct DSNote: View {
    var icon: String = "info.circle"
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: DS.Space.x2) {
            DSIcon(name: icon, size: 16)
                .foregroundStyle(DS.Palette.safelight)
            Text(text)
                .dsCaption()
                .foregroundStyle(DS.Palette.ink2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DS.Space.x3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DS.Palette.safelightWash)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(DS.Palette.safelight)
                .frame(width: 2)
        }
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.control, style: .continuous))
    }
}
