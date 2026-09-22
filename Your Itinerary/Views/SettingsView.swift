//
//  SettingsView.swift
//  Your Itinerary
//
//  Created by Lyn A on 14/09/2026.
//

import SwiftUI

struct SettingsView: View {
    // @AppStorage lagrer innstillingen i UserDefaults slik at den huskes
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            Color.customBackground
                .ignoresSafeArea()
            NavigationStack {
                Form {
                    Section(header: Text("Utseende")) {
                        Toggle(isOn: $isDarkMode) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isDarkMode ? Color.purple : Color.orange)
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                }
                                
                                Text("Mørk modus")
                            }
                            .tint(.brand)
                        }
                    }
                    
                    Section(header: Text("Om appen")) {
                        HStack {
                            Text("Versjon")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .navigationTitle("Innstillinger")
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

#Preview {
    SettingsView()
}
