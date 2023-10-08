//
//  KeychainAttributes.swift
//  KeychainDemoTests
//
//  Created by Alexander Cyon on 2023-10-07.
//

import Foundation
import KeychainAccess

protocol _KeychainAttributes {
	var label: String? { get }
	var comment: String? { get }
	var isSynchronizable: Bool { get }
	var accessibility: Accessibility? { get }
	var maybeAuthenticationPolicy: AuthenticationPolicy? { get }
}


extension KeychainAccess.Accessibility: @unchecked Sendable {}
extension KeychainAccess.AuthenticationPolicy: @unchecked Sendable {}



extension Keychain {
	
	public typealias Key = String
	public typealias Label = String
	public typealias Comment = String
	public typealias AuthenticationPrompt = String
	
	
	struct AttributesWithAuth: _KeychainAttributes {
		let label: String?
		let comment: String?
		let isSynchronizable: Bool
		let accessibility: Accessibility?
		let authenticationPolicy: AuthenticationPolicy
		
		init(
			label: String? = nil,
			comment: String? = nil,
			isSynchronizable: Bool = false,
			accessibility: Accessibility,
			authenticationPolicy: AuthenticationPolicy
		) {
			self.label = label
			self.comment = comment
			self.isSynchronizable = isSynchronizable
			self.accessibility = accessibility
			self.authenticationPolicy = authenticationPolicy
		}
		
		var maybeAuthenticationPolicy: AuthenticationPolicy? { authenticationPolicy }
	}
	struct AttributesWithoutAuth: _KeychainAttributes {
		let label: String?
		let comment: String?
		let isSynchronizable: Bool
		let accessibility: Accessibility?
		
		init(
			label: String? = nil,
			comment: String? = nil,
			isSynchronizable: Bool = false,
			accessibility: Accessibility? = nil
		) {
			self.label = label
			self.comment = comment
			self.isSynchronizable = isSynchronizable
			self.accessibility = accessibility
		}
		
		var maybeAuthenticationPolicy: AuthenticationPolicy? { nil }
	}
	
	enum Modifier {
		case attributes(_KeychainAttributes)
		case authPrompt(AuthenticationPrompt)
		init?(attributes: _KeychainAttributes?) {
			guard let attributes else { return nil }
			self = .attributes(attributes)
		}
		init?(authPrompt: AuthenticationPrompt?) {
			guard let authPrompt else { return nil }
			self = .authPrompt(authPrompt)
		}
	}
	
	func withAttributes(
		label: String?,
		comment: String?,
		isSynchronizable: Bool?,
		accessibility: Accessibility?,
		authenticationPolicy: AuthenticationPolicy?
	) -> Keychain {
		assert(!(authenticationPolicy != nil && accessibility == nil), "Specifying `authenticationPolicy` has no effect if you are not also specifying `accessibility`.")
		var keychain = self
		if let label {
			keychain = keychain.label(label)
		}
		if let comment {
			keychain = keychain.comment(comment)
		}
		if let isSynchronizable {
			keychain = synchronizable(isSynchronizable)
		}
		if let accessibility {
			if let authenticationPolicy {
				keychain = keychain.accessibility(accessibility, authenticationPolicy: authenticationPolicy)
			} else {
				keychain = keychain.accessibility(accessibility)
			}
		}
		return keychain
	}
	
	func with(
		attributes: _KeychainAttributes?
	) -> Keychain {
		withAttributes(
			label: attributes?.label,
			comment: attributes?.comment,
			isSynchronizable: attributes?.isSynchronizable,
			accessibility: attributes?.accessibility,
			authenticationPolicy: attributes?.maybeAuthenticationPolicy
		)
	}
	
	func modifier(_ modifier: Modifier?) -> Keychain {
		guard let modifier else { return self }
		switch modifier {
		case let .attributes(attributes):
			return with(attributes: attributes)
		case let .authPrompt(authPrompt):
			return authenticationPrompt(authPrompt)
		}
	}
}
