import 'dart:async';

import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class AppSnackBarMessage {
  const AppSnackBarMessage({
    required this.message,
    required this.backgroundColor,
    required this.icon,
  });

  final String message;
  final Color backgroundColor;
  final IconData icon;
}

class AppSnackBar {
  static final ValueNotifier<AppSnackBarMessage?> notifier =
  ValueNotifier<AppSnackBarMessage?>(null);

  static Timer? _timer;

  static void show({
    required String message,
    Color backgroundColor = Colors.black87,
    IconData icon = Icons.bolt,
  }) {
    debugPrint('[APP_TOAST] show called: $message');

    _timer?.cancel();

    notifier.value = AppSnackBarMessage(
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
    );

    _timer = Timer(const Duration(seconds: 4), () {
      notifier.value = null;
    });
  }

  static void hide() {
    _timer?.cancel();
    notifier.value = null;
  }
}

class AppToastOverlay extends StatelessWidget {
  const AppToastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSnackBarMessage?>(
      valueListenable: AppSnackBar.notifier,
      builder: (context, data, _) {
        if (data == null) return const SizedBox.shrink();

        final bottomPadding = MediaQuery.of(context).padding.bottom;

        return Positioned(
          left: 0,
          right: 0,
          bottom: bottomPadding + 150,
          child: IgnorePointer(
            ignoring: true,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    key: ValueKey(data.message),
                    width: 170,
                    height: 170,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: data.backgroundColor,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          data.icon,
                          color: Colors.white,
                          size: 38,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.message,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}