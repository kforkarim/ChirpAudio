//
//  ChirpGenerator.swift
//  ChirpAudio
//
//  Created by Karim Abdul on 6/28/25.
//

import AVFoundation

class ChirpGenerator {
    private let sampleRate = 44100
    private let durationPerChar: Double = 0.2
    private let fStart: Double = 1000.0

    func generateChirp(for text: String) -> AVAudioPCMBuffer? {
        let totalSamples = Int(Double(sampleRate) * durationPerChar * Double(text.count))
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 1)!
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalSamples)) else { return nil }

        buffer.frameLength = AVAudioFrameCount(totalSamples)
        let channelData = buffer.floatChannelData![0]
        var sampleOffset = 0

        for byte in text.utf8 {
            let freqStart = fStart + Double(byte)
            let freqEnd = freqStart + 500
            let charSamples = Int(Double(sampleRate) * durationPerChar)

            for i in 0..<charSamples {
                let t = Double(i) / Double(sampleRate)
                let instantFreq = freqStart + (freqEnd - freqStart) * t / durationPerChar
                let angle = 2.0 * Double.pi * instantFreq * t
                channelData[sampleOffset + i] = Float(sin(angle)) * 0.5
            }
            sampleOffset += charSamples
        }

        return buffer
    }
}
