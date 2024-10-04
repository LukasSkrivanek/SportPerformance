//
//  SportPerformance.swift
//  SportPerformance
//
//  Created by macbook on 30.09.2024.
//
import Foundation
import FirebaseFirestore
import SwiftData

protocol Performance {
    var id: String {get}
    var title: String { get }
    var duration : TimeInterval { get }
    var location: String {get }
    var isLocal: Bool { get }
}

struct SportPerformanceFirestore: Codable, Identifiable, Performance {
    var id : String 
    var title: String
    var location: String
    var duration: TimeInterval
    var isLocal: Bool 
}

@Model
class SportPerformanceLocal: ObservableObject, Identifiable, Performance{
    @Attribute(.unique) var id: String
    var title: String
    var location: String
    var duration: TimeInterval
    var isLocal: Bool

    init(id: String, title: String, location: String, duration: TimeInterval, isLocal: Bool) {
        self.id = id
        self.title = title
        self.location = location
        self.duration = duration
        self.isLocal = isLocal
    }
}

