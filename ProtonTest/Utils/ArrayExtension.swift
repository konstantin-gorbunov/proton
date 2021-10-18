//
//  ArrayExtension.swift
//  ProtonTest
//
//  Created by Kostiantyn Gorbunov on 18/10/2021.
//  Copyright © 2021 Proton Technologies AG. All rights reserved.
//

extension Array {
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}
