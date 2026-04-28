import SwiftUI
import CoreData
import CoreLocation

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var locationManager = LocationController()

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ParkingSpot.startTime, ascending: false)],
        animation: .default
    )
    private var spots: FetchedResults<ParkingSpot>
    var activeSpots: [ParkingSpot] {
        spots.filter { $0.endTime == nil }
    }

    var body: some View {
                
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    
                    /*
                    if let spot = activeSpot {
                        MapView(longitude: spot.longitude, latitude: spot.latitude, title: "Saved Spot")
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                            .shadow(radius: 5)
                            .onAppear { locationManager.startUpdating() }
                    } else if let currentPos = locationManager.currentLocation {
                        MapView(longitude: currentPos.coordinate.longitude, latitude: currentPos.coordinate.latitude, title: "You Are Here")
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 0))
                            .shadow(radius: 5)
                            .onAppear { locationManager.startUpdating() }
                    } else {


                        // Placeholder
                        ZStack {
                            Color.gray.opacity(0.1)
                            VStack {
                                ProgressView()
                                    .padding(.bottom, 8)
                                Text("Finding your location...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: 300)
                        .onAppear { locationManager.startUpdating() }
                    }
                    // ----------------------------
                     */


                    logo
                    header
                    Spacer()
                    Spacer()
                    
                    if !activeSpots.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 10) {
                                ForEach(activeSpots) { spot in
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
    
    var logo: some View {
        Text("\(Text("i").foregroundStyle(.blue))\(Text("Park"))")
            .font(.largeTitle.bold())
    }

    private func savedSpotCard(spot: ParkingSpot) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Saved Spot")
                        .font(.title3.bold())

                    Text("Your current saved parking spot.")
                        .foregroundStyle(.secondary)
                        //.fixedSize(horizontal: false, vertical: true)
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
            
                        
            MapView(longitude: spot.longitude, latitude: spot.latitude)
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .allowsHitTesting(false) 

            NavigationLink {
                SavedSpotDetailView(spot: spot)
            } label: {
                Text("View Saved Spot")
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
