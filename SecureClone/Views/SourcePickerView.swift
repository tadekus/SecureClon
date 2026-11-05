//
//  SourcePickerView.swift
//  SecureClone
//

import SwiftUI

struct SourcePickerView: View {
    let volumes: [VolumeInfo]
    @Binding var selection: VolumeInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Source card", systemImage: "sdcard")
                .font(.headline)

            if volumes.isEmpty {
                Text("No volumes detected. Plug in a card reader.")
                    .font(.caption).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            } else {
                ForEach(volumes) { vol in
                    DriveRow(volume: vol,
                             isSelected: selection == vol,
                             accent: .orange) {
                        selection = (selection == vol) ? nil : vol
                    }
                }
            }
        }
    }
}

struct DriveRow: View {
    let volume: VolumeInfo
    let isSelected: Bool
    var accent: Color = .accentColor
    var showCheckbox: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: volume.isRemovable ? "sdcard.fill" : "externaldrive.fill")
                    .foregroundStyle(isSelected ? accent : .secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(volume.name).bold()
                    Text("\(volume.availableCapacityFormatted) free of \(volume.totalCapacityFormatted)")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: showCheckbox ? "checkmark.square.fill" : "checkmark.circle.fill")
                        .foregroundStyle(accent)
                } else if showCheckbox {
                    Image(systemName: "square").foregroundStyle(.secondary)
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? accent.opacity(0.12) : Color.gray.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? accent.opacity(0.5) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
