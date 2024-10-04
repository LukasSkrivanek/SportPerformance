//
//  PerformanceRow.swift
//  SportPerformance
//
//  Created by macbook on 02.10.2024.
//
import SwiftUI

struct PerformanceRow: View {
    @Environment(\.colorScheme) private var colorScheme
    var performance: any Performance
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(performance.title)
                    .font(.headline)
                Text(performance.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(String(format: "%.0f minutes", performance.duration )) 
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(performance.isLocal ? "Local" : "Remote")
                .foregroundColor(performance.isLocal ? .green : .blue)
                .font(.subheadline)
                .padding(5)
                .background(performance.isLocal ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                .cornerRadius(5)
        }
        .padding()
        .background(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
        .cornerRadius(10)
        .shadow(color: colorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1), radius: 2) 
    }
}
