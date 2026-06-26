import 'package:flutter/material.dart';

import '../../../core/services/ar_asset_downloader.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import '../widgets/ar_camera_view.dart';

class ArAssetLoadingScreen extends StatefulWidget {
  const ArAssetLoadingScreen({super.key});

  @override
  State<ArAssetLoadingScreen> createState() => _ArAssetLoadingScreenState();
}

class _ArAssetLoadingScreenState extends State<ArAssetLoadingScreen> {
  double _progress = 0;
  String _message = 'Preparing AR assets...';
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    _prepareAssets();
  }

  Future<void> _prepareAssets() async {
    try {
      await ArAssetDownloader.ensureReady(
        onProgress: (progress, message) {
          if (!mounted) return;
          setState(() {
            _progress = progress;
            _message = message;
            _isExtracting = message.startsWith('Extracting');
          });
        },
      );

      final markerPath = await ArAssetDownloader.getMarkerPath();
      final reactionPath = await ArAssetDownloader.getReactionPath();
      await ARUnitySession.instance.configureArAssetPaths(
        markerPath: markerPath,
        reactionPath: reactionPath,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.scan);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message = 'Failed to prepare AR assets. Please try again.';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).clamp(0, 100).toStringAsFixed(0);

    return PopScope(
      canPop: !_isExtracting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isExtracting) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đang giải nén dữ liệu AR, vui lòng chờ hoàn tất.'),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.view_in_ar, color: Colors.white, size: 64),
                const SizedBox(height: 24),
                Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 24),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 12),
                Text(
                  '$percent%',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isExtracting
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
