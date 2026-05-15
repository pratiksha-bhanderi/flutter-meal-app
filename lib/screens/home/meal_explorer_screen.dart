import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/router/app_router.dart';
import 'package:meal_app/core/providers/cart_provider.dart';
import 'package:meal_app/core/providers/favourites_provider.dart';
import 'package:meal_app/core/widgets/meal_card.dart';
import 'package:meal_app/core/widgets/junk_food_refresh.dart';
import 'package:meal_app/core/providers/data_provider.dart';
import 'package:provider/provider.dart';

class MealExplorerScreen extends StatefulWidget {
  final String? category;
  final bool showBackButton;

  const MealExplorerScreen({
    super.key,
    this.category,
    this.showBackButton = true,
  });

  @override
  State<MealExplorerScreen> createState() => _MealExplorerScreenState();
}

class _MealExplorerScreenState extends State<MealExplorerScreen> {
  late String _currentCategory;
  String _searchQuery = '';
  RangeValues _priceRange = const RangeValues(0, 50);
  bool _topRatedOnly = false;
  final TextEditingController _searchController = TextEditingController();

  // Advanced Filters
  final Set<String> _selectedMeals = {};
  final Set<String> _selectedCourses = {};
  RangeValues _servingRange = const RangeValues(0, 10);
  RangeValues _prepTimeRange = const RangeValues(0, 60);

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.category ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = Provider.of<DataProvider>(context);
    final title = _currentCategory == 'All' ? 'All Meals' : _currentCategory;

    if (data.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Filter meals based on all criteria
    final filteredMeals = data.meals.where((meal) {
      final matchesCategory =
          _currentCategory == 'All' || meal['category'] == _currentCategory;
      final matchesSearch = meal['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());

      // Parse price (assuming format "$12.99")
      final priceStr = meal['price'].toString().replaceAll('\$', '');
      final price = double.tryParse(priceStr) ?? 0.0;
      final matchesPrice = price >= _priceRange.start && price <= _priceRange.end;

      // For mock purposes, assume meals with price > 13 are "top rated"
      final isTopRated = price > 13.0;
      final matchesRating = !_topRatedOnly || isTopRated;

      // Advanced Filters Logic
      final matchesMealType =
          _selectedMeals.isEmpty || _selectedMeals.contains(meal['mealType']);
      final matchesCourse = _selectedCourses.isEmpty ||
          _selectedCourses.contains(meal['course']);

      final servings = (meal['servings'] as num?)?.toDouble();
      final matchesServings = servings == null ||
          (servings >= _servingRange.start && servings <= _servingRange.end);

      final prepTime = (meal['prepTime'] as num?)?.toDouble();
      final matchesPrepTime = prepTime == null ||
          (prepTime >= _prepTimeRange.start && prepTime <= _prepTimeRange.end);

      return matchesCategory &&
          matchesSearch &&
          matchesPrice &&
          matchesRating &&
          matchesMealType &&
          matchesCourse &&
          matchesServings &&
          matchesPrepTime;
    }).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: cs.onSurface,
                  size: context.sp(20),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  Navigator.pop(context);
                },
              )
            : null,
        automaticallyImplyLeading: false,
        title: Text(
          title,
          style: AppTextStyles.font(
            context,
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: JunkFoodRefresh(
        onRefresh: () => data.loadData(),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.w(24),
                context.h(8),
                context.w(24),
                context.h(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline.withOpacity(0.5)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search pizza, burger...',
                          hintStyle: AppTextStyles.font(
                            context,
                            fontSize: 14,
                            color: cs.onSurface.withOpacity(0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: cs.onSurface.withOpacity(0.4),
                            size: context.sp(20),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: context.h(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: context.w(12)),
                  _filterBtn(context, cs),
                ],
              ),
            ),

            // Filter Chips (Categories)
            _buildFilters(context, cs),

            if (filteredMeals.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: context.sp(60),
                        color: cs.onSurface.withOpacity(0.1),
                      ),
                      SizedBox(height: context.h(16)),
                      Text(
                        'No results found',
                        style: AppTextStyles.font(
                          context,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    context.w(24),
                    context.h(16),
                    context.w(24),
                    context.h(32),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: context.w(16),
                    mainAxisSpacing: context.h(16),
                    childAspectRatio: 0.78,
                  ),
                  itemCount: filteredMeals.length,
                  itemBuilder: (context, index) {
                    final meal = filteredMeals[index];
                    return MealCard(
                      meal: meal,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRouter.mealDetail,
                          arguments: {
                            'meals': filteredMeals,
                            'index': index,
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterBtn(BuildContext context, ColorScheme cs) {
    final hasActiveFilters = _priceRange != const RangeValues(0, 50) ||
        _topRatedOnly ||
        _selectedMeals.isNotEmpty ||
        _selectedCourses.isNotEmpty ||
        _servingRange != const RangeValues(0, 10) ||
        _prepTimeRange != const RangeValues(0, 60);

    return GestureDetector(
      onTap: () => _showFilterSheet(context, cs),
      child: Container(
        padding: EdgeInsets.all(context.w(12)),
        decoration: BoxDecoration(
          color: hasActiveFilters ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasActiveFilters ? cs.primary : cs.outline.withOpacity(0.5),
          ),
        ),
        child: Icon(
          Icons.tune_rounded,
          color: hasActiveFilters ? Colors.white : cs.onSurface,
          size: context.sp(22),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (_, controller) => Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: EdgeInsets.symmetric(vertical: context.h(12)),
                    width: context.w(40),
                    height: context.h(4),
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Content
                  Expanded(
                    child: ListView(
                      controller: controller,
                      padding: EdgeInsets.fromLTRB(
                        context.w(24),
                        0,
                        context.w(24),
                        context.h(24),
                      ),
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Filter',
                              style: AppTextStyles.font(
                                context,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  _priceRange = const RangeValues(0, 50);
                                  _topRatedOnly = false;
                                  _selectedMeals.clear();
                                  _selectedCourses.clear();
                                  _servingRange = const RangeValues(0, 10);
                                  _prepTimeRange = const RangeValues(0, 60);
                                });
                                setState(() {});
                              },
                              child: Text(
                                'Reset',
                                style: AppTextStyles.font(
                                  context,
                                  fontSize: 15,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: context.h(32)),

                        // Price Section
                        _buildRangeSection(
                          context: context,
                          title: 'Price Range',
                          values: _priceRange,
                          min: 0,
                          max: 50,
                          unit: '',
                          isPrice: true,
                          onChanged: (val) {
                            setSheetState(() => _priceRange = val);
                            setState(() => _priceRange = val);
                          },
                          cs: cs,
                        ),

                        _buildDivider(context, cs),

                        // Meal Section
                        _buildFilterSectionTitle(context, 'Meal'),
                        SizedBox(height: context.h(12)),
                        _buildFilterChips(
                          context,
                          ['Breakfast', 'Brunch', 'Lunch', 'Dinner'],
                          _selectedMeals,
                          setSheetState,
                          cs,
                        ),

                        _buildDivider(context, cs),

                        // Course Section
                        _buildFilterSectionTitle(context, 'Course'),
                        SizedBox(height: context.h(12)),
                        _buildFilterChips(
                          context,
                          [
                            'Soup',
                            'Appetizer',
                            'Starter',
                            'Main Dish',
                            'Side',
                            'Dessert',
                            'Drinks',
                          ],
                          _selectedCourses,
                          setSheetState,
                          cs,
                        ),

                        _buildDivider(context, cs),

                        // Serving Section
                        _buildRangeSection(
                          context: context,
                          title: 'Serving',
                          values: _servingRange,
                          min: 0,
                          max: 10,
                          unit: '',
                          onChanged: (val) {
                            setSheetState(() => _servingRange = val);
                            setState(() => _servingRange = val);
                          },
                          cs: cs,
                        ),

                        _buildDivider(context, cs),

                        // Preparation Time Section
                        _buildRangeSection(
                          context: context,
                          title: 'Preparation Time',
                          values: _prepTimeRange,
                          min: 0,
                          max: 60,
                          unit: ' mins',
                          onChanged: (val) {
                            setSheetState(() => _prepTimeRange = val);
                            setState(() => _prepTimeRange = val);
                          },
                          cs: cs,
                        ),

                        SizedBox(height: context.h(40)),

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          height: context.h(60),
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'Apply',
                              style: AppTextStyles.font(
                                context,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildFilterSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.font(
        context,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildDivider(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.h(24)),
      child: Divider(color: cs.outline.withOpacity(0.5), height: 1),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    List<String> options,
    Set<String> selectedSet,
    StateSetter setSheetState,
    ColorScheme cs,
  ) {
    return Wrap(
      spacing: context.w(10),
      runSpacing: context.h(10),
      children: options.map((opt) {
        final isSelected = selectedSet.contains(opt);
        return GestureDetector(
          onTap: () {
            setSheetState(() {
              if (isSelected) {
                selectedSet.remove(opt);
              } else {
                selectedSet.add(opt);
              }
            });
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(20),
              vertical: context.h(10),
            ),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : cs.outline.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              opt,
              style: AppTextStyles.font(
                context,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : cs.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRangeSection({
    required BuildContext context,
    required String title,
    required RangeValues values,
    required double min,
    required double max,
    required String unit,
    bool isPrice = false,
    required Function(RangeValues) onChanged,
    required ColorScheme cs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.font(
                context,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Set Manually',
              style: AppTextStyles.font(
                context,
                fontSize: 13,
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(20)),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: cs.primary,
          inactiveColor: cs.primary.withOpacity(0.1),
          onChanged: onChanged,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPrice ? '\$${values.start.toInt()}' : '${values.start.toInt()}$unit',
                style: AppTextStyles.font(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                isPrice ? '\$${values.end.toInt()}' : '${values.end.toInt()}$unit',
                style: AppTextStyles.font(
                  context,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, ColorScheme cs) {
    final filters = [
      'All',
      'Pizza',
      'Burgers',
      'Fries',
      'Noodles',
      'Salads',
      'Desserts',
      'Pasta',
    ];
    return SizedBox(
      height: context.h(50),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filterName = filters[index];
          final isSelected = _currentCategory == filterName;

          return Container(
            margin: EdgeInsets.only(right: context.w(10)),
            child: FilterChip(
              avatar: filterName == 'All'
                  ? Icon(
                      Icons.grid_view_rounded,
                      size: context.sp(20),
                      color: isSelected
                          ? cs.primary
                          : cs.onSurface.withOpacity(0.5),
                    )
                  : null,
              label: Text(filterName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  setState(() => _currentCategory = filterName);
                }
              },
              backgroundColor: cs.surface,
              selectedColor: cs.primary.withOpacity(0.1),
              checkmarkColor: cs.primary,
              labelStyle: AppTextStyles.font(
                context,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.6),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? cs.primary : cs.outline.withOpacity(0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

