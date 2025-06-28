//
//  ChirpReceiverView.swift
//  ChirpAudio
//
//  Created by Karim Abdul on 6/28/25.
//

import SwiftUI
import AVFoundation

struct ChirpReceiverView: View {
    @State private var detectedText: String = ""
    private let micEngine = AVAudioEngine()
    private let decoder = ChirpDecoder()

    var body: some View {
        VStack(spacing: 20) {
            Text("Detected Text: \(detectedText)")
                .font(.headline)
                .padding()
        }
        .padding()
        .onAppear {
            setupMicInput()
        }
    }

    private func setupMicInput() {
    #if targetEnvironment(simulator)
        // Simulator has no valid audio input; skip to avoid crash
        print("Simulator: microphone input disabled")
        return
    #endif
        
        // Configure audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
            return
        }
        
        let input = micEngine.inputNode
        let bus = 0
        let format = AVAudioFormat(standardFormatWithSampleRate: session.sampleRate, channels: 1)
        
        input.removeTap(onBus: bus)
        input.installTap(onBus: bus, bufferSize: 1024, format: format) { buffer, _ in
            if let result = decoder.process(buffer: buffer, format: format!) {
                DispatchQueue.main.async {
                    self.detectedText.append(result)
                }
            }
        }
        
        do {
            try micEngine.start()
        } catch {
            print("Mic engine start error: \(error)")
        }
    }
}
