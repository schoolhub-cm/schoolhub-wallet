// lib/screens/schoolhub/schoolhub_etablissement_view.dart
// Vue Établissement : état de l'abonnement actuel et catalogue des offres

import 'package:flutter/material.dart';
import '../../services/schoolhub_service.dart';

class SchoolHubEtablissementView extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRefresh;

  const SchoolHubEtablissementView({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  @override
  State<SchoolHubEtablissementView> createState() => _SchoolHubEtablissementViewState();
}

class _SchoolHubEtablissementViewState extends State<SchoolHubEtablissementView> {
  static const _primary = Color(0xFF4F46E5);
  final _service = SchoolHubService();

  Map<String, dynamic>? get _aboActif => widget.data['abonnement_actif'] as Map<String, dynamic>?;
  List<dynamic> get _offres => (widget.data['offres'] as List?) ?? [];

  @override
  Widget build(BuildContext context) {
    final etabNom = widget.data['etablissement_nom'] ?? 'Établissement Scolaire';

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      color: _primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(etabNom)),
          SliverToBoxAdapter(child: _buildSubscriptionStatus()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Offres d'Abonnement SchoolHub",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)),
                  ),
                ],
              ),
            ),
          ),
          if (_offres.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Aucune offre disponible actuellement.', style: TextStyle(color: Color(0xFF94A3B8))),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _buildOffreCard(_offres[i] as Map<String, dynamic>),
                childCount: _offres.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withOpacity(0.3),
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
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Espace Établissement', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                Text(nom, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                Text(
                  widget.data['schoolhub_email'] ?? '',
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
                Text('Admin', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatus() {
    final actif = _aboActif != null;
    final offreNom = _aboActif?['offre'] ?? 'Aucun abonnement actif';
    final dateFin = _aboActif?['date_fin'] ?? '-';
    final jours = _aboActif?['jours_restants'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: actif ? const Color(0xFFBBF7D0) : const Color(0xFFFED7AA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: actif ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  actif ? Icons.workspace_premium_rounded : Icons.warning_amber_rounded,
                  color: actif ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Statut d'Abonnement", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    Text(
                      offreNom,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: actif ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  actif ? 'ACTIF' : 'INACTIF',
                  style: TextStyle(
                    color: actif ? const Color(0xFF15803D) : const Color(0xFFB45309),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (actif) ...[
            const SizedBox(height: 14),
            Container(height: 1, color: const Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date d'expiration : $dateFin", style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                Text(
                  "$jours jour${jours > 1 ? 's' : ''} restant${jours > 1 ? 's' : ''}",
                  style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOffreCard(Map<String, dynamic> offre) {
    final nom = offre['nom'] ?? 'Offre';
    final prix = (offre['prix'] as num?)?.toDouble() ?? 0;
    final duree = offre['duree_mois'] ?? 1;
    final desc = (offre['description'] ?? '').toString();
    final pop = offre['est_populaire'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: pop ? const Color(0xFF818CF8) : const Color(0xFFE2E8F0),
          width: pop ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      nom,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1E293B)),
                    ),
                    Text(
                      "${prix.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF4F46E5)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Durée : $duree mois",
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.4),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showSubscriptionDialog(offre),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      "Activer avec mon Wallet (${prix.toStringAsFixed(0)} FCFA)",
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (pop)
            Positioned(
              top: 0,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: const Text(
                  'POPULAIRE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(Map<String, dynamic> offre) {
    if (_aboActif != null) {
      final offreNom = _aboActif!['offre'] ?? 'en cours';
      final dateFin = _aboActif!['date_fin'] ?? '';
      final jours = _aboActif!['jours_restants'] ?? 0;
      if (jours > 0) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B)),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Abonnement en cours', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            content: Text(
              "Votre établissement bénéficie déjà de l'abonnement « $offreNom », actif jusqu'au $dateFin ($jours jour(s) restant(s)).\\n\\nVous pourrez activer une nouvelle offre dès l'expiration de votre période en cours.",
              style: const TextStyle(color: Color(0xFF475569), height: 1.5, fontSize: 13),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Compris'),
              ),
            ],
          ),
        );
        return;
      }
    }

    final pinCtrl = TextEditingController();
    bool paying = false;
    final prix = (offre['prix'] as num?)?.toDouble() ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Activation d'Abonnement", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Offre : ${offre['nom']}", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text("Durée : ${offre['duree_mois']} mois", style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      "${prix.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(fontWeight: FontWeight.w800, color: _primary, fontSize: 16),
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
                final resp = await _service.paySubscription(
                  offreId: offre['id'] as int,
                  pin: pinCtrl.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (resp.success) {
                  widget.onRefresh();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("✅ ${resp.data?['message'] ?? 'Abonnement activé'}"),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("❌ ${resp.error}"),
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
                  : const Text("Confirmer l'activation"),
            ),
          ],
        ),
      ),
    );
  }
}
