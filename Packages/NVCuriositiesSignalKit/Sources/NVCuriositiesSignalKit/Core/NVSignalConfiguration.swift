import Foundation

public struct NVSignalConfiguration: Equatable, Sendable {
    public let serverDomain: String
    public let initialURL: URL
    public let signalCheckURL: URL
    public let signalToken: String
    public let bundleID: String
    public let initialCheckDelay: TimeInterval
    public let requestTimeout: TimeInterval
    public let requestMode: NVSignalRequestMode

    public init(
        serverDomain: String? = nil,
        initialURL: URL,
        signalCheckURL: URL,
        signalToken: String,
        bundleID: String,
        initialCheckDelay: TimeInterval = 0.45,
        requestTimeout: TimeInterval = 7,
        requestMode: NVSignalRequestMode = .bundleProbe
    ) {
        self.serverDomain = serverDomain ?? signalCheckURL.host ?? initialURL.host ?? ""
        self.initialURL = initialURL
        self.signalCheckURL = signalCheckURL
        self.signalToken = signalToken
        self.bundleID = bundleID
        self.initialCheckDelay = initialCheckDelay
        self.requestTimeout = requestTimeout
        self.requestMode = requestMode
    }

    public init(
        serverDomain: String,
        signalToken: String,
        bundleID: String,
        fallbackURL: URL? = nil,
        initialCheckDelay: TimeInterval = 0.45,
        requestTimeout: TimeInterval = 7,
        requestMode: NVSignalRequestMode = .bundleProbe
    ) {
        let normalizedDomain = serverDomain.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseURL = URL(string: "https://\(normalizedDomain)")!

        self.init(
            serverDomain: normalizedDomain,
            initialURL: fallbackURL ?? baseURL,
            signalCheckURL: URL(string: "https://\(normalizedDomain)/api/v1/check")!,
            signalToken: signalToken,
            bundleID: bundleID,
            initialCheckDelay: initialCheckDelay,
            requestTimeout: requestTimeout,
            requestMode: requestMode
        )
    }

    public static let nvCuriositiesPreset = NVSignalConfiguration(
        serverDomain: "blazzapp.live",
        signalToken: "8e23ec9a97206ddf8219519426a79f3c6a1952f4d5f7b1f25730a186904e3148",
        bundleID: "com.nv.curiosities"
    )

    public func resolvedDestination(_ url: URL) -> NVSignalConfiguration {
        NVSignalConfiguration(
            serverDomain: serverDomain,
            initialURL: url,
            signalCheckURL: signalCheckURL,
            signalToken: signalToken,
            bundleID: bundleID,
            initialCheckDelay: initialCheckDelay,
            requestTimeout: requestTimeout,
            requestMode: requestMode
        )
    }
}

public enum NVSignalRequestMode: Equatable, Sendable {
    case bundleProbe
    case launchAnalytics
}
