import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ProgressCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;

  const ProgressCard({
    super.key,
    required this.totalTasks,
    required this.completedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final int percentInt = (percentage * 100).toInt();

    // Motivational tagline based on completion rate
    String tagline = "No tasks for today. Start fresh!";
    if (totalTasks > 0) {
      if (percentInt == 0) {
        tagline = "Let's make today productive!";
      } else if (percentInt < 50) {
        tagline = "Off to a good start! Keep going.";
      } else if (percentInt < 100) {
        tagline = "Over halfway there! You've got this.";
      } else {
        tagline = "Fantastic job! All tasks completed.";
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFFC96A53).withOpacity(0.2),
                  const Color(0xFFE8C5C8).withOpacity(0.15),
                ]
              : [
                  const Color(0xFFC96A53),
                  const Color(0xFFDC8672),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFFC96A53).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Progress",
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tagline,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262020)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "$completedTasks/$totalTasks",
                  style: TextStyle(
                    color: isDark ? AppColors.darkPrimary : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF332B2B)
                            : Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      height: 10,
                      width: MediaQuery.of(context).size.width * percentage * 0.72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppColors.darkPrimary, AppColors.darkAccent]
                              : [const Color(0xFFFDFBF7), AppColors.lightAccent],
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                "$percentInt%",
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
