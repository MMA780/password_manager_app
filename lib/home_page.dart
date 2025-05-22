import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:password_manager_app/dashboard_page.dart';
import 'package:password_manager_app/models/password_model.dart';
import 'package:password_manager_app/password_entry_form.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:animate_do/animate_do.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _filterCategory = "همه";
  late Box<PasswordEntry> _box;
  bool _isSearching = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _box = Hive.box<PasswordEntry>('passwords');
    _searchController.addListener(() {
      setState(() {});
    });
  }

  List<String> get categories {
    Set<String> cats = {"همه"};
    _box.values.forEach((entry) {
      if (entry.category.isNotEmpty) {
        cats.add(entry.category);
      }
    });
    var sortedCats = cats.toList();
    sortedCats.sort((a, b) {
      if (a == "همه") return -1;
      if (b == "همه") return 1;
      return a.compareTo(b);
    });
    return sortedCats;
  }

  List<PasswordEntry> get filteredPasswords {
    final allPasswords = _box.values.toList();
    // مرتب سازی پیشرفته تر: ابتدا بر اساس عنوان، سپس بر اساس نام کاربری
    allPasswords.sort((a, b) {
      int titleComparison = a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      );
      if (titleComparison != 0) {
        return titleComparison;
      }
      return a.username.toLowerCase().compareTo(b.username.toLowerCase());
    });

    return allPasswords.where((entry) {
      bool matchesCategory =
          _filterCategory == "همه" || entry.category == _filterCategory;
      bool matchesSearch =
          _searchController.text.isEmpty ||
          entry.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          entry.username.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          entry
              .category // جستجو در دسته بندی هم اضافه شد
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showAddOrEditDialog({PasswordEntry? entry}) async {
    HapticFeedback.lightImpact(); // بازخورد لمسی
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        // انیمیشن سفارشی برای باز شدن صفحه
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                PasswordEntryForm(editEntry: entry),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0); // شروع از پایین
          const end = Offset.zero;
          const curve = Curves.easeOutQuint; // منحنی نرم
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var fadeTween = Tween<double>(begin: 0.5, end: 1.0); // محو شدن همزمان

          return FadeTransition(
            opacity: animation.drive(fadeTween),
            child: SlideTransition(
              position: animation.drive(tween),
              child: child,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 400), // سرعت انتقال
      ),
    );
    if (result == true) {
      setState(() {});
    }
  }

  void _deletePassword(PasswordEntry entry) {
    showDialog(
      context: context,
      builder:
          (BuildContext ctx) => AlertDialog(
            title: Text(
              'تایید حذف رمز',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.right,
            ),
            content: Text(
              'آیا از حذف رمز "${entry.title}" برای همیشه مطمئن هستید؟',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            actionsAlignment:
                MainAxisAlignment.spaceEvenly, // توزیع بهتر دکمه ها
            actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'انصراف',
                  style: TextStyle(color: Colors.grey[700], fontSize: 14.5),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.delete_forever_rounded, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                label: Text('بله، حذف کن', style: TextStyle(fontSize: 14.5)),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  entry.delete();
                  setState(() {});
                  Navigator.of(ctx).pop();
                  Fluttertoast.showToast(msg: "رمز با موفقیت حذف شد");
                },
              ),
            ],
          ),
    );
  }

  void _copyToClipboard(String text, String fieldName) {
    Clipboard.setData(ClipboardData(text: text));
    Fluttertoast.showToast(
      msg: "$fieldName کپی شد!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER, // نمایش در مرکز
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.95),
      textColor: Colors.white,
      fontSize: 15.0,
    );
    HapticFeedback.selectionClick(); // بازخورد لمسی
  }

  void _showPassword(PasswordEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            entry.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.right,
          ),
          contentPadding: EdgeInsets.fromLTRB(20, 16, 20, 16), // پدینگ سفارشی
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "نام کاربری:",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SelectableText(
                entry.username,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 12),
              Text(
                "رمز عبور:",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(
                    0.7,
                  ), // پس زمینه کمی متفاوت
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 0.8),
                ),
                child: SelectableText(
                  entry.password,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          actionsAlignment: MainAxisAlignment.center, // دکمه در مرکز
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                "بستن",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textAlign: TextAlign.right,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "جستجو در عناوین، نام‌های کاربری و دسته‌بندی‌ها...",
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 15.5,
        ),
        // آیکون جستجو در ابتدای فیلد (سمت راست در RTL)
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(end: 8.0),
          child: Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.8),
            size: 22,
          ),
        ),
        // برای همخوانی با ارتفاع AppBar
        contentPadding: EdgeInsets.symmetric(vertical: 0),
      ),
      style: TextStyle(color: Colors.white, fontSize: 16),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwords = filteredPasswords;
    final bool isListEmpty = passwords.isEmpty;
    final bool isDefaultState =
        _searchController.text.isEmpty && _filterCategory == "همه";

    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title:
                _isSearching
                    ? _buildSearchField() // انیمیشن برای فیلد جستجو قبلا در خودش اعمال شده
                    : FadeInDown(
                      duration: Duration(milliseconds: 300),
                      child: Text("مدیریت رمزها"),
                    ),
            pinned: true,
            floating: true,
            snap: true,
            elevation: Theme.of(context).appBarTheme.elevation,
            leading: IconButton(
              // دکمه منو
              icon: Icon(Icons.menu_rounded),
              tooltip: "باز کردن منو",
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    _isSearching ? Icons.close_rounded : Icons.search_rounded,
                    key: ValueKey<bool>(_isSearching),
                  ),
                ),
                tooltip: _isSearching ? "بستن جستجو" : "جستجو",
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                    if (!_isSearching) {
                      _searchController.clear();
                    } else {
                      // اگر جستجو باز شد، کیبورد هم باز شود (اختیاری)
                      // FocusScope.of(context).requestFocus(FocusNode()); // نیاز به تعریف FocusNode برای TextField
                    }
                  });
                },
              ),
            ],
          ),
          if (categories.length > 1)
            SliverPersistentHeader(
              delegate: _SliverFilterDelegate(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(
                    0.98,
                  ), // کمی شفافیت برای افکت بهتر
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  child: BounceInDown(
                    delay: Duration(milliseconds: _isSearching ? 50 : 150),
                    duration: Duration(milliseconds: 400),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ), // پدینگ داخلی کمتر
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12), // گردی بیشتر
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.06,
                            ), // سایه خیلی ملایم
                            spreadRadius: 0.5,
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _filterCategory,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Theme.of(context).primaryColor,
                            size: 26,
                          ),
                          itemHeight: 52,
                          dropdownColor: Theme.of(context).cardTheme.color,
                          items:
                              categories.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            _filterCategory == value
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        color:
                                            _filterCategory == value
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _filterCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                minHeight: 72, // ارتفاع متناسب با پدینگ
                maxHeight: 72,
              ),
              pinned: true,
            ),

          ValueListenableBuilder(
            valueListenable: _box.listenable(),
            builder: (context, Box<PasswordEntry> box, _) {
              if (isListEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeIn(
                            delay: Duration(milliseconds: 200),
                            duration: Duration(milliseconds: 600),
                            child: Icon(
                              isDefaultState
                                  ? Icons.shield_moon_outlined
                                  : Icons.playlist_remove_rounded,
                              size: 85,
                              color: Colors.grey[350],
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeInUp(
                            delay: Duration(milliseconds: 400),
                            duration: Duration(milliseconds: 500),
                            child: Text(
                              isDefaultState
                                  ? "فضای امن شما خالی است!"
                                  : "موردی با این جستجو یافت نشد.",
                              style: TextStyle(
                                fontSize: 18.5,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (isDefaultState) SizedBox(height: 25),
                          if (isDefaultState)
                            FadeInUp(
                              delay: Duration(milliseconds: 600),
                              duration: Duration(milliseconds: 500),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 12,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.add_moderator_outlined,
                                  size: 20,
                                ),
                                label: Text(
                                  "افزودن اولین رمز امن",
                                  style: TextStyle(fontSize: 14.5),
                                ),
                                onPressed: () => _showAddOrEditDialog(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return AnimationLimiter(
                child: SliverPadding(
                  // پدینگ برای کل لیست
                  padding: EdgeInsets.only(
                    bottom: 10,
                    top: 5,
                  ), // پدینگ بالا و پایین لیست
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      var entry = passwords[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(
                          milliseconds: 500,
                        ), // انیمیشن کلی کارت
                        child: SlideAnimation(
                          verticalOffset: 60.0, // شروع از کمی پایین‌تر
                          curve: Curves.easeOutQuint, // منحنی نرم‌تر
                          child: FadeInAnimation(
                            curve: Curves.easeInExpo, // محو شدن با شتاب
                            child: Card(
                              // استایل از theme
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16.0),
                                onTap: () => _showAddOrEditDialog(entry: entry),
                                onLongPress: () {
                                  HapticFeedback.heavyImpact();
                                  _showPassword(entry);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 14.0,
                                  ),
                                  child: Row(
                                    children: [
                                      // آواتار دسته بندی با انیمیشن
                                      ZoomIn(
                                        duration: Duration(milliseconds: 400),
                                        delay: Duration(
                                          milliseconds: 100 + (index % 5 * 50),
                                        ), // تاخیر پلکانی
                                        child: CircleAvatar(
                                          radius: 23,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.1),
                                          child: Text(
                                            entry.category.isNotEmpty
                                                ? entry.category[0]
                                                    .toUpperCase()
                                                : "؟",
                                            style: TextStyle(
                                              fontSize: 17,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.title,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.right,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              "نام کاربری: ${entry.username}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                              textAlign: TextAlign.right,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 3),
                                            Text(
                                              "رمز عبور: •••••••••",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                letterSpacing: 0.5,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.all(
                                              6,
                                            ), // پدینگ کمتر
                                            constraints: BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ), // اندازه دکمه
                                            icon: Icon(
                                              Icons.visibility_outlined,
                                              color: Colors.blueGrey[300],
                                              size: 21,
                                            ),
                                            tooltip:
                                                "نمایش اطلاعات", // تغییر tooltip
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              _showPassword(entry);
                                            },
                                          ),
                                          PopupMenuButton<String>(
                                            padding:
                                                EdgeInsets
                                                    .zero, // حذف پدینگ داخلی دکمه popup
                                            iconSize: 21,
                                            icon: Icon(
                                              Icons.more_vert_rounded,
                                              color: Colors.grey[500],
                                            ),
                                            tooltip: "گزینه‌های بیشتر",
                                            itemBuilder:
                                                (
                                                  BuildContext context,
                                                ) => <PopupMenuEntry<String>>[
                                                  _buildPopupMenuItem(
                                                    context,
                                                    'copy_user',
                                                    Icons.copy_rounded,
                                                    'کپی نام کاربری',
                                                    iconSize: 19,
                                                  ),
                                                  _buildPopupMenuItem(
                                                    context,
                                                    'copy_pass',
                                                    Icons.copy_all_rounded,
                                                    'کپی رمز',
                                                    iconSize: 19,
                                                  ),
                                                  PopupMenuDivider(height: 0.5),
                                                  _buildPopupMenuItem(
                                                    context,
                                                    'edit',
                                                    Icons.edit_note_rounded,
                                                    'ویرایش اطلاعات',
                                                    iconSize: 19,
                                                  ), // آیکون بهتر
                                                  _buildPopupMenuItem(
                                                    context,
                                                    'delete',
                                                    Icons.delete_sweep_outlined,
                                                    'حذف این رمز',
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.error,
                                                    iconSize: 19,
                                                  ), // آیکون و رنگ بهتر
                                                ],
                                            onSelected: (value) {
                                              if (value == 'copy_user')
                                                _copyToClipboard(
                                                  entry.username,
                                                  "نام کاربری",
                                                );
                                              else if (value == 'copy_pass')
                                                _copyToClipboard(
                                                  entry.password,
                                                  "رمز عبور",
                                                );
                                              else if (value == 'edit')
                                                _showAddOrEditDialog(
                                                  entry: entry,
                                                );
                                              else if (value == 'delete')
                                                _deletePassword(entry);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }, childCount: passwords.length),
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 95), // فضای بیشتر برای FAB شناور
          ),
        ],
      ),
      drawer: _buildAppDrawer(),
      floatingActionButton: ZoomIn(
        delay: Duration(
          milliseconds: isListEmpty && isDefaultState ? 1000 : 500,
        ),
        duration: Duration(milliseconds: 400),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddOrEditDialog(),
          tooltip: 'افزودن رمز جدید',
          elevation: Theme.of(context).floatingActionButtonTheme.elevation,
          icon: Icon(Icons.add_rounded, size: 26), // آیکون بزرگتر
          label: Text("افزودن رمز"), // متن کامل‌تر
          // استایل از theme
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    BuildContext context,
    String value,
    IconData icon,
    String text, {
    Color? color,
    double iconSize = 20,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 42, // ارتفاع مناسب
      padding: EdgeInsets.only(left: 12, right: 16), // پدینگ جهتی
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(width: 16), // فاصله بیشتر
          Icon(
            icon,
            color: color ?? Theme.of(context).iconTheme.color?.withOpacity(0.8),
            size: iconSize,
          ),
        ],
      ),
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      elevation: 6, // سایه بیشتر برای Drawer
      width: MediaQuery.of(context).size.width * 0.75, // عرض Drawer
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: FadeInLeft(
              delay: Duration(milliseconds: 200),
              duration: Duration(milliseconds: 450),
              child: Text(
                "محمدمهدی ابدال محمودآبادی",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
            ),
            accountEmail: FadeInLeft(
              delay: Duration(milliseconds: 300),
              duration: Duration(milliseconds: 450),
              child: Text(
                "برنامه‌نویس فلاتر",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                ),
              ),
            ),
            currentAccountPictureSize: Size.square(70), // اندازه عکس
            currentAccountPicture: ZoomIn(
              delay: Duration(milliseconds: 100),
              duration: Duration(milliseconds: 500),
              child: CircleAvatar(
                backgroundImage: AssetImage("assets/images/me.jpg"),
                backgroundColor: Colors.white,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              // image: DecorationImage(
              //   fit: BoxFit.cover,
              //   colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
              //   image: AssetImage("assets/images/drawer_bg.png"), // تصویر پس‌زمینه
              // )
            ),
            margin: EdgeInsets.zero,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 10),
              children: [
                _buildDrawerItem(
                  icon: Icons.space_dashboard_outlined, // آیکون دیگر
                  text: "داشبورد آماری", // عنوان بهتر
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DashboardPage()),
                    );
                  },
                  delayMillis: 250,
                ),
                Divider(
                  indent: 20,
                  endIndent: 20,
                  height: 0.8,
                ), // جداکننده با فاصله
                if (categories.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 20.0,
                      top: 18.0,
                      bottom: 10.0,
                      left: 20.0,
                    ),
                    child: Text(
                      "فیلتر دسته‌بندی‌ها",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                if (categories.length > 1)
                  ...categories.map((cat) {
                    int index = categories.indexOf(cat);
                    return _buildDrawerItem(
                      icon:
                          _filterCategory == cat
                              ? Icons.label_important_rounded
                              : Icons
                                  .label_outline_rounded, // آیکون‌های واضح‌تر
                      text: cat,
                      isSelected: _filterCategory == cat,
                      onTap: () {
                        setState(() {
                          _filterCategory = cat;
                        });
                        Navigator.pop(context);
                      },
                      delayMillis: 300 + (index * 50),
                    );
                  }).toList(),
                Divider(indent: 20, endIndent: 20, height: 0.8),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  text: "درباره برنامه",
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder:
                          (context) => AboutDialog(
                            applicationName: "مدیریت رمزها",
                            applicationVersion:
                                "نسخه 1.1.0", // به‌روزرسانی نسخه
                            applicationIcon: ZoomIn(
                              // انیمیشن برای لوگو
                              duration: Duration(milliseconds: 400),
                              child: ShaderMask(
                                shaderCallback:
                                    (bounds) => LinearGradient(
                                      // گرادینت خطی برای لوگو
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(context)
                                            .colorScheme
                                            .secondary, // ترکیب دو رنگ سبز
                                      ],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ).createShader(bounds),
                                child: Image.asset(
                                  "assets/images/icon.png",
                                  width: 50, // اندازه مناسب
                                  color: Colors.white, // برای اعمال ShaderMask
                                ),
                              ),
                            ),
                            applicationLegalese:
                                "© ${DateTime.now().year} محمدمهدی ابدال محمودآبادی.\nتمامی حقوق محفوظ است.",
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  "این اپلیکیشن با هدف ایجاد راهکاری امن، ساده و زیبا برای مدیریت گذرواژه‌های شما طراحی و توسعه داده شده است. اطلاعات شما به صورت رمزنگاری شده در حافظه داخلی دستگاه ذخیره می‌گردد.",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.6,
                                    color:
                                        Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  delayMillis: 350 + (categories.length * 50),
                ),
              ],
            ),
          ),
          // بخش پایینی Drawer (اختیاری)
          // Divider(),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Text("نسخه ۱.۱.۰", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
          // )
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isSelected = false,
    int delayMillis = 300,
  }) {
    return SlideInLeft(
      delay: Duration(milliseconds: delayMillis),
      duration: Duration(milliseconds: 350), // انیمیشن سریعتر
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isSelected
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).listTileTheme.iconColor?.withOpacity(0.8),
          size: 22,
        ),
        title: Text(
          text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight:
                isSelected
                    ? FontWeight.w600
                    : FontWeight.normal, // تاکید کمتر برای آیتم عادی
            color:
                isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        tileColor:
            isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.06)
                : null, // رنگ انتخاب ملایم‌تر
        contentPadding: EdgeInsetsDirectional.only(
          start: 20.0,
          end: 16.0,
          top: 4.0,
          bottom: 4.0,
        ), // پدینگ متناسب
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(isSelected ? 25 : 0),
            left: Radius.circular(isSelected ? 5 : 0),
          ),
        ), // گوشه گرد جذاب
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        }, // بازخورد لمسی
      ),
    );
  }
}

// Delegate برای SliverPersistentHeader (فیلتر دسته‌بندی‌ها)
class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _SliverFilterDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverFilterDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
