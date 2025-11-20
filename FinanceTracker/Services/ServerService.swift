import Foundation
import UIKit

class ServerService {
    static let shared = ServerService()
    
    private let tokenKey = "serverToken"
    private let linkKey = "serverLink"
    private let baseAddress = "https://gtappinfo.site/ios-financetracker-personalloans/server.php"
    private let parameter = "Bs2675kDjkb5Ga"
    
    private init() {}
    
    var savedToken: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }
    
    var savedLink: String? {
        UserDefaults.standard.string(forKey: linkKey)
    }
    
    func hasToken() -> Bool {
        return savedToken != nil && savedLink != nil
    }
    
    func fetchServerData(completion: @escaping (Result<(token: String, link: String), Error>) -> Void) {
        guard let requestAddress = buildRequestAddress() else {
            completion(.failure(ServerError.invalidAddress))
            return
        }
        
        var request = URLRequest(url: requestAddress)
        request.httpMethod = "GET"
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data,
                  let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(ServerError.invalidResponse))
                return
            }
            
            if responseString.contains("#") {
                let components = responseString.components(separatedBy: "#")
                if components.count >= 2 {
                    let token = components[0]
                    let link = components[1]
                    
                    UserDefaults.standard.set(token, forKey: self.tokenKey)
                    UserDefaults.standard.set(link, forKey: self.linkKey)
                    
                    completion(.success((token: token, link: link)))
                } else {
                    completion(.failure(ServerError.invalidFormat))
                }
            } else {
                completion(.failure(ServerError.noSeparator))
            }
        }.resume()
    }
    
    private func buildRequestAddress() -> URL? {
        var components = URLComponents(string: baseAddress)
        var queryItems: [URLQueryItem] = []
        
        queryItems.append(URLQueryItem(name: "p", value: parameter))
        queryItems.append(URLQueryItem(name: "os", value: getOSVersion()))
        queryItems.append(URLQueryItem(name: "lng", value: getLanguageCode()))
        queryItems.append(URLQueryItem(name: "devicemodel", value: getDeviceModel()))
        queryItems.append(URLQueryItem(name: "country", value: getCountryCode()))
        components?.queryItems = queryItems
        
        return components?.url
    }
    
    private func getOSVersion() -> String {
        let version = UIDevice.current.systemVersion
        return "iOS\(version)"
    }
    
    private func getLanguageCode() -> String {
        let preferredLanguage = Locale.preferredLanguages.first ?? "en"
        let locale = Locale(identifier: preferredLanguage)
        return locale.language.languageCode?.identifier ?? "en"
    }
    
    private func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
        
        if let code = modelCode {
            return code
        }
        return "unknown"
    }
    
    private func getCountryCode() -> String {
        let locale = Locale.current
        return locale.region?.identifier ?? "US"
    }
}

enum ServerError: LocalizedError {
    case invalidAddress
    case invalidResponse
    case invalidFormat
    case noSeparator
    
    var errorDescription: String? {
        switch self {
        case .invalidAddress:
            return "Invalid server address"
        case .invalidResponse:
            return "Invalid server response"
        case .invalidFormat:
            return "Invalid response format"
        case .noSeparator:
            return "Response does not contain separator"
        }
    }
}

