//
//  SongFetcher.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 15.04.24.
//

import Foundation

struct Song:Codable {
    let track_name: String
    let artist_name: String
    let track_id: String
    let similarity: Double
    let mp3_url: String?
    let spotify_url: String?
    let image_url: String
}
struct AnyCodable: Codable {
    let value: Any

    init<T: Encodable>(_ value: T?) {
        self.value = value ?? ()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let encodableValue = value as? Encodable {
            try container.encode(encodableValue)
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Value is not encodable"))
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else {
            throw DecodingError.typeMismatch(Any.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}
