//
//  Binding+EXT.swift
//  SportPerformance
//
//  Created by macbook on 01.09.2025.
//

import SwiftUI

extension Binding {
    static func twoWay<T>(
        _ keyPath: ReferenceWritableKeyPath<T, Value>,
        on object: T
    ) -> Binding<Value> where T: Observable {
        return Binding(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
}
