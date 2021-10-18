//
//  ForecastCellViewModel.swift
//  ProtonTest
//
//  Created by Kostiantyn Gorbunov on 18/10/2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

import Foundation

class ForecastCellViewModel {
    let forecast: ForecastDay
    var imageData: Data?
    var cellDescription: String? {
        if let day = forecast.day, let description = forecast.forecastDescription {
            return "Day \(day): \(description)"
        }
        return nil
    }
    var viewControllerTitle: String? {
        if let day = forecast.day {
            return "Day \(day)"
        }
        return nil
    }
    
    init(forecast: ForecastDay, imageData: Data?) {
        self.forecast = forecast
        self.imageData = imageData
    }
}
