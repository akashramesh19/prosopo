//
//  RightDrawer.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

/**
 A reusable right-side drawer component.

 The drawer overlays content when opened, showing a semi-transparent
 backdrop that dismisses the drawer on tap. Width is configurable by
 fraction of screen width with a maximum cap.
 */
struct RightDrawer<Drawer: View, Content: View>: View {
    /// Binding controlling whether the drawer is open.
    @Binding var isOpen: Bool
    /// Fraction of the screen width used for the drawer, default is 0.6.
    var fraction: CGFloat = 0.6
    /// Maximum width allowed for the drawer, default is 420.
    var widthCap: CGFloat = 420

    /// Main content displayed beneath the drawer.
    @ViewBuilder var content: () -> Content
    /// Drawer content displayed when open.
    @ViewBuilder var drawer: () -> Drawer

    var body: some View {
        GeometryReader { geo in
            let w = min(widthCap, geo.size.width * fraction)

            ZStack(alignment: .trailing) {
                // Base content
                content()
                    .zIndex(0)

                if isOpen {
                    // Background overlay
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) { isOpen = false }
                        }
                        .zIndex(1)

                    // Drawer panel
                    drawer()
                        .frame(width: w)
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                        .background(.ultraThickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(radius: 12)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .zIndex(2)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isOpen)
        }
    }
}
