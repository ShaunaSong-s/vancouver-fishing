import Foundation

// MARK: - Localization Manager
class L10n: ObservableObject {
    static let shared = L10n()
    
    @Published var language: Language = .chinese {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        }
    }
    
    enum Language: String, CaseIterable {
        case chinese = "zh"
        case english = "en"
        
        var displayName: String {
            switch self {
            case .chinese: return "中文"
            case .english: return "English"
            }
        }
    }
    
    init() {
        if let saved = UserDefaults.standard.string(forKey: "app_language"),
           let lang = Language(rawValue: saved) {
            self.language = lang
        }
    }
    
    func t(_ zh: String, _ en: String) -> String {
        language == .chinese ? zh : en
    }
    
    // MARK: - Tab Bar
    var tabAI: String { t("AI助手", "AI Chat") }
    var tabSpots: String { t("钓点", "Spots") }
    var tabRoute: String { t("航线", "Route") }
    var tabInfo: String { t("百科", "Wiki") }
    var tabProfile: String { t("我的", "Profile") }
    
    // MARK: - Chat
    var chatTitle: String { t("🐟 钓鱼AI助手", "🐟 Fishing AI") }
    var chatPlaceholder: String { t("问我关于钓鱼的任何问题...", "Ask me anything about fishing...") }
    var chatWelcome: String {
        t("你好！我是你的温哥华钓鱼AI助手 🐟\n\n我可以帮你查询：\n• 天气、潮汐、海流\n• 推荐钓点和鱼种\n• 路径规划和油耗计算\n• DFO规则和禁渔区\n• 渔具和鱼饵推荐\n• 餐厅和做法推荐\n\n有什么可以帮你的？",
          "Hi! I'm your Vancouver Fishing AI Assistant 🐟\n\nI can help with:\n• Weather, tides & currents\n• Fishing spots & species\n• Route planning & fuel costs\n• DFO rules & closures\n• Gear & bait recommendations\n• Restaurants & recipes\n\nHow can I help?")
    }
    var chatError: String { t("抱歉，网络出了点问题，请稍后再试。", "Sorry, network error. Please try again.") }
    
    // Quick Actions
    var qaTides: String { t("今日潮汐", "Tides") }
    var qaWeather: String { t("天气预报", "Weather") }
    var qaSpots: String { t("推荐钓点", "Spots") }
    var qaCurrent: String { t("海流信息", "Currents") }
    var qaRestricted: String { t("禁渔区域", "Closures") }
    var qaTidesMsg: String { t("今天乔治亚海峡的潮汐情况如何？", "What are today's tides in Georgia Strait?") }
    var qaWeatherMsg: String { t("今天出海天气如何？风浪大吗？", "How's the weather for boating today?") }
    var qaSpotsMsg: String { t("今天推荐去哪里钓鱼？", "Where should I fish today?") }
    var qaCurrentMsg: String { t("当前海流方向和速度如何？", "What are the current conditions?") }
    var qaRestrictedMsg: String { t("哪些海域目前不能去钓鱼？", "Which areas are currently closed?") }
    
    // MARK: - Map
    var mapTitle: String { t("钓点地图", "Fishing Map") }
    var filterSalmon: String { t("三文鱼", "Salmon") }
    var filterHalibut: String { t("比目鱼", "Halibut") }
    var filterCrab: String { t("螃蟹", "Crab") }
    var filterPrawn: String { t("虾", "Prawn") }
    var filterRockfish: String { t("岩鱼", "Rockfish") }
    var filterRestricted: String { t("禁渔区", "Closures") }
    var spotSpecies: String { t("目标鱼种", "Target Species") }
    var spotConditions: String { t("最佳条件", "Best Conditions") }
    var spotGear: String { t("推荐装备", "Recommended Gear") }
    var spotRestricted: String { t("禁渔区", "Restricted") }
    
    // MARK: - Route Planner
    var routeTitle: String { t("航线规划", "Route Planner") }
    var routeDeparture: String { t("出发地点", "Departure") }
    var routeDock: String { t("船坞", "Dock") }
    var routeSelectDock: String { t("选择出发码头", "Select departure dock") }
    var routeBoatInfo: String { t("船只信息", "Boat Info") }
    var routeHP: String { t("引擎马力", "Engine HP") }
    var routeFuelCap: String { t("油箱容量 (L)", "Fuel Capacity (L)") }
    var routeSpeed: String { t("巡航速度 (knots)", "Cruise Speed (knots)") }
    var routeActivities: String { t("今日活动", "Activities") }
    var routeFishing: String { t("钓鱼", "Fishing") }
    var routeCrabbing: String { t("抓螃蟹", "Crabbing") }
    var routePrawning: String { t("抓虾", "Prawning") }
    var routeCalculate: String { t("计算最优路线", "Calculate Best Route") }
    var routeResult: String { t("路线结果", "Route Result") }
    var routeDistance: String { t("总距离", "Total Distance") }
    var routeFuel: String { t("预计油耗", "Est. Fuel") }
    var routeCost: String { t("预计费用", "Est. Cost") }
    var routeTime: String { t("预计时间", "Est. Time") }
    var routeNM: String { t("海里", "NM") }
    var routeLiters: String { t("升", "L") }
    var routeHours: String { t("小时", "hrs") }
    var routeRecommended: String { t("推荐路线", "Recommended Route") }
    
    // MARK: - Info Center
    var infoTitle: String { t("百科中心", "Info Center") }
    var infoRegulations: String { t("法规信息", "Regulations") }
    var infoDFO: String { t("DFO 禁渔区域", "DFO Closures") }
    var infoLicense: String { t("鱼证申请指南", "License Guide") }
    var infoGearSection: String { t("装备推荐", "Gear") }
    var infoGear: String { t("渔具推荐", "Gear Guide") }
    var infoBait: String { t("鱼饵推荐", "Bait Guide") }
    var infoFood: String { t("美食", "Food") }
    var infoRestaurant: String { t("鱼货加工餐厅", "Fish Restaurants") }
    var infoRecipes: String { t("在家做法", "Home Recipes") }
    var infoWeatherSection: String { t("海况信息", "Marine Info") }
    var infoWeather: String { t("天气预报", "Weather") }
    var infoTides: String { t("潮汐表", "Tides") }
    
    // MARK: - Profile / Login
    var profileTitle: String { t("个人中心", "Profile") }
    var loginTitle: String { t("登录", "Login") }
    var loginEmail: String { t("邮箱", "Email") }
    var loginPassword: String { t("密码", "Password") }
    var loginButton: String { t("登录", "Log In") }
    var signupButton: String { t("注册", "Sign Up") }
    var logoutButton: String { t("退出登录", "Log Out") }
    var loginPrompt: String { t("登录后享受完整功能", "Log in for full access") }
    var myBoat: String { t("我的船只", "My Boat") }
    var myLicense: String { t("我的鱼证", "My License") }
    var myRecords: String { t("钓鱼记录", "Fishing Log") }
    var settings: String { t("设置", "Settings") }
    var languageLabel: String { t("语言", "Language") }
    var notifications: String { t("通知", "Notifications") }
    var about: String { t("关于", "About") }
    
    // MARK: - Recipes
    var recipesTitle: String { t("在家做法", "Home Recipes") }
}
