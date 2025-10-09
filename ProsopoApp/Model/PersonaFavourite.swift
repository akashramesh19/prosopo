//
//  PersonaFavorite.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 9/10/2025.
//

import Foundation

/// Adds mapping from Persona to FavoritePersona.
extension Persona {
    var favoritePayload: FavoritePersona {
        FavoritePersona(
            id: id ?? UUID().uuidString,
            name: name,
            prompt: prompt
        )
    }
}
