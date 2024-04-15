//
//  AuthManager.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 07.04.24.
//

import Foundation

final class AuthManger {
    static let shared = AuthManger()

    struct Constants {
        static let clientId = "76a7825f69fb450f99d1081c63f0ed70"
        static let clientSecret = "9b0ff905c1bb4741924758a915a51856"
        static let tokenAPIURL = "https://accounts.spotify.com/api/token"
        static let redirectUri = "https://www.google.com"
        static let scope = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }

    private init () {}

    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientId)&scope=\(Constants.scope)&redirect_uri=\(Constants.redirectUri)&show_dialog=TRUE"
        return URL(string: string)
    }

    var isSignedIn: Bool{
        return accessToken != nil
    }

    private var refreshingToken: Bool = false

    private var accessToken: String?{
        return UserDefaults.standard.string(forKey: "access_token")
    }

    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    private var tokenExpirationDate: Date?{
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else{
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate

    }

    public func getCodeForToken(code:String, completion: @escaping ((Bool)->Void)){
        guard let url = URL(string: Constants.tokenAPIURL) else{
            return
        }

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectUri)
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)

        let basicToken = Constants.clientId+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            completion(false)
            return
        }

        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")


        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data,error == nil else{
                completion(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result:result)
                completion(true)
            }
            catch{
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
    }

    private var onRefreshBlock = [((String)->Void)]()
    public func withValidToken(completion: @escaping ((String)->Void)){
        guard !refreshingToken else{
            onRefreshBlock.append(completion)
            return
        }

        if shouldRefreshToken{
            shouldRefreshIfNeeded {[weak self] success in
                if let token = self?.accessToken, success{
                    completion(token)
                }
            }
        } else if let token = accessToken{
            completion(token)
        }
    }

    public func shouldRefreshIfNeeded(completion: ((Bool)-> Void)?){
        guard !refreshingToken else{
            return
        }

        guard shouldRefreshToken else{
            completion?(true)
            return
        }

        guard let refreshToken = self.refreshToken else {
            return
        }

        //Refresh Token
        guard let url = URL(string: Constants.tokenAPIURL) else{
            return
        }

        refreshingToken = true

        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)

        let basicToken = Constants.clientId+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            completion?(false)
            return
        }

        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")


        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data,error == nil else{
                completion?(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlock.forEach { $0(result.access_token)}
                self?.onRefreshBlock.removeAll()
                self?.cacheToken(result:result)
                completion?(true)
            }
            catch{
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }

    private func cacheToken(result: AuthResponse){

        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")

    }

    public func signOut(complection: (Bool)-> Void){
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expirationDate")
        complection(true)
    }

}
