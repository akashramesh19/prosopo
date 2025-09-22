//
//  EditPersonaView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

/*
 Mirrors Add screen styling but pre-filled with the persona.
 Regenerates prompt via PromptService (like AddPersonaModel does),
 then calls PersonaService.updatePersona.
*/

struct EditPersonaView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var role: String
    @State private var tone: PersonaTone
    @State private var guardrails: String
    @State private var consistency: Double
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let original: Persona
    private let service = PersonaService()
    private let promptService = PromptService()

    init(persona: Persona) {
        self._name = State(initialValue: persona.name)
        self._role = State(initialValue: persona.role)
        self._tone = State(initialValue: persona.tone)
        self._guardrails = State(initialValue: persona.guardrail)
        self._consistency = State(initialValue: persona.consistency)
        self.original = persona
    }

    var body: some View {
        Form {
            Section("Edit") {
                TextField("Name", text: $name)
                TextField("Role", text: $role)

                Picker("Tone", selection: $tone) {
                    ForEach(PersonaTone.allCases, id: \.self) { t in
                        Text(t.rawValue.capitalized).tag(t)
                    }
                }

                TextField("Guardrails", text: $guardrails, axis: .vertical)
                    .lineLimit(1...3)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Consistency")
                    Slider(value: $consistency, in: 0...1)
                    HStack {
                        Text("Consistent").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text("Human-Like").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                Button {
                    Task {
                        await save()
                    }
                } label: {
                    if isSaving {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Save Changes").frame(maxWidth: .infinity)
                    }
                }
                .disabled(isSaving || !canSave)

               //Delete the Persona
                Button(role: .destructive) {
                    Task {
                        await delete()
                    }
                } label: {
                    Text("Delete Persona").frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle("Prosopo")
        .alert("Couldn’t save changes", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @MainActor
    private func save() async {
        isSaving = true
        defer { isSaving = false }
        var updated = original
        updated.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.role = role.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.tone = tone
        updated.guardrail = guardrails
        updated.consistency = consistency

        do {
            //Regenerating prompt to stay consistent with Add flow
            let newPrompt = try await promptService.generatePrompt(for: updated)
            updated.prompt = newPrompt
            try await service.updatePersona(updated)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func delete() async {
        isSaving = true
        defer { isSaving = false }
        do {
            try await service.deletePersona(original)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
