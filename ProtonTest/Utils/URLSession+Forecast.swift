//
//  URLSession+Forecast.swift
//  ProtonTest
//
//  Created by Kostiantyn Gorbunov on 17/10/2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

import Foundation

extension URLSession {
    private func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? decoder.decode(T.self, from: data), response, nil)
        }
    }

    func forecastTask(with url: URL, completionHandler: @escaping (Forecast?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return codableTask(with: url, completionHandler: completionHandler)
    }
}
