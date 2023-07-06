//
//  SpeechSynthesizer.swift
//  TimeSpeaker
//
//  Created by 길지훈 on 2023/06/01.
//

import AVFoundation
import UIKit

class SpeechSynthesizer : ObservableObject {
    private let synthesizer: AVSpeechSynthesizer
    @Published var selectedLanguage: String = "ko-KR"
        
    init() {
        self.synthesizer = AVSpeechSynthesizer()
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: selectedLanguage)
        utterance.rate = 0.4

        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func vibrate() {
        let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
    }
    
    func updateSelectedLanguage(_ language: String) {
            selectedLanguage = language
        }
}
