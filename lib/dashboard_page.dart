import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_manager_app/models/password_model.dart';
import 'package:animate_do/animate_do.dart';

class DashboardPage extends StatelessWidget {
  final Box<PasswordEntry> _passwordBox = Hive.box<PasswordEntry>('passwords');

  Map<String, int> getCategoryCounts(Box<PasswordEntry> box) {
    Map<String, int> counts = {};
    for (var entry in box.values) {
      counts[entry.category] = (counts[entry.category] ?? 0) + 1;
    }
    var sortedEntries =
        counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  List<Color> _generatePieColors(BuildContext context, int count) {
    final List<Color> baseColors = [
      Theme.of(
        context,
      ).primaryColor.withBlue(100).withGreen(180), // تنوع بیشتر در سبز
      Theme.of(context).colorScheme.secondary.withOpacity(0.9),
      Colors.teal.shade400, Colors.lightGreen.shade600, // رنگ های سبز مرتبط
      Colors.amber.shade600, Colors.deepOrange.shade400,
      Colors.blue.shade400, Colors.purple.shade300,
      Colors.pink.shade300, Colors.cyan.shade400,
    ];
    if (count <= 0) return [];
    if (count <= baseColors.length) {
      return baseColors.sublist(0, count);
    }
    List<Color> generatedColors = List.from(baseColors);
    final math.Random random = math.Random(
      123,
    ); // استفاده از seed برای تولید رنگ‌های یکسان در هر بار
    for (int i = baseColors.length; i < count; i++) {
      final hue = random.nextDouble() * 360;
      final saturation =
          0.6 + random.nextDouble() * 0.2; // اشباع رنگ متوسط تا زیاد
      final lightness =
          0.5 + random.nextDouble() * 0.2; // روشنایی متوسط تا زیاد
      generatedColors.add(
        HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor(),
      );
    }
    return generatedColors;
  }

  Widget buildPieChart(BuildContext context, Map<String, int> dataMap) {
    if (dataMap.isEmpty) {
      return Center(
        child: Text(
          "داده‌ای برای نمایش نمودار موجود نیست.",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      );
    }
    final List<Color> colorList = _generatePieColors(context, dataMap.length);
    double totalValue = dataMap.values.fold(0, (sum, item) => sum + item);
    int sectionIndex = 0;

    return PieChart(
      PieChartData(
        sections:
            dataMap.entries.map((entry) {
              final Color sectionColor =
                  colorList[sectionIndex % colorList.length];
              sectionIndex++;
              final percentage =
                  totalValue > 0 ? (entry.value / totalValue) * 100 : 0.0;
              return PieChartSectionData(
                color: sectionColor,
                value: entry.value.toDouble(),
                title:
                    percentage > 3
                        ? "${percentage.toStringAsFixed(0)}%"
                        : "", // عدم نمایش درصد خیلی کوچک
                radius: MediaQuery.of(context).size.width / 4, // شعاع بزرگتر
                titleStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color:
                      sectionColor.computeLuminance() > 0.4
                          ? Colors.black.withOpacity(0.8)
                          : Colors.white.withOpacity(0.9),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 1.5,
                    ),
                  ],
                ),
                borderSide: BorderSide(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2.0,
                ),
              );
            }).toList(),
        centerSpaceRadius:
            MediaQuery.of(context).size.width / 7.5, // فضای مرکزی کمتر
        sectionsSpace: 1.5,
        pieTouchData: PieTouchData(
          touchCallback: (
            FlTouchEvent event,
            PieTouchResponse? pieTouchResponse,
          ) {
            //   setState(() { // اگر در StatefulWidget بود
            //     if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
            //       touchedIndex = -1;
            //       return;
            //     }
            //     touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            //   });
          },
        ),
        startDegreeOffset: -90,
      ),
    );
  }

  Widget _buildLegend(BuildContext context, Map<String, int> dataMap) {
    if (dataMap.isEmpty) return SizedBox.shrink();
    final List<Color> colorList = _generatePieColors(context, dataMap.length);
    int legendIndex = 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Wrap(
        spacing: 20.0,
        runSpacing: 14.0,
        alignment: WrapAlignment.center,
        children:
            dataMap.entries.map((entry) {
              final Color legendColor =
                  colorList[legendIndex % colorList.length];
              legendIndex++;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: legendColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 2,
                          offset: Offset(0.5, 0.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "${entry.key} (${entry.value})",
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ), // استفاده از رنگ متن تم
                    textAlign: TextAlign.right,
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    int delay,
  ) {
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 450), // انیمیشن سریعتر
      child: Card(
        elevation: Theme.of(context).cardTheme.elevation,
        shape: Theme.of(context).cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 18), // فاصله بیشتر
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24, // فونت بزرگتر و خواناتر
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              // انیمیشن کوچک برای مقدار (اختیاری)
              // if (value.isNotEmpty && int.tryParse(value) != null)
              //   CountIn(
              //     from: 0,
              //     to: int.parse(value),
              //     duration: Duration(milliseconds: 800 + delay),
              //     builder: (_, val) => Text(
              //       val.toInt().toString(),
              //        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              //        textAlign: TextAlign.right,
              //     )
              //   )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEntriesList(
    BuildContext context,
    Box<PasswordEntry> box,
    int delayOffset,
  ) {
    if (box.values.isEmpty) {
      return FadeIn(
        delay: Duration(milliseconds: delayOffset + 100),
        duration: Duration(milliseconds: 500),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 35.0),
            child: Text(
              "هنوز هیچ رمزی برای نمایش وجود ندارد.",
              style: TextStyle(fontSize: 15.5, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    final recentEntries = box.values.toList().reversed.take(5).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: recentEntries.length,
      padding: EdgeInsets.only(top: 4), // کمی پدینگ بالا
      itemBuilder: (context, index) {
        var entry = recentEntries[index];
        return FadeInUp(
          delay: Duration(milliseconds: delayOffset + (index * 100)),
          duration: Duration(milliseconds: 350),
          child: Card(
            margin: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 5.5,
            ), // مارجین متناسب
            elevation: Theme.of(context).cardTheme.elevation,
            shape: Theme.of(context).cardTheme.shape,
            child: ListTile(
              contentPadding: EdgeInsetsDirectional.only(
                start: 18,
                end: 14,
                top: 10,
                bottom: 10,
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.07),
                child: Icon(
                  Icons.history_edu_outlined,
                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                  size: 23,
                ), // آیکون مرتبط
              ),
              title: Text(
                entry.title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                "${entry.username}  •  ${entry.category}",
                style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _passwordBox.listenable(),
      builder: (context, Box<PasswordEntry> box, _) {
        final currentTotal = box.length;
        final currentCategoryCounts = getCategoryCounts(box);
        int uniqueCategories = currentCategoryCounts.keys.length;
        int baseDelay = 100;

        return Scaffold(
          appBar: AppBar(
            title: Text("داشبورد آماری"), // عنوان دقیق‌تر
            elevation: Theme.of(context).appBarTheme.elevation,
          ),
          body: ListView(
            // استفاده از ListView برای اسکرول کلی صفحه
            padding: const EdgeInsets.fromLTRB(
              8.0,
              12.0,
              8.0,
              8.0,
            ), // پدینگ برای کل صفحه
            children: [
              _buildInfoCard(
                context,
                "تعداد کل رمزهای ذخیره شده",
                "$currentTotal",
                Icons.all_inbox_rounded,
                baseDelay,
              ), // آیکون بهتر
              _buildInfoCard(
                context,
                "تعداد دسته‌بندی‌های فعال",
                "$uniqueCategories",
                Icons.account_tree_outlined,
                baseDelay + 100,
              ), // آیکون بهتر
              SizedBox(height: 28),
              FadeIn(
                delay: Duration(milliseconds: baseDelay + 200),
                duration: Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "نمودار توزیع رمزها بر اساس دسته‌بندی", // عنوان توصیفی‌تر
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 19,
                    ), // استفاده از TextTheme
                  ),
                ),
              ),
              SizedBox(height: 18),
              (currentTotal > 0 && currentCategoryCounts.isNotEmpty)
                  ? BounceInUp(
                    delay: Duration(milliseconds: baseDelay + 300),
                    duration: Duration(milliseconds: 650),
                    child: Container(
                      height:
                          MediaQuery.of(context).size.width *
                          0.7, // ارتفاع نمودار
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 5,
                      ),
                      child: buildPieChart(context, currentCategoryCounts),
                    ),
                  )
                  : FadeIn(
                    delay: Duration(milliseconds: baseDelay + 300),
                    child: Container(
                      height:
                          MediaQuery.of(context).size.width *
                          0.5, // ارتفاع برای پیام
                      alignment: Alignment.center,
                      child: Text(
                        "هنوز داده‌ای برای نمایش در نمودار وجود ندارد.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              SizedBox(
                height:
                    (currentTotal > 0 && currentCategoryCounts.isNotEmpty)
                        ? 10
                        : 0,
              ), // فاصله کمتر اگر نمودار هست
              if (currentTotal > 0 && currentCategoryCounts.isNotEmpty)
                FadeIn(
                  delay: Duration(milliseconds: baseDelay + 400),
                  duration: Duration(milliseconds: 500),
                  child: _buildLegend(context, currentCategoryCounts),
                ),
              SizedBox(height: 35), // فاصله بیشتر
              FadeIn(
                delay: Duration(milliseconds: baseDelay + 500),
                duration: Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 18.0,
                    end: 18.0,
                  ), // پدینگ متناسب
                  child: Text(
                    "۵ مورد از آخرین رمزهای اضافه شده", // عنوان دقیق‌تر
                    textAlign: TextAlign.start,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 18),
                  ),
                ),
              ),
              SizedBox(height: 14),
              _buildRecentEntriesList(context, box, baseDelay + 600),
              SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }
}
