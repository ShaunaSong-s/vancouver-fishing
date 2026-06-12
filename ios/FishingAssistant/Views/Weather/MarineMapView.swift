import SwiftUI
import MapKit

// MARK: - Marine Map View (Interactive Weather + Tides on Map)
struct MarineMapView: View {
    @EnvironmentObject var l10n: L10n
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MarineMapViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.25, longitude: -123.40),
        span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map with wind overlay
            GeometryReader { geometry in
                ZStack {
                    Map(coordinateRegion: $region, annotationItems: viewModel.visibleMapPoints) { point in
                        MapAnnotation(coordinate: point.coordinate) {
                            MarinePointAnnotation(
                                point: point,
                                isSelected: point.id == viewModel.selectedPoint?.id,
                                windData: nil // Wind shown as overlay now
                            )
                                .onTapGesture {
                                    viewModel.selectPoint(point)
                                }
                        }
                    }
                    
                    // Wind color overlay (grid-based)
                    WindOverlayView(
                        region: region,
                        windDataPerPoint: viewModel.windDataPerPoint,
                        mapPoints: viewModel.mapPoints,
                        timeIndex: viewModel.currentHourTotal,
                        overlayMode: viewModel.overlayMode,
                        overlayValues: viewModel.overlayValuesPerPoint
                    )
                    .allowsHitTesting(false)
                }
                .ignoresSafeArea(edges: .all)
                .onLongPressGesture(minimumDuration: 0.5) {
                    // Placeholder — actual coordinate computed in simultaneousGesture
                }
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .local))
                        .onEnded { value in
                            switch value {
                            case .second(true, let drag):
                                guard let location = drag?.location else { return }
                                let size = geometry.size
                                let lat = region.center.latitude + (0.5 - location.y / size.height) * region.span.latitudeDelta
                                let lon = region.center.longitude + (location.x / size.width - 0.5) * region.span.longitudeDelta
                                viewModel.addCustomPoint(lat: lat, lon: lon)
                            default: break
                            }
                        }
                )
                .onAppear {
                    viewModel.fetchWindForAllPoints()
                }
                .onChange(of: appState.navigateToCoordinate?.latitude) { _ in
                    if let coord = appState.navigateToCoordinate {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            region = MKCoordinateRegion(
                                center: coord,
                                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
                            )
                        }
                        appState.navigateToCoordinate = nil
                    }
                }
            }
            
            // Top: Instructions + selected point info
            VStack(spacing: 0) {
                // Header bar
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.t("海况地图", "Marine Map"))
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(l10n.t("长按地图添加自定义观测点", "Long press map to add custom point"))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    // Time display
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(viewModel.selectedTimeDisplay)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text(viewModel.selectedDateDisplay)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 55)
                .padding(.bottom, 10)
                .background(
                    LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .top, endPoint: .bottom)
                )
                
                // Wind legend (PredictWind style)
                HStack(spacing: 4) {
                    WindLegendDot(color: Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.6), label: "<6")
                    WindLegendDot(color: Color(red: 0.0, green: 0.8, blue: 0.5).opacity(0.6), label: "6-10")
                    WindLegendDot(color: Color(red: 0.5, green: 0.8, blue: 0.1).opacity(0.6), label: "10-15")
                    WindLegendDot(color: Color(red: 0.95, green: 0.7, blue: 0.0).opacity(0.6), label: "15-20")
                    WindLegendDot(color: Color(red: 0.95, green: 0.4, blue: 0.0).opacity(0.6), label: "20-25")
                    WindLegendDot(color: Color(red: 1.0, green: 0.1, blue: 0.1).opacity(0.6), label: ">25")
                    Text(viewModel.overlayMode.unit)
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(.black.opacity(0.5)))
                .padding(.leading, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Overlay mode selector (like PredictWind layer switcher)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(MarineMapViewModel.OverlayMode.allCases, id: \.self) { mode in
                            Button(action: { viewModel.overlayMode = mode }) {
                                VStack(spacing: 2) {
                                    Image(systemName: mode.icon)
                                        .font(.system(size: 12))
                                    Text(l10n.t(mode.label.zh, mode.label.en))
                                        .font(.system(size: 9))
                                }
                                .foregroundColor(viewModel.overlayMode == mode ? .white : .white.opacity(0.6))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(viewModel.overlayMode == mode ? Color.blue : Color.white.opacity(0.15))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
                
                // Model selector
                HStack(spacing: 6) {
                    ForEach(MarineMapViewModel.WeatherModel.allCases, id: \.self) { model in
                        Button(action: { viewModel.switchModel(to: model) }) {
                            Text(model.shortName)
                                .font(.system(size: 9, weight: viewModel.selectedModel == model ? .bold : .regular))
                                .foregroundColor(viewModel.selectedModel == model ? .white : .white.opacity(0.5))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    Capsule().fill(viewModel.selectedModel == model ? Color.blue.opacity(0.8) : Color.white.opacity(0.1))
                                )
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                
                Spacer()
            }
            
            // Bottom panel: time slider + data
            VStack(spacing: 0) {
                // Time slider
                timelineSlider
                
                // Data panel (shown when point selected)
                if let point = viewModel.selectedPoint {
                    selectedPointDataPanel(point: point)
                }
            }
            
            // Saved toast
            if viewModel.showSavedToast {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(l10n.t("已保存到我的钓点", "Saved to My Spots"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.ultraThickMaterial)
                            .shadow(radius: 4)
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.3), value: viewModel.showSavedToast)
            }
        }
    }
    
    // MARK: - Timeline Slider
    private var timelineSlider: some View {
        VStack(spacing: 4) {
            // Date + time display
            HStack {
                Text(viewModel.selectedDateDisplay)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(viewModel.selectedTimeDisplay)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                Spacer()
                // Play/animate button
                Button(action: { viewModel.toggleAnimation() }) {
                    Image(systemName: viewModel.isAnimating ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            
            // Day markers on top of slider
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { day in
                    Text(viewModel.dayMarkerLabel(offset: day))
                        .font(.system(size: 8))
                        .foregroundColor(viewModel.currentDayIndex == day ? .blue : .secondary)
                        .fontWeight(viewModel.currentDayIndex == day ? .bold : .regular)
                    if day < 6 { Spacer() }
                }
            }
            .padding(.horizontal, 20)
            
            // Single continuous slider for 7 days
            HStack(spacing: 8) {
                Button(action: { viewModel.stepTime(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Slider(value: $viewModel.totalTimeValue, in: 0...1, step: 1.0 / (7.0 * 48.0))
                    .accentColor(.blue)
                    .onChange(of: viewModel.totalTimeValue) { _ in
                        viewModel.updateFromTotalTime()
                    }
                
                Button(action: { viewModel.stepTime(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 12)
            
            // Current hour within day indicator
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { day in
                    HStack(spacing: 0) {
                        if day == viewModel.currentDayIndex {
                            Text("\(viewModel.currentHourInDay)h")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.blue)
                        } else {
                            Text("")
                                .font(.system(size: 8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, 8)
    }
    
    // MARK: - Selected Point Data Panel
    private func selectedPointDataPanel(point: MarineMapPoint) -> some View {
        VStack(spacing: 8) {
            // Location name
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.blue)
                Text(point.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { viewModel.selectedPoint = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            // Weather + Tide data grid
            HStack(spacing: 12) {
                // Waves - prominently displayed
                VStack(spacing: 3) {
                    Image(systemName: "water.waves")
                        .font(.title3)
                        .foregroundColor(viewModel.currentData.waveHeight > 1.0 ? .red : (viewModel.currentData.waveHeight > 0.5 ? .orange : .green))
                    Text(String(format: "%.1f m", viewModel.currentData.waveHeight))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.currentData.waveHeight > 1.0 ? .red : (viewModel.currentData.waveHeight > 0.5 ? .orange : .primary))
                    Text(viewModel.currentData.waveHeight > 1.0 ? l10n.t("❗不建议出海", "❗Stay ashore") : (viewModel.currentData.waveHeight > 0.5 ? l10n.t("⚠️注意", "⚠️Caution") : l10n.t("浪高", "Waves")))
                        .font(.system(size: 9))
                        .foregroundColor(viewModel.currentData.waveHeight > 0.5 ? .orange : .secondary)
                }
                .frame(width: 60)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.currentData.waveHeight > 1.0 ? Color.red.opacity(0.1) : (viewModel.currentData.waveHeight > 0.5 ? Color.orange.opacity(0.1) : Color.green.opacity(0.1)))
                )
                
                // Wind
                DataBubble(
                    icon: "wind",
                    title: l10n.t("风", "Wind"),
                    value: String(format: "%.0f kts", viewModel.currentData.windSpeed),
                    subtitle: viewModel.currentData.windDirection,
                    color: viewModel.currentData.windSpeed > 20 ? .red : (viewModel.currentData.windSpeed > 15 ? .orange : .green)
                )
                
                // Tide
                DataBubble(
                    icon: viewModel.currentData.tideRising ? "arrow.up" : "arrow.down",
                    title: l10n.t("潮", "Tide"),
                    value: String(format: "%.1fm", viewModel.currentData.tideHeight),
                    subtitle: viewModel.currentData.tideRising ? l10n.t("涨", "Rise") : l10n.t("退", "Fall"),
                    color: .blue
                )
                
                // Temp
                DataBubble(
                    icon: "thermometer",
                    title: l10n.t("温", "Temp"),
                    value: String(format: "%.0f°C", viewModel.currentData.temperature),
                    subtitle: "",
                    color: viewModel.currentData.temperature < 8 ? .blue : .orange
                )
                
                // Current
                DataBubble(
                    icon: "arrow.triangle.swap",
                    title: l10n.t("流", "Curr"),
                    value: String(format: "%.1f kts", viewModel.currentData.currentSpeed),
                    subtitle: viewModel.currentData.currentDirection,
                    color: viewModel.currentData.currentSpeed > 2 ? .orange : .green
                )
            }
            
            // Safety indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(viewModel.currentData.safetyColor)
                    .frame(width: 10, height: 10)
                Text(viewModel.currentData.safetyText(l10n: l10n))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(l10n.t("下次转流: ", "Next slack: ") + viewModel.currentData.nextSlack)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Mini forecast graph (24h wind/gust/wave)
            if let graphData = viewModel.forecastGraphData(for: point) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(l10n.t("24h 预报", "24h Forecast"))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                        HStack(spacing: 8) {
                            HStack(spacing: 2) {
                                Circle().fill(.blue).frame(width: 5, height: 5)
                                Text(l10n.t("风", "Wind")).font(.system(size: 8)).foregroundColor(.secondary)
                            }
                            HStack(spacing: 2) {
                                Circle().fill(.orange).frame(width: 5, height: 5)
                                Text(l10n.t("阵风", "Gust")).font(.system(size: 8)).foregroundColor(.secondary)
                            }
                            HStack(spacing: 2) {
                                Circle().fill(.cyan).frame(width: 5, height: 5)
                                Text(l10n.t("浪", "Wave")).font(.system(size: 8)).foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Mini chart canvas
                    Canvas { context, size in
                        let maxWind = max(graphData.windSpeeds.max() ?? 20, graphData.gustSpeeds.max() ?? 25, 20)
                        let maxWave = max(graphData.waveHeights.max() ?? 1.0, 1.0)
                        let count = min(graphData.windSpeeds.count, 24)
                        guard count > 1 else { return }
                        
                        let stepX = size.width / CGFloat(count - 1)
                        
                        // Draw gust line (orange, dashed)
                        var gustPath = Path()
                        for i in 0..<count {
                            let x = CGFloat(i) * stepX
                            let y = size.height * (1 - CGFloat(graphData.gustSpeeds[i]) / CGFloat(maxWind))
                            if i == 0 { gustPath.move(to: CGPoint(x: x, y: y)) }
                            else { gustPath.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        context.stroke(gustPath, with: .color(.orange.opacity(0.6)), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
                        
                        // Draw wind line (blue)
                        var windPath = Path()
                        for i in 0..<count {
                            let x = CGFloat(i) * stepX
                            let y = size.height * (1 - CGFloat(graphData.windSpeeds[i]) / CGFloat(maxWind))
                            if i == 0 { windPath.move(to: CGPoint(x: x, y: y)) }
                            else { windPath.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        context.stroke(windPath, with: .color(.blue), style: StrokeStyle(lineWidth: 1.5))
                        
                        // Draw wave line (cyan, scaled to wave range)
                        var wavePath = Path()
                        let waveCount = min(graphData.waveHeights.count, 24)
                        for i in 0..<waveCount {
                            let x = CGFloat(i) * stepX
                            let y = size.height * (1 - CGFloat(graphData.waveHeights[i]) / CGFloat(maxWave))
                            if i == 0 { wavePath.move(to: CGPoint(x: x, y: y)) }
                            else { wavePath.addLine(to: CGPoint(x: x, y: y)) }
                        }
                        context.stroke(wavePath, with: .color(.cyan), style: StrokeStyle(lineWidth: 1.2))
                        
                        // Current time marker
                        let currentIdx = viewModel.currentHourInDay
                        if currentIdx < count {
                            let markerX = CGFloat(currentIdx) * stepX
                            var markerPath = Path()
                            markerPath.move(to: CGPoint(x: markerX, y: 0))
                            markerPath.addLine(to: CGPoint(x: markerX, y: size.height))
                            context.stroke(markerPath, with: .color(.white.opacity(0.5)), style: StrokeStyle(lineWidth: 0.8, dash: [2, 2]))
                        }
                    }
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.05)))
                    
                    // Time axis labels
                    HStack {
                        Text("0h").font(.system(size: 7)).foregroundColor(.secondary)
                        Spacer()
                        Text("6h").font(.system(size: 7)).foregroundColor(.secondary)
                        Spacer()
                        Text("12h").font(.system(size: 7)).foregroundColor(.secondary)
                        Spacer()
                        Text("18h").font(.system(size: 7)).foregroundColor(.secondary)
                        Spacer()
                        Text("24h").font(.system(size: 7)).foregroundColor(.secondary)
                    }
                }
            }
            
            // Save as fishing spot button
            Button(action: {
                viewModel.saveAsFishingSpot(point: point)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.caption)
                    Text(l10n.t("保存为我的钓点", "Save as My Spot"))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.blue))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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

// MARK: - Map Annotation View
struct MarinePointAnnotation: View {
    let point: MarineMapPoint
    let isSelected: Bool
    var windData: WindArrowData?
    
    var body: some View {
        VStack(spacing: 2) {
            if isSelected {
                Text(point.name)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
            
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.white.opacity(0.9))
                    .frame(width: isSelected ? 28 : 18, height: isSelected ? 28 : 18)
                    .shadow(color: .black.opacity(0.3), radius: 2)
                
                Image(systemName: point.icon)
                    .font(.system(size: isSelected ? 14 : 9))
                    .foregroundColor(isSelected ? .white : .blue)
            }
        }
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Wind Overlay (PredictWind-style smooth gradient + animated particles)
struct WindOverlayView: View {
    let region: MKCoordinateRegion
    let windDataPerPoint: [String: WindArrowData]
    let mapPoints: [MarineMapPoint]
    let timeIndex: Int
    let overlayMode: MarineMapViewModel.OverlayMode
    let overlayValues: [String: Double]
    
    // High resolution grid for smooth PredictWind-style color
    private let gridCols = 50
    private let gridRows = 50
    
    var body: some View {
        ZStack {
            // Layer 1: PredictWind-style smooth color gradient (mode-dependent)
            GeometryReader { geo in
                Canvas { context, size in
                    let cellW = size.width / CGFloat(gridCols)
                    let cellH = size.height / CGFloat(gridRows)
                    
                    for row in 0..<gridRows {
                        for col in 0..<gridCols {
                            let fracX = (Double(col) + 0.5) / Double(gridCols)
                            let fracY = (Double(row) + 0.5) / Double(gridRows)
                            let lat = region.center.latitude + (0.5 - fracY) * region.span.latitudeDelta
                            let lon = region.center.longitude + (fracX - 0.5) * region.span.longitudeDelta
                            
                            let value = interpolateOverlayValue(lat: lat, lon: lon)
                            let color = colorForOverlay(value: value)
                            let rect = CGRect(
                                x: CGFloat(col) * cellW,
                                y: CGFloat(row) * cellH,
                                width: cellW + 1,
                                height: cellH + 1
                            )
                            context.fill(Path(rect), with: .color(color))
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .drawingGroup()
            }
            
            // Layer 2: Animated wind particles
            WindParticlesView(
                region: region,
                windDataPerPoint: windDataPerPoint,
                mapPoints: mapPoints,
                timeIndex: timeIndex
            )
        }
    }
    
    // MARK: - PredictWind Color Scale
    // Matching PredictWind's precise wind color bands (knots):
    // 0-2: very pale blue (almost transparent)
    // 2-4: light lavender blue
    // 4-6: light blue
    // 6-8: medium blue
    // 8-10: cyan/teal
    // 10-12: green-cyan
    // 12-15: green
    // 15-18: yellow-green
    // 18-20: yellow
    // 20-25: orange
    // 25-30: red-orange
    // 30-35: red
    // 35-40: dark red/magenta
    // 40+: purple
    private func predictWindColor(speed: Double) -> Color {
        let baseOpacity = 0.85
        
        if speed <= 1 {
            return Color(red: 0.4, green: 0.5, blue: 0.95).opacity(baseOpacity * 0.3)
        } else if speed <= 2 {
            let t = (speed - 1)
            return Color(red: 0.3, green: 0.45, blue: 0.95).opacity(baseOpacity * (0.35 + t * 0.15))
        } else if speed <= 4 {
            let t = (speed - 2) / 2
            return Color(
                red: 0.15 - t * 0.1,
                green: 0.4 + t * 0.15,
                blue: 0.95
            ).opacity(baseOpacity * (0.5 + t * 0.12))
        } else if speed <= 6 {
            let t = (speed - 4) / 2
            return Color(
                red: 0.0,
                green: 0.5 + t * 0.2,
                blue: 0.95 - t * 0.1
            ).opacity(baseOpacity * (0.62 + t * 0.08))
        } else if speed <= 8 {
            let t = (speed - 6) / 2
            return Color(
                red: 0.0,
                green: 0.65 + t * 0.15,
                blue: 0.85 - t * 0.25
            ).opacity(baseOpacity * (0.7 + t * 0.06))
        } else if speed <= 10 {
            let t = (speed - 8) / 2
            return Color(
                red: 0.0,
                green: 0.8 + t * 0.1,
                blue: 0.6 - t * 0.3
            ).opacity(baseOpacity * (0.76 + t * 0.04))
        } else if speed <= 12 {
            let t = (speed - 10) / 2
            return Color(
                red: t * 0.2,
                green: 0.85 + t * 0.05,
                blue: 0.3 - t * 0.2
            ).opacity(baseOpacity * (0.8 + t * 0.04))
        } else if speed <= 15 {
            let t = (speed - 12) / 3
            return Color(
                red: 0.2 + t * 0.5,
                green: 0.9 - t * 0.05,
                blue: 0.1 - t * 0.08
            ).opacity(baseOpacity * (0.84 + t * 0.04))
        } else if speed <= 18 {
            let t = (speed - 15) / 3
            return Color(
                red: 0.7 + t * 0.25,
                green: 0.85 - t * 0.25,
                blue: 0.02
            ).opacity(baseOpacity * (0.88 + t * 0.04))
        } else if speed <= 20 {
            let t = (speed - 18) / 2
            return Color(
                red: 0.95,
                green: 0.6 - t * 0.2,
                blue: 0.0
            ).opacity(baseOpacity * 0.92)
        } else if speed <= 25 {
            let t = (speed - 20) / 5
            return Color(
                red: 0.95,
                green: 0.4 - t * 0.2,
                blue: 0.0
            ).opacity(baseOpacity * 0.94)
        } else if speed <= 30 {
            let t = (speed - 25) / 5
            return Color(
                red: 0.95 + t * 0.05,
                green: 0.2 - t * 0.12,
                blue: t * 0.05
            ).opacity(baseOpacity * 0.96)
        } else if speed <= 35 {
            let t = (speed - 30) / 5
            return Color(
                red: 1.0 - t * 0.1,
                green: 0.08 - t * 0.05,
                blue: 0.05 + t * 0.2
            ).opacity(0.92)
        } else if speed <= 40 {
            let t = (speed - 35) / 5
            return Color(
                red: 0.85 - t * 0.15,
                green: 0.03,
                blue: 0.25 + t * 0.3
            ).opacity(0.95)
        } else {
            // Extreme — deep purple
            return Color(red: 0.55, green: 0.0, blue: 0.6).opacity(0.97)
        }
    }
    
    // MARK: - Wind Barb Drawing (PredictWind streamline arrow style)
    private func drawWindBarb(context: inout GraphicsContext, center: CGPoint, speed: Double, direction: Double, cellSize: CGFloat) {
        // PredictWind style: arrow points DOWNWIND (direction wind is flowing toward)
        // Compass to CG: compass 0°=N(up), 90°=E(right). CG: 0=right, +angle=clockwise(Y-down)
        // Downwind = direction + 180 in compass terms, CG angle = (direction + 180 - 90) = direction + 90
        let angle = CGFloat((direction + 90) * .pi / 180) // Arrow points downwind (where wind goes)
        let barbLen = cellSize * 0.4
        
        // Arrowhead (tip) at downwind end, tail at upwind end
        let tip = CGPoint(
            x: center.x + cos(angle) * barbLen,
            y: center.y + sin(angle) * barbLen
        )
        let tail = CGPoint(
            x: center.x - cos(angle) * barbLen,
            y: center.y - sin(angle) * barbLen
        )
        
        var barbPath = Path()
        barbPath.move(to: tail)
        barbPath.addLine(to: tip)
        
        // Draw arrowhead at tip (downwind end)
        let arrowSize = barbLen * 0.3
        let arrowAngle1 = angle + CGFloat.pi * 0.8
        let arrowAngle2 = angle - CGFloat.pi * 0.8
        let arrow1 = CGPoint(x: tip.x + cos(arrowAngle1) * arrowSize, y: tip.y + sin(arrowAngle1) * arrowSize)
        let arrow2 = CGPoint(x: tip.x + cos(arrowAngle2) * arrowSize, y: tip.y + sin(arrowAngle2) * arrowSize)
        barbPath.move(to: arrow1)
        barbPath.addLine(to: tip)
        barbPath.addLine(to: arrow2)
        
        // Speed ticks at tail (upwind end) - like feathers
        let perpAngle = angle + .pi / 2
        let flagLen = barbLen * 0.35
        var remainingSpeed = speed
        var flagOffset: CGFloat = 0
        let flagSpacing: CGFloat = barbLen * 0.2
        
        // Pennants (50 kts) - filled triangles at tail
        while remainingSpeed >= 50 {
            let base1 = CGPoint(
                x: tail.x + cos(angle) * flagOffset,
                y: tail.y + sin(angle) * flagOffset
            )
            let base2 = CGPoint(
                x: tail.x + cos(angle) * (flagOffset + flagSpacing),
                y: tail.y + sin(angle) * (flagOffset + flagSpacing)
            )
            let flagTip = CGPoint(
                x: base1.x + cos(perpAngle) * flagLen,
                y: base1.y + sin(perpAngle) * flagLen
            )
            barbPath.move(to: base1)
            barbPath.addLine(to: flagTip)
            barbPath.addLine(to: base2)
            barbPath.closeSubpath()
            flagOffset += flagSpacing * 1.5
            remainingSpeed -= 50
        }
        
        // Full barbs (10 kts) - lines from tail
        while remainingSpeed >= 10 {
            let base = CGPoint(
                x: tail.x + cos(angle) * flagOffset,
                y: tail.y + sin(angle) * flagOffset
            )
            let flagEnd = CGPoint(
                x: base.x + cos(perpAngle) * flagLen,
                y: base.y + sin(perpAngle) * flagLen
            )
            barbPath.move(to: base)
            barbPath.addLine(to: flagEnd)
            flagOffset += flagSpacing
            remainingSpeed -= 10
        }
        
        // Half barb (5 kts)
        if remainingSpeed >= 5 {
            let base = CGPoint(
                x: tail.x + cos(angle) * flagOffset,
                y: tail.y + sin(angle) * flagOffset
            )
            let flagEnd = CGPoint(
                x: base.x + cos(perpAngle) * flagLen * 0.5,
                y: base.y + sin(perpAngle) * flagLen * 0.5
            )
            barbPath.move(to: base)
            barbPath.addLine(to: flagEnd)
        }
        
        // Draw with white stroke
        context.stroke(barbPath, with: .color(.white.opacity(0.9)), style: StrokeStyle(lineWidth: 1.8, lineCap: .round, lineJoin: .round))
        
        // Speed label below
        let speedText = Text(String(format: "%.0f", speed))
            .font(.system(size: 8, weight: .bold, design: .rounded))
            .foregroundColor(.white)
        context.draw(context.resolve(speedText), at: CGPoint(x: center.x, y: center.y + barbLen + 6))
    }
    
    // MARK: - Generic Overlay Interpolation (IDW for any overlay mode)
    private func interpolateOverlayValue(lat: Double, lon: Double) -> Double {
        var weightedValue = 0.0
        var totalWeight = 0.0
        
        for point in mapPoints {
            guard let value = overlayValues[point.id] else { continue }
            let dLat = lat - point.lat
            let dLon = lon - point.lon
            let dist = sqrt(dLat * dLat + dLon * dLon)
            
            if dist < 0.001 { return value }
            
            let weight = 1.0 / pow(dist, 2.5)
            weightedValue += value * weight
            totalWeight += weight
        }
        
        guard totalWeight > 0 else { return 10 }
        return weightedValue / totalWeight
    }
    
    // MARK: - Mode-Specific Color Mapping
    private func colorForOverlay(value: Double) -> Color {
        switch overlayMode {
        case .wind, .gust:
            return predictWindColor(speed: value)
        case .wave:
            return waveColor(height: value)
        case .temp:
            return tempColor(temp: value)
        case .pressure:
            return pressureColor(hPa: value)
        case .precipitation:
            return precipColor(mm: value)
        case .cloud:
            return cloudColor(percent: value)
        }
    }
    
    // Wave height color: blue → green → yellow → orange → red
    private func waveColor(height: Double) -> Color {
        let opacity = 0.5
        if height <= 0.1 {
            return Color(red: 0.3, green: 0.4, blue: 0.9).opacity(opacity * 0.2)
        } else if height <= 0.3 {
            let t = (height - 0.1) / 0.2
            return Color(red: 0.1, green: 0.5 + t * 0.2, blue: 0.9 - t * 0.2).opacity(opacity * 0.4)
        } else if height <= 0.5 {
            let t = (height - 0.3) / 0.2
            return Color(red: 0.0, green: 0.7 + t * 0.1, blue: 0.6 - t * 0.3).opacity(opacity * 0.6)
        } else if height <= 0.8 {
            let t = (height - 0.5) / 0.3
            return Color(red: t * 0.5, green: 0.8 - t * 0.1, blue: 0.3 - t * 0.2).opacity(opacity * 0.7)
        } else if height <= 1.2 {
            let t = (height - 0.8) / 0.4
            return Color(red: 0.5 + t * 0.4, green: 0.7 - t * 0.2, blue: 0.05).opacity(opacity * 0.8)
        } else if height <= 1.8 {
            let t = (height - 1.2) / 0.6
            return Color(red: 0.9 + t * 0.1, green: 0.5 - t * 0.3, blue: 0.0).opacity(opacity * 0.85)
        } else if height <= 2.5 {
            let t = (height - 1.8) / 0.7
            return Color(red: 1.0, green: 0.2 - t * 0.15, blue: t * 0.05).opacity(opacity * 0.9)
        } else {
            return Color(red: 0.9, green: 0.0, blue: 0.2).opacity(0.6)
        }
    }
    
    // Temperature color: purple(cold) → blue → cyan → green → yellow → orange → red(hot)
    private func tempColor(temp: Double) -> Color {
        let opacity = 0.45
        if temp <= 2 {
            return Color(red: 0.5, green: 0.0, blue: 0.8).opacity(opacity * 0.8)
        } else if temp <= 5 {
            let t = (temp - 2) / 3
            return Color(red: 0.3 - t * 0.2, green: 0.1 + t * 0.2, blue: 0.9).opacity(opacity * 0.7)
        } else if temp <= 8 {
            let t = (temp - 5) / 3
            return Color(red: 0.0, green: 0.4 + t * 0.3, blue: 0.9 - t * 0.3).opacity(opacity * 0.6)
        } else if temp <= 11 {
            let t = (temp - 8) / 3
            return Color(red: 0.0, green: 0.7 + t * 0.1, blue: 0.5 - t * 0.3).opacity(opacity * 0.6)
        } else if temp <= 14 {
            let t = (temp - 11) / 3
            return Color(red: t * 0.5, green: 0.8, blue: 0.1).opacity(opacity * 0.6)
        } else if temp <= 18 {
            let t = (temp - 14) / 4
            return Color(red: 0.5 + t * 0.4, green: 0.8 - t * 0.1, blue: 0.0).opacity(opacity * 0.7)
        } else if temp <= 22 {
            let t = (temp - 18) / 4
            return Color(red: 0.95, green: 0.6 - t * 0.3, blue: 0.0).opacity(opacity * 0.75)
        } else {
            return Color(red: 1.0, green: 0.2, blue: 0.0).opacity(opacity * 0.8)
        }
    }
    
    // Pressure color: low(red/orange) → normal(green) → high(blue)
    private func pressureColor(hPa: Double) -> Color {
        let opacity = 0.4
        if hPa <= 995 {
            return Color(red: 0.9, green: 0.2, blue: 0.1).opacity(opacity * 0.9)
        } else if hPa <= 1005 {
            let t = (hPa - 995) / 10
            return Color(red: 0.9 - t * 0.4, green: 0.3 + t * 0.4, blue: 0.1).opacity(opacity * 0.7)
        } else if hPa <= 1013 {
            let t = (hPa - 1005) / 8
            return Color(red: 0.3 - t * 0.3, green: 0.7 + t * 0.1, blue: 0.2 + t * 0.2).opacity(opacity * 0.5)
        } else if hPa <= 1020 {
            let t = (hPa - 1013) / 7
            return Color(red: 0.0, green: 0.7 - t * 0.2, blue: 0.5 + t * 0.3).opacity(opacity * 0.5)
        } else if hPa <= 1030 {
            let t = (hPa - 1020) / 10
            return Color(red: 0.1, green: 0.4 - t * 0.1, blue: 0.8 + t * 0.1).opacity(opacity * 0.6)
        } else {
            return Color(red: 0.2, green: 0.2, blue: 0.9).opacity(opacity * 0.7)
        }
    }
    
    // Precipitation color: transparent → light blue → blue → purple
    private func precipColor(mm: Double) -> Color {
        if mm <= 0.1 {
            return Color.clear
        } else if mm <= 0.5 {
            let t = (mm - 0.1) / 0.4
            return Color(red: 0.4, green: 0.6, blue: 0.95).opacity(0.2 + t * 0.2)
        } else if mm <= 1.0 {
            let t = (mm - 0.5) / 0.5
            return Color(red: 0.2 - t * 0.1, green: 0.5, blue: 0.95).opacity(0.4 + t * 0.1)
        } else if mm <= 3.0 {
            let t = (mm - 1.0) / 2.0
            return Color(red: 0.1, green: 0.3 + t * 0.1, blue: 0.9).opacity(0.5 + t * 0.1)
        } else if mm <= 7.0 {
            let t = (mm - 3.0) / 4.0
            return Color(red: 0.2 + t * 0.3, green: 0.2, blue: 0.9 - t * 0.1).opacity(0.55 + t * 0.1)
        } else {
            return Color(red: 0.6, green: 0.1, blue: 0.8).opacity(0.65)
        }
    }
    
    // Cloud cover color: clear → white overlay
    private func cloudColor(percent: Double) -> Color {
        let t = min(1.0, percent / 100.0)
        return Color.white.opacity(t * 0.5)
    }
    
    // MARK: - IDW Interpolation
    private func interpolateWind(lat: Double, lon: Double) -> (speed: Double, direction: Double) {
        var weightedSpeed = 0.0
        var sinSum = 0.0
        var cosSum = 0.0
        var totalWeight = 0.0
        
        if windDataPerPoint.isEmpty {
            let baseFactor = sin((lon + 123.5) * 3) * 4 + 12
            let dirFactor = 340.0 + cos(lat * 2) * 15
            return (baseFactor, dirFactor)
        }
        
        for point in mapPoints {
            guard let wind = windDataPerPoint[point.id] else { continue }
            let dLat = lat - point.lat
            let dLon = lon - point.lon
            let dist = sqrt(dLat * dLat + dLon * dLon)
            
            if dist < 0.001 {
                return (wind.speed, wind.directionDegrees)
            }
            
            // IDW with power 2.5 for sharper local influence
            let weight = 1.0 / pow(dist, 2.5)
            weightedSpeed += wind.speed * weight
            sinSum += sin(wind.directionDegrees * .pi / 180) * weight
            cosSum += cos(wind.directionDegrees * .pi / 180) * weight
            totalWeight += weight
        }
        
        guard totalWeight > 0 else { return (10, 340) }
        
        let avgSpeed = weightedSpeed / totalWeight
        let avgDir = atan2(sinSum / totalWeight, cosSum / totalWeight) * 180 / .pi
        return (avgSpeed, avgDir < 0 ? avgDir + 360 : avgDir)
    }
}

// MARK: - Animated Wind Particles (PredictWind signature effect)
struct WindParticlesView: View {
    let region: MKCoordinateRegion
    let windDataPerPoint: [String: WindArrowData]
    let mapPoints: [MarineMapPoint]
    let timeIndex: Int
    
    @State private var particles: [WindParticle] = []
    @State private var animationPhase: Double = 0
    
    private let particleCount = 120
    
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for particle in particles {
                    let x = particle.x * size.width
                    let y = particle.y * size.height
                    let alpha = particle.life
                    
                    // Draw particle trail
                    let trailLen: CGFloat = CGFloat(particle.speed) * 2.5
                    let angle = particle.direction * .pi / 180
                    
                    let startPt = CGPoint(
                        x: x - cos(angle) * trailLen,
                        y: y - sin(angle) * trailLen
                    )
                    let endPt = CGPoint(x: x, y: y)
                    
                    var trail = Path()
                    trail.move(to: startPt)
                    trail.addLine(to: endPt)
                    
                    context.stroke(trail, with: .color(.white.opacity(alpha * 0.7)),
                                 style: StrokeStyle(lineWidth: 1.2, lineCap: .round))
                    
                    // Particle dot
                    let dotRect = CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3)
                    context.fill(Path(ellipseIn: dotRect), with: .color(.white.opacity(alpha * 0.9)))
                }
            }
            .onAppear {
                initParticles()
                startAnimation(size: geo.size)
            }
            .onChange(of: timeIndex) { _ in
                // Re-init particles on time change
                initParticles()
            }
        }
    }
    
    private func initParticles() {
        particles = (0..<particleCount).map { _ in
            WindParticle(
                x: Double.random(in: 0...1),
                y: Double.random(in: 0...1),
                speed: 0,
                direction: 0,
                life: Double.random(in: 0.3...1.0),
                age: Double.random(in: 0...1)
            )
        }
        updateParticleWindData()
    }
    
    private func updateParticleWindData() {
        for i in 0..<particles.count {
            let lat = region.center.latitude + (0.5 - particles[i].y) * region.span.latitudeDelta
            let lon = region.center.longitude + (particles[i].x - 0.5) * region.span.longitudeDelta
            let wind = interpolateWindForParticle(lat: lat, lon: lon)
            particles[i].speed = wind.speed
            particles[i].direction = (wind.direction + 90) // Convert compass to CG screen angle (wind blows TO)
        }
    }
    
    private func startAnimation(size: CGSize) {
        // Use a timer to animate particles
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            DispatchQueue.main.async {
                advanceParticles()
            }
        }
    }
    
    private func advanceParticles() {
        for i in 0..<particles.count {
            let speedFactor = particles[i].speed * 0.0008
            let angle = particles[i].direction * .pi / 180
            
            particles[i].x += cos(angle) * speedFactor
            particles[i].y += sin(angle) * speedFactor
            particles[i].age += 0.015
            
            // Fade based on age
            if particles[i].age > 0.8 {
                particles[i].life = max(0, 1.0 - (particles[i].age - 0.8) * 5)
            }
            
            // Reset particle if off-screen or dead
            if particles[i].x < 0 || particles[i].x > 1 ||
               particles[i].y < 0 || particles[i].y > 1 ||
               particles[i].age > 1.0 {
                particles[i].x = Double.random(in: 0...1)
                particles[i].y = Double.random(in: 0...1)
                particles[i].life = 1.0
                particles[i].age = 0
                
                // Get wind at new position
                let lat = region.center.latitude + (0.5 - particles[i].y) * region.span.latitudeDelta
                let lon = region.center.longitude + (particles[i].x - 0.5) * region.span.longitudeDelta
                let wind = interpolateWindForParticle(lat: lat, lon: lon)
                particles[i].speed = wind.speed
                particles[i].direction = (wind.direction + 90)
            }
        }
    }
    
    private func interpolateWindForParticle(lat: Double, lon: Double) -> (speed: Double, direction: Double) {
        var weightedSpeed = 0.0
        var sinSum = 0.0
        var cosSum = 0.0
        var totalWeight = 0.0
        
        if windDataPerPoint.isEmpty {
            return (10, 340)
        }
        
        for point in mapPoints {
            guard let wind = windDataPerPoint[point.id] else { continue }
            let dLat = lat - point.lat
            let dLon = lon - point.lon
            let dist = sqrt(dLat * dLat + dLon * dLon)
            if dist < 0.001 { return (wind.speed, wind.directionDegrees) }
            let weight = 1.0 / pow(dist, 2.5)
            weightedSpeed += wind.speed * weight
            sinSum += sin(wind.directionDegrees * .pi / 180) * weight
            cosSum += cos(wind.directionDegrees * .pi / 180) * weight
            totalWeight += weight
        }
        
        guard totalWeight > 0 else { return (10, 340) }
        let avgSpeed = weightedSpeed / totalWeight
        let avgDir = atan2(sinSum / totalWeight, cosSum / totalWeight) * 180 / .pi
        return (avgSpeed, avgDir < 0 ? avgDir + 360 : avgDir)
    }
}

struct WindParticle {
    var x: Double
    var y: Double
    var speed: Double
    var direction: Double
    var life: Double
    var age: Double
}

// MARK: - Wind Arrow View (kept for individual point detail)
struct WindArrowView: View {
    let speed: Double
    let directionDegrees: Double
    
    var arrowColor: Color {
        if speed > 25 { return .red }
        if speed > 18 { return .orange }
        if speed > 10 { return Color(red: 0.2, green: 0.6, blue: 1.0) }
        return .green
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(String(format: "%.0f", speed))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(4)
                .background(
                    Circle()
                        .fill(arrowColor)
                        .shadow(color: arrowColor.opacity(0.5), radius: 3)
                )
        }
        .frame(width: 30, height: 30)
    }
}

// MARK: - Wind Legend Dot
struct WindLegendDot: View {
    let color: Color
    let label: String
    var body: some View {
        HStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - Data Bubble
struct DataBubble: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 8))
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption2)
                .fontWeight(.bold)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - View Model
class MarineMapViewModel: ObservableObject {
    @Published var mapPoints: [MarineMapPoint] = []
    @Published var selectedPoint: MarineMapPoint?
    @Published var timeSliderValue: Double = 0.5
    @Published var selectedDayOffset: Int = 0
    @Published var totalTimeValue: Double = 0.0 // 0-1 over 7 days
    @Published var isAnimating: Bool = false
    @Published var currentData = MarineConditionData.default
    @Published var windDataPerPoint: [String: WindArrowData] = [:]
    @Published var overlayMode: OverlayMode = .wind
    @Published var selectedModel: WeatherModel = .gem
    
    /// Overlay display modes (like PredictWind layer switcher)
    enum OverlayMode: String, CaseIterable {
        case wind = "wind"
        case gust = "gust"
        case wave = "wave"
        case temp = "temp"
        case pressure = "pressure"
        case precipitation = "rain"
        case cloud = "cloud"
        
        var icon: String {
            switch self {
            case .wind: return "wind"
            case .gust: return "wind.circle"
            case .wave: return "water.waves"
            case .temp: return "thermometer"
            case .pressure: return "barometer"
            case .precipitation: return "cloud.rain"
            case .cloud: return "cloud"
            }
        }
        
        var label: (zh: String, en: String) {
            switch self {
            case .wind: return ("风速", "Wind")
            case .gust: return ("阵风", "Gust")
            case .wave: return ("浪高", "Waves")
            case .temp: return ("气温", "Temp")
            case .pressure: return ("气压", "Pressure")
            case .precipitation: return ("降水", "Rain")
            case .cloud: return ("云量", "Cloud")
            }
        }
        
        var unit: String {
            switch self {
            case .wind, .gust: return "kts"
            case .wave: return "m"
            case .temp: return "°C"
            case .pressure: return "hPa"
            case .precipitation: return "mm"
            case .cloud: return "%"
            }
        }
    }
    
    /// Weather model selection (like PredictWind multi-model)
    enum WeatherModel: String, CaseIterable {
        case gem = "gem_seamless"
        case gfs = "gfs_seamless"
        case ecmwf = "ecmwf_ifs025"
        case icon = "icon_seamless"
        
        var displayName: String {
            switch self {
            case .gem: return "GEM 🇨🇦"
            case .gfs: return "GFS 🇺🇸"
            case .ecmwf: return "ECMWF 🇪🇺"
            case .icon: return "ICON 🇩🇪"
            }
        }
        
        var shortName: String {
            switch self {
            case .gem: return "GEM"
            case .gfs: return "GFS"
            case .ecmwf: return "ECMWF"
            case .icon: return "ICON"
            }
        }
    }
    
    /// Only non-grid points shown as map annotations
    var visibleMapPoints: [MarineMapPoint] {
        mapPoints.filter { !$0.id.hasPrefix("grid_") }
    }
    
    // Cached hourly data per point (fetched once, indexed by time)
    private var cachedWindSpeed: [String: [Double]] = [:]   // point id -> 168 hourly values
    private var cachedWindDir: [String: [Double]] = [:]
    private var cachedTemp: [String: [Double]] = [:]
    private var cachedGust: [String: [Double]] = [:]
    private var cachedWaveHeight: [String: [Double]] = [:]
    private var cachedWaveDir: [String: [Double]] = [:]
    private var cachedWavePeriod: [String: [Double]] = [:]
    private var cachedPressure: [String: [Double]] = [:]
    private var cachedPrecipitation: [String: [Double]] = [:]
    private var cachedCloudCover: [String: [Double]] = [:]
    private var dataLoaded: Bool = false
    private var lastFetchTime: Date?
    private static let cacheRefreshInterval: TimeInterval = 6 * 3600 // 6 hours
    
    /// Current overlay values per point (generic - used by color layer)
    var overlayValuesPerPoint: [String: Double] {
        let idx = currentHourTotal
        var values: [String: Double] = [:]
        for point in mapPoints {
            switch overlayMode {
            case .wind:
                values[point.id] = cachedWindSpeed[point.id]?[safe: idx] ?? windDataPerPoint[point.id]?.speed ?? 10
            case .gust:
                values[point.id] = cachedGust[point.id]?[safe: idx] ?? (cachedWindSpeed[point.id]?[safe: idx] ?? 15) * 1.3
            case .wave:
                values[point.id] = cachedWaveHeight[point.id]?[safe: idx] ?? 0.3
            case .temp:
                values[point.id] = cachedTemp[point.id]?[safe: idx] ?? 11
            case .pressure:
                values[point.id] = cachedPressure[point.id]?[safe: idx] ?? 1013
            case .precipitation:
                values[point.id] = cachedPrecipitation[point.id]?[safe: idx] ?? 0
            case .cloud:
                values[point.id] = cachedCloudCover[point.id]?[safe: idx] ?? 50
            }
        }
        return values
    }
    
    private var animationTimer: Timer?
    
    let timeLabels = ["00:00", "03:00", "06:00", "09:00", "12:00", "15:00", "18:00", "21:00", "24:00"]
    
    var currentDayIndex: Int {
        let totalHours = totalTimeValue * 7.0 * 24.0
        return min(6, Int(totalHours / 24.0))
    }
    
    var currentHourInDay: Int {
        let totalHours = totalTimeValue * 7.0 * 24.0
        return Int(totalHours) % 24
    }
    
    var currentHourTotal: Int {
        return Int(totalTimeValue * 7.0 * 24.0)
    }
    
    var selectedTimeDisplay: String {
        let totalHours = totalTimeValue * 7.0 * 24.0
        let hourInDay = Int(totalHours) % 24
        let fractionalHour = totalHours - Double(Int(totalHours))
        let minute = Int(fractionalHour * 60.0)
        let roundedMin = (minute / 15) * 15
        return String(format: "%02d:%02d", hourInDay, roundedMin)
    }
    
    var selectedDateDisplay: String {
        let date = Calendar.current.date(byAdding: .day, value: currentDayIndex, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 (EEE)"
        return formatter.string(from: date)
    }
    
    func dayMarkerLabel(offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }
    
    func updateFromTotalTime() {
        // Derive day offset and time from totalTimeValue
        let totalHours = totalTimeValue * 7 * 24
        selectedDayOffset = min(6, Int(totalHours / 24))
        let hourInDay = totalHours.truncatingRemainder(dividingBy: 24)
        timeSliderValue = hourInDay / 24.0
        // Update from cache (instant, no network)
        updateWindOverlayFromCache()
        updateSelectedPointFromCache()
    }
    
    init() {
        loadDefaultPoints()
        updateForCurrentTime()
        // Try loading from disk cache first (instant)
        if loadCacheFromDisk() {
            dataLoaded = true
            updateWindOverlayFromCache()
        } else {
            generateFallbackWindData()
        }
    }
    
    /// Generate initial wind data so overlay shows immediately before API returns
    /// Default to NNW outflow wind (typical Vancouver Georgia Strait pattern)
    private func generateFallbackWindData() {
        for point in mapPoints {
            let baseSpeed = 10.0 + sin((point.lon + 123.5) * 5) * 5.0 + cos(point.lat * 3) * 3.0
            // NNW wind (330-350°) is typical spring pattern in Georgia Strait
            let baseDir = 340.0 + sin(point.lat * 2) * 15.0 + cos(point.lon * 3) * 10.0
            windDataPerPoint[point.id] = WindArrowData(speed: max(3, baseSpeed), directionDegrees: baseDir)
        }
    }
    
    func loadDefaultPoints() {
        mapPoints = [
            // Core navigation points (user-visible)
            MarineMapPoint(id: "pt_atkinson", name: "Point Atkinson", lat: 49.330, lon: -123.264, icon: "water.waves"),
            MarineMapPoint(id: "bowen_e", name: "Bowen Island E", lat: 49.383, lon: -123.333, icon: "fish"),
            MarineMapPoint(id: "horseshoe", name: "Horseshoe Bay", lat: 49.374, lon: -123.273, icon: "ferry"),
            MarineMapPoint(id: "sand_heads", name: "Sand Heads", lat: 49.108, lon: -123.300, icon: "water.waves"),
            MarineMapPoint(id: "steveston", name: "Steveston", lat: 49.124, lon: -123.187, icon: "sailboat"),
            MarineMapPoint(id: "active_pass", name: "Active Pass", lat: 48.870, lon: -123.280, icon: "water.waves"),
            MarineMapPoint(id: "howe_sound", name: "Howe Sound", lat: 49.420, lon: -123.320, icon: "fish"),
            MarineMapPoint(id: "english_bay", name: "English Bay", lat: 49.280, lon: -123.190, icon: "sailboat"),
            MarineMapPoint(id: "indian_arm", name: "Indian Arm", lat: 49.350, lon: -122.880, icon: "fish"),
            MarineMapPoint(id: "tsawwassen", name: "Tsawwassen", lat: 49.006, lon: -123.084, icon: "ferry"),
            MarineMapPoint(id: "deep_cove", name: "Deep Cove", lat: 49.330, lon: -122.950, icon: "sailboat"),
            MarineMapPoint(id: "white_rock", name: "White Rock", lat: 49.020, lon: -122.803, icon: "water.waves"),
            MarineMapPoint(id: "roberts_bank", name: "Roberts Bank", lat: 49.030, lon: -123.160, icon: "water.waves"),
            MarineMapPoint(id: "galiano_island", name: "Galiano Island", lat: 48.920, lon: -123.420, icon: "fish"),
            MarineMapPoint(id: "gabriola_pass", name: "Gabriola Pass", lat: 49.130, lon: -123.730, icon: "water.waves"),
            MarineMapPoint(id: "nanaimo_harbour", name: "Nanaimo Harbour", lat: 49.167, lon: -123.935, icon: "ferry"),
            MarineMapPoint(id: "porlier_pass", name: "Porlier Pass", lat: 49.010, lon: -123.580, icon: "water.waves"),
            MarineMapPoint(id: "thrasher_rock", name: "Thrasher Rock", lat: 49.090, lon: -123.710, icon: "fish"),
            MarineMapPoint(id: "belcarra", name: "Belcarra", lat: 49.314, lon: -122.924, icon: "sailboat"),
            MarineMapPoint(id: "vancouver_harbour", name: "Vancouver Harbour", lat: 49.295, lon: -123.115, icon: "ferry"),
            // Additional grid points for higher wind resolution
            MarineMapPoint(id: "grid_01", name: "Strait Central N", lat: 49.350, lon: -123.500, icon: "wind"),
            MarineMapPoint(id: "grid_02", name: "Strait Central S", lat: 49.150, lon: -123.500, icon: "wind"),
            MarineMapPoint(id: "grid_03", name: "Georgia Mid", lat: 49.200, lon: -123.350, icon: "wind"),
            MarineMapPoint(id: "grid_04", name: "Burrard Inlet", lat: 49.305, lon: -123.030, icon: "wind"),
            MarineMapPoint(id: "grid_05", name: "Lions Gate", lat: 49.315, lon: -123.140, icon: "wind"),
            MarineMapPoint(id: "grid_06", name: "Howe S. Mid", lat: 49.450, lon: -123.350, icon: "wind"),
            MarineMapPoint(id: "grid_07", name: "Strait S", lat: 49.050, lon: -123.400, icon: "wind"),
            MarineMapPoint(id: "grid_08", name: "Boundary Bay", lat: 49.000, lon: -122.950, icon: "wind"),
            MarineMapPoint(id: "grid_09", name: "Gulf Is. N", lat: 49.050, lon: -123.550, icon: "wind"),
            MarineMapPoint(id: "grid_10", name: "Gulf Is. S", lat: 48.950, lon: -123.500, icon: "wind"),
            MarineMapPoint(id: "grid_11", name: "Fraser Mouth", lat: 49.080, lon: -123.200, icon: "wind"),
            MarineMapPoint(id: "grid_12", name: "Passage Is.", lat: 49.345, lon: -123.310, icon: "wind"),
            MarineMapPoint(id: "grid_13", name: "Keats Is.", lat: 49.400, lon: -123.420, icon: "wind"),
            MarineMapPoint(id: "grid_14", name: "Gambier Is.", lat: 49.450, lon: -123.420, icon: "wind"),
            MarineMapPoint(id: "grid_15", name: "Trincomali Ch.", lat: 48.900, lon: -123.380, icon: "wind"),
            MarineMapPoint(id: "grid_16", name: "Valdes Is.", lat: 49.050, lon: -123.650, icon: "wind"),
            MarineMapPoint(id: "grid_17", name: "Strait NW", lat: 49.300, lon: -123.600, icon: "wind"),
            MarineMapPoint(id: "grid_18", name: "Strait NE", lat: 49.300, lon: -123.000, icon: "wind"),
            MarineMapPoint(id: "grid_19", name: "S. Gulf", lat: 48.950, lon: -123.200, icon: "wind"),
            MarineMapPoint(id: "grid_20", name: "N. Howe", lat: 49.500, lon: -123.300, icon: "wind"),
        ]
    }
    
    func addCustomPoint(lat: Double, lon: Double) {
        let id = "custom_\(Int(Date().timeIntervalSince1970))"
        let name = String(format: "%.3f, %.3f", lat, lon)
        let point = MarineMapPoint(id: id, name: name, lat: lat, lon: lon, icon: "mappin")
        mapPoints.append(point)
        selectPoint(point)
        // Fetch data for new custom point
        fetchAndCachePoint(point)
    }
    
    func selectPoint(_ point: MarineMapPoint) {
        selectedPoint = point
        updateSelectedPointFromCache()
        // If not cached yet, fetch
        if cachedWindSpeed[point.id] == nil {
            fetchAndCachePoint(point)
        }
    }
    
    func updateForCurrentTime() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        timeSliderValue = (Double(hour) * 60 + Double(minute)) / (24 * 60)
        // Set totalTimeValue to now (day 0, current hour)
        totalTimeValue = (Double(hour) + Double(minute) / 60.0) / (7.0 * 24.0)
    }
    
    func updateForTime() {
        updateWindOverlayFromCache()
        updateSelectedPointFromCache()
    }
    
    // MARK: - Cache-based updates (instant, no network)
    
    /// Update wind overlay from cached data for current time index
    private func updateWindOverlayFromCache() {
        let idx = currentHourTotal
        var newData: [String: WindArrowData] = [:]
        for point in mapPoints {
            if let speeds = cachedWindSpeed[point.id], let dirs = cachedWindDir[point.id] {
                // Use cached API data
                let speed = speeds[safe: idx] ?? speeds.last ?? 12
                let dir = dirs[safe: idx] ?? dirs.last ?? 270
                newData[point.id] = WindArrowData(speed: speed, directionDegrees: dir)
            } else {
                // Time-varying fallback: NNW outflow (typical Georgia Strait)
                let hourFactor = sin(Double(idx) * 0.3 + point.lon * 2) * 4.0
                let baseSpeed = 10.0 + sin((point.lon + 123.5) * 5) * 5.0 + cos(point.lat * 3) * 3.0 + hourFactor
                let baseDir = 340.0 + sin(point.lat * 2 + Double(idx) * 0.1) * 15.0 + cos(point.lon * 3) * 10.0
                newData[point.id] = WindArrowData(speed: max(3, baseSpeed), directionDegrees: baseDir)
            }
        }
        windDataPerPoint = newData
    }
    
    /// Update selected point's condition data from cache
    private func updateSelectedPointFromCache() {
        guard let point = selectedPoint else { return }
        let idx = currentHourTotal
        let hour = currentHourInDay
        let minuteOfDayValue = Double(hour * 60)
        
        let windSpeed = cachedWindSpeed[point.id]?[safe: idx] ?? 12
        let windDir = cachedWindDir[point.id]?[safe: idx] ?? 270
        let temp = cachedTemp[point.id]?[safe: idx] ?? 11
        let gust = cachedGust[point.id]?[safe: idx] ?? windSpeed * 1.3
        let waveHt = cachedWaveHeight[point.id]?[safe: idx] ?? windSpeed * 0.05
        
        // Tide estimation based on time (semi-diurnal)
        let tidePhase = sin(minuteOfDayValue / (6.2 * 60) * .pi)
        let tideHeight = 2.8 + tidePhase * 1.8
        let tideRising = cos(minuteOfDayValue / (6.2 * 60) * .pi) > 0
        
        // Current speed estimation
        let currentSpd = abs(cos(minuteOfDayValue / (6.2 * 60) * .pi)) * 2.2
        
        // Next slack
        let currentMins = Int(minuteOfDayValue) % (6 * 60 + 12)
        let minsToSlack = 6 * 60 + 12 - currentMins
        let slackH = (hour + minsToSlack / 60) % 24
        let slackM = minsToSlack % 60
        
        self.currentData = MarineConditionData(
            windSpeed: windSpeed,
            windDirection: degreesToCompass(windDir),
            gustSpeed: gust,
            waveHeight: waveHt,
            temperature: temp,
            tideHeight: tideHeight,
            tideRising: tideRising,
            currentSpeed: currentSpd,
            currentDirection: tideRising ? "NW" : "SE",
            nextSlack: String(format: "%02d:%02d", slackH, slackM),
            safetyColor: (windSpeed > 25 || waveHt > 1.0) ? .red : ((windSpeed > 18 || waveHt > 0.5) ? .orange : .green)
        )
    }
    
    func stepTime(by steps: Int) {
        let stepSize = 1.0 / (7.0 * 48.0) // 30 min steps over 7 days
        totalTimeValue = max(0, min(1, totalTimeValue + Double(steps) * stepSize))
        updateFromTotalTime()
    }
    
    func selectDay(offset: Int) {
        selectedDayOffset = offset
        updateForTime()
    }
    
    // MARK: - Forecast Graph Data (24h from current day start)
    struct ForecastGraphPoint {
        let windSpeeds: [Double]   // 24 hourly values
        let gustSpeeds: [Double]
        let waveHeights: [Double]
    }
    
    func forecastGraphData(for point: MarineMapPoint) -> ForecastGraphPoint? {
        let dayStart = currentDayIndex * 24
        let dayEnd = min(dayStart + 24, 168)
        guard dayEnd > dayStart else { return nil }
        
        let winds = cachedWindSpeed[point.id] ?? []
        let gusts = cachedGust[point.id] ?? []
        let waves = cachedWaveHeight[point.id] ?? []
        
        guard !winds.isEmpty, dayStart < winds.count else { return nil }
        
        let safeEnd = min(dayEnd, winds.count)
        let windSlice = Array(winds[dayStart..<safeEnd])
        let gustSlice = gusts.isEmpty ? windSlice.map { $0 * 1.3 } : Array(gusts[dayStart..<min(dayEnd, gusts.count)])
        let waveSlice = waves.isEmpty ? windSlice.map { $0 * 0.04 } : Array(waves[dayStart..<min(dayEnd, waves.count)])
        
        guard !windSlice.isEmpty else { return nil }
        return ForecastGraphPoint(windSpeeds: windSlice, gustSpeeds: gustSlice, waveHeights: waveSlice)
    }
    
    func dayButtonLabel(offset: Int, l10n: L10n) -> String {
        let date = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let dateStr = formatter.string(from: date)
        if offset == 0 {
            return l10n.t("今天", "Today")
        }
        return dateStr
    }
    
    func toggleAnimation() {
        isAnimating.toggle()
        if isAnimating {
            animationTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.totalTimeValue += 1.0 / (7.0 * 48.0)
                    if self.totalTimeValue > 1.0 {
                        self.totalTimeValue = 0
                    }
                    self.updateFromTotalTime()
                }
            }
        } else {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }
    
    /// Switch weather model and re-fetch data
    func switchModel(to model: WeatherModel) {
        guard model != selectedModel else { return }
        selectedModel = model
        // Clear cache and re-fetch with new model
        dataLoaded = false
        lastFetchTime = nil
        cachedWindSpeed.removeAll()
        cachedWindDir.removeAll()
        cachedTemp.removeAll()
        cachedGust.removeAll()
        cachedPressure.removeAll()
        cachedPrecipitation.removeAll()
        cachedCloudCover.removeAll()
        generateFallbackWindData()
        fetchWindForAllPoints()
    }
    
    // MARK: - Fetch & Cache Data (single batch API call for all points)
    
    /// Fetch all points' weather data in ONE API call (avoids rate limiting)
    func fetchWindForAllPoints() {
        // If cache is fresh (< 6 hours), skip network fetch
        if dataLoaded, let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < Self.cacheRefreshInterval {
            updateWindOverlayFromCache()
            return
        }
        
        Task { @MainActor in
            // Batch all points into ONE API call (Open-Meteo supports comma-separated coords)
            let points = mapPoints.map { (id: $0.id, lat: $0.lat, lon: $0.lon) }
            
            // Split into chunks of 40 max (URL length limit)
            let chunkSize = 40
            var anySuccess = false
            
            for chunkStart in stride(from: 0, to: points.count, by: chunkSize) {
                let chunkEnd = min(chunkStart + chunkSize, points.count)
                let chunk = Array(points[chunkStart..<chunkEnd])
                
                if let results = await MarineDataService.shared.fetchBatchWeather(points: chunk, model: selectedModel.rawValue) {
                    for (id, response) in results {
                        if let hourly = response.hourly {
                            if let speeds = hourly.wind_speed_10m {
                                cachedWindSpeed[id] = speeds.compactMap { $0 }
                            }
                            if let dirs = hourly.wind_direction_10m {
                                cachedWindDir[id] = dirs.compactMap { $0 }
                            }
                            if let temps = hourly.temperature_2m {
                                cachedTemp[id] = temps.compactMap { $0 }
                            }
                            if let gusts = hourly.wind_gusts_10m {
                                cachedGust[id] = gusts.compactMap { $0 }
                            }
                            if let pressures = hourly.surface_pressure {
                                cachedPressure[id] = pressures.compactMap { $0 }
                            }
                            if let precips = hourly.precipitation {
                                cachedPrecipitation[id] = precips.compactMap { $0 }
                            }
                            if let clouds = hourly.cloud_cover {
                                cachedCloudCover[id] = clouds.compactMap { $0 }
                            }
                            anySuccess = true
                        }
                    }
                    updateWindOverlayFromCache()
                }
                
                // Small delay between chunks to avoid rate limiting
                if chunkEnd < points.count {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
            }
            
            // Also fetch wave data in batch from marine API
            for chunkStart in stride(from: 0, to: points.count, by: chunkSize) {
                let chunkEnd = min(chunkStart + chunkSize, points.count)
                let chunk = Array(points[chunkStart..<chunkEnd])
                
                if let waveResults = await MarineDataService.shared.fetchBatchWaves(points: chunk) {
                    for (id, response) in waveResults {
                        if let hourly = response.hourly {
                            if let heights = hourly.wave_height {
                                cachedWaveHeight[id] = heights.compactMap { $0 }
                            }
                            if let dirs = hourly.wave_direction {
                                cachedWaveDir[id] = dirs.compactMap { $0 }
                            }
                            if let periods = hourly.wave_period {
                                cachedWavePeriod[id] = periods.compactMap { $0 }
                            }
                        }
                    }
                }
                
                if chunkEnd < points.count {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                }
            }
            
            if anySuccess {
                dataLoaded = true
                lastFetchTime = Date()
                saveCacheToDisk()
                print("Wind data fetched: \(cachedWindSpeed.count) points cached")
            } else {
                print("Wind fetch failed - using fallback/cached data")
            }
            updateWindOverlayFromCache()
            updateSelectedPointFromCache()
        }
    }
    
    /// Fetch and cache a single point
    private func fetchAndCachePoint(_ point: MarineMapPoint) {
        Task { @MainActor in
            await fetchAndCachePointAsync(point)
            updateWindOverlayFromCache()
            updateSelectedPointFromCache()
        }
    }
    
    private func fetchAndCachePointAsync(_ point: MarineMapPoint) async {
        let weather = await MarineDataService.shared.fetchMarineWeather(lat: point.lat, lon: point.lon)
        let waves = await MarineDataService.shared.fetchWaveData(lat: point.lat, lon: point.lon)
        
        if let hourly = weather?.hourly {
            if let speeds = hourly.wind_speed_10m {
                cachedWindSpeed[point.id] = speeds.map { $0 ?? 12 }
            }
            if let dirs = hourly.wind_direction_10m {
                cachedWindDir[point.id] = dirs.map { $0 ?? 270 }
            }
            if let temps = hourly.temperature_2m {
                cachedTemp[point.id] = temps.map { $0 ?? 11 }
            }
            if let gusts = hourly.wind_gusts_10m {
                cachedGust[point.id] = gusts.map { $0 ?? 18 }
            }
        }
        
        if let waveHourly = waves?.hourly, let heights = waveHourly.wave_height {
            cachedWaveHeight[point.id] = heights.map { $0 ?? 0.3 }
        }
    }
    
    private func degreesToCompass(_ degrees: Double) -> String {
        let dirs = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees + 11.25) / 22.5) % 16
        return dirs[index]
    }
    
    // MARK: - Disk Cache (6-hour TTL)
    
    private static var cacheFileURL: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("marine_wind_cache.json")
    }
    
    private struct DiskCache: Codable {
        let timestamp: Date
        let windSpeed: [String: [Double]]
        let windDir: [String: [Double]]
        let temp: [String: [Double]]
        let gust: [String: [Double]]
        let waveHeight: [String: [Double]]
        let waveDir: [String: [Double]]?
        let wavePeriod: [String: [Double]]?
        let pressure: [String: [Double]]?
        let precipitation: [String: [Double]]?
        let cloudCover: [String: [Double]]?
    }
    
    private func saveCacheToDisk() {
        let cache = DiskCache(
            timestamp: Date(),
            windSpeed: cachedWindSpeed,
            windDir: cachedWindDir,
            temp: cachedTemp,
            gust: cachedGust,
            waveHeight: cachedWaveHeight,
            waveDir: cachedWaveDir,
            wavePeriod: cachedWavePeriod,
            pressure: cachedPressure,
            precipitation: cachedPrecipitation,
            cloudCover: cachedCloudCover
        )
        do {
            let data = try JSONEncoder().encode(cache)
            try data.write(to: Self.cacheFileURL, options: .atomic)
            print("Wind cache saved (\(data.count / 1024)KB)")
        } catch {
            print("Cache save error: \(error)")
        }
    }
    
    /// Returns true if valid cache was loaded
    private func loadCacheFromDisk() -> Bool {
        do {
            let data = try Data(contentsOf: Self.cacheFileURL)
            let cache = try JSONDecoder().decode(DiskCache.self, from: data)
            
            // Check if cache is still within 6 hours
            let age = Date().timeIntervalSince(cache.timestamp)
            guard age < Self.cacheRefreshInterval else {
                print("Wind cache expired (age: \(Int(age/3600))h)")
                return false
            }
            
            cachedWindSpeed = cache.windSpeed
            cachedWindDir = cache.windDir
            cachedTemp = cache.temp
            cachedGust = cache.gust
            cachedWaveHeight = cache.waveHeight
            cachedWaveDir = cache.waveDir ?? [:]
            cachedWavePeriod = cache.wavePeriod ?? [:]
            cachedPressure = cache.pressure ?? [:]
            cachedPrecipitation = cache.precipitation ?? [:]
            cachedCloudCover = cache.cloudCover ?? [:]
            lastFetchTime = cache.timestamp
            print("Wind cache loaded (age: \(Int(age/60))min, \(cache.windSpeed.count) points)")
            return !cache.windSpeed.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Save as My Fishing Spot
    @Published var showSavedToast = false
    
    func saveAsFishingSpot(point: MarineMapPoint) {
        let spot = MyFishingSpot(
            id: UUID().uuidString,
            name: point.name,
            latitude: point.lat,
            longitude: point.lon,
            depth: "",
            categories: [.fish],
            species: [],
            notes: "",
            lastVisited: nil,
            rating: 0
        )
        
        // Load existing spots, append, save
        var spots: [MyFishingSpot] = []
        if let data = UserDefaults.standard.data(forKey: "my_fishing_spots"),
           let decoded = try? JSONDecoder().decode([MyFishingSpot].self, from: data) {
            spots = decoded
        }
        spots.append(spot)
        if let data = try? JSONEncoder().encode(spots) {
            UserDefaults.standard.set(data, forKey: "my_fishing_spots")
        }
        showSavedToast = true
        
        // Auto-dismiss toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showSavedToast = false
        }
    }
}

// MARK: - Wind Arrow Data
struct WindArrowData {
    let speed: Double
    let directionDegrees: Double
}

// MARK: - Data Models
struct MarineMapPoint: Identifiable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let icon: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct MarineConditionData {
    let windSpeed: Double
    let windDirection: String
    let gustSpeed: Double
    let waveHeight: Double
    let temperature: Double
    let tideHeight: Double
    let tideRising: Bool
    let currentSpeed: Double
    let currentDirection: String
    let nextSlack: String
    let safetyColor: Color
    
    func safetyText(l10n: L10n) -> String {
        if windSpeed > 25 || waveHeight > 1.0 { return l10n.t("危险 - 不建议出海", "Dangerous - Stay ashore") }
        if windSpeed > 18 || waveHeight > 0.5 { return l10n.t("注意 - 浪高超0.5m不建议出海", "Caution - Waves >0.5m, not recommended") }
        return l10n.t("良好 - 适合出海", "Good - Safe to go")
    }
    
    static let `default` = MarineConditionData(
        windSpeed: 12, windDirection: "NW", gustSpeed: 18, waveHeight: 0.6,
        temperature: 11, tideHeight: 3.2, tideRising: true, currentSpeed: 1.2,
        currentDirection: "NW", nextSlack: "14:22", safetyColor: .green
    )
}
