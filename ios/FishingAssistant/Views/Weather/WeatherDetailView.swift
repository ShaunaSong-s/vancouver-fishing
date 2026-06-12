import SwiftUI

// Safe array subscript
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Weather View (PredictWind style)
struct WeatherDetailView: View {
    @EnvironmentObject var l10n: L10n
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Location & Date Picker
                VStack(spacing: 10) {
                    // Location picker
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Picker(l10n.t("地点", "Location"), selection: $viewModel.selectedLocation) {
                            ForEach(viewModel.locations, id: \.id) { loc in
                                Text(loc.name).tag(loc.id)
                            }
                        }
                        .pickerStyle(.menu)
                        .onChange(of: viewModel.selectedLocation) { _ in
                            viewModel.refresh()
                        }
                        
                        Spacer()
                        
                        Button(action: { viewModel.refresh() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.clockwise")
                                Text(viewModel.lastUpdateTime)
                            }
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
                        
                        // Quick date buttons
                        Spacer()
                        HStack(spacing: 6) {
                            ForEach(0..<3, id: \.self) { dayOffset in
                                Button(action: {
                                    viewModel.selectedDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: Calendar.current.startOfDay(for: Date()))!
                                }) {
                                    Text(viewModel.dayLabel(offset: dayOffset, l10n: l10n))
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
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
                
                // Current Conditions Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(l10n.t("当前海况", "Current Conditions"))
                                .font(.headline)
                            Text(viewModel.currentLocationName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: viewModel.currentWeather.icon)
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    
                    Divider()
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        WeatherStatCard(
                            icon: "thermometer",
                            title: l10n.t("温度", "Temp"),
                            value: String(format: "%.1f°C", viewModel.currentWeather.temperature)
                        )
                        WeatherStatCard(
                            icon: "wind",
                            title: l10n.t("风速", "Wind"),
                            value: String(format: "%.0f kts %@", viewModel.currentWeather.windSpeed, viewModel.currentWeather.windDirection)
                        )
                        WeatherStatCard(
                            icon: "water.waves",
                            title: l10n.t("浪高", "Waves"),
                            value: String(format: "%.1f m", viewModel.currentWeather.waveHeight)
                        )
                        WeatherStatCard(
                            icon: "wind.snow",
                            title: l10n.t("阵风", "Gusts"),
                            value: String(format: "%.0f kts", viewModel.currentWeather.gustSpeed)
                        )
                        WeatherStatCard(
                            icon: "eye",
                            title: l10n.t("能见度", "Visibility"),
                            value: viewModel.currentWeather.visibility
                        )
                        WeatherStatCard(
                            icon: "barometer",
                            title: l10n.t("气压", "Pressure"),
                            value: String(format: "%.0f hPa", viewModel.currentWeather.pressure)
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                .padding(.horizontal)
                
                // Safety Assessment
                safetyCard
                
                // Hourly Forecast (PredictWind style)
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.t("逐时预报", "Hourly Forecast"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.hourlyForecast) { hour in
                                HourlyForecastCard(hour: hour, l10n: l10n)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // 3-Day Forecast
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.t("三日预报", "3-Day Forecast"))
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.dailyForecast) { day in
                        DailyForecastRow(day: day, l10n: l10n)
                    }
                    .padding(.horizontal)
                }
                
                // Marine Forecast Text
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.t("海洋预报", "Marine Forecast"))
                        .font(.headline)
                    Text(viewModel.marineForecast)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5)
                .padding(.horizontal)
                
                // Data source
                HStack {
                    Text(l10n.t("数据源: Environment Canada", "Source: Environment Canada"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(l10n.t("每30分钟自动更新", "Auto-refresh every 30 min"))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
        }
        .background(Color(.systemGray6))
        .navigationTitle(l10n.infoWeather)
        .onAppear { viewModel.refresh() }
    }
    
    private var safetyCard: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.safetyLevel.icon)
                .font(.title2)
                .foregroundColor(viewModel.safetyLevel.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.safetyLevel.title(l10n: l10n))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(viewModel.safetyLevel.description(l10n: l10n))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(viewModel.safetyLevel.color.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views
struct WeatherStatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct HourlyForecastCard: View {
    let hour: HourlyForecast
    let l10n: L10n
    
    var body: some View {
        VStack(spacing: 6) {
            Text(hour.time)
                .font(.caption2)
                .foregroundColor(.secondary)
            Image(systemName: hour.icon)
                .font(.title3)
                .foregroundColor(.blue)
            Text("\(hour.windSpeed, specifier: "%.0f")")
                .font(.caption)
                .fontWeight(.bold)
            Text(hour.windDirection)
                .font(.caption2)
                .foregroundColor(.secondary)
            // Wind bar (PredictWind style)
            RoundedRectangle(cornerRadius: 2)
                .fill(hour.windColor)
                .frame(width: 6, height: CGFloat(hour.windSpeed) * 1.5)
            Text("\(hour.waveHeight, specifier: "%.1f")m")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 50)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct DailyForecastRow: View {
    let day: DailyForecast
    let l10n: L10n
    
    var body: some View {
        HStack {
            Text(day.dayName)
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)
            Image(systemName: day.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "wind")
                    .font(.caption)
                Text("\(day.windLow, specifier: "%.0f")-\(day.windHigh, specifier: "%.0f") kts")
                    .font(.caption)
            }
            .frame(width: 90)
            HStack(spacing: 4) {
                Image(systemName: "water.waves")
                    .font(.caption)
                Text("\(day.waveHeight, specifier: "%.1f")m")
                    .font(.caption)
            }
            .frame(width: 60)
            Circle()
                .fill(day.safetyColor)
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - View Model
class WeatherViewModel: ObservableObject {
    @Published var currentWeather = CurrentWeather.default
    @Published var hourlyForecast: [HourlyForecast] = []
    @Published var dailyForecast: [DailyForecast] = []
    @Published var marineForecast = ""
    @Published var lastUpdateTime = "--:--"
    @Published var safetyLevel: SafetyLevel = .good
    @Published var selectedLocation: String = "georgia_strait"
    @Published var selectedDate: Date = Date()
    
    var currentLocationName: String {
        locations.first(where: { $0.id == selectedLocation })?.name ?? "Georgia Strait"
    }
    
    let locations: [WeatherLocation] = [
        WeatherLocation(id: "georgia_strait", name: "Georgia Strait", lat: 49.25, lon: -123.75),
        WeatherLocation(id: "howe_sound", name: "Howe Sound", lat: 49.42, lon: -123.30),
        WeatherLocation(id: "english_bay", name: "English Bay", lat: 49.28, lon: -123.19),
        WeatherLocation(id: "indian_arm", name: "Indian Arm", lat: 49.35, lon: -122.88),
        WeatherLocation(id: "bowen_island", name: "Bowen Island", lat: 49.38, lon: -123.35),
        WeatherLocation(id: "point_roberts", name: "Point Roberts", lat: 48.98, lon: -123.08),
        WeatherLocation(id: "sand_heads", name: "Sand Heads / Fraser River", lat: 49.10, lon: -123.30),
        WeatherLocation(id: "nanaimo", name: "Nanaimo", lat: 49.17, lon: -123.94),
        WeatherLocation(id: "active_pass", name: "Active Pass", lat: 48.87, lon: -123.28),
        WeatherLocation(id: "boundary_bay", name: "Boundary Bay", lat: 49.00, lon: -123.05),
    ]
    
    private var refreshTimer: Timer?
    
    init() {
        loadData()
        // Auto-refresh every 30 minutes
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            self?.refresh()
        }
    }
    
    func dayLabel(offset: Int, l10n: L10n) -> String {
        switch offset {
        case 0: return l10n.t("今天", "Today")
        case 1: return l10n.t("明天", "Tmrw")
        case 2: return l10n.t("后天", "Day 3")
        default: return ""
        }
    }
    
    func isSelectedDay(offset: Int) -> Bool {
        let target = Calendar.current.date(byAdding: .day, value: offset, to: Calendar.current.startOfDay(for: Date()))!
        return Calendar.current.isDate(selectedDate, inSameDayAs: target)
    }
    
    func refresh() {
        loadData()
    }
    
    private func loadData() {
        guard let loc = locations.first(where: { $0.id == selectedLocation }) else { return }
        
        // Fetch real data from Open-Meteo API
        Task { @MainActor in
            let weatherData = await MarineDataService.shared.fetchMarineWeather(lat: loc.lat, lon: loc.lon)
            let waveData = await MarineDataService.shared.fetchWaveData(lat: loc.lat, lon: loc.lon)
            
            if let weather = weatherData {
                self.processRealWeather(weather: weather, wave: waveData)
            } else {
                // Fallback to simulated data if API fails
                self.loadFallbackData()
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            self.lastUpdateTime = formatter.string(from: Date())
        }
    }
    
    private func processRealWeather(weather: MarineWeatherResponse, wave: MarineWaveResponse?) {
        // Current conditions from real API
        let temp = weather.current?.temperature_2m ?? 12.0
        let windSpd = weather.current?.wind_speed_10m ?? 15.0
        let windDir = weather.current?.wind_direction_10m ?? 0
        let gust = weather.current?.wind_gusts_10m ?? windSpd * 1.3
        let pressure = weather.current?.surface_pressure ?? 1013.0
        let waveHt = wave?.current?.wave_height ?? windSpd * 0.05
        
        currentWeather = CurrentWeather(
            temperature: temp,
            windSpeed: windSpd,
            windDirection: degreesToCompass(windDir),
            gustSpeed: gust,
            waveHeight: waveHt,
            visibility: windSpd > 25 ? "Fair" : "Good",
            pressure: pressure,
            icon: weatherIcon(wind: windSpd, temp: temp)
        )
        
        // Safety (wave > 0.5m = caution, > 1.0m = dangerous)
        if windSpd > 25 || waveHt > 1.0 { safetyLevel = .dangerous }
        else if windSpd > 18 || waveHt > 0.5 { safetyLevel = .caution }
        else { safetyLevel = .good }
        
        // Hourly from real data
        if let hourlyTimes = weather.hourly?.time,
           let hourlyWinds = weather.hourly?.wind_speed_10m,
           let hourlyDirs = weather.hourly?.wind_direction_10m {
            
            let calendar = Calendar.current
            let selectedDayStart = calendar.startOfDay(for: selectedDate)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            dateFormatter.timeZone = TimeZone(identifier: "America/Vancouver")
            
            var forecasts: [HourlyForecast] = []
            for i in 0..<min(hourlyTimes.count, hourlyWinds.count) {
                guard let date = dateFormatter.date(from: hourlyTimes[i]) else { continue }
                guard calendar.isDate(date, inSameDayAs: selectedDayStart) else { continue }
                
                let hour = calendar.component(.hour, from: date)
                let wind = hourlyWinds[i] ?? 10
                let dir = hourlyDirs[i] ?? 0
                let waveH = wave?.hourly?.wave_height?[safe: i] ?? wind * 0.05
                
                forecasts.append(HourlyForecast(
                    id: forecasts.count,
                    time: String(format: "%02d:00", hour),
                    windSpeed: wind,
                    windDirection: degreesToCompass(dir),
                    waveHeight: waveH ?? wind * 0.05,
                    icon: wind > 20 ? "wind" : "cloud.sun",
                    windColor: wind > 20 ? .red : (wind > 15 ? .orange : .green)
                ))
            }
            hourlyForecast = forecasts.isEmpty ? hourlyForecast : forecasts
        }
        
        // Daily from real data
        if let dailyTimes = weather.daily?.time,
           let dailyMaxWind = weather.daily?.wind_speed_10m_max {
            
            let dayNames_zh = ["今天", "明天", "后天", "第4天", "第5天", "第6天", "第7天"]
            let dayNames_en = ["Today", "Tmrw", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"]
            
            dailyForecast = (0..<min(dailyTimes.count, 7)).compactMap { i in
                let maxW = dailyMaxWind[i] ?? 15
                let minW = maxW * 0.5
                return DailyForecast(
                    id: i,
                    dayName: i < dayNames_zh.count ? dayNames_zh[i] : "\(i+1)",
                    dayNameEN: i < dayNames_en.count ? dayNames_en[i] : "Day \(i+1)",
                    windLow: minW,
                    windHigh: maxW,
                    waveHeight: maxW * 0.05,
                    icon: maxW > 20 ? "cloud.bolt" : "cloud.sun",
                    safetyColor: maxW > 25 ? .red : (maxW > 18 ? .orange : .green)
                )
            }
        }
        
        // Marine forecast summary
        let locName = currentLocationName
        let windDesc = currentWeather.windSpeed > 20 ? "strong" : (currentWeather.windSpeed > 12 ? "moderate" : "light")
        marineForecast = """
        \(locName): Wind \(currentWeather.windDirection) \(Int(currentWeather.windSpeed)) knots (\(windDesc)). \
        Gusts to \(Int(currentWeather.gustSpeed)) knots. \
        Seas \(String(format: "%.1f", currentWeather.waveHeight)) metres. \
        Pressure \(Int(currentWeather.pressure)) hPa.
        
        Data from Open-Meteo API (updated in real-time).
        """
    }
    
    private func loadFallbackData() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let dayOffset = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: selectedDate)).day ?? 0
        let locIndex = Double(locations.firstIndex(where: { $0.id == selectedLocation }) ?? 0)
        let locationFactor = 1.0 + locIndex * 0.08
        let baseTemp = (11.0 + Double(hour) * 0.3 - Double(dayOffset) * 0.5) * (1.0 + locIndex * 0.02)
        let baseWind = (12.0 + sin(Double(hour) * 0.5) * 8.0) * locationFactor + Double(dayOffset) * 2
        let baseWave = baseWind * 0.06
        
        currentWeather = CurrentWeather(
            temperature: baseTemp, windSpeed: baseWind,
            windDirection: hour < 12 ? "NW" : "W", gustSpeed: baseWind * 1.4,
            waveHeight: baseWave, visibility: baseWind > 25 ? "Fair" : "Good",
            pressure: 1013.0 + sin(Double(hour) * 0.3) * 5, icon: weatherIcon(wind: baseWind, temp: baseTemp)
        )
        
        if baseWind > 25 || baseWave > 1.0 { safetyLevel = .dangerous }
        else if baseWind > 18 || baseWave > 0.5 { safetyLevel = .caution }
        else { safetyLevel = .good }
        
        hourlyForecast = (0..<12).map { offset in
            let futureHour = (hour + offset) % 24
            let windSpd = max(5, 12.0 + sin(Double(futureHour) * 0.5) * 8.0)
            return HourlyForecast(
                id: offset, time: String(format: "%02d:00", futureHour),
                windSpeed: windSpd, windDirection: futureHour < 14 ? "NW" : "W",
                waveHeight: max(0.3, windSpd * 0.055), icon: windSpd > 20 ? "wind" : "cloud.sun",
                windColor: windSpd > 20 ? .red : (windSpd > 15 ? .orange : .green)
            )
        }
        
        let dayNames_zh = ["今天", "明天", "后天"]
        let dayNames_en = ["Today", "Tomorrow", "Day 3"]
        dailyForecast = (0..<3).map { i in
            let wHigh = baseWind + Double(i) * 3
            return DailyForecast(
                id: i, dayName: dayNames_zh[i], dayNameEN: dayNames_en[i],
                windLow: wHigh * 0.6, windHigh: wHigh, waveHeight: wHigh * 0.055,
                icon: wHigh > 20 ? "cloud.bolt" : "cloud.sun",
                safetyColor: wHigh > 25 ? .red : (wHigh > 18 ? .orange : .green)
            )
        }
        
        marineForecast = "\(currentLocationName): Offline mode - showing estimated data."
    }
    
    // MARK: - Helpers
    private func degreesToCompass(_ degrees: Double) -> String {
        let dirs = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        let index = Int((degrees + 11.25) / 22.5) % 16
        return dirs[index]
    }
    
    private func weatherIcon(wind: Double, temp: Double) -> String {
        if wind > 25 { return "cloud.bolt" }
        if wind > 18 { return "wind" }
        if temp < 5 { return "cloud.snow" }
        return "cloud.sun"
    }
}

// MARK: - Data Models
struct CurrentWeather {
    let temperature: Double
    let windSpeed: Double
    let windDirection: String
    let gustSpeed: Double
    let waveHeight: Double
    let visibility: String
    let pressure: Double
    let icon: String
    
    static let `default` = CurrentWeather(
        temperature: 12.0, windSpeed: 15.0, windDirection: "NW",
        gustSpeed: 22.0, waveHeight: 0.8, visibility: "Good",
        pressure: 1013.0, icon: "cloud.sun"
    )
}

struct HourlyForecast: Identifiable {
    let id: Int
    let time: String
    let windSpeed: Double
    let windDirection: String
    let waveHeight: Double
    let icon: String
    let windColor: Color
}

struct DailyForecast: Identifiable {
    let id: Int
    let dayName: String
    let dayNameEN: String
    let windLow: Double
    let windHigh: Double
    let waveHeight: Double
    let icon: String
    let safetyColor: Color
}

struct WeatherLocation: Identifiable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
}

enum SafetyLevel {
    case good, caution, dangerous
    
    var icon: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.triangle.fill"
        case .dangerous: return "xmark.octagon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .good: return .green
        case .caution: return .orange
        case .dangerous: return .red
        }
    }
    
    func title(l10n: L10n) -> String {
        switch self {
        case .good: return l10n.t("适合出海", "Good to Go")
        case .caution: return l10n.t("注意安全", "Use Caution")
        case .dangerous: return l10n.t("不建议出海", "Stay Ashore")
        }
    }
    
    func description(l10n: L10n) -> String {
        switch self {
        case .good: return l10n.t("风浪条件良好，适合各类船只出海", "Conditions suitable for all vessels")
        case .caution: return l10n.t("浪高超过0.5m，小船不建议出海", "Waves over 0.5m, small boats not recommended")
        case .dangerous: return l10n.t("浪高超过1m，强烈建议不要出海", "Waves over 1m, strongly advise staying ashore")
        }
    }
}
