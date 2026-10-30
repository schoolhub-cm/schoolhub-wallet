// lib/screens/schoolhub/schoolhub_parent_view.dart
// Vue Parent : liste des enfants + tranches de pension

import 'package:flutter/material.dart';
import '../../services/schoolhub_service.dart';

class SchoolHubParentView extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRefresh;

  const SchoolHubParentView({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  @override
  State<SchoolHubParentView> createState() => _SchoolHubParentViewState();
}

class _SchoolHubParentViewState extends State<SchoolHubParentView> {
  static const _primary = Color(0xFF4F46E5);
  final _service = SchoolHubService();
  int _selectedChild = 0;

  List<dynamic> get _enfants => (widget.data['enfants'] as List?) ?? [];

  @override
  Widget build(BuildContext context) {
    final parentNom = widget.data['parent_nom'] ?? 'Parent';

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      color: _primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(parentNom)),
          if (_enfants.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('Aucun enfant associé trouvé.'),
              ),
            ),
          if (_enfants.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildChildSelector()),
            SliverToBoxAdapter(child: _buildTranchesSection()),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(String nom) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Espace Parent', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                Text(nom, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                Text(
                  '${_enfants.length} enfant${_enfants.length > 1 ? "s" : ""} enregistré${_enfants.length > 1 ? "s" : ""}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                SizedBox(width: 4),
                Text('Lié', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text('Mes enfants', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B))),
        ),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _enfants.length,
            itemBuilder: (ctx, i) {
              final e = _enfants[i] as Map<String, dynamic>;
              final selected = i == _selectedChild;
              final prenom = (e['prenom'] ?? '').toString();
              final nom = (e['nom'] ?? '').toString();
              final initials = '${prenom.isNotEmpty ? prenom[0] : "?"}${nom.isNotEmpty ? nom[0] : ""}';
              return GestureDetector(
                onTap: () => setState(() => _selectedChild = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)])
                        : null,
                    color: selected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? Colors.transparent : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: selected ? [
                      BoxShadow(
                        color: _primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        initials,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: selected ? Colors.white : _primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prenom,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? Colors.white70 : const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTranchesSection() {
    if (_enfants.isEmpty) return const SizedBox.shrink();

    final enfant = _enfants[_selectedChild] as Map<String, dynamic>;
    final tranches = (enfant['tranches'] as List?) ?? [];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${enfant['prenom']} ${enfant['nom']} — Tranches de pension',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B)),
                ),
              ),
              Text(
                'Matr: ${enfant['matricule'] ?? ""}',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tranches.isEmpty)
            _buildEmptyTranches()
          else
            ...tranches.map((t) => _buildTrancheCard(t as Map<String, dynamic>, enfant)),
        ],
      ),
    );
  }

  Widget _buildEmptyTranches() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 40, color: Color(0xFF10B981)),
            SizedBox(height: 8),
            Text('Toutes les tranches sont à jour !', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrancheCard(Map<String, dynamic> tranche, Map<String, dynamic> enfant) {
    final paye = tranche['paye'] == true;
    final montant = (tranche['montant'] as num).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: paye ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: paye ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                paye ? Icons.check_circle_rounded : Icons.payment_rounded,
                color: paye ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tranche['nom'] ?? 'Tranche', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(
                    'Échéance: ${tranche['date_limite'] ?? "-"}',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${montant.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                if (paye)
                  const Text('Payé', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600))
                else
                  GestureDetector(
                    onTap: () => _showPayDialog(tranche, enfant),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Payer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(Map<String, dynamic> tranche, Map<String, dynamic> enfant) {
    final pinCtrl = TextEditingController();
    bool paying = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Paiement de pension', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.child_care_rounded, color: _primary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${enfant['prenom']} ${enfant['nom']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(tranche['nom'] ?? '', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          Text(
                            '${(tranche['montant'] as num).toStringAsFixed(0)} FCFA',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: _primary, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PIN Wallet (4 chiffres)',
                  prefixIcon: const Icon(Icons.lock_rounded, color: _primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: paying ? null : () async {
                setDialogState(() => paying = true);
                final resp = await _service.payPension(
                  eleveId: enfant['id'] as int,
                  trancheId: tranche['id'] as int,
                  pin: pinCtrl.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (resp.success) {
                  widget.onRefresh();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ${resp.data?["message"] ?? "Paiement réussi"} — Reçu: ${resp.data?["numero_recu"] ?? ""}'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ ${resp.error}'),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: paying
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }
}
