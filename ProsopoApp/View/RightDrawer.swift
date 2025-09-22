//
//  RightDrawer.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 22/9/2025.
//

import SwiftUI

struct RightDrawer<Drawer: View, Content: View>: View {
    @Binding var isOpen: Bool
    var fraction: CGFloat = 0.6
    var widthCap: CGFloat = 420

    @ViewBuilder var content: () -> Content
    @ViewBuilder var drawer: () -> Drawer

    var body: some View {
        GeometryReader { geo in
            let w = min(widthCap, geo.size.width * fraction)

            ZStack(alignment: .trailing) {
                // main content stays untouched
                // ZIndex is expiclitly mentioned to create the hierarchy within the stack
                content()
                    .zIndex(0)

                // show overlay + drawer only when open
                if isOpen {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) { isOpen = false }
                        }
                        .zIndex(1)

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
