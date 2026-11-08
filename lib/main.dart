
import 'package:flutter/material.dart';

void main() {
  runApp(const DataTrackApp());
}

class DataTrackApp extends StatelessWidget {
  const DataTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DataTrack',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101827),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class UsageEntry {
  final String name;
  final double data;
  final String time;
  final IconData icon;

  UsageEntry(this.name, this.data, this.time, this.icon);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double dataLimit = 10.0;

  final List<UsageEntry> entries = [
    UsageEntry('YouTube', 1.2, '10:30 AM', Icons.play_circle),
    UsageEntry('Instagram', 0.8, '09:15 AM', Icons.camera_alt),
    UsageEntry('Chrome', 0.5, '08:45 AM', Icons.language),
    UsageEntry('WhatsApp', 0.2, '08:00 AM', Icons.chat),
  ];

  double get totalUsed =>
      entries.fold(0, (sum, item) => sum + item.data);

  double get remaining => (dataLimit - totalUsed).clamp(0, dataLimit);

  void addUsage(String name, double amount) {
    setState(() {
      entries.insert(
        0,
        UsageEntry(
          name,
          amount,
          TimeOfDay.now().format(context),
          Icons.data_usage,
        ),
      );
    });
  }

  void showAddDialog() {
    final nameController = TextEditingController();
    final dataController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Data Usage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Application name',
                hintText: 'e.g. YouTube',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dataController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Data used (GB)',
                hintText: 'e.g. 0.5',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final amount = double.tryParse(dataController.text);

              if (name.isNotEmpty && amount != null && amount > 0) {
                addUsage(name, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (totalUsed / dataLimit).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DataTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Usage'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, User 👋',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Monitor your internet consumption',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 25),

            // Main usage card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF075985),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL DATA USED',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${totalUsed.toStringAsFixed(2)} GB',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 11,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF67E8F9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(progress * 100).toStringAsFixed(0)}% used'),
                      Text('${dataLimit.toStringAsFixed(1)} GB limit'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Statistics
            Row(
              children: [
                Expanded(
                  child: statCard(
                    'Remaining',
                    '${remaining.toStringAsFixed(2)} GB',
                    Icons.wifi,
                    Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: statCard(
                    'Data Limit',
                    '${dataLimit.toStringAsFixed(1)} GB',
                    Icons.data_usage,
                    Colors.orangeAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Weekly Usage',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            weeklyChart(),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${entries.length} apps',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...entries.map((entry) => activityTile(entry)),

            const SizedBox(height: 25),

            // Change data limit
            OutlinedButton.icon(
              onPressed: () {
                showLimitDialog();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Change Data Limit'),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget weeklyChart() {
    final values = [2.5, 3.2, 1.8, 4.1, 2.9, 3.5, 2.2];
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            children: [
              Container(
                width: 23,
                height: values[index] * 25,
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                days[index],
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget activityTile(UsageEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF334155),
            child: Icon(entry.icon, color: Colors.lightBlueAccent),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.time,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.data.toStringAsFixed(2)} GB',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.lightBlueAccent,
            ),
          ),
        ],
      ),
    );
  }

  void showLimitDialog() {
    final controller = TextEditingController(
      text: dataLimit.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Data Limit'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Monthly limit (GB)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                setState(() {
                  dataLimit = value;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}