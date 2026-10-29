// lib/screens/transactions/history_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/transaction_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TransactionModel> _allTransactions = [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final res = await AuthService().api.getTransactionsHistory();

    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _allTransactions = res.data!
            .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _errorMessage = res.error ?? 'Impossible de charger l\'historique.';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recharges = _allTransactions.where((t) => t.isRecharge).toList();
    final paiements = _allTransactions.where((t) => !t.isRecharge).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique des Transactions'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(text: 'Toutes (${_allTransactions.length})'),
            Tab(text: 'Recharges (${recharges.length})'),
            Tab(text: 'Paiements (${paiements.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTransactions,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(_allTransactions),
                    _buildList(recharges),
                    _buildList(paiements),
                  ],
                ),
    );
  }

  Widget _buildList(List<TransactionModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_long_outlined, size: 44, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune transaction trouvée',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Vos opérations apparaîtront ici dès que vous rechargerez ou paierez.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, idx) {
          final trans = list[idx];
          return TransactionTile(
            transaction: trans,
            onTap: () => _showTransactionDetails(trans),
          );
        },
      ),
    );
  }

  void _showTransactionDetails(TransactionModel trans) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trans.typeDisplay,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (trans.isSuccess ? AppColors.success : AppColors.warning).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trans.statutDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: trans.isSuccess ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow('Montant', '${trans.montant.toStringAsFixed(0)} FCFA'),
            if (trans.balanceApres != null)
              _detailRow('Nouveau Solde', '${trans.balanceApres!.toStringAsFixed(0)} FCFA'),
            _detailRow('Date', trans.createdAt),
            if (trans.reference.isNotEmpty) _detailRow('Référence Fapshi', trans.reference),
            if (trans.description.isNotEmpty) _detailRow('Description', trans.description),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
