SwiftyPoke
==================

Swift Framework Wrapper for Pokémon Database pokeapi.co

Usage:
............

.. code-block:: swift

	import SwiftyPoké

	SwiftyPoke.shared.fillNationalPokédex { (success) -> Void in
        if success {
        	let pokedex = SwiftyPoke.shared.getPokédex()
        	SwiftyPoke.shared.getPokémon(pokedex[0]) { (pokémon) -> Void in
        		print("Fetched \(pokémon.name)")

        		SwiftyPoke.shared.getSprite(pokémon.sprites[0]) { (sprite) -> Void in
	                if cell.tag == pokemonForCell.nationalID {
	                    spriteImageView.image = UIImage(data: sprite.image!)
	                }
	            }

        	}
        }
    }

TODO: 
........

- Data Persistance