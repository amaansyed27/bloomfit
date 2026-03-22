import 'package:flutter/material.dart';
import '../widgets/premade_workouts_view.dart';
import '../widgets/workout_crafter_view.dart';
import '../widgets/saved_workouts_view.dart';
// import '../../authentication/data/user_repository.dart'; // Not strictly needed here if handled in widget

class WorkoutHubScreen extends StatefulWidget {
  const WorkoutHubScreen({super.key});

  @override
  State<WorkoutHubScreen> createState() => _WorkoutHubScreenState();
}

class _WorkoutHubScreenState extends State<WorkoutHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 110,
        ), // Push everything down below floating header
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header area replacing AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                "Fit Center",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFFF6B6B),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFFF6B6B),
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Explore"),
                  Tab(text: "Crafter"),
                  Tab(text: "Library"),
                ],
              ),
            ),

            // Tab View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  PremadeWorkoutsView(),
                  WorkoutCrafterView(),
                  SavedWorkoutsView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
