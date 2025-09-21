//
//  Item.swift
//  ProsopoApp
//
//  Created by Akash Ramesh on 21/9/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
