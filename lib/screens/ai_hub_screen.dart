import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'package:samapp/screens/legacy_capsule_list_screen.dart';
import 'package:samapp/services/ai_hub/life_coach_service.dart';
import 'package:samapp/services/ai_hub/ai_chat_navigation_service.dart';
import 'package:samapp/services/ai_hub/challenge_service.dart';
import 'package:samapp/services/ai_hub/legacy_capsule_service.dart';
import 'package:samapp/screens/ai_hub/ai_chat_screen.dart';
import 'package:samapp/services/ai_hub/mission_service.dart';
import 'package:samapp/services/ai_hub/muse_service.dart';
import 'package:samapp/services/ai_hub/life_coach_service.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});

  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> {
  final MissionService _missionService = MissionService();
  final MuseService _museService = MuseService();
  final ChallengeService _challengeService = ChallengeService();
  final LegacyCapsuleService _legacyCapsuleService = LegacyCapsuleService();
  final LifeCoachService _lifeCoachService = LifeCoachService();
  final AiChatNavigationService _aiChatNavigationService = AiChatNavigationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _FeatureCard(
            icon: Icons.mic,
            title: 'Voice Assistant / Chatbot',
            description: 'Your AI buddy that talks with your stored data.',
            onTap: () => _aiChatNavigationService.navigateToAiChat(context),
          ),
          _FeatureCard(
            icon: Icons.psychology,
            title: 'AI Life Coach / Therapist',
            description: 'Trained on your own journal data to reflect your patterns back to you.',
            onTap: () => _lifeCoachService.showComingSoon(context),
          ),
          _FeatureCard(
            icon: Icons.explore,
            title: 'Random Life Missions',
            description: 'Small daily adventures to spice up your life.',
            onTap: () => _missionService.showMissionCategories(context),
          ),
          _FeatureCard(
            icon: Icons.lightbulb,
            title: 'Creative Muse Generator',
            description: 'AI-powered ideas for your next creative spark.',
            onTap: () => _museService.getCreativeMuse(context),
          ),
          _FeatureCard(
            icon: Icons.track_changes,
            title: 'Dynamic Challenges',
            description: 'Personalized missions to balance your life stats.',
            onTap: () => _challengeService.getDynamicChallenge(context),
          ),
          _FeatureCard(
            icon: Icons.watch_later,
            title: 'Legacy Capsule',
            description: 'Digital time capsules for your future self or loved ones.',
            onTap: () => _legacyCapsuleService.navigateToLegacyCapsules(context),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon, size: 40),
        title: Text(title),
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }
}
