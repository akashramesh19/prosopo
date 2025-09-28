//
//  PersonaList.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 26/9/2025.
//

import SwiftUI

/// A scrollable list of persona tiles with view, edit, and delete actions.
struct PersonasList: View {
    /// Collection of personas to display.
    let personas: [Persona]
    /// Action triggered when a persona tile is tapped for viewing.
    let onTapView: (Persona) -> Void
    /// Action triggered when a persona tile is tapped for editing.
    let onTapEdit: (Persona) -> Void
    /// Action triggered when a persona tile is requested for deletion.
    let onAskDelete: (Persona) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(personas) { persona in
                    PersonaTile(
                        persona: persona,
                        onViewTap: { onTapView(persona) },
                        onEditTap: { onTapEdit(persona) },
                        onAskDelete: { onAskDelete(persona) }
                    )
                    .padding(.horizontal, 8)
                    .swipeActions {
                        Button(role: .destructive) { onAskDelete(persona) } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

/**
 A tile representing a single persona with multiple gesture-based actions.

 - Single tap → view persona
 - Double tap → edit persona
 - Long press → copy persona prompt
 - Triple tap → delete persona
 */
struct PersonaTile: View {
    /// Persona represented by the tile.
    let persona: Persona
    /// Action executed when tile is tapped once.
    var onViewTap:   (() -> Void)? = nil
    /// Action executed when tile is double tapped.
    var onEditTap:   (() -> Void)? = nil
    /// Action executed when tile is triple tapped or delete is requested.
    var onAskDelete: (() -> Void)? = nil

    @State private var showCopied = false
    @State private var singleTapWork: DispatchWorkItem? = nil
    @State private var pendingAny = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(persona.name)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(12)
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            .contentShape(RoundedRectangle(cornerRadius: 12))

            if showCopied {
                TileCopiedPill()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 6)
            }
        }
        // Triple tap → delete
        .highPriorityGesture(
            TapGesture(count: 3).onEnded {
                pendingAny = true
                singleTapWork?.cancel()
                onAskDelete?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { pendingAny = false }
            }
        )
        // Double tap → edit
        .gesture(
            TapGesture(count: 2).onEnded {
                pendingAny = true
                singleTapWork?.cancel()
                onEditTap?()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { pendingAny = false }
            }
        )
        // Long press → copy prompt
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.25, maximumDistance: 12)
                .onEnded { didHold in
                    if didHold {
                        pendingAny = true
                        singleTapWork?.cancel()
                        copyPrompt()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { pendingAny = false }
                    }
                }
        )
        // Single tap → view
        .simultaneousGesture(
            TapGesture(count: 1).onEnded {
                singleTapWork?.cancel()
                let work = DispatchWorkItem {
                    if !pendingAny { onViewTap?() }
                }
                singleTapWork = work
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
            }
        )
        .accessibilityLabel("\(persona.name). Tap to view, double tap to edit, long press to copy, triple tap to delete.")
    }

    /// Copies the persona prompt to clipboard with haptic feedback and shows a confirmation pill.
    private func copyPrompt() {
        UIPasteboard.general.string = persona.prompt
        let h = UINotificationFeedbackGenerator()
        h.notificationOccurred(.success)
        withAnimation { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showCopied = false }
        }
    }
}

/// A pill view shown temporarily when a persona prompt is copied.
private struct TileCopiedPill: View {
    var body: some View {
        Text("Prompt copied")
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 3, y: 2)
    }
}
