//
//  PhotoController.swift
//  iPark
//
//  Created by Yotam Krikov on 5/15/26.
//

import SwiftUI
import PhotosUI
import Combine

class PhotoController: ObservableObject {
    
    @Published var selectedImage: UIImage? = nil
    @Published var photoPickerItem: PhotosPickerItem? = nil

    var imageExists: Bool { selectedImage != nil }

    // Load from existing CoreData binary
    func load(from data: Data?) {
        guard let data else { selectedImage = nil; return }
        selectedImage = UIImage(data: data)
    }

    // Convert current image to JPEG for saving
    var jpegData: Data? {
        selectedImage?.jpegData(compressionQuality: 0.8)
    }
    
    // Load from PhotosPicker selection
    func loadFromPicker() async {
        guard let item = photoPickerItem,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        await MainActor.run { selectedImage = image }
    }

    func clear() {
        selectedImage = nil
        photoPickerItem = nil
    }
}
