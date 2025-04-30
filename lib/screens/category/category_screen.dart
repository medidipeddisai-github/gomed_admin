import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomed_admin/provider/categoryprovider.dart';
import 'package:gomed_admin/screens/category/addcategory.dart';
import 'package:gomed_admin/widgets/mainappbar.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => CategoryScreenState();
}

class CategoryScreenState extends ConsumerState<CategoryScreen> {

 @override
void initState() {
  super.initState();
  Future.microtask(() => _fetchCategories()); // Correct Way
  // or alternatively
  // WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCategories());
}

void _fetchCategories() {
  ref.read(categoryProvider.notifier).getcategory();
}

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryProvider);

    return SafeArea(
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: mainTopBar(title: 'category'),
        ),
        body: categoryState.data == null || categoryState.data!.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: categoryState.data!.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final category = categoryState.data![index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        category.name ?? 'No name available',
                        style: const TextStyle(
                          color: Color(0xFF6418C3),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddCategoryScreen(
                                    categoryId: category.sId,
                                    categoryName: category.name,
                                    isEdit: true,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Delete Category'),
                                    content: const Text('Are you sure you want to delete this category?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldDelete == true) { // If the user confirmed deletion
                                bool isDeleted = await ref.read(categoryProvider.notifier).deletecategory(category.sId);

                                if (isDeleted) {
                                  _fetchCategories(); // Refresh the category list

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(" Category deleted successfully!"),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  // Show failure message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(" Failed to delete category. Please try again."),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                          )


                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCategoryScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
