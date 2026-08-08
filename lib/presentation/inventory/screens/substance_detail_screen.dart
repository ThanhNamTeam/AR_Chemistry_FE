import 'package:flutter/material.dart';

import '../../../core/api/inventory_api.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/response/substance_detail_response.dart';
import '../../../shared/styles/app_colors.dart';

class SubstanceDetailScreen extends StatefulWidget {
  final String substanceId;

  const SubstanceDetailScreen({
    super.key,
    required this.substanceId,
  });

  @override
  State<SubstanceDetailScreen> createState() => _SubstanceDetailScreenState();
}

class _SubstanceDetailScreenState extends State<SubstanceDetailScreen> {
  final InventoryApi _inventoryApi = InventoryApi();

  bool _isLoading = true;
  String? _errorMessage;
  SubstanceDetailResponse? _detail;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _inventoryApi.getSubstanceDetail(widget.substanceId);

      if (!mounted) return;

      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
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
                        l10n.substanceDetail,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadDetail,
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 140),
          Icon(
            Icons.error_outline,
            size: 56,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cannotLoadSubstanceDetail,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    final detail = _detail;

    if (detail == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 140),
          Text(
            l10n.noDetailFound,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        _HeroCard(detail: detail),
        const SizedBox(height: 16),
        _InfoSection(
          title: l10n.basicInformation,
          children: [
            _InfoRow(label: l10n.name, value: detail.name),
            _InfoRow(label: l10n.vietnameseName, value: detail.vietnameseName),
            _InfoRow(label: l10n.formula, value: detail.formula),
            _InfoRow(label: l10n.chemicalGroup, value: detail.chemicalGroup),
            _InfoRow(label: l10n.state, value: detail.state),
          ],
        ),
        const SizedBox(height: 16),
        if (detail.elementDetail != null)
          _ElementDetailSection(element: detail.elementDetail!)
        else if (detail.compoundDetail != null)
          _CompoundDetailSection(compound: detail.compoundDetail!)
        else
          _InfoSection(
            title: l10n.substanceDetail,
            children: [
              _InfoRow(
                label: l10n.statusLabel,
                value: l10n.noDetailAvailable,
              ),
            ],
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final SubstanceDetailResponse detail;

  const _HeroCard({
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = detail.elementDetail?.symbol ?? detail.displayFormula;
    final stateColor = AppColors.substanceStateColor(detail.state);
    final stateGradient = AppColors.substanceStateGradient(detail.state);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.substanceStateBorder(detail.state),
        ),
        boxShadow: [
          BoxShadow(
            color: stateColor.withValues(alpha: 0.10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 108,
            height: 108,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: stateGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: stateColor.withValues(alpha: 0.28),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Text(
              symbol.isNotEmpty ? symbol : '?',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            detail.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail.displayFormula,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontFamily: 'Inter',
            ),
          ),
          if (detail.state != null && detail.state!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.substanceStateSurface(detail.state),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.substanceStateBorder(detail.state),
                ),
              ),
              child: Text(
                detail.state!,
                style: TextStyle(
                  color: stateColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ElementDetailSection extends StatelessWidget {
  final ElementDetailResponse element;

  const _ElementDetailSection({
    required this.element,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _InfoSection(
      title: l10n.elementDetail,
      children: [
        _InfoRow(
          label: l10n.atomicNumber,
          value: element.atomicNumber?.toString(),
        ),
        _InfoRow(
          label: l10n.symbolLabel,
          value: element.symbol,
        ),
        _InfoRow(
          label: l10n.periodicCategory,
          value: element.periodicCategory,
        ),
        _InfoRow(
          label: l10n.atomicMass,
          value: element.atomicMass?.toString(),
        ),
        _InfoRow(
          label: l10n.period,
          value: element.period?.toString(),
        ),
        _InfoRow(
          label: l10n.groupLabel,
          value: element.groupNumber?.toString(),
        ),
      ],
    );
  }
}

class _CompoundDetailSection extends StatelessWidget {
  final CompoundDetailResponse compound;

  const _CompoundDetailSection({
    required this.compound,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _InfoSection(
      title: l10n.compoundDetail,
      children: [
        _InfoRow(
          label: l10n.iupacName,
          value: compound.iupacName,
        ),
        _InfoRow(
          label: l10n.casNumber,
          value: compound.casNumber,
        ),
        _InfoRow(
          label: l10n.compoundClass,
          value: compound.compoundClass,
        ),
        _InfoRow(
          label: l10n.usageNote,
          value: compound.usageNote,
        ),
        _InfoRow(
          label: l10n.reactionProductOnly,
          value: compound.reactionProductOnly ? l10n.yes : l10n.no,
        ),
        _InfoRow(
          label: l10n.physicalInKit,
          value: compound.physicalInKit ? l10n.yes : l10n.no,
        ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value == null || value!.isEmpty ? '—' : value!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

