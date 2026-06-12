import SwiftUI
import CoreLocation

struct InfoCenterView: View {
    @EnvironmentObject var l10n: L10n
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero section
                    VStack(spacing: 6) {
                        Text(l10n.t("🐟", "🐟"))
                            .font(.system(size: 32))
                        Text(l10n.infoTitle)
                            .font(.title2.weight(.bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text(l10n.t("温哥华海钓百科", "Vancouver Fishing Encyclopedia"))
                            .font(.caption)
                            .foregroundColor(AppTheme.Colors.textMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .staggeredAppear(index: 0)
                    
                    // Regulations
                    InfoSectionView(title: l10n.infoRegulations, icon: "shield.checkered") {
                        InfoRowLink(title: l10n.infoDFO, icon: "exclamationmark.triangle.fill", color: .red) {
                            DFORegulationsView()
                        }
                        InfoRowLink(title: l10n.infoLicense, icon: "doc.text.fill", color: AppTheme.Colors.accent) {
                            LicenseGuideView()
                        }
                    }
                    .staggeredAppear(index: 1)
                    
                    // Gear
                    InfoSectionView(title: l10n.infoGearSection, icon: "wrench.and.screwdriver") {
                        InfoRowLink(title: l10n.infoGear, icon: "wrench.and.screwdriver.fill", color: AppTheme.Colors.gold) {
                            GearRecommendationView()
                        }
                        InfoRowLink(title: l10n.infoBait, icon: "leaf.fill", color: AppTheme.Colors.success) {
                            BaitRecommendationView()
                        }
                    }
                    .staggeredAppear(index: 2)
                    
                    // Food
                    InfoSectionView(title: l10n.infoFood, icon: "fork.knife") {
                        InfoRowLink(title: l10n.infoRestaurant, icon: "fork.knife.circle.fill", color: .orange) {
                            RestaurantListView()
                        }
                        InfoRowLink(title: l10n.infoRecipes, icon: "flame.fill", color: .red) {
                            RecipeListView()
                        }
                    }
                    .staggeredAppear(index: 3)
                    
                    // Weather
                    InfoSectionView(title: l10n.infoWeatherSection, icon: "cloud.sun") {
                        InfoRowLink(title: l10n.infoWeather, icon: "cloud.sun.fill", color: AppTheme.Colors.accent) {
                            WeatherDetailView()
                        }
                        InfoRowLink(title: l10n.infoTides, icon: "water.waves", color: .cyan) {
                            TideDetailView()
                        }
                    }
                    .staggeredAppear(index: 4)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppTheme.Colors.heroGradient.ignoresSafeArea())
            .toolbarBackground(AppTheme.Colors.deepOcean.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Info Section Card
struct InfoSectionView<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppTheme.Colors.gold)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundColor(AppTheme.Colors.goldLight)
                    .textCase(.uppercase)
                    .tracking(1)
            }
            .padding(.leading, 4)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(AppTheme.Colors.oceanMid.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.Colors.cardBorder, lineWidth: 0.5)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.md))
        }
    }
}

// MARK: - Info Row Link
struct InfoRowLink<Destination: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let destination: () -> Destination
    
    var body: some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.Colors.oceanLight.opacity(0.15))
        }
        .scalePress()
    }
}

// MARK: - DFO Regulations
struct DFORegulationsView: View {
    @EnvironmentObject var l10n: L10n
    
    var body: some View {
        List {
            // MARK: - Management Areas
            Section(header: Text(l10n.t("📍 管理区域 (Management Areas)", "📍 Management Areas"))) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(l10n.t(
                        "温哥华附近海域主要涉及以下DFO管理区域：",
                        "Vancouver area waters fall under these DFO management areas:"
                    ))
                    .font(.callout)
                    
                    AreaInfoRow(area: "Area 28", zhDesc: "Howe Sound (豪湾)", enDesc: "Howe Sound", zhDetail: "Horseshoe Bay → Bowen Island → Gambier Island → Squamish 整个豪湾区域", enDetail: "Horseshoe Bay → Bowen Island → Gambier Island → Squamish - entire Howe Sound")
                    
                    AreaInfoRow(area: "Area 29", zhDesc: "Georgia Strait 南部", enDesc: "Georgia Strait South", zhDetail: "Point Atkinson → Roberts Bank → Tsawwassen → Active Pass → Sand Heads", enDetail: "Point Atkinson → Roberts Bank → Tsawwassen → Active Pass → Sand Heads")
                    
                    AreaInfoRow(area: "Area 15", zhDesc: "Indian Arm / Burrard Inlet", enDesc: "Indian Arm / Burrard Inlet", zhDetail: "Deep Cove → Indian Arm 整个内湾, Vancouver Harbour", enDetail: "Deep Cove → Indian Arm full inlet, Vancouver Harbour")
                    
                    AreaInfoRow(area: "Area 18", zhDesc: "Strait of Georgia 中北部", enDesc: "Strait of Georgia Central/North", zhDetail: "Nanaimo → Gabriola → Thrasher Rock 一带", enDetail: "Nanaimo → Gabriola → Thrasher Rock area")
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Rockfish Conservation Areas
            Section(header: Text(l10n.t("🚫 岩鱼保护区 (Rockfish Conservation Areas)", "🚫 Rockfish Conservation Areas (RCAs)"))) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(l10n.t(
                        "⚠️ RCA内全年禁止所有底钓活动（包括 jigging、底层拖钓）。违者罚款可达$100,000+",
                        "⚠️ ALL bottom fishing prohibited year-round within RCAs (including jigging, bottom trolling). Fines up to $100,000+"
                    ))
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 4)
                }
                
                RCARow(
                    name: "Passage Island RCA",
                    zhLocation: "Passage Island 周围 — West Vancouver 与 Bowen Island 之间",
                    enLocation: "Around Passage Island — between West Vancouver & Bowen Island",
                    zhCoords: "49°20.5'N, 123°18.5'W 为中心，半径约0.5nm",
                    enCoords: "Centered ~49°20.5'N, 123°18.5'W, radius ~0.5nm",
                    zhRestrictions: "禁止所有底钓 (jigging, bottom fishing)\n允许: 表层trolling三文鱼 (downrigger < 45m除外)",
                    enRestrictions: "No bottom fishing (jigging, bottom fishing)\nAllowed: Surface trolling for salmon (downrigger < 45m excluded)",
                    latitude: 49.3417, longitude: -123.308
                )
                
                RCARow(
                    name: "Howe Sound (Defence Islands) RCA",
                    zhLocation: "Defence Islands 附近 — Bowen Island 北侧",
                    enLocation: "Near Defence Islands — north side of Bowen Island",
                    zhCoords: "49°25'N, 123°22'W 附近区域",
                    enCoords: "Near 49°25'N, 123°22'W area",
                    zhRestrictions: "禁止所有底钓\n允许: 三文鱼表层拖钓, 蟹笼, 虾笼",
                    enRestrictions: "No bottom fishing\nAllowed: Salmon trolling, crab traps, prawn traps",
                    latitude: 49.4167, longitude: -123.367
                )
                
                RCARow(
                    name: "Halkett Point RCA",
                    zhLocation: "Gambier Island 东南角 — Howe Sound 中部",
                    enLocation: "SE corner of Gambier Island — central Howe Sound",
                    zhCoords: "49°26'N, 123°22'W 附近",
                    enCoords: "Near 49°26'N, 123°22'W",
                    zhRestrictions: "禁止所有底钓\n包括 Lingcod jigging 和 Rockfish 作钓",
                    enRestrictions: "No bottom fishing\nIncludes lingcod jigging and rockfish targeting",
                    latitude: 49.4333, longitude: -123.367
                )
                
                RCARow(
                    name: "Bowyer Island RCA",
                    zhLocation: "Bowyer Island — Horseshoe Bay 西北",
                    enLocation: "Bowyer Island — NW of Horseshoe Bay",
                    zhCoords: "49°23'N, 123°21'W",
                    enCoords: "49°23'N, 123°21'W",
                    zhRestrictions: "禁止底钓\n热门区域，很多人不知道是RCA！小心不要误入",
                    enRestrictions: "No bottom fishing\nPopular area - many anglers don't realize it's an RCA! Be careful",
                    latitude: 49.3833, longitude: -123.350
                )
                
                RCARow(
                    name: "Point Atkinson / Lighthouse Park RCA",
                    zhLocation: "Lighthouse Park 灯塔前方海域 — West Vancouver",
                    enLocation: "Waters off Lighthouse Park — West Vancouver",
                    zhCoords: "49°20'N, 123°15'W 附近岸线向外延伸",
                    enCoords: "Near 49°20'N, 123°15'W extending from shore",
                    zhRestrictions: "禁止底钓\n注意：这里是热门Chinook钓点，表层trolling允许但不能jig底",
                    enRestrictions: "No bottom fishing\nNote: Popular Chinook spot - surface trolling OK but no bottom jigging",
                    latitude: 49.3300, longitude: -123.264
                )
                
                RCARow(
                    name: "Thrasher Rock RCA",
                    zhLocation: "Gabriola Island 东南 — Georgia Strait 中部",
                    enLocation: "SE of Gabriola Island — central Georgia Strait",
                    zhCoords: "49°04'N, 123°38'W 附近",
                    enCoords: "Near 49°04'N, 123°38'W",
                    zhRestrictions: "禁止底钓\n著名Halibut/Lingcod区域但RCA部分禁止！注意边界",
                    enRestrictions: "No bottom fishing\nFamous halibut/lingcod area but RCA portion is closed! Watch boundaries",
                    latitude: 49.0667, longitude: -123.633
                )
            }
            
            // MARK: - Sponge Reef Closures
            Section(header: Text(l10n.t("🧽 玻璃海绵礁保护区 (Glass Sponge Reefs)", "🧽 Glass Sponge Reef Closures"))) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(l10n.t(
                        "⚠️ 这些区域禁止锚泊、底钓、下笼。违者最高罚款$100,000",
                        "⚠️ No anchoring, bottom fishing, or trap setting. Max fine $100,000"
                    ))
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 4)
                }
                
                RCARow(
                    name: l10n.t("Howe Sound 玻璃海绵礁 (9个区域)", "Howe Sound Glass Sponge Reefs (9 sites)"),
                    zhLocation: "分布在Howe Sound深水区域，包括 Defence Islands, Halkett Bay, Anvil Island 附近等",
                    enLocation: "Scattered across Howe Sound deep areas, including Defence Islands, Halkett Bay, near Anvil Island",
                    zhCoords: "多个保护区域，需查看DFO地图确认具体边界",
                    enCoords: "Multiple protected zones, check DFO map for exact boundaries",
                    zhRestrictions: "严禁锚泊 (No Anchoring)\n严禁底钓和任何接触海底的活动\n严禁下蟹笼/虾笼\n可以从上方通过，但不能停船作业",
                    enRestrictions: "NO anchoring\nNO bottom contact activities\nNO crab/prawn traps\nTransit allowed but no stopping for fishing",
                    latitude: 49.430, longitude: -123.350
                )
            }
            
            // MARK: - Shellfish Closures
            Section(header: Text(l10n.t("🦪 贝类污染禁区 (Shellfish Contamination)", "🦪 Shellfish Contamination Closures"))) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.t(
                        "以下区域由于水质污染，禁止采集贝类（蛤蜊、牡蛎、青口等）。螃蟹和虾不受影响。",
                        "The following areas are closed to bivalve harvesting (clams, oysters, mussels) due to contamination. Crab and prawn NOT affected."
                    ))
                    .font(.callout)
                    
                    ClosureRow(icon: "🚫", zhArea: "Vancouver Harbour (Burrard Inlet)", enArea: "Vancouver Harbour (Burrard Inlet)", zhNote: "First Narrows → Port Moody 全部 — 永久禁止采集贝类", enNote: "First Narrows → Port Moody — Permanent bivalve closure")
                    
                    ClosureRow(icon: "🚫", zhArea: "False Creek", enArea: "False Creek", zhNote: "全部水域 — 永久禁止", enNote: "All waters — Permanent closure")
                    
                    ClosureRow(icon: "🚫", zhArea: "Indian Arm 部分区域", enArea: "Parts of Indian Arm", zhNote: "Deep Cove 到 Woodlands 之间岸线区域", enNote: "Shoreline areas between Deep Cove and Woodlands")
                    
                    ClosureRow(icon: "⚠️", zhArea: "Fraser River 河口", enArea: "Fraser River Estuary", zhNote: "Roberts Bank / Sturgeon Bank — 季节性关闭，查看最新通知", enNote: "Roberts Bank / Sturgeon Bank — Seasonal, check latest notices")
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Seasonal Closures
            Section(header: Text(l10n.t("📅 季节性禁渔 (Seasonal Closures)", "📅 Seasonal Closures"))) {
                VStack(alignment: .leading, spacing: 8) {
                    SeasonRow(
                        species: l10n.t("🐟 Chinook Salmon", "🐟 Chinook Salmon"),
                        zhDetail: "Area 29: 通常全年开放但有mark-selective规则\n部分时段只能保留有脂鳍切除标记(hatchery)的鱼\n野生鱼(adipose fin intact)必须释放",
                        enDetail: "Area 29: Usually open year-round with mark-selective rules\nSome periods only hatchery-marked fish (adipose fin clipped) can be kept\nWild fish (adipose fin intact) must be released"
                    )
                    
                    SeasonRow(
                        species: l10n.t("🐟 Lingcod", "🐟 Lingcod"),
                        zhDetail: "Area 28/29: 通常开放季 5月1日 - 11月30日\n12月-4月关闭（产卵保护期）\n最低尺寸: 65cm",
                        enDetail: "Area 28/29: Typically open May 1 - Nov 30\nClosed Dec-Apr (spawning protection)\nMinimum size: 65cm"
                    )
                    
                    SeasonRow(
                        species: l10n.t("🦐 Spot Prawn", "🦐 Spot Prawn"),
                        zhDetail: "Area 28/29: 每年5月中旬 - 6月下旬（仅约6-8周！）\n具体开放日期每年不同，需关注DFO Fishery Notice\n每人每天限额: 125只（带头）",
                        enDetail: "Area 28/29: Mid-May to late June (~6-8 weeks only!)\nExact dates vary yearly - watch DFO Fishery Notices\nDaily limit: 125 per person (head-on)"
                    )
                    
                    SeasonRow(
                        species: l10n.t("🦀 Dungeness Crab", "🦀 Dungeness Crab"),
                        zhDetail: "Area 28/29: 通常全年开放\n但每年6-8月部分区域可能关闭(soft-shell期)\n最低尺寸: 165mm 甲宽\n只能保留公蟹",
                        enDetail: "Area 28/29: Usually open year-round\nSome areas may close June-Aug (soft-shell period)\nMinimum size: 165mm carapace width\nMales only"
                    )
                    
                    SeasonRow(
                        species: l10n.t("🐠 Halibut", "🐠 Halibut"),
                        zhDetail: "Area 29: 通常2月1日 - 11月（具体看配额）\n必须当天通过iRec上报（保留和释放都要！）\n每人每天1条\n最低尺寸: 无（但有最大尺寸限制126cm某些年）",
                        enDetail: "Area 29: Usually Feb 1 - Nov (quota dependent)\nMUST report same day via iRec (kept AND released!)\nDaily limit: 1 per person\nMinimum size: none (but max size 126cm some years)"
                    )
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Daily Limits
            Section(header: Text(l10n.t("📊 每日保有限额 (Daily Limits)", "📊 Daily Retention Limits"))) {
                VStack(alignment: .leading, spacing: 6) {
                    LimitRow(zhSpecies: "奇努克三文鱼", enSpecies: "Chinook Salmon", limit: "2", zhNote: "Area 29 可能有额外限制(mark-selective)", enNote: "Area 29 may have additional mark-selective restrictions")
                    LimitRow(zhSpecies: "银三文鱼", enSpecies: "Coho Salmon", limit: "4", zhNote: "通常只在8-10月开放保留", enNote: "Usually retention only open Aug-Oct")
                    LimitRow(zhSpecies: "粉三文鱼", enSpecies: "Pink Salmon", limit: "4", zhNote: "奇数年份(2025, 2027)更多", enNote: "More abundant in odd years (2025, 2027)")
                    LimitRow(zhSpecies: "狗三文鱼", enSpecies: "Chum Salmon", limit: "4", zhNote: "秋季河口附近", enNote: "Fall season near river mouths")
                    LimitRow(zhSpecies: "红三文鱼", enSpecies: "Sockeye Salmon", limit: "0-4", zhNote: "⚠️ 取决于年度回归量，很多年禁止保留", enNote: "⚠️ Depends on annual returns, often zero retention")
                    LimitRow(zhSpecies: "大比目鱼", enSpecies: "Halibut", limit: "1", zhNote: "必须iRec上报！", enNote: "Must report via iRec!")
                    LimitRow(zhSpecies: "岩鳕", enSpecies: "Lingcod", limit: "1", zhNote: "最低65cm，开放季5-11月", enNote: "Min 65cm, open season May-Nov")
                    LimitRow(zhSpecies: "岩鱼(全部)", enSpecies: "Rockfish (all)", limit: "1", zhNote: "所有岩鱼合计！注意RCA禁区", enNote: "ALL rockfish combined! Watch RCAs")
                    LimitRow(zhSpecies: "珍宝蟹", enSpecies: "Dungeness Crab", limit: "4", zhNote: "公蟹≥165mm，母蟹必须释放", enNote: "Males ≥165mm only, females must be released")
                    LimitRow(zhSpecies: "红石蟹", enSpecies: "Red Rock Crab", limit: "6", zhNote: "无性别限制", enNote: "No gender restriction")
                    LimitRow(zhSpecies: "斑点虾", enSpecies: "Spot Prawn", limit: "125", zhNote: "带头计数，季节性开放", enNote: "Head-on count, seasonal opening")
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Important Rules
            Section(header: Text(l10n.t("⚠️ 重要规则提醒", "⚠️ Important Rules"))) {
                VStack(alignment: .leading, spacing: 10) {
                    RuleRow(icon: "📋", zhRule: "必须随身携带有效 Tidal Waters Sport Fishing Licence", enRule: "Must carry valid Tidal Waters Sport Fishing Licence at all times")
                    RuleRow(icon: "🐟", zhRule: "钓三文鱼必须额外购买 Salmon Conservation Stamp", enRule: "Salmon Conservation Stamp required for salmon fishing")
                    RuleRow(icon: "📱", zhRule: "Halibut 必须当天通过 iRec 上报（保留和释放都要）", enRule: "Halibut MUST be reported same-day via iRec (kept AND released)")
                    RuleRow(icon: "📐", zhRule: "鱼从嘴尖到尾鳍自然分叉处测量长度", enRule: "Measure fish from tip of nose to fork of tail")
                    RuleRow(icon: "🏷️", zhRule: "蟹笼/虾笼浮标必须标注姓名和电话号码", enRule: "Crab/prawn trap buoys must show name & phone number")
                    RuleRow(icon: "🔓", zhRule: "蟹笼必须有逃逸环 (escape rings)，否则违法", enRule: "Crab traps MUST have escape rings or they're illegal")
                    RuleRow(icon: "🦀", zhRule: "母蟹和软壳蟹必须立即释放", enRule: "Female crabs and soft-shell crabs must be released immediately")
                    RuleRow(icon: "⏰", zhRule: "笼具不能在水中超过24小时无人看管", enRule: "Traps cannot be left unattended for more than 24 hours")
                    RuleRow(icon: "🎣", zhRule: "每人最多同时使用2根鱼竿（某些区域限1根）", enRule: "Max 2 rods per person (some areas limited to 1)")
                    RuleRow(icon: "📵", zhRule: "禁止出售休闲渔获 — 只能自用", enRule: "Selling recreational catch is ILLEGAL — personal use only")
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - iRec Reporting
            Section(header: Text(l10n.t("📱 iRec 渔获上报", "📱 iRec Catch Reporting"))) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.t(
                        "iRec 是DFO的电子渔获上报系统。以下鱼种必须上报：",
                        "iRec is DFO's electronic catch reporting system. These species MUST be reported:"
                    ))
                    .font(.callout)
                    
                    Text(l10n.t(
                        "• Halibut — 保留和释放都必须当天上报\n• Chinook Salmon — 某些区域/时段要求上报\n• Lingcod — 建议上报（未来可能强制）",
                        "• Halibut — BOTH kept and released, same day\n• Chinook Salmon — Required in some areas/periods\n• Lingcod — Recommended (may become mandatory)"
                    ))
                    .font(.callout)
                    .foregroundColor(.secondary)
                    
                    Link(destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/irec-eng.html")!) {
                        Label(l10n.t("iRec 上报网站", "iRec Reporting Website"), systemImage: "link")
                    }
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - Links
            Section(header: Text(l10n.t("🔗 官方链接", "🔗 Official Links"))) {
                Link(destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/index-eng.html")!) {
                    Label(l10n.t("DFO BC 休闲渔业指南", "DFO BC Recreational Fishing Guide"), systemImage: "book")
                }
                Link(destination: URL(string: "https://notices.dfo-mpo.gc.ca/fns-sap/index-eng.cfm")!) {
                    Label(l10n.t("DFO 渔业通知 (Fishery Notices)", "DFO Fishery Notices"), systemImage: "bell")
                }
                Link(destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/licence-permis/index-eng.html")!) {
                    Label(l10n.t("购买鱼证", "Buy Fishing Licence"), systemImage: "creditcard")
                }
                Link(destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/maps-cartes/rca-acs/index-eng.html")!) {
                    Label(l10n.t("RCA 保护区地图", "RCA Map"), systemImage: "map")
                }
                Link(destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/shellfish-mollusques/contamination/index-eng.html")!) {
                    Label(l10n.t("贝类污染禁区查询", "Shellfish Contamination Closures"), systemImage: "exclamationmark.triangle")
                }
            }
            
            Section {
                VStack(spacing: 4) {
                    Text(l10n.t(
                        "⚠️ 以上信息仅供参考。DFO法规经常更新，出海前请务必查看最新 Fishery Notices。违规罚款严重！",
                        "⚠️ Information is for reference only. DFO regulations change frequently. Always check latest Fishery Notices before heading out. Fines are severe!"
                    ))
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(l10n.infoDFO)
    }
}

// MARK: - DFO Helper Views
struct AreaInfoRow: View {
    @EnvironmentObject var l10n: L10n
    let area: String
    let zhDesc: String
    let enDesc: String
    let zhDetail: String
    let enDetail: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(area).font(.subheadline).fontWeight(.bold).foregroundColor(.blue)
                Text("—").foregroundColor(.secondary)
                Text(l10n.language == .chinese ? zhDesc : enDesc).font(.subheadline)
            }
            Text(l10n.language == .chinese ? zhDetail : enDetail)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct RCARow: View {
    @EnvironmentObject var l10n: L10n
    @EnvironmentObject var appState: AppState
    let name: String
    let zhLocation: String
    let enLocation: String
    let zhCoords: String
    let enCoords: String
    let zhRestrictions: String
    let enRestrictions: String
    var latitude: Double = 0
    var longitude: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Spacer()
                if latitude != 0 && longitude != 0 {
                    Button(action: {
                        appState.navigateToCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        appState.selectedTab = 1
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "map.fill")
                                .font(.caption2)
                            Text(l10n.t("查看地图", "Map"))
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.blue))
                    }
                }
            }
            
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: "mappin")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text(l10n.language == .chinese ? zhLocation : enLocation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: "location.circle")
                    .font(.caption2)
                    .foregroundColor(.blue)
                Text(l10n.language == .chinese ? zhCoords : enCoords)
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            
            Text(l10n.language == .chinese ? zhRestrictions : enRestrictions)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Divider()
        }
        .padding(.vertical, 2)
    }
}

struct ClosureRow: View {
    @EnvironmentObject var l10n: L10n
    let icon: String
    let zhArea: String
    let enArea: String
    let zhNote: String
    let enNote: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.language == .chinese ? zhArea : enArea)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(l10n.language == .chinese ? zhNote : enNote)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct SeasonRow: View {
    @EnvironmentObject var l10n: L10n
    let species: String
    let zhDetail: String
    let enDetail: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(species)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(l10n.language == .chinese ? zhDetail : enDetail)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
        }
    }
}

struct LimitRow: View {
    @EnvironmentObject var l10n: L10n
    let zhSpecies: String
    let enSpecies: String
    let limit: String
    let zhNote: String
    let enNote: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(l10n.language == .chinese ? zhSpecies : enSpecies)
                .font(.caption)
                .frame(width: 120, alignment: .leading)
            Text(limit)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(l10n.language == .chinese ? zhNote : enNote)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct RuleRow: View {
    @EnvironmentObject var l10n: L10n
    let icon: String
    let zhRule: String
    let enRule: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(icon)
            Text(l10n.language == .chinese ? zhRule : enRule)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
// MARK: - License Guide
struct LicenseGuideView: View {
    @EnvironmentObject var l10n: L10n
    
    var body: some View {
        List {
            Section(l10n.t("鱼证类型", "License Types")) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tidal Waters Sport Fishing Licence").font(.headline)
                    Text(l10n.t("海水钓鱼证 - 必须持有", "Saltwater fishing license - Required"))
                        .font(.caption).foregroundColor(.secondary)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Salmon Conservation Stamp").font(.headline)
                    Text(l10n.t("三文鱼保育票 - 钓三文鱼必须", "Salmon stamp - Required for salmon"))
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            Section {
                Link(l10n.t("在线购买鱼证", "Buy License Online"),
                     destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/licence-permis/application-eng.html")!)
            }
        }
        .navigationTitle(l10n.infoLicense)
    }
}

// MARK: - Gear & Bait (Pacific Vancouver specific)
struct GearRecommendationView: View {
    @EnvironmentObject var l10n: L10n
    
    var body: some View {
        List {
            Section(header: Text(l10n.t("🐟 三文鱼 (Chinook/Coho)", "🐟 Salmon (Chinook/Coho)"))) {
                GearCard(
                    rod: l10n.t("10.5ft 中重动作下海竿 (Shimano Teramar / Okuma Classic Pro)", "10.5ft MH Downrigger Rod (Shimano Teramar / Okuma Classic Pro)"),
                    reel: l10n.t("Shimano Tekota 500/600 或 Daiwa Saltist 水滴轮", "Shimano Tekota 500/600 or Daiwa Saltist Level Wind"),
                    line: l10n.t("主线 50lb braid + 前导 20-25lb fluoro", "Main: 50lb braid + Leader: 20-25lb fluorocarbon"),
                    rig: l10n.t("Downrigger钢缆 + Release Clip + Flasher + Hoochie/Spoon", "Downrigger wire + Release Clip + Flasher + Hoochie/Spoon"),
                    depth: l10n.t("40-120ft (Georgia Strait 常见深度)", "40-120ft (typical Georgia Strait depth)"),
                    notes: l10n.t("温哥华Chinook偏好Green/Chartreuse色系Flasher\nCoho对粉色/紫色反应好\n建议备2-3套不同颜色", "Vancouver Chinook prefer Green/Chartreuse Flashers\nCoho respond to Pink/Purple\nBring 2-3 color combos")
                )
            }
            
            Section(header: Text(l10n.t("🐟 三文鱼 Mooching", "🐟 Salmon Mooching"))) {
                GearCard(
                    rod: l10n.t("10-11ft 轻动作 Mooching竿 (Shimano Convergence)", "10-11ft Light Action Mooching Rod (Shimano Convergence)"),
                    reel: l10n.t("大型旋转轮 4000-5000 (Shimano Stradic / Penn Battle)", "Large Spinning Reel 4000-5000 (Shimano Stradic / Penn Battle)"),
                    line: l10n.t("主线 30lb braid + 前导 15-20lb mono", "Main: 30lb braid + Leader: 15-20lb mono"),
                    rig: l10n.t("Sliding weight 2-6oz + 双钩 Tandem Hook + Cut Plug Herring", "Sliding weight 2-6oz + Tandem Hook setup + Cut Plug Herring"),
                    depth: l10n.t("30-80ft (Point Atkinson/English Bay 近岸)", "30-80ft (Point Atkinson/English Bay nearshore)"),
                    notes: l10n.t("Georgia Strait最传统钓法\n鲱鱼需要切成旋转形状\n涨潮初期最有效", "Most traditional method in Georgia Strait\nCut herring to spin pattern\nMost effective on incoming tide")
                )
            }
            
            Section(header: Text(l10n.t("🐠 比目鱼 (Halibut)", "🐠 Halibut"))) {
                GearCard(
                    rod: l10n.t("5.5-6ft 重动作船竿 80-130lb级 (Penn Ally / Shimano Trevala)", "5.5-6ft Heavy Boat Rod 80-130lb class (Penn Ally / Shimano Trevala)"),
                    reel: l10n.t("大型水滴轮 (Penn Squall 30 / Daiwa Saltist 40)", "Large Conventional Reel (Penn Squall 30 / Daiwa Saltist 40)"),
                    line: l10n.t("主线 80-100lb braid + 前导 80lb mono/fluoro", "Main: 80-100lb braid + Leader: 80lb mono/fluorocarbon"),
                    rig: l10n.t("Spreader Bar + 16-32oz Cannonball Weight + 大号Circle Hook 8/0-10/0", "Spreader Bar + 16-32oz Cannonball Weight + Large Circle Hook 8/0-10/0"),
                    depth: l10n.t("100-300ft (Halibut Bank / Thrasher Rock)", "100-300ft (Halibut Bank / Thrasher Rock)"),
                    notes: l10n.t("温哥华Halibut季节: 2月-11月\n海流强时需要加重铅坠\n超过100lb的鱼需要Harpoon或网兜\n注意DFO保有限制", "Vancouver Halibut season: Feb-Nov\nIncrease weight in strong current\nFish over 100lb need harpoon or large net\nCheck DFO retention limits")
                )
            }
            
            Section(header: Text(l10n.t("🐡 岩鱼 (Lingcod/Rockfish)", "🐡 Lingcod/Rockfish"))) {
                GearCard(
                    rod: l10n.t("6-7ft 中重动作铁板竿 (Shimano Trevala / Okuma Cedros)", "6-7ft MH Jigging Rod (Shimano Trevala / Okuma Cedros)"),
                    reel: l10n.t("中型水滴轮 300-400 (Shimano Tranx / Daiwa Lexa)", "Medium Conventional 300-400 (Shimano Tranx / Daiwa Lexa)"),
                    line: l10n.t("主线 50-65lb braid + 前导 40lb fluoro", "Main: 50-65lb braid + Leader: 40lb fluorocarbon"),
                    rig: l10n.t("Jig Head 3-6oz + Soft Plastic (白色/珍珠色) 或 Metal Jig", "Jig Head 3-6oz + Soft Plastic (White/Pearl) or Metal Jig"),
                    depth: l10n.t("60-200ft (Bowen Island / Passage Island 礁石区)", "60-200ft (Bowen Island / Passage Island reef areas)"),
                    notes: l10n.t("⚠️ 注意RCA禁渔区 (Rockfish Conservation Areas)\nLingcod开放季: 一般5月-11月\n释放时不要拉上水面太快 (barotrauma)", "⚠️ Check RCA closures (Rockfish Conservation Areas)\nLingcod open: typically May-Nov\nRelease slowly to avoid barotrauma")
                )
            }
            
            Section(header: Text(l10n.t("🦀 螃蟹 (Dungeness Crab)", "🦀 Dungeness Crab"))) {
                GearCard(
                    rod: l10n.t("不需要鱼竿 — 使用蟹笼", "No rod needed — use crab trap"),
                    reel: l10n.t("手动绳索或电动绞盘", "Manual rope or electric winch"),
                    line: l10n.t("3/8\" 尼龙绳 200ft + 浮标", "3/8\" nylon rope 200ft + buoy float"),
                    rig: l10n.t("折叠蟹笼 (Promar / Danielson) + 饵笼 + 铅坠", "Folding crab trap (Promar / Danielson) + bait cage + weight"),
                    depth: l10n.t("30-80ft 泥沙底 (Howe Sound / Roberts Bank)", "30-80ft sandy/mud bottom (Howe Sound / Roberts Bank)"),
                    notes: l10n.t("BC蟹季: 通常6月-次年4月\n必须使用DFO认证蟹笼 (逃逸环)\n保有限制: 公蟹 ≥165mm, 每人每天4只\n浮标必须标注姓名和电话", "BC Crab season: typically June-April\nMust use DFO-certified trap (escape rings)\nRetention: Male ≥165mm, 4 per person/day\nBuoy must show name & phone number")
                )
            }
            
            Section(header: Text(l10n.t("🦐 斑点虾 (Spot Prawn)", "🦐 Spot Prawn"))) {
                GearCard(
                    rod: l10n.t("不需要鱼竿 — 使用虾笼", "No rod needed — use prawn trap"),
                    reel: l10n.t("手动绞盘或 Scotty电动 Pot Puller", "Manual winch or Scotty Electric Pot Puller"),
                    line: l10n.t("1/4\" 编织绳 400-600ft + 浮标", "1/4\" braided rope 400-600ft + buoy float"),
                    rig: l10n.t("商用虾笼 (至少4个入口) + 饵罐", "Commercial prawn trap (min 4 entrances) + bait jar"),
                    depth: l10n.t("250-500ft (Indian Arm / Howe Sound 深水区)", "250-500ft (Indian Arm / Howe Sound deep areas)"),
                    notes: l10n.t("BC斑点虾季: 5-6月 (仅约6-8周)\n用Prawn Pellets + 鱼油效果最好\n浸泡2-4小时提笼\n保有限制: 每人每天125只\nIndian Arm是温哥华最佳虾区", "BC Spot Prawn season: May-June (only ~6-8 weeks)\nPrawn Pellets + fish oil works best\nSoak 2-4 hours before pulling\nRetention: 125 per person/day\nIndian Arm is Vancouver's prime spot")
                )
            }
        }
        .navigationTitle(l10n.infoGear)
    }
}

struct GearCard: View {
    let rod: String
    let reel: String
    let line: String
    let rig: String
    let depth: String
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GearRow(icon: "🎣", label: "Rod", value: rod)
            GearRow(icon: "⚙️", label: "Reel", value: reel)
            GearRow(icon: "🧵", label: "Line", value: line)
            GearRow(icon: "🪝", label: "Rig", value: rig)
            GearRow(icon: "📏", label: "Depth", value: depth)
            Divider()
            Text(notes)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
    }
}

struct GearRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(icon)
                .font(.caption)
            Text(value)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct BaitRecommendationView: View {
    @EnvironmentObject var l10n: L10n
    
    var body: some View {
        List {
            Section(header: Text(l10n.t("🐟 三文鱼用饵", "🐟 Salmon Bait"))) {
                BaitCard(items: [
                    BaitItem(
                        name: l10n.t("Herring (鲱鱼)", "Herring"),
                        usage: l10n.t("Cut Plug / Whole — Georgia Strait #1首选活饵", "Cut Plug / Whole — #1 live bait in Georgia Strait"),
                        tips: l10n.t("Steveston码头可买新鲜鲱鱼\n切成Spin Cut让鱼饵水中旋转\n配合Mooching钓法最佳", "Buy fresh at Steveston dock\nSpin Cut for underwater rotation\nBest with Mooching technique"),
                        where_to_buy: l10n.t("Steveston Marine & Hardware / Pacific Angler", "Steveston Marine & Hardware / Pacific Angler")
                    ),
                    BaitItem(
                        name: l10n.t("Hoochie (章鱼裙)", "Hoochie (Octopus Skirt)"),
                        usage: l10n.t("搭配Flasher使用 — Downrigger钓法标配", "Used with Flasher — Standard for Downrigger"),
                        tips: l10n.t("Chinook: Green/Chartreuse/Army Truck色\nCoho: Pink/Purple/Blue色\n4-5inch最通用", "Chinook: Green/Chartreuse/Army Truck\nCoho: Pink/Purple/Blue\n4-5 inch most versatile"),
                        where_to_buy: l10n.t("Canadian Tire / Pacific Angler / Berry's Bait & Tackle", "Canadian Tire / Pacific Angler / Berry's Bait & Tackle")
                    ),
                    BaitItem(
                        name: l10n.t("Spoon (匙型亮片)", "Spoon"),
                        usage: l10n.t("单独或搭配Flasher — 模拟受伤小鱼", "Solo or with Flasher — mimics injured baitfish"),
                        tips: l10n.t("推荐: Gibbs Delta / Silver Horde\nCoho喜欢小号 (3-4\")\nChinook用大号 (4-5\")\n银色/蓝色在阴天效果好", "Recommended: Gibbs Delta / Silver Horde\nCoho like small (3-4\")\nChinook prefer large (4-5\")\nSilver/Blue works on cloudy days"),
                        where_to_buy: l10n.t("Pacific Angler / Fisherman's Supply / Island Outfitters", "Pacific Angler / Fisherman's Supply / Island Outfitters")
                    ),
                    BaitItem(
                        name: l10n.t("Anchovy (鳀鱼)", "Anchovy"),
                        usage: l10n.t("Whole Rigged — Coho最爱", "Whole Rigged — Coho favorite"),
                        tips: l10n.t("用Anchovy Head装配器固定\n保持鱼饵自然旋转\n夏季Coho季节特别有效", "Use Anchovy Head rig to secure\nKeep natural spinning action\nParticularly effective during summer Coho season"),
                        where_to_buy: l10n.t("Steveston码头鱼饵店 / Fred's Custom Tackle", "Steveston dock bait shops / Fred's Custom Tackle")
                    ),
                ])
            }
            
            Section(header: Text(l10n.t("🐠 比目鱼用饵", "🐠 Halibut Bait"))) {
                BaitCard(items: [
                    BaitItem(
                        name: l10n.t("Octopus (章鱼)", "Octopus"),
                        usage: l10n.t("整条或切块 — Halibut最爱", "Whole or cut pieces — Halibut favorite"),
                        tips: l10n.t("气味强烈，在深水引诱效果极佳\n可与Herring组合使用\n用大号Circle Hook (8/0-10/0) 穿挂", "Strong scent, excellent deep water attractant\nCan combine with Herring\nThread on large Circle Hook (8/0-10/0)"),
                        where_to_buy: l10n.t("T&T超市 / 大统华 海鲜柜台", "T&T Supermarket / Asian seafood markets")
                    ),
                    BaitItem(
                        name: l10n.t("Herring (大鲱鱼)", "Large Herring"),
                        usage: l10n.t("整条穿钩 — 广谱底钓饵", "Whole rigged — versatile bottom bait"),
                        tips: l10n.t("在Halibut Bank用16-32oz铅坠沉底\n搭配Spreader Bar避免缠线\n需要耐心等待，不要频繁收线", "Use 16-32oz weight at Halibut Bank\nUse Spreader Bar to avoid tangles\nBe patient, don't reel in frequently"),
                        where_to_buy: l10n.t("各钓具店均有冷冻鲱鱼", "Frozen herring at all tackle shops")
                    ),
                    BaitItem(
                        name: l10n.t("Salmon Belly (三文鱼肚)", "Salmon Belly"),
                        usage: l10n.t("切条状 — 强烈气味引诱", "Cut strips — strong scent attractant"),
                        tips: l10n.t("自己钓到的三文鱼留下鱼腹\n切成长条飘带状\n在Thrasher Rock区域特别有效", "Save belly from your own caught salmon\nCut into long strip streamers\nParticularly effective at Thrasher Rock"),
                        where_to_buy: l10n.t("自制最佳 — 用你钓到的三文鱼", "Best homemade — from your caught salmon")
                    ),
                ])
            }
            
            Section(header: Text(l10n.t("🦀 螃蟹饵料", "🦀 Crab Bait"))) {
                BaitCard(items: [
                    BaitItem(
                        name: l10n.t("鸡腿/鸡架", "Chicken Legs/Carcass"),
                        usage: l10n.t("放入蟹笼饵笼 — 最便宜有效", "In trap bait cage — cheapest & effective"),
                        tips: l10n.t("烤箱稍微烤一下增加气味\n一个蟹笼放2-3个鸡腿\nHowe Sound 效果极佳", "Lightly bake to increase scent\n2-3 legs per trap\nExcellent results in Howe Sound"),
                        where_to_buy: l10n.t("任何超市 — Costco鸡腿最划算", "Any supermarket — Costco legs best value")
                    ),
                    BaitItem(
                        name: l10n.t("鱼头/鱼骨", "Fish Head/Carcass"),
                        usage: l10n.t("放入饵笼 — 气味持久", "In bait cage — long-lasting scent"),
                        tips: l10n.t("三文鱼头效果最好\nRockfish或Lingcod骨架也行\n可以放入Bait Mesh Bag防止被吃光", "Salmon head works best\nRockfish or Lingcod carcass also good\nUse Bait Mesh Bag to prevent eating"),
                        where_to_buy: l10n.t("自制 — 用你钓的鱼剩余部分", "Homemade — from your fish scraps")
                    ),
                    BaitItem(
                        name: l10n.t("Cat Food (猫粮罐头)", "Cat Food (Canned)"),
                        usage: l10n.t("戳孔放入蟹笼 — 缓释气味", "Puncture holes & place in trap — slow release scent"),
                        tips: l10n.t("选鱼味猫粮罐头\n用钉子戳几个洞让气味散出\n配合鸡腿一起放效果最好", "Choose fish-flavored cans\nPuncture holes for scent release\nCombine with chicken for best results"),
                        where_to_buy: l10n.t("Dollar Store / Walmart — 最便宜的鱼味罐头", "Dollar Store / Walmart — cheapest fish flavor cans")
                    ),
                ])
            }
            
            Section(header: Text(l10n.t("🦐 虾饵", "🦐 Prawn Bait"))) {
                BaitCard(items: [
                    BaitItem(
                        name: l10n.t("Prawn Pellets (虾饵颗粒)", "Prawn Pellets"),
                        usage: l10n.t("放入虾笼饵罐 — 标准配置", "In trap bait jar — standard setup"),
                        tips: l10n.t("用专用Bait Jar带小孔缓释\nIndian Arm深水区效果最佳\n可加入少量Fish Oil增强气味", "Use perforated Bait Jar for slow release\nBest in Indian Arm deep water\nAdd small amount of Fish Oil to boost scent"),
                        where_to_buy: l10n.t("Pacific Angler / Canadian Tire / Amazon", "Pacific Angler / Canadian Tire / Amazon")
                    ),
                    BaitItem(
                        name: l10n.t("Fish Oil (鱼油)", "Fish Oil"),
                        usage: l10n.t("浸泡Pellets或滴入饵罐 — 强力引诱", "Soak Pellets or drip in jar — strong attractant"),
                        tips: l10n.t("买Salmon Oil或Herring Oil\n出发前一晚浸泡Pellets\n温哥华虾民的秘密武器", "Buy Salmon Oil or Herring Oil\nSoak Pellets night before trip\nVancouver prawners' secret weapon"),
                        where_to_buy: l10n.t("钓具店 / Amazon (Pro-Cure品牌推荐)", "Tackle shops / Amazon (Pro-Cure brand recommended)")
                    ),
                    BaitItem(
                        name: l10n.t("鱼头 + 鸡骨架", "Fish Head + Chicken Carcass"),
                        usage: l10n.t("用Mesh Bag挂在虾笼外 — 备选方案", "In Mesh Bag hung outside trap — alternative"),
                        tips: l10n.t("适合没有专用Pellets时使用\n气味散播范围大\nHowe Sound老渔民常用此法", "Good when you don't have Pellets\nLarger scent dispersion area\nOld-time Howe Sound fishers use this method"),
                        where_to_buy: l10n.t("自制", "Homemade")
                    ),
                ])
            }
            
            Section(header: Text(l10n.t("🏪 温哥华钓具店推荐", "🏪 Recommended Vancouver Tackle Shops"))) {
                VStack(alignment: .leading, spacing: 8) {
                    ShopRow(name: "Pacific Angler", address: "1520 W 3rd Ave, Vancouver", specialty: l10n.t("最全面的三文鱼装备", "Most comprehensive salmon gear"))
                    ShopRow(name: "Berry's Bait & Tackle", address: "Steveston, Richmond", specialty: l10n.t("鲱鱼/鳀鱼鲜活饵", "Fresh herring/anchovy bait"))
                    ShopRow(name: "Fred's Custom Tackle", address: "1122 56th St, Delta", specialty: l10n.t("定制Flasher/Hoochie", "Custom Flashers & Hoochies"))
                    ShopRow(name: "Island Outfitters", address: "3319 Douglas St, Victoria", specialty: l10n.t("比目鱼重装备", "Halibut heavy gear"))
                    ShopRow(name: "Canadian Tire", address: l10n.t("各分店", "Multiple locations"), specialty: l10n.t("蟹笼/虾笼/通用装备", "Crab/prawn traps & general gear"))
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text(l10n.t("📅 季节推荐", "📅 Seasonal Guide"))) {
                VStack(alignment: .leading, spacing: 8) {
                    BaitSeasonRow(season: l10n.t("🌸 春季 (3-5月)", "🌸 Spring (Mar-May)"),
                              target: l10n.t("Chinook开始活跃 + 斑点虾季", "Chinook getting active + Spot Prawn season"),
                              bait: l10n.t("Herring Cut Plug + Green Hoochie\nPrawn Pellets + Fish Oil", "Herring Cut Plug + Green Hoochie\nPrawn Pellets + Fish Oil"))
                    Divider()
                    BaitSeasonRow(season: l10n.t("☀️ 夏季 (6-8月)", "☀️ Summer (Jun-Aug)"),
                              target: l10n.t("Chinook/Coho高峰 + 蟹季 + 虾季尾声", "Chinook/Coho peak + Crab season + Prawn end"),
                              bait: l10n.t("Flasher+Hoochie (Chartreuse)\nAnchovy Whole Rig\n鸡腿蟹饵", "Flasher+Hoochie (Chartreuse)\nAnchovy Whole Rig\nChicken crab bait"))
                    Divider()
                    BaitSeasonRow(season: l10n.t("🍂 秋季 (9-11月)", "🍂 Fall (Sep-Nov)"),
                              target: l10n.t("Coho回游高峰 + Halibut + 蟹季", "Coho return peak + Halibut + Crab season"),
                              bait: l10n.t("Pink Hoochie + Silver Spoon\nOctopus (Halibut)\n三文鱼头蟹饵", "Pink Hoochie + Silver Spoon\nOctopus (Halibut)\nSalmon head crab bait"))
                    Divider()
                    BaitSeasonRow(season: l10n.t("❄️ 冬季 (12-2月)", "❄️ Winter (Dec-Feb)"),
                              target: l10n.t("Winter Chinook + 蟹季 + Lingcod", "Winter Chinook + Crab + Lingcod"),
                              bait: l10n.t("Herring Whole + Anchovy\nWhite Soft Plastic Jig (Lingcod)\n鸡腿+猫粮蟹饵", "Herring Whole + Anchovy\nWhite Soft Plastic Jig (Lingcod)\nChicken+Cat food crab bait"))
                }
                .padding(.vertical, 4)
            }
            
            Section(header: Text(l10n.t("💡 温哥华本地经验", "💡 Local Vancouver Tips"))) {
                VStack(alignment: .leading, spacing: 8) {
                    TipRow(tip: l10n.t("Georgia Strait的Chinook对Army Truck色系最敏感 (绿色+黑条纹)", "Georgia Strait Chinook respond best to Army Truck color (green + black stripes)"))
                    TipRow(tip: l10n.t("Point Atkinson附近经常出现Bait Ball，看到海鸥群聚就是信号", "Bait Balls frequently appear near Point Atkinson — seagull flocks are the signal"))
                    TipRow(tip: l10n.t("涨潮初期 (Flood Start) 是三文鱼进食的最佳时机", "Early incoming tide (Flood Start) is prime salmon feeding time"))
                    TipRow(tip: l10n.t("Indian Arm虾区最佳深度在300-450ft之间", "Indian Arm prawn sweet spot is 300-450ft depth"))
                    TipRow(tip: l10n.t("Howe Sound的蟹偏好30-60ft泥底，远离岩石区", "Howe Sound crabs prefer 30-60ft mud bottom, away from rocks"))
                    TipRow(tip: l10n.t("冬季Chinook比夏季更深 (100-180ft)，用更大号Flasher", "Winter Chinook run deeper (100-180ft) — use larger Flashers"))
                    TipRow(tip: l10n.t("Sand Heads附近水浊，用亮色/发光饵效果好", "Near Sand Heads murky water — bright/glow bait works well"))
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(l10n.infoBait)
    }
}

struct ShopRow: View {
    let name: String
    let address: String
    let specialty: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).font(.subheadline).fontWeight(.semibold)
            Text(address).font(.caption).foregroundColor(.secondary)
            Text(specialty).font(.caption2).foregroundColor(.blue)
        }
    }
}

struct BaitItem {
    let name: String
    let usage: String
    let tips: String
    let where_to_buy: String
}

struct BaitCard: View {
    let items: [BaitItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(items.indices, id: \.self) { i in
                VStack(alignment: .leading, spacing: 4) {
                    Text(items[i].name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(items[i].usage)
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(items[i].tips)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 4) {
                        Image(systemName: "cart")
                            .font(.system(size: 9))
                            .foregroundColor(.green)
                        Text(items[i].where_to_buy)
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                    if i < items.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct BaitSeasonRow: View {
    let season: String
    let target: String
    let bait: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(season).font(.subheadline).fontWeight(.semibold)
            Text(target).font(.caption).foregroundColor(.blue)
            Text(bait).font(.caption).foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct TipRow: View {
    let tip: String
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").font(.caption).foregroundColor(.orange)
            Text(tip).font(.caption).fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Restaurant
struct RestaurantListView: View {
    @EnvironmentObject var l10n: L10n
    
    struct FishRestaurant: Identifiable {
        let id = UUID()
        let icon: String
        let zhName: String
        let enName: String
        let zhAddress: String
        let enAddress: String
        let zhServices: String
        let enServices: String
        let zhNote: String
        let enNote: String
    }
    
    let restaurants: [FishRestaurant] = [
        FishRestaurant(
            icon: "🐟",
            zhName: "Steveston Fish Market",
            enName: "Steveston Fish Market",
            zhAddress: "列治文 Steveston码头旁",
            enAddress: "Steveston Wharf, Richmond",
            zhServices: "代切sashimi、鱼片加工、真空包装、冷冻储存",
            enServices: "Sashimi cutting, filleting, vacuum packing, freezer storage",
            zhNote: "最受本地钓鱼人欢迎的加工点，价格公道。带上你的渔获直接过去，师傅刀工很好。",
            enNote: "Most popular with local anglers, fair pricing. Bring your catch directly - skilled filleters."
        ),
        FishRestaurant(
            icon: "🔥",
            zhName: "The Fish Counter",
            enName: "The Fish Counter",
            zhAddress: "Main St, Vancouver",
            enAddress: "Main St, Vancouver",
            zhServices: "专业烟熏加工(hot smoke/cold smoke)、腌制、鱼干",
            enServices: "Professional smoking (hot/cold), curing, jerky",
            zhNote: "他们的alder wood烟熏三文鱼是一绝！可以做candy salmon，送人特别好。",
            enNote: "Their alder wood smoked salmon is amazing! Can make candy salmon - great for gifts."
        ),
        FishRestaurant(
            icon: "🥢",
            zhName: "渔人码头海鲜酒家 Fisherman's Terrace",
            enName: "Fisherman's Terrace",
            zhAddress: "列治文 Aberdeen Centre",
            enAddress: "Aberdeen Centre, Richmond",
            zhServices: "中式加工：清蒸、姜葱炒、避风塘、椒盐、红烧",
            enServices: "Chinese-style: steamed, ginger scallion, typhoon shelter, salt & pepper, braised",
            zhNote: "带活蟹活鱼过去，加工费按做法收。清蒸石斑和避风塘炒蟹必点。可以先打电话确认。",
            enNote: "Bring live crab/fish, cooking fee per dish. Must-try: steamed grouper & typhoon shelter crab. Call ahead to confirm."
        ),
        FishRestaurant(
            icon: "🦀",
            zhName: "海港大酒楼 Sea Harbour",
            enName: "Sea Harbour Seafood Restaurant",
            zhAddress: "列治文 River Rd",
            enAddress: "River Rd, Richmond",
            zhServices: "代蒸螃蟹、龙虾加工、活鱼加工、粤式做法",
            enServices: "Crab steaming, lobster cooking, live fish, Cantonese-style",
            zhNote: "蟹季必去！他们蒸蟹很到位，配的姜醋汁也好。可以自带斑点虾让他们白灼。",
            enNote: "A must during crab season! Perfectly steamed crab with great ginger-vinegar dip. Can bring your own spot prawns for blanching."
        ),
        FishRestaurant(
            icon: "🍣",
            zhName: "Toshi Sushi",
            enName: "Toshi Sushi",
            zhAddress: "Main St, Vancouver",
            enAddress: "Main St, Vancouver",
            zhServices: "日式加工：刺身、寿司、烤鱼、鱼头汤",
            enServices: "Japanese-style: sashimi, sushi, grilled, fish head soup",
            zhNote: "可以带自己的三文鱼过去做刺身，需要提前沟通。师傅刀工专业。",
            enNote: "Can bring your own salmon for sashimi, call ahead to arrange. Professional knife skills."
        ),
        FishRestaurant(
            icon: "🏪",
            zhName: "Steveston Seafood House",
            enName: "Steveston Seafood House",
            zhAddress: "Steveston, Richmond",
            enAddress: "Steveston, Richmond",
            zhServices: "鱼获代切、真空包装、冷冻、烟熏",
            enServices: "Filleting, vacuum packing, freezing, smoking",
            zhNote: "就在码头附近，下船直接走过去。方便快捷，渔获处理一条龙服务。",
            enNote: "Right by the wharf, walk straight from the dock. One-stop fish processing service."
        ),
        FishRestaurant(
            icon: "🍺",
            zhName: "The Flying Beaver Bar & Grill",
            enName: "The Flying Beaver Bar & Grill",
            zhAddress: "Richmond Seaplane Terminal",
            enAddress: "Richmond Seaplane Terminal",
            zhServices: "Fish & Chips、烤鱼、汉堡，不加工自带鱼",
            enServices: "Fish & Chips, grilled fish, burgers. Does NOT cook your own fish",
            zhNote: "钓鱼回来吃饭的好去处！看水上飞机起降，喝杯啤酒庆祝收获。虽然不代加工但氛围好。",
            enNote: "Great spot for post-fishing meal! Watch seaplanes while enjoying a beer. Doesn't cook your catch, but great atmosphere."
        ),
        FishRestaurant(
            icon: "🥘",
            zhName: "福满楼 Full House Seafood",
            enName: "Full House Seafood Restaurant",
            zhAddress: "列治文 No.3 Rd",
            enAddress: "No.3 Rd, Richmond",
            zhServices: "中式加工：清蒸、豉汁蒸、蒜蓉蒸、煲汤、火锅",
            enServices: "Chinese-style: steamed, black bean sauce, garlic, soup, hot pot",
            zhNote: "服务态度好，加工费合理。推荐让他们做鱼头煲汤或酸菜鱼，用你自己钓的Lingcod或Rockfish。",
            enNote: "Good service, reasonable cooking fees. Try their fish head soup or Sichuan pickled fish - great with your own lingcod or rockfish."
        ),
    ]
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text(l10n.t(
                        "以下餐厅可以加工你的渔获，建议去之前先打电话确认",
                        "These restaurants can cook your catch. Call ahead to confirm"
                    ))
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            }
            
            ForEach(restaurants) { r in
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(r.icon).font(.title2)
                            Text(l10n.language == .chinese ? r.zhName : r.enName)
                                .font(.headline)
                        }
                        
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                            Text(l10n.language == .chinese ? r.zhAddress : r.enAddress)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(l10n.t("🔧 加工服务", "🔧 Services"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(l10n.language == .chinese ? r.zhServices : r.enServices)
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(l10n.t("💡 Tips", "💡 Tips"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(l10n.language == .chinese ? r.zhNote : r.enNote)
                                .font(.callout)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(l10n.infoRestaurant)
    }
}

// MARK: - Weather & Tides (implemented in WeatherDetailView.swift and TideDetailView.swift)

// MARK: - Recipes (Full Content)
struct RecipeListView: View {
    @EnvironmentObject var l10n: L10n
    
    let fishCategories: [FishRecipeCategory] = [
        FishRecipeCategory(
            icon: "🦀",
            zhName: "螃蟹 (Dungeness Crab)",
            enName: "Dungeness Crab",
            recipes: [
                FishRecipe(
                    zhTitle: "清蒸珍宝蟹", enTitle: "Steamed Dungeness Crab",
                    style: .chinese,
                    zhIngredients: "活蟹1只(约1.5-2磅)、姜50g、镇江醋3大匙、白糖1小匙、料酒少许",
                    enIngredients: "1 live crab (1.5-2 lbs), 50g ginger, 3 tbsp Chinkiang vinegar, 1 tsp sugar, splash of Shaoxing wine",
                    zhSteps: "1. 活蟹放冰箱冷冻30分钟使其昏迷（人道处理）\n2. 用刷子清洗蟹壳和腿部\n3. 蒸锅水烧开，放入姜片和料酒\n4. 蟹肚朝上放入蒸笼（防止蟹黄流出）\n5. 大火蒸15-18分钟（1.5磅蒸15分钟，每多半磅加3分钟）\n6. 蟹壳变深橘红色即可\n7. 蘸料：姜末+镇江醋+少许糖混合",
                    enSteps: "1. Place live crab in freezer 30 min to humanely sedate\n2. Scrub shell and legs with brush\n3. Bring steamer water to boil with ginger & wine\n4. Place crab belly-up (prevents roe from leaking)\n5. Steam 15-18 min on high (15 min per 1.5 lbs, +3 min per extra half lb)\n6. Done when shell turns deep orange-red\n7. Dip: minced ginger + black vinegar + touch of sugar",
                    zhTips: "蟹肚朝上是关键，否则蟹黄全流到水里。蒸好后不要立即开盖，关火焖2分钟肉更嫩。",
                    enTips: "Belly-up is key - otherwise the roe drips out. After steaming, leave lid on 2 min before opening for more tender meat."
                ),
                FishRecipe(
                    zhTitle: "姜葱炒蟹", enTitle: "Ginger Scallion Crab",
                    style: .chinese,
                    zhIngredients: "活蟹1只、姜100g(切厚片)、大葱3根(切段)、蒜4瓣、料酒2大匙、酱油1大匙、白糖1小匙、淀粉适量、油3大匙",
                    enIngredients: "1 live crab, 100g ginger (thick slices), 3 scallion stalks (cut), 4 garlic cloves, 2 tbsp Shaoxing wine, 1 tbsp soy sauce, 1 tsp sugar, cornstarch, 3 tbsp oil",
                    zhSteps: "1. 蟹处理干净切块，蟹钳拍裂\n2. 切面拍上薄薄一层淀粉（锁住蟹肉水分）\n3. 热锅凉油，放入蟹块煎至切面变色（约2分钟）\n4. 捞出蟹块，锅中加油爆香姜片和蒜\n5. 姜香四溢时放回蟹块\n6. 淋入料酒，加酱油和糖\n7. 放入葱段大火翻炒30秒\n8. 加2大匙水盖盖焖3分钟\n9. 大火收汁，葱姜裹满蟹块即可",
                    enSteps: "1. Clean & cut crab into pieces, crack claws\n2. Lightly dust cut surfaces with cornstarch (seals in moisture)\n3. Pan-fry crab pieces cut-side down 2 min until color changes\n4. Remove crab, add oil, stir-fry ginger & garlic until fragrant\n5. Return crab pieces to wok\n6. Splash Shaoxing wine, add soy sauce & sugar\n7. Add scallions, stir-fry 30 sec on high\n8. Add 2 tbsp water, cover & braise 3 min\n9. Uncover, reduce sauce until it coats the crab",
                    zhTips: "姜一定要用足量，至少半碗姜片。大火快炒是关键，让蟹壳焦香。",
                    enTips: "Use generous amounts of ginger - at least half a bowl of slices. High heat is key for that charred wok flavor on the shell."
                ),
                FishRecipe(
                    zhTitle: "避风塘炒蟹", enTitle: "Typhoon Shelter Fried Crab",
                    style: .chinese,
                    zhIngredients: "活蟹1只、蒜2整头(切碎)、干辣椒6个、豆豉1大匙、面包糠3大匙、淀粉适量、油(炸蟹用)、葱花",
                    enIngredients: "1 live crab, 2 heads garlic (minced), 6 dried chilies, 1 tbsp fermented black beans, 3 tbsp breadcrumbs, cornstarch, oil for frying, scallions",
                    zhSteps: "1. 蟹切块拍淀粉，180°C油炸至壳变红定型（约2分钟）捞出\n2. 另起锅小火将蒜蓉慢慢炸至金黄酥脆（约5分钟）捞出备用\n3. 锅留少许底油，放入干辣椒段和豆豉爆香\n4. 放入面包糠小火炒至金黄\n5. 倒入蒜酥和蟹块大火翻炒1分钟\n6. 让蒜酥均匀裹在蟹块上\n7. 撒葱花出锅",
                    enSteps: "1. Cut crab, coat in starch, deep fry at 180°C until shell turns red (~2 min), remove\n2. Separately, slowly fry garlic on low heat until golden & crispy (~5 min), remove\n3. In same wok with a little oil, fry dried chilies & black beans until fragrant\n4. Add breadcrumbs, toast on low until golden\n5. Toss in garlic crisp + crab, stir-fry 1 min on high\n6. Ensure garlic crumbs coat all pieces evenly\n7. Garnish with scallions & serve",
                    zhTips: "炸蒜蓉一定要小火慢炸，大火会苦。面包糠让蒜酥更蓬松。这是港式经典！",
                    enTips: "Fry garlic on LOW heat - high heat makes it bitter. Breadcrumbs add extra crunch. This is a Hong Kong classic!"
                ),
                FishRecipe(
                    zhTitle: "奶油蒜香焗蟹", enTitle: "Garlic Butter Baked Crab",
                    style: .western,
                    zhIngredients: "熟蟹1只、黄油80g、蒜6瓣(切碎)、白葡萄酒60ml、柠檬1个、欧芹碎2大匙、卡宴辣椒粉少许、盐和黑胡椒",
                    enIngredients: "1 cooked crab, 80g butter, 6 garlic cloves (minced), 60ml white wine, 1 lemon, 2 tbsp chopped parsley, pinch cayenne, salt & black pepper",
                    zhSteps: "1. 蟹煮熟后切半，去除腮和内脏\n2. 黄油小火融化，加入蒜末煸香（不要焦）\n3. 加白葡萄酒煮30秒收汁\n4. 加柠檬汁、欧芹、卡宴辣椒粉\n5. 将蒜蓉黄油淋在蟹肉上\n6. 烤箱200°C烤8-10分钟至表面微焦\n7. 挤柠檬汁，配面包蘸黄油汁",
                    enSteps: "1. Cook crab, halve it, remove gills & innards\n2. Melt butter on low, sauté garlic until fragrant (don't burn)\n3. Add white wine, reduce 30 sec\n4. Add lemon juice, parsley, cayenne\n5. Pour garlic butter over crab meat\n6. Bake at 200°C for 8-10 min until lightly golden\n7. Squeeze lemon, serve with crusty bread to soak up butter",
                    zhTips: "用好黄油是关键！蟹肉已经熟了所以烤的时间不用太长，主要是让黄油渗入。配酸面包最佳。",
                    enTips: "Quality butter is key! Crab is already cooked so baking is just to let butter soak in. Best served with sourdough bread."
                ),
                FishRecipe(
                    zhTitle: "蟹饼配柠檬蒜泥蛋黄酱", enTitle: "Crab Cakes with Lemon Aioli",
                    style: .western,
                    zhIngredients: "蟹肉300g、面包糠1/2杯、蛋黄酱3大匙、第戎芥末1小匙、鸡蛋1个、红甜椒碎2大匙、欧芹碎1大匙、Old Bay调味粉1小匙、柠檬汁、蒜泥蛋黄酱",
                    enIngredients: "300g crab meat, 1/2 cup breadcrumbs, 3 tbsp mayonnaise, 1 tsp Dijon mustard, 1 egg, 2 tbsp diced red pepper, 1 tbsp parsley, 1 tsp Old Bay, lemon juice, aioli for serving",
                    zhSteps: "1. 蟹肉挑去壳碎，轻轻拆散（保留大块）\n2. 碗中混合蛋黄酱、芥末、鸡蛋、调味粉\n3. 轻轻拌入蟹肉、面包糠、红椒、欧芹\n4. 分成6个饼状（不要压太紧）\n5. 冰箱冷藏30分钟定型\n6. 平底锅中火放黄油，每面煎3-4分钟至金黄\n7. 配柠檬蒜泥蛋黄酱和混合生菜",
                    enSteps: "1. Pick through crab meat for shell bits, gently flake (keep large chunks)\n2. Mix mayo, mustard, egg, Old Bay in bowl\n3. Gently fold in crab, breadcrumbs, red pepper, parsley\n4. Form 6 patties (don't compress too tightly)\n5. Refrigerate 30 min to firm up\n6. Pan-fry in butter, 3-4 min each side until golden\n7. Serve with lemon aioli and mixed greens",
                    zhTips: "蟹肉不要搅拌过度！保留大块口感更好。冷藏定型这步不能省，否则下锅会散。",
                    enTips: "Don't over-mix the crab! Keep large chunks for better texture. Chilling step is essential or they'll fall apart in the pan."
                ),
            ]
        ),
        FishRecipeCategory(
            icon: "🦐",
            zhName: "斑点虾 (Spot Prawn)",
            enName: "Spot Prawn",
            recipes: [
                FishRecipe(
                    zhTitle: "白灼斑点虾", enTitle: "Blanched Spot Prawns",
                    style: .chinese,
                    zhIngredients: "活斑点虾1磅、姜3片、料酒1大匙、冰水一大碗\n蘸料：酱油2大匙、芥末适量（或姜末+醋）",
                    enIngredients: "1 lb live spot prawns, 3 ginger slices, 1 tbsp wine, bowl of ice water\nDip: 2 tbsp soy + wasabi (or ginger-vinegar)",
                    zhSteps: "1. 大锅烧水至沸腾，加姜片和料酒\n2. 活虾快速放入（不要犹豫，一次全部下锅）\n3. 虾壳变红、虾身卷曲即捞出（约90秒-2分钟）\n4. 立即放入冰水中过凉30秒（保持弹性）\n5. 沥干摆盘\n6. 配酱油芥末或姜醋汁",
                    enSteps: "1. Bring large pot of water to rolling boil, add ginger & wine\n2. Add live prawns all at once (don't hesitate)\n3. Remove when shells turn red & bodies curl (~90 sec - 2 min)\n4. Immediately plunge into ice bath 30 sec (keeps them snappy)\n5. Drain and plate\n6. Serve with soy-wasabi or ginger-vinegar dip",
                    zhTips: "关键是不要煮过头！宁可少10秒也不要多10秒。虾头里的膏是精华，吸着吃。活虾才有这个弹牙口感。",
                    enTips: "Key: DON'T overcook! Better 10 sec under than 10 sec over. The head contains rich roe/tomalley - suck it out. Only live prawns give that snappy texture."
                ),
                FishRecipe(
                    zhTitle: "斑点虾刺身", enTitle: "Spot Prawn Sashimi",
                    style: .japanese,
                    zhIngredients: "活斑点虾8-10只、冰块大量、酱油、新鲜芥末、紫苏叶（装饰）",
                    enIngredients: "8-10 live spot prawns, lots of ice, soy sauce, fresh wasabi, shiso leaves (garnish)",
                    zhSteps: "1. 确保虾是活的（弹跳有力）\n2. 捏住头部和身体连接处，快速一拧分离头身\n3. 从虾腹剥壳，保持尾部完整\n4. 用竹签从背部挑出虾线\n5. 冰盘上铺紫苏叶，摆放虾身\n6. 虾头另外留下（可炸或煮汤）\n7. 配酱油和现磨芥末食用",
                    enSteps: "1. Ensure prawns are alive (jumping vigorously)\n2. Pinch where head meets body, twist to separate\n3. Peel shell from belly side, keep tail intact\n4. Use toothpick to remove vein from back\n5. Plate on ice with shiso leaves\n6. Reserve heads (deep fry or make soup)\n7. Serve with soy sauce and fresh-grated wasabi",
                    zhTips: "斑点虾是温哥华最适合做刺身的虾！肉质甜嫩弹牙，5月初刚开季的虾最肥美。虾头一定要留着炸，超级香脆。",
                    enTips: "Spot prawns are THE best sashimi prawn in Vancouver! Sweet, tender & snappy. Early May prawns are the plumpest. Always save heads for deep frying - insanely crispy & rich."
                ),
                FishRecipe(
                    zhTitle: "蒜蓉粉丝蒸虾", enTitle: "Garlic Glass Noodle Steamed Prawns",
                    style: .chinese,
                    zhIngredients: "斑点虾12只、粉丝1把(泡软)、蒜1整头(切蓉)、生抽2大匙、蒸鱼豉油1大匙、油3大匙、小葱2根、红辣椒1个(装饰)",
                    enIngredients: "12 spot prawns, 1 bundle glass noodles (soaked), 1 head garlic (minced), 2 tbsp soy sauce, 1 tbsp steamed fish soy, 3 tbsp oil, 2 scallions, 1 red chili (garnish)",
                    zhSteps: "1. 虾从背部剪开去虾线（保留虾壳增香）\n2. 粉丝泡软剪短，拌入少许酱油铺盘底\n3. 虾开背朝上整齐摆放在粉丝上\n4. 蒜蓉分两份：一半拌油和酱油做成蒜蓉酱，堆在每只虾上\n5. 大火蒸5-6分钟（虾大则6分钟）\n6. 出锅撒葱花和红椒丝\n7. 热锅烧油至冒烟，淋在蒜蓉葱花上（呲呲作响）\n8. 最后淋蒸鱼豉油",
                    enSteps: "1. Cut prawns along the back, devein (keep shell for flavor)\n2. Soak noodles, cut short, toss with soy sauce, spread on plate\n3. Arrange prawns back-up on noodles\n4. Mix half the garlic with oil & soy to make sauce, pile on each prawn\n5. Steam 5-6 min on high (6 min for large ones)\n6. Top with scallions & chili shreds\n7. Heat oil until smoking, pour over garlic & scallions (sizzle!)\n8. Drizzle steamed fish soy sauce",
                    zhTips: "最后淋热油那一步是灵魂！油一定要烧到冒烟再淋，才有那个锅气。粉丝会吸收虾的鲜味，比虾还好吃。",
                    enTips: "The hot oil drizzle at the end is THE soul of this dish! Oil must be smoking hot for that wok-hei sizzle. The noodles absorb all the prawn flavor - often tastier than the prawns themselves."
                ),
                FishRecipe(
                    zhTitle: "椒盐斑点虾", enTitle: "Salt & Pepper Spot Prawns",
                    style: .chinese,
                    zhIngredients: "斑点虾1磅、淀粉3大匙、蒜4瓣(切碎)、干辣椒4个(切段)、花椒粒1小匙、椒盐粉1大匙、葱花、油(炸用)",
                    enIngredients: "1 lb spot prawns, 3 tbsp cornstarch, 4 garlic cloves (minced), 4 dried chilies (cut), 1 tsp Sichuan peppercorns, 1 tbsp salt-pepper mix, scallions, oil for frying",
                    zhSteps: "1. 虾剪须和虾枪，从背部剪开去虾线\n2. 拍上薄淀粉（不用蘸很多）\n3. 油温180°C炸至金黄酥脆（约2分钟）捞出\n4. 锅留一大匙底油\n5. 小火爆香蒜末、辣椒段、花椒粒\n6. 倒入炸虾，撒椒盐粉大火翻炒30秒\n7. 撒葱花出锅",
                    enSteps: "1. Trim whiskers & rostrum, devein from back\n2. Lightly coat with cornstarch\n3. Deep fry at 180°C until golden crispy (~2 min), remove\n4. Keep 1 tbsp oil in wok\n5. Low heat: fry garlic, chili, Sichuan pepper until fragrant\n6. Toss in fried prawns, add salt-pepper mix, stir-fry 30 sec on high\n7. Garnish with scallions & serve",
                    zhTips: "壳都能吃！炸得够脆的话连壳带肉一起嚼，是最好的下酒菜。花椒要现炒的才有麻劲儿。",
                    enTips: "You can eat the shell! If fried crispy enough, chew shell and all - best beer snack ever. Use fresh-toasted Sichuan pepper for the numbing kick."
                ),
                FishRecipe(
                    zhTitle: "斑点虾意面", enTitle: "Spot Prawn Linguine",
                    style: .western,
                    zhIngredients: "斑点虾12只(去壳留头)、意面200g、蒜4瓣、白葡萄酒80ml、小番茄10个(切半)、黄油2大匙、橄榄油2大匙、红辣椒碎、欧芹、帕玛森奶酪",
                    enIngredients: "12 spot prawns (peeled, save heads), 200g linguine, 4 garlic cloves, 80ml white wine, 10 cherry tomatoes (halved), 2 tbsp butter, 2 tbsp olive oil, chili flakes, parsley, Parmesan",
                    zhSteps: "1. 煮意面至al dente（比包装时间少1分钟）留1杯面水\n2. 虾头用橄榄油小火煎出橙红色虾油（3分钟）捞出头\n3. 同锅加黄油蒜末爆香\n4. 放小番茄煎软，加辣椒碎\n5. 倒白葡萄酒收汁一半\n6. 放入虾仁两面煎30秒变色\n7. 加入意面和半杯面水翻拌\n8. 关火加帕玛森奶酪和欧芹拌匀",
                    enSteps: "1. Cook pasta to al dente (1 min less than package), save 1 cup pasta water\n2. Fry prawn heads in olive oil on low to extract orange prawn oil (3 min), remove heads\n3. In same pan, add butter & garlic, sauté\n4. Add cherry tomatoes, cook until soft, add chili flakes\n5. Deglaze with white wine, reduce by half\n6. Add prawn meat, sear 30 sec each side\n7. Toss in pasta with half cup pasta water\n8. Off heat, stir in Parmesan & parsley",
                    zhTips: "虾头煎出的虾油是这道菜的秘密武器！颜色金红，鲜味爆炸。面水的淀粉帮助酱汁挂面。不要煮过虾仁！",
                    enTips: "The prawn head oil is the SECRET weapon! Golden-red color, umami bomb. Pasta water starch helps sauce cling to noodles. Don't overcook the prawns!"
                ),
                FishRecipe(
                    zhTitle: "蒜香黄油虾配烤面包", enTitle: "Garlic Butter Prawns with Crostini",
                    style: .western,
                    zhIngredients: "斑点虾1磅(去壳)、黄油60g、蒜5瓣(切片)、白葡萄酒3大匙、柠檬1个、红辣椒碎、欧芹碎、法棍面包切片",
                    enIngredients: "1 lb spot prawns (peeled), 60g butter, 5 garlic cloves (sliced), 3 tbsp white wine, 1 lemon, chili flakes, chopped parsley, sliced baguette",
                    zhSteps: "1. 铸铁锅或平底锅大火烧热\n2. 放入黄油融化至起泡\n3. 加蒜片煸至金黄边缘\n4. 放入虾仁单层铺开，不要翻动1分钟\n5. 翻面，加白葡萄酒和辣椒碎\n6. 挤入柠檬汁，撒欧芹\n7. 配烤脆的法棍蘸黄油汁食用\n8. 连锅上桌最佳",
                    enSteps: "1. Heat cast iron or skillet on high\n2. Add butter, melt until foaming\n3. Add garlic slices, cook until edges golden\n4. Add prawns in single layer, DON'T touch for 1 min\n5. Flip, add white wine & chili flakes\n6. Squeeze lemon, scatter parsley\n7. Serve with toasted baguette for dipping\n8. Serve in the pan for best presentation",
                    zhTips: "虾下锅不要急着翻！让一面煎出焦香Maillard反应。配酸面包蘸蒜黄油汁是灵魂吃法。",
                    enTips: "Don't rush the flip! Let one side develop a golden Maillard crust. Sourdough dipped in the garlic butter sauce is the real star."
                ),
            ]
        ),
        FishRecipeCategory(
            icon: "🐟",
            zhName: "三文鱼 (Salmon)",
            enName: "Salmon (Chinook/Coho/Sockeye)",
            recipes: [
                FishRecipe(
                    zhTitle: "三文鱼刺身", enTitle: "Salmon Sashimi",
                    style: .japanese,
                    zhIngredients: "新鲜三文鱼柳400g(sashimi grade)、酱油、新鲜芥末、姜片、萝卜丝(装饰)",
                    enIngredients: "400g fresh salmon fillet (sashimi grade), soy sauce, fresh wasabi, ginger slices, daikon shreds (garnish)",
                    zhSteps: "1. 重要：必须冷冻-20°C 48小时或-35°C 15小时杀寄生虫\n2. 冰箱解冻（约12小时）\n3. 用锋利刺身刀，45度角切3-5mm厚片\n4. 切时一刀拉到底，不要来回锯\n5. 冰盘铺萝卜丝，摆放鱼片\n6. 配酱油、现磨芥末、姜片",
                    enSteps: "1. IMPORTANT: Must freeze at -20°C for 48hrs or -35°C for 15hrs to kill parasites\n2. Thaw in fridge (~12 hours)\n3. Use sharp sashimi knife at 45° angle, cut 3-5mm slices\n4. Pull knife in one smooth stroke - never saw back and forth\n5. Plate on daikon shreds over ice\n6. Serve with soy, fresh wasabi, ginger",
                    zhTips: "Chinook(春鲑)脂肪最高最适合刺身，口感入口即化。Sockeye颜色最红但脂肪较少。绝对不要用超市普通三文鱼做刺身！必须确认是sashimi grade。",
                    enTips: "Chinook (Spring) has highest fat content, best for sashimi - melts in mouth. Sockeye is reddest but leaner. NEVER use regular supermarket salmon for sashimi! Must confirm sashimi grade."
                ),
                FishRecipe(
                    zhTitle: "味噌烤三文鱼", enTitle: "Miso-Glazed Salmon",
                    style: .japanese,
                    zhIngredients: "三文鱼排4块(皮付)、白味噌3大匙、味醂2大匙、清酒1大匙、糖1大匙、姜泥1小匙",
                    enIngredients: "4 salmon fillets (skin-on), 3 tbsp white miso, 2 tbsp mirin, 1 tbsp sake, 1 tbsp sugar, 1 tsp grated ginger",
                    zhSteps: "1. 混合味噌、味醂、清酒、糖、姜泥做腌料\n2. 三文鱼均匀涂抹腌料\n3. 保鲜膜包好冷藏腌制至少4小时（过夜最佳）\n4. 取出鱼排轻轻擦去多余腌料（防止焦糊）\n5. 烤箱设broil/上火220°C\n6. 烤8-10分钟至表面焦糖化\n7. 配米饭和腌姜",
                    enSteps: "1. Mix miso, mirin, sake, sugar, ginger for marinade\n2. Coat salmon evenly with marinade\n3. Wrap and refrigerate at least 4 hrs (overnight best)\n4. Remove, gently wipe off excess marinade (prevents burning)\n5. Set oven to broil / upper heat 220°C\n6. Broil 8-10 min until caramelized on top\n7. Serve with rice and pickled ginger",
                    zhTips: "Nobu餐厅的招牌菜简化版！腌过夜味道渗透更好。多余的腌料一定要擦掉否则会烧焦发苦。",
                    enTips: "Simplified version of Nobu's signature dish! Overnight marination gives deeper flavor. MUST wipe off excess or it'll burn and taste bitter."
                ),
                FishRecipe(
                    zhTitle: "盐烤三文鱼 (Shioyake)", enTitle: "Salt-Grilled Salmon (Shioyake)",
                    style: .japanese,
                    zhIngredients: "三文鱼排2块(带皮)、粗海盐2大匙、柠檬1个、萝卜泥(配菜)",
                    enIngredients: "2 salmon fillets (skin-on), 2 tbsp coarse sea salt, 1 lemon, grated daikon (garnish)",
                    zhSteps: "1. 鱼排两面均匀撒粗海盐\n2. 放置20-30分钟出水（这步很重要！去腥提鲜）\n3. 用纸巾吸干表面水分\n4. 皮面朝下放入热锅（不需要油）\n5. 中火煎皮面4-5分钟至酥脆金黄\n6. 翻面再煎2-3分钟（肉面不要煎太久）\n7. 配柠檬角和萝卜泥",
                    enSteps: "1. Salt both sides of fillet evenly with coarse sea salt\n2. Rest 20-30 min to draw out moisture (essential! removes fishiness)\n3. Pat surface dry with paper towel\n4. Place skin-side down in hot dry pan (no oil needed)\n5. Cook skin 4-5 min on medium until crispy golden\n6. Flip, cook flesh side 2-3 min (don't overcook)\n7. Serve with lemon wedge and grated daikon",
                    zhTips: "最简单也是最考验食材新鲜度的做法。盐腌出水那一步千万不能省！脆皮是灵魂。鱼中心保持微粉色最完美。",
                    enTips: "Simplest method that showcases fish freshness. The salting/resting step is NON-NEGOTIABLE! Crispy skin is the soul. Perfect when center stays slightly pink."
                ),
                FishRecipe(
                    zhTitle: "三文鱼头豆腐汤", enTitle: "Salmon Head & Tofu Soup",
                    style: .chinese,
                    zhIngredients: "三文鱼头1个(劈开)、嫩豆腐1块、白萝卜半根、姜6片、葱3根、料酒2大匙、白胡椒粉、盐、香菜",
                    enIngredients: "1 salmon head (split), 1 block silken tofu, 1/2 daikon radish, 6 ginger slices, 3 scallions, 2 tbsp wine, white pepper, salt, cilantro",
                    zhSteps: "1. 鱼头去鳃（鳃有腥味），冲洗干净\n2. 热锅放少许油，鱼头两面煎至金黄（约3分钟每面）\n3. 这步是关键！煎过的鱼头汤才会变乳白色\n4. 加姜片、料酒，注入热水（一定要热水！冷水汤不白）\n5. 大火煮开后转中小火炖30-40分钟\n6. 汤变成浓白色后加入豆腐块和萝卜片\n7. 再煮10分钟\n8. 加盐和白胡椒调味\n9. 撒葱花和香菜",
                    enSteps: "1. Remove gills (they taste fishy), rinse head clean\n2. Pan-fry head in a little oil until golden (~3 min each side)\n3. KEY STEP! Frying makes the soup turn milky white\n4. Add ginger & wine, pour in HOT water (cold water = clear soup)\n5. Bring to boil, then simmer 30-40 min on med-low\n6. Once soup is creamy white, add tofu cubes & radish slices\n7. Cook 10 more minutes\n8. Season with salt & white pepper\n9. Garnish with scallions & cilantro",
                    zhTips: "两个关键：1.鱼头必须煎香！2.必须加热水！做到这两点汤一定是浓白色。Chinook鱼头最大最肥，一个头就能煮一大锅。",
                    enTips: "Two secrets: 1. MUST fry the head golden! 2. MUST add HOT water! Do both and soup will be creamy white. Chinook heads are biggest & fattiest - one head makes a huge pot."
                ),
                FishRecipe(
                    zhTitle: "烟熏三文鱼", enTitle: "Cold-Smoked Salmon (Lox)",
                    style: .western,
                    zhIngredients: "三文鱼柳1整条(约1kg去皮)、粗海盐1杯、红糖1杯、黑胡椒2大匙、新鲜莳萝1把、Alder木屑",
                    enIngredients: "1 whole salmon fillet (~1kg, skinned), 1 cup coarse sea salt, 1 cup brown sugar, 2 tbsp black pepper, bunch of fresh dill, alder wood chips",
                    zhSteps: "1. 混合盐+糖+胡椒做腌料\n2. 鱼肉铺在保鲜膜上，均匀覆盖腌料和莳萝\n3. 紧紧包裹，放在有边烤盘上\n4. 上面压重物（如另一个烤盘+罐头）\n5. 冷藏腌制24-48小时（36小时最佳）\n6. 取出冲洗干净，拍干\n7. 放在架子上冰箱风干8-12小时形成pellicle（表面变得微黏发亮）\n8. 冷烟熏：温度保持<30°C，烟熏6-10小时\n9. 使用Alder wood chips（BC经典木材）\n10. 熏好后冷藏静置24小时再切薄片",
                    enSteps: "1. Mix salt + sugar + pepper for cure\n2. Lay fillet on cling wrap, cover evenly with cure & dill\n3. Wrap tightly, place on rimmed tray\n4. Weigh down (another tray + cans)\n5. Cure in fridge 24-48 hrs (36 hrs ideal)\n6. Rinse off cure, pat dry\n7. Air-dry on rack in fridge 8-12 hrs to form pellicle (surface becomes tacky & glossy)\n8. Cold smoke: keep temp <30°C, smoke 6-10 hrs\n9. Use Alder wood chips (BC classic)\n10. After smoking, rest 24 hrs in fridge before slicing thin",
                    zhTips: "这是一个3天的项目但非常值得！Pellicle（风干表膜）是烟能附着的关键。Alder是太平洋西北最传统的烟熏木。切片时用最锋利的刀斜切薄片。",
                    enTips: "This is a 3-day project but SO worth it! The pellicle (dried surface film) is essential for smoke adhesion. Alder is the Pacific Northwest traditional smoke wood. Slice thin at an angle with your sharpest knife."
                ),
                FishRecipe(
                    zhTitle: "香煎三文鱼配奶油莳萝酱", enTitle: "Pan-Seared Salmon with Cream Dill Sauce",
                    style: .western,
                    zhIngredients: "三文鱼排4块(带皮)、橄榄油、盐和黑胡椒\n酱汁：黄油1大匙、青葱2根、白葡萄酒60ml、浓奶油120ml、新鲜莳萝3大匙、柠檬汁1大匙、第戎芥末1小匙",
                    enIngredients: "4 salmon fillets (skin-on), olive oil, salt & pepper\nSauce: 1 tbsp butter, 2 shallots, 60ml white wine, 120ml heavy cream, 3 tbsp fresh dill, 1 tbsp lemon juice, 1 tsp Dijon mustard",
                    zhSteps: "1. 鱼排提前20分钟取出回温\n2. 皮面用刀轻划几道（防止卷曲）\n3. 两面撒盐和黑胡椒\n4. 平底锅大火烧热，放橄榄油\n5. 皮面朝下放入，用铲子压住10秒（保持平整）\n6. 中大火煎皮4分钟至酥脆\n7. 翻面煎2-3分钟（看厚度）\n8. 取出鱼排休息\n9. 同锅加黄油炒青葱\n10. 白葡萄酒收汁，加奶油小火煮2分钟\n11. 加莳萝、柠檬汁、芥末\n12. 淋酱汁在鱼排上",
                    enSteps: "1. Bring fillets to room temp 20 min before cooking\n2. Score skin lightly (prevents curling)\n3. Season both sides with salt & pepper\n4. Heat pan on high with olive oil\n5. Place skin-down, press with spatula 10 sec (keeps flat)\n6. Cook skin 4 min on med-high until crispy\n7. Flip, cook 2-3 min (depending on thickness)\n8. Remove fish to rest\n9. Same pan: add butter, sauté shallots\n10. Deglaze with wine, reduce, add cream, simmer 2 min\n11. Stir in dill, lemon juice, mustard\n12. Pour sauce over fish",
                    zhTips: "脆皮三文鱼的秘诀：皮面一定要完全干燥！下锅前用纸巾彻底擦干。不要急着翻面，皮自然会脱离锅底。鱼中心保持半熟最嫩。",
                    enTips: "Crispy skin secret: skin MUST be completely dry! Pat thoroughly with paper towels before cooking. Don't rush the flip - skin will release naturally when ready. Keep center medium-rare for best texture."
                ),
                FishRecipe(
                    zhTitle: "枫糖烤三文鱼", enTitle: "Maple-Glazed Cedar Plank Salmon",
                    style: .western,
                    zhIngredients: "三文鱼整条柳500g、雪松木板1块(泡水2小时)、枫糖浆3大匙、酱油1大匙、第戎芥末1大匙、蒜2瓣(切蓉)、黑胡椒",
                    enIngredients: "500g salmon fillet, 1 cedar plank (soaked 2 hrs), 3 tbsp maple syrup, 1 tbsp soy sauce, 1 tbsp Dijon mustard, 2 garlic cloves (minced), black pepper",
                    zhSteps: "1. 雪松木板提前浸泡水中至少2小时\n2. 混合枫糖、酱油、芥末、蒜做酱汁\n3. 三文鱼放在木板上，刷上酱汁\n4. 烤箱200°C或BBQ中火\n5. 烤12-15分钟至鱼肉内部达60°C\n6. 最后2分钟再刷一层酱汁\n7. 连木板一起上桌（很有仪式感）",
                    enSteps: "1. Soak cedar plank in water at least 2 hours\n2. Mix maple syrup, soy sauce, mustard, garlic for glaze\n3. Place salmon on plank, brush with glaze\n4. Oven at 200°C or BBQ on medium\n5. Cook 12-15 min until internal temp reaches 60°C\n6. Brush another layer of glaze for last 2 min\n7. Serve on the plank for dramatic presentation",
                    zhTips: "这是BC最经典的做法之一！木板泡水防止着火的同时给鱼肉增添烟熏雪松香。用真正加拿大枫糖浆（不是玉米糖浆假货）。",
                    enTips: "This is THE most iconic BC salmon preparation! Soaking prevents fire while infusing cedar smoke flavor. Use REAL Canadian maple syrup (not corn syrup imitation)."
                ),
            ]
        ),
        FishRecipeCategory(
            icon: "🐟",
            zhName: "比目鱼 (Halibut)",
            enName: "Halibut",
            recipes: [
                FishRecipe(
                    zhTitle: "清蒸比目鱼", enTitle: "Cantonese Steamed Halibut",
                    style: .chinese,
                    zhIngredients: "比目鱼柳400g(切2cm厚)、姜丝大量、葱丝1把、红椒丝少许、蒸鱼豉油3大匙、油3大匙、料酒1大匙",
                    enIngredients: "400g halibut fillet (2cm thick), generous ginger shreds, 1 handful scallion shreds, some red chili shreds, 3 tbsp steamed fish soy, 3 tbsp oil, 1 tbsp wine",
                    zhSteps: "1. 鱼块抹少许盐和料酒腌5分钟\n2. 盘底铺筷子或姜片架高（让蒸汽环绕）\n3. 鱼肉放上，铺少许姜丝\n4. 水开后放入，大火蒸8-10分钟（看厚度）\n5. 蒸好倒掉盘中蒸出的水（这个水很腥！）\n6. 铺上新鲜的葱丝、姜丝、红椒丝\n7. 烧3大匙油至冒烟，淋在葱姜上（呲呲响）\n8. 最后均匀浇蒸鱼豉油",
                    enSteps: "1. Rub fish with salt & wine, rest 5 min\n2. Elevate fish on plate with chopsticks or ginger (allows steam circulation)\n3. Place fish, add some ginger shreds on top\n4. Once water boils, steam 8-10 min on high (depends on thickness)\n5. Pour out steaming liquid (it's fishy!)\n6. Top with fresh scallion, ginger & chili shreds\n7. Heat 3 tbsp oil until smoking, pour over the toppings (sizzle!)\n8. Drizzle steamed fish soy sauce evenly",
                    zhTips: "蒸鱼三要素：1.火要猛 2.时间要准 3.蒸汁要倒掉！比目鱼肉嫩，宁可少蒸也不要过头。筷子戳进去不费力就熟了。",
                    enTips: "3 rules for steaming fish: 1. FIERCE fire 2. PRECISE timing 3. DRAIN the liquid! Halibut is delicate - err on undercooking. It's done when a chopstick slides in easily."
                ),
                FishRecipe(
                    zhTitle: "炸鱼薯条", enTitle: "Classic Fish & Chips",
                    style: .western,
                    zhIngredients: "比目鱼柳500g(切大条)、中筋面粉1.5杯、冰镇啤酒250ml、泡打粉1小匙、盐、白胡椒、油(炸用)、大号薯仔3个\n配料：Tartar sauce、麦芽醋、柠檬角",
                    enIngredients: "500g halibut (cut into strips), 1.5 cups flour, 250ml ice-cold beer, 1 tsp baking powder, salt, white pepper, oil for frying, 3 large potatoes\nServe with: tartar sauce, malt vinegar, lemon wedges",
                    zhSteps: "1. 薯仔切粗条，冷水泡30分钟去淀粉\n2. 薯条先160°C油炸5分钟至软（第一次炸），捞出\n3. 做面糊：面粉+泡打粉+盐+白胡椒，倒入冰啤酒搅拌（有小颗粒OK）\n4. 鱼块拍干，撒薄面粉\n5. 裹面糊让多余的滴落\n6. 180°C油温，放入鱼块炸4-5分钟至金黄酥脆\n7. 捞出沥油，放在架子上（不要放纸巾上会变软）\n8. 薯条升温至190°C复炸2分钟至金黄酥脆\n9. 撒盐，配tartar sauce和麦芽醋",
                    enSteps: "1. Cut potatoes into thick chips, soak in cold water 30 min\n2. First fry chips at 160°C for 5 min until soft, remove\n3. Make batter: flour + baking powder + salt + white pepper, stir in ice-cold beer (small lumps OK)\n4. Pat fish dry, dust with thin flour\n5. Dip in batter, let excess drip off\n6. Fry at 180°C for 4-5 min until golden & crispy\n7. Drain on wire rack (NOT paper towels - that makes it soggy)\n8. Second-fry chips at 190°C for 2 min until golden & crispy\n9. Season with salt, serve with tartar sauce & malt vinegar",
                    zhTips: "面糊用冰啤酒是关键！CO2+低温=超级酥脆。不要搅拌过度，有疙瘩没关系。薯条两次油炸法（先低温再高温）是餐厅级别的秘诀。Halibut是做fish & chips最好的鱼！",
                    enTips: "ICE-COLD beer is key! CO2 + low temp = ultra crispy. Don't over-mix batter, lumps are fine. Double-frying chips (low then high temp) is the restaurant secret. Halibut makes THE best fish & chips!"
                ),
                FishRecipe(
                    zhTitle: "比目鱼Ceviche", enTitle: "Halibut Ceviche",
                    style: .fusion,
                    zhIngredients: "极新鲜比目鱼300g(切1cm丁)、青柠5个(榨汁)、红洋葱半个(切薄)、墨西哥辣椒1个(去籽切碎)、香菜1把、小番茄8个(切4份)、牛油果1个、盐、玉米片",
                    enIngredients: "300g super-fresh halibut (1cm dice), 5 limes (juiced), 1/2 red onion (thin sliced), 1 jalapeño (seeded, minced), bunch cilantro, 8 cherry tomatoes (quartered), 1 avocado, salt, tortilla chips",
                    zhSteps: "1. 鱼切1cm方丁（大小一致很重要！腌制均匀）\n2. 放入碗中，倒入足量青柠汁完全覆盖\n3. 加盐拌匀，盖保鲜膜冷藏\n4. 腌制20-30分钟（鱼肉变白变不透明即可）\n5. 沥掉大部分柠檬汁\n6. 加入红洋葱、辣椒、番茄、香菜轻轻拌匀\n7. 尝味道补盐\n8. 食用时放牛油果丁，配玉米片",
                    enSteps: "1. Dice fish into 1cm cubes (uniform size is important for even curing!)\n2. Place in bowl, add enough lime juice to fully cover\n3. Add salt, toss gently, cover with plastic wrap\n4. Refrigerate 20-30 min (done when fish turns white & opaque)\n5. Drain most of the lime juice\n6. Gently fold in onion, jalapeño, tomatoes, cilantro\n7. Taste and adjust salt\n8. Top with avocado cubes when serving, eat with tortilla chips",
                    zhTips: "鱼必须极新鲜！刚钓上来的最好。不要腌超过40分钟否则口感变硬。红洋葱提前泡冰水10分钟可以去辣。夏天在船上做这道最爽！",
                    enTips: "Fish MUST be ultra fresh! Just-caught is best. Don't cure over 40 min or texture gets rubbery. Soak red onion in ice water 10 min to mellow its bite. Making this on the boat in summer is the BEST!"
                ),
                FishRecipe(
                    zhTitle: "红烧比目鱼", enTitle: "Braised Halibut in Soy Sauce",
                    style: .chinese,
                    zhIngredients: "比目鱼排2块(400g厚切)、姜4片、蒜3瓣、大葱1根、料酒2大匙、生抽2大匙、老抽1小匙(上色)、白糖1大匙、醋少许、淀粉水",
                    enIngredients: "2 halibut steaks (400g, thick cut), 4 ginger slices, 3 garlic cloves, 1 leek, 2 tbsp Shaoxing wine, 2 tbsp light soy, 1 tsp dark soy, 1 tbsp sugar, splash vinegar, starch slurry",
                    zhSteps: "1. 鱼排两面拍薄淀粉\n2. 热锅宽油，鱼排煎至两面金黄（每面2分钟）\n3. 捞出鱼，锅留底油\n4. 爆香姜蒜葱段\n5. 淋料酒，加生抽、老抽、白糖、半碗热水\n6. 汤汁烧开后轻轻放入鱼排\n7. 中小火焖煮8-10分钟，中途翻一次面\n8. 大火收汁（汤汁浓稠能挂在鱼上即可）\n9. 出锅前淋几滴醋提鲜",
                    enSteps: "1. Dust fish with thin cornstarch\n2. Pan-fry in generous oil until golden (2 min each side)\n3. Remove fish, keep some oil in wok\n4. Fry ginger, garlic, leek until fragrant\n5. Add wine, soy sauces, sugar, half bowl hot water\n6. Bring to boil, gently slide in fish\n7. Braise 8-10 min on med-low, flip once halfway\n8. Reduce sauce on high (until thick enough to coat fish)\n9. Add a few drops vinegar before plating for brightness",
                    zhTips: "比目鱼肉厚适合红烧不容易散。煎的时候不要频繁翻动！等一面完全定型再翻。老抽只用少量上色，多了会咸。",
                    enTips: "Halibut's thick flesh is ideal for braising - won't fall apart. Don't move fish while frying! Wait until fully set before flipping. Use dark soy sparingly - just for color."
                ),
                FishRecipe(
                    zhTitle: "比目鱼配柠檬黄油和焦化酸豆", enTitle: "Halibut with Lemon Brown Butter & Capers",
                    style: .western,
                    zhIngredients: "比目鱼柳4块(各150g)、黄油60g、酸豆(Capers)2大匙、柠檬1个、欧芹碎、橄榄油、盐和黑胡椒",
                    enIngredients: "4 halibut fillets (150g each), 60g butter, 2 tbsp capers, 1 lemon, chopped parsley, olive oil, salt & pepper",
                    zhSteps: "1. 鱼块两面撒盐胡椒，室温回10分钟\n2. 平底锅大火加橄榄油\n3. 鱼块下锅煎3-4分钟（不要动！）至底部金黄\n4. 翻面煎2-3分钟\n5. 取出鱼放盘子\n6. 同锅转中火放黄油\n7. 黄油融化起泡→变金黄色→出坚果香（约2分钟）\n8. 加入酸豆炸30秒（会溅油注意！）\n9. 关火加柠檬汁和欧芹\n10. 将焦化黄油酱淋在鱼上",
                    enSteps: "1. Season fish with salt & pepper, rest at room temp 10 min\n2. Heat olive oil in pan on high\n3. Sear fish 3-4 min (DON'T move!) until golden underneath\n4. Flip, cook 2-3 min\n5. Remove fish to plate\n6. Same pan on medium, add butter\n7. Butter melts → foams → turns golden → smells nutty (~2 min)\n8. Add capers, fry 30 sec (watch for splatter!)\n9. Kill heat, add lemon juice & parsley\n10. Pour brown butter sauce over fish",
                    zhTips: "焦化黄油（Beurre noisette）是法式经典！关键是从金黄到焦黑只有几秒钟的窗口，闻到坚果香立刻加柠檬汁停止加热。酸豆的咸酸平衡了黄油的浓郁。",
                    enTips: "Brown butter (beurre noisette) is a French classic! The window from golden to burnt is just seconds - add lemon juice the moment you smell nuts to stop the cooking. Capers' salty tang balances the rich butter."
                ),
            ]
        ),
        FishRecipeCategory(
            icon: "🦈",
            zhName: "岩鱼 (Lingcod & Rockfish)",
            enName: "Lingcod & Rockfish",
            recipes: [
                FishRecipe(
                    zhTitle: "清蒸岩鱼", enTitle: "Steamed Lingcod Cantonese Style",
                    style: .chinese,
                    zhIngredients: "Lingcod鱼柳400g、姜丝大量、葱丝、蒸鱼豉油3大匙、油3大匙、料酒1大匙、红椒丝",
                    enIngredients: "400g lingcod fillet, generous ginger shreds, scallion shreds, 3 tbsp steamed fish soy, 3 tbsp oil, 1 tbsp wine, red chili shreds",
                    zhSteps: "1. 鱼块抹姜汁和料酒去腥，腌5分钟\n2. 盘底放几片姜垫底\n3. 鱼肉放上，上面铺姜丝\n4. 水开后大火蒸10-12分钟（Lingcod肉厚需要久一点）\n5. 蒸好倒掉盘中蒸汁\n6. 放葱丝、红椒丝\n7. 烧热油淋上\n8. 浇蒸鱼豉油",
                    enSteps: "1. Rub fish with ginger juice & wine to remove fishiness, rest 5 min\n2. Place ginger slices on plate as base\n3. Place fish, top with ginger shreds\n4. Steam 10-12 min on high after water boils (lingcod is thick, needs longer)\n5. Drain steaming liquid\n6. Top with scallion & chili shreds\n7. Pour smoking hot oil over\n8. Drizzle steamed fish soy",
                    zhTips: "Lingcod肉质比较紧实厚实，蒸的时间比普通鱼长2-3分钟。有些Lingcod肉是蓝绿色的，煮熟后会变白，完全正常可食用！",
                    enTips: "Lingcod flesh is firmer & thicker than most fish - steam 2-3 min longer. Some lingcod have BLUE-GREEN flesh - it turns white when cooked. Completely normal & safe to eat!"
                ),
                FishRecipe(
                    zhTitle: "酸菜鱼 (岩鱼版)", enTitle: "Sichuan Sour Cabbage Fish Stew",
                    style: .chinese,
                    zhIngredients: "Lingcod或Rockfish 500g(切薄片)、酸菜1包(250g)、干辣椒8个、花椒2大匙、姜片5片、蒜4瓣、蛋清1个、淀粉2大匙、料酒1大匙、鸡汤或水4杯",
                    enIngredients: "500g lingcod or rockfish (thinly sliced), 1 pack pickled mustard greens (250g), 8 dried chilies, 2 tbsp Sichuan peppercorns, 5 ginger slices, 4 garlic cloves, 1 egg white, 2 tbsp starch, 1 tbsp wine, 4 cups chicken stock",
                    zhSteps: "1. 鱼片加蛋清、淀粉、料酒、少许盐抓匀上浆\n2. 酸菜切段，挤干水分\n3. 锅中油爆香姜蒜、干辣椒、花椒\n4. 放入酸菜翻炒2分钟出香味\n5. 加鸡汤大火煮开，中火煮10分钟让酸味充分释放\n6. 汤开后放入鱼片，轻轻拨散\n7. 鱼片变白即熟（约1-2分钟）不要煮太久！\n8. 盛入大碗\n9. 另起小锅热油，加花椒和干辣椒炸香\n10. 将热油连辣椒一起浇在鱼上（呲呲作响）",
                    enSteps: "1. Marinate fish slices with egg white, starch, wine, pinch of salt\n2. Cut pickled greens into pieces, squeeze dry\n3. In wok: fry ginger, garlic, dried chilies, Sichuan pepper in oil\n4. Add pickled greens, stir-fry 2 min until fragrant\n5. Add stock, boil then simmer 10 min to release sour flavor\n6. Slide in fish slices, gently separate them\n7. Fish is done when white (~1-2 min) DON'T overcook!\n8. Transfer to large bowl\n9. In small pot, heat oil with peppercorns & dried chilies until fragrant\n10. Pour sizzling oil over the fish (dramatic sizzle!)",
                    zhTips: "上浆（蛋清+淀粉）是鱼片嫩滑的秘诀！酸菜要买正宗的四川酸菜。最后那一勺热油不仅好看，还能激发花椒的麻香。Rockfish和Lingcod的肉紧实不散，比草鱼更适合做这道菜。",
                    enTips: "The velveting (egg white + starch) is the secret to silky fish! Get authentic Sichuan pickled greens. The final hot oil drizzle isn't just for show - it activates the numbing Sichuan pepper aroma. Rockfish & lingcod hold together better than carp for this dish."
                ),
                FishRecipe(
                    zhTitle: "啤酒炸鱼 Tacos", enTitle: "Beer-Battered Fish Tacos",
                    style: .western,
                    zhIngredients: "Lingcod 400g(切条)、面粉1杯、冰啤酒200ml、小玉米饼8个、紫甘蓝丝1杯、牛油果酱、酸奶油、辣酱(Sriracha或Chipotle)、青柠、香菜",
                    enIngredients: "400g lingcod (cut into strips), 1 cup flour, 200ml ice-cold beer, 8 small tortillas, 1 cup shredded purple cabbage, guacamole, sour cream, hot sauce (Sriracha or Chipotle), lime, cilantro",
                    zhSteps: "1. 面糊：面粉+盐+辣椒粉，倒入冰啤酒搅拌（不要过度）\n2. 鱼条拍干撒少许面粉\n3. 裹面糊180°C油炸3-4分钟至金黄酥脆\n4. 小玉米饼干锅加热\n5. 组装Taco：饼→紫甘蓝丝→炸鱼→牛油果酱→酸奶油→辣酱→香菜→挤青柠",
                    enSteps: "1. Batter: flour + salt + chili powder, stir in ice beer (don't overmix)\n2. Pat fish dry, dust lightly with flour\n3. Dip in batter, fry at 180°C for 3-4 min until golden & crispy\n4. Dry-heat tortillas in a pan\n5. Assemble tacos: tortilla → purple cabbage → fried fish → guacamole → sour cream → hot sauce → cilantro → squeeze of lime",
                    zhTips: "温哥华的Lingcod是做fish taco最好的鱼之一！肉质紧实不散，口感像龙虾。配Chipotle酱的烟熏辣味绝配。可以做一个辣酱bar让大家自选。",
                    enTips: "Vancouver lingcod is one of THE best fish for tacos! Firm flesh won't fall apart, texture like lobster. Chipotle sauce's smoky heat is a perfect pairing. Set up a sauce bar for everyone to customize."
                ),
                FishRecipe(
                    zhTitle: "岩鱼汤底火锅", enTitle: "Rockfish Hot Pot",
                    style: .chinese,
                    zhIngredients: "Rockfish整条或鱼骨500g、豆腐1块、各种蔬菜、菌菇、粉丝\n汤底：姜片、蒜、葱段、白胡椒粒、料酒、枸杞\n蘸料：沙茶酱、蒜蓉、葱花、香菜、辣椒油",
                    enIngredients: "1 whole rockfish or 500g fish bones, tofu, assorted vegetables, mushrooms, glass noodles\nBroth: ginger, garlic, scallions, white peppercorns, wine, goji berries\nDip: satay sauce, garlic, scallions, cilantro, chili oil",
                    zhSteps: "1. 鱼骨或整条鱼切大块\n2. 鱼块煎至两面金黄（出奶白汤的关键！）\n3. 加姜蒜葱段爆香\n4. 注入大量热水大火煮开\n5. 加白胡椒粒、枸杞、料酒\n6. 大火煮15分钟至汤变乳白\n7. 转入火锅锅中\n8. 摆好各种配菜\n9. 边涮边吃，先下耐煮的蘑菇和根茎类\n10. 鱼片最后下，变色即捞",
                    enSteps: "1. Cut fish/bones into large pieces\n2. Pan-fry until golden (KEY for milky white broth!)\n3. Fry ginger, garlic, scallions until fragrant\n4. Add lots of HOT water, bring to rolling boil\n5. Add white peppercorns, goji berries, wine\n6. Boil hard 15 min until broth turns milky white\n7. Transfer to hot pot vessel\n8. Arrange all side ingredients\n9. Cook as you eat - mushrooms & root veggies first\n10. Fish slices go in last - remove when color changes",
                    zhTips: "这是冬天最治愈的做法！鱼骨熬出来的汤比整条鱼还鲜。火锅结束后的汤底下面条或泡饭是精华。BC的Rockfish肉质适中不柴。",
                    enTips: "The most comforting winter dish! Fish bone broth is even more flavorful than whole fish. End the hot pot with noodles or rice in the broth - that's the best part. BC rockfish has perfect texture - not dry."
                ),
            ]
        ),
        FishRecipeCategory(
            icon: "🐡",
            zhName: "石斑鱼 (Grouper)",
            enName: "Grouper",
            recipes: [
                FishRecipe(
                    zhTitle: "清蒸石斑", enTitle: "Steamed Grouper",
                    style: .chinese,
                    zhIngredients: "石斑鱼1条(约1-1.5磅)、姜丝、葱丝、蒸鱼豉油3大匙、油3大匙、料酒、盐少许",
                    enIngredients: "1 grouper (~1-1.5 lbs), ginger shreds, scallion shreds, 3 tbsp steamed fish soy, 3 tbsp oil, wine, pinch of salt",
                    zhSteps: "1. 鱼清理干净，身上划3刀方便入味和受热均匀\n2. 抹少许盐和料酒\n3. 姜丝铺鱼身上下（下面也要垫！防止粘盘）\n4. 水烧开后放入，大火蒸8-10分钟（每500g约8分钟）\n5. 关火不开盖焖2分钟（余热让肉更嫩）\n6. 倒掉蒸汁，放新鲜葱姜丝\n7. 淋滚油激出葱香\n8. 浇蒸鱼豉油",
                    enSteps: "1. Clean fish, score 3 cuts for even cooking\n2. Rub with salt & wine\n3. Ginger shreds on top AND underneath (prevents sticking)\n4. Steam 8-10 min on high after water boils (~8 min per 500g)\n5. Turn off heat, leave lid on 2 min (residual heat tenderizes)\n6. Drain liquid, add fresh scallion & ginger shreds\n7. Pour smoking hot oil to release scallion aroma\n8. Drizzle steamed fish soy sauce",
                    zhTips: "广东人吃鱼最高境界就是清蒸！好鱼不需要复杂调味。李锦记蒸鱼豉油是最经典搭配。关火焖2分钟这个小窍门很多人不知道。",
                    enTips: "Cantonese believe steaming is the ultimate way to honor fresh fish! Good fish needs simple seasoning. Lee Kum Kee steamed fish soy is the classic. The 2-min resting trick is a pro move many don't know."
                ),
                FishRecipe(
                    zhTitle: "石斑鱼煲", enTitle: "Grouper Clay Pot",
                    style: .chinese,
                    zhIngredients: "石斑鱼块400g、嫩豆腐1块、粉丝1把、姜片、蒜片、葱段、高汤2杯、酱油2大匙、蚝油1大匙、白胡椒粉、香菜",
                    enIngredients: "400g grouper pieces, 1 block soft tofu, 1 bundle glass noodles, ginger, garlic, scallions, 2 cups stock, 2 tbsp soy sauce, 1 tbsp oyster sauce, white pepper, cilantro",
                    zhSteps: "1. 鱼块拍淀粉煎至两面金黄\n2. 砂锅（或厚底锅）底部铺粉丝和豆腐块\n3. 放入煎好的鱼块\n4. 加高汤、酱油、蚝油\n5. 姜片蒜片葱段放入\n6. 大火煮开转中小火焖15分钟\n7. 撒白胡椒粉和香菜\n8. 连砂锅上桌（保温效果好）",
                    enSteps: "1. Dust fish with starch, pan-fry until golden\n2. Line clay pot with glass noodles & tofu cubes\n3. Place fried fish on top\n4. Add stock, soy sauce, oyster sauce\n5. Add ginger, garlic, scallion pieces\n6. Bring to boil, then braise 15 min on med-low\n7. Sprinkle white pepper & cilantro\n8. Serve in the pot (keeps it hot)",
                    zhTips: "砂锅的蓄热性很好，上桌后还能继续沸腾。粉丝会吸收所有鱼汤精华，是这道菜的隐藏主角。",
                    enTips: "Clay pots retain heat beautifully - food keeps bubbling at the table. Glass noodles absorb all the fish broth flavor and are the hidden star of this dish."
                ),
                FishRecipe(
                    zhTitle: "烤石斑鱼配地中海风味", enTitle: "Mediterranean Baked Grouper",
                    style: .western,
                    zhIngredients: "石斑鱼柳4块、小番茄1杯(切半)、卡拉马塔橄榄1/3杯、酸豆2大匙、蒜3瓣(切片)、白葡萄酒60ml、橄榄油、新鲜百里香、盐和黑胡椒",
                    enIngredients: "4 grouper fillets, 1 cup cherry tomatoes (halved), 1/3 cup Kalamata olives, 2 tbsp capers, 3 garlic cloves (sliced), 60ml white wine, olive oil, fresh thyme, salt & pepper",
                    zhSteps: "1. 烤箱预热200°C\n2. 烤盘中放小番茄、橄榄、酸豆、蒜片\n3. 淋橄榄油拌匀，放入烤箱先烤10分钟\n4. 鱼柳两面抹盐胡椒和橄榄油\n5. 取出烤盘，把鱼放在烤好的蔬菜上\n6. 淋白葡萄酒，放百里香枝\n7. 继续烤12-15分钟至鱼肉刚好熟透\n8. 配烤面包或蒸粗麦粉(Couscous)",
                    enSteps: "1. Preheat oven to 200°C\n2. In baking dish: cherry tomatoes, olives, capers, garlic\n3. Toss with olive oil, roast 10 min first\n4. Season fish with salt, pepper, olive oil\n5. Remove dish, place fish on roasted vegetables\n6. Drizzle white wine, add thyme sprigs\n7. Bake 12-15 min until fish just flakes\n8. Serve with crusty bread or couscous",
                    zhTips: "先烤蔬菜再放鱼能让蔬菜充分焦糖化出甜味。鱼肉用叉子轻碰能分层即可，过头会变干。这道菜配白葡萄酒最完美。",
                    enTips: "Roasting veggies first caramelizes them for sweetness. Fish is done when it flakes with gentle fork pressure - overdone becomes dry. Perfect pairing with a crisp white wine."
                ),
            ]
        ),
    ]
    
    var body: some View {
        List {
            ForEach(fishCategories) { category in
                Section {
                    NavigationLink {
                        RecipeDetailView(category: category)
                    } label: {
                        HStack {
                            Text(category.icon).font(.title2)
                            Text(l10n.language == .chinese ? category.zhName : category.enName)
                                .font(.body)
                            Spacer()
                            Text("\(category.recipes.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .navigationTitle(l10n.recipesTitle)
    }
}

// MARK: - Recipe Detail
struct RecipeDetailView: View {
    @EnvironmentObject var l10n: L10n
    let category: FishRecipeCategory
    
    var body: some View {
        List {
            ForEach(category.recipes) { recipe in
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(recipe.style.rawValue)
                            Text(l10n.language == .chinese ? recipe.zhTitle : recipe.enTitle)
                                .font(.headline)
                        }
                        
                        let ingredients = l10n.language == .chinese ? recipe.zhIngredients : recipe.enIngredients
                        if !ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(l10n.t("📋 食材", "📋 Ingredients"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(ingredients)
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(l10n.t("👨‍🍳 步骤", "👨‍🍳 Steps"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(l10n.language == .chinese ? recipe.zhSteps : recipe.enSteps)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineSpacing(4)
                        }
                        
                        let tips = l10n.language == .chinese ? recipe.zhTips : recipe.enTips
                        if !tips.isEmpty {
                            Divider()
                            VStack(alignment: .leading, spacing: 4) {
                                Text(l10n.t("💡 小贴士", "💡 Tips"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(tips)
                                    .font(.callout)
                                    .foregroundColor(.orange)
                                    .lineSpacing(3)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("\(category.icon) \(l10n.language == .chinese ? category.zhName : category.enName)")
    }
}

// MARK: - Recipe Data Models
struct FishRecipeCategory: Identifiable {
    let id = UUID()
    let icon: String
    let zhName: String
    let enName: String
    let recipes: [FishRecipe]
}

struct FishRecipe: Identifiable {
    let id = UUID()
    let zhTitle: String
    let enTitle: String
    let style: RecipeStyle
    let zhIngredients: String
    let enIngredients: String
    let zhSteps: String
    let enSteps: String
    let zhTips: String
    let enTips: String
    
    init(zhTitle: String, enTitle: String, style: RecipeStyle = .chinese, zhIngredients: String = "", enIngredients: String = "", zhSteps: String, enSteps: String, zhTips: String = "", enTips: String = "") {
        self.zhTitle = zhTitle
        self.enTitle = enTitle
        self.style = style
        self.zhIngredients = zhIngredients
        self.enIngredients = enIngredients
        self.zhSteps = zhSteps
        self.enSteps = enSteps
        self.zhTips = zhTips
        self.enTips = enTips
    }
}

enum RecipeStyle: String {
    case chinese = "🇨🇳"
    case western = "🇨🇦"
    case japanese = "🇯🇵"
    case fusion = "🌏"
}

// MARK: - Profile View with Login/Logout + Language Switcher
struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var l10n: L10n
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar card
                    if let user = appState.currentUser {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(colors: [AppTheme.Colors.oceanSurface, AppTheme.Colors.oceanLight], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 72, height: 72)
                                    .overlay(
                                        Circle()
                                            .stroke(AppTheme.Colors.gold.opacity(0.3), lineWidth: 1.5)
                                    )
                                Image(systemName: "person.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppTheme.Colors.goldLight)
                            }
                            
                            Text(user.displayName)
                                .font(.title3.weight(.bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(AppTheme.Colors.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                    
                    // My Info section
                    InfoSectionView(title: l10n.t("我的信息", "My Info"), icon: "person.text.rectangle") {
                        InfoRowLink(title: l10n.t("我的钓点", "My Spots"), icon: "mappin.circle.fill", color: AppTheme.Colors.accent) {
                            MySpotsView()
                        }
                        InfoRowLink(title: l10n.myBoat, icon: "sailboat.fill", color: AppTheme.Colors.gold) {
                            MyBoatView()
                        }
                        InfoRowLink(title: l10n.myLicense, icon: "doc.text.fill", color: AppTheme.Colors.success) {
                            MyLicenseView()
                        }
                        InfoRowLink(title: l10n.myRecords, icon: "list.clipboard.fill", color: .purple) {
                            FishingLogView()
                        }
                    }
                    
                    // Settings section
                    InfoSectionView(title: l10n.settings, icon: "gearshape") {
                        // Captain toggle
                        HStack(spacing: 12) {
                            Image(systemName: "helm")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors.gold)
                                .frame(width: 28)
                            Text(l10n.t("我是船长", "I'm a Captain"))
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Toggle("", isOn: $appState.isCaptain)
                                .tint(AppTheme.Colors.gold)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppTheme.Colors.oceanLight.opacity(0.15))
                        
                        // Language
                        HStack(spacing: 12) {
                            Image(systemName: "globe")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors.accent)
                                .frame(width: 28)
                            Text(l10n.languageLabel)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Spacer()
                            Picker("", selection: $l10n.language) {
                                ForEach(L10n.Language.allCases, id: \.self) { lang in
                                    Text(lang.displayName).tag(lang)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 140)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(AppTheme.Colors.oceanLight.opacity(0.15))
                        
                        InfoRowLink(title: l10n.t("AI 助手设置", "AI Assistant Settings"), icon: "brain.fill", color: .purple) {
                            AISettingsView()
                        }
                        InfoRowLink(title: l10n.about, icon: "info.circle.fill", color: AppTheme.Colors.textSecondary) {
                            AboutView()
                        }
                    }
                    
                    // Logout
                    Button(action: { appState.logout() }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text(l10n.logoutButton)
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.red.opacity(0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                .fill(Color.red.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                                        .stroke(Color.red.opacity(0.15), lineWidth: 0.5)
                                )
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(AppTheme.Colors.heroGradient.ignoresSafeArea())
            .navigationTitle(l10n.profileTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Colors.deepOcean.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - My Boat View
struct MyBoatView: View {
    @EnvironmentObject var l10n: L10n
    @AppStorage("boat_name") private var boatName = ""
    @AppStorage("boat_length") private var boatLength = ""
    @AppStorage("boat_engine") private var boatEngine = ""
    @AppStorage("boat_fuel_capacity") private var fuelCapacity = ""
    
    var body: some View {
        Form {
            Section(l10n.t("船只信息", "Boat Info")) {
                HStack {
                    Text(l10n.t("船名", "Name"))
                    Spacer()
                    TextField(l10n.t("输入船名", "Enter name"), text: $boatName)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(l10n.t("长度(ft)", "Length(ft)"))
                    Spacer()
                    TextField("e.g. 22", text: $boatLength)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
                HStack {
                    Text(l10n.t("引擎", "Engine"))
                    Spacer()
                    TextField("e.g. 150HP Yamaha", text: $boatEngine)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text(l10n.t("油箱(L)", "Fuel(L)"))
                    Spacer()
                    TextField("e.g. 200", text: $fuelCapacity)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
            }
        }
        .navigationTitle(l10n.myBoat)
    }
}

// MARK: - My License View
struct MyLicenseView: View {
    @EnvironmentObject var l10n: L10n
    @StateObject private var viewModel = LicenseViewModel()
    
    var body: some View {
        List {
            // Active licenses
            Section(l10n.t("我的鱼证", "My Licenses")) {
                if viewModel.licenses.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text(l10n.t("暂无鱼证信息", "No licenses yet"))
                            .foregroundColor(.secondary)
                        Text(l10n.t("点击下方添加你的鱼证", "Tap below to add your license"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(viewModel.licenses) { license in
                        LicenseCardView(license: license)
                    }
                    .onDelete { indexSet in
                        viewModel.licenses.remove(atOffsets: indexSet)
                        viewModel.save()
                    }
                }
            }
            
            // Add license
            Section {
                Button(action: { viewModel.showAddSheet = true }) {
                    Label(l10n.t("添加鱼证", "Add License"), systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            // Info section
            Section(l10n.t("鱼证须知", "License Info")) {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(icon: "1.circle.fill", text: l10n.t("Tidal Waters Sport Fishing Licence - 海水钓鱼必须", "Tidal Waters Sport Fishing Licence - Required for saltwater"))
                    InfoRow(icon: "2.circle.fill", text: l10n.t("Salmon Conservation Stamp - 钓三文鱼额外需要", "Salmon Conservation Stamp - Required for salmon"))
                    InfoRow(icon: "3.circle.fill", text: l10n.t("Halibut Tag - 钓比目鱼需要(免费)", "Halibut Tag - Required for halibut (free)"))
                }
                .padding(.vertical, 4)
                
                Link(l10n.t("🔗 在线购买鱼证 (DFO)", "🔗 Buy License Online (DFO)"),
                     destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/licence-permis/application-eng.html")!)
            }
        }
        .navigationTitle(l10n.myLicense)
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddLicenseSheet(viewModel: viewModel)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
    }
}

struct LicenseCardView: View {
    let license: FishingLicense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(license.type.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                if license.isExpired {
                    Text("已过期")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(4)
                } else {
                    Text("有效")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            HStack {
                Text("# \(license.number)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(license.startDate, format: .dateTime.month().day().year()) - \(license.endDate, format: .dateTime.month().day().year())")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddLicenseSheet: View {
    @ObservedObject var viewModel: LicenseViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: LicenseType = .tidalWaters
    @State private var number = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("类型", selection: $selectedType) {
                    ForEach(LicenseType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                TextField("证件号码", text: $number)
                DatePicker("起始日期", selection: $startDate, displayedComponents: .date)
                DatePicker("到期日期", selection: $endDate, displayedComponents: .date)
            }
            .navigationTitle("添加鱼证")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let license = FishingLicense(
                            id: UUID().uuidString,
                            type: selectedType,
                            number: number.isEmpty ? "N/A" : number,
                            startDate: startDate,
                            endDate: endDate
                        )
                        viewModel.licenses.append(license)
                        viewModel.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Fishing Log View
struct FishingLogView: View {
    @EnvironmentObject var l10n: L10n
    @StateObject private var viewModel = FishingLogViewModel()
    
    var body: some View {
        List {
            if viewModel.records.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "fish")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text(l10n.t("暂无钓鱼记录", "No fishing records yet"))
                            .foregroundColor(.secondary)
                        Text(l10n.t("每次出海后记录你的收获吧！", "Record your catch after each trip!"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            } else {
                // Stats summary
                Section(l10n.t("统计", "Stats")) {
                    HStack {
                        StatBox(title: l10n.t("出海次数", "Trips"), value: "\(viewModel.records.count)", icon: "sailboat", color: .blue)
                        StatBox(title: l10n.t("总鱼获", "Total Catch"), value: "\(viewModel.totalCatch)", icon: "fish", color: .green)
                        StatBox(title: l10n.t("最大鱼", "Biggest"), value: viewModel.biggestFish, icon: "trophy", color: .orange)
                    }
                }
                
                // Records list
                Section(l10n.t("记录", "Records")) {
                    ForEach(viewModel.records) { record in
                        FishingRecordRow(record: record)
                    }
                    .onDelete { indexSet in
                        viewModel.records.remove(atOffsets: indexSet)
                        viewModel.save()
                    }
                }
            }
            
            // Add record button
            Section {
                Button(action: { viewModel.showAddSheet = true }) {
                    Label(l10n.t("添加钓鱼记录", "Add Fishing Record"), systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            // DFO iRec Reporting
            Section(l10n.t("⚠️ 强制上报提醒", "⚠️ Mandatory Reporting")) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(l10n.t("以下鱼种必须在当天上报 DFO:", "These species MUST be reported to DFO same day:"))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ReportingRow(species: "Halibut", note: l10n.t("保留或释放都必须上报", "Must report kept AND released"))
                        ReportingRow(species: "Chinook Salmon", note: l10n.t("标记鱼(缺脂鳍)必须上报", "Marked fish (missing adipose) must report"))
                        ReportingRow(species: "Lingcod", note: l10n.t("部分区域需上报", "Required in some areas"))
                    }
                }
                .padding(.vertical, 4)
                
                Link(destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/irec-eng.html")!) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text(l10n.t("前往 iRec 上报系统", "Go to iRec Reporting System"))
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                
                Link(destination: URL(string: "https://www.pac.dfo-mpo.gc.ca/fm-gp/rec/licence-permis/application-eng.html")!) {
                    HStack {
                        Image(systemName: "doc.text")
                        Text(l10n.t("查看/续期鱼证 (NLS)", "View/Renew License (NLS)"))
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle(l10n.myRecords)
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddFishingRecordSheet(viewModel: viewModel)
        }
    }
}

struct ReportingRow: View {
    let species: String
    let note: String
    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 1) {
                Text(species)
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(note)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FishingRecordRow: View {
    let record: FishingRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.date, format: .dateTime.month().day().year())
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(record.location)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            HStack {
                ForEach(record.catches, id: \.self) { c in
                    Text(c)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            if !record.notes.isEmpty {
                Text(record.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddFishingRecordSheet: View {
    @ObservedObject var viewModel: FishingLogViewModel
    @Environment(\.dismiss) var dismiss
    @State private var date = Date()
    @State private var location = ""
    @State private var catches = ""
    @State private var notes = ""
    
    let locationOptions = ["Bowen Island", "Point Atkinson", "Howe Sound", "Indian Arm", "Thrasher Rock", "Active Pass", "Sand Heads"]
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker("日期", selection: $date, displayedComponents: .date)
                Picker("地点", selection: $location) {
                    Text("选择地点").tag("")
                    ForEach(locationOptions, id: \.self) { loc in
                        Text(loc).tag(loc)
                    }
                }
                TextField("鱼获 (逗号分隔，如: Chinook x2, Coho x1)", text: $catches)
                TextField("备注 (天气、用饵等)", text: $notes)
            }
            .navigationTitle("添加记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let catchList = catches.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        let record = FishingRecord(
                            id: UUID().uuidString,
                            date: date,
                            location: location.isEmpty ? "Unknown" : location,
                            catches: catchList,
                            notes: notes
                        )
                        viewModel.records.insert(record, at: 0)
                        viewModel.save()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Data Models

enum LicenseType: String, Codable, CaseIterable {
    case tidalWaters = "tidal_waters"
    case salmonStamp = "salmon_stamp"
    case halibutTag = "halibut_tag"
    case crabLicense = "crab_license"
    case prawnLicense = "prawn_license"
    
    var displayName: String {
        switch self {
        case .tidalWaters: return "Tidal Waters Sport Fishing Licence"
        case .salmonStamp: return "Salmon Conservation Stamp"
        case .halibutTag: return "Halibut Tag"
        case .crabLicense: return "Crab License"
        case .prawnLicense: return "Prawn by Trap License"
        }
    }
}

struct FishingLicense: Identifiable, Codable {
    let id: String
    let type: LicenseType
    let number: String
    let startDate: Date
    let endDate: Date
    
    var isExpired: Bool {
        endDate < Date()
    }
}

struct FishingRecord: Identifiable, Codable {
    let id: String
    let date: Date
    let location: String
    let catches: [String]
    let notes: String
}

// MARK: - View Models

class LicenseViewModel: ObservableObject {
    @Published var licenses: [FishingLicense] = []
    @Published var showAddSheet = false
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: "my_licenses"),
           let decoded = try? JSONDecoder().decode([FishingLicense].self, from: data) {
            licenses = decoded
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(licenses) {
            UserDefaults.standard.set(data, forKey: "my_licenses")
        }
    }
}

class FishingLogViewModel: ObservableObject {
    @Published var records: [FishingRecord] = []
    @Published var showAddSheet = false
    
    var totalCatch: Int {
        records.reduce(0) { $0 + $1.catches.count }
    }
    
    var biggestFish: String {
        if records.isEmpty { return "-" }
        // Just return first catch of first record as placeholder
        return records.first?.catches.first ?? "-"
    }
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: "fishing_records"),
           let decoded = try? JSONDecoder().decode([FishingRecord].self, from: data) {
            records = decoded
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: "fishing_records")
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @EnvironmentObject var l10n: L10n
    
    var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "fish.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text(l10n.t("钓鱼助手", "Fishing Assistant"))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(l10n.t("海尚海钓 Top Vancouver Fishing Charter", "Top Vancouver Fishing Charter"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("v1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            
            Section(l10n.t("关于我们", "About Us")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(l10n.t(
                        "海尚海钓 (Top Vancouver Fishing Charter) 是温哥华本地专业海钓团队。我们的船长拥有多年Georgia Strait海钓经验，提供中英文双语服务。\n\n无论你是新手还是老手，我们都能为你提供最专业的海钓体验。全套渔具装备提供，你只需要人来就行！",
                        "Top Vancouver Fishing Charter is a professional local fishing team in Vancouver. Our captains have years of Georgia Strait fishing experience and offer bilingual service in Chinese and English.\n\nWhether you're a beginner or experienced angler, we provide the most professional fishing experience. All gear and equipment provided - just bring yourself!"
                    ))
                    .font(.callout)
                    .lineSpacing(4)
                }
                .padding(.vertical, 4)
            }
            
            Section(l10n.t("我们的服务", "Our Services")) {
                Label(l10n.t("专业包船海钓", "Professional Fishing Charters"), systemImage: "ferry")
                Label(l10n.t("华人船长 中英文服务", "Bilingual Captains (CN/EN)"), systemImage: "person.fill")
                Label(l10n.t("全套渔具装备提供", "All Gear & Equipment Provided"), systemImage: "wrench.and.screwdriver")
                Label(l10n.t("新手教学 手把手指导", "Beginner-Friendly Instruction"), systemImage: "graduationcap")
                Label(l10n.t("公司团建 朋友聚会", "Corporate Events & Group Outings"), systemImage: "person.3.fill")
                Label(l10n.t("三文鱼 比目鱼 螃蟹 斑点虾", "Salmon, Halibut, Crab, Spot Prawn"), systemImage: "fish")
            }
            
            Section(l10n.t("功能特色", "App Features")) {
                Label(l10n.t("7种海况叠加模式", "7 Marine Overlay Modes"), systemImage: "map")
                Label(l10n.t("4种天气模型对比", "4 Weather Model Comparison"), systemImage: "cloud.sun")
                Label(l10n.t("AI 钓鱼助手", "AI Fishing Assistant"), systemImage: "brain")
                Label(l10n.t("航线规划与油耗计算", "Route Planning & Fuel Calc"), systemImage: "location.fill")
                Label(l10n.t("DFO 潮汐与法规", "DFO Tides & Regulations"), systemImage: "water.waves")
                Label(l10n.t("中英文双语界面", "Bilingual Interface (CN/EN)"), systemImage: "globe")
            }
            
            Section(l10n.t("数据来源", "Data Sources")) {
                VStack(alignment: .leading, spacing: 6) {
                    DataSourceRow(name: "Open-Meteo", desc: l10n.t("天气与海洋预报数据", "Weather & Marine Forecast Data"))
                    DataSourceRow(name: "DFO IWLS", desc: l10n.t("加拿大官方潮汐数据", "Official Canadian Tide Data"))
                    DataSourceRow(name: "Apple MapKit", desc: l10n.t("地图与位置服务", "Maps & Location Services"))
                    DataSourceRow(name: "Groq AI", desc: l10n.t("AI 智能对话引擎", "AI Chat Engine"))
                }
                .padding(.vertical, 4)
            }
            
            Section(l10n.t("法律信息", "Legal")) {
                Link(destination: URL(string: "https://topvancouverfishing.com/privacy")!) {
                    Label(l10n.t("隐私政策", "Privacy Policy"), systemImage: "lock.shield")
                }
                Link(destination: URL(string: "https://topvancouverfishing.com/terms")!) {
                    Label(l10n.t("使用条款", "Terms of Use"), systemImage: "doc.text")
                }
            }
            
            Section {
                VStack(spacing: 4) {
                    Text("© 2026 Top Vancouver Fishing Charter Inc.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("Vancouver, British Columbia, Canada")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(l10n.about)
    }
}

struct DataSourceRow: View {
    let name: String
    let desc: String
    var body: some View {
        HStack {
            Text(name)
                .font(.callout)
                .fontWeight(.medium)
            Spacer()
            Text(desc)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - AI Settings View
struct AISettingsView: View {
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "ai_api_key") ?? ""
    @State private var apiBase: String = UserDefaults.standard.string(forKey: "ai_api_base") ?? ""
    @State private var aiModel: String = UserDefaults.standard.string(forKey: "ai_model") ?? ""
    @State private var showKey = false
    @State private var testResult: String = ""
    @State private var isTesting = false
    @EnvironmentObject var l10n: L10n
    
    private var isUsingDefault: Bool {
        apiKey.isEmpty && apiBase.isEmpty && aiModel.isEmpty
    }
    
    var body: some View {
        Form {
            // Status section
            Section {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(l10n.t("AI 助手已就绪", "AI Assistant Ready"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(l10n.t("默认使用 Groq (Llama 3.1) 免费服务", "Using Groq (Llama 3.1) free service by default"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(header: Text(l10n.t("自定义配置 (可选)", "Custom Configuration (Optional)")),
                    footer: Text(l10n.t("留空则使用默认AI服务。如需使用其他服务商可在此修改。", "Leave empty to use default AI service. Modify here to use other providers."))) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("API Key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        if showKey {
                            TextField(l10n.t("留空使用默认", "Leave empty for default"), text: $apiKey)
                                .font(.system(.body, design: .monospaced))
                        } else {
                            SecureField(l10n.t("留空使用默认", "Leave empty for default"), text: $apiKey)
                        }
                        Button(action: { showKey.toggle() }) {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(l10n.t("接口地址", "API Base URL"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("https://api.openai.com/v1", text: $apiBase)
                        .font(.system(.body, design: .monospaced))
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(l10n.t("模型", "Model"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("gpt-3.5-turbo", text: $aiModel)
                        .font(.system(.body, design: .monospaced))
                        .autocapitalization(.none)
                }
            }
            
            Section {
                Button(action: saveSettings) {
                    HStack {
                        Spacer()
                        Text(l10n.t("保存设置", "Save Settings"))
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                
                Button(action: testConnection) {
                    HStack {
                        Spacer()
                        if isTesting {
                            ProgressView()
                                .padding(.trailing, 4)
                        }
                        Text(l10n.t("测试连接", "Test Connection"))
                        Spacer()
                    }
                }
                .disabled(isTesting)
            }
            
            if !testResult.isEmpty {
                Section(l10n.t("测试结果", "Test Result")) {
                    Text(testResult)
                        .font(.caption)
                        .foregroundColor(testResult.contains("✅") ? .green : .red)
                }
            }
            
            // Reset to default
            if !isUsingDefault {
                Section {
                    Button(action: resetToDefault) {
                        HStack {
                            Spacer()
                            Text(l10n.t("恢复默认设置", "Reset to Default"))
                                .foregroundColor(.orange)
                            Spacer()
                        }
                    }
                }
            }
            
            Section(header: Text(l10n.t("其他服务商 (高级)", "Other Providers (Advanced)"))) {
                VStack(alignment: .leading, spacing: 8) {
                    ProviderRow(name: "OpenAI", model: "gpt-4o-mini", url: "https://platform.openai.com")
                    ProviderRow(name: "DeepSeek", model: "deepseek-chat", url: "https://platform.deepseek.com")
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(l10n.t("AI 设置", "AI Settings"))
    }
    
    private func saveSettings() {
        if apiKey.isEmpty {
            UserDefaults.standard.removeObject(forKey: "ai_api_key")
        } else {
            UserDefaults.standard.set(apiKey, forKey: "ai_api_key")
        }
        if apiBase.isEmpty {
            UserDefaults.standard.removeObject(forKey: "ai_api_base")
        } else {
            UserDefaults.standard.set(apiBase, forKey: "ai_api_base")
        }
        if aiModel.isEmpty {
            UserDefaults.standard.removeObject(forKey: "ai_model")
        } else {
            UserDefaults.standard.set(aiModel, forKey: "ai_model")
        }
        testResult = "✅ " + l10n.t("设置已保存", "Settings saved")
    }
    
    private func resetToDefault() {
        UserDefaults.standard.removeObject(forKey: "ai_api_key")
        UserDefaults.standard.removeObject(forKey: "ai_api_base")
        UserDefaults.standard.removeObject(forKey: "ai_model")
        apiKey = ""
        apiBase = ""
        aiModel = ""
        testResult = "✅ " + l10n.t("已恢复默认设置", "Reset to default")
    }
    
    private func testConnection() {
        saveSettings()
        isTesting = true
        testResult = ""
        
        Task {
            let service = APIService()
            let response = try? await service.chat(message: "你好，请用一句话介绍你自己", history: [])
            await MainActor.run {
                isTesting = false
                if let resp = response, !resp.contains("你可以问我") {
                    testResult = "✅ " + l10n.t("连接成功！回复: ", "Connected! Reply: ") + String(resp.prefix(100))
                } else {
                    testResult = "❌ " + l10n.t("AI连接失败，使用离线模式", "AI connection failed, using offline mode")
                }
            }
        }
    }
}

struct ProviderRow: View {
    let name: String
    let model: String
    let url: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(model)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(url)
                .font(.caption2)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - My Spots View
struct MySpotsView: View {
    @EnvironmentObject var l10n: L10n
    @StateObject private var viewModel = MySpotsViewModel()
    
    var body: some View {
        List {
            if viewModel.spots.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "mappin.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text(l10n.t("暂无保存的钓点", "No saved spots yet"))
                            .foregroundColor(.secondary)
                        Text(l10n.t("保存你发现的好钓点，记录鱼种和心得", "Save your favorite spots with species and notes"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            } else {
                // Group by species type
                let fishSpots = viewModel.spots.filter { $0.categories.contains(.fish) }
                let crabSpots = viewModel.spots.filter { $0.categories.contains(.crab) }
                let prawnSpots = viewModel.spots.filter { $0.categories.contains(.prawn) }
                let otherSpots = viewModel.spots.filter { $0.categories.allSatisfy { c in c != .fish && c != .crab && c != .prawn } }
                
                if !fishSpots.isEmpty {
                    Section(l10n.t("🐟 鱼类钓点", "🐟 Fish Spots")) {
                        ForEach(fishSpots) { spot in
                            MySpotRow(spot: spot)
                        }
                        .onDelete { indexSet in
                            let ids = indexSet.map { fishSpots[$0].id }
                            viewModel.spots.removeAll { ids.contains($0.id) }
                            viewModel.save()
                        }
                    }
                }
                
                if !crabSpots.isEmpty {
                    Section(l10n.t("🦀 螃蟹钓点", "🦀 Crab Spots")) {
                        ForEach(crabSpots) { spot in
                            MySpotRow(spot: spot)
                        }
                        .onDelete { indexSet in
                            let ids = indexSet.map { crabSpots[$0].id }
                            viewModel.spots.removeAll { ids.contains($0.id) }
                            viewModel.save()
                        }
                    }
                }
                
                if !prawnSpots.isEmpty {
                    Section(l10n.t("🦐 虾类钓点", "🦐 Prawn Spots")) {
                        ForEach(prawnSpots) { spot in
                            MySpotRow(spot: spot)
                        }
                        .onDelete { indexSet in
                            let ids = indexSet.map { prawnSpots[$0].id }
                            viewModel.spots.removeAll { ids.contains($0.id) }
                            viewModel.save()
                        }
                    }
                }
                
                if !otherSpots.isEmpty {
                    Section(l10n.t("📍 其他钓点", "📍 Other Spots")) {
                        ForEach(otherSpots) { spot in
                            MySpotRow(spot: spot)
                        }
                        .onDelete { indexSet in
                            let ids = indexSet.map { otherSpots[$0].id }
                            viewModel.spots.removeAll { ids.contains($0.id) }
                            viewModel.save()
                        }
                    }
                }
            }
            
            Section {
                Button(action: { viewModel.showAddSheet = true }) {
                    Label(l10n.t("添加钓点", "Add Spot"), systemImage: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle(l10n.t("我的钓点", "My Spots"))
        .sheet(isPresented: $viewModel.showAddSheet) {
            AddMySpotSheet(viewModel: viewModel)
        }
    }
}

struct MySpotRow: View {
    let spot: MyFishingSpot
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(spot.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(spot.categories.map { $0.emoji }.joined(separator: " "))
                    .font(.caption)
            }
            
            HStack {
                Image(systemName: "location")
                    .font(.system(size: 9))
                Text(String(format: "%.4f, %.4f", spot.latitude, spot.longitude))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                if !spot.depth.isEmpty {
                    Text("· \(spot.depth)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if !spot.species.isEmpty {
                HStack(spacing: 4) {
                    ForEach(spot.species, id: \.self) { sp in
                        Text(sp)
                            .font(.system(size: 10))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            
            if !spot.notes.isEmpty {
                Text(spot.notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            if let date = spot.lastVisited {
                Text("最近: \(date, format: .dateTime.month().day().year())")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddMySpotSheet: View {
    @ObservedObject var viewModel: MySpotsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var depth = ""
    @State private var species = ""
    @State private var notes = ""
    @State private var selectedCategories: Set<SpotCategory> = [.fish]
    @State private var useCurrentLocation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("钓点名称 (如: Bowen东南角)", text: $name)
                    
                    HStack {
                        TextField("纬度 (如: 49.3833)", text: $latitude)
                            .keyboardType(.decimalPad)
                        TextField("经度 (如: -123.3333)", text: $longitude)
                            .keyboardType(.numbersAndPunctuation)
                    }
                    
                    TextField("深度 (如: 60-100ft)", text: $depth)
                }
                
                Section(header: Text("分类")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(SpotCategory.allCases, id: \.self) { cat in
                            Button(action: {
                                if selectedCategories.contains(cat) {
                                    selectedCategories.remove(cat)
                                } else {
                                    selectedCategories.insert(cat)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Text(cat.emoji)
                                    Text(cat.label)
                                        .font(.caption)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedCategories.contains(cat) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedCategories.contains(cat) ? Color.blue : Color.clear, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Section(header: Text("鱼种")) {
                    TextField("具体鱼种 (逗号分隔，如: Chinook, Coho, Lingcod)", text: $species)
                }
                
                Section(header: Text("备注")) {
                    TextField("心得、用饵、时间段等", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("添加钓点")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let speciesList = species.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        let spot = MyFishingSpot(
                            id: UUID().uuidString,
                            name: name.isEmpty ? "未命名钓点" : name,
                            latitude: Double(latitude) ?? 49.25,
                            longitude: Double(longitude) ?? -123.30,
                            depth: depth,
                            categories: Array(selectedCategories),
                            species: speciesList,
                            notes: notes,
                            lastVisited: Date(),
                            rating: 0
                        )
                        viewModel.spots.append(spot)
                        viewModel.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty && latitude.isEmpty)
                }
            }
        }
    }
}

// MARK: - My Spots Data Model

enum SpotCategory: String, Codable, CaseIterable {
    case fish = "fish"
    case crab = "crab"
    case prawn = "prawn"
    case clam = "clam"
    case squid = "squid"
    case other = "other"
    
    var emoji: String {
        switch self {
        case .fish: return "🐟"
        case .crab: return "🦀"
        case .prawn: return "🦐"
        case .clam: return "🐚"
        case .squid: return "🦑"
        case .other: return "📍"
        }
    }
    
    var label: String {
        switch self {
        case .fish: return "鱼"
        case .crab: return "蟹"
        case .prawn: return "虾"
        case .clam: return "蛤蜊"
        case .squid: return "鱿鱼"
        case .other: return "其他"
        }
    }
}

struct MyFishingSpot: Identifiable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let depth: String
    let categories: [SpotCategory]
    let species: [String]
    let notes: String
    let lastVisited: Date?
    let rating: Int
}

class MySpotsViewModel: ObservableObject {
    @Published var spots: [MyFishingSpot] = []
    @Published var showAddSheet = false
    
    init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: "my_fishing_spots"),
           let decoded = try? JSONDecoder().decode([MyFishingSpot].self, from: data) {
            spots = decoded
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(spots) {
            UserDefaults.standard.set(data, forKey: "my_fishing_spots")
        }
    }
}
