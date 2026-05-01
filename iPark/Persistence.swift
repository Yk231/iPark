//
//  Persistence.swift
//  iPark2
//
//  Created by Yotam Krikov on 4/22/26.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext

        for i in 0..<3 {
            let spot = ParkingSpot(context: viewContext)
            
            spot.id = UUID()
            spot.startTime = Date()
            spot.endTime = nil
            
            spot.title = "Spot \(i)"
            spot.floor = Int16(i)
            spot.section = "A\(i)"
            spot.number = Int16(i * 10)
            spot.notes = "Test notes \(i)"
            
            spot.latitude = 0.0
            spot.longitude = 0.0
            spot.distanceTo = 0.0
            spot.timeLimitMinutes = 0
        }

        try? viewContext.save()
        return controller
        }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "iPark2")
        
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("No store description")
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }}
