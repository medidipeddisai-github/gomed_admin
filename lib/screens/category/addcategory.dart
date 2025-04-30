import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/categoryprovider.dart';
import 'package:gomed_admin/widgets/mainappbar.dart';
import 'package:gomed_admin/widgets/topbar.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final bool isEdit;

  const AddCategoryScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.isEdit = false,
  });

  @override
  ConsumerState<AddCategoryScreen> createState() => AddCategoryScreenState();
}

class AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _categoryController.text = widget.categoryName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar:  PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: TopBar(title: 'Add/Edit Category',onBackPressed: () => Navigator.pop(context)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Category Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Enter Category Name',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final categoryName = _categoryController.text.trim();
                  if (categoryName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a category name')),
                    );
                    return;
                  }

                  bool isSuccess = false;

                  if (widget.isEdit) {
                    isSuccess = await ref.read(categoryProvider.notifier).updatecategory(
                      categoryName,
                      widget.categoryId,
                    );
                    
                    if (isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Category updated successfully!'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(' Failed to update category. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    isSuccess = await ref.read(categoryProvider.notifier).addcategory(
                      categoryName,
                    );

                    if (isSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(' Category added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(' Failed to add category. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }

                  if (isSuccess) Navigator.pop(context); // Only go back if the operation is successful
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  backgroundColor: widget.isEdit ?Colors.blue:const Color(0xFF2A9D8F),
                ),
                child: Text(widget.isEdit ? 'Update Category' : 'Add Category',style: TextStyle(color:Colors.white,),)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
