import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/details_row.dart';
import '../../core/utils/status_badge.dart';
import '../../models/transcation_model.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final all = wallet.transactions;
    final loading = wallet.txnLoading;

    final filtered = _filter == 'ALL'
        ? all
        : all.where((t) => t.type == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterBar(),
          // List
          Expanded(
            child: loading
                ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accent))
                : filtered.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
              onRefresh: () => wallet.loadTransactions(),
              color: AppTheme.accent,
              backgroundColor: AppTheme.card,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) => _TxnDetailTile(txn: filtered[i],
                    wallet: wallet.wallet),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['ALL', 'SEND', 'RECEIVE', 'ADD_MONEY'];
    final labels = {'ALL': 'All', 'SEND': 'Sent', 'RECEIVE': 'Received', 'ADD_MONEY': 'Top-Up'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = _filter == f;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.accent : AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: selected ? AppTheme.accent : AppTheme.divider),
                ),
                child: Text(
                  labels[f]!,
                  style: TextStyle(
                    color: selected ? AppTheme.primary : AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_rounded, color: AppTheme.textMuted, size: 56),
          const SizedBox(height: 16),
          Text(
            _filter == 'ALL' ? 'No transactions yet' : 'No ${_filter.toLowerCase()} transactions',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _TxnDetailTile extends StatelessWidget {
  final TransactionModel txn;
  final wallet;

  const _TxnDetailTile({required this.txn, this.wallet});

  @override
  Widget build(BuildContext context) {
    final isSend = txn.isSend;
    final isAdd = txn.isAddMoney;
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final dateFmt = DateFormat('MMM d, yyyy • h:mm a');

    final color = isAdd
        ? const Color(0xFF9B72FF)
        : isSend
        ? AppTheme.danger
        : AppTheme.accent;

    final icon = isAdd
        ? Icons.add_circle_outlined
        : isSend
        ? Icons.north_east_rounded
        : Icons.south_west_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAdd
                            ? 'Money Added'
                            : isSend
                            ? 'Sent Money'
                            : 'Money Received',
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        txn.createdAt != null ? dateFmt.format(txn.createdAt!) : '—',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isSend ? '-' : '+'}SAR ${fmt.format(txn.amount)}',
                      style: TextStyle(
                        color: isSend ? AppTheme.danger : AppTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusBadge(status: txn.status, success: txn.isSuccess),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final dateFmt = DateFormat('MMMM d, yyyy • h:mm a');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Transaction Details',
                style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24), DetailRow('Amount', 'SAR ${fmt.format(txn.amount)}'),
            DetailRow('Type', txn.type),
            DetailRow('Status', txn.status),
            DetailRow('From', txn.senderWallet.isNotEmpty ? txn.senderWallet : '—'),
            DetailRow('To', txn.receiverWallet.isNotEmpty ? txn.receiverWallet : '—'),
            DetailRow(
                'Date', txn.createdAt != null ? dateFmt.format(txn.createdAt!) : '—'),
            DetailRow('Ref ID', txn.id.substring(0, 8).toUpperCase()),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}



