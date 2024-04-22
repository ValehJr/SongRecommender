//
//  SongFetcher.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 22.04.24.
//

import Foundation
import UIKit
class SongFetcher {
  static let shared = SongFetcher()

  func fetchSongs(for query: String, completion: @escaping ([Song]?, Error?) -> Void) {
    let urlString = "http://127.0.0.1:8000/getrecommendation/?search_string=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    guard let url = URL(string: urlString) else {
      print("Invalid URL")
      completion(nil, nil)
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "accept")
    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error fetching data: \(error)")
        completion(nil, error)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Invalid HTTP response")
        completion(nil, nil)
        return
      }

      guard httpResponse.statusCode == 200 else {
        print("HTTP status code: \(httpResponse.statusCode)")
        completion(nil, nil)
        return
      }

      guard let data = data else {
        print("No data received")
        completion(nil, nil)
        return
      }

      do {
        let songs = try JSONDecoder().decode([Song].self, from: data)
        completion(songs, nil)
      } catch {
        print("Error decoding JSON: \(error)")
        completion(nil, error)
      }
    }.resume()
  }

  func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    let session = URLSession.shared
    let task = session.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print("Error loading image: \(error)")
        completion(nil)
        return
      }

      guard let data = data, let image = UIImage(data: data) else {
        print("Invalid image data")
        completion(nil)
        return
      }
      completion(image)
    }

    task.resume()
  }
}
