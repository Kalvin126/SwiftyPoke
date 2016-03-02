SwiftyPoke
==================

Swift Framework Wrapper for Pokémon Database pokeapi.co

Currently, data is only cached by instance/session.

Install: 
...........

Drag the .xcodeproj into your application and add SwiftyPoke.framework to your project's embedded binaries and Linked Frameworks and Libraries

To enable caching add this to application:didFinishLaunchingWithOptions: :

.. code-block:: swift

    let URLCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)   // 4 MB
    NSURLCache.setSharedURLCache(URLCache)

Usage:
............

When you want to retrieve a resource, call SwiftyPoke.get*****(resource) to fetch it or retrieve from cache.

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
    