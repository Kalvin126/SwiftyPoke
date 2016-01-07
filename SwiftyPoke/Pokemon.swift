//
//  Pokemon.swift
//  SwiftyPoké
//
//  Created by Kalvin Loc on 12/7/15.
//  Copyright © 2015 redpanda. All rights reserved.
//

import Foundation

public struct Pokémon {
    public let name: String
    public let nationalID: Int
    public let resourceURI: String
    public var created: String?
    public var modified: String?
    
    public var catchRate: Int?
    public var species: String?
    public var hp: Int?
    public var attack: Int?
    public var defense: Int?
    public var spATK: Int?
    public var spDEF: Int?
    public var speed: Int?
    public var total: Int?
    public var eggCycles: Int?
    public var evYield: String?
    public var exp: Int?
    public var growthRate: String?
    public var height: String?
    public var weight: String?
    public var happiness: Int?
    public var maleFemalRatio: String? // in the format M / F

    public var abilities: Array<Ability> = []
    public var descriptions: Array<Description> = []
    public var egg_groups: Array<EggGroup> = []
    public var evolutions: Array<Evolution> = []
    public var moves: Array<Move> = []
    public var sprites = [Sprite]()
    public var types: Array<Type> = []

    init(info:Dictionary<String,AnyObject>) {
        if let nID = info["national_id"] as? Int {
            // full dictionary
            nationalID = nID
            name = info["name"] as! String
            resourceURI = info["resource_uri"] as! String

            created = info["created"] as? String
            modified = info["modified"] as? String
            catchRate = info["catch_rate"] as? Int
            species = info["species"] as? String
            hp = info["hp"] as? Int
            attack = info["attack"] as? Int
            defense = info["defense"] as? Int
            spATK = info["sp_atk"] as? Int
            spDEF = info["sp_def"] as? Int
            speed = info["speed"] as? Int
            total = info["total"] as? Int
            eggCycles = info["egg_cycles"] as? Int
            evYield = info["ev_yield"] as? String
            exp = info["exp"] as? Int
            growthRate = info["growth_rate"] as? String
            height = info["height"] as? String
            weight = info["weight"] as? String
            happiness = info["happiness"] as? Int
            maleFemalRatio = info["male_femal_ratio"] as? String
            
            for rawAbility in info["abilities"] as! NSArray {
                abilities.append(Ability(info: rawAbility as! Dictionary<String, AnyObject>))
            }

            for rawEggGroup in info["egg_groups"] as! NSArray {
                egg_groups.append(EggGroup(info: rawEggGroup as! Dictionary<String, AnyObject>))
            }

            for rawEvolution in info["evolutions"] as! NSArray {
                evolutions.append(Evolution(info: rawEvolution as! Dictionary<String, AnyObject>))
            }

            for rawDescription in info["descriptions"] as! NSArray {
                descriptions.append(Description(info: rawDescription as! Dictionary<String, AnyObject>))
            }

            for rawSprite in info["sprites"] as! NSArray {
                var sprite = Sprite(info: rawSprite as! Dictionary<String, AnyObject>)
                sprite.pokémon = self
                sprites += [sprite]
            }

            for rawMove in info["moves"] as! NSArray {
                moves.append(Move(info: rawMove as! Dictionary<String, AnyObject>))
            }

            for rawType in info["types"] as! NSArray {
                types.append(Type(info: rawType as! Dictionary<String, AnyObject>))
            }

        } else {
            // Pokedex short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String
            let startIndex = resourceURI[Range(start: resourceURI.startIndex, end: resourceURI.startIndex.advancedBy(1))] == "/"
            let range = Range(start: resourceURI.startIndex.advancedBy(startIndex ? 16 : 15), end: resourceURI.endIndex.advancedBy(-1))
            let nid = resourceURI.substringWithRange(range)
            nationalID = Int(nid)!
        }
    }
}

public struct Evolution {
    public var level: Int?
    public var method: String
    public var detail: String?
    public var resourceURI: String
    public var to: String

    public var pokémonNationalID: Int

    init(info:Dictionary<String,AnyObject>) {

        level = info["level"] as? Int
        method = info["method"] as! String
        detail = info["detail"] as? String
        resourceURI = info["resource_uri"] as! String
        to = info["to"] as! String

        let range = Range(start: resourceURI.startIndex.advancedBy(16), end: resourceURI.endIndex.advancedBy(-1))
        pokémonNationalID = Int(resourceURI.substringWithRange(range))!
    }
}

public struct Type {
    public var name: String
    public var id: Int
    public var resourceURI: String

    public var created: String?
    public var modified: String?

    public var ineffective: [Type] = []
    public var noEffect: [Type] = []
    public var resistance: [Type] = []
    public var superEffective: [Type] = []
    public var weakness: [Type] = []

    init(info: Dictionary<String,AnyObject>) {
        if let crea = info["created"] as? String {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = crea
            modified = info["modified"] as? String

            func processTypes(var arr: Array<Type>, data: Array<Dictionary<String,AnyObject>>){
                for rawType in data {
                    arr.append(Type(info: rawType))
                }
            }

            processTypes(   ineffective, data: info["ineffective"] as! Array<Dictionary<String, AnyObject>>)
            processTypes(      noEffect, data: info["no_effect"] as! Array<Dictionary<String, AnyObject>>)
            processTypes(    resistance, data: info["resistance"] as! Array<Dictionary<String, AnyObject>>)
            processTypes(superEffective, data: info["super_effective"] as! Array<Dictionary<String, AnyObject>>)
            processTypes(      weakness, data: info["weakness"] as! Array<Dictionary<String, AnyObject>>)
        } else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(13), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct Move {   // TODO: Lean_type is
    public var name: String
    public var id: Int
    public var resourceURI: String

    public var learnType: String?

    public var created: String?
    public var modified: String?

    public var desc: String?
    public var power: Int?
    public var accuracy: Int?
    public var category: String?
    public var pp: Int?

    init(info:Dictionary<String,AnyObject>) {
        if let desc = info["description"] as? String {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = info["created"] as? String
            modified = info["modified"] as? String

            self.desc = desc
            power = info["power"] as? Int
            accuracy = info["accuracy"] as? Int
            category = info["category"] as? String
            pp = info["pp"] as? Int

        } else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            learnType = info["learn_type"] as? String

            let range = Range(start: resourceURI.startIndex.advancedBy(13), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }

}

public struct Ability {
    public var name: String
    public var id: Int
    public var resourceURI: String

    public var created: String?
    public var modified: String?
    public var description: String?

    init(info:Dictionary<String,AnyObject>) {
        if let desc = info["description"] as? String {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = info["created"] as? String
            modified = info["modified"] as? String
            description = desc
        } else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(16), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct EggGroup {
    public var name: String
    public var id: Int
    public var resourceURI: String

    public var created: String?
    public var modified: String?

    public var pokémon: [Pokémon] = []

    init(info:Dictionary<String,AnyObject>) {
        if let crea = info["created"] as? String {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = crea
            modified = info["modified"] as? String

            for rawPokémon in info["pokemon"] as! NSArray {
                pokémon.append(Pokémon(info: rawPokémon as! Dictionary<String, AnyObject>))
            }
        } else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(12), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct Description {
    public var name: String
    public var id: Int
    public var resourceURI: String

    public var created: String?
    public var modified: String?

    public var desc: String?
    public var games: [Game] = []
    public var pokémon: [Pokémon] = []

    init(info:Dictionary<String,AnyObject>) {
        if let desc = info["description"] as? String {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = info["created"] as? String
            modified = info["modified"] as? String

            self.desc = desc

            pokémon.append(Pokémon(info: info["pokemon"] as! Dictionary<String, AnyObject>))
        } else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(20), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct Sprite {
    public var name: String
    public var id: Int
    public var resourceURI: String

    public var created: String?
    public var modified: String?

    public var pokémon: Pokémon?
    public var imageURI: String?
    public var image: NSData?      // should this be memory cached?

    init(info:Dictionary<String,AnyObject>) {
        if let img = info["image"] as? String {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = info["created"] as? String
            modified = info["modified"] as? String

            pokémon = Pokémon(info: (info["pokemon"] as! Dictionary<String, AnyObject>))
            imageURI = img
        } else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(15), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct Game {
    public var name: String
    public var id: Int
    public var resourceURI: String

    public var created: String?
    public var modified: String?

    public var releaseYear: Int?
    public var generation: Int?

    init(info:Dictionary<String,AnyObject>) {
        if let releaseYr = info["release_year"] as? Int {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = info["created"] as? String
            modified = info["modified"] as? String

            releaseYear = releaseYr
            generation = info["generation"] as? Int

        } else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(13), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}
