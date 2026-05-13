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
                                    savedSpotCard(spot: spot)
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
    
    // MARK: - Saved Spot Card
    private func savedSpotCard(spot: ParkingSpot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    
                    let title = spot.title ?? "Parking Spot"
                    Text("\(title)")
                        .font(.title3.bold())

                    Text("Your current saved parking spot.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
            
            }
            
            Divider()
            
            
            // Display timer
            if spot.timeLimitMinutes > 0 {
                let startTime = spot.startTime ?? Date()
                let deadline = startTime.addingTimeInterval(Double(spot.timeLimitMinutes) * 60)
                
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let isExpired = context.date > deadline
                    
                    HStack {
                        Image(systemName: "timer")
                        if isExpired {
                            Text("Expired")
                        } else {
                            Text(timerInterval: startTime...deadline, countsDown: true)
                        }
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(isExpired ? .red : .blue)
                    .padding(.vertical, 4)
                }
            }
           
            // Map
            MapView(longitude: spot.longitude, latitude: spot.latitude)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .allowsHitTesting(false) 

            // View spot navigation to SavedSpotDetailView
            NavigationLink {
                SavedSpotDetailView(spot: spot)
            } label: {
                Text("View Parking Spot")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
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

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
