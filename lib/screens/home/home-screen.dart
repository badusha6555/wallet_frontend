import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/common_widgets.dart';
import '../../models/transcation_model.dart';
import '../../models/user_model.dart';
import '../../models/wallet_model.dart';
import '../profile/profile_screen.dart';
import '../remittance/remittance_screen.dart';
import '../transactions/add_money.dart';
import '../transactions/send_money.dart';
import '../transactions/transactions_history.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _tab = 0;
  bool _balanceVisible = true;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 2), lowerBound: 0.95, upperBound: 1.0)
      ..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<WalletProvider>().loadWallet(),
      context.read<WalletProvider>().loadTransactions(),
      context.read<ProfileProvider>().loadProfile(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _HomeTab(onRefresh: _loadData, balanceVisible: _balanceVisible,
          onToggleBalance: () => setState(() => _balanceVisible = !_balanceVisible)),
      const TransactionHistoryScreen(),
      const RemittanceScreen(showAppBar: false),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: tabs[_tab],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0)),
              _NavItem(icon: Icons.swap_horiz_rounded, label: 'History', selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1)),
              _NavItem(icon: Icons.flight_takeoff_rounded, label: 'Send Abroad', selected: _tab == 2,
                  onTap: () => setState(() => _tab = 2)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', selected: _tab == 3,
                  onTap: () => setState(() => _tab = 3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.accentGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? AppTheme.accent : AppTheme.textMuted, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.accent : AppTheme.textMuted,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _HomeTab extends StatelessWidget {
  final VoidCallback onRefresh;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;

  const _HomeTab({
    required this.onRefresh,
    required this.balanceVisible,
    required this.onToggleBalance,
  });

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>().wallet;
    final profile = context.watch<ProfileProvider>().profile;
    final transactions = context.watch<WalletProvider>().transactions;
    final loading = context.watch<WalletProvider>().loading;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppTheme.accent,
      backgroundColor: AppTheme.card,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildHeader(context, profile),
                const SizedBox(height: 8),
                _buildBalanceCard(context, wallet, loading),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 28),
                if (transactions.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Recent Activity', transactions),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          if (transactions.isEmpty)
            SliverToBoxAdapter(child: _buildEmptyTxn())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _TxnTile(txn: transactions[i], wallet: wallet),
                childCount: transactions.length.clamp(0, 5),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel? profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_greeting()},',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  profile?.username ?? '···',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF00A8E8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                (profile?.username.isNotEmpty == true)
                    ? profile!.username[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletModel? wallet, bool loading) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2137), Color(0xFF0A1628)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.accent.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.08),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onToggleBalance,
                  child: Icon(
                    balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.textMuted,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            loading
                ? const SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: AppTheme.accent, strokeWidth: 2),
                ),
              ),
            )
                : Text(
              balanceVisible
                  ? 'SAR ${fmt.format(wallet?.balance ?? 0.0)}'
                  : 'SAR ••••••',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentGlow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.credit_card_rounded, color: AppTheme.accent, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    wallet != null ? _formatWalletNumber(wallet.walletNumber) : '············',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.send_rounded,
                  label: 'Send',
                  color: AppTheme.accent,
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const SendMoneyScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.add_rounded,
                  label: 'Add Money',
                  color: const Color(0xFF9B72FF),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const AddMoneyScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.flight_takeoff_rounded,
                  label: 'Send Abroad',
                  color: const Color(0xFFFF8C42),
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const RemittanceScreen())),
                ),
              ),
              const SizedBox(width: 12),

            ],
          ),
          const SizedBox(height: 16),
          // Remittance promo banner
          _buildRemittanceBanner(context),
        ],
      ),
    );
  }

  Widget _buildRemittanceBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const RemittanceScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D2137),
              const Color(0xFF1A0A2E),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF8C42).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C42).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.public_rounded, color: Color(0xFFFF8C42), size: 20),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Compare International Rates',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('MyApp · Wise · Bank — find the best deal',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFFF8C42), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, List transactions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: const Text('See all',
                style: TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTxn() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.swap_horiz_rounded, color: AppTheme.textMuted, size: 48),
            SizedBox(height: 12),
            Text('No transactions yet',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 15)),
            SizedBox(height: 4),
            Text('Start by sending or adding money',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  String _formatWalletNumber(String num) {
    if (num.length == 12) {
      return '${num.substring(0, 4)} ${num.substring(4, 8)} ${num.substring(8)}';
    }
    return num;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TxnTile extends StatelessWidget {
  final TransactionModel txn;
  final WalletModel? wallet;

  const _TxnTile({required this.txn, this.wallet});

  @override
  Widget build(BuildContext context) {
    final isSend = txn.isSend;
    final isAdd = txn.isAddMoney;
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final dateFmt = DateFormat('MMM d, h:mm a');

    final color = isAdd
        ? const Color(0xFF9B72FF)
        : isSend
        ? AppTheme.danger
        : AppTheme.accent;

    final icon = isAdd
        ? Icons.add_circle_rounded
        : isSend
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    final title = isAdd
        ? 'Added Money'
        : isSend
        ? 'Sent to ${txn.receiverWallet}'
        : 'Received from ${txn.senderWallet}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (txn.isSuccess ? AppTheme.success : AppTheme.danger).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  txn.status,
                  style: TextStyle(
                    color: txn.isSuccess ? AppTheme.success : AppTheme.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}