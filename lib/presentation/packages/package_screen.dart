import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/knowledge_points_badge.dart';
import '../../core/l10n/app_localizations.dart';
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

  ProductDetails? _googlePlayProduct;
  String _googlePlayPriceText = 'Đang tải giá...';

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
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).purchaseError}: $error',
            ),
          ),
        );
      },
    );

    Future.microtask(() async {
      setState(() => _isLoading = true);

      await context.read<AppState>().loadPackages();
      await _loadGooglePlayProduct();

      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  Future<void> _loadGooglePlayProduct() async {
    final available = await _inAppPurchase.isAvailable();

    if (!available) {
      setState(() {
        _googlePlayPriceText = 'Google Play không khả dụng';
      });
      return;
    }

    final response = await _inAppPurchase.queryProductDetails({
      _googlePlayProductId,
    });

    if (response.productDetails.isEmpty) {
      setState(() {
        _googlePlayPriceText = 'Không tìm thấy giá';
      });
      return;
    }

    final product = response.productDetails.first;

    setState(() {
      _googlePlayProduct = product;
      _googlePlayPriceText = product.price;
    });
  }



  Future<void> _buyPackageWithGooglePlay(String productId) async {
    if (_isPurchasing) return;

    if (productId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).googleProductIdEmpty),
        ),
      );
      return;
    }

    setState(() => _isPurchasing = true);

    try {
      final available = await _inAppPurchase.isAvailable();

      if (!available) {
        throw Exception(AppLocalizations.of(context).googlePlayBillingUnavailable);
      }

      final response = await _inAppPurchase.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
        throw Exception(
          AppLocalizations.of(context).productNotFoundOnGooglePlay(productId),
        );
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
        SnackBar(content: Text('${AppLocalizations.of(context).purchasePackageFailed}: $e')),
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
              purchase.error?.message ?? AppLocalizations.of(context).paymentFailed,
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
                    : AppLocalizations.of(context).purchasePackageSuccess,
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
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context).verifyGooglePlayFailed}: $e',
              ),
            ),
          );
        }
      }
    }
  }

  String _getPackageSubtitle(BuildContext context, String packageType) {
    final l10n = AppLocalizations.of(context);
    switch (packageType) {
      case 'PREMIUM_BASIC':
        return l10n.premiumBasicSubtitle;
      case 'PREMIUM_FULL':
        return l10n.premiumFullSubtitle;
      case 'AR_LIFETIME':
        return l10n.arLifetimeSubtitle;
      default:
        return packageType;
    }
  }

  String _getDurationText(int durationDays) {
    final l10n = AppLocalizations.of(context);
    if (durationDays >= 99999) return l10n.lifetime;
    return '$durationDays days';
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                            l10n.upgradePackages,
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
                        l10n.noPackagesAvailable,
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
                              context,
                              package.packageType,
                            ),
                            duration: _getDurationText(
                              package.durationDays,
                            ),
                            priceText: _googlePlayPriceText,
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
  final String priceText;
  final VoidCallback onTap;

  const _PackageCard({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {


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
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/ar_30_days.png',
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
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