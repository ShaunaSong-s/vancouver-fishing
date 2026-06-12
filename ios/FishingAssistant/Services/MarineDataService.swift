import Foundation

/// Service to fetch real weather and tide data from public APIs
/// - Weather: Environment Canada / Open-Meteo (free, no API key)
/// - Tides: DFO IWLS API (free, no API key)
class MarineDataService {
    static let shared = MarineDataService()
    
    // MARK: - Open-Meteo Marine Weather API (free, no key needed)
    // Docs: https://open-meteo.com/en/docs/marine-weather-api
    
    func fetchMarineWeather(lat: Double, lon: Double) async -> MarineWeatherResponse? {
        // Use cell_selection=sea for accurate marine grid cells (not land-biased)
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m,surface_pressure&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m&timezone=America%2FVancouver&forecast_days=7&wind_speed_unit=kn&models=gem_seamless&cell_selection=sea"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            return try JSONDecoder().decode(MarineWeatherResponse.self, from: data)
        } catch {
            print("Weather API error: \(error)")
            return nil
        }
    }
    
    /// Batch fetch weather for multiple coordinates in ONE API call (avoids rate limiting)
    /// Open-Meteo supports comma-separated lat/lon for up to 100 locations
    func fetchBatchWeather(points: [(id: String, lat: Double, lon: Double)], model: String = "gem_seamless") async -> [String: MarineWeatherResponse]? {
        guard !points.isEmpty else { return nil }
        
        let lats = points.map { String(format: "%.3f", $0.lat) }.joined(separator: ",")
        let lons = points.map { String(format: "%.3f", $0.lon) }.joined(separator: ",")
        
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lats)&longitude=\(lons)&hourly=temperature_2m,wind_speed_10m,wind_direction_10m,wind_gusts_10m,surface_pressure,precipitation,cloud_cover&timezone=America%2FVancouver&forecast_days=7&wind_speed_unit=kn&models=\(model)&cell_selection=sea"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Batch weather API status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return nil
            }
            
            // Multi-location returns an array of responses
            if points.count == 1 {
                // Single location: returns a single object
                let single = try JSONDecoder().decode(MarineWeatherResponse.self, from: data)
                return [points[0].id: single]
            } else {
                // Multiple locations: returns an array
                let results = try JSONDecoder().decode([MarineWeatherResponse].self, from: data)
                var dict: [String: MarineWeatherResponse] = [:]
                for (i, result) in results.enumerated() where i < points.count {
                    dict[points[i].id] = result
                }
                return dict
            }
        } catch {
            print("Batch weather API error: \(error)")
            return nil
        }
    }
    
    /// Batch fetch marine wave data for multiple coordinates
    func fetchBatchWaves(points: [(id: String, lat: Double, lon: Double)]) async -> [String: MarineWaveResponse]? {
        guard !points.isEmpty else { return nil }
        
        let lats = points.map { String(format: "%.3f", $0.lat) }.joined(separator: ",")
        let lons = points.map { String(format: "%.3f", $0.lon) }.joined(separator: ",")
        
        let urlString = "https://marine-api.open-meteo.com/v1/marine?latitude=\(lats)&longitude=\(lons)&hourly=wave_height,wave_direction,wave_period,swell_wave_height,swell_wave_direction,swell_wave_period&timezone=America%2FVancouver&forecast_days=7"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            if points.count == 1 {
                let single = try JSONDecoder().decode(MarineWaveResponse.self, from: data)
                return [points[0].id: single]
            } else {
                let results = try JSONDecoder().decode([MarineWaveResponse].self, from: data)
                var dict: [String: MarineWaveResponse] = [:]
                for (i, result) in results.enumerated() where i < points.count {
                    dict[points[i].id] = result
                }
                return dict
            }
        } catch {
            print("Batch wave API error: \(error)")
            return nil
        }
    }
    
    // Open-Meteo Marine API for wave data
    func fetchWaveData(lat: Double, lon: Double) async -> MarineWaveResponse? {
        let urlString = "https://marine-api.open-meteo.com/v1/marine?latitude=\(lat)&longitude=\(lon)&current=wave_height,wave_direction,wave_period&hourly=wave_height,wave_direction,wave_period&timezone=America%2FVancouver&forecast_days=3"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            return try JSONDecoder().decode(MarineWaveResponse.self, from: data)
        } catch {
            print("Wave API error: \(error)")
            return nil
        }
    }
    
    // MARK: - DFO Tides & Currents API (free, no key needed)
    // Docs: https://api-iwls.dfo-mpo.gc.ca/swagger-ui/index.html
    
    /// DFO station IDs for BC coast
    static let dfoStations: [String: String] = [
        "point_atkinson": "7795",
        "vancouver": "7735",
        "sand_heads": "7594",
        "tsawwassen": "7590",
        "horseshoe_bay": "7811",
        "deep_cove": "7780",  // Approximate - Indian Arm
        "steveston": "7607",
        "white_rock": "7589",
        "nanaimo": "7917",
        "active_pass": "7841",
    ]
    
    func fetchTidePredictions(stationId: String, date: Date) async -> [DFOTidePrediction]? {
        guard let dfoId = MarineDataService.dfoStations[stationId] else { return nil }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 2, to: startOfDay)!
        
        let startStr = formatter.string(from: startOfDay)
        let endStr = formatter.string(from: endOfDay)
        
        let urlString = "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/\(dfoId)/data?time-series-code=wlp-hilo&from=\(startStr)T00:00:00Z&to=\(endStr)T00:00:00Z"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            return try JSONDecoder().decode([DFOTidePrediction].self, from: data)
        } catch {
            print("DFO Tides API error: \(error)")
            return nil
        }
    }
    
    /// Fetch continuous water level predictions (every 15 min)
    func fetchTideCurve(stationId: String, date: Date) async -> [DFOWaterLevel]? {
        guard let dfoId = MarineDataService.dfoStations[stationId] else { return nil }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let startStr = formatter.string(from: startOfDay)
        let endStr = formatter.string(from: endOfDay)
        
        let urlString = "https://api-iwls.dfo-mpo.gc.ca/api/v1/stations/\(dfoId)/data?time-series-code=wlp&from=\(startStr)T00:00:00Z&to=\(endStr)T00:00:00Z"
        
        guard let url = URL(string: urlString) else { return nil }
        
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            return try JSONDecoder().decode([DFOWaterLevel].self, from: data)
        } catch {
            print("DFO Curve API error: \(error)")
            return nil
        }
    }
}

// MARK: - Open-Meteo Response Models

struct MarineWeatherResponse: Codable {
    let current: CurrentWeatherAPI?
    let hourly: HourlyWeatherAPI?
    let daily: DailyWeatherAPI?
    
    struct CurrentWeatherAPI: Codable {
        let temperature_2m: Double?
        let wind_speed_10m: Double?
        let wind_direction_10m: Double?
        let wind_gusts_10m: Double?
        let surface_pressure: Double?
    }
    
    struct HourlyWeatherAPI: Codable {
        let time: [String]?
        let temperature_2m: [Double?]?
        let wind_speed_10m: [Double?]?
        let wind_direction_10m: [Double?]?
        let wind_gusts_10m: [Double?]?
        let surface_pressure: [Double?]?
        let precipitation: [Double?]?
        let cloud_cover: [Double?]?
    }
    
    struct DailyWeatherAPI: Codable {
        let time: [String]?
        let temperature_2m_max: [Double?]?
        let temperature_2m_min: [Double?]?
        let wind_speed_10m_max: [Double?]?
        let wind_gusts_10m_max: [Double?]?
    }
}

struct MarineWaveResponse: Codable {
    let current: CurrentWaveAPI?
    let hourly: HourlyWaveAPI?
    
    struct CurrentWaveAPI: Codable {
        let wave_height: Double?
        let wave_direction: Double?
        let wave_period: Double?
    }
    
    struct HourlyWaveAPI: Codable {
        let time: [String]?
        let wave_height: [Double?]?
        let wave_direction: [Double?]?
        let wave_period: [Double?]?
        let swell_wave_height: [Double?]?
        let swell_wave_direction: [Double?]?
        let swell_wave_period: [Double?]?
    }
}

// MARK: - DFO Response Models

struct DFOTidePrediction: Codable {
    let eventDate: String?
    let value: Double?
    let qcFlagCode: String?
    
    // DFO uses "eventDate" for the timestamp
    enum CodingKeys: String, CodingKey {
        case eventDate
        case value
        case qcFlagCode
    }
}

struct DFOWaterLevel: Codable {
    let eventDate: String?
    let value: Double?
}
