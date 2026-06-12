# App Store 上架完整指南

## Top Vancouver Fishing Charter Inc. — 钓鱼助手 App

---

## 第一步：注册 Apple Developer Program

1. 前往 https://developer.apple.com/programs/enroll/
2. 选择 **Organization** (公司类型)
3. 需要准备：
   - Apple ID（用公司邮箱注册一个新的，如 dev@topvancouverfishing.com）
   - **D-U-N-S Number** — 免费申请：https://developer.apple.com/enroll/duns-lookup/
     - 输入公司名 "Top Vancouver Fishing Charter Inc"
     - 地址填温哥华办公地址
     - 通常 5-7 个工作日获得
   - 公司法律实体名称（必须与BC Registry一致）
   - 公司网站（需要有一个活跃网站）
4. 支付 $99 USD/年 (约 $135 CAD)
5. Apple 审核公司资质，通常 1-3 个工作日

> ⚠️ D-U-N-S Number 是最耗时的步骤，建议第一时间申请

---

## 第二步：配置证书和签名

注册完成后，登录 https://developer.apple.com：

### 2.1 创建 App ID
1. Certificates, Identifiers & Profiles → Identifiers → ＋
2. 选 App IDs → Continue
3. Bundle ID: `com.topvancouverfishing.fishingassistant`
4. Description: Fishing Assistant
5. Capabilities 勾选: ✅ Maps, ✅ Push Notifications (如果以后需要)

### 2.2 创建 Distribution Certificate
1. Certificates → ＋ → Apple Distribution
2. 在 Mac 上打开 Keychain Access → Certificate Assistant → Request a Certificate from a Certificate Authority
3. 上传 CSR 文件 → 下载证书 → 双击安装

### 2.3 创建 Provisioning Profile
1. Profiles → ＋ → App Store Connect
2. 选择刚创建的 App ID
3. 选择 Distribution Certificate
4. 命名: "FishingAssistant AppStore"
5. 下载并双击安装

---

## 第三步：Xcode 项目配置

在 Xcode 中更新以下设置：

### 3.1 General Tab
- Display Name: `钓鱼助手`
- Bundle Identifier: `com.topvancouverfishing.fishingassistant`
- Version: `1.0.0`
- Build: `1`

### 3.2 Signing & Capabilities
- 取消勾选 "Automatically manage signing"（或保持自动并选对 Team）
- Team: 选择 "Top Vancouver Fishing Charter Inc"
- Signing Certificate: Apple Distribution
- Provisioning Profile: 选择刚下载的 profile

### 3.3 需要在 project.pbxproj 中更新的值：
```
DEVELOPMENT_TEAM = <你的新Team ID>;  // 注册后会得到
PRODUCT_BUNDLE_IDENTIFIER = com.topvancouverfishing.fishingassistant;
```

---

## 第四步：创建 App Store Connect 列表

1. 登录 https://appstoreconnect.apple.com
2. My Apps → ＋ → New App
3. 填写：
   - Platform: iOS
   - Name: "Fishing Assistant - Vancouver" 或 "钓鱼助手 - 温哥华"
   - Primary Language: English (Canada) 或 Simplified Chinese
   - Bundle ID: 选择之前创建的
   - SKU: `fishing-assistant-v1`

---

## 第五步：填写 App Store 信息

参考 `app-store-metadata.md` 文件中的内容：

### 5.1 App Information
- Category: Sports (Primary), Weather (Secondary)
- Content Rights: Does not contain third-party content
- Age Rating: 4+

### 5.2 Pricing and Availability
- Price: Free
- Availability: All territories (或只选 Canada 先)

### 5.3 App Privacy (隐私标签)
Apple 会让你声明数据收集情况：
- **Location**: ✅ Used for App Functionality (NOT linked to identity, NOT used for tracking)
- **Usage Data**: ❌ Not collected
- **Contact Info**: ❌ Not collected
- **Identifiers**: ❌ Not collected

### 5.4 版本信息
- Screenshots (见 metadata 文件的截图尺寸要求)
- Description (从 metadata 文件复制)
- Keywords
- Support URL: 你的网站
- Privacy Policy URL: 你的隐私政策页面

---

## 第六步：上传构建

### 6.1 Archive
```bash
# 在 Xcode 中:
Product → Archive

# 或命令行:
xcodebuild archive \
  -scheme FishingAssistant \
  -archivePath build/FishingAssistant.xcarchive \
  -destination 'generic/platform=iOS'
```

### 6.2 Upload
- Archive 完成后, Xcode Organizer 会打开
- 选择 Archive → Distribute App → App Store Connect → Upload
- 等待 Apple 处理 (通常 10-30 分钟)

### 6.3 TestFlight (推荐先内测)
- 上传后在 App Store Connect → TestFlight 中可见
- 添加内部测试员 (最多25人，无需审核)
- 添加外部测试员 (需要 Beta 审核，通常24小时)

---

## 第七步：提交审核

1. 在 App Store Connect 选择版本 → 添加 Build
2. 填写 App Review Information:
   - 联系信息 (名字、电话、邮箱)
   - Review Notes (告诉审核员如何测试)
   - 不需要 Demo Account (本app无登录)
3. 提交 (Submit for Review)
4. 审核时间：通常 24-48 小时

---

## 常见审核被拒原因及预防

| 潜在问题 | 状态 | 解决方案 |
|---------|------|---------|
| 缺少隐私政策 | ✅ 已准备 | `docs/privacy-policy.html` |
| 位置权限未说明用途 | ✅ 已有 | Info.plist 中已设置 |
| 硬编码 API Key | ⚠️ 注意 | Groq free tier key 在代码中，建议后续移到服务器 |
| 无网络时崩溃 | ❓ 需测试 | 确保离线状态有错误提示 |
| iPad 适配 | ✅ 已支持 | TARGETED_DEVICE_FAMILY = "1,2" |
| 截图不符 | ❓ 需准备 | 需要真机截图 |

---

## 时间线预估

| 步骤 | 预计时间 |
|------|---------|
| D-U-N-S 申请 | 5-7 工作日 |
| Apple Developer 审核 | 1-3 工作日 |
| 准备截图和文案 | 1-2 天 |
| TestFlight 内测 | 建议至少 1 周 |
| App Review | 24-48 小时 |
| **总计** | **约 3-4 周** |

---

## 后续优化建议

1. **网站**: 建立 topvancouverfishing.com，放隐私政策和支持页面
2. **API Key 安全**: 将 Groq API key 移到后端代理，不直接暴露在客户端
3. **App Store 优化 (ASO)**: 根据搜索词排名调整 keywords
4. **Localization**: 添加 App Store 多语言描述（英文 + 中文已准备）
5. **Push 通知**: 未来可加鱼情提醒、天气警报等

---

## 需要你操作的清单

- [ ] 申请 D-U-N-S Number
- [ ] 注册 Apple Developer Program (Organization)
- [ ] 建立公司网站 (至少放隐私政策页面)
- [ ] 设置公司邮箱 (privacy@topvancouverfishing.com)
- [ ] 在 Xcode 中更新 Team ID 和 Bundle ID
- [ ] 做真机截图 (至少5张)
- [ ] TestFlight 内测
- [ ] 提交审核
