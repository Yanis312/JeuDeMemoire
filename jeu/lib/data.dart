import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

// Enumeration for game difficulty levels
enum Level { easy, medium, hard }

// A class to hold image, sound URL, and image name
class Asset {
  String imageUrl;
  String soundUrl;
  String imageName; // Image name property

  Asset(
      {required this.imageUrl,
      required this.soundUrl,
      required this.imageName});
}
/*
// Method to read the asset file names from a text file asynchronously
Future<List<Asset>> loadAssetsFromFile() async {
  String fileContent = await rootBundle.loadString(
      'assets/kab_word_photo_sound_mapping.txt'); // Load the combined assets file
  return fileContent
      .split('\n') // Split by newline to get each asset line
      .map((line) => line.trim()) // Trim whitespace
      .where((line) => line.isNotEmpty) // Remove empty lines
      .map((line) {
    var parts = line.split(','); // Split each line by comma
    if (parts.length < 3) {
      throw FormatException('Invalid asset line: $line');
    }
    // Correct order of parts based on your file: image_name, soundUrl, imageUrl
    return Asset(
      imageName: parts[0].trim(), // First column is image name
      soundUrl: parts[1].trim(),  // Second column is sound URL
      imageUrl: parts[2].trim()   // Third column is image URL
    );
  }).toList(); // Return the list of Asset objects
}
*/

Future<List<Asset>> loadAssetsFromFile() async {
  String fileContent;
  try {
    // Try to load from the cloud first
    var response = await http.get(Uri.parse(
        'https://d27s18bdmp7aby.cloudfront.net/kab_word_photo_sound_mapping.txt'));
    if (response.statusCode == 200) {
      // Explicitly decode the response body using UTF-8
      fileContent = utf8.decode(response.bodyBytes);
    } else {
      throw Exception('Failed to load assets from the cloud');
    }
  } catch (e) {
    // If loading from the cloud fails, fall back to the local file
    //print('Loading from local assets due to error: $e');
    fileContent =
        await rootBundle.loadString('assets/kab_word_photo_sound_mapping.txt');
  }

  // Process the file content exactly as before
  return fileContent
      .split('\n') // Split by newline to get each asset line
      .map((line) => line.trim()) // Trim whitespace
      .where((line) => line.isNotEmpty) // Remove empty lines
      .map((line) {
    var parts = line.split(','); // Split each line by comma
    if (parts.length < 3) {
      throw FormatException('Invalid asset line: $line');
    }
    // Correct order of parts based on your file: image_name, soundUrl, imageUrl
    return Asset(
        imageName: parts[0].trim(), // First column is image name
        soundUrl: parts[1].trim(), // Second column is sound URL
        imageUrl: parts[2].trim() // Third column is image URL
        );
  }).toList(); // Return the list of Asset objects
}

// Method to get the source array of card images based on the level
Future<List<Asset>> getSourceArray(Level level) async {
  List<Asset> allAssets =
      await loadAssetsFromFile(); // Load all assets from the combined file
  int numPairs; // Number of image pairs to load depending on the level

  // Set the number of pairs based on the difficulty level
  if (level == Level.hard) {
    numPairs = 16; // Load 16 pairs for hard (32 cards)
  } else if (level == Level.medium) {
    numPairs = 12; // Load 12 pairs for medium (24 cards)
  } else {
    numPairs = 8; // Load 8 pairs for easy (16 cards)
  }

  // Ensure there are enough unique assets to select the required number of pairs
  if (numPairs > allAssets.length) {
    throw Exception(
        'Not enough unique assets in kab_word_photo_sound_mapping.txt to form $numPairs pairs.');
  }

  // Shuffle the list to ensure random distribution
  allAssets.shuffle();

  // Take the first 'numPairs' assets and duplicate them to form pairs
  List<Asset> gameAssets = List<Asset>.from(allAssets.take(numPairs));
  gameAssets
      .addAll(List<Asset>.from(gameAssets)); // Duplicate the list to form pairs

  // Shuffle the resulting list to mix the pairs
  gameAssets.shuffle();

  return gameAssets;
}
