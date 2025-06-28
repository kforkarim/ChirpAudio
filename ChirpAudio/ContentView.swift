import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "Transmitter"

    var body: some View {
        NavigationView {
            VStack {
                Picker("Mode", selection: $selectedTab) {
                    Text("Transmitter").tag("Transmitter")
                    Text("Receiver").tag("Receiver")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if selectedTab == "Transmitter" {
                    ChirpTransmitterView()
                } else {
                    ChirpReceiverView()
                }
            }
            .navigationTitle("Chirp Communicator")
        }
    }
}
