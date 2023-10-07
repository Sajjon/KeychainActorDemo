//
//  ApaTests.swift
//  ApaTests
//
//  Created by Alexander Cyon on 2023-10-06.
//

import XCTest
import KeychainAccess
@testable import DummyHost

let testKey = "testKey"

extension KeychainActor {
	
	func set(data: Data = .random()) async throws {
		try await KeychainActor.shared.authenticatedSetData(
			data,
			forKey: testKey,
			accessibility: .whenUnlocked,
			authenticationPolicy: .userPresence
		)
	}
	
	func doGet() async throws -> Data? {
		try await KeychainActor.shared.getDataWithAuth(forKey: testKey, authenticationPrompt: "test")
	}
	
	@discardableResult
	func doTest() async throws -> Data {
		if let value = try await doGet() {
			return value
		} else {
			let new = Data.random()
			try await set(data: new)
			return new
		}
	}
}

final class KeychainActorTests: XCTestCase {
	let sut = KeychainActor.shared
	
	@MainActor
	func test() async throws {
		try await sut.removeAllItems()
		let startValue = try await sut.doGet()
		XCTAssertNil(startValue)
	
		let tasks = try await manyTasks {
			try await self.sut.doTest()
		}
		
		var values = Set<Data>()
		for task in tasks {
			let value = try await task.value
			values.insert(value)
		}
		XCTAssertEqual(values.count, 1)
	}
	
}
