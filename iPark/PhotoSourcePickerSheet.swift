//
//  MapPickerSheet.swift
//  iPark
//
//  Created by Yotam Krikov on 5/12/26.
//

import SwiftUI


struct PhotoSourcePickerSheet: View {
    @Binding var isPresented: Bool
    let imageExists: Bool
    let onCamera: () -> Void
    let onLibrary: () -> Void
    let onRemove: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            
            // MAIN CARD
            VStack(spacing: 0) {
                Text(imageExists ? "Replace Photo" : "Add Photo")
                    .font(.headline)
                    .padding(.vertical, 16)

                Divider()
                
                // Camera
                sourceButton(title: "Take Photo", image: "camera-icon") {
                    isPresented = false
                    onCamera()
                }
                // Photo Library
                sourceButton(title: "Choose from Library", image: "photo-library-icon"){
                    isPresented = false
                    onLibrary()
                }
                // Trash
                if imageExists {
                    sourceButton(title: "Remove Photo", image: "trash"){
                        isPresented = false
                        onRemove()
                    }
                    .foregroundStyle(.red)
                }
                

            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 12)
            
            // CANCEL CARD
            Button {
                isPresented = false
            } label: {
                Text("Cancel")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 12)
        }
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.hidden)
        .presentationBackground(.clear)
    }
    
    // MARK: - Map Row
    private func sourceButton(title: String, image: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            HStack(spacing: 14) {
                Image(image)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                Text(title)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .buttonStyle(.plain)
        
    }
    

    
}



