import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/common_widgets.dart';


class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      showError(context, 'Enter a valid amount');
      return;
    }
    setState(() => _loading = true);
    final ok = await context.read<WalletProvider>().addMoney(amount);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      showSuccess(context, 'SAR ${amount.toStringAsFixed(2)} added successfully!');
      Navigator.pop(context);
    } else {
      showError(context, context.read<WalletProvider>().error ?? 'Failed to add money');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>().wallet;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current balance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A0A37), Color(0xFF0A1628)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF9B72FF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Balance',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    'SAR ${wallet?.balance.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wallet?.walletNumber ?? '············',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Enter Amount',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            AppTextField(
              label: 'Amount (SAR)',
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              prefixIcon: Icons.add_card_rounded,
            ),
            const SizedBox(height: 16),

            // Quick amounts
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
              physics: const NeverScrollableScrollPhysics(),
              children: [100, 250, 500, 1000, 2500, 5000]
                  .map((a) => GestureDetector(
                onTap: () => _amountCtrl.text = a.toString(),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Text(
                    'SAR $a',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 32),

            // Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.warning.withOpacity(0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This is a simulated top-up. In production, payment gateway integration is required.',
                      style: TextStyle(color: AppTheme.warning, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: 'Add Money',
              onPressed: _add,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}