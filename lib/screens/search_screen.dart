// search_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import models to access dummyProducts and dummyCategories

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [
    'Organic Rice',
    'Wood Pressed Oil',
    'Millet'
  ]; // Dummy recent searches
  final int _maxRecentSearches = 5; // Limit the number of recent searches

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addSearchToRecents(String query) {
    if (query.isEmpty) return;
    setState(() {
      // Remove if already exists to move it to the top
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      // Keep only the latest N searches
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
      }
    });
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search_rounded,
                    color: Theme.of(context).hintColor),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: Theme.of(context)
                          .iconTheme
                          .color
                          ?.withAlpha((255 * 0.6).round())),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
              onSubmitted: (query) {
                _addSearchToRecents(query);
                // In a real app, you'd trigger a search here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Searching for: $query')),
                );
              },
            ),
            const SizedBox(height: 24.0),
            if (_recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Recent Searches'),
                  TextButton(
                    onPressed: _clearRecentSearches,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              _buildTagList(_recentSearches, onTap: (tag) {
                _searchController.text = tag;
                _addSearchToRecents(tag);
                // Trigger search with the selected tag
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Searching for: $tag')),
                );
              }),
              const SizedBox(height: 24.0),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Popular Categories'),
                TextButton(
                  onPressed: () {
                    // Navigate to categories screen or show all categories
                    Navigator.pushNamed(context, '/categories');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            _buildTagList(
                dummyCategoriesNotifier.value.map((c) => c.name).toList(),
                onTap: (tag) {
              _searchController.text = tag;
              _addSearchToRecents(tag);
              // Trigger search with the selected category
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Searching in category: $tag')),
              );
            }),
            const SizedBox(height: 24.0),
            // Placeholder for keyboard (as seen in image)
            // In a real app, this would be handled by the system keyboard.
            // For UI simulation, we can add a dummy keyboard layout.
            // This is a simplified representation.
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _KeyButton(
                          text: 'Q',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'W',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'E',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'R',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'T',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'Y',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'U',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'I',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'O',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'P',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _KeyButton(
                          text: 'A',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'S',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'D',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'F',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'G',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'H',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'J',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'K',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'L',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _KeyButton(
                          text: 'Z',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'X',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'C',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'V',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'B',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'N',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'M',
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _KeyButton(
                          text: '123',
                          isSpecial: true,
                          textColor: Colors.white),
                      _KeyButton(
                          text: ',',
                          isSpecial: true,
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'space',
                          flex: 4,
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: '.',
                          isSpecial: true,
                          textColor:
                              Theme.of(context).textTheme.bodyLarge?.color),
                      _KeyButton(
                          text: 'return',
                          isSpecial: true,
                          textColor: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTagList(List<String> tags, {Function(String)? onTap}) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: tags
          .map((tag) => GestureDetector(
                onTap: onTap != null ? () => onTap(tag) : null,
                child: Chip(
                  backgroundColor: const Color(0xFF5CB85C).withAlpha(51),
                  label: Text(tag,
                      style: const TextStyle(color: Color(0xFF5CB85C))),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                ),
              ))
          .toList(),
    );
  }

  // Moved these methods inside the _SearchScreenState class
  Widget _buildKeyboardRow(List<String> keys, {bool isSpecialRow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys
            .map((key) => _buildKeyButton(key, isSpecialRow: isSpecialRow))
            .toList(),
      ),
    );
  }

  Widget _buildKeyButton(String key, {bool isSpecialRow = false}) {
    return Expanded(
      flex: key == 'space' ? 4 : (isSpecialRow ? 2 : 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: () {
            if (key == 'return') {
              _addSearchToRecents(_searchController.text);
              // Handle search submission
            } else if (key == 'space') {
              _searchController.text += ' ';
            } else if (key == '123') {
              // Toggle to numbers/symbols
            } else {
              _searchController.text += key.toLowerCase();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: key == 'return'
                ? const Color(0xFF5CB85C)
                : Theme.of(context).cardColor,
            foregroundColor: key == 'return'
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            minimumSize: const Size(0, 40), // Ensure minimum height
          ),
          child: Text(key, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String text;
  final int flex;
  final bool isSpecial;
  final Color? textColor;

  const _KeyButton({
    required this.text,
    this.flex = 1,
    this.isSpecial = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: () {
            // This is a dummy key button, actual logic would be in SearchScreen
            // For example: Provider.of<SearchController>(context, listen: false).addText(text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSpecial
                ? const Color(0xFF5CB85C)
                : Theme.of(context).cardColor,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            minimumSize: const Size(0, 40),
          ),
          child: Text(text, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
