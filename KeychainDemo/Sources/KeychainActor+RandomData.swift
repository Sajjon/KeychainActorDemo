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
	
	func authGetSavedRandomData() async throws -> Data?  {
		try await KeychainActor.shared.getDataWithAuth(
			forKey: authRandomKey,
			authenticationPrompt: "auth random data"
		)
	}
	
	@discardableResult
	func authGetSavedDataElseSaveNewRandom() async throws -> Data {
		let key = authRandomKey
		if let value = try await authGetSavedRandomData() {
			print("AUTH Found existing value='\(value.hexEncodedString())' for '\(key)'")
			return value
		} else {
			let new = Data.random()
			print("AUTH Found no value for '\(key)', saving new: '\(new.hexEncodedString())'")
			try await KeychainActor.shared.setDataWithAuth(
				new,
				forKey: key,
				accessibility: .whenUnlockedThisDeviceOnly,
				authenticationPolicy: .biometryAny
			)
			return new
		}
	}
}

extension KeychainActor {
	
	func noAuthGetSavedRandomData() async throws -> Data? {
		try await KeychainActor.shared.getDataWithoutAuth(
			forKey: noAuthRandomKey
		)
	}
	
	@discardableResult
	func noAuthGetSavedDataElseSaveNewRandom() async throws -> Data {
		let key = noAuthRandomKey
		if let value = try await noAuthGetSavedRandomData() {
			print("NO AUTH Found existing value='\(value.hexEncodedString())' for '\(key)'")
			return value
		} else {
			let new = Data.random()
			print("NO AUTH Found no value for '\(key)', saving new: '\(new.hexEncodedString())'")
			try await KeychainActor.shared.setDataWithoutAuth(
				data: new,
				forKey: key,
				accessibility: .always
			)
			return new
		}
	}
}
