//
//  SwiftyPoke.swift
//  SwiftyPoke
//
//  Created by Kalvin Loc on 12/7/15.
//  Copyright © 2015 redpanda. All rights reserved.
//

import Foundation

public final class SwiftyPoke {
    private var verbose = true
    private var timeout: NSTimeInterval = 60;
    private var cache = NSURLCache.sharedURLCache()

    private static let shared = SwiftyPoke()
    private let APIURL = "http://pokeapi.co"

    // Resource Caches
    private var pokémon         = [Int : Pokémon]()
    private var types           = [Int : Type]()
    private var moves           = [Int : Move]()
    private var abilities       = [Int : Ability]()
    private var eggGroups       = [Int : EggGroup]()
    private var descriptions    = [Int : Description]()
    private var sprites         = [Int : Sprite]()
    private var games           = [Int : Game]()

    private func getJSONResponseWithURI(uri: String, completion: (response: Dictionary<String, AnyObject>) -> Void) {
        self.getDataWithURI(uri) { (data, response, error) -> Void in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! Dictionary<String, AnyObject>
                completion(response: json)
            } catch {
                if self.verbose { print("\(error)")}
            }
        }
    }

    private func getDataWithURI(uri: String, completion: ((data: NSData?, response: NSURLResponse?, error: NSError?) -> Void)) {
        let URL = NSURL(string: APIURL + uri)!
        let URLRequest = NSURLRequest(URL: URL, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: timeout)

        // Test if response cache for URL is availible
        if let cachedResponse = cache.cachedResponseForRequest(URLRequest) {
            completion(data: cachedResponse.data, response: cachedResponse.response, error: nil)
            return
        }

        if verbose { print("Querying URL: \(URL)") }

        // No chached response, lets query
        let requestStart:NSDate = NSDate()
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: APIURL + uri)!) { (data, response, error) in
            let interval:NSTimeInterval = NSDate().timeIntervalSinceDate(requestStart)
            if self.verbose { print("Response returned in \(interval) seconds") }

            if error != nil {
                print(error)
                return
            }

            // Cache response
            self.cache.storeCachedResponse(NSCachedURLResponse(response: response!, data: data!), forRequest: URLRequest)

            dispatch_async(dispatch_get_main_queue()) {
                completion(data: data, response: response, error: error)
            }
        }.resume()
    }

    /**
     Fetches pokémon and fill pokédex. Note that this only fetches names and resource URI's for all Pokémon
     Pass a Pokémon to getPokémon to fetch complete Pokémon data
     Must call this function before calling getPokédex().

     - parameter completion: Closure to call once Pokédex is filled
     */
    public static func fillNationalPokédex(completion: (success: Bool) -> Void) {
        shared.getJSONResponseWithURI("/api/v1/pokedex/1/") { (response) -> Void in
            let rawPokémonData = response["pokemon"] as! NSArray

            for p in rawPokémonData {
                let pokémon = Pokémon(info: p as! Dictionary<String, AnyObject>)

                shared.pokémon[pokémon.nationalID] = pokémon
            }

            completion(success: true)
        }

        // Fetch all types and Egg Groups
        getTypes { (types) -> Void in }
        getEggGroups { (eggGroups) -> Void in }
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

    /**
     Returns the cached Pokémon in the Pokédex. Will return an empty Array if fillNationalPokédex is not initially called

     - returns: Array of Pokémon
     */
    public static func getPokédex() -> [Pokémon] {
        return Array(shared.pokémon.values).sort { $0.nationalID < $1.nationalID }
    }

    /**
    Fetches complete Pokémon record; however, sprite, moves, etc, only contain preliminary data. Pass into corresponding fetch function to get complete data. Fetched Pokémon is then cached. Will return immediately if already cached.
     
     - parameter pokémon: Pokémon to fetch
     - parameter completion: completion handler to call once the pokémon is ready to be returned
     */
    public static func getPokémon(pokémon: Pokémon, completion: (pokémon: Pokémon) -> Void) {
        if let cached = shared.checkForCache(pokémon) as? Pokémon {
            completion(pokémon: cached)
            return
        }

        // pokedex/1/ returns URIs without leading /
        shared.getJSONResponseWithURI("/" + pokémon.resourceURI) { (response) -> Void in
            let retPoké = Pokémon(info: response)
            shared.pokémon[pokémon.nationalID] = retPoké

            completion(pokémon: retPoké)
        }
    }

    /**
     Fetches complete Pokémon record by ID; however, sprite, moves, etc, only contain preliminary data. Pass into corresponding fetch function to get complete data. Fetched Pokémon is then cached. Will return immediately if already cached.

     - parameter id: Pokémon's national ID to fetch
     - parameter completion: completion handler to call once the pokémon is ready to be returned
     */
    public static func getPokémonByID(id: Int, completion: (pokémon: Pokémon) -> Void) {
        getPokémon(shared.pokémon[id]!, completion: completion)
    }

    public static func getRandomPokémon(completion: (pokémon: Pokémon) -> Void) {
        let rand = arc4random_uniform(UInt32(shared.pokémon.count))
        let pokémon = Array(shared.pokémon.values)[Int(rand)]
        getPokémon(pokémon, completion: completion)
    }

    /**
     Fetches all complete Type records; Fetched Types are then cached. Will return immediately if already cached.

     - parameter type: Type to fetch
     - parameter completion: completion handler to call once the Type is ready to be returned
     */
    public static func getTypes(completion: (types: [Type]) -> Void) {
        if shared.types.count != 0 {
            completion(types: Array(shared.types.values))
            return
        }

        shared.getJSONResponseWithURI("/api/v1/type/?limit=20") { (response) -> Void in
            for rawType in response["objects"] as! NSArray {
                let type = Type(info: rawType as! Dictionary<String, AnyObject>)
                shared.types[type.id] = type
            }

            completion(types: Array(shared.types.values))
        }
    }

    /**
     Fetches complete Type record; types it effects will be lite records and will need to passed in to this function to fetch full record. Fetched Type is then cached. Will return immediately if already cached.
     
     - parameter type: Type to fetch
     - parameter completion: completion handler to call once the Type is ready to be returned
     */
    public static func getType(type: Type, completion: (type: Type) -> Void) {
        if let cached = shared.checkForCache(type) as? Type {
            completion(type: cached)
            return
        }

        shared.getJSONResponseWithURI(type.resourceURI) { (response) -> Void in
            let retType = Type(info: response)
            shared.types[retType.id] = retType    // cache fetched resource

            completion(type: retType)
        }
    }

    /**
     Fetches complete Move record. Fetched move is then cached. Will return immediately if already cached.

     - parameter type: Move to fetch
     - parameter completion: completion handler to call once the Move is ready to be returned
     */
    public static func getMove(move: Move, completion: (move: Move) -> Void) {
        if let cached = shared.checkForCache(move) as? Move {
            completion(move: cached)
            return
        }

        shared.getJSONResponseWithURI(move.resourceURI) { (response) -> Void in
            let retMove = Move(info: response)
            shared.moves[retMove.id] = retMove

            completion(move: retMove)
        }
    }

    /**
     Fetches complete Ability record. Fetched Ability is then cached. Will return immediately if already cached.

     - parameter type: Move to Ability
     - parameter completion: completion handler to call once the Ability is ready to be returned
     */
    public static func getAbility(ability: Ability, completion: (ability: Ability) -> Void) {
        if let cached = shared.checkForCache(ability) as? Ability {
            completion(ability: cached)
            return
        }

        shared.getJSONResponseWithURI(ability.resourceURI) { (response) -> Void in
            let retAbility = Ability(info: response)
            shared.abilities[retAbility.id] = retAbility

            completion(ability: retAbility)
        }
    }


    /**
     Fetches all Egg Group records. Fetched EggGroups are then cached. Will return immediately if already cached.

     - parameter completion: completion handler to call once EggGroups are ready to be returned
     */
    public static func getEggGroups(completion: (eggGroups: [EggGroup]) -> Void) {
        if shared.eggGroups.count != 0 {
            completion(eggGroups: Array(shared.eggGroups.values))
            return
        }

        shared.getJSONResponseWithURI("/api/v1/egg/?limit=15") { (response) -> Void in
            for rawGroup in response["objects"] as! NSArray {
                let group = EggGroup(info: rawGroup as! Dictionary<String, AnyObject>)
                shared.eggGroups[group.id] = group
            }

            completion(eggGroups: Array(shared.eggGroups.values))
        }
    }

    /**
     Fetches complete EggGroup record. Fetched EggGroup is then cached. Will return immediately if already cached.

     - parameter type: EggGroup to fetch
     - parameter completion: completion handler to call once the EggGroup is ready to be returned
     */
    public static func getEggGroup(eggGroup: EggGroup, completion: (eggGroup: EggGroup) -> Void) {
        if let cached = shared.checkForCache(eggGroup) as? EggGroup {
            completion(eggGroup: cached)
            return
        }

        shared.getJSONResponseWithURI(eggGroup.resourceURI) { (response) -> Void in
            let retEggGroup = EggGroup(info: response)
            shared.eggGroups[retEggGroup.id] = retEggGroup

            completion(eggGroup: retEggGroup)
        }
    }

    /**
     Fetches complete Description record. Fetched Description is then cached. Will return immediately if already cached.

     - parameter type: Description to fetch
     - parameter completion: completion handler to call once the Description is ready to be returned
     */
    public static func getDescription(description: Description, completion: (description: Description) -> Void) {
        if let cached = shared.checkForCache(description) as? Description {
            completion(description: cached)
            return
        }

        shared.getJSONResponseWithURI(description.resourceURI) { (response) -> Void in
            let retDescription = Description(info: response)
            shared.descriptions[retDescription.id] = retDescription

            completion(description: retDescription)
        }
    }

    /**
     Fetches complete Sprite record. Fetched Sprite is then cached. Will return immediately if already cached.

     - parameter type: Sprite to fetch
     - parameter completion: completion handler to call once the Sprite is ready to be returned
     */
    public static func getSprite(sprite: Sprite, completion: (sprite: Sprite) -> Void) {
        if let cached = shared.checkForCache(sprite) as? Sprite {  // check local cache
            completion(sprite: cached)
            return
        }

        shared.getJSONResponseWithURI(sprite.resourceURI) { (response) -> Void in
            var fetchedSprite = Sprite(info: response)
            fetchedSprite.pokémon = sprite.pokémon

            // fetch spriteImg as well
            shared.getDataWithURI(fetchedSprite.imageURI!) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil else {
                        if shared.verbose { print("Failed to retrieve: \(sprite.imageURI!)") }
                        return
                    }

                    fetchedSprite.image = data
                    shared.sprites[sprite.id] = fetchedSprite
                    completion(sprite: fetchedSprite)
                }
            }
        }
    }

    /**
     Fetches complete Game record. Fetched Game is then cached. Will return immediately if already cached.

     - parameter type: Game to fetch
     - parameter completion: completion handler to call once the Game is ready to be returned
     */
    public static func getGame(game: Game, completion: (game: Game) -> Void) {
        if let cached = shared.checkForCache(game) as? Game {
            completion(game: cached)
            return
        }

        shared.getJSONResponseWithURI(game.resourceURI) { (response) -> Void in
            let retGame = Game(info: response)
            shared.games[retGame.id] = retGame

            completion(game: retGame)
        }
    }
}
