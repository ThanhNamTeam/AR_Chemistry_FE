import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/knowledge_points_badge.dart';
import '../../core/api/payment_api.dart';
import '../../routes/app_routes.dart';
import '../home/providers/app_state.dart';


class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  bool _isLoading = false;
  bool _isPurchasing = false;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final PaymentApi _paymentApi = PaymentApi();
  static const String _googlePlayProductId = 'ar_access_30_days';

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _purchaseSub = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (error) {
        if (!mounted) return;
        setState(() => _isPurchasing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase error: $error')),
        );
      },
    );

    Future.microtask(() async {
      setState(() => _isLoading = true);

      await context.read<AppState>().loadPackages();

      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }



  Future<void> _buyPackageWithGooglePlay(String productId) async {
    if (_isPurchasing) return;

    if (productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Product ID is empty')),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      final available = await _inAppPurchase.isAvailable();

      if (!available) {
        throw Exception('Google Play Billing is not available');
      }

      final response = await _inAppPurchase.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
        throw Exception('Product not found on Google Play: $productId');
      }

      final product = response.productDetails.first;

      final purchaseParam = PurchaseParam(productDetails: product);

      await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isPurchasing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mua gói thất bại: $e')),
      );
    }
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases,
      ) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        if (!mounted) return;

        setState(() => _isPurchasing = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              purchase.error?.message ?? 'Thanh toán thất bại',
            ),
          ),
        );
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        try {
          final access = await _paymentApi.verifyGooglePlayPurchase(
            productId: purchase.productID,
            purchaseToken: purchase.verificationData.serverVerificationData,
          );

          if (purchase.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchase);
          }

          if (!mounted) return;

          setState(() => _isPurchasing = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                access.message.isNotEmpty
                    ? access.message
                    : 'Mua gói thành công',
              ),
            ),
          );

          if (access.canScanAR) {
            Navigator.pushNamed(context, AppRoutes.scan);
          }
        } catch (e) {
          if (!mounted) return;

          setState(() => _isPurchasing = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verify Google Play thất bại: $e')),
          );
        }
      }
    }
  }

  String _getPackageSubtitle(String packageType) {
    switch (packageType) {
      case 'PREMIUM_BASIC':
        return 'Unlock basic premium features';
      case 'PREMIUM_FULL':
        return 'Unlock all premium features';
      case 'AR_LIFETIME':
        return 'Permanent AR access';
      default:
        return packageType;
    }
  }

  String _getDurationText(int durationDays) {
    if (durationDays >= 99999) return 'Lifetime';
    return '$durationDays days';
  }


  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final packages = state.packages;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Upgrade Packages',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        KnowledgePointsBadge(points: state.knowledgePoints),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                        : packages.isEmpty
                        ? Center(
                      child: Text(
                        'No packages available',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    )
                        : ListView.builder(
                      padding:
                      const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: packages.length,
                      itemBuilder: (context, index) {
                        final package = packages[index];

                        return Padding(
                          padding:
                          const EdgeInsets.only(bottom: 14),
                          child: _PackageCard(
                            title: package.name,
                            subtitle: _getPackageSubtitle(
                              package.packageType,
                            ),
                            duration: _getDurationText(
                              package.durationDays,
                            ),
                            price: package.price,
                            onTap: _isPurchasing
                                ? () {}
                                : () => _buyPackageWithGooglePlay(_googlePlayProductId),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final int price;
  final VoidCallback onTap;

  const _PackageCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priceText = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VND',
    ).format(price);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cardBg,
            AppColors.cardSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.amberGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.amberLight,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.emphasisPositive,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Buy AR 30 Days',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}