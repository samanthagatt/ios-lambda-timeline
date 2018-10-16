//
//  Comment.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth

struct Comment: FirebaseConvertible, Equatable {
    
    static private let textKey = "text"
    static private let audioURLKey = "audioURL"
    static private let author = "author"
    static private let timestampKey = "timestamp"
    
    let text: String?
    let audioURL: URL?
    let author: Author
    let timestamp: Date
    
    init(text: String? = nil, audioURL: URL? = nil, author: Author, timestamp: Date = Date()) {
        self.text = text
        self.author = author
        self.timestamp = timestamp
        self.audioURL = audioURL
    }
    
    init?(dictionary: [String : Any]) {
        let text = dictionary[Comment.textKey] as? String
        var audioURL: URL? = nil
        if let audioURLString = dictionary[Comment.audioURLKey] as? String {
            audioURL = URL(string: audioURLString)
        }
        
        guard let authorDictionary = dictionary[Comment.author] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Comment.timestampKey] as? TimeInterval else { return nil }
        
        self.text = text
        self.audioURL = audioURL
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
    }
    
    var dictionaryRepresentation: [String: Any] {
        
        var dictionary: [String: Any]
        
        if let audioURLComment = audioURL {
            dictionary = [Comment.audioURLKey: audioURLComment.absoluteString,
                          Comment.author: author.dictionaryRepresentation,
                          Comment.timestampKey: timestamp.timeIntervalSince1970]
        } else {
            dictionary = [Comment.textKey: text ?? "[No text in comment]",
                          Comment.author: author.dictionaryRepresentation,
                          Comment.timestampKey: timestamp.timeIntervalSince1970]
        }
        
        return dictionary
    }
}
