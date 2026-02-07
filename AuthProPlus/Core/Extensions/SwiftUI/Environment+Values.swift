//
//  LoadingKey.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//


import SwiftUI

private struct LoadingKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

private struct AuthDataStoreKey: EnvironmentKey {
    static let defaultValue: AuthDataStore = AuthDataStore()
}

extension EnvironmentValues {
    var isLoading: Binding<Bool> {
        get { self[LoadingKey.self] }
        set { self[LoadingKey.self] = newValue }
    }
    
    var authDataStore: AuthDataStore {
        get { self[AuthDataStoreKey.self] }
        set { self[AuthDataStoreKey.self] = newValue }
    }
}
