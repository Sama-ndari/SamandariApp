import 'package:flutter/material.dart';
import 'package:samapp/screens/legacy_capsule_list_screen.dart';

class LegacyCapsuleService {
  void navigateToLegacyCapsules(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LegacyCapsuleListScreen(),
      ),
    );
  }
}
