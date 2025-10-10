import 'package:flutter/material.dart';

class LifeCoachService {
  void showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI Life Coach / Therapist coming soon!')),
    );
  }
}
