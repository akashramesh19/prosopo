//
//  PersonaView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

/*
 UI for Viewing Persona Details.
 Contains the persona fields and a copy and open chatgpt option for the user.
*/

struct PersonaView: View {
    let persona: Persona
    @State private var showCopied = false
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Details")
                    .font(.title2).bold()
                    .padding(.top, 16)

                VStack(spacing: 12) {
                    DetailRow(title: "Name",        value: persona.name)
                    DetailRow(title: "Role",        value: persona.role)
                    DetailRow(title: "Tone",        value: persona.tone.rawValue.capitalized)
                    DetailRow(title: "Guardrails",  value: persona.guardrail)
                    DetailRow(title: "Consistency", value: consistencyLabel(persona.consistency))
                }

                VStack(spacing: 10) {
                    Button {
                        copyToClipboard(persona.prompt)
                        flashCopiedPopup()
                        openCoPilot()
                    } label: {
                        HStack(spacing: 8) {
                            Image("chatgpt_logo")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)
                            Text("Copy & Open ChatGPT")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

                    
                    Button {
                        copyToClipboard(persona.prompt)
                        flashCopiedPopup()
                        openGemini()
                    } label: {
                        HStack(spacing: 8) {
                            Image("gemini_logo")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 18)
                            Text("Copy & Open Gemini")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Button {
                        copyToClipboard(persona.prompt)
                        flashCopiedPopup()
                    } label: {
                        Label("Copy Prompt", systemImage: "doc.on.doc")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .overlay(alignment: .top) {
                if showCopied {
                    CopiedMessage()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .navigationTitle("Prosopo")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    EditPersonaView(persona: persona)
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                .accessibilityLabel("Edit Persona")
            }
        }
    }

    private func consistencyLabel(_ v: Double) -> String {
        return "\(Int(100 - (v * 100)))%"
    }

    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }

    private func flashCopiedPopup() {
        withAnimation { showCopied = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { showCopied = false }
        }
    }

    private func openChatGPT() {
        if let url = URL(string: "https://chatgpt.com/") {
            openURL(url)
        }
    }
    
    private func openGemini(){
        if let url = URL(string: "https://gemini.google.com/"){
            openURL(url)
        }
    }
}

// Reusable UI bits
private struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)

            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

//Copied popup message
private struct CopiedMessage: View {
    var body: some View {
        Text("Prompt copied")
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 3, y: 2)
            .padding(.top, 8)
    }
}
