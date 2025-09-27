//
//  AddPersonaView.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI
import SwiftData

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
    @Environment(\.modelContext) private var modelContext
    @StateObject private var model = AddPersonaModel()

    private let service = PersonaService()

    //Toast Pill for confirming that draft is saved
    @State private var showDraftSaved = false
    //Toast Pill when duplicate name is detected
    @State private var showDuplicateName = false

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
                        //createPersona now blocks duplicates internally and surfaces an error string
                        if let persona = await model.createPersona() {
                            do {
                                try await service.addPersona(persona, userId: uid)
                                //Deleting local draft after successful create
                                model.deleteDrafts()
                                await MainActor.run { dismiss() }
                            } catch {
                                await MainActor.run { model.errorMessage = error.localizedDescription }
                            }
                        } else {
                            //If duplicate name, show a pill and do not proceed
                            if model.errorMessage == "Persona name already exists." {
                                await MainActor.run {
                                    withAnimation { showDuplicateName = true }
                                }
                                try? await Task.sleep(nanoseconds: 1_000_000_000)
                                await MainActor.run {
                                    withAnimation { showDuplicateName = false }
                                }
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
        .onAppear {
            //Bind context + user, then load most recent draft (if any)
            model.bind(context: modelContext)
            if let uid = auth.userId {
                model.setUserId(uid)
                model.loadDraftIfAny()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    //Save draft locally and show the pill before dismiss
                    model.saveDraftIfPossible()
                    withAnimation { showDraftSaved = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation { showDraftSaved = false }
                        dismiss()
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            if showDraftSaved {
                DraftSavedPill()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .overlay(alignment: .top) {
            if showDuplicateName {
                NameExistsPill()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 40)
            }
        }
    }
}

private struct DraftSavedPill: View {
    var body: some View {
        Text("Draft saved")
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 3, y: 2)
            .padding(.top, 8)
    }
}

private struct NameExistsPill: View {
    var body: some View {
        Text("Name already exists")
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 3, y: 2)
    }
}
