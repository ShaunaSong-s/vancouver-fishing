import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var l10n: L10n
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.2), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 40)
                        
                        // Logo
                        VStack(spacing: 8) {
                            Text("🐟")
                                .font(.system(size: 72))
                            Text("Vancouver Fishing")
                                .font(.title)
                                .fontWeight(.bold)
                            Text(l10n.t("温哥华钓鱼助手", "Vancouver Fishing Assistant"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 20)
                        
                        // Form
                        VStack(spacing: 16) {
                            if isSignUp {
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(.gray)
                                        .frame(width: 24)
                                    TextField(l10n.t("昵称", "Name"), text: $name)
                                        .textContentType(.name)
                                        .autocapitalization(.words)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 5)
                            }
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                TextField(l10n.loginEmail, text: $email)
                                    .textContentType(.emailAddress)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                    .frame(width: 24)
                                SecureField(l10n.loginPassword, text: $password)
                                    .textContentType(isSignUp ? .newPassword : .password)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 5)
                        }
                        .padding(.horizontal)
                        
                        // Login / Signup Button
                        Button(action: performAuth) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(isSignUp ? l10n.signupButton : l10n.loginButton)
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding(.horizontal)
                        
                        // Toggle login/signup
                        Button(action: { withAnimation { isSignUp.toggle() } }) {
                            Text(isSignUp
                                 ? l10n.t("已有账号？登录", "Already have an account? Log In")
                                 : l10n.t("没有账号？注册", "Don't have an account? Sign Up"))
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        
                        // Language switcher
                        Picker("", selection: $l10n.language) {
                            ForEach(L10n.Language.allCases, id: \.self) { lang in
                                Text(lang.displayName).tag(lang)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                        
                        Spacer()
                    }
                }
            }
            .alert(l10n.t("登录失败", "Login Failed"), isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(l10n.t("请检查邮箱和密码", "Please check your email and password"))
            }
        }
    }
    
    private func performAuth() {
        isLoading = true
        Task {
            let success: Bool
            if isSignUp {
                success = await appState.signup(email: email, password: password, name: name)
            } else {
                success = await appState.login(email: email, password: password)
            }
            await MainActor.run {
                isLoading = false
                if !success { showError = true }
            }
        }
    }
}
