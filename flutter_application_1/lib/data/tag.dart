class TagStorage {
  static List<String> _tags = [
    'Work',
    'Personal',
    'Urgent',
    'Shopping',
    'Health',
  ];

  // Load tags from memory
  static Future<List<String>> loadTags() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_tags);
  }

  // Save tags to memory
  static Future<void> saveTags(List<String> tags) async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 50));
    _tags = List.from(tags);
  }

  // Add new tags (automatically avoids duplicates)
  static Future<void> addTags(List<String> newTags) async {
    final currentTags = await loadTags();
    final updatedTags = {...currentTags, ...newTags}.toList(); // merge and deduplicate
    await saveTags(updatedTags);
  }
}