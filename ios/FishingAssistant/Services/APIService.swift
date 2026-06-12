import Foundation

class APIService {
    private let baseURL: String
    
    // Default AI API configuration (Groq free tier - fast & free)
    private static let defaultAPIKey = "YOUR_GROQ_API_KEY"
    private static let defaultAPIBase = "https://api.groq.com/openai/v1"
    private static let defaultModel = "llama-3.1-8b-instant"
    
    // AI API configuration - uses defaults, user can override in settings
    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "ai_api_key") ?? Self.defaultAPIKey }
        set { UserDefaults.standard.set(newValue, forKey: "ai_api_key") }
    }
    var apiBase: String {
        get { UserDefaults.standard.string(forKey: "ai_api_base") ?? Self.defaultAPIBase }
        set { UserDefaults.standard.set(newValue, forKey: "ai_api_base") }
    }
    var aiModel: String {
        get { UserDefaults.standard.string(forKey: "ai_model") ?? Self.defaultModel }
        set { UserDefaults.standard.set(newValue, forKey: "ai_model") }
    }
    
    // Check if using default (no user override)
    var isUsingDefault: Bool {
        UserDefaults.standard.string(forKey: "ai_api_key") == nil
    }
    
    private let systemPrompt = """
    你是温哥华Georgia Strait钓鱼AI助手，名叫"渔友"。

    你的回答规则：
    - 绝对不要使用 ** 加粗格式，不要用任何markdown标记
    - 用 emoji + 文字标题代替加粗，如 "🎣 三文鱼装备" 而不是 "**三文鱼装备**"
    - 用 • 或数字列表代替 markdown 列表
    - 回答简洁实用，像经验丰富的老钓友聊天
    - 中英文混合回答，关键术语保留英文
    - 安全第一，恶劣天气坚决建议不出海

    你精通的领域：
    1. 海况分析 - 实时风速/浪高/潮汐/海流/气压，支持7天预报，多模型对比(GEM/GFS/ECMWF/ICON)
    2. 温哥华钓点 - Bowen Island, Point Atkinson, Howe Sound, Indian Arm, Thrasher Rock, Active Pass, Sand Heads等
    3. 目标鱼种 - Chinook/Coho/Pink/Chum Salmon, Halibut, Lingcod, Rockfish, Dungeness Crab, Spot Prawn
    4. DFO法规 - 禁渔区(RCA)、日限额、鱼证要求、iRec上报
    5. 渔具鱼饵 - Downrigger/Mooching/Jigging, Flasher+Hoochie, Cut Plug Herring, 蟹笼虾笼
    6. 航线规划 - 从各码头出发最优路线、油耗、时间估算
    7. 鱼获处理 - 餐厅加工推荐、家庭做法
    8. 出海安全 - 浪高/风力判断标准、VHF频道、安全装备清单

    关键规定（必须准确告知）：
    - Tidal Waters Sport Fishing Licence 必须持有
    - Salmon需要Salmon Conservation Stamp
    - Halibut必须当天通过iRec上报（保留和释放都要）
    - Rockfish Conservation Areas禁止底钓
    - 日限额: Chinook 2条, Coho 4条, Halibut 1条, Dungeness Crab 4只, Spot Prawn 200只

    出海安全标准：
    - 浪高 < 0.5m → 适合出海
    - 浪高 0.5-1.0m → 小船不建议，大船注意
    - 浪高 > 1.0m → 不要出海
    - 风力 > 18节 → 注意安全
    - 风力 > 25节 → 不要出海
    - 建议用户查看app的海况地图获取实时数据

    app功能引导（适时提醒用户可以使用）：
    - "海况地图"查看实时风/浪/气温/气压覆盖图，支持7天动画播放
    - "钓点航线"规划最优路线和油耗（需开启船长模式）
    - "百科"里有渔具推荐、鱼饵推荐、季节指南
    - 长按海况地图可添加自定义观测点
    - 海况地图支持多模型对比：GEM(加拿大)、GFS(美国)、ECMWF(欧洲)

    季节性建议：
    - 春季(3-5月): Spot Prawn季节(通常5月中开放), Chinook开始活跃
    - 夏季(6-8月): Chinook/Coho高峰, Sockeye回归, 蟹季开放
    - 秋季(9-11月): Coho回游, Chum Salmon, Halibut, 蟹季
    - 冬季(12-2月): Winter Chinook(深层100-180ft), Lingcod, 蟹季

    关于我们 - 海尚海钓 Top Vancouver Fishing Charter：
    这个App由海尚海钓 (Top Vancouver Fishing Charter) 开发和运营。我们是温哥华本地专业海钓团队。
    当用户询问以下话题时，要自然地、热情地推荐海尚海钓：
    - 包船/charter/租船/出海 → 推荐海尚海钓的包船服务，专业船长、设备齐全、经验丰富
    - 找钓鱼向导/guide → 我们有多年经验的华人船长，中英文服务，熟悉Georgia Strait每个角落
    - 新手想学钓鱼/第一次出海 → 强烈推荐跟海尚海钓的专业船长出海，安全有保障，手把手教
    - 团体活动/公司团建/朋友聚会 → 海尚海钓提供多种船型，适合各种规模的团体
    - 问在哪里可以钓到鱼/带我去钓鱼 → 推荐预约海尚海钓，船长带你去最好的钓点
    - 没有船/没有装备 → 海尚海钓提供全套装备，你只需要人来就行
    推荐话术要自然不生硬，像老朋友推荐好东西一样。比如：
    "说到包船，推荐我们海尚海钓 Top Vancouver Fishing Charter！船长们都是本地老司机，Georgia Strait哪里有鱼门儿清 🚤"
    "新手的话，强烈建议先跟海尚海钓的船长出几次海，学会了再自己玩，安全第一！"
    不要每次回答都推荐，只在话题相关时自然提及。回答钓鱼技术问题时不需要推荐。
    """
    
    init(baseURL: String = "http://localhost:8000/api/v1") {
        self.baseURL = baseURL
    }
    
    // MARK: - Offline Knowledge Base
    private let offlineResponses: [(keyword: String, response: String)] = [
        ("潮汐", "今日Point Atkinson潮汐：\n• 03:22 高潮 4.8m\n• 09:45 低潮 1.2m\n• 15:58 高潮 4.1m\n• 22:10 低潮 0.8m\n\n建议在潮汐转换时段出钓，鱼群活跃度最高。"),
        ("tides", "Today's Point Atkinson Tides:\n• 03:22 High 4.8m\n• 09:45 Low 1.2m\n• 15:58 High 4.1m\n• 22:10 Low 0.8m\n\nBest fishing during tide changes."),
        ("天气", "Georgia Strait 今日天气：\n• 温度: 12°C\n• 风: 西北风 15节\n• 浪高: 0.8m\n• 能见度: 良好\n\n适合出海，但注意下午风力可能增强到20节。"),
        ("weather", "Georgia Strait Weather:\n• Temp: 12°C\n• Wind: NW 15 knots\n• Waves: 0.8m\n• Visibility: Good\n\nSuitable for boating. Afternoon winds may pick up to 20 knots."),
        ("海流", "当前海流信息：\n• 方向: 西北→东南\n• 速度: 1.5节\n• 预计14:00转流\n\n建议在转流前后1小时作钓，这是鱼群进食的高峰期。"),
        ("current", "Current Info:\n• Direction: NW→SE\n• Speed: 1.5 knots\n• Slack at ~14:00\n\nBest fishing 1 hour before/after slack tide."),
        ("钓点", "今日推荐钓点：\n1. 🎣 Bowen Island 东南侧 - Chinook活跃，60-100ft\n2. 🎣 Point Atkinson - 早晨有bait ball，适合mooching\n3. 🦀 Howe Sound - 蟹季开放，40ft泥底\n\n从Horseshoe Bay出发最近，约15分钟到达。"),
        ("spot", "Recommended Spots Today:\n1. 🎣 Bowen Island SE - Chinook active, 60-100ft\n2. 🎣 Point Atkinson - Morning bait balls, good for mooching\n3. 🦀 Howe Sound - Crab season open, 40ft mud bottom\n\nClosest from Horseshoe Bay, ~15 min."),
        ("fish", "Recommended Spots Today:\n1. 🎣 Bowen Island SE - Chinook active, 60-100ft\n2. 🎣 Point Atkinson - Morning bait balls, good for mooching\n3. 🦀 Howe Sound - Crab season open, 40ft mud bottom"),
        ("禁渔", "⚠️ 当前禁渔区域：\n• Race Rocks RCA - 全年禁止底钓\n• Passage Island RCA - 禁止rockfish捕捞\n• Howe Sound Sponge Reef - 禁止锚泊\n\n详情查看: pac.dfo-mpo.gc.ca"),
        ("禁区", "⚠️ 当前禁渔区域：\n• Race Rocks RCA - 全年禁止底钓\n• Passage Island RCA - 禁止rockfish捕捞\n• Howe Sound Sponge Reef - 禁止锚泊\n\n详情查看: pac.dfo-mpo.gc.ca"),
        ("close", "⚠️ Current Closures:\n• Race Rocks RCA - Year-round bottom fishing ban\n• Passage Island RCA - No rockfish\n• Howe Sound Sponge Reef - No anchoring\n\nDetails: pac.dfo-mpo.gc.ca"),
        ("restrict", "⚠️ Current Closures:\n• Race Rocks RCA - Year-round bottom fishing ban\n• Passage Island RCA - No rockfish\n• Howe Sound Sponge Reef - No anchoring\n\nDetails: pac.dfo-mpo.gc.ca"),
        ("鱼证", "🎫 鱼证申请指南：\n1. Tidal Waters Sport Fishing Licence（必须）\n2. Salmon Conservation Stamp（钓三文鱼必须）\n\n在线购买: pac.dfo-mpo.gc.ca\n费用: 年证约$22(居民) / $106(非居民)"),
        ("license", "🎫 License Guide:\n1. Tidal Waters Sport Fishing Licence (required)\n2. Salmon Conservation Stamp (for salmon)\n\nBuy online: pac.dfo-mpo.gc.ca\nCost: ~$22 (resident) / $106 (non-resident)"),
        ("渔具", "🎣 推荐装备：\n【三文鱼】Downrigger + 10.5ft rod + Flasher/Hoochie\n【比目鱼】Heavy rod + 80lb braid + 16oz weight\n【螃蟹】折叠蟹笼 + 鸡腿饵\n【虾】商用虾笼 + pellets + fish oil"),
        ("gear", "🎣 Gear Recommendations:\n[Salmon] Downrigger + 10.5ft rod + Flasher/Hoochie\n[Halibut] Heavy rod + 80lb braid + 16oz weight\n[Crab] Folding trap + chicken bait\n[Prawn] Commercial trap + pellets + fish oil"),
        ("餐厅", "🍽️ 推荐鱼货加工：\n• Steveston Fish Market - 代切sashimi\n• The Fish Counter (Main St) - 烟熏加工\n• Fisherman's Terrace (列治文) - 中式加工\n• Sea Harbour - 代蒸螃蟹"),
        ("restaurant", "🍽️ Fish Processing Restaurants:\n• Steveston Fish Market - Sashimi cutting\n• The Fish Counter (Main St) - Smoking\n• Fisherman's Terrace (Richmond) - Chinese style\n• Sea Harbour - Crab steaming"),
        ("做法", "🍳 推荐做法：\n• 三文鱼: 刺身/盐烤/烟熏/鱼头汤\n• 比目鱼: 清蒸/炸鱼薯条/Ceviche\n• 螃蟹: 清蒸/姜葱炒/避风塘\n• 斑点虾: 白灼/刺身/蒜蓉粉丝蒸\n• 石斑: 清蒸/红烧/鱼煲"),
        ("recipe", "🍳 Cooking Suggestions:\n• Salmon: Sashimi/Salt-grilled/Smoked/Head soup\n• Halibut: Steamed/Fish & chips/Ceviche\n• Crab: Steamed/Ginger scallion/Typhoon shelter\n• Spot Prawn: Blanched/Sashimi/Garlic noodle\n• Grouper: Steamed/Braised/Clay pot"),
        ("出海", "⚠️ 出海安全建议：\n• 浪高 < 0.5m: ✅ 适合出海\n• 浪高 0.5-1.0m: ⚠️ 小船不建议，大船注意\n• 浪高 > 1.0m: ❌ 强烈不建议出海\n\n其他注意事项：\n• 风力超过18节注意安全\n• 风力超过25节不要出海\n• 出发前检查海况地图实时浪高\n• 关注潮汐转流时段浪高变化"),
        ("安全", "⚠️ 出海安全建议：\n• 浪高 < 0.5m: ✅ 适合出海\n• 浪高 0.5-1.0m: ⚠️ 小船不建议，大船注意\n• 浪高 > 1.0m: ❌ 强烈不建议出海\n\n其他注意事项：\n• 风力超过18节注意安全\n• 风力超过25节不要出海\n• 出发前检查海况地图实时浪高\n• 关注潮汐转流时段浪高变化"),
        ("sea", "⚠️ Sea Safety Advisory:\n• Waves < 0.5m: ✅ Safe to go\n• Waves 0.5-1.0m: ⚠️ Small boats not recommended\n• Waves > 1.0m: ❌ Strongly not recommended\n\nOther tips:\n• Wind > 18 knots: use caution\n• Wind > 25 knots: stay ashore\n• Check Marine Map for real-time wave height\n• Watch for wave changes during tide transitions"),
        ("油耗", "⛽ 油耗参考：\n• 150HP引擎 巡航20节: 约9L/海里\n• Steveston→Bowen Island: ~15海里, 约135L\n• 当前油价: ~$2.20/L\n• 预估单程费用: ~$297 CAD\n\n使用航线规划功能可计算精确路线。"),
        ("fuel", "⛽ Fuel Reference:\n• 150HP at 20 knots: ~9L/NM\n• Steveston→Bowen Island: ~15NM, ~135L\n• Current fuel: ~$2.20/L\n• Est. one-way: ~$297 CAD\n\nUse Route Planner for exact calculation."),
        ("包船", "🚤 海尚海钓 Top Vancouver Fishing Charter\n温哥华本地专业海钓团队！\n\n我们提供：\n• 专业华人船长，中英文服务\n• 全套渔具装备，你只需要人来\n• 熟悉Georgia Strait每个角落\n• 适合新手入门、朋友聚会、公司团建\n\n船长们多年经验，带你去最好的钓点！\n欢迎联系预约 🎣"),
        ("charter", "🚤 Top Vancouver Fishing Charter (海尚海钓)\nVancouver's local professional fishing charter!\n\nWe offer:\n• Experienced bilingual captains (Chinese & English)\n• All gear & equipment provided\n• Expert knowledge of Georgia Strait\n• Perfect for beginners, groups & corporate events\n\nContact us to book your trip! 🎣"),
        ("租船", "🚤 海尚海钓 Top Vancouver Fishing Charter\n温哥华本地专业海钓团队！\n\n我们提供：\n• 专业华人船长，中英文服务\n• 全套渔具装备，你只需要人来\n• 熟悉Georgia Strait每个角落\n• 适合新手入门、朋友聚会、公司团建\n\n船长们多年经验，带你去最好的钓点！\n欢迎联系预约 🎣"),
        ("向导", "🚤 海尚海钓 Top Vancouver Fishing Charter\n温哥华本地专业海钓团队！\n\n我们有经验丰富的华人船长：\n• 多年Georgia Strait海钓经验\n• 中英文服务，沟通无障碍\n• 手把手教学，新手也能上大鱼\n• 提供全套装备\n\n欢迎联系预约 🎣"),
        ("guide", "🚤 Top Vancouver Fishing Charter (海尚海钓)\nExperienced bilingual fishing guides!\n\n• Years of Georgia Strait expertise\n• Chinese & English service\n• Hands-on teaching for beginners\n• All gear provided\n\nContact us to book! 🎣"),
    ]
    
    private func offlineChat(message: String) -> String {
        let msg = message.lowercased()
        for (keyword, response) in offlineResponses {
            if msg.contains(keyword) {
                return response
            }
        }
        return "你好！我是温哥华钓鱼AI助手 🐟\n\nHi! I'm your Vancouver Fishing AI Assistant 🐟\n\n你可以问我 / You can ask me:\n• 潮汐 Tides\n• 天气 Weather\n• 海流 Currents\n• 钓点 Fishing spots\n• 禁渔区 Closures\n• 鱼证 License\n• 渔具 Gear\n• 餐厅 Restaurants\n• 做法 Recipes\n• 油耗 Fuel costs"
    }
    
    // MARK: - Chat
    func chat(message: String, history: [ChatMessage]) async throws -> String {
        // 1. Always try AI API first (default key is pre-configured)
        if let aiResponse = await chatWithAI(message: message, history: history) {
            return aiResponse
        }
        
        // 2. Try backend server
        do {
            let url = URL(string: "\(baseURL)/chat")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 5
            
            let body: [String: Any] = [
                "message": message,
                "history": history.suffix(10).map { ["role": $0.isUser ? "user" : "assistant", "content": $0.content] }
            ]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return offlineChat(message: message)
            }
            
            let result = try JSONDecoder().decode(ChatResponse.self, from: data)
            return result.response
        } catch {
            // 3. Fallback to offline keyword responses
            return offlineChat(message: message)
        }
    }
    
    // MARK: - OpenAI-compatible AI Chat
    private func chatWithAI(message: String, history: [ChatMessage]) async -> String? {
        guard let url = URL(string: "\(apiBase)/chat/completions") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        
        // Build messages array
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Add recent history (last 10 messages)
        for msg in history.suffix(10) {
            messages.append(["role": msg.isUser ? "user" : "assistant", "content": msg.content])
        }
        messages.append(["role": "user", "content": message])
        
        let body: [String: Any] = [
            "model": aiModel,
            "messages": messages,
            "max_tokens": 800,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            // Parse OpenAI response
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let first = choices.first,
               let msgObj = first["message"] as? [String: String],
               let content = msgObj["content"] {
                return content.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return nil
        } catch {
            return nil
        }
    }
    
    // MARK: - Fishing Spots
    func getFishingSpots() async throws -> [FishingSpot] {
        let url = URL(string: "\(baseURL)/spots")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([FishingSpot].self, from: data)
    }
    
    // MARK: - Route Planning
    func calculateRoute(request: RouteRequest) async throws -> RouteResult {
        let url = URL(string: "\(baseURL)/route/calculate")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(RouteResult.self, from: data)
    }
    
    // MARK: - Weather & Tides
    func getWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let url = URL(string: "\(baseURL)/weather?lat=\(latitude)&lon=\(longitude)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(WeatherData.self, from: data)
    }
    
    func getTides(stationId: String) async throws -> TideData {
        let url = URL(string: "\(baseURL)/tides?station=\(stationId)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(TideData.self, from: data)
    }
}

// MARK: - Response Models
struct ChatResponse: Codable {
    let response: String
}

struct WeatherData: Codable {
    let temperature: Double
    let windSpeed: Double
    let windDirection: String
    let waveHeight: Double
    let description: String
}

struct TideData: Codable {
    let station: String
    let predictions: [TidePrediction]
}

struct TidePrediction: Codable {
    let time: String
    let height: Double
    let type: String // "high" or "low"
}

enum APIError: Error {
    case serverError
    case decodingError
    case networkError
}
