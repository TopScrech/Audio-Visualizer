import SwiftUI
import Charts
import AVFoundation

@available(iOS 17, *)
public struct AudioVisualizerView: View {
    @State private var vm: AudioProcessingVM
    
    private let url: URL
    private let fileName: String
    
    public init(_ url: URL, fileName: String) {
        self.url = url
        self.fileName = fileName
        
        self.vm = .init(url)
    }
    
    private let timer = Timer.publish(
        every: Constants.updateInterval,
        on: .main,
        in: .common
    ).autoconnect()
    
    @State var song: String?
    @State var artist: String?
    
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
        .task {
            fetchSongAndArtist(url)
        }
        .background {
            backgroundPicture
        }
        .preferredColorScheme(.dark)
    }
    
    private func fetchSongAndArtist(_ url: URL) {
        let asset = AVAsset(url: url)
        let metadata = asset.metadata
        
        for item in metadata {
            if let commonKey = item.commonKey?.rawValue {
                if commonKey == AVMetadataKey.commonKeyTitle.rawValue {
                    song = item.stringValue
                } else if commonKey == AVMetadataKey.commonKeyArtist.rawValue {
                    artist = item.stringValue
                }
            }
        }
    }
    
    var playerControls: some View {
        Group {
            //            ProgressView(value: 0.4)
            //                .tint(.secondary)
            //                .padding(.vertical)
            
            Text(song ?? fileName)
                .font(.title2)
                .lineLimit(1)
                .animation(.default, value: song)
            
            Text(artist ?? "Unknown Artist")
                .animation(.default, value: artist)
            
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
        Group {
            if let artwork = Bundle.main.url(forResource: "artwork", withExtension: "PNG"),
               let image = UIImage(contentsOfFile: artwork.path) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Color.clear
                    .padding()
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
