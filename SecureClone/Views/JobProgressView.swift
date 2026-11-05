//
//  JobProgressView.swift
//  SecureClone
//

import SwiftUI

struct JobProgressView: View {
    @ObservedObject var vm: CloneViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let job = vm.job {
                JobHeader(job: job)
                Divider()
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(job.destinationProgress) { dp in
                            DestinationProgressRow(progress: dp, totalBytes: job.totalBytes)
                        }
                    }
                }
                .frame(maxHeight: 220)

                Divider()
                logView
            } else {
                ContentUnavailableView(
                    "No active job",
                    systemImage: "play.circle",
                    description: Text("Select a source card and one or more destination drives, then press Start Clone.")
                )
            }
        }
        .padding()
    }

    private var logView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Log").font(.headline)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(vm.logTail.enumerated()), id: \.offset) { idx, line in
                            Text(line)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(idx)
                        }
                    }
                    .padding(8)
                }
                .background(Color.black.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onChange(of: vm.logTail.count) { _, _ in
                    if let last = vm.logTail.indices.last {
                        withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
            }
        }
    }
}

struct JobHeader: View {
    @ObservedObject var job: CloneJob

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(job.state.label).font(.headline)
                Spacer()
                statusBadge
            }
            ProgressView(value: job.overallProgress)
            if !job.currentFile.isEmpty && job.state == .copying {
                Text(job.currentFile)
                    .font(.system(.caption, design: .monospaced))
                    .lineLimit(1).truncationMode(.middle)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder private var statusBadge: some View {
        switch job.state {
        case .completed:
            Label("Verified", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
        case .failed:
            Label("Failed", systemImage: "xmark.seal.fill").foregroundStyle(.red)
        default:
            EmptyView()
        }
    }
}

struct DestinationProgressRow: View {
    @ObservedObject var progress: DestinationProgress
    let totalBytes: Int64

    private var fraction: Double {
        totalBytes > 0 ? Double(progress.bytesCompleted) / Double(totalBytes) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "externaldrive.fill")
                    .foregroundStyle(progress.failed ? .red : .green)
                Text(progress.volume.name).bold()
                Spacer()
                Text("\(progress.verifiedCount)/\(progress.filesCompleted) verified")
                    .font(.caption).foregroundStyle(.secondary)
            }
            ProgressView(value: fraction)
                .tint(progress.failed ? .red : .green)
            Text(VolumeInfo.format(progress.bytesCompleted))
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.06)))
    }
}
