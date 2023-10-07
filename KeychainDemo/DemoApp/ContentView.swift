//
//  ContentView.swift
//  DummyHost
//
//  Created by Alexander Cyon on 2023-10-07.
//

import Foundation
import SwiftUI

enum Status: Equatable {
	case initializing
	case initialized
	case failedToInitialize(String)
	
	case error(String)
	case finishedWithFailure(String)
	case finishedSuccessfully
}

struct ContentView: View {
	let sut = KeychainActor.shared
	@State var status: Status = .initializing
	var body: some View {
		VStack {
			StatusView(status: status)
			Button("Test") {
				Task {
					await doTest()
				}
			}
		}.task {
			await initialize()
		}
	}
	
	private func initialize() async {
		do {
			try await sut.removeAllItems()
			status = .initialized
		} catch {
			status = .failedToInitialize("Failed to remove all items in keychain \(error)")
		}
	}
	
	private func doTest() async {
		do {
			let result = try await manyTasks {
				try await sut.getSavedDataElseSaveNewRandom()
			}
			if result.count == 0 {
				status = .finishedWithFailure("Zero elements")
			} else if result.count == 1 {
				status = .finishedSuccessfully
			} else {
				status = .finishedWithFailure("#\(result.count) elements")
			}
		} catch {
			status = .error("\(error)")
		}
	}
}

struct StatusView: View {
	let status: Status
	var body: some View {
		HStack {
			Circle().fill(status.color)
				.frame(width: 20, height: 20)
			Text(status.description)
		}
	}
}

extension Status {
	var description: String {
		switch self {
		case .initializing: return "initializing"
		case let .failedToInitialize(error): return "Failed to initialize \(error)"
		case .initialized: return "initialized"
		case let .error(error): return "Error: \(error)"
		case .finishedSuccessfully: return "Success"
		case let .finishedWithFailure(failure): return "Failed: \(failure)"
		}
	}
	var color: Color {
		switch self {
		case .initializing: return .yellow
		case .failedToInitialize: return .red
		case .initialized: return .blue
		case .error: return .red
		case .finishedSuccessfully: return .green
		case .finishedWithFailure: return .orange
		}
	}
}
