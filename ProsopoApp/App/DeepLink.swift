//
//  DeepLink.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 9/10/2025.
//
import Foundation

/// Parses supported app deep links.
enum DeepLink {
    case copy(personaId: String)
    case copyFavorite

    init?(url: URL) {
        guard url.scheme == "prosopo" else { return nil }
        switch url.host?.lowercased() {
        case "copy":
            let id = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "id" })?.value
            if let id { self = .copy(personaId: id) } else { return nil }
        case "copyfavorite":
            self = .copyFavorite
        default:
            return nil
        }
    }
}
