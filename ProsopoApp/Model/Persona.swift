//
//  Persona.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import Foundation
import FirebaseFirestore

struct Persona: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var role: String

    ///Persisted as String in Firestore but in app it will be used through the "tone" variable that is of type PersonaTone enum
    var toneRaw: String

    var guardrail: String
    var consistency: Double

    var prompt: String
    var userId: String?
    var createdAt: Date
    
    ///Seperate updated At is created to monitor edits and sort based on recently updated personas
    var updatedAt: Date

    ///Enum is used everywhere in the app for tone
    var tone: PersonaTone {
        get { PersonaTone(rawValue: toneRaw) ?? .precise }
        set { toneRaw = newValue.rawValue }
    }

    ///Computing the temperature based on the tone and consistency values
    var temperature: Double {
        let base = baseTemperatureMap[tone] ?? 0.5
        let adjusted = base + (consistency - 0.5) * 0.4
        return max(0.0, min(1.0, adjusted))
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, role, guardrail, consistency, prompt, userId, createdAt, updatedAt
        case toneRaw = "tone"   ///Firestore field name stays "tone"
    }

    ///init for creating the Persona with enum
    init(id: String? = nil,
         name: String,
         role: String,
         tone: PersonaTone,
         guardrail: String,
         consistency: Double,
         userId: String? = nil,
         createdAt: Date = .now,
         updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.role = role
        self.toneRaw = tone.rawValue
        self.guardrail = guardrail
        self.consistency = consistency
        self.prompt = ""
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

