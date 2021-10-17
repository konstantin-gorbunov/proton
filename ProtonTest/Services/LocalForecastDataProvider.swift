//
//  LocalForecastDataProvider.swift
//  ProtonTest
//
//  Created by Kostiantyn Gorbunov on 17/10/2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

import Foundation

struct LocalForecastDataProvider: DataProvider {

    private let queue = DispatchQueue(label: "LocalForecastDataProviderQueue")

    // Completion block will be called on main queue
    func fetchForecastList(_ completion: @escaping FetchForecastCompletion) {
        guard let path = Bundle.main.url(forResource: "forecast", withExtension: "json") else {
            DispatchQueue.main.async {
                completion(.failure(DataProviderError.resourceNotFound))
            }
            return
        }

        queue.async {
            do {
                let jsonData = try Data(contentsOf: path)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let result = try decoder.decode(Forecast.self, from: jsonData)

                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(DataProviderError.parsingFailure(inner: error)))
                }
            }
        }
    }
}
