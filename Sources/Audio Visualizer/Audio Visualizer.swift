import SwiftUI
import Charts

@available(iOS 17, *)
public struct AudioVisualizerView: View {
    @State private var vm: AudioProcessingVM
    
    private let url: URL
    private let name: String
    private let artist: String
    
    public init(_ url: URL, name: String, artist: String) {
        self.url = url
        self.name = name
        self.artist = artist
        
        self.vm = .init(url)
    }
    
    private let timer = Timer.publish(
        every: Constants.updateInterval,
        on: .main,
        in: .common
    ).autoconnect()
    
    @State private var isPlaying = false
    @State private var data: [Float] = Array(repeating: 0, count: Constants.barAmount)
        .map { _ in
            Float.random(in: 1...Constants.magnitudeLimit)
        }
    
    public var body: some View {
        VStack {
            Spacer()
            
            VStack {
                Chart(Array(data.enumerated()), id: \.0) { index, magnitude in
                    BarMark(
                        x: .value("Frequency", String(index)),
                        y: .value("Magnitude", magnitude)
                    )
                    .foregroundStyle(
                        Color(
                            hue: 0.3 - Double((magnitude / Constants.magnitudeLimit) / 5),
                            saturation: 1,
                            brightness: 1,
                            opacity: 0.7
                        )
                    )
                }
                .onReceive(timer, perform: updateData)
                .chartYScale(domain: 0...Constants.magnitudeLimit)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 100)
                .padding()
                .background(
                    .black
                        .opacity(0.3)
                        .shadow(.inner(radius: 20))
                )
                .cornerRadius(10)
                
                playerControls
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 40)
            .padding()
        }
        .background {
            backgroundPicture
        }
        .preferredColorScheme(.dark)
    }
    
    var playerControls: some View {
        Group {
            ProgressView(value: 0.4)
                .tint(.secondary)
                .padding(.vertical)
            
            Text(name)
                .font(.title2)
                .lineLimit(1)
            
            Text(artist)
            
            HStack(spacing: 40) {
                Button {
                    vm.resetAndPlayAudio()
                } label: {
                    Image(systemName: "backward.fill")
                }
                
                Button {
                    playButtonTapped()
                } label: {
                    Image(systemName: "\(isPlaying ? "pause" : "play").circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "forward.fill")
                        .foregroundStyle(.tertiary)
                }
                .disabled(true)
            }
            .padding(10)
            .foregroundColor(.secondary)
        }
    }
    
    var backgroundPicture: some View {
        AsyncImage(
            url: URL(
                string: "https://upload.wikimedia.org/wikipedia/commons/6/6f/Beethoven.jpg"
            ),
            transaction: Transaction(animation: .easeOut(duration: 1))
        ) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                
            default:
                Color.clear
            }
        }
        .overlay {
            LinearGradient(
                colors: [.clear, .black],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
    
    func updateData(_: Date) {
        if isPlaying {
            withAnimation(.easeOut(duration: 0.08)) {
                data = vm.fftMagnitudes.map {
                    min($0, Constants.magnitudeLimit)
                }
            }
        }
    }
    
    func playButtonTapped() {
        if isPlaying {
            vm.player.pause()
        } else {
            vm.player.play()
        }
        
        isPlaying.toggle()
    }
}

//#Preview {
//    AudioVisualizerView(
//        name: "Preview Song",
//        artist: "Preview Artist"
//    )
//}
