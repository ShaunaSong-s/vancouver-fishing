import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var l10n: L10n
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Quick action buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        QuickActionButton(title: l10n.qaTides, icon: "water.waves") {
                            sendMessage(l10n.qaTidesMsg)
                        }
                        .staggeredAppear(index: 0)
                        QuickActionButton(title: l10n.qaWeather, icon: "cloud.sun") {
                            sendMessage(l10n.qaWeatherMsg)
                        }
                        .staggeredAppear(index: 1)
                        QuickActionButton(title: l10n.qaSpots, icon: "mappin.and.ellipse") {
                            sendMessage(l10n.qaSpotsMsg)
                        }
                        .staggeredAppear(index: 2)
                        QuickActionButton(title: l10n.qaCurrent, icon: "arrow.triangle.swap") {
                            sendMessage(l10n.qaCurrentMsg)
                        }
                        .staggeredAppear(index: 3)
                        QuickActionButton(title: l10n.qaRestricted, icon: "exclamationmark.triangle") {
                            sendMessage(l10n.qaRestrictedMsg)
                        }
                        .staggeredAppear(index: 4)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                .background(AppTheme.Colors.oceanMid.opacity(0.3))
                
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.messages) { message in
                                ChatBubbleView(message: message)
                                    .id(message.id)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation(.spring(response: 0.3)) {
                            if let lastMessage = viewModel.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input bar
                HStack(spacing: 12) {
                    TextField(l10n.chatPlaceholder, text: $inputText)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                .fill(AppTheme.Colors.oceanLight.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppTheme.Radius.lg)
                                        .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                                )
                        )
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .focused($isInputFocused)
                        .onSubmit { sendCurrentMessage() }
                    
                    Button(action: sendCurrentMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(inputText.isEmpty ? AppTheme.Colors.textMuted : AppTheme.Colors.deepOcean)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(inputText.isEmpty ? AnyShapeStyle(AppTheme.Colors.oceanLight) : AnyShapeStyle(AppTheme.Colors.goldGradient))
                            )
                            .shadow(color: inputText.isEmpty ? .clear : AppTheme.Colors.gold.opacity(0.3), radius: 8, y: 2)
                    }
                    .disabled(inputText.isEmpty || viewModel.isLoading)
                    .animation(.spring(response: 0.3), value: inputText.isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppTheme.Colors.deepOcean.opacity(0.95))
            }
            .background(AppTheme.Colors.heroGradient.ignoresSafeArea())
            .navigationTitle(l10n.chatTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.Colors.deepOcean.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                if viewModel.messages.isEmpty {
                    viewModel.setWelcome(l10n.chatWelcome)
                }
            }
        }
    }
    
    private func sendMessage(_ text: String) {
        viewModel.sendMessage(text, apiService: appState.apiService, errorMsg: l10n.chatError)
    }
    
    private func sendCurrentMessage() {
        guard !inputText.isEmpty else { return }
        let text = inputText
        inputText = ""
        sendMessage(text)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption.weight(.medium))
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(AppTheme.Colors.oceanLight.opacity(0.6))
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.Colors.gold.opacity(0.2), lineWidth: 0.5)
                    )
            )
            .foregroundColor(AppTheme.Colors.goldLight)
        }
    }
}

struct ChatBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 50) }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(message.isUser
                                  ? LinearGradient(colors: [AppTheme.Colors.oceanSurface, AppTheme.Colors.oceanLight], startPoint: .topLeading, endPoint: .bottomTrailing)
                                  : LinearGradient(colors: [AppTheme.Colors.oceanMid.opacity(0.6), AppTheme.Colors.oceanLight.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(message.isUser ? AppTheme.Colors.gold.opacity(0.15) : AppTheme.Colors.cardBorder, lineWidth: 0.5)
                            )
                    )
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(message.timestamp, style: .time)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.Colors.textMuted)
            }
            
            if !message.isUser { Spacer(minLength: 50) }
        }
    }
}
