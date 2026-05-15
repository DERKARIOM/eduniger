import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/material.dart';

class BadgeService {
  static final BadgeService instance = BadgeService._();
  BadgeService._();

  // ── Vérifie si le badge est supporté sur cet appareil ────────────────
  Future<bool> estSupporte() async {
    try {
      return await AppBadgePlus.isSupported();
    } catch (e) {
      debugPrint('⚠️ Badge non supporté : $e');
      return false;
    }
  }

  // ── Mettre à jour le badge avec le nombre de non-lues ────────────────
  Future<void> mettreAJour(int nombreNonLues) async {
    try {
      final supporte = await estSupporte();
      if (!supporte) return;

      if (nombreNonLues <= 0) {
        await AppBadgePlus.updateBadge(0); // efface le badge
      } else {
        await AppBadgePlus.updateBadge(nombreNonLues);
      }
      debugPrint('🔴 Badge mis à jour : $nombreNonLues');
    } catch (e) {
      debugPrint('⚠️ Erreur badge : $e');
    }
  }

  // ── Effacer le badge (toutes les notifs lues) ─────────────────────────
  Future<void> effacer() async {
    await mettreAJour(0);
    debugPrint('✅ Badge effacé');
  }
}