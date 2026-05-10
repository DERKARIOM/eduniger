import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationModel {
  final int?   dbId;
  final String id;
  final String numeroUser;
  final String titre;
  final String corps;
  final String type;       // data['type']  → "0", "1", "2"...
  final String extraData;  // data['extraData']
  final Map<String, dynamic> data;
  final DateTime dateCreation;
  bool estLue;

  NotificationModel({
    this.dbId,
    required this.id,
    required this.numeroUser,
    required this.titre,
    required this.corps,
    required this.type,
    required this.extraData,
    required this.data,
    required this.dateCreation,
    this.estLue = false,
  });

  // ✅ Priorité data['title'] > notification.title (Data Message du serveur)
  factory NotificationModel.fromRemoteMessage(
      RemoteMessage msg,
      String numeroUser,
      ) {
    final d = msg.data;
    return NotificationModel(
      id          : msg.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      numeroUser  : numeroUser,
      titre       : d['title']?.toString()     ?? msg.notification?.title ?? '',
      corps       : d['body']?.toString()       ?? msg.notification?.body  ?? '',
      type        : d['type']?.toString()       ?? '',
      extraData   : d['extraData']?.toString()  ?? '',
      data        : d,
      dateCreation: msg.sentTime ?? DateTime.now(),
      estLue      : false,
    );
  }

  // ── SQLite ──────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'id'           : id,
    'numero_user'  : numeroUser,
    'titre'        : titre,
    'corps'        : corps,
    'type'         : type,
    'extra_data'   : extraData,
    'data_json'    : jsonEncode(data),
    'date_creation': dateCreation.toIso8601String(),
    'est_lue'      : estLue ? 1 : 0,
  };

  factory NotificationModel.fromMap(Map<String, dynamic> m) =>
      NotificationModel(
        dbId        : m['db_id']        as int?,
        id          : m['id']           as String,
        numeroUser  : m['numero_user']  as String,
        titre       : m['titre']        as String,
        corps       : m['corps']        as String,
        type        : m['type']         as String,
        extraData   : m['extra_data']   as String,
        data        : jsonDecode(m['data_json'] as String)
        as Map<String, dynamic>,
        dateCreation: DateTime.parse(m['date_creation'] as String),
        estLue      : (m['est_lue'] as int) == 1,
      );
}