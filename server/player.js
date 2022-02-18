/**
 * Boucle de gameplay :
 * Le joueur choisit son peuple
 * Il choisit sa classe
 * Il récupère des stats random
 * Il ouvre la map
 * Il choisit une mission
 * Il choisit une réponses a une péripétie (furtif, aggresive, négociation)
 * Fin de la mission, rapport de mission
 * Récupération des objets
 * Possibilité de vendre et acheter les objets contre une monnaie gold
 * Possibilité de crafter des equipement avec les objets
 * Possibilité de revendre le token equipement a un jour contre de l'argent qui attérie sur le compte du joueur qui vend (on récupère 5 %)
 */

/**
 * HERO
 * 6 stats (end, str, dex,)
 * 4 jobs ()
 */
class Hero {

    constructor(){
        this.stats = {
            "strong" : 0,
            "dexterity" : 0,
            "intelligence" : 0,
            "endurence" : 0,
            "vitality" : 0,
            "" : 0,
        };
        this.inventory = {};
        this.equipement = {
            "head":null,
            "body":null,
            "legs":null,
            "arms":null,
        };
    }

    
    /**
     * Entrainer le personnage
     */
    train(){

    }

    addExp(){

    }

    levelUp(){

    }

    /**
     * inventory
     */

    addItems(item){

    }

    getItem(){

    }

    getItems(){

    }

    removeItems(){

    }

    /**
     * craft items
     * permet de crafter armes et armures
     */

}
