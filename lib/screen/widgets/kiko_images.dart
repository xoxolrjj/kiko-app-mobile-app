import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kiko_app_mobile_app/dependency/dependency_manager.dart';
 
class KikoImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isCircular;

  const KikoImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.isCircular = false,
  });

  @override
  State<KikoImage> createState() => _KikoImageState();
}

class _KikoImageState extends State<KikoImage> {
  Future<String>? _downloadURLFuture;

  @override
  void initState() {
    super.initState();
    _fetchDownloadURL();
  }

  @override
  void didUpdateWidget(KikoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _fetchDownloadURL();
    }
  }

  bool _isUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  void _fetchDownloadURL() {
    if (_isUrl(widget.imagePath)) {
      _downloadURLFuture = Future.value(widget.imagePath);
    } else {
      _downloadURLFuture =
          sl<FirebaseStorage>().ref(widget.imagePath).getDownloadURL();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _downloadURLFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.placeholder ??
              const Center(child: CircularProgressIndicator.adaptive());
        }

        if (snapshot.hasError) {
          return widget.errorWidget ?? const Icon(Icons.error);
        }

        if (!snapshot.hasData) {
          return widget.errorWidget ?? const Icon(Icons.error);
        }

        final imageWidget = CachedNetworkImage(
          imageUrl: snapshot.data!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder:
              (context, url) =>
                  widget.placeholder ??
                  const Center(child: CircularProgressIndicator.adaptive()),
          errorWidget:
              (context, url, error) =>
                  widget.errorWidget ?? const Icon(Icons.error),
        );

        if (widget.isCircular) {
          return ClipOval(child: imageWidget);
        }

        return imageWidget;
      },
    );
  }
}
