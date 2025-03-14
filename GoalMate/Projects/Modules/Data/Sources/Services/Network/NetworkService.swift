//
//  NetworkService.swift
//  Data
//
//  Created by Importants on 2/5/25.
//

import Foundation

public final class NetworkService: NSObject {
    private var config: NetworkConfigurable

    private var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 5
        configuration.timeoutIntervalForResource = 5
        return URLSession(configuration: configuration)
    }

    init(
        config: NetworkConfigurable
    ) {
        self.config = config
        super.init()
    }

    func asyncRequest<T: Decodable, E: ResponseRequestable>(
        with endpoint: E
    ) async throws -> T where E.Response == T {
        do {
            let urlRequest = try endpoint.urlRequest(with: config)
            log(request: urlRequest)
            let (data, response) = try await session.data(for: urlRequest)
            let value: T = try self.manageResponse(
                data: data,
                response: response,
                decoder: endpoint.responseDecoder
            )
            log(response: value)
            return value
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unKnownedError
        }
    }

    private func manageResponse<T: Decodable>(
        data: Data,
        response: URLResponse,
        decoder: ResponseDecoder
    ) throws -> T {
        guard let response = response as? HTTPURLResponse
        else { throw NetworkError.invaildResponse }
        
        switch response.statusCode {
        case 200...299:
            do {
                let decodingData: T = try decoder.decode(data)
                return decodingData
            } catch let error {
                print("Failed to decode type: \(T.self)")
                switch error as? DecodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context)")
                    print("Coding path: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("Key '\(key)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .valueNotFound(let value, let context):
                    print("Value '\(value)' not found: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type '\(type)' mismatch: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .none:
                    print("Error: \(error)")
                case .some(let error):
                    print("Error: \(error)")
                }
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON data: \(jsonString)")
                }
                throw NetworkError.invalidFormat
            }
        default:
            throw NetworkError.statusCodeError(code: response.statusCode)
        }
    }
}

private extension NetworkService {
    func log(request: URLRequest) {
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = URLComponents(string: urlAsString)
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        var output = """
      \(urlAsString)\n\n
      \(method) \(path)?\(query) HTTP/1.1 \n
      HOST: \(host)\n
      """
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            output += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            output += "\n \(String(data: body, encoding: .utf8) ?? "")"
        }
        print(output)
    }

    func log<T: Decodable>(response: T) {
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        print(response)
    }
}
