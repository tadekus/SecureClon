//
//  DestinationPickerView.swift
//  SecureClone
//

import SwiftUI

struct DestinationPickerView: View {
    let volumes: [VolumeInfo]
    let source: VolumeInfo?
    @Binding var selection: Set<VolumeInfo>

    /// Don't allow the source to also be a destination.
    private var candidates: [VolumeInfo] {
        volumes.filter { $0 != source }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Destinations (\(selection.count))", systemImage: "externaldrive.badge.plus")
                .font(.headline)

            if candidates.isEmpty {
                Text("No destination drives available.")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            } else {
                ForEach(candidates) { vol in
                    DriveRow(volume: vol,
                             isSelected: selection.contains(vol),
                             accent: .green,
                             showCheckbox: true) {
                        if selection.contains(vol) { selection.remove(vol) }
                        else { selection.insert(vol) }
                    }
                }
            }
        }
    }
}
