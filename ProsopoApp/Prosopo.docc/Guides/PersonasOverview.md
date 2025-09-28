# Personas Overview

This guide explains how personas are modeled, persisted, and used in the UI.  
It ties together the **Model → Service → ViewModel → View** flow so you can extend features confidently.

## What is a Persona?

A persona is a reusable prompt profile with tone and consistency controls.

Key types:
- ``Persona`` – the core model (Firestore-codable) with a type-safe ``Persona/tone`` wrapper.
- ``PersonaTone`` – enum of tones used across the app.
- ``DraftPersona`` – scratch model for editing/creation before committing.

```swift
/// Simplified sketch (see the real type for full fields)
public struct Persona: Identifiable, Codable {
    public var id: String?
    public var name: String
    public var role: String
    public var toneRaw: String
    public var guardrail: String
    public var consistency: Double
    public var prompt: String
    public var userId: String?
    public var createdAt: Date
    public var updatedAt: Date

    /// Type-safe tone wrapper over persisted string.
    public var tone: PersonaTone {
        get { PersonaTone(rawValue: toneRaw) ?? .precise }
        set { toneRaw = newValue.rawValue }
    }

    /// Mapped from `consistency` to model temperature.
    public var temperature: Double
}

