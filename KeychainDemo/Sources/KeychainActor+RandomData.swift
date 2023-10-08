//
//  KeychainActor+RandomData.swift
//  DummyHost
//
//  Created by Alexander Cyon on 2023-10-07.
//

import Foundation
import KeychainAccess

let authRandomKey = "authRandomDataKey"
let noAuthRandomKey = "noAuthRandomDataKey"

extension KeychainActor {
		
	@MainActor
	@discardableResult
	func authGetSavedDataElseSaveNewRandom() async throws -> Data {
		try await KeychainActor.shared.getDataWithAuthIfPresent(
			forKey: authRandomKey,
			with: .init(accessibility: .whenUnlockedThisDeviceOnly, authenticationPolicy: .biometryAny),
			elseSetTo: .random(),
			authenticationPrompt: "Keychain demo"
		).data
		
	}
}

extension KeychainActor {
	
	@MainActor
	@discardableResult
	func noAuthGetSavedDataElseSaveNewRandom() async throws -> Data {
		try await KeychainActor.shared.getDataWithoutAuthIfPresent(
			forKey: noAuthRandomKey,
			with: Keychain.AttributesWithoutAuth(),
			elseSetTo: .random()
		).data
	}
}
