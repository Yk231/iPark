//
//  ActionRow.swift
//  iPark
//
//  Created by Yotam Krikov on 5/12/26.
//

import SwiftUI

struct ActionRow: View {
    
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View{
        
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .frame(width: 56, height: 56)
                .background(color.opacity(0.15))
                .foregroundStyle(color)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(.white.opacity(0.06), lineWidth: 1)
        )
        
        
        
        
    }
}
