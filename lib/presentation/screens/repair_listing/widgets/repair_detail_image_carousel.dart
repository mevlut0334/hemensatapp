// lib/presentation/screens/repair_listing/widgets/repair_detail_image_carousel.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';

class RepairDetailImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const RepairDetailImageCarousel({
    super.key,
    required this.imageUrls,
  });

  @override
  State<RepairDetailImageCarousel> createState() => _RepairDetailImageCarouselState();
}

class _RepairDetailImageCarouselState extends State<RepairDetailImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<String> _validImageUrls;

  @override
  void initState() {
    super.initState();
    _validImageUrls = _validateAndFilterImageUrls(widget.imageUrls);
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(RepairDetailImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls != widget.imageUrls) {
      _validImageUrls = _validateAndFilterImageUrls(widget.imageUrls);
    }
  }

  List<String> _validateAndFilterImageUrls(List<String> urls) {
    if (urls.isEmpty) {
      return [];
    }

    return urls.where((url) {
      // Boş veya null kontrolü
      if (url.isEmpty) {
        return false;
      }

      // URL format kontrolü
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return false;
      }

      // Temel URL yapı kontrolü
      try {
        Uri.parse(url);
        return true;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Geçerli görsel yoksa placeholder göster
    if (_validImageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return Stack(
      children: [
        // Görsel Carousel
        SizedBox(
          height: 350,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _validImageUrls.length,
            itemBuilder: (context, index) {
              return _buildImageItem(context, index);
            },
          ),
        ),

        // Gradient overlay (alt kısım)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),

        // Sayfa göstergeleri (dots)
        if (_validImageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _validImageUrls.length,
                (index) => _buildDotIndicator(index),
              ),
            ),
          ),

        // Görsel sayısı badge (sağ üst)
        if (_validImageUrls.length > 1)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.image,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentPage + 1}/${_validImageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageItem(BuildContext context, int index) {
    final imageUrl = _validImageUrls[index];

    return GestureDetector(
      onTap: () => _openFullScreen(context, index),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        httpHeaders: const {
          'Connection': 'keep-alive',
          'Accept': 'image/*',
        },
        placeholder: (context, url) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
        errorWidget: (context, url, error) {
          return _buildErrorPlaceholder(url);
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
        memCacheWidth: 1000,
        memCacheHeight: 1000,
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 350,
      width: double.infinity,
      color: AppColors.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android,
              size: 80,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Görsel bulunamadı',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder(String url) {
    return Container(
      height: 350,
      width: double.infinity,
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Görsel yüklenemedi',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                url.length > 50 ? '${url.substring(0, 50)}...' : url,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreen(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          imageUrls: _validImageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// Tam ekran görsel görüntüleyici
class _FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentPage + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                httpHeaders: const {
                  'Connection': 'keep-alive',
                  'Accept': 'image/*',
                },
                placeholder: (context, url) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Görsel yüklenemedi',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                fadeInDuration: const Duration(milliseconds: 300),
              ),
            ),
          );
        },
      ),
    );
  }
}