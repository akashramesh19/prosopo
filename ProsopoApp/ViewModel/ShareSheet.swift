//
//  ShareSheet.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 12/10/2025.
//

import SwiftUI
import UIKit

/**
 UIKit share sheet from SwiftUI.

 Presents UIActivityViewController with provided items.
 */
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    var activities: [UIActivity]? = nil
    var excluded: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: activities)
        vc.excludedActivityTypes = excluded
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
