import 'package:flutter/material.dart';

import '../../../../shared/styles/app_colors.dart';
import '../data/chemistry_data.dart';

class MiniGameLearningScreen extends StatefulWidget {
  const MiniGameLearningScreen({super.key});

  @override
  State<MiniGameLearningScreen> createState() =>
      _MiniGameLearningScreenState();
}

class _MiniGameLearningScreenState extends State<MiniGameLearningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: const [
                    _AtomicMassPoemTab(),
                    _ValencePoemTab(),
                    _ElementExplorerTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.arrow_back_ios_new,
                  color: AppColors.primary, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Học Bài Thơ',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        tabs: const [
          Tab(text: 'Khối lượng'),
          Tab(text: 'Hóa trị'),
          Tab(text: 'Nguyên tố'),
        ],
      ),
    );
  }
}

// ─── Tab 1: Atomic Mass Poem ────────────────────────────────────────────────

class _AtomicMassPoemTab extends StatelessWidget {
  const _AtomicMassPoemTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PoemTitle(
            title: 'Bài thơ Khối lượng Nguyên tử',
            subtitle: '34 nguyên tố • từ H đến Bi',
            icon: Icons.balance_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _PoemCard(
            poem: ChemistryData.atomicMassPoem,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Bảng tra cứu nhanh',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          _AtomicMassTable(),
        ],
      ),
    );
  }
}

class _AtomicMassTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final elements = ChemistryData.elementsWithAtomicMass;
    return Column(
      children: elements.map((el) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBg.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    el.symbol,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  el.nameVi,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                ),
                child: Text(
                  el.atomicMassStr,
                  style: TextStyle(
                    color: AppColors.accentLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Tab 2: Valence Poem ────────────────────────────────────────────────────

class _ValencePoemTab extends StatelessWidget {
  const _ValencePoemTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PoemTitle(
            title: 'Bài thơ Hóa trị',
            subtitle: '25 nguyên tố • quy tắc hóa trị',
            icon: Icons.link_outlined,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          _PoemCard(
            poem: ChemistryData.valencePoem,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 24),
          Text(
            'Bảng tra cứu hóa trị',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          _ValenceTable(),
        ],
      ),
    );
  }
}

class _ValenceTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final elements = ChemistryData.elementsWithValence;
    return Column(
      children: elements.map((el) {
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardBg.withOpacity(0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.secondary.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    el.symbol,
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  el.nameVi,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: el.hasMultipleValences
                      ? AppColors.amber.withOpacity(0.1)
                      : AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: el.hasMultipleValences
                        ? AppColors.amber.withOpacity(0.3)
                        : AppColors.secondary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  el.valenceStr,
                  style: TextStyle(
                    color: el.hasMultipleValences
                        ? AppColors.amberLight
                        : AppColors.secondaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Tab 3: Element Explorer ────────────────────────────────────────────────

class _ElementExplorerTab extends StatefulWidget {
  const _ElementExplorerTab();

  @override
  State<_ElementExplorerTab> createState() => _ElementExplorerTabState();
}

class _ElementExplorerTabState extends State<_ElementExplorerTab> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final all = ChemistryData.allElements;
    final filtered = _query.isEmpty
        ? all
        : all
            .where((e) =>
                e.symbol.toLowerCase().contains(_query) ||
                e.nameVi.toLowerCase().contains(_query) ||
                e.nameEn.toLowerCase().contains(_query))
            .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                  fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tìm nguyên tố (tên, ký hiệu)…',
                hintStyle: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.85,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _ElementTile(
              element: filtered[i],
              onTap: () => _showDetail(context, filtered[i]),
            ),
          ),
        ),
      ],
    );
  }

  void _showDetail(BuildContext context, ChemElementData el) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ElementDetailSheet(element: el),
    );
  }
}

class _ElementTile extends StatelessWidget {
  final ChemElementData element;
  final VoidCallback onTap;

  const _ElementTile({required this.element, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasValence = element.hasValence;
    final hasAtomicMass = element.hasAtomicMass;
    Color accent = hasAtomicMass && hasValence
        ? AppColors.primary
        : hasAtomicMass
            ? AppColors.accent
            : AppColors.secondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasAtomicMass)
              Text(
                element.atomicMassStr,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 8,
                  fontFamily: 'Inter',
                ),
              ),
            Text(
              element.symbol,
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              element.nameVi,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 8,
                fontFamily: 'Inter',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ElementDetailSheet extends StatelessWidget {
  final ChemElementData element;

  const _ElementDetailSheet({required this.element});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundMid,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Symbol card
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    element.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (element.hasAtomicMass)
                    Text(
                      element.atomicMassStr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontFamily: 'Inter',
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            element.nameVi,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Inter',
            ),
          ),
          Text(
            element.nameEn,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 20),
          // Info grid
          Row(
            children: [
              if (element.hasAtomicMass)
                Expanded(
                  child: _InfoCard(
                    label: 'Khối lượng NTK',
                    value: '${element.atomicMassStr} đvC',
                    icon: Icons.balance_outlined,
                    color: AppColors.accent,
                  ),
                ),
              if (element.hasAtomicMass && element.hasValence)
                const SizedBox(width: 10),
              if (element.hasValence)
                Expanded(
                  child: _InfoCard(
                    label: 'Hóa trị',
                    value: element.valenceStr,
                    icon: Icons.link_outlined,
                    color: element.hasMultipleValences
                        ? AppColors.amber
                        : AppColors.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Poem lines
          if (element.atomicMassPoemLine.isNotEmpty)
            _PoemLineCard(
              label: 'Bài thơ KL nguyên tử:',
              line: element.atomicMassPoemLine,
              color: AppColors.primary,
            ),
          if (element.valencePoemLine.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PoemLineCard(
              label: 'Bài thơ Hóa trị:',
              line: element.valencePoemLine,
              color: AppColors.secondary,
            ),
          ],
          const SizedBox(height: 12),
          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline,
                    color: AppColors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    element.explanation,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      height: 1.5,
                    ),
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

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
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

class _PoemLineCard extends StatelessWidget {
  final String label;
  final String line;
  final Color color;

  const _PoemLineCard(
      {required this.label, required this.line, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            line,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontFamily: 'Inter',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ──────────────────────────────────────────────────────────

class _PoemTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _PoemTitle({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PoemCard extends StatelessWidget {
  final String poem;
  final Color color;

  const _PoemCard({required this.poem, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        poem,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontFamily: 'Inter',
          height: 1.9,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
