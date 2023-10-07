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
	
	@MainActor
	func test() async throws {
		try await sut.removeAllItems()
		let startValue = try await sut.getSavedRandomData()
		XCTAssertNil(startValue)
	
		let tasks = try await manyTasks {
			try await self.sut.getSavedDataElseSaveNewRandom()
		}
		
		var values = Set<Data>()
		for task in tasks {
			let value = try await task.value
			values.insert(value)
		}
		XCTAssertEqual(values.count, 1)
	}
	
}
