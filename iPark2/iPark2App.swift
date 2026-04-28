//
//  iPark2App.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/22/26.
//

import SwiftUI
import CoreData

@main
struct iPark2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
