import 'package:flutter/material.dart';

class FullScreenImageView extends StatefulWidget {
  final String imagePath;
  final bool isNetwork;

  const FullScreenImageView({
    super.key,
    required this.imagePath,
    this.isNetwork = false,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  final TransformationController _controller = TransformationController();
  TapDownDetails? _doubleTapDetails;

  void _handleDoubleTap() {
    if (_controller.value != Matrix4.identity()) {
      _controller.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      _controller.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(2.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = widget.isNetwork
        ? Image.network(
      widget.imagePath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.white),
    )
        : Image.asset(
      widget.imagePath,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.white),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onDoubleTapDown: (details) => _doubleTapDetails = details,
        onDoubleTap: _handleDoubleTap,
        child: Center(
          child: InteractiveViewer(
            transformationController: _controller,
            minScale: 1,
            maxScale: 5,
            child: imageWidget,
          ),
        ),
      ),
    );
  }
}
