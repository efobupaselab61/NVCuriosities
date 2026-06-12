import SwiftUI

#if canImport(UIKit)
public struct NVLaunchProbePanel: View {
    public let configuration: NVSignalConfiguration
    @AppStorage("settings.language") private var preferredLanguage = "en"
    @State private var isLoading = false
    @State private var statusMessage: String?
    @State private var presentedDestination: NVLaunchDestination?

    public init(configuration: NVSignalConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("NV Launch Probe", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(NVSignalTheme.accent)

            Text("Checks the NV launch route and opens the approved destination when the server enables it.")
                .font(.subheadline)
                .foregroundStyle(NVSignalTheme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button {
                Task { await loadDestination() }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .tint(NVSignalTheme.navy)
                    }
                    Text(isLoading ? "Probing..." : "Probe Route")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(NVSignalTheme.accent)
            .foregroundStyle(NVSignalTheme.navy)
            .disabled(isLoading)

            if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(NVSignalTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NVSignalTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .fullScreenCover(item: $presentedDestination) { destination in
            NavigationStack {
                NVSignalBrowserScreen(configuration: destination.configuration)
            }
        }
        .nvSignalKeepsAudioAlive()
    }

    @MainActor
    private func loadDestination() async {
        isLoading = true
        statusMessage = nil
        defer { isLoading = false }

        do {
            let client = NVSignalRequestClient(configuration: configuration)
            let decision = try await client.loadDecision(preferredLanguage: preferredLanguage)

            guard decision.enabled else {
                statusMessage = "Route disabled. Staying in NV Curiosities."
                return
            }

            guard let url = decision.url else {
                statusMessage = "Route enabled but no destination URL was provided."
                return
            }

            presentedDestination = NVLaunchDestination(
                configuration: configuration.resolvedDestination(url)
            )
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}

public struct NVLaunchDestination: Identifiable {
    public let id = UUID()
    public let configuration: NVSignalConfiguration

    public init(configuration: NVSignalConfiguration) {
        self.configuration = configuration
    }
}
#endif
