//
//  MediaPlayerView.swift
//  Wrlds
//
//  Created by Charles Romeo on 1/10/24.
//

import Foundation
import SwiftUI
import RealmSwift
import AVFoundation
import CoreEngine

class AudioPlayerManager: ObservableObject {
    @Published var audioPlayer: AVPlayer?
    @Published var isCurrentlyPlaying: Bool = false
    @Published var isCurrentlyPaused: Bool = false
    
    var isPlaying: Bool {
        audioPlayer?.timeControlStatus == .playing
    }
    
    func play(from url: URL) {
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
        isCurrentlyPlaying = true
        isCurrentlyPaused = false
    }
    
    func pause() {
        audioPlayer?.pause()
        isCurrentlyPlaying = false
        isCurrentlyPaused = true
    }
    
    func resume() {
        audioPlayer?.play()
        isCurrentlyPlaying = true
        isCurrentlyPaused = false
    }
    
    func stop() {
        audioPlayer?.pause()
        audioPlayer = nil
        isCurrentlyPlaying = false
        isCurrentlyPaused = false
    }
}

struct PlayerView: View {
    @StateObject private var audioPlayerManager = AudioPlayerManager()
    var song: Song  // Assuming Song has a downloadUrl property

    var body: some View {
        VStack {
            Text(song.title)  // Display the song title
            HStack {
                Button("Play") {
                    if let url = URL(string: song.downloadUrl) {
                        audioPlayerManager.play(from: url)
                    }
                }
                Button("Pause") {
                    audioPlayerManager.pause()
                }
                Button("Resume") {
                    audioPlayerManager.resume()
                }
                Button("Stop") {
                    audioPlayerManager.stop()
                }
            }
        }
    }
}

func addNewSong(title:String?=nil, artist:String?=nil, downloadUrl:String?=nil) {
    let newSong = Song()
    newSong.title = title ?? "UTBR00?"
    newSong.artist = artist ?? "under the bunk"
    newSong.downloadUrl = downloadUrl ?? "https://firebasestorage.googleapis.com/v0/b/ludi-software.appspot.com/o/songs%2Fback%20on%20my%20mind.m4a?alt=media&token=99d7a16b-a790-43d5-abc5-c2cde00f70c3"
    
    realm().safeWrite { r in
        r.create(Song.self, value: newSong, update: .all)
    }
    
    firebaseDatabase { db in
        db.child("songs").child(newSong.id).save(obj: newSong)
    }
}



struct MusicPlayerView: View {
    
    @StateObject private var audioPlayerManager = AudioPlayerManager()

    @ObservedResults(Song.self) var songs
    @State private var currentSong: Song?
    
    @State var showUploadSong: Bool = false
    
    
    var body: some View {
        VStack {
            
            Text("Under The Bunk Radio")
            // List of Songs
            List(songs, id: \.id) { song in
                Button(action: {
                    currentSong = song
                    if let url = URL(string: song.downloadUrl) {
                        audioPlayerManager.play(from: url)
                    }
                }) {
                    HStack {
                        Image(song.description) // Make sure this is a valid image
                            .resizable()
                            .frame(width: 50, height: 50)
                        VStack(alignment: .leading) {
                            Text(song.title)
                                .font(.headline)
                            Text(song.artist)
                                .font(.subheadline)
                        }
                    }
                }
            }
            
            VStack {
                Text("Now Playing").font(.title)
                Text(currentSong?.title ?? "").font(.headline)
                Text(currentSong?.artist ?? "").font(.subheadline)
            }
            
            HStack {
                Button(action: {
                    
                }) {
                    Image(systemName: "backward.fill")
                }
                Button(action: {
                    if self.audioPlayerManager.isPlaying {
                        audioPlayerManager.pause()
                    } else if self.audioPlayerManager.isCurrentlyPaused {
                        audioPlayerManager.resume()
                        
                    } else {
                        if let cs = currentSong {
                            if let url = URL(string: cs.downloadUrl) {
                                audioPlayerManager.play(from: url)
                            }
                        }
                        
                    }
                }) {
                    Image(systemName: self.audioPlayerManager.isCurrentlyPlaying ? "pause.fill" : "play.fill")
                }
                Button(action: {
                    audioPlayerManager.stop()
                    currentSong = nil
                }) {
                    Image(systemName: "stop.fill")
                }
                Button(action: { /* next action */ }) {
                    Image(systemName: "forward.fill")
                }
            }
            .padding()
            // Upload Song Button
            Button(action: {
                
                showUploadSong = true
                
            }) {
                Text("Upload Song")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(40)
            }
            .padding()
        }
        .background(
            RecordShape()
                .stroke(Color.black, lineWidth: 5)
                .frame(width: 1000, height: 1000)
                .background(Color.gray.opacity(0.0))
                .padding(50)
        )
        .sheet(isPresented: $showUploadSong) {
            UploadAudioView()
        }
        .refreshable {
            fetchSongs()
        }
        .onAppear() {
//            addNewSong()
            fetchSongs()
        }
    }
    
    func fetchSongs() {
        firebaseDatabase { db in
            db.child("songs").get { snapshot in
                let results = snapshot.toLudiObjects(Song.self, realm: songs.realm?.thaw())
                print("Songs Incoming: \(String(describing: results))")
            }
        }
    }
}
