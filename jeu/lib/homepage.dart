import 'package:flutter/material.dart';

import 'flipcardgame.dart';
import 'data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(), // Barre d'application vide.
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Marges autour du ListView.
        child: ListView.builder(
          itemCount: _list.length, // Nombre d'éléments dans la liste.
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Navigation vers une nouvelle page lorsque l'élément est tapé.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => _list[index].goto,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Marges autour de chaque élément.
                child: Stack(
                  children: [
                    Container(
                      height: 110, // Hauteur du conteneur principal.
                      width: double.infinity, // Largeur du conteneur, prend toute la largeur disponible.
                      decoration: BoxDecoration(
                        color: _list[index].primarycolor, // Couleur principale du conteneur.
                        borderRadius: BorderRadius.circular(25), // Coins arrondis du conteneur.
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 6, // Rayon de flou de l'ombre.
                            color: Colors.grey, // Couleur de l'ombre.
                            spreadRadius: 1, // Épandement de l'ombre.
                            offset: Offset(4, 4), // Décalage de l'ombre.
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 100, // Hauteur du conteneur secondaire.
                      width: double.infinity, // Largeur du conteneur, prend toute la largeur disponible.
                      decoration: BoxDecoration(
                        color: _list[index].secomdarycolor, // Couleur secondaire du conteneur.
                        borderRadius: BorderRadius.circular(25), // Coins arrondis du conteneur.
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 6, // Rayon de flou de l'ombre.
                            color: Colors.black12, // Couleur de l'ombre.
                            spreadRadius: 1, // Épandement de l'ombre.
                            offset: Offset(2, 2), // Décalage de l'ombre.
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Aligne les enfants au centre verticalement.
                        children: [
                          Center(
                            child: Text(
                              _list[index].name, // Nom de l'élément de la liste.
                              style: const TextStyle(
                                color: Colors.white, // Couleur du texte.
                                fontSize: 28, // Taille de la police.
                                fontWeight: FontWeight.bold, // Poids de la police en gras.
                                shadows: [
                                  Shadow(
                                    color: Colors.black26, // Couleur de la première ombre.
                                    blurRadius: 3, // Rayon de flou de la première ombre.
                                    offset: Offset(1, 1.5), // Décalage de la première ombre.
                                  ),
                                  Shadow(
                                    color: Colors.blue, // Couleur de la deuxième ombre.
                                    blurRadius: 3, // Rayon de flou de la deuxième ombre.
                                    offset: Offset(0.5, 1.5), // Décalage de la deuxième ombre.
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Aligne les étoiles au centre horizontalement.
                            crossAxisAlignment: CrossAxisAlignment.center, // Aligne les étoiles au centre verticalement.
                            children: genratestar(_list[index].noOfstar), // Génère les étoiles en fonction du nombre d'étoiles.
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Génère une liste d'icônes d'étoiles dorées en fonction du nombre donné.
  List<Widget> genratestar(int no) {
    List<Widget> icons = [];
    for (int i = 0; i < no; i++) {
      icons.add(
        const Icon(
          Icons.star,
          color: Colors.amber, // Couleur or pour les étoiles.
        ),
      );
    }
    return icons;
  }
}



// Classe Details qui représente les informations d'un élément de la liste.
class Details {
  String name; // Le nom de l'élément.
  Color primarycolor; // La couleur principale de l'élément.
  Color secomdarycolor; // La couleur secondaire de l'élément.
  Widget goto; // La destination (widget) vers laquelle naviguer lorsqu'on clique sur l'élément.
  int noOfstar; // Le nombre d'étoiles associé à l'élément.

  // Constructeur de la classe Details.
  Details(
      {required this.name, // Le nom est obligatoire.
      required this.primarycolor, // La couleur principale est obligatoire.
      required this.secomdarycolor, // La couleur secondaire est obligatoire.
      required this.noOfstar, // Le nombre d'étoiles est obligatoire.
      required this.goto}); // La destination est obligatoire.
}


// Liste des objets Details utilisée pour générer les éléments de la liste.
List<Details> _list = [
  Details(
    name: "FACILE",
    primarycolor: const Color.fromARGB(255, 84, 124, 218), // Couleur principale turquoise.
    secomdarycolor: const Color.fromARGB(255, 100, 181, 246), // Couleur secondaire bleu clair.
    noOfstar: 1, // Une étoile pour le niveau facile.
    goto: const FlipCardGame(Level.easy), // Destination de la page pour le niveau facile.
  ),
   Details(
    name: "MOYEN",
    primarycolor: const Color.fromARGB(255, 232, 56, 212), // Couleur principale ambre.
    secomdarycolor: const Color.fromARGB(255, 232, 56, 212), // Couleur secondaire ambre clair.
    noOfstar: 2, // Deux étoiles pour le niveau moyen.
    goto: const FlipCardGame(Level.medium), // Destination de la page pour le niveau moyen.
  ),
  Details(
    name: "DIFFICILE",
    primarycolor: Colors.deepOrange, // Couleur principale orange foncé.
    secomdarycolor: const Color.fromARGB(255, 255, 87, 34), // Couleur secondaire orange vif.
    noOfstar: 3, // Trois étoiles pour le niveau difficile.
    goto: const FlipCardGame(Level.hard), // Destination de la page pour le niveau difficile.
  ),
];


