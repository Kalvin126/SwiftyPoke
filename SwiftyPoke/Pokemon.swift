//
//  Pokemon.swift
//  SwiftyPoké
//
//  Created by Kalvin Loc on 12/7/15.
//  Copyright © 2015 redpanda. All rights reserved.
//

import Foundation

public struct Pokémon {
    /** The resource name e.g. Bulbasaur. */
    public let name: String
    /** The id of the resource, this is the National pokedex number of the pokemon. */
    public let nationalID: Int
    /** The uri of this resource. */
    public let resourceURI: String
    /**  the creation date of the resource. */
    public var created: String?
    /**  the last time this resource was modified. */
    public var modified: String?

    /** this pokemon's catch rate. */
    public var catchRate: Int?
    public var species: String?
    public var hp: Int?
    public var attack: Int?
    public var defense: Int?
    public var spATK: Int?
    public var spDEF: Int?
    public var speed: Int?
    /** the total attributes. */
    public var total: Int?
    /** number of egg cycles needed. */
    public var eggCycles: Int?
    /**  the ev yield for this pokemon. */
    public var evYield: String?
    /** the exp yield from this pokemon. */
    public var exp: Int?
    /** the growth rate of this pokemon. */
    public var growthRate: String?
    public var height: String?
    public var weight: String?
    /** base happiness for this pokemon. */
    public var happiness: Int?
    /** Male to Female ratio in the format M / F */
    public var maleFemalRatio: String?

    /**  the abilities this pokemon can have. */
    public var abilities: Array<Ability> = []
    /** the pokedex descriptions this pokemon has. */
    public var descriptions: Array<Description> = []
    /** the egg groups this pokemon is in. */
    public var egg_groups: Array<EggGroup> = []
    /** the evolutions this pokemon can evolve into. */
    public var evolutions: Array<Evolution> = []
    /** the moves this pokemon can learn. */
    public var moves: Array<Move> = []
    /** The sprites of this pokemon */
    public var sprites = [Sprite]()
    /**  the types this pokemon is. */
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

        }
        else {
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

public struct Type : Equatable {
    /** the resource name e.g. Water. */
    public var name: String
    /** the id of the resource. */
    public var id: Int
    /** the uri of this resource. */
    public var resourceURI: String

    /** the creation date of the resource. */
    public var created: String?
    /** the last time this resource was modified. */
    public var modified: String?

    /** the types this type is ineffective against. */
    public var ineffective: [Type] = []
    /** the types this type has no effect against. */
    public var noEffect: [Type] = []
    /** the types this type is resistant to. */
    public var resistance: [Type] = []
    /** the types this type is super effective against. */
    public var superEffective: [Type] = []
    /** the types this type is weak to. */
    public var weakness: [Type] = []

    init(info: Dictionary<String,AnyObject>) {
        if let crea = info["created"] as? String {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = crea
            modified = info["modified"] as? String

            func processTypes(inout arr: [Type], data: Array<Dictionary<String,AnyObject>>){
                for rawType in data {
                    arr.append(Type(info: rawType))
                }
            }

            processTypes(   &ineffective, data: info["ineffective"      ] as! Array<Dictionary<String, AnyObject>>)
            processTypes(      &noEffect, data: info["no_effect"        ] as! Array<Dictionary<String, AnyObject>>)
            processTypes(    &resistance, data: info["resistance"       ] as! Array<Dictionary<String, AnyObject>>)
            processTypes(&superEffective, data: info["super_effective"  ] as! Array<Dictionary<String, AnyObject>>)
            processTypes(      &weakness, data: info["weakness"         ] as! Array<Dictionary<String, AnyObject>>)
        }
        else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(13), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public func ==(lhs: Type, rhs: Type) -> Bool {
    return lhs.name == rhs.name
}

public struct Move {   // TODO: Lean_type is
    /** the resource name e.g. Water. */
    public var name: String
    /** the id of the resource. */
    public var id: Int
    /** the uri of this resource. */
    public var resourceURI: String

    /** the creation date of the resource. */
    public var created: String?
    /** the last time this resource was modified. */
    public var modified: String?

    public var learnType: String?

    /** a description of the move. */
    public var desc: String?
    /** the power of the move. */
    public var power: Int?
    /** the accuracy of the move. */
    public var accuracy: Int?
    /**  the category of the move. */
    public var category: String?
    /** the pp points of the move. */
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

        }
        else {
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
    /** the resource name e.g. Overgrow. */
    public var name: String
    /** the id of the resource. */
    public var id: Int
    /** the uri of this resource. */
    public var resourceURI: String

    /** the creation date of the resource. */
    public var created: String?
    /** the last time this resource was modified. */
    public var modified: String?

    /** the description of this ability */
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
        }
        else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(16), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct EggGroup {
    /** the resource name e.g. Monster.*/
    public var name: String
    /** the id of the resource. */
    public var id: Int
    /** the uri of this resource. */
    public var resourceURI: String

    /** the creation date of the resource. */
    public var created: String?
    /** the last time this resource was modified. */
    public var modified: String?

    /** a list of all the pokemon in that egg group. */
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
        }
        else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(12), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct Description {
    /** the resource name */
    public var name: String
    /** the id of the resource. */
    public var id: Int
    /** the uri of this resource. */
    public var resourceURI: String

    /** the creation date of the resource. */
    public var created: String?
    /** the last time this resource was modified. */
    public var modified: String?

    public var description: String?
    /** a list of games this description is in. */
    public var games: [Game] = []
    /** the pokemon this description is for. */
    public var pokémon: Pokémon?

    init(info:Dictionary<String,AnyObject>) {
        if let desc = info["description"] as? String {
            // full dictionary
            name = info["name"] as! String
            id = info["id"] as! Int
            resourceURI = info["resource_uri"] as! String

            created = info["created"] as? String
            modified = info["modified"] as? String

            description = desc

            pokémon = Pokémon(info: info["pokemon"] as! Dictionary<String, AnyObject>)

            for rawGame in info["games"] as! NSArray {
                games.append(Game(info: rawGame as! Dictionary<String, AnyObject>))
            }
        }
        else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(20), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct Sprite {
    /** the resource name */
    public var name: String
    /** the id of the resource. */
    public var id: Int
    /** the uri of this resource. */
    public var resourceURI: String

    /** the creation date of the resource. */
    public var created: String?
    /** the last time this resource was modified. */
    public var modified: String?

    /** the pokemon this sprite is for. */
    public var pokémon: Pokémon?
    /** the uri for the sprite image */
    public var imageURI: String?
    /** the image data. Pass this into UIImage or NSImage for display. */
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
        }
        else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(15), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}

public struct Game {
    /** the resource name e.g. Pokemon red. */
    public var name: String
    /** the id of the resource. */
    public var id: Int
    /** the uri of this resource. */
    public var resourceURI: String

    /** the creation date of the resource. */
    public var created: String?
    /** the last time this resource was modified. */
    public var modified: String?

    /**  the year the game was released */
    public var releaseYear: Int?
    /** the generation this game belongs to. */
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

        }
        else {
            // short data
            name = (info["name"] as! String).capitalizedString
            resourceURI = info["resource_uri"] as! String

            let range = Range(start: resourceURI.startIndex.advancedBy(13), end: resourceURI.endIndex.advancedBy(-1))
            id = Int(resourceURI.substringWithRange(range))!
        }
    }
}
