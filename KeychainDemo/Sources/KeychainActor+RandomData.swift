//
//  KeychainActor+RandomData.swift
//  DummyHost
//
//  Created by Alexander Cyon on 2023-10-07.
//

import Foundation
import KeychainAccess

let randomDataKey = "randomDataKey"

extension KeychainActor {
	
	func setRandomData(
		_ data: Data = .random()
	) async throws {
		try await KeychainActor.shared.authenticatedSetData(
			data,
			forKey: randomDataKey,
			accessibility: .whenUnlocked,
			authenticationPolicy: .userPresence
		)
	}
	
	func getSavedRandomData() async throws -> Data? {
		try await KeychainActor.shared.getDataWithAuth(
			forKey: randomDataKey,
			authenticationPrompt: "random data"
		)
	}
	
	@discardableResult
	func getSavedDataElseSaveNewRandom() async throws -> Data {
		if let value = try await getSavedRandomData() {
			return value
		} else {
			let new = Data.random()
			try await setRandomData(new)
			return new
		}
	}
}
