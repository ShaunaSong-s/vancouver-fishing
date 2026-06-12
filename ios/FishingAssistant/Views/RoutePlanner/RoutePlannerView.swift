import SwiftUI
import MapKit

struct RoutePlannerView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var l10n: L10n
    @StateObject private var viewModel = RoutePlannerViewModel()
    @StateObject private var spotsVM = FishingMapViewModel()
    @StateObject private var locationManager = FishingLocationManager()
    @State private var showSettings = true
    @State private var addingWaypoint = false
    @State private var mapPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.25, longitude: -123.30),
        span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
    ))
    @State private var visibleRegion: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.25, longitude: -123.30),
        span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
    )
    @State private var selectedSpot: FishingSpot?
    
    var body: some View {
        NavigationStack {
            routeMapView
                .overlay(alignment: .top) {
                    // Top filter bar
                    VStack(spacing: 4) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                FilterChip(title: l10n.filterSalmon, icon: "🐟", isSelected: spotsVM.selectedFilter == .salmon) {
                                    spotsVM.selectedFilter = spotsVM.selectedFilter == .salmon ? nil : .salmon
                                }
                                FilterChip(title: l10n.filterCrab, icon: "🦀", isSelected: spotsVM.selectedFilter == .crab) {
                                    spotsVM.selectedFilter = spotsVM.selectedFilter == .crab ? nil : .crab
                                }
                                FilterChip(title: l10n.filterPrawn, icon: "🦐", isSelected: spotsVM.selectedFilter == .prawn) {
                                    spotsVM.selectedFilter = spotsVM.selectedFilter == .prawn ? nil : .prawn
                                }
                                FilterChip(title: l10n.filterHalibut, icon: "🐠", isSelected: spotsVM.selectedFilter == .halibut) {
                                    spotsVM.selectedFilter = spotsVM.selectedFilter == .halibut ? nil : .halibut
                                }
                                FilterChip(title: l10n.filterRockfish, icon: "🐡", isSelected: spotsVM.selectedFilter == .rockfish) {
                                    spotsVM.selectedFilter = spotsVM.selectedFilter == .rockfish ? nil : .rockfish
                                }
                            }
                            .padding(.horizontal)
                        }
                        HStack {
                            if !viewModel.customWaypoints.isEmpty {
                                Text(l10n.t("已添加 \(viewModel.customWaypoints.count) 个途经点", "\(viewModel.customWaypoints.count) waypoints"))
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                Button(action: { viewModel.clearCustomWaypoints() }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                            }
                            Spacer()
                            Button(action: { withAnimation { showSettings.toggle() } }) {
                                Image(systemName: showSettings ? "chevron.down.circle.fill" : "gearshape.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .background(Circle().fill(.ultraThinMaterial))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 50)
                }
                .overlay(alignment: .bottom) {
                    // Bottom panels — only shown content, no invisible frame
                    VStack(spacing: 0) {
                        if let spot = selectedSpot {
                            spotDetailOverlay(spot: spot)
                        }
                        if showSettings {
                            settingsPanel
                        }
                        if let result = viewModel.routeResult {
                            routeResultBar(result: result)
                        }
                    }
                }
                .navigationTitle(l10n.t("钓点航线", "Spots & Route"))
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            spotsVM.loadFishingSpots(apiService: appState.apiService)
        }
    }
    
    // MARK: - Route Map with fishing spots
    private var routeMapView: some View {
        MapReader { proxy in
            Map(position: $mapPosition, interactionModes: .all) {
                UserAnnotation()
                
                // Fishing spots + route annotations
                ForEach(combinedAnnotations) { annotation in
                    Annotation(annotation.name, coordinate: annotation.coordinate) {
                        if annotation.id.hasPrefix("fishspot_") {
                            FishingSpotMapPin(annotation: annotation)
                                .onTapGesture {
                                    if let spot = spotsVM.fishingSpots.first(where: { "fishspot_\($0.id)" == annotation.id }) {
                                        selectedSpot = spot
                                    }
                                }
                        } else {
                            RouteAnnotationView(annotation: annotation)
                        }
                    }
                }
                
                // Route polyline
                if let result = viewModel.routeResult, let ramp = viewModel.selectedRamp {
                    let coords = routeCoordinates(ramp: ramp, waypoints: result.waypoints)
                    MapPolyline(coordinates: coords)
                        .stroke(.blue, style: StrokeStyle(lineWidth: 2.5, dash: [8, 4]))
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                visibleRegion = context.region
            }
            .onTapGesture { screenPoint in
                guard addingWaypoint else { return }
                if let coordinate = proxy.convert(screenPoint, from: .local) {
                    viewModel.addCustomWaypoint(lat: coordinate.latitude, lon: coordinate.longitude)
                }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
            }
        }
        .ignoresSafeArea(edges: .all)
        .overlay(alignment: .bottomTrailing) {
            VStack(spacing: 10) {
                // Add waypoint mode toggle
                Button(action: { withAnimation { addingWaypoint.toggle() } }) {
                    Image(systemName: addingWaypoint ? "mappin.slash" : "mappin.and.ellipse")
                        .font(.title3)
                        .foregroundColor(addingWaypoint ? .red : .orange)
                        .padding(10)
                        .background(Circle().fill(.ultraThinMaterial))
                        .shadow(radius: 3)
                }
                
                // My location button
                Button(action: { centerOnUser() }) {
                    Image(systemName: "location.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(Circle().fill(.ultraThinMaterial))
                        .shadow(radius: 3)
                }
            }
            .padding(.trailing, 12)
            .padding(.bottom, showSettings ? 200 : 60)
        }
        .onAppear {
            locationManager.requestPermission()
            locationManager.startUpdating()
        }
    }
    
    private func centerOnUser() {
        if let loc = locationManager.currentLocation {
            withAnimation {
                mapPosition = .region(MKCoordinateRegion(
                    center: loc.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                ))
            }
        }
    }
    
    // Combined annotations: fishing spots + route annotations
    private var combinedAnnotations: [RouteAnnotation] {
        var annotations = viewModel.allAnnotations
        
        // Add fishing spots as annotations
        for spot in spotsVM.fishingSpots {
            annotations.append(RouteAnnotation(
                id: "fishspot_\(spot.id)",
                name: spot.name,
                coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude),
                color: spot.isRestricted ? .red : .cyan,
                icon: spot.isRestricted ? "xmark.circle.fill" : "mappin.circle.fill",
                number: nil,
                size: spot.isRestricted ? 28 : 22,
                showLabel: spot.isRestricted
            ))
        }
        
        return annotations
    }
    
    // Route coordinates for MapPolyline
    private func routeCoordinates(ramp: BoatRamp, waypoints: [Waypoint]) -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: ramp.latitude, longitude: ramp.longitude)
        ]
        coords += waypoints.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        // Return to ramp
        coords.append(CLLocationCoordinate2D(latitude: ramp.latitude, longitude: ramp.longitude))
        return coords
    }
    
    // MARK: - Settings Panel
    private var settingsPanel: some View {
        VStack(spacing: 10) {
            // Departure picker
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.green)
                Picker(l10n.routeDock, selection: $viewModel.selectedRamp) {
                    Text(l10n.routeSelectDock).tag(nil as BoatRamp?)
                    ForEach(viewModel.boatRamps) { ramp in
                        Text(ramp.name).tag(ramp as BoatRamp?)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Boat info row
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Text("HP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("150", text: $viewModel.engineHP)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 55)
                }
                HStack(spacing: 4) {
                    Text("L")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("200", text: $viewModel.fuelCapacity)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 55)
                }
                HStack(spacing: 4) {
                    Text("kts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("20", text: $viewModel.cruiseSpeed)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 50)
                }
            }
            
            // Activity toggles (compact)
            HStack(spacing: 12) {
                Toggle(isOn: $viewModel.wantsFishing) {
                    Text("🎣")
                }
                .toggleStyle(.button)
                .tint(viewModel.wantsFishing ? .blue : .gray)
                
                Toggle(isOn: $viewModel.wantsCrabbing) {
                    Text("🦀")
                }
                .toggleStyle(.button)
                .tint(viewModel.wantsCrabbing ? .orange : .gray)
                
                Toggle(isOn: $viewModel.wantsPrawning) {
                    Text("🦐")
                }
                .toggleStyle(.button)
                .tint(viewModel.wantsPrawning ? .pink : .gray)
                
                Spacer()
                
                // Calculate button
                Button(action: {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    viewModel.calculateRoute(apiService: appState.apiService)
                }) {
                    HStack(spacing: 4) {
                        if viewModel.isCalculating {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Image(systemName: "location.north.line.fill")
                            Text(l10n.t("规划", "Plan"))
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(viewModel.selectedRamp == nil ? Color.gray : Color.blue)
                    .cornerRadius(20)
                }
                .disabled(viewModel.selectedRamp == nil || viewModel.isCalculating)
            }
            
            // Error message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 8)
    }
    
    // MARK: - Route Result Bar
    private func routeResultBar(result: RouteResult) -> some View {
        VStack(spacing: 6) {
            if result.fuelWarning {
                HStack(spacing: 4) {
                    Image(systemName: "fuelpump.exclamationmark.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(l10n.t("油量可能不足！保留25%安全余量", "Low fuel warning! 25% reserve"))
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            
            // Stats row
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", result.totalDistanceNM))
                        .font(.subheadline).fontWeight(.bold)
                    Text(l10n.routeNM)
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 2) {
                    Text(String(format: "%.0f L", result.estimatedFuelL))
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(result.fuelWarning ? .red : .primary)
                    Text(l10n.t("油耗", "Fuel"))
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 2) {
                    Text(String(format: "$%.0f", result.estimatedCostCAD))
                        .font(.subheadline).fontWeight(.bold)
                    Text("CAD")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                VStack(spacing: 2) {
                    Text(String(format: "%.1fh", result.estimatedTimeHours))
                        .font(.subheadline).fontWeight(.bold)
                    Text(l10n.t("时间", "Time"))
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                }
                
                Divider().frame(height: 30)
                
                // Waypoint list (scrollable)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(result.waypoints.indices, id: \.self) { i in
                            VStack(spacing: 1) {
                                Text("\(i+1)")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white)
                                    .frame(width: 14, height: 14)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                Text(String(result.waypoints[i].name.prefix(6)))
                                    .font(.system(size: 8))
                                    .lineLimit(1)
                            }
                        }
                        VStack(spacing: 1) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 8))
                                .foregroundColor(.green)
                            Text(l10n.t("回", "Back"))
                                .font(.system(size: 8))
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }
    
    // MARK: - Spot Detail Overlay (inline, no sheet)
    private func spotDetailOverlay(spot: FishingSpot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: spot.isRestricted ? "xmark.circle.fill" : "mappin.circle.fill")
                    .foregroundColor(spot.isRestricted ? .red : .cyan)
                Text(spot.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { withAnimation { selectedSpot = nil } }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            
            if spot.isRestricted, let note = spot.restrictionNote {
                Text("⚠️ " + note)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.t("DFO 区域", "DFO Area"))
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(spot.dfoArea)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(l10n.t("目标鱼种", "Target Species"))
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    Text(spot.targetSpecies.prefix(3).joined(separator: ", "))
                        .font(.caption)
                        .lineLimit(1)
                }
            }
            
            Text(spot.bestConditions)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(spot.recommendedGear)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Route Annotation View
struct RouteAnnotationView: View {
    let annotation: RouteAnnotation
    
    var body: some View {
        VStack(spacing: 2) {
            if annotation.showLabel {
                Text(annotation.name)
                    .font(.system(size: 9))
                    .fontWeight(.bold)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(annotation.color.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            ZStack {
                Circle()
                    .fill(annotation.color)
                    .frame(width: annotation.size, height: annotation.size)
                    .shadow(color: annotation.color.opacity(0.4), radius: 3)
                
                if let number = annotation.number {
                    Text("\(number)")
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: annotation.icon)
                        .font(.system(size: annotation.size * 0.45))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Route Annotation Model
struct RouteAnnotation: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let color: Color
    let icon: String
    let number: Int?
    let size: CGFloat
    let showLabel: Bool
}

// MARK: - Fishing Spot Map Pin
struct FishingSpotMapPin: View {
    let annotation: RouteAnnotation
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: annotation.icon)
                .font(.title3)
                .foregroundColor(annotation.color)
            Text(annotation.name)
                .font(.system(size: 8))
                .fontWeight(.medium)
                .lineLimit(1)
        }
    }
}
