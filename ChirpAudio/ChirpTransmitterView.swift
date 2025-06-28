//
//  ChirpTransmitterView.swift
//  ChirpAudio
//
//  Created by Karim Abdul on 6/28/25.
//

import SwiftUI
import AVFoundation

struct ChirpTransmitterView: View {
    @State private var inputText: String = ""
    @State private var isPlaying: Bool = false

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let chirpGenerator = ChirpGenerator()

    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter text to transmit", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: playChirp) {
                Text(isPlaying ? "Playing..." : "Transmit via Chirp")
                    .foregroundColor(.white)
                    .padding()
                    .background(isPlaying ? Color.gray : Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isPlaying || inputText.isEmpty)
        }
        .padding()
        .onAppear {
            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: nil)
            try? engine.start()
        }
    }

    private func playChirp() {
    #if targetEnvironment(simulator)
        // Simulator playback disabled to avoid audio format crash
        print("Simulator: playback disabled")
        self.isPlaying = false
        return
    #endif
        guard let buffer = chirpGenerator.generateChirp(for: inputText) else { return }
        isPlaying = true
        player.play()
        player.scheduleBuffer(buffer, at: nil, options: .interrupts) {
            DispatchQueue.main.async { self.isPlaying = false }
        }
    }
}
