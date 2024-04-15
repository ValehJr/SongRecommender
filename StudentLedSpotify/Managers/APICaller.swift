//
//  APICaller.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 07.04.24.
//

import Foundation
final class APICaller{
    static let shared = APICaller()

    private init() {}

    struct Constants{
        static let baseAPIURL = "https://api.spotify.com/v1"
    }

    enum APIError: Error{
        case failedToGetData
    }

    //MARK: - Search

    public func search(with query: String, completion: @escaping ((Result<[SearchResult],Error>)->Void)){
        createRequest(
            with: URL(string: "\(Constants.baseAPIURL)/search?limit=6&type=track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
            type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    var searchResults: [SearchResult] = []
                  print(searchResults)
                    searchResults.append(
                        contentsOf: result.tracks.items.compactMap({
                            SearchResult.track(model: $0)
                        }))
                    searchResults.append(
                        contentsOf: result.albums.items.compactMap({
                            SearchResult.album(model: $0)
                        }))
                    searchResults.append(
                        contentsOf: result.artists.items.compactMap({
                            SearchResult.artist(model: $0)
                        }))
                    completion(.success(searchResults))

                }catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }


    //MARK: - Private

    enum HTTPMethod: String{
        case GET
        case POST
        case DELETE
        case PUT
    }

    private func createRequest(with url: URL?,type: HTTPMethod,completion: @escaping ((URLRequest)->Void)) {
        AuthManger.shared.withValidToken { token in
            guard let apiURL = url else{
                print("Incorrect Url")
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            completion(request)
        }
    }
}
