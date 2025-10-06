import AVFoundation
import UIKit

class GvAudio {
    static func startCall() {
        let s = AVAudioSession.sharedInstance()
        try? s.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .duckOthers])
        try? s.setActive(true)
        UIDevice.current.isProximityMonitoringEnabled = true
    }
    
    static func endCall() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        UIDevice.current.isProximityMonitoringEnabled = false
    }
    
    static func speaker(_ on: Bool) {
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(on ? .speaker : .none)
    }
}