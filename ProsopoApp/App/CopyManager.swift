//
//  CopyManager.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 9/10/2025.
//

import SwiftUI

/// Handles deep links that copy persona prompts and shows a small toast.
final class CopyManager: ObservableObject {
    @Published var copiedName: String? = nil

    func handle(url: URL) {
        guard let link = DeepLink(url: url) else { return }
        switch link {
        case .copy(let personaId):
            if let fav = FavoriteStore.load(), fav.id == personaId {
                UIPasteboard.general.string = fav.prompt
                withAnimation { self.copiedName = fav.name }
            }
        case .copyFavorite:
            if let fav = FavoriteStore.load() {
                UIPasteboard.general.string = fav.prompt
                withAnimation { self.copiedName = fav.name }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { self.copiedName = nil }
        }
    }
}

/// Small material toast for copy confirmations.
struct CopiedToast: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .padding(.top, 12)
    }
}
