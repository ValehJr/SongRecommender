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
    let urlString = "http://127.0.0.1:8000/getsongrecommendations/?song_query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
    guard let url = URL(string: urlString) else {
      print("Invalid URL")
      completion(nil, nil)
      return
    }
    URLSession.shared.dataTask(with: url) { data, response, error in
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

  func fetchPlaylistSongs(for query: String, completion: @escaping (Playlist?,Error?) -> Void) {
    let urlString = "http://127.0.0.1:8000/getplaylistrecommendations/?playlist_url=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

    guard let url = URL(string: urlString) else {
      print("Invalid url")
      completion(nil,nil)
      return
    }

    URLSession.shared.dataTask(with: url){ data, response, error in
      if let error = error {
        print("Error fetching data:\(error.localizedDescription)")
        completion(nil,nil)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Invalid HTTP response")
        completion(nil,nil)
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
        let playlist = try JSONDecoder().decode(Playlist.self, from: data)
        completion(playlist, nil)
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
