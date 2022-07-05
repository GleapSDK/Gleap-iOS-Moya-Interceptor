import Foundation
import Moya
import Gleap

/// Logs network activity (outgoing requests and incoming responses).
public final class GleapMoyaPlugin {
  public var data: GleapNetworkLoggerData
  
  /// Initializes a GleapMoyaPlugin.
  public init(data: GleapNetworkLoggerData = GleapNetworkLoggerData.shared()) {
    self.data = data
  }
}

// MARK: - PluginType
extension GleapMoyaPlugin: PluginType {
  public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
    switch result {
    case .success(let response):
      logNetworkResponse(response, target: target, isFromError: false)
    case let .failure(error):
      logNetworkError(error, target: target)
    }
  }
}

// MARK: - Logging
private extension GleapMoyaPlugin {
  func logNetworkResponse(_ response: Response, target: TargetType, isFromError: Bool) {
    guard let originalRequest = response.request else {
      return
    }
    
    let isoDateFormatter = ISO8601DateFormatter()
    let contentType = response.response?.headers["Content-Type"] ?? ""
    
    var request: [String: Any] = [
      "type": originalRequest.httpMethod ?? "--",
      "url": originalRequest.url?.absoluteString ?? "--",
      "date": isoDateFormatter.string(from: Date()),
      "success": true,
      "contentType": contentType
    ]
    
    // Request
    var requestContent: [String: Any] = [:]
    
    requestContent["headers"] = originalRequest.allHTTPHeaderFields
    
    // Set request payload
    if let bodyStream = originalRequest.httpBodyStream {
      requestContent["payload"] = bodyStream.description
    }
    if let body = originalRequest.httpBody {
      requestContent["payload"] = getPayload(data: body, contentType: originalRequest.allHTTPHeaderFields?["Content-Type"] ?? "")
    }
    
    // Append the request
    request["request"] = requestContent
    
    // Response
    var responseContent: [String: Any] = [:]
    
    // Set http status
    responseContent["status"] = response.response?.statusCode ?? 0
    
    // Set response http headers
    if let httpHeaders = response.response?.allHeaderFields {
      responseContent["headers"] = httpHeaders
    }
    
    responseContent["payload"] = getPayload(data: response.data, contentType: contentType)
    
    // Append the request
    request["response"] = responseContent
    
    // Append new request
    data.logRequest(request: request)
  }
  
  func logNetworkError(_ error: MoyaError, target: TargetType) {
    if let moyaResponse = error.response {
      return logNetworkResponse(moyaResponse, target: target, isFromError: true)
    }
  }
  
  func getPayload(data: Data?, contentType: String?) -> String {
    guard let data = data else {
      return "<no_content>"
    }
    
    if (data.count <= 0) {
      return "<no_content>"
    }
    
    let maxBodySize = 1024 * 500;
    if (isTextBased(contentType: contentType) && data.count < maxBodySize) {
      return String(decoding: data, as: UTF8.self)
    }
    
    return "<response_too_large>"
  }
  
  func isTextBased(contentType: String?) -> Bool {
    guard let contentType = contentType else {
      return false
    }
    if (contentType.contains("text/")) {
      return true;
    }
    if (contentType.contains("application/javascript")) {
      return true;
    }
    if (contentType.contains("application/xhtml+xml")) {
      return true;
    }
    if (contentType.contains("application/json")) {
      return true;
    }
    if (contentType.contains("application/xml")) {
      return true;
    }
    if (contentType.contains("application/x-www-form-urlencoded")) {
      return true;
    }
    if (contentType.contains("multipart/")) {
      return true;
    }
    return false;
  }
}

/// Logs network activity (outgoing requests and incoming responses).
public class GleapNetworkLoggerData {
  private var logs = [Any]()
  private let maxRequests = 15
  
  private static var sharedGleapNetworkLoggerData: GleapNetworkLoggerData = {
    return GleapNetworkLoggerData()
  }()
  
  public func logRequest(request: [String: Any]) {
    if (logs.count > maxRequests) {
      logs.remove(at: 0)
    }
    
    // Append the request
    logs.append(request)
    
    // Send the updated logs to Gleap
    Gleap.attachExternalData(["networkLogs": logs])
  }
  
  public class func shared() -> GleapNetworkLoggerData {
    return sharedGleapNetworkLoggerData
  }
}
