//
//  DestinationRowView.swift
//  Your Itinerary
//
//  Created by Lyn A on 24/10/2026.
//

import SwiftUI

struct DestinationRowView: View {
    let destination: SupabaseDestination
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageName = destination.imageName, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(destination.title)
                    .font(.headline)
                Text(destination.country)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
