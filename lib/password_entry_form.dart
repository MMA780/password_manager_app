import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_manager_app/models/password_model.dart';

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

  final _formKey = GlobalKey<FormState>();

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
    _categoryController = TextEditingController(
      text: widget.editEntry?.category ?? "General",
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editEntry != null ? "ویرایش رمز" : "افزودن رمز جدید",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: "عنوان"),
                validator: (value) => value!.isEmpty ? "وارد کن!" : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "نام کاربری"),
                validator: (value) => value!.isEmpty ? "وارد کن!" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "رمز"),
                obscureText: true,
                validator: (value) => value!.isEmpty ? "وارد کن!" : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: "دسته‌بندی"),
                validator: (value) => value!.isEmpty ? "وارد کن!" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.editEntry != null) {
                      widget.editEntry!.title = _titleController.text;
                      widget.editEntry!.username = _usernameController.text;
                      widget.editEntry!.password = _passwordController.text;
                      widget.editEntry!.category = _categoryController.text;
                      widget.editEntry!.save();
                    } else {
                      Hive.box<PasswordEntry>('passwords').add(
                        PasswordEntry(
                          title: _titleController.text,
                          username: _usernameController.text,
                          password: _passwordController.text,
                          category: _categoryController.text,
                        ),
                      );
                    }
                    Navigator.pop(context, true);
                  }
                },
                child: Text("ذخیره"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
