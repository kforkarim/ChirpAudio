//
//  ChirpDecoder.swift
//  ChirpAudio
//
//  Created by Karim Abdul on 6/28/25.
//

import AVFoundation
import Accelerate

class ChirpDecoder {
    private let sampleRate: Double = 44100
    private let fftSize: Int = 1024
    private var fftSetup: FFTSetup?
    private var window: [Float]
    
    init() {
        fftSetup = vDSP_create_fftsetup(vDSP_Length(log2(Float(fftSize))), FFTRadix(kFFTRadix2))
        window = [Float](repeating: 0.0, count: fftSize)
        vDSP_hann_window(&window, vDSP_Length(fftSize), Int32(vDSP_HANN_NORM))
    }
    
    func process(buffer: AVAudioPCMBuffer, format: AVAudioFormat) -> String? {
        guard let data = buffer.floatChannelData?[0] else { return nil }
        
        var real = [Float](repeating: 0.0, count: fftSize)
        var imag = [Float](repeating: 0.0, count: fftSize)
        
        for i in 0..<fftSize {
            real[i] = data[i] * window[i]
        }
        
        var detectedChar: String? = nil
        
        real.withUnsafeMutableBufferPointer { realPtr in
            imag.withUnsafeMutableBufferPointer { imagPtr in
                var splitComplex = DSPSplitComplex(realp: realPtr.baseAddress!, imagp: imagPtr.baseAddress!)
                vDSP_fft_zip(fftSetup!, &splitComplex, 1, vDSP_Length(log2(Float(fftSize))), FFTDirection(FFT_FORWARD))
                
                var magnitudes = [Float](repeating: 0.0, count: fftSize / 2)
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(fftSize / 2))
                
                if let maxIndex = magnitudes.firstIndex(of: magnitudes.max() ?? 0.0) {
                    let freq = Double(maxIndex) * sampleRate / Double(fftSize)
                    let charCode = Int(freq - 1000.0)
                    if (0..<256).contains(charCode) {
                        detectedChar = String(UnicodeScalar(UInt8(charCode)))
                    }
                }
            }
        }
        
        return detectedChar
    }
    
    deinit {
        if let setup = fftSetup {
            vDSP_destroy_fftsetup(setup)
        }
    }
}
