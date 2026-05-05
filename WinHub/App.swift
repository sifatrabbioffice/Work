import SwiftUI
import UniformTypeIdentifiers

@main
struct WinHubApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var isGameRunning = false
    @State private var selectedFile: String = "No File Loaded"
    @State private var showFilePicker = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isGameRunning {
                EmulatorView(fileName: selectedFile) {
                    isGameRunning = false
                }
            } else {
                VStack(spacing: 25) {
                    Text("WIN HUB ENVIRONMENT")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.blue)
                    
                    Text("Loaded: \(selectedFile)")
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 20) {
                        Button(action: { showFilePicker = true }) {
                            Label("Import File", systemImage: "doc.badge.plus")
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        
                        if selectedFile != "No File Loaded" {
                            Button(action: { isGameRunning = true }) {
                                Text("Run Game")
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.item]) { result in
            switch result {
            case .success(let url):
                selectedFile = url.lastPathComponent
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// এমাসিভ গেমপ্যাড ওভারলে
struct EmulatorView: View {
    let fileName: String
    var onExit: () -> Void
    
    var body: some View {
        ZStack {
            // Emulator Screen Area
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 0.1))
                .overlay(Text("Executing: \(fileName)").foregroundColor(.white.opacity(0.2)))
            
            VStack {
                HStack {
                    Button("Exit", action: onExit)
                        .padding().background(Color.red.opacity(0.8)).cornerRadius(10)
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                // Gamepad Controls
                HStack {
                    JoystickControl()
                    Spacer()
                    ActionButtonGrid()
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea()
    }
}

struct JoystickControl: View {
    @State private var drag = CGSize.zero
    var body: some View {
        Circle()
            .fill(.white.opacity(0.1))
            .frame(width: 150, height: 150)
            .overlay(
                Circle()
                    .fill(.white.opacity(0.6))
                    .frame(width: 70, height: 70)
                    .offset(drag)
                    .gesture(DragGesture().onChanged { v in
                        let limit: CGFloat = 40
                        drag = CGSize(
                            width: min(max(v.translation.width, -limit), limit),
                            height: min(max(v.translation.height, -limit), limit)
                        )
                    }.onEnded { _ in withAnimation { drag = .zero } })
            )
    }
}

struct ActionButtonGrid: View {
    var body: some View {
        VStack(spacing: 20) {
            GameBtn(t: "Y", c: .yellow)
            HStack(spacing: 20) {
                GameBtn(t: "X", c: .blue)
                GameBtn(t: "B", c: .red)
            }
            GameBtn(t: "A", c: .green)
        }
    }
}

struct GameBtn: View {
    let t: String; let c: Color
    var body: some View {
        Circle().fill(c.opacity(0.7)).frame(width: 75, height: 75)
            .overlay(Text(t).bold().white())
    }
}

extension View {
    func white() -> some View { self.foregroundColor(.white) }
}
