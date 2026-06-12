import SwiftUI
import MapKit

struct FishingMapView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var l10n: L10n
    @StateObject private var viewModel = FishingMapViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.15, longitude: -123.75),
        span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: viewModel.fishingSpots) { spot in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(
                        latitude: spot.latitude,
                        longitude: spot.longitude
                    )) {
                        FishingSpotPin(spot: spot)
                            .onTapGesture {
                                viewModel.selectedSpot = spot
                            }
                    }
                }
.ignoresSafeArea(edges: .all)
                
                // Filter chips
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(title: l10n.filterSalmon, icon: "🐟", isSelected: viewModel.selectedFilter == .salmon) {
                                viewModel.selectedFilter = .salmon
                            }
                            FilterChip(title: l10n.filterHalibut, icon: "🐠", isSelected: viewModel.selectedFilter == .halibut) {
                                viewModel.selectedFilter = .halibut
                            }
                            FilterChip(title: l10n.filterCrab, icon: "🦀", isSelected: viewModel.selectedFilter == .crab) {
                                viewModel.selectedFilter = .crab
                            }
                            FilterChip(title: l10n.filterPrawn, icon: "🦐", isSelected: viewModel.selectedFilter == .prawn) {
                                viewModel.selectedFilter = .prawn
                            }
                            FilterChip(title: l10n.filterRockfish, icon: "🐡", isSelected: viewModel.selectedFilter == .rockfish) {
                                viewModel.selectedFilter = .rockfish
                            }
                            FilterChip(title: l10n.filterRestricted, icon: "⚠️", isSelected: viewModel.selectedFilter == .restricted) {
                                viewModel.selectedFilter = .restricted
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 50)
                    .background(
                        LinearGradient(colors: [.black.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom)
                    )
                    
                    Spacer()
                }
            }
            .navigationTitle(l10n.mapTitle)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $viewModel.selectedSpot) { spot in
                FishingSpotDetailView(spot: spot)
            }
        }
        .onAppear {
            viewModel.loadFishingSpots(apiService: appState.apiService)
        }
    }
}

struct FishingSpotPin: View {
    let spot: FishingSpot
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: spot.isRestricted ? "xmark.circle.fill" : "mappin.circle.fill")
                .font(.title2)
                .foregroundColor(spot.isRestricted ? .red : .blue)
            Text(spot.name)
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(icon)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
            .shadow(radius: 2)
        }
    }
}

struct FishingSpotDetailView: View {
    let spot: FishingSpot
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(spot.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("DFO Area: \(spot.dfoArea)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if spot.isRestricted {
                            Label("禁渔区", systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                    
                    Divider()
                    
                    // Fish species
                    VStack(alignment: .leading, spacing: 8) {
                        Text("目标鱼种")
                            .font(.headline)
                        ForEach(spot.targetSpecies, id: \.self) { species in
                            HStack {
                                Image(systemName: "fish")
                                Text(species)
                            }
                        }
                    }
                    
                    // Best conditions
                    VStack(alignment: .leading, spacing: 8) {
                        Text("最佳条件")
                            .font(.headline)
                        Text(spot.bestConditions)
                            .foregroundColor(.secondary)
                    }
                    
                    // Recommended gear
                    VStack(alignment: .leading, spacing: 8) {
                        Text("推荐装备")
                            .font(.headline)
                        Text(spot.recommendedGear)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}
