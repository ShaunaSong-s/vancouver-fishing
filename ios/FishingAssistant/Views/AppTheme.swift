import SwiftUI

// MARK: - App Design System
// Deep Ocean + Gold — luxury maritime aesthetic

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        // Primary ocean palette
        static let deepOcean = Color(red: 0.016, green: 0.051, blue: 0.102)     // #040d1a
        static let oceanMid = Color(red: 0.039, green: 0.118, blue: 0.239)       // #0a1e3d
        static let oceanLight = Color(red: 0.063, green: 0.165, blue: 0.290)     // #102a4a
        static let oceanSurface = Color(red: 0.098, green: 0.220, blue: 0.365)   // #19385d
        
        // Gold accent
        static let gold = Color(red: 0.788, green: 0.663, blue: 0.431)           // #c9a96e
        static let goldLight = Color(red: 0.910, green: 0.835, blue: 0.659)      // #e8d5a8
        static let goldBright = Color(red: 0.961, green: 0.902, blue: 0.784)     // #f5e6c8
        
        // Functional
        static let accent = Color(red: 0.180, green: 0.714, blue: 0.878)         // Teal-blue
        static let success = Color(red: 0.2, green: 0.78, blue: 0.55)
        static let warning = Color(red: 0.95, green: 0.68, blue: 0.0)
        static let danger = Color(red: 0.95, green: 0.25, blue: 0.2)
        
        // Text
        static let textPrimary = Color(red: 0.941, green: 0.925, blue: 0.894)    // #f0ece4
        static let textSecondary = Color(red: 0.941, green: 0.925, blue: 0.894).opacity(0.6)
        static let textMuted = Color(red: 0.941, green: 0.925, blue: 0.894).opacity(0.4)
        
        // Card backgrounds
        static let cardBg = Color(red: 0.039, green: 0.118, blue: 0.239).opacity(0.5)
        static let cardBorder = Color(red: 0.788, green: 0.663, blue: 0.431).opacity(0.12)
        
        // Gradient presets
        static let heroGradient = LinearGradient(
            colors: [deepOcean, oceanMid, deepOcean],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let goldGradient = LinearGradient(
            colors: [goldBright, gold, Color(red: 0.659, green: 0.518, blue: 0.290)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let cardGradient = LinearGradient(
            colors: [oceanLight.opacity(0.4), oceanMid.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Dimensions
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }
    
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let pill: CGFloat = 100
    }
}

// MARK: - View Modifiers

struct OceanCardModifier: ViewModifier {
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(AppTheme.Colors.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.Colors.cardBorder, lineWidth: 1)
                    )
            )
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                            .stroke(AppTheme.Colors.cardBorder, lineWidth: 0.5)
                    )
            )
    }
}

struct GoldAccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(AppTheme.Colors.deepOcean)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(AppTheme.Colors.goldGradient)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

struct OceanButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(AppTheme.Colors.goldLight)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(AppTheme.Colors.oceanLight)
                    .overlay(
                        Capsule()
                            .stroke(AppTheme.Colors.gold.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

// MARK: - Animations

struct AppAnimations {
    static let springResponse: Double = 0.4
    static let springDamping: Double = 0.75
    
    static var smooth: Animation {
        .spring(response: springResponse, dampingFraction: springDamping)
    }
    
    static var quick: Animation {
        .spring(response: 0.25, dampingFraction: 0.8)
    }
    
    static func staggered(index: Int, base: Double = 0.05) -> Animation {
        .spring(response: springResponse, dampingFraction: springDamping)
        .delay(Double(index) * base)
    }
}

// MARK: - Staggered Appear Modifier
struct StaggeredAppearModifier: ViewModifier {
    let index: Int
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 18)
            .onAppear {
                withAnimation(AppAnimations.staggered(index: index)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Shimmer Modifier (for loading states)
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, AppTheme.Colors.goldLight.opacity(0.15), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 200
                }
            }
    }
}

// MARK: - Scale Press Modifier
struct ScalePressModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(AppAnimations.quick, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - View Extensions

extension View {
    func oceanCard(padding: CGFloat = 16) -> some View {
        modifier(OceanCardModifier(padding: padding))
    }
    
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
    
    func oceanBackground() -> some View {
        self.background(AppTheme.Colors.heroGradient.ignoresSafeArea())
    }
    
    func staggeredAppear(index: Int) -> some View {
        modifier(StaggeredAppearModifier(index: index))
    }
    
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
    
    func scalePress() -> some View {
        modifier(ScalePressModifier())
    }
}
