//
//  Alert.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/29/26.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let timeRemaining: Int
    
    init(title: String, timeRemaining: Int){
        self.title = title
        self.timeRemaining = timeRemaining
    }
    
    func toString() -> String{
        return "\(title) has \(timeRemaining) left"
    }

}

