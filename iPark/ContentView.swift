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

    @State private var showAlerts = false

    var body: some View {
                
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {

                    ZStack {
                        LogoView()
                        
                        HStack {
                            Spacer()
                            
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
                   
                    if !spots.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(spots) { spot in
                                    savedSpotCard(spot: spot)
                                }
                            }
                            .padding()
                        }
                    }


                
                    NavigationLink {
                        CreateSpotView()
                    } label: {
                        actionRow(
                            title: "Save New Spot",
                            subtitle: "Save your current parking spot.",
                            icon: "plus",
                            color: .green
                        )
                    }
                    .buttonStyle(.plain)
                    

                    NavigationLink {
                        HistoryView()
                    } label: {
                        actionRow(
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

    
    
    
    // --------------------------------------------------------------------------------------------------------------------
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
    
    private func savedSpotCard(spot: ParkingSpot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Parking Spot")
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
            if let title = spot.title, !title.isEmpty {
                Text("\(title)")
                    .font(.title3.bold())
            }
            
          
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
           
                        
            MapView(longitude: spot.longitude, latitude: spot.latitude)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .allowsHitTesting(false) 

            NavigationLink {
                SavedSpotDetailView(spot: spot)
            } label: {
                Text("View Parking Spot")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }



    
    

    private func actionRow(title: String, subtitle: String, icon: String, color: Color) -> some View {
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
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
