//
//  LiveForecastDataProvider.swift
//  ProtonTest
//
//  Created by Kostiantyn Gorbunov on 17/10/2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

import Foundation

struct LiveForecastDataProvider: DataProvider {
    
    private enum Constants {
        static let url: URL? = URL(string: "https://protonmail.github.io/proton-mobile-test/api/forecast")
    }

    func fetchForecastList(_ completion: @escaping FetchForecastCompletion) {
        guard let url = Constants.url else {
            DispatchQueue.main.async {
                completion(.failure(DataProviderError.resourceNotFound))
            }
            return
        }
        let task = URLSession.shared.forecastTask(with: url) { forecast, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(DataProviderError.parsingFailure(inner: error)))
                }
            }
            if let result = forecast {
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            }
        }
        task.resume()
    }
}
