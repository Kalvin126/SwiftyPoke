SwiftyPoke
==================

Swift Framework Wrapper for Pokémon Database pokeapi.co
Currently, data is only cached by instance/session.

Usage:
............

When you want to retrieve a resource, call SwiftyPoke.shared.get*****(resource) to fetch or retrieve a cached version.

.. code-block:: swift

    import SwiftyPoke

    SwiftyPoke.fillNationalPokédex { (success) -> Void in
        if success {
            let pokedex = SwiftyPoke.getPokédex()
            SwiftyPoke.getPokémon(pokedex[0]) { (pokémon) -> Void in
                print("Fetched \(pokémon.name)")

                SwiftyPoke.getSprite(pokémon.sprites[0]) { (sprite) -> Void in
                    let image = UIImage(data: sprite.image!)
                }
            }
        }
    }

TODO: 
........

- Documentation
- Data Persistance
