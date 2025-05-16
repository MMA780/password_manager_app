import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'password_entry_form.dart';
import 'dashboard_page.dart';
import 'models/password_model.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _filterCategory = "همه";
  late Box<PasswordEntry> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<PasswordEntry>('passwords');
  }

  List<String> get categories {
    Set<String> cats = {};
    for (var entry in _box.values) {
      cats.add(entry.category);
    }
    return ["همه", ...cats.toList()];
  }

  List<PasswordEntry> get filteredPasswords {
    return _box.values.where((entry) {
      bool matchesCategory =
          _filterCategory == "همه" || entry.category == _filterCategory;
      bool matchesSearch =
          _searchController.text.isEmpty ||
          entry.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          entry.username.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showAddDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PasswordEntryForm()),
    );
    if (result == true) setState(() {});
  }

  void _deletePassword(PasswordEntry entry) {
    entry.delete();
    setState(() {});
  }

  void _editPassword(PasswordEntry entry) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordEntryForm(editEntry: entry),
      ),
    );
    if (result == true) setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("مدیریت رمزها"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey[200],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              child: Text(
                'منو',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "جستجو...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("داشبورد"),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardPage()),
                  ),
            ),
            Divider(),
            ...categories.map(
              (cat) => ListTile(
                title: Text(cat),
                onTap: () {
                  setState(() {
                    _filterCategory = cat;
                    Navigator.pop(context);
                  });
                },
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text("درباره ما"),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder:
                      (_) => Container(
                        padding: EdgeInsets.all(20),
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage(
                                "assets/images/me.jpg",
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "محمدمهدی ابدال محمودآبادی",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "توسعه‌دهنده فلاتر",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  "من یک توسعه‌دهنده موبایل با علاقه به طراحی رابط کاربری زیبا و کاربردی هستم. "
                                  "همواره در پی یادگیری فناوری‌های جدید و انتقال دانش به دیگران.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _filterCategory,
                  items:
                      categories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _filterCategory = value!;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _box.listenable(),
                builder: (context, Box<PasswordEntry> box, _) {
                  if (box.values.isEmpty) {
                    return Center(child: Text("رمزی وجود ندارد"));
                  }
                  return AnimationLimiter(
                    child: ListView.builder(
                      itemCount: filteredPasswords.length,
                      itemBuilder: (context, index) {
                        var entry = filteredPasswords[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  title: Text(entry.title),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("نام کاربری: ${entry.username}"),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text("رمز: ********"),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.remove_red_eye),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return AlertDialog(
                                                    title: Text("نمایش رمز"),
                                                    content: SelectableText(
                                                      entry.password,
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop,
                                                        child: Text("بستن"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () => _editPassword(entry),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () => _deletePassword(entry),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onPressed: _showAddDialog,
          child: Icon(Icons.add, size: 32),
        ),
      ),
    );
  }
}
