//
//  ContentLoadingState.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/6/26.
//

import Foundation

/// Represents the loading lifecycle for fetching and presenting content.
///
/// Use this type to drive UI states like placeholders, empty views, error messaging,
/// and completed content. It's common to store this in a view model and switch on it
/// from SwiftUI to present the appropriate view.
///
/// Example:
/// ```swift
/// switch loadingState {
/// case .loading:
///     ProgressView()
/// case .empty:
///     ContentEmptyView()
/// case .error(let error):
///     ErrorView(error: error)
/// case .complete:
///     ContentListView()
/// }
/// ```
enum ContentLoadingState {
    /// A fetch is in progress. Show a progress indicator or skeleton view.
    case loading

    /// The request completed successfully but there is no data to display.
    case empty

    /// The request failed with an error. Attach the originating `Error` for context.
    case error(Error)

    /// Content loaded successfully and is ready to display.
    case complete
}

extension ContentLoadingState: Equatable {
    /// Equates two `ContentLoadingState` values.
    ///
    /// - Note: For `.error`, equality is determined by comparing `localizedDescription`.
    ///   This is a pragmatic approach for UI state comparisons but may not distinguish
    ///   between different error types with the same message. If you need more precise
    ///   semantics, consider wrapping errors in a domain-specific error type that
    ///   conforms to `Equatable`.
    static func == (lhs: ContentLoadingState, rhs: ContentLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.empty, .empty),
             (.complete, .complete):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
