//
//  DraftPersona.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 24/9/2025.
//

import Foundation
import SwiftData

/**
 The Draft Persona model is used to match the storage and fetch of the drafted personas to SwiftData.
 */
@Model
final class DraftPersona {
    @Attribute(.unique) var draftKey: String
    var userId: String
    var name: String
    var role: String
    var toneRaw: String
    var guardrail: String
    var consistency: Double
    var updatedAt: Date

    init(userId: String,
         name: String = "",
         role: String = "",
         toneRaw: String = "precise",
         guardrail: String = "",
         consistency: Double = 0.5,
         updatedAt: Date = .now) {
        self.userId = userId
        self.draftKey = "\(userId)-addPersona"
        self.name = name
        self.role = role
        self.toneRaw = toneRaw
        self.guardrail = guardrail
        self.consistency = consistency
        self.updatedAt = updatedAt
    }
}
