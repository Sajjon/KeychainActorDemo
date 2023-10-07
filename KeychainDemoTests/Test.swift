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
		
		let t0 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		await Task.yield()
		await Task.yield()
		let t1 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		await Task.yield()
		await Task.yield()
		let t2 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		try await sut.doTest()
		await Task.yield()
		let t3 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		try await sut.doTest()
		await Task.yield()
		let t4 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		try await sut.doTest()
		await Task.yield()
		let t5 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		try await sut.doTest()
		await Task.yield()
		let t6 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		try await sut.doTest()
		await Task.yield()
		let t7 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		try await sut.doTest()
		await Task.yield()
		let t8 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		try await sut.doTest()
		await Task.yield()
		let t9 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let tasks = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9]
		var values = Set<Data>()
		for task in tasks {
			let value = try await task.value
			values.insert(value)
		}
		XCTAssertEqual(values.count, 1)
	}
	
}
