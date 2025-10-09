//
//  FavoriteStore.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 9/10/2025.
//

import Foundation
import WidgetKit

/// Provides access to the favourite persona using App Group UserDefaults when available.
public enum FavoriteStore {
    private static let appGroup = "group.com.prosopoapp"
    private static let key = "favorite_persona"

    private static var defaults: UserDefaults {
        if let d = UserDefaults(suiteName: appGroup) { return d }
        return UserDefaults.standard
    }

    /// Saves a favourite persona and refreshes widget timelines.
    public static func save(_ fav: FavoritePersona) {
        if let data = try? JSONEncoder().encode(fav) {
            defaults.set(data, forKey: key)
            WidgetCenter.shared.reloadTimelines(ofKind: "PersonasWidget")
        }
    }

    /// Loads the stored favourite persona if it exists.
    public static func load() -> FavoritePersona? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(FavoritePersona.self, from: data)
    }

    /// Clears the stored favourite persona.
    public static func clear() {
        defaults.removeObject(forKey: key)
        WidgetCenter.shared.reloadTimelines(ofKind: "PersonasWidget")
    }
}
