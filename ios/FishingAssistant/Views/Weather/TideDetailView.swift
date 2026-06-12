import SwiftUI

// MARK: - Tide View (PredictWind style)
struct TideDetailView: View {
    @EnvironmentObject var l10n: L10n
    @StateObject private var viewModel = TideViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Location & Date picker
                VStack(spacing: 10) {
                    // Station picker
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Picker(l10n.t("观测站", "Station"), selection: $viewModel.selectedStation) {
                            ForEach(viewModel.stations, id: \.id) { station in
                                Text(station.name).tag(station.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: viewModel.selectedStation) { _ in
                            viewModel.refresh()
                        }
                        
                        Spacer()
                        
                        Button(action: { viewModel.refresh() }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Date picker
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .font(.caption)
                        DatePicker(
                            l10n.t("日期", "Date"),
                            selection: $viewModel.selectedDate,
                            in: Date()...Calendar.current.date(byAdding: .day, value: 6, to: Date())!,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .onChange(of: viewModel.selectedDate) { _ in
                            viewModel.refresh()
                        }
                        
                        Spacer()
                        
                        // Quick day buttons
                        HStack(spacing: 6) {
                            ForEach(0..<4, id: \.self) { dayOffset in
                                Button(action: {
                                    viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Calendar.current.startOfDay(for: Date()))!
                                }) {
                                    Text(viewModel.dayLabel(offset: dayOffset, l10n: l10n))
                                        .font(.caption2)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 4)
                                        .background(viewModel.isSelectedDay(offset: dayOffset) ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(viewModel.isSelectedDay(offset: dayOffset) ? .white : .primary)
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Current tide status
                currentTideCard
                
                // Tide curve (visual)
                tideCurveView
                
                // Selected day's tide table
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.selectedDayTitle(l10n: l10n))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.todayTides) { tide in
                        TideEventRow(tide: tide, l10n: l10n, isNext: tide.id == viewModel.nextTideId)
                    }
                    .padding(.horizontal)
                }
                
                // Next day's tides
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.nextDayTitle(l10n: l10n))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.tomorrowTides) { tide in
                        TideEventRow(tide: tide, l10n: l10n, isNext: false)
                    }
                    .padding(.horizontal)
                }
                
                // Tidal currents
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.t("海流信息", "Current Flow"))
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(viewModel.currentDirection))
                            Text(l10n.t("流向", "Direction"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(viewModel.currentDirectionText)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        VStack(spacing: 4) {
                            Text("\(viewModel.currentSpeed, specifier: "%.1f")")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text(l10n.t("流速 (节)", "Speed (kts)"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 4) {
                            Text(viewModel.nextSlackTime)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text(l10n.t("下次转流", "Next Slack"))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Fishing tip based on tides
                fishingTipCard
                
                // Source
                HStack {
                    Text(l10n.t("数据源: DFO Tides & Currents", "Source: DFO Tides & Currents"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(l10n.t("每15分钟自动更新", "Auto-refresh every 15 min"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        }
        .background(Color(.systemGray6))
        .navigationTitle(l10n.infoTides)
        .onAppear { viewModel.refresh() }
    }
    
    // MARK: - Current Tide Card
    private var currentTideCard: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text(l10n.t("当前水位", "Current Level"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.currentHeight, specifier: "%.2f") m")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            Divider().frame(height: 50)
            
            VStack(spacing: 4) {
                Text(l10n.t("潮汐状态", "Tide Status"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: viewModel.isRising ? "arrow.up" : "arrow.down")
                        .foregroundColor(viewModel.isRising ? .green : .orange)
                    Text(viewModel.isRising
                         ? l10n.t("涨潮中", "Rising")
                         : l10n.t("退潮中", "Falling"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                }
            }
            
            Divider().frame(height: 50)
            
            VStack(spacing: 4) {
                Text(l10n.t("潮差", "Range"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.tidalRange, specifier: "%.1f") m")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(viewModel.tidalRange > 3.5
                     ? l10n.t("大潮", "Spring")
                     : l10n.t("小潮", "Neap"))
                .font(.caption2)
                .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }
    
    // MARK: - Tide Curve
    private var tideCurveView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(l10n.t("潮汐曲线", "Tide Curve"))
                .font(.headline)
                .padding(.horizontal)
            
            // Simple visual tide curve
            GeometryReader { geometry in
                let width = geometry.size.width - 32
                let height: CGFloat = 100
                
                Path { path in
                    let points = viewModel.tideCurvePoints
                    guard points.count > 1 else { return }
                    
                    let xStep = width / CGFloat(points.count - 1)
                    
                    path.move(to: CGPoint(x: 16, y: height - CGFloat(points[0]) * height / 5.0))
                    for i in 1..<points.count {
                        let x = 16 + xStep * CGFloat(i)
                        let y = height - CGFloat(points[i]) * height / 5.0
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
                
                // Current time indicator
                let progress = viewModel.currentTimeProgress
                let xPos = 16 + width * CGFloat(progress)
                
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .position(x: xPos, y: height - CGFloat(viewModel.currentHeight) * height / 5.0)
                
                // Time labels
                HStack {
                    Text("00:00").font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text("06:00").font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text("12:00").font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text("18:00").font(.caption2).foregroundColor(.secondary)
                    Spacer()
                    Text("24:00").font(.caption2).foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .offset(y: height + 5)
            }
            .frame(height: 130)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Fishing Tip Card
    private var fishingTipCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "fish")
                .font(.title2)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.t("钓鱼建议", "Fishing Tip"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(viewModel.fishingTip(l10n: l10n))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Tide Event Row
struct TideEventRow: View {
    let tide: TideEvent
    let l10n: L10n
    let isNext: Bool
    
    var body: some View {
        HStack {
            Image(systemName: tide.type == "high" ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                .foregroundColor(tide.type == "high" ? .blue : .orange)
            
            Text(tide.time)
                .font(.subheadline)
                .fontWeight(isNext ? .bold : .regular)
                .frame(width: 50, alignment: .leading)
            
            Text(tide.type == "high"
                 ? l10n.t("高潮", "High")
                 : l10n.t("低潮", "Low"))
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 40)
            
            Spacer()
            
            Text("\(tide.height, specifier: "%.2f") m")
                .font(.subheadline)
                .fontWeight(.medium)
            
            if isNext {
                Text(l10n.t("← 下一个", "← next"))
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isNext ? Color.orange.opacity(0.05) : Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - View Model
class TideViewModel: ObservableObject {
    @Published var selectedStation: String = "point_atkinson"
    @Published var selectedDate: Date = Date()
    @Published var todayTides: [TideEvent] = []
    @Published var tomorrowTides: [TideEvent] = []
    @Published var currentHeight: Double = 3.2
    @Published var isRising: Bool = true
    @Published var tidalRange: Double = 4.0
    @Published var nextTideId: Int = 2
    @Published var currentDirection: Double = 135
    @Published var currentDirectionText: String = "SE"
    @Published var currentSpeed: Double = 1.5
    @Published var nextSlackTime: String = "14:22"
    @Published var tideCurvePoints: [Double] = []
    @Published var currentTimeProgress: Double = 0.5
    
    let stations: [TideStation] = [
        TideStation(id: "point_atkinson", name: "Point Atkinson"),
        TideStation(id: "vancouver", name: "Vancouver Harbour"),
        TideStation(id: "sand_heads", name: "Sand Heads"),
        TideStation(id: "tsawwassen", name: "Tsawwassen"),
        TideStation(id: "horseshoe_bay", name: "Horseshoe Bay"),
        TideStation(id: "deep_cove", name: "Deep Cove"),
        TideStation(id: "steveston", name: "Steveston"),
        TideStation(id: "white_rock", name: "White Rock"),
        TideStation(id: "nanaimo", name: "Nanaimo"),
        TideStation(id: "active_pass", name: "Active Pass"),
    ]
    
    private var refreshTimer: Timer?
    
    init() {
        loadData()
        // Auto-refresh every 15 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }
    
    func dayLabel(offset: Int, l10n: L10n) -> String {
        switch offset {
        case 0: return l10n.t("今天", "Today")
        case 1: return l10n.t("明天", "Tmrw")
        case 2: return l10n.t("后天", "Day 3")
        case 3: return l10n.t("大后天", "Day 4")
        default: return ""
        }
    }
    
    func isSelectedDay(offset: Int) -> Bool {
        let target = Calendar.current.date(byAdding: .day, value: offset, to: Calendar.current.startOfDay(for: Date()))!
        return Calendar.current.isDate(selectedDate, inSameDayAs: target)
    }
    
    func selectedDayTitle(l10n: L10n) -> String {
        if Calendar.current.isDateInToday(selectedDate) {
            return l10n.t("今日潮汐", "Today's Tides")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: selectedDate) + l10n.t(" 潮汐", " Tides")
    }
    
    func nextDayTitle(l10n: L10n) -> String {
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
        if Calendar.current.isDateInTomorrow(nextDay) || Calendar.current.isDateInToday(selectedDate) {
            return l10n.t("次日潮汐", "Next Day Tides")
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: nextDay) + l10n.t(" 潮汐", " Tides")
    }
    
    func refresh() {
        loadData()
    }
    
    func fishingTip(l10n: L10n) -> String {
        if abs(currentSpeed) < 0.5 {
            return l10n.t(
                "现在正值转流时段，是钓鱼的黄金时间！鱼群在这时最活跃。",
                "Slack tide right now - prime fishing time! Fish are most active during tide changes."
            )
        } else if isRising {
            return l10n.t(
                "涨潮中，饵鱼被推向岸边，建议在岬角和海角附近作钓。转流时间约\(nextSlackTime)。",
                "Rising tide pushing bait towards shore. Fish near points and headlands. Slack at ~\(nextSlackTime)."
            )
        } else {
            return l10n.t(
                "退潮中，饵鱼被带向深水。建议在水道口和深水区作钓。转流时间约\(nextSlackTime)。",
                "Falling tide carrying bait to deeper water. Fish channel mouths and drops. Slack at ~\(nextSlackTime)."
            )
        }
    }
    
    private func loadData() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        currentTimeProgress = (Double(hour) * 60 + Double(minute)) / (24 * 60)
        
        // Fetch real tide data from DFO API
        Task { @MainActor in
            let predictions = await MarineDataService.shared.fetchTidePredictions(
                stationId: selectedStation, date: selectedDate
            )
            let curveData = await MarineDataService.shared.fetchTideCurve(
                stationId: selectedStation, date: selectedDate
            )
            
            if let preds = predictions, !preds.isEmpty {
                self.processRealTides(predictions: preds, curveData: curveData)
            } else {
                self.loadFallbackTides()
            }
        }
    }
    
    private func processRealTides(predictions: [DFOTidePrediction], curveData: [DFOWaterLevel]?) {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        timeFormatter.timeZone = TimeZone(identifier: "America/Vancouver")
        
        let selectedDayStart = calendar.startOfDay(for: selectedDate)
        let nextDayStart = calendar.date(byAdding: .day, value: 1, to: selectedDayStart)!
        let dayAfterStart = calendar.date(byAdding: .day, value: 2, to: selectedDayStart)!
        
        // Parse predictions into today and tomorrow
        var today: [TideEvent] = []
        var tomorrow: [TideEvent] = []
        var eventId = 1
        var prevHeight: Double = 0
        
        for pred in predictions {
            guard let dateStr = pred.eventDate,
                  let value = pred.value else { continue }
            
            // Try to parse ISO date
            var date: Date?
            date = dateFormatter.date(from: dateStr)
            if date == nil {
                // Try alternate format
                let altFormatter = ISO8601DateFormatter()
                altFormatter.formatOptions = [.withInternetDateTime]
                date = altFormatter.date(from: dateStr)
            }
            guard let eventDate = date else { continue }
            
            let type = value > prevHeight ? "high" : "low"
            prevHeight = value
            
            let timeStr = timeFormatter.string(from: eventDate)
            let event = TideEvent(id: eventId, time: timeStr, height: value, type: type)
            
            if eventDate >= selectedDayStart && eventDate < nextDayStart {
                today.append(event)
            } else if eventDate >= nextDayStart && eventDate < dayAfterStart {
                tomorrow.append(event)
            }
            eventId += 1
        }
        
        if !today.isEmpty { todayTides = today }
        if !tomorrow.isEmpty { tomorrowTides = tomorrow }
        
        // Determine high/low by height comparison
        if todayTides.count >= 2 {
            // Re-classify: alternating high/low starting with the highest
            let sorted = todayTides.sorted { $0.height > $1.height }
            var classified: [TideEvent] = []
            for (i, tide) in todayTides.enumerated() {
                let isHigh = sorted.prefix(todayTides.count / 2 + 1).contains(where: { $0.id == tide.id })
                classified.append(TideEvent(id: tide.id, time: tide.time, height: tide.height, type: isHigh ? "high" : "low"))
            }
            todayTides = classified
        }
        
        // Determine next tide
        if let firstUpcoming = todayTides.first(where: { tide in
            let parts = tide.time.split(separator: ":")
            guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return false }
            return h * 60 + m > currentMinutes
        }) {
            nextTideId = firstUpcoming.id
            isRising = firstUpcoming.type == "high"
        }
        
        // Tidal range
        if let maxH = todayTides.map({ $0.height }).max(),
           let minH = todayTides.map({ $0.height }).min() {
            tidalRange = maxH - minH
            
            // Estimate current height
            let progress = Double(currentMinutes) / (24 * 60)
            currentHeight = minH + (maxH - minH) * (0.5 + 0.5 * sin(progress * 4 * .pi))
        }
        
        // Current flow estimation
        currentSpeed = abs(cos(Double(currentMinutes) / (6.2 * 60) * .pi)) * 2.5
        currentDirection = isRising ? 315 : 135
        currentDirectionText = isRising ? "NW" : "SE"
        
        // Next slack from tide times
        let tideMinutes = todayTides.compactMap { tide -> Int? in
            let parts = tide.time.split(separator: ":")
            guard parts.count == 2, let h = Int(parts[0]), let m = Int(parts[1]) else { return nil }
            return h * 60 + m
        }
        if let nextTideTime = tideMinutes.first(where: { $0 > currentMinutes }) {
            // Slack is approximately halfway between tides
            let prevTideTime = tideMinutes.last(where: { $0 <= currentMinutes }) ?? currentMinutes
            let slackMinutes = (prevTideTime + nextTideTime) / 2
            if slackMinutes > currentMinutes {
                nextSlackTime = String(format: "%02d:%02d", slackMinutes / 60, slackMinutes % 60)
            } else {
                nextSlackTime = String(format: "%02d:%02d", nextTideTime / 60, nextTideTime % 60)
            }
        }
        
        // Process curve data for graph
        if let curve = curveData, !curve.isEmpty {
            tideCurvePoints = curve.compactMap { $0.value }
            if tideCurvePoints.count < 10 {
                generateSyntheticCurve()
            }
        } else {
            generateSyntheticCurve()
        }
    }
    
    private func generateSyntheticCurve() {
        tideCurvePoints = (0..<48).map { i in
            let t = Double(i) / 48.0 * 24.0 * 60.0
            let phase1 = sin(t / (12.42 * 60) * 2 * .pi)
            let phase2 = sin(t / (12.0 * 60) * 2 * .pi) * 0.3
            let minH = todayTides.map({ $0.height }).min() ?? 0.8
            let maxH = todayTides.map({ $0.height }).max() ?? 4.5
            let mid = (minH + maxH) / 2
            let amp = (maxH - minH) / 2
            return mid + (phase1 + phase2) * amp * 0.7
        }
    }
    
    private func loadFallbackTides() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        let dayOffset = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: selectedDate)).day ?? 0
        let stationIndex = Double(stations.firstIndex(where: { $0.id == selectedStation }) ?? 0)
        let stationOffset = stationIndex * 12
        let heightFactor = 1.0 + stationIndex * 0.05
        
        let baseHighTime1 = 3 * 60 + 22 + Int(stationOffset) + dayOffset * 48
        let baseLowTime1 = 9 * 60 + 45 + Int(stationOffset) + dayOffset * 48
        let baseHighTime2 = 15 * 60 + 58 + Int(stationOffset) + dayOffset * 48
        let baseLowTime2 = 22 * 60 + 10 + Int(stationOffset) + dayOffset * 48
        
        todayTides = [
            TideEvent(id: 1, time: String(format: "%02d:%02d", (baseHighTime1 / 60) % 24, baseHighTime1 % 60), height: 4.68 * heightFactor, type: "high"),
            TideEvent(id: 2, time: String(format: "%02d:%02d", (baseLowTime1 / 60) % 24, baseLowTime1 % 60), height: 1.12 / heightFactor, type: "low"),
            TideEvent(id: 3, time: String(format: "%02d:%02d", (baseHighTime2 / 60) % 24, baseHighTime2 % 60), height: 4.21 * heightFactor, type: "high"),
            TideEvent(id: 4, time: String(format: "%02d:%02d", (baseLowTime2 / 60) % 24, baseLowTime2 % 60), height: 0.78 / heightFactor, type: "low"),
        ]
        
        tomorrowTides = [
            TideEvent(id: 5, time: "04:05", height: 4.52 * heightFactor, type: "high"),
            TideEvent(id: 6, time: "10:28", height: 1.35 / heightFactor, type: "low"),
            TideEvent(id: 7, time: "16:42", height: 4.08 * heightFactor, type: "high"),
            TideEvent(id: 8, time: "22:55", height: 0.92 / heightFactor, type: "low"),
        ]
        
        if currentMinutes < 3 * 60 + 22 { nextTideId = 1; isRising = true }
        else if currentMinutes < 9 * 60 + 45 { nextTideId = 2; isRising = false }
        else if currentMinutes < 15 * 60 + 58 { nextTideId = 3; isRising = true }
        else if currentMinutes < 22 * 60 + 10 { nextTideId = 4; isRising = false }
        else { nextTideId = 5; isRising = true }
        
        let tidePhase = sin(Double(currentMinutes) / (6.2 * 60) * .pi)
        currentHeight = 2.5 + tidePhase * 2.0
        tidalRange = 4.68 - 0.78
        currentSpeed = abs(cos(Double(currentMinutes) / (6.2 * 60) * .pi)) * 2.5
        currentDirection = isRising ? 315 : 135
        currentDirectionText = isRising ? "NW" : "SE"
        nextSlackTime = "14:22"
        
        generateSyntheticCurve()
    }
}

// MARK: - Data Models
struct TideStation: Identifiable {
    let id: String
    let name: String
}

struct TideEvent: Identifiable {
    let id: Int
    let time: String
    let height: Double
    let type: String // "high" or "low"
}
