//
//  AboutView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Prosopo - Persona Manager")
                .font(.title2).bold()
            Text("Create your personalized Personas for better LLM experience")
                .font(.caption).bold()
            Text("Version 1.0.0")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text("Powered by OpenAI")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .padding()
        .presentationDetents([.height(160), .medium])
    }
}

#Preview {
    AboutView()
}
