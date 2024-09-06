# Usage Example
```swift
import AudioVisualizer

if let url = Bundle.main.url(forResource: "music", withExtension: "mp3") {
    NavigationLink("Test") {
        AudioVisualizerView(
            url,
            name: "Moonlight Sonata Op. 27 No. 2 - III. Preston",
            artist: "Ludwig van Beethoven"
        )
    }
}
```
