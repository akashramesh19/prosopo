//
//  SuggestPersonaView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 11/10/2025.
//

import SwiftUI
import FirebaseAuth

/*
 View for suggesting a persona from description input.
 The user enters a free-form description, which is processed by OpenAI.
 The mapped JSON response is shown for review before saving as a Persona.
*/

struct SuggestPersonaView: View {
    @StateObject private var model = SuggestPersonaModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            // Description input section
            Section(header: Text("Description")) {
                TextEditor(text: $model.descriptionText)
                    .frame(minHeight: 140)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.2)))

                // Button to trigger persona suggestion from description
                Button {
                    Task { await model.suggest() }
                } label: {
                    if model.isGenerating {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Suggest Persona").frame(maxWidth: .infinity)
                    }
                }
                .disabled(model.isGenerating || model.descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            // Display suggested persona if available
            if let p = model.suggested {
                Section(header: Text("Suggested")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(p.name).foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Role")
                        Spacer()
                        Text(p.role).foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Tone")
                        Spacer()
                        Text(p.tone.rawValue.capitalized).foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Guardrails")
                        Text(p.guardrail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Consistency")
                        Spacer()
                        Text(String(format: "%.2f", p.consistency)).foregroundStyle(.secondary)
                    }

                    // Button to create persona in Firestore
                    Button {
                        Task {
                            if let _ = await model.saveSuggested() {
                                dismiss()
                            }
                        }
                    } label: {
                        if model.isSaving {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Create").frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            // Error display section
            if let err = model.errorMessage, !err.isEmpty {
                Section {
                    Text(err).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Suggest Persona")
        .onAppear {
            if let uid = Auth.auth().currentUser?.uid {
                model.start(userId: uid)
            }
        }
    }
}
