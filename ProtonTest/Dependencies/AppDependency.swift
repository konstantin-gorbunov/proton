//
//  AppDependency.swift
//  ProtonTest
//
//  Created by Kostiantyn Gorbunov on 17/10/2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

protocol Dependency {
    var liveDataProvider: DataProvider { get }
    var localDataProvider: DataProvider { get }
}

class AppDependency: Dependency {
    let liveDataProvider: DataProvider = LiveForecastDataProvider()
    var localDataProvider: DataProvider = LocalForecastDataProvider()
}
