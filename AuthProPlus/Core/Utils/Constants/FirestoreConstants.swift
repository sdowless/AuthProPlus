//
//  FirestoreConstants.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation
import Firebase

/// Centralized Firestore references used by AuthProPlus.
///
/// Use this type as a single source of truth for collection/document paths to avoid
/// stringly-typed references scattered throughout the codebase. If you maintain
/// separate environments (e.g., staging/production), consider injecting a configured
/// `Firestore` instance rather than using the global singleton.
struct FirestoreConstants {
    /// Root Firestore instance.
    private static let Root = Firestore.firestore()
    
    /// Collection reference for user documents.
    ///
    /// Each document's ID corresponds to the Firebase Auth UID of the user.
    static let UserCollection = Root.collection("users")
}
