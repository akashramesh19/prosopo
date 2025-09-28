//
//  TemperatureMap.swift
//  Prosopo
//
//  Created by Akash Ramesh on 27/8/2025.
//

import Foundation

/**
 The base temperature map that needs to be used everytime a new persona instance is being created to set the temperature value based on the persona tone and consistency selected by the user.
 This map helps to set the base temperature for the temperature formula used for the Persona's temperature.
 */

public let baseTemperatureMap: [PersonaTone: Double] = [
    .precise: 0.1,
    .concise: 0.2,
    .assertive: 0.3,
    .constructive: 0.35,
    .supportive: 0.5,
    .friendly: 0.6
]
