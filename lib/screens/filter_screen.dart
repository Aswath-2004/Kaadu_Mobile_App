// filter_screen.dart
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // To use dummyCategories and dummyProducts

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Filter states (dummy values)
  String? _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(5.0, 100.0);
  double _selectedRating = 0.0; // 0 for any, 3.0 for 3+ etc.
  String? _selectedDeliveryTime;
  String? _selectedAvailability =
      'All'; // New: 'All', 'In Stock', 'Out of Stock'
  List<String> _selectedUnits = []; // New: Multiple unit selection

  final List<String> _deliveryTimeOptions = const [
    '0-15 min',
    '15-30 min',
    '30-60 min',
    '60+ min'
  ];

  // Get unique units from dummy products
  List<String> get _uniqueUnits {
    Set<String> units = {};
    for (var product in dummyProducts) {
      units.add(product.unit);
    }
    return units.toList()..sort(); // Sort for consistent display
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter'),
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterSectionTitle('Categories'),
            _buildCategoryFilter(),
            const SizedBox(height: 24.0),
            _buildFilterSectionTitle('Price'),
            _buildPriceFilter(),
            const SizedBox(height: 24.0),
            _buildFilterSectionTitle('Rating'),
            _buildRatingFilter(),
            const SizedBox(height: 24.0),
            _buildFilterSectionTitle('Availability'), // New section
            _buildAvailabilityFilter(),
            const SizedBox(height: 24.0),
            _buildFilterSectionTitle('Unit'), // New section
            _buildUnitFilter(),
            const SizedBox(height: 24.0),
            _buildFilterSectionTitle('Delivery Time'),
            _buildDeliveryTimeFilter(),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reset filters
                      setState(() {
                        _selectedCategory = 'All';
                        _priceRange = const RangeValues(5.0, 100.0);
                        _selectedRating = 0.0;
                        _selectedDeliveryTime = null;
                        _selectedAvailability = 'All';
                        _selectedUnits = [];
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withAlpha((255 * 0.3).round()) ??
                              Colors.white30,
                          width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      'Reset', // Changed from Cancel to Reset
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply filters and navigate back
                      Navigator.pop(context, {
                        'category': _selectedCategory,
                        'priceRange': _priceRange,
                        'rating': _selectedRating,
                        'deliveryTime': _selectedDeliveryTime,
                        'availability': _selectedAvailability, // New filter
                        'units': _selectedUnits, // New filter
                      });
                    },
                    child: const Text('Show Results'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
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

  Widget _buildCategoryFilter() {
    return ValueListenableBuilder<List<Category>>(
      valueListenable: dummyCategoriesNotifier,
      builder: (context, categories, child) {
        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            'All',
            ...categories.map((c) => c.name).toList(),
          ].map((categoryName) {
            final isSelected = _selectedCategory == categoryName;
            return ChoiceChip(
              label: Text(categoryName),
              selected: isSelected,
              selectedColor: const Color(0xFF5CB85C),
              backgroundColor: Theme.of(context).cardColor,
              labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha((255 * 0.7).round())),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF5CB85C)
                        : Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withAlpha((255 * 0.3).round()) ??
                            Colors.white30),
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? categoryName : null;
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '₹${_priceRange.start.toStringAsFixed(2)} - ₹${_priceRange.end.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF5CB85C),
            inactiveTrackColor: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withAlpha((255 * 0.3).round()) ??
                Colors.white30,
            thumbColor: const Color(0xFF5CB85C),
            overlayColor: const Color(0xFF5CB85C).withAlpha(51),
            valueIndicatorColor: const Color(0xFF5CB85C),
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: 0.0,
            max: 500.0, // Increased max price for dummy data
            divisions: 500,
            labels: RangeLabels(
              _priceRange.start.toStringAsFixed(2),
              _priceRange.end.toStringAsFixed(2),
            ),
            onChanged: (newRange) {
              setState(() {
                _priceRange = newRange;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Wrap(
      // Changed from Row to Wrap to prevent overflow
      spacing: 8.0, // Horizontal spacing between chips
      runSpacing: 8.0, // Vertical spacing between lines of chips
      children: [
        _buildRatingButton(context, 3.0),
        _buildRatingButton(context, 4.0),
        _buildRatingButton(context, 4.5),
        _buildRatingButton(context, 5.0),
      ],
    );
  }

  Widget _buildRatingButton(BuildContext context, double rating) {
    final isSelected = _selectedRating == rating;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRating = rating;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5CB85C)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: isSelected
                  ? const Color(0xFF5CB85C)
                  : Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withAlpha((255 * 0.3).round()) ??
                      Colors.white30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded,
                color: isSelected ? Colors.white : Colors.amber, size: 18),
            const SizedBox(width: 4.0),
            Text(
              '${rating.toStringAsFixed(1)} ${rating == 5.0 ? '' : 'or higher'}',
              style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha((255 * 0.7).round())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityFilter() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: ['All', 'In Stock', 'Out of Stock'].map((availability) {
        final isSelected = _selectedAvailability == availability;
        return ChoiceChip(
          label: Text(availability),
          selected: isSelected,
          selectedColor: const Color(0xFF5CB85C),
          backgroundColor: Theme.of(context).cardColor,
          labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.7).round())),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
                color: isSelected
                    ? const Color(0xFF5CB85C)
                    : Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha((255 * 0.3).round()) ??
                        Colors.white30),
          ),
          onSelected: (selected) {
            setState(() {
              _selectedAvailability = selected ? availability : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildUnitFilter() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _uniqueUnits.map((unit) {
        final isSelected = _selectedUnits.contains(unit);
        return ChoiceChip(
          label: Text(unit),
          selected: isSelected,
          selectedColor: const Color(0xFF5CB85C),
          backgroundColor: Theme.of(context).cardColor,
          labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.7).round())),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
                color: isSelected
                    ? const Color(0xFF5CB85C)
                    : Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha((255 * 0.3).round()) ??
                        Colors.white30),
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedUnits.add(unit);
              } else {
                _selectedUnits.remove(unit);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDeliveryTimeFilter() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _deliveryTimeOptions.map((time) {
        final isSelected = _selectedDeliveryTime == time;
        return ChoiceChip(
          label: Text(time),
          selected: isSelected,
          selectedColor: const Color(0xFF5CB85C),
          backgroundColor: Theme.of(context).cardColor,
          labelStyle: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withAlpha((255 * 0.7).round())),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(
                color: isSelected
                    ? const Color(0xFF5CB85C)
                    : Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha((255 * 0.3).round()) ??
                        Colors.white30),
          ),
          onSelected: (selected) {
            setState(() {
              _selectedDeliveryTime = selected ? time : null;
            });
          },
        );
      }).toList(),
    );
  }
}
