import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/shared/widgets/cached_network_image_widget.dart';

/// Диалог с каруселью изображений товара.
/// Позволяет быстро просмотреть все фото без перехода в детали товара.
class ProductImagesCarouselDialog extends StatefulWidget {
  final List<ImageData> images;
  final String productTitle;
  final int initialIndex;

  const ProductImagesCarouselDialog({
    super.key,
    required this.images,
    required this.productTitle,
    this.initialIndex = 0,
  });

  /// Показать диалог с каруселью изображений
  static void show(
    BuildContext context, {
    required List<ImageData> images,
    required String productTitle,
    int initialIndex = 0,
  }) {
    if (images.isEmpty) return;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => ProductImagesCarouselDialog(
        images: images,
        productTitle: productTitle,
        initialIndex: initialIndex,
      ),
    );
  }

  @override
  State<ProductImagesCarouselDialog> createState() =>
      _ProductImagesCarouselDialogState();
}

class _ProductImagesCarouselDialogState
    extends State<ProductImagesCarouselDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.productTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Карусель изображений
          Flexible(
            child: Container(
              color: Colors.white,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  final image = widget.images[index];
                  final imageUrl = image.uri.isNotEmpty
                      ? image.uri
                      : image.getOptimalUrl();

                  return Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: CachedNetworkImageWidget(
                        imageUrl: imageUrl,
                        webpUrl: image.webp,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Индикатор страниц
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.images.length > 1) ...[
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentIndex > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                  Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentIndex < widget.images.length - 1
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                ] else
                  const Text(
                    '1 / 1',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
