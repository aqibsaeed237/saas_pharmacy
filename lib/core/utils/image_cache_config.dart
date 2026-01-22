import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Image cache configuration for cross-platform image caching
class ImageCacheConfig {
  /// Configure image cache settings
  static void configure() {
    // Set image cache size (50MB)
    PaintingBinding.instance.imageCache.maximumSize = 50 * 1024 * 1024;
    
    // Set image cache object count
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100;
  }

  /// Clear image cache
  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Precache images
  static Future<void> precacheImageProvider(ImageProvider provider, BuildContext context) {
    return precacheImage(provider, context);
  }
}

/// Custom cached network image widget
class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? 
        const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => errorWidget ?? 
        const Icon(Icons.error),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );
  }
}

