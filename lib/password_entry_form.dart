import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_manager_app/models/password_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:random_string/random_string.dart' as rs;
import 'dart:math' as math;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';

class PasswordEntryForm extends StatefulWidget {
  final PasswordEntry? editEntry;

  PasswordEntryForm({this.editEntry});

  @override
  State<PasswordEntryForm> createState() => _PasswordEntryFormState();
}

class _PasswordEntryFormState extends State<PasswordEntryForm> {
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _categoryController;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final passNotifier = ValueNotifier<PasswordStrength?>(null);

  final List<String> _suggestedCategories = [
    "عمومی",
    "کار",
    "شخصی",
    "مالی و بانکی",
    "شبکه‌های اجتماعی",
    "ایمیل‌ها",
    "بازی و سرگرمی",
    "فروشگاه آنلاین",
    "سرویس‌های آنلاین",
    "سایر موارد",
  ];
  String? _selectedCategory;
  final _random = math.Random.secure();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.editEntry?.title ?? "",
    );
    _usernameController = TextEditingController(
      text: widget.editEntry?.username ?? "",
    );
    _passwordController = TextEditingController(
      text: widget.editEntry?.password ?? "",
    );
    String initialCategory =
        widget.editEntry?.category ?? _suggestedCategories.first;
    if (!_suggestedCategories.contains(initialCategory) &&
        initialCategory.isNotEmpty) {
      _categoryController = TextEditingController(text: initialCategory);
      _selectedCategory = null;
    } else {
      _categoryController = TextEditingController(text: initialCategory);
      _selectedCategory = initialCategory;
    }

    _passwordController.addListener(() {
      passNotifier.value = PasswordStrength.calculate(
        text: _passwordController.text,
      );
    });
    if (_passwordController.text.isNotEmpty) {
      passNotifier.value = PasswordStrength.calculate(
        text: _passwordController.text,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _categoryController.dispose();
    passNotifier.dispose();
    super.dispose();
  }

  String _generateStrongPassword({
    int length = 18,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSpecialChars = true,
  }) {
    if (length < 8 && length > 0) length = 8;
    if (length <= 0) length = 18;

    List<String> charCategories = [];
    if (includeLowercase) charCategories.add('abcdefghijklmnopqrstuvwxyz');
    if (includeUppercase) charCategories.add('ABCDEFGHIJKLMNOPQRSTUVWXYZ');
    if (includeNumbers) charCategories.add('0123456789');
    if (includeSpecialChars) charCategories.add('!@#\$%^&*()_-+=<>?/[]{}|~.');

    if (charCategories.isEmpty) return rs.randomAlphaNumeric(length);

    List<String> passwordChars = [];
    for (String categoryChars in charCategories) {
      if (passwordChars.length < length) {
        passwordChars.add(categoryChars[_random.nextInt(categoryChars.length)]);
      } else {
        break;
      }
    }

    String allAllowedChars = charCategories.join('');
    if (allAllowedChars.isEmpty) return rs.randomAlphaNumeric(length);

    while (passwordChars.length < length) {
      passwordChars.add(
        allAllowedChars[_random.nextInt(allAllowedChars.length)],
      );
    }
    passwordChars.shuffle(_random);
    return passwordChars.join('');
  }

  void _onGeneratePasswordPressed() {
    String newPassword = _generateStrongPassword();
    setState(() {
      _passwordController.text = newPassword;
    });
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      msg: "رمز جدید تولید و در کلیپ‌بورد کپی شد!",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.95),
      textColor: Colors.white,
      fontSize: 15.0,
    );
    Clipboard.setData(ClipboardData(text: newPassword));
  }

  void _saveForm() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      final String title = _titleController.text.trim();
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text;
      final String categoryFromTextField = _categoryController.text.trim();
      final String finalCategory;

      if (_selectedCategory != null &&
          _selectedCategory!.isNotEmpty &&
          _suggestedCategories.contains(_selectedCategory)) {
        finalCategory = _selectedCategory!;
      } else if (categoryFromTextField.isNotEmpty) {
        finalCategory = categoryFromTextField;
      } else {
        finalCategory = _suggestedCategories.first;
      }

      if (title.isEmpty || username.isEmpty || password.isEmpty) {
        Fluttertoast.showToast(
          msg: "عنوان، نام کاربری و رمز عبور نمی‌توانند خالی باشند.",
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.black87,
        );
        return;
      }

      if (widget.editEntry != null) {
        widget.editEntry!.title = title;
        widget.editEntry!.username = username;
        widget.editEntry!.password = password;
        widget.editEntry!.category = finalCategory;
        widget.editEntry!.save();
        Fluttertoast.showToast(msg: "تغییرات با موفقیت ذخیره شد");
      } else {
        Hive.box<PasswordEntry>('passwords').add(
          PasswordEntry(
            title: title,
            username: username,
            password: password,
            category: finalCategory,
          ),
        );
        Fluttertoast.showToast(msg: "رمز جدید با موفقیت اضافه شد");
      }
      if (mounted) Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: "لطفا خطاهای فرم را برطرف کنید.",
        backgroundColor: Theme.of(context).colorScheme.error,
        textColor: Theme.of(context).colorScheme.onError,
      );
      HapticFeedback.heavyImpact();
    }
  }

  String _getPasswordStrengthText(PasswordStrength? strength) {
    if (strength == null || _passwordController.text.isEmpty)
      return "برای بررسی، رمز را وارد کنید";
    switch (strength) {
      case PasswordStrength.weak:
        return 'بسیار ضعیف';
      case PasswordStrength.medium:
        return 'متوسط';
      case PasswordStrength.strong:
        return 'قوی';
      case PasswordStrength.secure:
        return 'بسیار قوی و ایمن';
      default:
        return "برای بررسی، رمز را وارد کنید";
    }
  }

  Color _getPasswordStrengthColor(
    PasswordStrength? strength,
    BuildContext context,
  ) {
    if (strength == null || _passwordController.text.isEmpty)
      return Colors.grey.shade400;
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red.shade600;
      case PasswordStrength.medium:
        return Colors.orange.shade600;
      case PasswordStrength.strong:
        return Colors.green.shade600;
      case PasswordStrength.secure:
        return Theme.of(context).primaryColorDark ??
            Theme.of(context).primaryColor;
      default:
        return Colors.grey.shade400;
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextAlign textAlign = TextAlign.right,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    int delay = 100,
    FocusNode? focusNode,
    Function(String)? onFieldSubmitted,
    Function(String)? onChanged, // اضافه کردن پارامتر onChanged به تابع کمکی
  }) {
    return FadeInDown(
      delay: Duration(milliseconds: delay),
      duration: Duration(milliseconds: 450),
      child: TextFormField(
        controller: controller,
        textAlign: textAlign,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12.0, end: 8.0),
            child: Icon(prefixIcon, size: 21),
          ),
          suffixIcon: suffixIcon,
        ),
        obscureText: obscureText,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction ?? TextInputAction.next,
        onChanged: onChanged, // استفاده از پارامتر onChanged
        onFieldSubmitted:
            onFieldSubmitted ??
            (_) {
              if (textInputAction != TextInputAction.done) {
                FocusScope.of(context).nextFocus();
              } else {
                _saveForm();
              }
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int animationDelay = 100;
    final FocusNode titleNode = FocusNode();
    final FocusNode usernameNode = FocusNode();
    final FocusNode passwordNode = FocusNode();
    final FocusNode categoryNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editEntry != null ? "ویرایش اطلاعات رمز" : "افزودن رمز جدید",
        ),
        elevation: 1.0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTextFormField(
                  focusNode: titleNode,
                  controller: _titleController,
                  labelText: "عنوان*",
                  hintText: "مثال: حساب کاربری گوگل",
                  prefixIcon: Icons.label_important_outline_rounded,
                  validator:
                      (value) =>
                          value!.trim().isEmpty
                              ? "عنوان نمی‌تواند خالی باشد"
                              : null,
                  delay: animationDelay,
                  onFieldSubmitted:
                      (_) => FocusScope.of(context).requestFocus(usernameNode),
                ),
                SizedBox(height: 20),
                _buildTextFormField(
                  focusNode: usernameNode,
                  controller: _usernameController,
                  labelText: "نام کاربری / ایمیل*",
                  hintText: "مثال: myemail@example.com",
                  prefixIcon: Icons.person_pin_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator:
                      (value) =>
                          value!.trim().isEmpty
                              ? "نام کاربری نمی‌تواند خالی باشد"
                              : null,
                  delay: animationDelay += 80,
                  onFieldSubmitted:
                      (_) => FocusScope.of(context).requestFocus(passwordNode),
                ),
                SizedBox(height: 20),
                _buildTextFormField(
                  focusNode: passwordNode,
                  controller: _passwordController,
                  labelText: "رمز عبور*",
                  hintText: "رمز عبور را وارد یا تولید کنید",
                  prefixIcon: Icons.password_rounded,
                  obscureText: _obscurePassword,
                  textAlign: TextAlign.left,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade600,
                          size: 22,
                        ),
                        tooltip:
                            _obscurePassword ? "نمایش رمز" : "پنهان کردن رمز",
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.autorenew_rounded,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                        tooltip: "تولید رمز عبور قوی",
                        onPressed: _onGeneratePasswordPressed,
                      ),
                      SizedBox(width: 4),
                    ],
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty
                              ? "رمز عبور نمی‌تواند خالی باشد"
                              : null,
                  delay: animationDelay += 80,
                  onFieldSubmitted:
                      (_) => FocusScope.of(context).requestFocus(categoryNode),
                ),
                SizedBox(height: 12),
                FadeIn(
                  delay: Duration(milliseconds: animationDelay + 50),
                  duration: Duration(milliseconds: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- PasswordStrengthChecker بدون barBuilder ---
                        PasswordStrengthChecker(
                          strength: passNotifier,
                          // اگر پارامترهای دیگری برای استایل دهی دارد، اینجا اضافه کنید
                          // مثلا:
                          // height: 8.5,
                          // strengthColors: { // این بستگی به API پکیج دارد
                          //   PasswordStrength.weak: Colors.red.shade600,
                          //   PasswordStrength.medium: Colors.orange.shade600,
                          //   PasswordStrength.strong: Colors.green.shade600,
                          //   PasswordStrength.secure: Theme.of(context).primaryColor,
                          // },
                        ),
                        SizedBox(height: 7),
                        ValueListenableBuilder<PasswordStrength?>(
                          valueListenable: passNotifier,
                          builder: (context, strengthValue, child) {
                            return Text(
                              _getPasswordStrengthText(strengthValue),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                color: _getPasswordStrengthColor(
                                  strengthValue,
                                  context,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 22),
                FadeInDown(
                  delay: Duration(milliseconds: animationDelay += 80),
                  duration: Duration(milliseconds: 400),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "انتخاب دسته‌بندی",
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 12.0,
                          end: 8.0,
                        ),
                        child: Icon(Icons.bookmark_border_rounded, size: 21),
                      ),
                    ),
                    value: _selectedCategory,
                    items:
                        _suggestedCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                category,
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                        if (newValue != null) {
                          _categoryController.text = newValue;
                        } else {
                          _categoryController.clear();
                        }
                        FocusScope.of(context).requestFocus(categoryNode);
                      });
                    },
                    isExpanded: true,
                    dropdownColor: Theme.of(
                      context,
                    ).cardTheme.color?.withOpacity(0.98),
                    borderRadius: BorderRadius.circular(12),
                    hint: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "یک دسته انتخاب کنید...",
                        style: Theme.of(context).inputDecorationTheme.hintStyle,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // --- اصلاح TextFormField برای دسته‌بندی سفارشی ---
                FadeInDown(
                  delay: Duration(milliseconds: animationDelay += 80),
                  duration: Duration(milliseconds: 400),
                  child: TextFormField(
                    // استفاده مستقیم از TextFormField
                    focusNode: categoryNode,
                    controller: _categoryController,
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: "یا دسته‌بندی سفارشی*",
                      hintText: "مثال: پروژه دانشگاه",
                      prefixIcon: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 12.0,
                          end: 8.0,
                        ),
                        child: Icon(
                          Icons.drive_file_rename_outline_rounded,
                          size: 21,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if ((_selectedCategory == null ||
                              _selectedCategory!.isEmpty) &&
                          (value == null || value.trim().isEmpty)) {
                        return "یک دسته‌بندی انتخاب یا وارد کنید";
                      }
                      return null;
                    },
                    onChanged: (text) {
                      // onChanged مستقیماً اینجا
                      if (_suggestedCategories.contains(text)) {
                        if (_selectedCategory != text) {
                          setState(() {
                            _selectedCategory = text;
                          });
                        }
                      } else {
                        if (_selectedCategory != null) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        }
                      }
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _saveForm(),
                  ),
                ),
                SizedBox(height: 40),
                FadeInUp(
                  delay: Duration(milliseconds: animationDelay + 150),
                  duration: Duration(milliseconds: 500),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.save_as_outlined, size: 22),
                    onPressed: _saveForm,
                    label: Text(
                      widget.editEntry != null ? "ذخیره تغییرات" : "افزودن رمز",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
