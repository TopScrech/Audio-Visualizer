import AVFoundation
import Accelerate

/**
 - I'm no expert in audio processing. What I did here, I learnt from this Article:
 - __Audio Visualization in Swift Using Metal and Accelerate__
 - _By Alex Barbulescu_
 - https://betterprogramming.pub/audio-visualization-in-swift-using-metal-accelerate-part-1-390965c095d7
 
 This works for the purposes of this demo, but if you want to add a sound visualizer to a real app,
 consider using something more robust, like the [AudioKit](https://audiokit.io/) framework.
 */

@available(iOS 17, *)
@Observable
final class AudioProcessingVM {
    private let engine = AVAudioEngine()
    private let bufferSize = 1024
    
    let player = AVAudioPlayerNode()
    
    var fftMagnitudes: [Float] = []
    private var audioFile: AVAudioFile
    
    init(_ url: URL) {
        // Initialize the audio file
        audioFile = try! AVAudioFile(forReading: url)
        let format = audioFile.processingFormat
        
        // Setup the audio engine
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        
        engine.prepare()
        try! engine.start()
        
        // Schedule the file to play
        player.scheduleFile(audioFile, at: nil)
        
        // Setup FFT
        let fftSetup = vDSP_DFT_zop_CreateSetup(nil, UInt(bufferSize), vDSP_DFT_Direction.FORWARD)
        
        // Install a tap to capture audio data
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: UInt32(bufferSize), format: nil) { [self] buffer, _ in
            if let channelData = buffer.floatChannelData?[0] {
                fftMagnitudes = fft(data: channelData, setup: fftSetup!)
            }
        }
    }
    
    func resetAndPlayAudio() {
        if player.isPlaying {
            player.stop()
            player.scheduleFile(audioFile, at: nil)
            player.play()
        } else {
            player.scheduleFile(audioFile, at: nil)
        }
    }
    
    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        var realIn = [Float](repeating: 0, count: bufferSize)
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)
        
        for i in 0 ..< bufferSize {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        
        var magnitudes = [Float](repeating: 0, count: Constants.barAmount)
        
        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imagBP in
                var complex = DSPSplitComplex(
                    realp: realBP.baseAddress!,
                    imagp: imagBP.baseAddress!
                )
                
                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(Constants.barAmount))
            }
        }
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: Constants.barAmount)
        var scalingFactor = Float(1)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(Constants.barAmount))
        
        return normalizedMagnitudes
    }
}
