import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_conrtroller.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/wallet_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/common_widgets.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;
    final wallet = context.watch<WalletProvider>().wallet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditSheet(context, profile?.phone, profile?.address),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar + Name
            _buildAvatar(context, profile?.username ?? '?', profile?.email ?? ''),
            const SizedBox(height: 28),

            // Wallet Info Card
            _buildWalletCard(wallet),
            const SizedBox(height: 20),

            // Info List
            _buildInfoCard(context, profile),
            const SizedBox(height: 20),

            // Settings
            _buildSettingsCard(context),
            const SizedBox(height: 20),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout_rounded, color: AppTheme.danger),
                label: const Text('Logout',
                    style: TextStyle(color: AppTheme.danger, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.danger),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String name, String email) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accent, Color(0xFF00A8E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withOpacity(0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AppTheme.primary, fontSize: 32, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(name,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
      ],
    );
  }

  Widget _buildWalletCard(wallet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wallet Number',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                CopyableText(
                  text: wallet?.walletNumber ?? '············',
                  style: const TextStyle(
                      color: AppTheme.accent, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.divider,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Balance', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                'SAR ${wallet?.balance.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, profile) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: profile?.phone ?? 'Not set',
          ),
          const Divider(color: AppTheme.divider, height: 1, indent: 56),
          _InfoTile(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: profile?.address ?? 'Not set',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () => showSuccess(context, 'Coming soon!'),
          ),
          const Divider(color: AppTheme.divider, height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.security_outlined,
            label: 'Security',
            onTap: () => showSuccess(context, 'Coming soon!'),
          ),
          const Divider(color: AppTheme.divider, height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () => showSuccess(context, 'Coming soon!'),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, String? phone, String? address) {
    final phoneCtrl = TextEditingController(text: phone);
    final addressCtrl = TextEditingController(text: address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
                style: TextStyle(
                    color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Phone',
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Address',
              controller: addressCtrl,
              prefixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 24),
            Consumer<ProfileProvider>(
              builder: (ctx, pp, _) => GradientButton(
                label: 'Save Changes',
                loading: pp.updating,
                onPressed: () async {
                  final ok = await pp.updateProfile(
                    phone: phoneCtrl.text,
                    address: addressCtrl.text,
                  );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    if (ok) showSuccess(ctx, 'Profile updated!');
                    else showError(ctx, pp.error ?? 'Update failed');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthProvider>().logout();
              context.read<WalletProvider>().clear();
              context.read<ProfileProvider>().clear();
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                Text(value,
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 20),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500))),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}