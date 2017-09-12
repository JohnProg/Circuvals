import Foundation
import AVFoundation

class SpeechQueue: NSObject, AVSpeechSynthesizerDelegate {
    private let synth = AVSpeechSynthesizer()
    private let session = AVAudioSession.sharedInstance()
    private var queue = [String]()

    override init() {
        super.init()
        synth.delegate = self
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        dequeue()
    }
    
    func enque(text: String) {
        if synth.isSpeaking {
            queue.append(text)
        }
        else {
            speak(text: text)
        }
    }
    
    private func dequeue() {
        if let text = queue.popLast() {
            speak(text: text)
        }
        else {
            do {
                try session.setActive(false, with: [.notifyOthersOnDeactivation])
            } catch _ {
                log.error("Error disabling Session")
            }
        }
    }
    
    private func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
    }
}
