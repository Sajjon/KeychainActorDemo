//
//  ApaTests.swift
//  ApaTests
//
//  Created by Alexander Cyon on 2023-10-06.
//

import XCTest
import KeychainAccess

let testKey = "testKey"
extension KeychainActor {
	
	func doTest() async throws -> Data {
		if let value = try await KeychainActor.shared.getDataWithoutAuth(forKey: testKey) {
			return value
		} else {
			let new = Data.random(byteCount: 16)
			try await KeychainActor.shared.setDataWithoutAuth(
				.init(
					data: new,
					key: testKey,
					iCloudSyncEnabled: false,
					accessibility: .always,
					label: nil, comment: nil
				)
			)
			return new
		}
	}
}

final class ApaTests: XCTestCase {
	let sut = KeychainActor.shared
	
	func test() async throws {
		let t0 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let t1 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let t2 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let t3 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let t4 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let t5 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let t6 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let t7 = Task {
			try await sut.doTest()
		}
		await Task.yield()
		
		let t8 = Task {
			try await sut.doTest()
		}
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
