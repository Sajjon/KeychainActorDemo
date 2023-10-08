//
//  ApaTests.swift
//  ApaTests
//
//  Created by Alexander Cyon on 2023-10-06.
//

import XCTest
import KeychainAccess
@testable import DummyHost

final class KeychainActorTests: XCTestCase {
	let sut = KeychainActor.shared
	
	func testNoAuth() async throws {
		for _ in 0..<100 {
			try await onceNoAuthTest()
		}
	}
	
	func testAuth() async throws {
//		for _ in 0..<100 {
			try await onceAuthTest()
//		}
	}
	
	func onceNoAuthTest() async throws {
		try await sut.removeAllItems()
		let startValue = try await sut.noAuthGetSavedRandomData()
		XCTAssertNil(startValue)
	
		let values = try await valuesFromManyTasks {
			try await self.sut.noAuthGetSavedDataElseSaveNewRandom()
		}
		XCTAssertEqual(values.count, 1)
	}
	
	func onceAuthTest() async throws {
		try await sut.removeAllItems()
		let startValue = try await sut.authGetSavedRandomData()
		XCTAssertNil(startValue)
	
		let values = try await valuesFromManyTasks {
			try await self.sut.authGetSavedDataElseSaveNewRandom()
		}
		XCTAssertEqual(values.count, 1)
	}
}
