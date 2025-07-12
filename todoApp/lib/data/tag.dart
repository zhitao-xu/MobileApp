import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class TagStorage {
  static List<String> _tags = [];
  static bool _isInitialized = false;
  static const String _fileName = 'tags.json';
  
  static final List<String> _defaultTags = [
    'Work',
    'Personal',
    'Urgent',
    'Shopping',
    'Health',
  ];

  // Initialize storage
  static Future<void> _initialize() async {
    if (_isInitialized) return;
    
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        _tags = jsonList.cast<String>();
      } else {
        _tags = List.from(_defaultTags);
        await _saveToFile(); // Save default tags
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing tags: $e');
      }
      _tags = List.from(_defaultTags);
    }
    
    _isInitialized = true;
  }

  // Save to file in background
  static Future<void> _saveToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      await file.writeAsString(json.encode(_tags));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to file: $e');
      }
    }
  }

  // Load tags
  static Future<List<String>> loadTags() async {
    await _initialize();
    return List.from(_tags);
  }

  // Save tags
  static Future<void> saveTags(List<String> tags) async {
    await _initialize();
    _tags = List.from(tags);
    await _saveToFile(); // Save to file in background
  }

  // Add new tags (automatically avoids duplicates)
  static Future<void> addTags(List<String> newTags) async {
    await _initialize();
    final updatedTags = {..._tags, ...newTags}.toList();
    _tags = updatedTags;
    await _saveToFile(); // Save to file in background
  }

  // Remove a tag
  static Future<void> removeTag(String tag) async {
    await _initialize();
    _tags.remove(tag);
    await _saveToFile(); // Save to file in background
  }
}