//
//  ForecastDay.swift
//  ProtonTest
//
//  Created by Kostiantyn Gorbunov on 17/10/2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

import Foundation

typealias Forecast = [ForecastDay]

// MARK: - ForecastElement
struct ForecastDay: Codable {
    let day, forecastDescription: String?
    let sunrise, sunset: Int?
    let chanceRain: Double?
    let high, low: Int?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case day
        case forecastDescription = "description"
        case sunrise, sunset
        case chanceRain = "chance_rain"
        case high, low, image
    }
}
