import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_manager_app/models/password_model.dart';

class DashboardPage extends StatelessWidget {
  final Box<PasswordEntry> _box = Hive.box<PasswordEntry>('passwords');

  Map<String, int> getCategoryCounts() {
    Map<String, int> counts = {};
    for (var entry in _box.values) {
      counts[entry.category] =
          counts.containsKey(entry.category) ? counts[entry.category]! + 1 : 1;
    }
    return counts;
  }

  Widget buildPieChart(BuildContext context) {
    final dataMap = getCategoryCounts();
    final colorList = [
      Colors.green,
      Colors.teal,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];

    return PieChart(
      PieChartData(
        sections:
            dataMap.entries.map((entry) {
              final index = dataMap.keys.toList().indexOf(entry.key);
              return PieChartSectionData(
                color: colorList[index % colorList.length],
                value: entry.value.toDouble(),
                title: "${entry.value}",
                radius: 50,
                titleStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _box.length;

    return Scaffold(
      appBar: AppBar(title: Text("داشبورد")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("تعداد کل رمزها", style: TextStyle(fontSize: 18)),
                    Chip(
                      label: Text(
                        "$total",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "توزیع بر اساس دسته",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              width: double.infinity,
              child: Center(child: buildPieChart(context)),
            ),
            SizedBox(height: 20),
            Text(
              "آخرین رمزهای اضافه شده",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _box.listenable(),
                builder: (context, Box<PasswordEntry> box, _) {
                  if (box.values.isEmpty) {
                    return Center(child: Text("رمزی وجود ندارد"));
                  }
                  final recentEntries =
                      box.values.toList().reversed.take(5).toList();
                  return ListView.builder(
                    itemCount: recentEntries.length,
                    itemBuilder: (context, index) {
                      var entry = recentEntries[index];
                      return ListTile(
                        leading: Icon(Icons.lock, color: Colors.green),
                        title: Text(entry.title),
                        subtitle: Text("${entry.username} - ${entry.category}"),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
