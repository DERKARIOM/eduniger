import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/notification_model.dart';
import '../view_model/notification_view_model.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});
  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  void initState() {
    super.initState();
    // Charger au premier affichage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().chargerNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<NotificationViewModel>();
    final theme  = Theme.of(context);
    final couleurPrimaire = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(children: [
          const Text('Notifications'),
          if (vm.nonLues > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: couleurPrimaire,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${vm.nonLues}',
                style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ]),
        actions: [
          if (vm.notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (val) {
                if (val == 'lire_tout') vm.toutMarquerLues();
                if (val == 'effacer_tout') _confirmerEffacement(context, vm);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'lire_tout',
                    child: Row(children: [
                      Icon(Icons.done_all, size: 18), SizedBox(width: 8),
                      Text('Tout marquer comme lu'),
                    ])),
                const PopupMenuItem(value: 'effacer_tout',
                    child: Row(children: [
                      Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Tout effacer', style: TextStyle(color: Colors.red)),
                    ])),
              ],
            ),
        ],
      ),

      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.notifications.isEmpty
          ? _vueVide(context)
          : RefreshIndicator(
        onRefresh: vm.chargerNotifications,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: vm.notifications.length,
          separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 70),
          itemBuilder: (ctx, i) =>
              _TuileNotification(
                notif  : vm.notifications[i],
                onTap  : () => vm.marquerCommeLue(vm.notifications[i].id),
                onSuppr: () => vm.supprimer(vm.notifications[i].id),
              ),
        ),
      ),
    );
  }

  Widget _vueVide(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.notifications_none,
            size: 72,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
        const SizedBox(height: 16),
        Text('Aucune notification',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.grey)),
        const SizedBox(height: 8),
        Text('Vous serez notifié ici',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );

  void _confirmerEffacement(BuildContext ctx, NotificationViewModel vm) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Effacer tout ?'),
        content: const Text('Toutes les notifications seront supprimées.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () { Navigator.pop(ctx); vm.toutEffacer(); },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }
}

// ── Tuile individuelle ───────────────────────────────────────────────────────
class _TuileNotification extends StatelessWidget {
  const _TuileNotification({
    required this.notif,
    required this.onTap,
    required this.onSuppr,
  });

  final NotificationModel notif;
  final VoidCallback       onTap;
  final VoidCallback       onSuppr;

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final nonLue = !notif.estLue;

    return Dismissible(
      key    : Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color    : Colors.red,
        alignment: Alignment.centerRight,
        padding  : const EdgeInsets.only(right: 20),
        child    : const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onSuppr(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: nonLue
              ? theme.colorScheme.primary.withOpacity(0.06)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône + indicateur non-lu
              Stack(children: [
                CircleAvatar(
                  radius  : 22,
                  backgroundColor:
                  theme.colorScheme.primary.withOpacity(0.12),
                  child: Icon(Icons.notifications,
                      color: theme.colorScheme.primary, size: 22),
                ),
                if (nonLue)
                  Positioned(
                    top  : 0, right: 0,
                    child: Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.scaffoldBackgroundColor, width: 1.5),
                      ),
                    ),
                  ),
              ]),

              const SizedBox(width: 12),

              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.titre,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                              nonLue ? FontWeight.bold : FontWeight.normal,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formaterDate(notif.dateCreation),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.corps,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formaterDate(DateTime date) {
    final now  = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1)  return 'À l\'instant';
    if (diff.inHours   < 1)  return 'Il y a ${diff.inMinutes}m';
    if (diff.inDays    < 1)  return 'Il y a ${diff.inHours}h';
    if (diff.inDays    == 1) return 'Hier';
    return DateFormat('dd/MM').format(date);
  }
}