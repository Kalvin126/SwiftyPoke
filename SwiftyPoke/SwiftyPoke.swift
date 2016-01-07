//
//  SwiftyPoke.swift
//  SwiftyPoke
//
//  Created by Kalvin Loc on 12/7/15.
//  Copyright © 2015 redpanda. All rights reserved.
//

import Foundation

public class SwiftyPoke {
    private var verbose = false

    private static let shared = SwiftyPoke()
    private let APIURL = "http://pokeapi.co"

    // Caches
    private var pokémon         = [Int : Pokémon]()
    private var types           = [Int : Type]()
    private var moves           = [Int : Move]()
    private var abilities       = [Int : Ability]()
    private var eggGroups       = [Int : EggGroup]()
    private var descriptions    = [Int : Description]()
    private var sprites         = [Int : Sprite]()
    private var games           = [Int : Game]()

    init() {
    }

    private func getResponseWithURI(uri: String, completion: (response: Dictionary<String, AnyObject>) -> Void) {
        let fullURL = NSURL(string: APIURL + uri)!
        if verbose { print("Querying URL: \(fullURL)") }

        let requestStart:NSDate = NSDate()
        NSURLSession.sharedSession().dataTaskWithURL(fullURL) {
            (data, response, error) -> Void in
            let interval:NSTimeInterval = NSDate().timeIntervalSinceDate(requestStart)
            if self.verbose { print("Response returned in \(interval) seconds") }

            if error != nil {
                print(error)
                return
            }

            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! Dictionary<String, AnyObject>
                dispatch_async(dispatch_get_main_queue()) {
                    completion(response: json)
                }

            } catch {
                if self.verbose { print("\(error)")}
            }
        }.resume()
    }

    private func getDataWithURI(uri: String, completion: ((data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: APIURL + uri)!) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                completion(data: data, response: response, error: error)
            }
            }.resume()
    }

    public static func fillNationalPokédex(completion: (success: Bool) -> Void) {
        SwiftyPoke.shared.getResponseWithURI("/api/v1/pokedex/1/") { (response: Dictionary<String, AnyObject>) -> Void in
            let rawPokémonData = response["pokemon"] as! NSArray

            for p in rawPokémonData {
                let pokémon = Pokémon(info: p as! Dictionary<String, AnyObject>)

                SwiftyPoke.shared.pokémon[pokémon.nationalID] = pokémon
            }

            completion(success: true)
        }
    }

    // MARK: Resource fetch funcs

    private func checkForCache(resource: Any) -> Any? {
        switch resource {
        case is Pokémon:
            let pokémon = resource as! Pokémon
            if self.pokémon[pokémon.nationalID]!.created != nil {
                return self.pokémon[pokémon.nationalID]
            }

        case is Type:
            let type = resource as! Type
            if let retType = types[type.id] {
                return retType
            }

        case is Move:
            let move = resource as! Move
            if let retMove = moves[move.id] {
                return retMove
            }

        case is Ability:
            let ability = resource as! Ability
            if let retAbility = abilities[ability.id] {
                return retAbility
            }

        case is EggGroup:
            let eggGroup = resource as! EggGroup
            if let retEggGroup = eggGroups[eggGroup.id] {
                return retEggGroup
            }

        case is Description:
            let desc = resource as! Description
            if let retDesc = descriptions[desc.id] {
                return retDesc
            }

        case is Sprite:
            let sprite = resource as! Sprite
            if let retSprite = sprites[sprite.id] {
                return retSprite
            }

        case is Game:
            let game = resource as! Game
            if let retGame = games[game.id] {
                return retGame
            }

        default:
            return nil
        }

        return nil
    }

    public static func getPokédex() -> [Pokémon] {
        return Array(SwiftyPoke.shared.pokémon.values).sort { $0.nationalID < $1.nationalID }
    }

    public static func getPokémon(pokémon: Pokémon, completion: (pokémon: Pokémon) -> Void) {
        if let cached = SwiftyPoke.shared.checkForCache(pokémon) as? Pokémon {
            completion(pokémon: cached)
            return
        }

        // pokedex/1/ returns URIs without leading /
        SwiftyPoke.shared.getResponseWithURI("/" + pokémon.resourceURI) { (response: Dictionary<String, AnyObject>) -> Void in
            let retPoké = Pokémon(info: response)
            SwiftyPoke.shared.pokémon[pokémon.nationalID] = retPoké

            completion(pokémon: retPoké)
        }
    }

    public static func getType(type: Type, completion: (type: Type) -> Void) {
        if let cached = SwiftyPoke.shared.checkForCache(type) as? Type {
            completion(type: cached)
            return
        }

        SwiftyPoke.shared.getResponseWithURI(type.resourceURI) { (response: Dictionary<String, AnyObject>) -> Void in
            let retType = Type(info: response)
            SwiftyPoke.shared.types[retType.id] = retType    // cache fetched resource

            completion(type: retType)
        }
    }

    public static func getMove(move: Move, completion: (move: Move) -> Void) {
        if let cached = SwiftyPoke.shared.checkForCache(move) as? Move {
            completion(move: cached)
            return
        }

        SwiftyPoke.shared.getResponseWithURI(move.resourceURI) { (response: Dictionary<String, AnyObject>) -> Void in
            let retMove = Move(info: response)
            SwiftyPoke.shared.moves[retMove.id] = retMove

            completion(move: retMove)
        }
    }

    public static func getAbility(ability: Ability, completion: (ability: Ability) -> Void) {
        if let cached = SwiftyPoke.shared.checkForCache(ability) as? Ability {
            completion(ability: cached)
            return
        }

        SwiftyPoke.shared.getResponseWithURI(ability.resourceURI) { (response: Dictionary<String, AnyObject>) -> Void in
            let retAbility = Ability(info: response)
            SwiftyPoke.shared.abilities[retAbility.id] = retAbility

            completion(ability: retAbility)
        }
    }

    public static func getEggGroup(eggGroup: EggGroup, completion: (eggGroup: EggGroup) -> Void) {
        if let cached = SwiftyPoke.shared.checkForCache(eggGroup) as? EggGroup {
            completion(eggGroup: cached)
            return
        }

        SwiftyPoke.shared.getResponseWithURI(eggGroup.resourceURI) { (response: Dictionary<String, AnyObject>) -> Void in
            let retEggGroup = EggGroup(info: response)
            SwiftyPoke.shared.eggGroups[retEggGroup.id] = retEggGroup

            completion(eggGroup: retEggGroup)
        }
    }

    public static func getDescription(description: Description, completion: (description: Description) -> Void) {
        if let cached = SwiftyPoke.shared.checkForCache(description) as? Description {
            completion(description: cached)
            return
        }

        SwiftyPoke.shared.getResponseWithURI(description.resourceURI) { (response: Dictionary<String, AnyObject>) -> Void in
            let retDescription = Description(info: response)
            SwiftyPoke.shared.descriptions[retDescription.id] = retDescription

            completion(description: retDescription)
        }
    }

    public static func getSprite(sprite: Sprite, completion: (sprite: Sprite) -> Void) {
        if let cached = SwiftyPoke.shared.checkForCache(sprite) as? Sprite {  // check local cache
            completion(sprite: cached)
            return
        }

        SwiftyPoke.shared.getResponseWithURI(sprite.resourceURI) { (response) -> Void in
            var fetchedSprite = Sprite(info: response)
            fetchedSprite.pokémon = sprite.pokémon

            // fetch spriteImg as well
            SwiftyPoke.shared.getDataWithURI(fetchedSprite.imageURI!) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else {
                        if SwiftyPoke.shared.verbose { print("Failed to retrieve: \(sprite.imageURI!)") }
                        return
                    }

                    fetchedSprite.image = data
                    SwiftyPoke.shared.sprites[sprite.id] = fetchedSprite
                    completion(sprite: fetchedSprite)
                }
            }
        }
    }

    public static func getGame(game: Game, completion: (game: Game) -> Void) {
        if let cached = SwiftyPoke.shared.checkForCache(game) as? Game {
            completion(game: cached)
            return
        }

        SwiftyPoke.shared.getResponseWithURI(game.resourceURI) { (response: Dictionary<String, AnyObject>) -> Void in
            let retGame = Game(info: response)
            SwiftyPoke.shared.games[retGame.id] = retGame

            completion(game: retGame)
        }
    }
}

