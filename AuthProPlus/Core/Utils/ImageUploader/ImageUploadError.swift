//
//  ImageUploadError.swift
//  AuthProPlus
//
//  Created by Stephan Dowless on 2/15/26.
//


/// Errors that can occur during image uploads.
///
/// Extend this enum with additional cases (e.g., unauthorized, networkUnavailable)
/// if you need more granular error handling.
enum ImageUploadError: Error {
    /// A generic failure occurred while uploading the image.
    case uploadFailed
    /// The provided image data could not be decoded into a UIImage for compression.
    case invalidImageData
    /// The image exceeds the maximum allowed size and could not be compressed within limits.
    case imageTooLarge
    /// Compression failed to produce valid data.
    case compressionFailed
}
