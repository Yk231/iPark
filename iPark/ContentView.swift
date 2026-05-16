import SwiftUI
import CoreData
import CoreLocation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var locationManager = LocationController()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ParkingSpot.startTime, ascending: false)],
        predicate: NSPredicate(format: "endTime == nil"),
        animation: .default
    )
    private var spots: FetchedResults<ParkingSpot>

    // MARK: - Body
    var body: some View {
                
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    ZStack {
                        LogoView()
                        
                        HStack {
                            Spacer()
                            
                            // Alerts button
                            NavigationLink {
                                alertsView()
                            } label: {
                                Image(systemName: "bell")
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.horizontal)
                    

                    header
                    Spacer()
                    Spacer()
                   
                    // Scrollable LazyHStack of ongoing parking spots
                    if !spots.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(spots) { spot in
                                    SavedSpotCard(spot: spot)
                                }
                                
                            }
                            .padding()
                        }
                    }


                
                    // Create spot button
                    NavigationLink {
                        CreateSpotView()
                    } label: {
                        ActionRow(
                            title: "Save New Spot",
                            subtitle: "Save your current parking spot.",
                            icon: "plus",
                            color: .green
                        )
                    }
                    .buttonStyle(.plain)
                    

                    // History view button
                    NavigationLink {
                        HistoryView()
                    } label: {
                        ActionRow(
                            title: "View History",
                            subtitle: "See your previous parking spots.",
                            icon: "clock.arrow.circlepath",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)
                    
                    
                    
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    
    
    
    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Text("Welcome back!")
                .font(.largeTitle.bold())

            Text("Your parking, saved.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
