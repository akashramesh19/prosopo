//
//  SharePromptButton.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 12/10/2025.
//

import SwiftUI

/**
 Button to share the persona prompt via the iOS share sheet.
 */
struct SharePromptButton: View {
    let persona: Persona
    @State private var showShare = false

    var body: some View {
        Button {
            showShare = true
        } label: {
            Label("Share Prompt", systemImage: "square.and.arrow.up")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(12)
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: [shareText()],
                       activities: nil,
                       excluded: nil)
        }
    }

    /// Builds a shareable text for the persona.
    private func shareText() -> String {
        """
        \(persona.name)
        Role: \(persona.role)
        Tone: \(persona.tone.rawValue.capitalized)
        Guardrails: \(persona.guardrail)
        Consistency: \(Int(100 - (persona.consistency * 100)))%

        Prompt:
        \(persona.prompt)
        """
    }
}
