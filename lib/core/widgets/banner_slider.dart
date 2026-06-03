import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_lube/models/banner_model.dart';
import 'package:auto_lube/core/widgets/banner_widget.dart';
import 'package:auto_lube/core/widgets/shimmer_widget.dart';

class BannerSlider extends StatefulWidget {
  final List<BannerModel> banners;
  final bool isLoading;
  final double height;

  const BannerSlider({
    super.key,
    required this.banners,
    this.isLoading = false,
    this.height = 180.0,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (!widget.isLoading) {
      _startAutoScroll();
    }
  }

  @override
  void didUpdateWidget(covariant BannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isLoading && oldWidget.isLoading) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.banners.isEmpty) return;
      
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    // Restart timer when user swiped manually
    _startAutoScroll();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
            ),
            child: const ShimmerBox(width: double.infinity, height: double.infinity),
          ),
        ),
      );
    }

    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.banners.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final banner = widget.banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: BannerWidget(
                  banner: banner,
                  height: widget.height,
                ),
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 6.0,
                width: _currentPage == index ? 24.0 : 6.0,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF007AFF)
                      : const Color(0xFFC7C7CC),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
