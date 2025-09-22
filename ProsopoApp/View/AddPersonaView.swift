//
//  AddPersonaView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

/*
 UI unchanged from prototype.
 Workflow Changed:
 - Build fields in AddPersonaModel
 - Generate prompt via PromptService in model.createPersona()
 - Persist to Firestore via PersonaService.addPersona
*/

struct AddPersonaView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var model = AddPersonaModel()

    private let service = PersonaService()

    var body: some View {
        Form {
            //Form inputs
            Section("Create") {
                TextField("Name", text: $model.name)
                TextField("Role", text: $model.role)
                
                Picker("Tone", selection: $model.tone) {
                    ForEach(PersonaTone.allCases, id: \.self) { t in
                        Text(t.rawValue.capitalized).tag(t)
                    }
                }

                TextField("Guardrails", text: $model.guardrails, axis: .vertical)
                    .lineLimit(1...3)
                
                //Slider for choosing consistency
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

            //Create button
            Section {
                Button {
                    Task {
                        guard let uid = auth.userId else {
                            model.errorMessage = "Not signed in."
                            return
                        }
                        if let persona = await model.createPersona() {
                            do {
                                try await service.addPersona(persona, userId: uid)
                                await MainActor.run { dismiss() }
                            } catch {
                                await MainActor.run { model.errorMessage = error.localizedDescription }
                            }
                        }
                    }
                } label: {
                    if model.isCreating {
                        ProgressView().frame(maxWidth: .infinity)
                    } else {
                        Text("Create").frame(maxWidth: .infinity)
                    }
                }
                .disabled(!model.canCreate || model.isCreating)
            }
        }
        .navigationTitle("Prosopo")
        .alert("Couldn’t create persona", isPresented: .constant(model.errorMessage != nil)) {
            Button("OK") { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
