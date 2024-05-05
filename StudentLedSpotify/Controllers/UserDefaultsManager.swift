//
//  UserDefaultsSave.swift
//  StudentLedSpotify
//
//  Created by Valeh Ismayilov on 03.05.24.
//

import Foundation

class UserDefaultsManager {
   static let shared = UserDefaultsManager()
   var song:[Song] = []
   func saveSongToUserDefaults(song:Song) {
	  do {
		 let encoder = JSONEncoder()
		 let songData = try encoder.encode(song)
		 var songsArray = UserDefaults.standard.array(forKey: "songs") as? [Data] ?? []
		 songsArray.append(songData)
		 UserDefaults.standard.set(songsArray, forKey: "songs")
	  } catch {
		 print("Error encoding song data:", error)
	  }
   }

   func deleteSongFromUserDefaults(song:Song) {
	  var songsArray = UserDefaults.standard.array(forKey: "songs") as? [Data] ?? []
	  songsArray = songsArray.filter { data in
		 do {
			let decoder = JSONDecoder()
			let savedSong = try decoder.decode(Song.self, from: data)
			return savedSong.track_id != song.track_id
		 } catch {
			print("Error decoding song data:", error)
			return true
		 }
	  }

	  UserDefaults.standard.set(songsArray, forKey: "songs")
   }

   func isSongSaved(song:Song) -> Bool {
	  guard let songsData = UserDefaults.standard.array(forKey: "songs") as? [Data] else {
		 return false
	  }
	  for songData in songsData {
		 do {
			let decoder = JSONDecoder()
			let savedSong = try decoder.decode(Song.self, from: songData)
			if savedSong == song {
			   return true
			}
		 } catch {
			print("Error decoding song data:", error)
		 }
	  }
	  return false
   }
}
