import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';

enum Level { hard, medium, easy }

List<String> fillSourceArray() {
  return [
    'assets/animalspics/dino.png',
    'assets/animalspics/dino.png',

    'assets/animalspics/rouge.png',
    'assets/animalspics/rouge.png',

    'assets/animalspics/bleu.png',
    'assets/animalspics/bleu.png',

    'assets/animalspics/jaune.png',
    'assets/animalspics/jaune.png',
    
    'assets/animalspics/blanc.png',
    'assets/animalspics/blanc.png',

    'assets/animalspics/gris.png',
    'assets/animalspics/gris.png',

    'assets/animalspics/vert.png',
    'assets/animalspics/vert.png',

    'assets/animalspics/rose.png',
    'assets/animalspics/rose.png',



    // Ajoutez plus d'images si nécessaire pour remplir toutes les cartes
  ];
}

List<String> getSourceArray(Level level) {
  List<String> sourceArray = fillSourceArray();
  List<String> selectedArray = [];
  int numPairs;

  // Définir le nombre de paires en fonction du niveau
  if (level == Level.hard) {
    numPairs = 16; // 32 cartes
  } else if (level == Level.medium) {
    numPairs = 12; // 24 cartes
  } else if (level == Level.easy) {
    numPairs = 8; // 16 cartes
  } else {
    return [];
  }

  // Vérifier qu'il y a suffisamment d'images pour le nombre de paires
  if (numPairs * 2 > sourceArray.length) {
    throw Exception("Pas assez d'images pour ce niveau. Ajoutez plus d'images.");
  }

  // Prendre les paires nécessaires
  for (int i = 0; i < numPairs; i++) {
    selectedArray.add(sourceArray[i * 2]);
    selectedArray.add(sourceArray[i * 2 + 1]);
  }

  // Mélanger les cartes
  selectedArray.shuffle();
  return selectedArray;
}

List<bool> getInitialItemState(Level level) {
  int numCards;

  if (level == Level.hard) {
    numCards = 32; // 16 paires
  } else if (level == Level.medium) {
    numCards = 24; // 12 paires
  } else if (level == Level.easy) {
    numCards = 16; // 8 paires
  } else {
    return [];
  }

  return List.generate(numCards, (_) => true);
}

List<GlobalKey<FlipCardState>> getCardStateKeys(Level level) {
  int numCards;

  if (level == Level.hard) {
    numCards = 32;
  } else if (level == Level.medium) {
    numCards = 24;
  } else if (level == Level.easy) {
    numCards = 16;
  } else {
    return [];
  }

  return List.generate(numCards, (_) => GlobalKey<FlipCardState>());
}
