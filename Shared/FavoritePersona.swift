//
//  FavoritePersona.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 9/10/2025.
//

import Foundation

/// Represents the favourite persona shared between the app and the widget.
public struct FavoritePersona: Codable, Equatable {
    public let id: String
    public let name: String
    public let prompt: String

    public init(id: String, name: String, prompt: String) {
        self.id = id
        self.name = name
        self.prompt = prompt
    }
}
