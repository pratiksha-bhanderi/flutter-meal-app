import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';
import 'package:meal_app/core/utils/responsive_util.dart';
import 'package:meal_app/utils/image_paths.dart';

// --- MODEL ---
class AddedIngredient {
  final String imagePath;
  final Offset startPosition;
  final Offset endPosition;
  final double rotation;
  final int durationMs;
  final double sizeMultiplier;

  AddedIngredient({
    required this.imagePath,
    required this.startPosition,
    required this.endPosition,
    required this.rotation,
    required this.durationMs,
    this.sizeMultiplier = 1.0,
  });
}

// ============================================================
//  BURGER LAYER WIDGET
// ============================================================
class _BurgerLayer extends StatefulWidget {
  final String imagePath;
  final String name;
  final double width;
  final double height;

  const _BurgerLayer({
    super.key,
    required this.imagePath,
    required this.name,
    required this.width,
    required this.height,
  });

  @override
  State<_BurgerLayer> createState() => _BurgerLayerState();
}

class _BurgerLayerState extends State<_BurgerLayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _dropAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _dropAnim = Tween<double>(
      begin: -50,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _bgColorForIngredient(widget.name);
    // Slight random offset for "real" messy look
    final randomOffset = (widget.name.hashCode % 10) - 5.0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.translate(
        offset: Offset(randomOffset, _dropAnim.value),
        child: Opacity(opacity: _fadeAnim.value, child: child),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipPath(
          clipper: _WavyClipper(),
          child: Container(
            color: bgColor.withValues(alpha: 0.3),
            child: Image.asset(
              widget.imagePath,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  static Color _bgColorForIngredient(String name) {
    final n = name.toLowerCase();
    if (n.contains('lettuce')) return const Color(0xFF2E7D32);
    if (n.contains('cheese')) return const Color(0xFFF9A825);
    if (n.contains('tomato')) return const Color(0xFFC62828);
    if (n.contains('pickle')) return const Color(0xFF388E3C);
    if (n.contains('bacon')) return const Color(0xFF5D1A1A);
    if (n.contains('onion')) return const Color(0xFF6A1B9A);
    return const Color(0xFF9E9E9E);
  }
}

class _WavyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.1);
    // Wavy top
    for (double i = 0; i <= size.width; i += 15) {
      path.lineTo(i, size.height * 0.1 + (i % 30 == 0 ? 2.0 : -2.0));
    }
    path.lineTo(size.width, size.height * 0.9);
    // Wavy bottom
    for (double i = size.width; i >= 0; i -= 15) {
      path.lineTo(i, size.height * 0.9 + (i % 30 == 0 ? -2.0 : 2.0));
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ============================================================
//  BURGER BUILDER WIDGET
// ============================================================
class _BurgerBuilder extends StatelessWidget {
  final List<Map<String, dynamic>> layers;
  final double burgerWidth;

  const _BurgerBuilder({required this.layers, required this.burgerWidth});

  @override
  Widget build(BuildContext context) {
    final double bunW = burgerWidth;
    final double pattyW = burgerWidth * 2;

    final List<Widget> stackChildren = [];

    // 1. BOTTOM BUN ON PLATE
    stackChildren.add(
      Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 0, 0.001)
          ..rotateX(0.2),
        alignment: Alignment.center,
        child: _TransparentAsset(
          path: AppImagePaths.burgerBottomBun,
          width: bunW,
        ),
      ),
    );

    // 2. THE PATTY (Gourmet Grilled Patty)
    // stackChildren.add(
    //   Positioned(
    //     bottom: bunW * 0.18,
    //     left: (bunW * 1.2 - pattyW) / 4,
    //     child: Transform(
    //       transform: Matrix4.identity()
    //         ..setEntry(3, 2, 0.001)
    //         ..rotateX(0.2),
    //       alignment: Alignment.center,
    //       child: _TransparentAsset(
    //         path: 'assets/images/ingredients/custom/burger_patty.png',
    //         width: pattyW,
    //       ),
    //     ),
    //   ),
    // );

    // 3. ORGANIC INGREDIENT LAYERS
    double currentHeight = bunW * 0.5; // Start higher for better visibility

    for (var layer in layers) {
      final String path = layer['image'];
      final String name = layer['name'];

      stackChildren.add(
        Positioned(
          bottom: currentHeight,
          left: 0,
          right: 0,
          child: _OrganicLayer(imagePath: path, name: name, width: bunW),
        ),
      );
      currentHeight += bunW * 0.22; // More space for exploded view
    }

    // 4. TOP BUN
    stackChildren.add(
      Positioned(
        bottom: currentHeight + 10,
        left: (bunW * 1.2 - bunW) / 3,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(0.2),
          alignment: Alignment.center,
          child: _TransparentAsset(
            path: AppImagePaths.burgerTopBun,
            width: bunW,
          ),
        ),
      ),
    );

    return SizedBox(
      width: bunW,
      height: 480,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: stackChildren,
      ),
    );
  }
}

class _OrganicLayer extends StatelessWidget {
  final String imagePath;
  final String name;
  final double width;

  const _OrganicLayer({
    required this.imagePath,
    required this.name,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final r = math.Random(name.hashCode);
    final String label = name.toLowerCase();
    final bool isLettuce = label.contains('lettuce');
    final bool isCheese = label.contains('cheese');
    final bool isOnion = label.contains('onion');
    final bool isTomato = label.contains('tomato');
    final bool isPickle = label.contains('pickle');

    int pieces = 3;
    if (isLettuce || isCheese || isTomato)
      pieces = 1; // Tomato asset already has multiple slices
    else if (isPickle)
      pieces = 3;
    else if (isOnion)
      pieces = 4;

    return Center(
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(
            isTomato ? 0 : 0.4,
          ), // Preserve natural photo angle for tomato
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          height: width * 0.4,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(pieces, (i) {
              final double angle =
                  (i * (360 / pieces) + r.nextInt(20)) * (math.pi / 180);
              final double dist = (pieces > 1) ? width * 0.18 : 0;

              double sliceW = width * 0.45;
              if (isLettuce) sliceW = width * 1.1;
              if (isCheese) sliceW = width * 0.85;
              if (isPickle) sliceW = width * 0.35;
              if (isTomato)
                sliceW = width * 1.2; // Show the full photographic asset

              return Positioned(
                left: (width / 2 - sliceW / 2) + math.cos(angle) * dist,
                top: (width * 0.05) + math.sin(angle) * (width * 0.08),
                child: Transform.rotate(
                  angle: isTomato
                      ? 0
                      : r.nextDouble() *
                            2 *
                            math.pi, // No extra spin for tomato
                  child: _IndividualSlice(
                    path: imagePath,
                    width: sliceW,
                    isCheese: isCheese,
                    isRing: isOnion,
                    isRound: isPickle, // Tomato no longer needs ClipOval
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _IndividualSlice extends StatelessWidget {
  final String path;
  final double width;
  final bool isCheese;
  final bool isRing;
  final bool isRound;

  const _IndividualSlice({
    required this.path,
    required this.width,
    this.isCheese = false,
    this.isRing = false,
    this.isRound = false,
  });

  @override
  Widget build(BuildContext context) {
    if (path == 'ketchup') {
      return CustomPaint(
        size: Size(width, width * 0.3),
        painter: _KetchupPainter(seed: 0),
      );
    }

    if (isCheese && !path.contains('burger_cheese')) {
      return Container(
        width: width,
        height: width,
        decoration: BoxDecoration(
          color: const Color(0xFFFFD54F),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
      );
    }

    // Unified filter for transparent burger assets
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        1, 1, 1, 0, -40, // Removes black backgrounds
      ]),
      child: Image.asset(
        path,
        width: width,
        height: isRing ? width : width * 0.7,
        fit: isRing ? BoxFit.contain : BoxFit.fitHeight,
      ),
    );
  }
}

class _KetchupPainter extends CustomPainter {
  final int seed;
  _KetchupPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC62828)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    for (double x = 0; x <= size.width; x += 10) {
      path.lineTo(x, size.height * (0.4 + math.sin(x * 0.1) * 0.3));
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _RingClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addOval(
      Rect.fromLTWH(
        size.width * 0.15,
        size.height * 0.15,
        size.width * 0.7,
        size.height * 0.7,
      ),
    );
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _LeafyClipper extends CustomClipper<Path> {
  final int seed;
  _LeafyClipper({required this.seed});

  @override
  Path getClip(Size size) {
    final r = math.Random(seed);
    final path = Path();
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width * 0.45;

    for (int i = 0; i < 360; i += 10) {
      final double angle = i * math.pi / 180;
      final double wave = 5 + r.nextDouble() * 15;
      final double x =
          centerX + (radius + wave * math.sin(i * 0.1)) * math.cos(angle);
      final double y =
          centerY + (radius + wave * math.sin(i * 0.1)) * math.sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Helper to remove black/checkerboard from generated assets
class _TransparentAsset extends StatelessWidget {
  final String path;
  final double width;
  const _TransparentAsset({required this.path, required this.width});

  @override
  Widget build(BuildContext context) {
    // Intelligent filter to remove black backgrounds from gourmet assets
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        1, 0, 0, 0, 0,
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        1, 1, 1, 0, -50, // Turns black to transparent
      ]),
      child: Image.asset(path, width: width, fit: BoxFit.contain),
    );
  }
}

// Top bun with dome shape
class _TopBun extends StatelessWidget {
  final double width;
  final double height;
  const _TopBun({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppImagePaths.burgerTopBun,
      width: width,
      height: height * 1.4,
      fit: BoxFit.contain,
    );
  }
}

// ============================================================
//  MAIN SCREEN
// ============================================================
class IngredientSelectionScreen extends StatefulWidget {
  final Map<String, dynamic> meal;

  const IngredientSelectionScreen({super.key, required this.meal});

  @override
  State<IngredientSelectionScreen> createState() =>
      _IngredientSelectionScreenState();
}

class _IngredientSelectionScreenState extends State<IngredientSelectionScreen> {
  final List<AddedIngredient> _addedIngredients = [];
  final List<Map<String, dynamic>> _burgerLayers = []; // Ordered burger layers
  final Set<String> _activeIngredientPaths = {};
  bool _isCheeseAdded = false;

  List<Map<String, dynamic>> get _availableIngredients =>
      _getIngredientsForCategory(widget.meal['category'] ?? '');

  List<Map<String, dynamic>> _getIngredientsForCategory(String category) {
    switch (category) {
      case 'Pizza':
        return [
          {
            'name': 'Pepperoni',
            'image': 'assets/images/ingredients/pepperoni.png',
            'scale': 1.2,
            'ring': 0.75,
          },
          {
            'name': 'Mushroom',
            'image': 'assets/images/ingredients/mushroom.png',
            'scale': 0.9,
            'ring': 0.55,
          },
          {
            'name': 'Cheese',
            'image': 'assets/images/ingredients/cheese.png',
            'scale': 1.4,
            'ring': 0.4,
          },
          {
            'name': 'Basil',
            'image': 'assets/images/ingredients/basil.png',
            'scale': 0.8,
            'ring': 0.65,
          },
          {
            'name': 'Olive',
            'image': 'assets/images/ingredients/olive.png',
            'scale': 0.5,
            'ring': 0.3,
          },
          {
            'name': 'Bacon',
            'image': 'assets/images/ingredients/bacon.png',
            'scale': 1.1,
            'ring': 0.8,
          },
          {
            'name': 'Tomato',
            'image': 'assets/images/ingredients/tomato.png',
            'scale': 1.0,
            'ring': 0.45,
          },
          {
            'name': 'Chili',
            'image': 'assets/images/ingredients/chili_flakes.png',
            'scale': 0.4,
            'ring': 0.25,
          },
        ];
      case 'Burgers':
        return [
          {
            'name': 'Lettuce',
            'image': AppImagePaths.burgerLettuce,
            'scale': 1.2,
          },
          {'name': 'Cheese', 'image': AppImagePaths.burgerCheese, 'scale': 1.1},
          {'name': 'Tomato', 'image': AppImagePaths.burgerTomato, 'scale': 1.1},
          {
            'name': 'Pickles',
            'image': AppImagePaths.burgerPickle,
            'scale': 0.8,
          },
          {'name': 'Bacon', 'image': AppImagePaths.burgerBacon, 'scale': 1.1},
          {'name': 'Onion', 'image': AppImagePaths.burgerOnion, 'scale': 1.0},
          {'name': 'Ketchup', 'image': 'ketchup', 'scale': 1.0},
        ];
      case 'Salads':
        return [
          {
            'name': 'Avocado',
            'image': 'assets/images/ingredients/avocado.png',
            'scale': 1.0,
          },
          {
            'name': 'Feta',
            'image': 'assets/images/ingredients/feta.png',
            'scale': 0.5,
          },
          {
            'name': 'Croutons',
            'image': 'assets/images/ingredients/croutons.png',
            'scale': 0.6,
          },
          {
            'name': 'Tomato',
            'image': 'assets/images/ingredients/tomato.png',
            'scale': 0.9,
          },
        ];
      case 'Noodles':
      case 'Pasta':
        return [
          {
            'name': 'Egg',
            'image': 'assets/images/ingredients/egg.png',
            'scale': 1.0,
          },
          {
            'name': 'Shrimp',
            'image': 'assets/images/ingredients/shrimp.png',
            'scale': 0.9,
          },
          {
            'name': 'Parmesan',
            'image': 'assets/images/ingredients/parmesan.png',
            'scale': 0.7,
          },
          {
            'name': 'Chili',
            'image': 'assets/images/ingredients/chili_flakes.png',
            'scale': 0.4,
          },
        ];
      case 'Desserts':
        return [
          {
            'name': 'Strawberry',
            'image': 'assets/images/ingredients/strawberry.png',
            'scale': 0.9,
          },
          {
            'name': 'Choc Chips',
            'image': 'assets/images/ingredients/chocolate_chips.png',
            'scale': 0.4,
          },
        ];
      default:
        return [
          {
            'name': 'Tomato',
            'image': 'assets/images/ingredients/tomato.png',
            'scale': 1.0,
          },
          {
            'name': 'Cheese',
            'image': 'assets/images/ingredients/cheese.png',
            'scale': 1.2,
          },
          {
            'name': 'Basil',
            'image': 'assets/images/ingredients/basil.png',
            'scale': 0.8,
          },
          {
            'name': 'Olive',
            'image': 'assets/images/ingredients/olive.png',
            'scale': 0.5,
          },
        ];
    }
  }

  void _onTapIngredient(
    Map<String, dynamic> ingredient,
    Offset tapPos,
    Offset centerPos,
    double mealRadius,
    int index,
  ) {
    final imagePath = ingredient['image'] as String;
    final category = widget.meal['category'] ?? '';

    // TOGGLE off
    if (_activeIngredientPaths.contains(imagePath)) {
      setState(() {
        _activeIngredientPaths.remove(imagePath);
        if (category == 'Burgers') {
          _burgerLayers.removeWhere((l) => l['image'] == imagePath);
        } else {
          _addedIngredients.removeWhere((i) => i.imagePath == imagePath);
          if (imagePath.contains('cheese')) _isCheeseAdded = false;
        }
      });
      return;
    }

    if (category == 'Burgers') {
      setState(() {
        _burgerLayers.add(ingredient);
        _activeIngredientPaths.add(imagePath);
      });
      return;
    }

    // --- Pizza / others: flying animation ---
    if (imagePath.contains('cheese') && category == 'Pizza') {
      setState(() {
        _isCheeseAdded = true;
        _activeIngredientPaths.add(imagePath);
      });
      return;
    }

    final random = math.Random();
    final int numPieces = (category == 'Pizza') ? 7 : (random.nextInt(3) + 3);
    final double typeAngleOffset = index * 0.4;
    final newItems = <AddedIngredient>[];
    final scaleMultiplier = ingredient['scale'] as double? ?? 1.0;
    final preferredRing = ingredient['ring'] as double?;

    for (int i = 0; i < numPieces; i++) {
      double angle, distance;
      if (category == 'Pizza') {
        if (i == 0) {
          angle = 0;
          distance = 0;
        } else {
          angle = ((i - 1) * (2 * math.pi / (numPieces - 1))) + typeAngleOffset;
          angle += (random.nextDouble() - 0.5) * 0.1;
          final ringBase = preferredRing ?? 0.6;
          distance = mealRadius * (ringBase + random.nextDouble() * 0.03);
        }
      } else if (category == 'Burgers') {
        // Cluster on the burger patty area
        angle = random.nextDouble() * 2 * math.pi;
        distance = math.sqrt(random.nextDouble()) * (mealRadius * 0.5);
      } else {
        angle = random.nextDouble() * 2 * math.pi;
        distance = math.sqrt(random.nextDouble()) * (mealRadius * 0.85);
      }

      final endX = centerPos.dx + distance * math.cos(angle);
      // For burger, we offset slightly down to land on the patty
      final endY =
          centerPos.dy +
          distance * math.sin(angle) +
          (category == 'Burgers' ? context.h(20) : 0);

      newItems.add(
        AddedIngredient(
          imagePath: imagePath,
          startPosition: tapPos,
          endPosition: Offset(endX, endY),
          rotation: random.nextDouble() * 2 * math.pi,
          durationMs: 500 + random.nextInt(300),
          sizeMultiplier: scaleMultiplier,
        ),
      );
    }

    setState(() {
      _addedIngredients.addAll(newItems);
      _activeIngredientPaths.add(imagePath);
    });
  }

  Widget _buildDishBase(
    String category,
    double radius,
    ColorScheme cs,
    bool isDark,
  ) {
    switch (category) {
      case 'Pizza':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFE25822), Color(0xFFD2691E)],
                  stops: [0.85, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            if (_isCheeseAdded)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, val, _) => Opacity(
                  opacity: val,
                  child: Container(
                    width: radius * 1.75,
                    height: radius * 1.75,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFFFFDE7),
                          Color(0xFFFFF59D),
                          Color(0xFFFFD54F),
                        ],
                        stops: [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      case 'Noodles':
      case 'Pasta':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            Container(
              width: radius * 1.6,
              height: radius * 1.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFF9C4).withValues(alpha: 0.9),
                    const Color(0xFFFBC02D).withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: CustomPaint(painter: _NoodlePainter()),
            ),
          ],
        );
      case 'Salads':
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            Container(
              width: radius * 1.6,
              height: radius * 1.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF81C784).withValues(alpha: 0.8),
                    const Color(0xFF388E3C).withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ],
        );
      case 'Desserts':
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        );
      default:
        return Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isBurger = widget.meal['category'] == 'Burgers';

    final centerX = screenWidth / 2;
    final centerY = screenHeight * 0.45;
    final centerPos = Offset(centerX, centerY);
    final mealRadius = context.w(140);
    final burgerWidth = screenWidth * 0.85;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customize',
          style: AppTextStyles.font(
            context,
            color: cs.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ---- MAIN VIEW ----
          Positioned(
            left: centerX - mealRadius * 1.2,
            top: isBurger ? screenHeight * 0.05 : centerY - mealRadius,
            child: isBurger
                ? _BurgerBuilder(
                    layers: _burgerLayers,
                    burgerWidth: burgerWidth,
                  )
                : _buildDishBase(
                    widget.meal['category'] ?? '',
                    mealRadius,
                    cs,
                    isDark,
                  ),
          ),

          // ---- FLYING INGREDIENTS (Only for non-burger items) ----
          if (!isBurger)
            ..._addedIngredients.map((ing) {
              return TweenAnimationBuilder<double>(
                key: ObjectKey(ing),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: ing.durationMs),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  final currentPos = Offset.lerp(
                    ing.startPosition,
                    ing.endPosition,
                    val,
                  )!;
                  final scale = 1.0 + math.sin(val * math.pi) * 0.5;
                  final size = context.w(50) * ing.sizeMultiplier;

                  return Positioned(
                    left: currentPos.dx - size / 2,
                    top: currentPos.dy - size / 2,
                    child: Transform.rotate(
                      angle: ing.rotation * val,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: 0.1 * val,
                                ),
                                blurRadius: 3,
                                spreadRadius: -1,
                                offset: Offset(1.5 * val, 2 * val),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            ing.imagePath,
                            width: size,
                            height: size,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

          // ---- INGREDIENT SELECTOR ----
          Positioned(
            bottom: context.h(130),
            left: 0,
            right: 0,
            height: context.h(110),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              scrollDirection: Axis.horizontal,
              itemCount: _availableIngredients.length,
              separatorBuilder: (_, __) => SizedBox(width: context.w(16)),
              itemBuilder: (context, index) {
                final ingredient = _availableIngredients[index];
                final bool isActive = _activeIngredientPaths.contains(
                  ingredient['image'],
                );
                return GestureDetector(
                  onTapUp: (details) => _onTapIngredient(
                    ingredient,
                    details.globalPosition,
                    centerPos,
                    mealRadius,
                    index,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: context.w(4)),
                    padding: EdgeInsets.all(context.w(10)),
                    decoration: BoxDecoration(
                      color: isActive
                          ? cs.primary.withValues(alpha: 0.1)
                          : (isDark ? AppColors.darkGrey : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? cs.primary : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: context.w(45),
                          height: context.w(45),
                          child: ClipOval(
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.matrix([
                                1.5,
                                0,
                                0,
                                0,
                                -100,
                                0,
                                1.5,
                                0,
                                0,
                                -100,
                                0,
                                0,
                                1.5,
                                0,
                                -100,
                                1,
                                1,
                                1,
                                0,
                                -250,
                              ]),
                              child: ingredient['image'] == 'ketchup'
                                  ? CustomPaint(
                                      size: const Size(40, 40),
                                      painter: _KetchupPainter(seed: 0),
                                    )
                                  : Image.asset(
                                      ingredient['image'],
                                      width: context.w(35),
                                      fit: BoxFit.contain,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(8)),
                        Text(
                          ingredient['name'],
                          style: AppTextStyles.font(
                            context,
                            color: isActive ? cs.primary : cs.onSurface,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ---- BOTTOM ACTION ----
          Positioned(
            bottom: context.h(40),
            left: context.w(24),
            right: context.w(24),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: context.h(20),
                horizontal: context.w(24),
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Additions',
                        style: AppTextStyles.font(
                          context,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${isBurger ? _burgerLayers.length : _addedIngredients.length} Items',
                        style: AppTextStyles.font(
                          context,
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.w(20),
                        vertical: context.h(12),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Done',
                        style: AppTextStyles.font(
                          context,
                          color: AppColors.primaryOrange,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  PAINTERS
// ============================================================
class _NoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFE082).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final r = math.Random(42);
    for (int i = 0; i < 15; i++) {
      final path = Path();
      path.moveTo(
        size.width * (0.2 + r.nextDouble() * 0.6),
        size.height * (0.2 + r.nextDouble() * 0.6),
      );
      for (int j = 0; j < 3; j++) {
        path.quadraticBezierTo(
          size.width * r.nextDouble(),
          size.height * r.nextDouble(),
          size.width * (0.2 + r.nextDouble() * 0.6),
          size.height * (0.2 + r.nextDouble() * 0.6),
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
