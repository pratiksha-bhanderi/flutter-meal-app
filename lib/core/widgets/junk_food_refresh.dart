import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:meal_app/core/theme/app_styles.dart';

class JunkFoodRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const JunkFoodRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<JunkFoodRefresh> createState() => _JunkFoodRefreshState();
}

class _JunkFoodRefreshState extends State<JunkFoodRefresh> with TickerProviderStateMixin {
  late AnimationController _rainbowController;
  late AnimationController _spinController;
  
  double _pullDistance = 0.0;
  bool _isRefreshing = false;
  bool _canRefresh = false;
  
  final double _triggerDistance = 110.0;
  final double _maxPullDistance = 140.0;
  
  final List<String> _emojis = ['🍔', '🍕', '🍟', '🍩', '🌮', '🌭', '🍦'];
  late String _currentEmoji;

  @override
  void initState() {
    super.initState();
    _currentEmoji = _emojis[0];
    
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _rainbowController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _updateEmoji() {
    setState(() {
      _currentEmoji = _emojis[math.Random().nextInt(_emojis.length)];
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels < 0) {
        setState(() {
          _pullDistance = notification.metrics.pixels.abs().clamp(0.0, _maxPullDistance);
          _canRefresh = _pullDistance >= _triggerDistance;
        });
      } else if (_pullDistance > 0) {
        setState(() {
          _pullDistance = 0;
          _canRefresh = false;
        });
      }
    } else if (notification is ScrollEndNotification) {
      if (_canRefresh && !_isRefreshing) {
        _startRefresh();
      } else {
        setState(() {
          _pullDistance = 0;
          _canRefresh = false;
        });
      }
    }
    return false;
  }

  Future<void> _startRefresh() async {
    setState(() {
      _isRefreshing = true;
      _pullDistance = _triggerDistance;
    });
    
    _spinController.repeat();
    _updateEmoji();

    await widget.onRefresh();

    if (mounted) {
      _spinController.stop();
      _spinController.reset();
      setState(() {
        _isRefreshing = false;
        _pullDistance = 0;
        _canRefresh = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: Stack(
        children: [
          // The Scrollable Child
          widget.child,

          // The Refresh Indicator Overlay
          if (_pullDistance > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildRefreshUI(),
            ),
        ],
      ),
    );
  }

  Widget _buildRefreshUI() {
    final double opacity = (_pullDistance / _triggerDistance).clamp(0.0, 1.0);
    final double scale = (_pullDistance / _triggerDistance).clamp(0.2, 1.2);
    
    return Container(
      height: _pullDistance,
      width: double.infinity,
      clipBehavior: Clip.none,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rainbow Gradient Bar
          AnimatedBuilder(
            animation: _rainbowController,
            builder: (context, child) {
              return Container(
                height: 4,
                width: double.infinity,
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: List.generate(6, (index) {
                      return HSVColor.fromAHSV(
                        1.0,
                        ((index * 60) + (_rainbowController.value * 360)) % 360,
                        0.8,
                        1.0,
                      ).toColor();
                    }),
                  ),
                ),
              );
            },
          ),
          
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji
              AnimatedBuilder(
                animation: _spinController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _isRefreshing ? _spinController.value * 2 * math.pi : 0,
                    child: Transform.scale(
                      scale: scale,
                      child: Text(
                        _currentEmoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              
              // Text
              Opacity(
                opacity: opacity,
                child: Text(
                  _isRefreshing
                      ? "Loading junk food..."
                      : (_canRefresh ? "Release to refresh!" : "Pull for junk food!"),
                  style: AppTextStyles.font(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _canRefresh ? AppColors.primaryOrange : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
