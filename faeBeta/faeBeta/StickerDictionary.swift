//
//  StickerDictionary.swift
//  quickChat
//
//  Created by User on 7/21/16.
//  Copyright © 2016 User. All rights reserved.
//

import Foundation

// this is data source of sticker image. In the dictionary, every key value pair is a set of sticker.
// the key is the name of image that in the bottom tab, value is array of name of sticker image.
// If you want to add a set of sticker, add name of its tab bar image in stickerIndex, and key value pair of the new set of sticker
// and add image to asset and done!
struct StickerInfoStrcut {
    
    // a dictionary storing all the sticker's name
    static var stickerDictionary = [
    "stickerHistory" : [],
    "stickerLike" : [],
    "faeGuy" :
        ["faeGuy1", "faeGuy2", "faeGuy3", "faeGuy4", "faeGuy5", "faeGuy6", "faeGuy7", "faeGuy8", "faeGuy9", "faeGuy10", "faeGuy11", "faeGuy12", "faeGuy13", "faeGuy14", "faeGuy15", "faeGuy16", "faeGuy17", "faeGuy18", "faeGuy19", "faeGuy20", "faeGuy21", "faeGuy22", "faeGuy23", "faeGuy24", "faeGuy25", "faeGuy26", "faeGuy27", "faeGuy28", "faeGuy29", "faeGuy30", "faeGuy31", "faeGuy32"],
    "faeSticker" :
        ["faeSticker1", "faeSticker2", "faeSticker3", "faeSticker4", "faeSticker5", "faeSticker6", "faeSticker7", "faeSticker8", "faeSticker9", "faeSticker10", "faeSticker11", "faeSticker12", "faeSticker13", "faeSticker14", "faeSticker15"],
    "steamBun" :
        ["steamBun1", "steamBun2", "steamBun3", "steamBun4", "steamBun5", "steamBun6", "steamBun7", "steamBun8", "steamBun9", "steamBun10", "steamBun11", "steamBun12", "steamBun13", "steamBun14", "steamBun15", "steamBun16", "steamBun17", "steamBun18", "steamBun19", "steamBun20", "steamBun21", "steamBun22", "steamBun23", "steamBun24", "steamBun25", "steamBun26", "steamBun27", "steamBun28", "steamBun29", "steamBun30", "steamBun31", "steamBun32"],
    "faeEmoji" :
        ["Happy", "LOL", "WarmSmile", "Hehe", "Smile", "CrySmile", "CoverSmile", "Love", "Huehue", "Beauty", "Wink", "LoveLove", "Slurp", "Kiss", "Bye", "WarmBye", "Heyy", "Sly", "Clapclap", "Cash", "Stare", "Blush", "WowStare", "Awkward", "Surprise", "Scared", "Opposite", "Unhappy", "Sigh", "welp", "Sad", "mmm", "Please", "Crying", "Tears", "holdtears", "Waterfall", "Shush", "Sick", "Dizzy", "DizzyCold", "Cold", "Gross", "Puke", "Sleepy", "Yawn", "Sleeping", "Snore", "Slap", "Pound", "Burnt", "Ignore", "Tantrum", "Scold", "Angry", "Mad", "Hmm", "Processing", "Hesitate", "Dontknow", "Wat", "Thinking", "Whistle", "Shhh", "Hmph", "Hmph2", "Speechless", "Uhh", "Boo", "Embarass", "Awkward2", "Shy", "Pick Nose", "Smirk", "Soldier", "TooCool", "Warrior", "CreepSun" ,"CreepMoon", "HappyDevil", "UnhappyDevil", "Doge", "Piggy" ,"Alpaca", "PoopFace", "Skull", "Sunglass", "SmilingSun", "Night", "Poop"]
]

    // the tabs
    static var stickerIndex = ["stickerHistory", "stickerLike", "faeEmoji","faeSticker","faeGuy", "steamBun"]

    // store how many pages does each album need
    static var pageNumDictionary = ["stickerMore": 0,
                             "stickerHistory": 0,
                             "stickerLike": 0,
                             "faeEmoji": 0,
                             "faeSticker": 0,
                             "faeGuy": 0,
                             "steamBun": 0]
}
