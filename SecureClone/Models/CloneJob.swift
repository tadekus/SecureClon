//
//  CloneJob.swift
//  SecureClone
//
//  Models for a cloning operation: the job itself, per-file results,
//  and per-destination verification status.
//

import Foundation

enum JobState: Equatable {
    case idle
    case scanning
    case copying
    case verifying
    case completed
    case failed(String)

    var label: String {
        switch self {
        case .idle:       return "Ready"
        case .scanning:   return "Scanning source…"
        case .copying:    return "Copying…"
        case .verifying:  return "Verifying…"
        case .completed:  return "Completed"
        case .failed(let m): return "Failed: \(m)"
        }
    }
}

/// One source file fanned out to N destinations.
struct FileResult: Identifiable {
    let id = UUID()
    let relativePath: String
    let size: Int64
    var sourceHash: String = ""
    /// destination mount URL -> computed hash
    var destinationHashes: [URL: String] = [:]
    /// destination mount URL -> verified (hash matches source)
    var verified: [URL: Bool] = [:]

    var allVerified: Bool {
        !verified.isEmpty && verified.values.allSatisfy { $0 }
    }
}

/// Per-destination running totals, for the UI.
final class DestinationProgress: Identifiable, ObservableObject {
    let id = UUID()
    let volume: VolumeInfo
    @Published var filesCompleted: Int = 0
    @Published var bytesCompleted: Int64 = 0
    @Published var verifiedCount: Int = 0
    @Published var failed: Bool = false

    init(volume: VolumeInfo) { self.volume = volume }
}

final class CloneJob: ObservableObject, Identifiable {
    let id = UUID()
    let source: VolumeInfo
    let destinations: [VolumeInfo]
    let algorithm: HashAlgorithm
    let startedAt: Date = Date()

    @Published var state: JobState = .idle
    @Published var overallProgress: Double = 0      // 0…1 across all bytes
    @Published var currentFile: String = ""
    @Published var fileResults: [FileResult] = []
    @Published var destinationProgress: [DestinationProgress]

    var totalBytes: Int64 = 0
    var bytesProcessed: Int64 = 0

    init(source: VolumeInfo, destinations: [VolumeInfo], algorithm: HashAlgorithm) {
        self.source = source
        self.destinations = destinations
        self.algorithm = algorithm
        self.destinationProgress = destinations.map { DestinationProgress(volume: $0) }
    }

    var allDestinationsVerified: Bool {
        !fileResults.isEmpty && fileResults.allSatisfy { $0.allVerified }
    }
}
