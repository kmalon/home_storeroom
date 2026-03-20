import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// null = use system locale
final localeProvider = StateProvider<Locale?>((ref) => null);
