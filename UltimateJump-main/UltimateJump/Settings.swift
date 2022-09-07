//
//  Settings.swift
//  UltimateJump
//
//  Created by Yiwen Xu on 12/8/21.
//

import SpriteKit

enum PhysicsCategories {
    static let none: UInt32 = 0
    static let ballCategory: UInt32 = 0x1
    static let platformCategory: UInt32 = 0x1 << 1
    static let deerWithSanta: UInt32 = 0x1 << 2
    static let tweet: UInt32 = 0x1 << 3
}

enum ZPositions {
    static let background: CGFloat = -1
    static let platform: CGFloat = 0
    static let ball: CGFloat = 1
    static let stick: CGFloat = 2
    static let scoreLabel: CGFloat = 2
    static let logo: CGFloat = 2
    static let playButton: CGFloat = 2
}

enum Character {
    case char1
    case char2
    case char3
    case char4
    case char5
    case char6
    case char7
    case char8
    case char9
    case char10
    case char11
    case char12
}
