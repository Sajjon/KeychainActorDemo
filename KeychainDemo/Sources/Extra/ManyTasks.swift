//
//  ManyTasks.swift
//  DummyHost
//
//  Created by Alexander Cyon on 2023-10-07.
//

import Foundation

public func manyTasks<T>(
	task: @Sendable @escaping () async throws -> T
) async rethrows -> [Task<T, any Error>] {
	
	let t0 = Task {
		try await task()
	}
	await Task.yield()
	await Task.yield()
	await Task.yield()
	let t1 = Task {
		try await task()
	}
	await Task.yield()
	await Task.yield()
	await Task.yield()
	let t2 = Task {
		try await task()
	}
	await Task.yield()
	_ = try await task()
	await Task.yield()
	let t3 = Task {
		try await task()
	}
	await Task.yield()
	_ = try await task()
	await Task.yield()
	let t4 = Task {
		try await task()
	}
	await Task.yield()
	_ = try await task()
	await Task.yield()
	let t5 = Task {
		try await task()
	}
	await Task.yield()
	_ = try await task()
	await Task.yield()
	let t6 = Task {
		try await task()
	}
	await Task.yield()
	_ = try await task()
	await Task.yield()
	let t7 = Task {
		try await task()
	}
	await Task.yield()
	_ = try await task()
	await Task.yield()
	let t8 = Task {
		try await task()
	}
	await Task.yield()
	_ = try await task()
	await Task.yield()
	let t9 = Task {
		try await task()
	}
	await Task.yield()
	
	return [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9]
}
