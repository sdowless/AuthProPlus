//
//  SupabaseRegistrationValidationService.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/14/26.
//

import Foundation
import Supabase
/// Supabase-backed implementation of `RegistrationValidationProtocol`.
///
/// This service checks uniqueness of email and username by querying your Supabase `users` table.
/// Adjust table/column names to match your schema.
struct SupabaseRegistrationValidationService: RegistrationValidationProtocol {
    private let client: SupabaseClient
    private let tableName: String

    init(client: SupabaseClient, tableName: String = "users") {
        self.client = client
        self.tableName = tableName
    }

    func validateEmail(_ email: String) async throws -> InputValidationState {
        let isValid = try await checkUniqueness(forKey: "email", value: email)
        guard isValid else { throw RegistrationValidationError.emailValidationFailed }
        return isValid ? .validated : .invalid
    }

    func validateUsername(_ username: String) async throws -> InputValidationState {
        let isValid = try await checkUniqueness(forKey: "username", value: username)
        guard isValid else { throw RegistrationValidationError.usernameValidationFailed }
        return isValid ? .validated : .invalid
    }

    private func checkUniqueness(forKey key: String, value: String) async throws -> Bool {

        let rows: [AuthProPlusUser] = try await client
            .from(tableName)
            .select()
            .eq(key, value: value)
            .limit(1)
            .execute()
            .value
        
        return rows.isEmpty
    }
}

