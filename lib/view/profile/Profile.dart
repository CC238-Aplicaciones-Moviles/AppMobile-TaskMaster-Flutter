import 'package:flutter/material.dart';
import 'package:taskmaster_flutter/sharedPreferences/TaskmasterPrefs.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required TaskmasterPrefs prefs});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
