//
//  NetworkError.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/22/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

internal func LocalizedString(_ key: String, comment: String?) -> String {
    return NSLocalizedString(key, bundle: Bundle.main, comment: comment ?? "")
}

import Foundation

public enum NetworkError: Error, CustomStringConvertible {
    /// Unknown or not supported error.
    case unknown

    /// Not connected to the internet.
    case notConnectedToInternet

    /// International data roaming turned off.
    case internationalRoamingOff

    /// Cannot reach the server.
    case notReachedServer

    /// Connection is lost.
    case connectionLost

    /// Incorrect data returned from the server.
    case incorrectDataReturned
	
	/// Request returned Unauthorized
	case unauthorized

    internal init(error: NSError) {
        if error.domain == NSURLErrorDomain {
            switch error.code {
            case NSURLErrorUnknown:
                self = .unknown
            case NSURLErrorCancelled:
                self = .unknown // Cancellation is not used in this project.
            case NSURLErrorBadURL:
                self = .incorrectDataReturned // Because it is caused by a bad URL returned in a JSON response from the server.
            case NSURLErrorTimedOut:
                self = .notReachedServer
            case NSURLErrorUnsupportedURL:
                self = .incorrectDataReturned
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                self = .notReachedServer
            case NSURLErrorDataLengthExceedsMaximum:
                self = .incorrectDataReturned
            case NSURLErrorNetworkConnectionLost:
                self = .connectionLost
            case NSURLErrorDNSLookupFailed:
                self = .notReachedServer
            case NSURLErrorHTTPTooManyRedirects:
                self = .unknown
            case NSURLErrorResourceUnavailable:
                self = .incorrectDataReturned
            case NSURLErrorNotConnectedToInternet:
                self = .notConnectedToInternet
            case NSURLErrorRedirectToNonExistentLocation, NSURLErrorBadServerResponse:
                self = .incorrectDataReturned
            case NSURLErrorUserCancelledAuthentication, NSURLErrorUserAuthenticationRequired:
                self = .unauthorized
            case NSURLErrorZeroByteResource, NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData:
                self = .incorrectDataReturned
            case NSURLErrorCannotParseResponse:
                self = .incorrectDataReturned
            case NSURLErrorInternationalRoamingOff:
                self = .internationalRoamingOff
            case NSURLErrorCallIsActive, NSURLErrorDataNotAllowed, NSURLErrorRequestBodyStreamExhausted:
                self = .unknown
            case NSURLErrorFileDoesNotExist, NSURLErrorFileIsDirectory:
                self = .incorrectDataReturned
            case
            NSURLErrorNoPermissionsToReadFile,
            NSURLErrorSecureConnectionFailed,
            NSURLErrorServerCertificateHasBadDate,
            NSURLErrorServerCertificateUntrusted,
            NSURLErrorServerCertificateHasUnknownRoot,
            NSURLErrorServerCertificateNotYetValid,
            NSURLErrorClientCertificateRejected,
            NSURLErrorClientCertificateRequired,
            NSURLErrorCannotLoadFromNetwork,
            NSURLErrorCannotCreateFile,
            NSURLErrorCannotOpenFile,
            NSURLErrorCannotCloseFile,
            NSURLErrorCannotWriteToFile,
            NSURLErrorCannotRemoveFile,
            NSURLErrorCannotMoveFile,
            NSURLErrorDownloadDecodingFailedMidStream,
            NSURLErrorDownloadDecodingFailedToComplete:
                self = .unknown
            default:
                self = .unknown
            }
        }
        else {
            self = .unknown
        }
    }

    public var description: String {
        let text: String
        switch self {
        case .unknown:
            text = LocalizedString("NetworkError_Unknown", comment: "Error description")
        case .notConnectedToInternet:
            text = LocalizedString("NetworkError_NotConnectedToInternet", comment: "Error description")
        case .internationalRoamingOff:
            text = LocalizedString("NetworkError_InternationalRoamingOff", comment: "Error description")
        case .notReachedServer:
            text = LocalizedString("NetworkError_NotReachedServer", comment: "Error description")
        case .connectionLost:
            text = LocalizedString("NetworkError_ConnectionLost", comment: "Error description")
        case .incorrectDataReturned:
            text = LocalizedString("NetworkError_IncorrectDataReturned", comment: "Error description")
		case .unauthorized:
			text = LocalizedString("NetworkError_Unauthorized", comment: "Error description")
        }
        return text
    }
}
