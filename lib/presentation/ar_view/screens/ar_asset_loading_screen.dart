import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
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
  String? _downloaderMessage;
  bool _isExtracting = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _prepareAssets();
  }

  Future<void> _prepareAssets() async {
    setState(() {
      _failed = false;
      _progress = 0;
      _downloaderMessage = null;
    });

    try {
      await ArAssetDownloader.ensureReady(
        onProgress: (progress, message) {
          if (!mounted) return;
          setState(() {
            _progress = progress;
            _downloaderMessage = message;
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
      final args = ModalRoute.of(context)?.settings.arguments;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.scan,
        arguments: args,
      );
    } catch (e) {
      // Không hiển thị e.toString() cho người dùng — chuỗi exception Dart/Dio
      // vô nghĩa với học sinh. Log để debug, màn hình hiện thông báo thân thiện
      // kèm nút Thử lại.
      debugPrint('AR asset prepare failed: $e');
      if (!mounted) return;
      setState(() {
        _failed = true;
        _isExtracting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = (_progress * 100).clamp(0, 100).toStringAsFixed(0);

    return PopScope(
      canPop: !_isExtracting,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isExtracting) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.arExtracting)),
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
                Icon(
                  _failed ? Icons.cloud_off : Icons.view_in_ar,
                  color: _failed ? AppColors.error : AppColors.textPrimary,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  _failed
                      ? l10n.arPrepareFailed
                      : (_downloaderMessage ?? l10n.arPreparingAssets),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
                if (!_failed) ...[
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
                ],
                const SizedBox(height: 20),
                if (_failed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _prepareAssets,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.tryAgainAction),
                    ),
                  ),
                TextButton(
                  onPressed: _isExtracting
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
