//
//  EditPersonaView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

/**
 A form view used to edit an existing persona.

 Styling mirrors the add screen but fields are pre-filled
 with the original persona. The prompt is regenerated via
 `PromptService` in `EditPersonaModel.save()`, followed by
 an update request to `PersonaService.updatePersona`.
 */
struct EditPersonaView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var model: EditPersonaModel
    @State private var showDeleteConfirm = false

    private let original: Persona
    
    /// Initializes the view with an existing persona.
    ///
    /// - Parameter persona: The persona being edited.
    init(persona: Persona) {
        self._model = StateObject(wrappedValue: EditPersonaModel(original: persona))
        self.original = persona
    }

    var body: some View {
        Form {
            Section("Edit") {
                TextField("Name", text: $model.name)
                TextField("Role", text: $model.role)

                Picker("Tone", selection: $model.tone) {
                    ForEach(PersonaTone.allCases, id: \.self) { t in
                        Text(t.rawValue.capitalized).tag(t)
                    }
                }

                TextField("Guardrails", text: $model.guardrails, axis: .vertical)
                    .lineLimit(1...3)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Consistency")
                    Slider(value: $model.consistency, in: 0...1)
                    HStack {
                        Text("Consistent").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text("Human-Like").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                // Save changes
                Button {
                    Task {
                        if let _ = await model.save() {
                            dismiss()
                        }
                    }
                } label: {
                    if model.isSaving {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Save Changes").frame(maxWidth: .infinity)
                    }
                }
                .disabled(model.isSaving || !model.canSave)

                // Delete persona
                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Text("Delete Persona").frame(maxWidth: .infinity)
                }
                .disabled(model.isSaving)
            }
        }
        .navigationTitle("Prosopo")
        .alert("Couldn’t save changes", isPresented: .constant(model.errorMessage != nil)) {
            Button("OK") { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
        .confirmationDialog("Delete this persona?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    if await model.delete(confirm: true) {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
