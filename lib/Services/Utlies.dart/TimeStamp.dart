import 'package:cloud_firestore/cloud_firestore.dart';

DateTime parseTimestamp(dynamic timestampValue) {
  if (timestampValue == null) return DateTime.now();
  if (timestampValue is Timestamp) {
    return timestampValue.toDate();
  } else if (timestampValue is String) {
    return DateTime.tryParse(timestampValue) ?? DateTime.now();
  } else {
    return DateTime.now();
  }
}

