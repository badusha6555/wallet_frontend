import 'package:fintech_wallet/controllers/remittance_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/remittance_provider_model.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/common_widgets.dart';
import '../../models/remittance_result_model.dart';

const _currencies = [
  ('SAR', '🇸🇦', 'Saudi Riyal'),
  ('USD', '🇺🇸', 'US Dollar'),
  ('EUR', '🇪🇺', 'Euro'),
  ('GBP', '🇬🇧', 'British Pound'),
  ('AED', '🇦🇪', 'UAE Dirham'),
  ('INR', '🇮🇳', 'Indian Rupee'),
  ('PKR', '🇵🇰', 'Pakistani Rupee'),
  ('BDT', '🇧🇩', 'Bangladeshi Taka'),
  ('PHP', '🇵🇭', 'Philippine Peso'),
  ('EGP', '🇪🇬', 'Egyptian Pound'),
  ('MYR', '🇲🇾', 'Malaysian Ringgit'),
];

const _countries = [
  ('India', '🇮🇳'),
  ('Pakistan', '🇵🇰'),
  ('Bangladesh', '🇧🇩'),
  ('Philippines', '🇵🇭'),
  ('Egypt', '🇪🇬'),
  ('Malaysia', '🇲🇾'),
  ('UAE', '🇦🇪'),
  ('USA', '🇺🇸'),
  ('UK', '🇬🇧'),
];

class RemittanceScreen extends StatefulWidget {
  final bool showAppBar;
  const RemittanceScreen({super.key, this.showAppBar = true});

  @override
  State<RemittanceScreen> createState() => _RemittanceScreenState();
}

class _RemittanceScreenState extends State<RemittanceScreen>
    with SingleTickerProviderStateMixin {
  final _amountCtrl = TextEditingController(text: '1000');
  String _fromCurrency = 'SAR';
  String _toCurrency = 'INR';
  String _country = 'India';
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _compare() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      showError(context, 'Enter a valid amount');
      return;
    }
    await context.read<RemittanceController>().optimize(
      amount: amount,
      fromCurrency: _fromCurrency,
      toCurrency: _toCurrency,
      receiverCountry: _country,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
        title: const Text('Send Abroad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      )
          : null,
      body: Consumer<RemittanceController>(
        builder: (ctx, controller, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              widget.showAppBar ? 20 : MediaQuery.of(context).padding.top + 20,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.showAppBar) ...[
                  const Text('Send Abroad',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Compare rates across providers',
                      style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 20),
                ],

                _buildInfoBanner(),
                const SizedBox(height: 24),
                _buildAmountSection(),
                const SizedBox(height: 20),
                _buildCurrencyPairRow(),
                const SizedBox(height: 16),
                _buildCountrySelector(),
                const SizedBox(height: 28),

                GradientButton(
                  label: 'Compare Rates',
                  onPressed: _compare,
                  loading: controller.isLoading,
                ),

                if (controller.isLoading) ...[
                  const SizedBox(height: 32),
                  _buildShimmerCards(),
                ] else if (controller.status == RemittanceStatus.loaded &&
                    controller.result != null) ...[
                  const SizedBox(height: 32),
                  _buildResults(controller.result!),
                ] else if (controller.status == RemittanceStatus.error) ...[
                  const SizedBox(height: 24),
                  _buildError(controller.error ?? 'Something went wrong'),
                ] else ...[
                  const SizedBox(height: 40),
                  _buildPlaceholder(),
                ],

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.accentGlow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.compare_arrows_rounded, color: AppTheme.accent, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Compare real-time rates across providers and find the best deal for your transfer.',
              style: TextStyle(color: AppTheme.accent, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('YOU SEND',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              const SizedBox(width: 18),
              Text(_fromCurrency,
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: AppTheme.divider),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 26,
                        fontWeight: FontWeight.w800),
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 8,
          children: [500, 1000, 2000, 5000].map((a) {
            return GestureDetector(
              onTap: () => setState(() => _amountCtrl.text = a.toString()),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Text('$_fromCurrency $a',
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCurrencyPairRow() {
    return Row(
      children: [
        Expanded(
          child: _CurrencyDropdown(
            label: 'FROM',
            value: _fromCurrency,
            onChanged: (v) => setState(() => _fromCurrency = v),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => setState(() {
            final tmp = _fromCurrency;
            _fromCurrency = _toCurrency;
            _toCurrency = tmp;
          }),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.accentGlow,
              shape: BoxShape.circle,
              border:
              Border.all(color: AppTheme.accent.withOpacity(0.3)),
            ),
            child: const Icon(Icons.swap_horiz_rounded,
                color: AppTheme.accent, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CurrencyDropdown(
            label: 'TO',
            value: _toCurrency,
            onChanged: (v) => setState(() => _toCurrency = v),
          ),
        ),
      ],
    );
  }

  Widget _buildCountrySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RECEIVER\'S COUNTRY',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _country,
              dropdownColor: AppTheme.card,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 14),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textMuted),
              items: _countries
                  .map((c) => DropdownMenuItem(
                value: c.$1,
                child: Text('${c.$2}  ${c.$1}'),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _country = v!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCards() {
    return Column(
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _shimmerCtrl,
          builder: (_, __) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment(-1 + _shimmerCtrl.value * 2, 0),
                end: Alignment(_shimmerCtrl.value * 2, 0),
                colors: const [AppTheme.card, AppTheme.cardLight, AppTheme.card],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildResults(RemittanceResult result) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final sorted = [...result.providers]
      ..sort((a, b) => b.finalAmount.compareTo(a.finalAmount));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Provider Comparison',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGlow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${result.providers.length} providers',
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Sending $_fromCurrency ${fmt.format(amount)} → $_toCurrency',
          style:
          const TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 16),
        if (result.best != null) _buildBestCard(result.best!, fmt),
        const SizedBox(height: 16),
        ...sorted.asMap().entries.map((e) => _ProviderCard(
          provider: e.value,
          rank: e.key + 1,
          isBest: e.value.providerName == result.bestProvider,
          toCurrency: _toCurrency,
          fmt: fmt,
        )),
      ],
    );
  }

  Widget _buildBestCard(RemittanceProvider best, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.15),
            AppTheme.accent.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border:
        Border.all(color: AppTheme.accent.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppTheme.accent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('BEST RATE FOUND',
                    style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8)),
                const SizedBox(height: 3),
                Text(best.providerName,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  'Rate: ${best.rate.toStringAsFixed(4)}  ·  Fee: ${fmt.format(best.fee)}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fmt.format(best.finalAmount),
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              Text(_toCurrency,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.card,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.divider),
            ),
            child: const Icon(Icons.compare_arrows_rounded,
                color: AppTheme.textMuted, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter an amount and tap\n"Compare Rates" to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.textMuted, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.danger, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: AppTheme.danger, fontSize: 13))),
        ],
      ),
    );
  }
}
class _CurrencyDropdown extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _CurrencyDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppTheme.card,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textMuted, size: 18),
              selectedItemBuilder: (_) => _currencies
                  .map((c) => Align(
                alignment: Alignment.centerLeft,
                child: Text('${c.$2}  ${c.$1}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ))
                  .toList(),
              items: _currencies
                  .map((c) => DropdownMenuItem(
                value: c.$1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${c.$2}  ${c.$1}',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                    Text(c.$3,
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11)),
                  ],
                ),
              ))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }
}


class _ProviderCard extends StatefulWidget {
  final RemittanceProvider provider;
  final int rank;
  final bool isBest;
  final String toCurrency;
  final NumberFormat fmt;

  const _ProviderCard({
    required this.provider,
    required this.rank,
    required this.isBest,
    required this.toCurrency,
    required this.fmt,
  });

  @override
  State<_ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<_ProviderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + widget.rank * 100));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    Future.delayed(Duration(milliseconds: widget.rank * 80), _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.provider.providerName.toLowerCase()) {
      case 'myapp':
        return AppTheme.accent;
      case 'wise':
        return const Color(0xFF9EEAF9);
      case 'bank':
        return AppTheme.warning;
      default:
        return const Color(0xFF9B72FF);
    }
  }

  IconData get _icon {
    switch (widget.provider.providerName.toLowerCase()) {
      case 'myapp':
        return Icons.account_balance_wallet_rounded;
      case 'wise':
        return Icons.currency_exchange_rounded;
      case 'bank':
        return Icons.account_balance_rounded;
      default:
        return Icons.payments_rounded;
    }
  }

  Color get _rankColor {
    switch (widget.rank) {
      case 1:
        return AppTheme.accent;
      case 2:
        return const Color(0xFF9B72FF);
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
            .animate(_anim),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isBest
                  ? AppTheme.accent.withOpacity(0.3)
                  : AppTheme.divider,
              width: widget.isBest ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Rank
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: _rankColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('#${widget.rank}',
                          style: TextStyle(
                              color: _rankColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: _color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  // Name + badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(widget.provider.providerName,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            if (widget.isBest) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGlow,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('BEST',
                                    style: TextStyle(
                                        color: AppTheme.accent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fee: ${widget.fmt.format(widget.provider.fee)}',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.fmt.format(widget.provider.finalAmount),
                        style: TextStyle(
                          color: widget.isBest
                              ? AppTheme.accent
                              : AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(widget.toCurrency,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Stats row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _Stat('Exchange Rate',
                        widget.provider.rate.toStringAsFixed(4)),
                    _Divider(),
                    _Stat('Transfer Fee',
                        widget.fmt.format(widget.provider.fee)),
                    _Divider(),
                    _Stat('You Get',
                        widget.fmt.format(widget.provider.finalAmount),
                        highlight: widget.isBest),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _Stat(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 10),
              textAlign: TextAlign.center),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  color: highlight
                      ? AppTheme.accent
                      : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 1,
      height: 28,
      color: AppTheme.divider,
      margin: const EdgeInsets.symmetric(horizontal: 4));
}