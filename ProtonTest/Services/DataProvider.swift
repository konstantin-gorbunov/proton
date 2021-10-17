//
//  DataProvider.swift
//  ProtonTest
//
//  Created by Kostiantyn Gorbunov on 17/10/2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

import Foundation

enum DataProviderError: Error {
    case resourceNotFound
    case parsingFailure(inner: Error)
}

protocol DataProvider {
    typealias FetchForecastResult = Result<Forecast, Error>
    typealias FetchForecastCompletion = (FetchForecastResult) -> Void

    func fetchForecastList(_ completion: @escaping FetchForecastCompletion)
}
