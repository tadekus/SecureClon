//
//  ProgressThrottle.swift
//  SecureClone
//
//  A tiny thread-safe byte counter. The clone engine calls add() from its
//  actor context (off the main thread); the view model reads snapshot() to
//  publish progress without spawning a task per chunk.
//

import Foundation

final class ProgressThrottle: @unchecked Sendable {
    private let lock = NSLock()
    private var bytes: Int64 = 0

    func add(_ n: Int) {
        lock.lock(); bytes += Int64(n); lock.unlock()
    }

    func snapshot() -> Int64 {
        lock.lock(); defer { lock.unlock() }
        return bytes
    }
}
