import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/widgets/knowledge_points_badge.dart';
import '../home/providers/app_state.dart';
import 'package:image_picker/image_picker.dart';


class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  bool _isLoading = false;
  bool _showQRModal = false;

  String? _selectedPackageId;
  String? _selectedPackageName;
  int _selectedPrice = 0;
  String? _transferCode;
  String? _proofImageUrl;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      setState(() => _isLoading = true);

      await context.read<AppState>().loadPackages();

      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  void _openQR({
    required String packageId,
    required String packageName,
    required int price,
  }) {
    setState(() {
      _selectedPackageId = packageId;
      _selectedPackageName = packageName;
      _selectedPrice = price;
      _transferCode = 'CHEM_${DateTime.now().millisecondsSinceEpoch}';
      _proofImageUrl = null;
      _showQRModal = true;
    });
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

  Future<void> _confirmPayment(AppState state) async {
    if (_selectedPackageId == null) return;

    if (_proofImageUrl == null || _proofImageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please upload proof image first',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final ok = await state.createBankPayment(
      packageId: _selectedPackageId!,
      proofImageUrl: _proofImageUrl!,
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Create payment failed',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _showQRModal = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Payment submitted. Please wait for staff approval.',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _pickProofImage(AppState state) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    final fileSize = bytes.length;
    final fileName = picked.name;

    final lowerName = fileName.toLowerCase();
    final contentType = lowerName.endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';

    final fileUrl = await state.uploadPaymentProof(
      fileName: fileName,
      contentType: contentType,
      fileSize: fileSize,
      bytes: bytes,
    );

    if (!mounted) return;

    if (fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Upload proof image failed',
            style: TextStyle(fontFamily: 'Inter'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _proofImageUrl = fileUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Proof image uploaded successfully',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
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
                            onTap: () => _openQR(
                              packageId: package.id,
                              packageName: package.name,
                              price: package.price,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              if (_showQRModal)
                _PackageQRModal(
                  packageName: _selectedPackageName ?? '',
                  price: _selectedPrice,
                  transferCode: _transferCode ?? '',
                  proofImageUrl: _proofImageUrl,
                  onPickProof: () => _pickProofImage(state),
                  onConfirm: () => _confirmPayment(state),
                  onCancel: () => setState(() => _showQRModal = false),
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
                    'Pay with Bank',
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

class _PackageQRModal extends StatelessWidget {
  final String packageName;
  final int price;
  final String transferCode;
  final String? proofImageUrl;
  final VoidCallback onPickProof;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PackageQRModal({
    required this.packageName,
    required this.price,
    required this.transferCode,
    required this.proofImageUrl,
    required this.onPickProof,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final qrUrl =
        'https://img.vietqr.io/image/'
        'VCB-1031285717-print.png'
        '?amount=$price'
        '&addInfo=$transferCode'
        '&accountName=NGUYEN%20HOAI%20AN';

    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                packageName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  qrUrl,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan QR code to pay',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    _InfoRow('Receiver', 'Chemistry AR'),
                    const SizedBox(height: 6),
                    _InfoRow(
                      'Amount',
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'VND',
                      ).format(price),
                    ),
                    const SizedBox(height: 6),
                    _InfoRow('Content', transferCode),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPickProof,
                  icon: Icon(
                    proofImageUrl == null ? Icons.upload_file : Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    proofImageUrl == null
                        ? 'Upload proof image'
                        : 'Proof image uploaded',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: proofImageUrl == null
                        ? Colors.orange.shade700
                        : Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: proofImageUrl == null ? null : onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: proofImageUrl == null
                        ? Colors.grey.shade400
                        : Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Payment',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}