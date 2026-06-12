import Foundation

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    
    func setWelcome(_ text: String) {
        if messages.isEmpty {
            messages = [ChatMessage(content: text, isUser: false, timestamp: Date())]
        }
    }
    
    func sendMessage(_ text: String, apiService: APIService, errorMsg: String) {
        let userMessage = ChatMessage(content: text, isUser: true, timestamp: Date())
        messages.append(userMessage)
        isLoading = true
        
        Task { @MainActor in
            do {
                let response = try await apiService.chat(message: text, history: messages)
                let aiMessage = ChatMessage(content: response, isUser: false, timestamp: Date())
                messages.append(aiMessage)
            } catch {
                let errMessage = ChatMessage(content: errorMsg, isUser: false, timestamp: Date())
                messages.append(errMessage)
            }
            isLoading = false
        }
    }
}

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}
