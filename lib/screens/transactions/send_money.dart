import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/common_widgets.dart';
import '../../models/wallet_model.dart';


class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _walletCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  WalletModel? _verifiedWallet;
  bool _verifying = false;
  bool _sending = false;

  @override
  void dispose() {
    _walletCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_walletCtrl.text.trim().length < 10) return;
    setState(() { _verifying = true; _verifiedWallet = null; });
    final w = await context.read<WalletProvider>().verifyWallet(_walletCtrl.text.trim());
    setState(() { _verifiedWallet = w; _verifying = false; });
    if (w == null) showError(context, 'Wallet not found');
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    if (_verifiedWallet == null) { showError(context, 'Please verify the wallet first'); return; }
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) { showError(context, 'Invalid amount'); return; }

    setState(() => _sending = true);
    final ok = await context.read<WalletProvider>().sendMoney(_walletCtrl.text.trim(), amount);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      _showSuccessSheet(amount);
    } else {
      showError(context, context.read<WalletProvider>().error ?? 'Transfer failed');
    }
  }

  void _showSuccessSheet(double amount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.accentGlow,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accent, width: 2),
              ),
              child: const Icon(Icons.check_rounded, color: AppTheme.accent, size: 36),
            ),
            const SizedBox(height: 20),
            const Text('Transfer Successful!',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'SAR ${amount.toStringAsFixed(2)} sent to ${_verifiedWallet?.username}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myWallet = context.watch<WalletProvider>().wallet;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded,
                        color: AppTheme.accent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Balance: SAR ${myWallet?.balance.toStringAsFixed(2) ?? '0.00'}',
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Recipient Wallet',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Wallet Number',
                      controller: _walletCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.credit_card_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Enter wallet number' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _verify,
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGlow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                      ),
                      child: _verifying
                          ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: AppTheme.accent, strokeWidth: 2))
                          : const Center(
                          child: Text('Verify',
                              style: TextStyle(
                                  color: AppTheme.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13))),
                    ),
                  ),
                ],
              ),

              if (_verifiedWallet != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGlow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _verifiedWallet!.username.isNotEmpty
                                ? _verifiedWallet!.username[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: AppTheme.accent, fontWeight: FontWeight.w800, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_verifiedWallet!.username,
                              style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          const SizedBox(height: 2),
                          const Text('Verified ✓',
                              style: TextStyle(color: AppTheme.accent, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
              const Text('Amount',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Amount (SAR)',
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.payments_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'Enter valid amount';
                  return null;
                },
              ),


              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [50, 100, 200, 500]
                    .map((a) => GestureDetector(
                  onTap: () => _amountCtrl.text = a.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Text('SAR $a',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ))
                    .toList(),
              ),

              const SizedBox(height: 36),
              GradientButton(
                label: 'Send Money',
                onPressed: _send,
                loading: _sending,
              ),
            ],
          ),
        ),
      ),
    );
  }
}