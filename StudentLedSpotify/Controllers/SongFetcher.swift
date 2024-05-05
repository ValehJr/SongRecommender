//
//  SongFetcher.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 09.03.24.
//

import Foundation
import UIKit

class SongFetcher {
  static let shared = SongFetcher()

  func fetchSongs(for query: String, completion: @escaping ([Song]?, Error?) -> Void) {
    let urlString = "http://127.0.0.1:8000/recommendations/songs/?song_query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

    guard let url = URL(string: urlString) else {
      print("Invalid URL")
      let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
      completion(nil, error)
      showAlert(message: "Invalid URL")
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "accept")

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error fetching data: \(error)")
        completion(nil, error)
        self.showAlert(message: error.localizedDescription)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Invalid HTTP response")
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
        completion(nil, error)
        self.showAlert(message: "Invalid HTTP response")
        return
      }

      guard httpResponse.statusCode == 200 else {
        let errorMessage = "HTTP status code: \(httpResponse.statusCode)"
        print(errorMessage)
        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        completion(nil, error)
        self.showAlert(message: errorMessage)
        return
      }

      guard let data = data else {
        print("No data received")
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
        completion(nil, error)
        self.showAlert(message: "No data received")
        return
      }

      do {
        let songs = try JSONDecoder().decode([Song].self, from: data)
        completion(songs, nil)
      } catch {
        let errorMessage = "No song was found"
        print(errorMessage)
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        completion(nil, error)
        self.showAlert(message: errorMessage)
      }
    }.resume()
  }

  func fetchPlaylistSongs(for query: String, completion: @escaping (Playlist?, Error?) -> Void) {
    let urlString = "http://127.0.0.1:8000/recommendations/playlists_v1/?playlist_url=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

    guard let url = URL(string: urlString) else {
      print("Invalid URL")
      let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
      completion(nil, error)
      self.showAlert(message: "Invalid URL")
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "accept")

    URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        print("Error fetching data: \(error)")
        completion(nil, error)
        self.showAlert(message: error.localizedDescription)
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        print("Invalid HTTP response")
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])
        completion(nil, error)
        self.showAlert(message: "Invalid HTTP response")
        return
      }

      guard httpResponse.statusCode == 200 else {
        let errorMessage = "HTTP status code: \(httpResponse.statusCode)"
        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        completion(nil, error)
        self.showAlert(message: errorMessage)
        return
      }

      guard let data = data else {
        print("No data received")
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
        completion(nil, error)
        self.showAlert(message: "No data received")
        return
      }

      do {
        let playlist = try JSONDecoder().decode(Playlist.self, from: data)
        completion(playlist, nil)
      } catch {
        let errorMessage = "Invalid Spotify URL"
        print(errorMessage)
        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        completion(nil, error)
        self.showAlert(message: errorMessage)
      }

    }.resume()
  }

  func showAlert(message: String) {
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
         let topViewController = windowScene.windows.first?.rootViewController {
        topViewController.present(alertController, animated: true, completion: nil)
      }
    }
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
