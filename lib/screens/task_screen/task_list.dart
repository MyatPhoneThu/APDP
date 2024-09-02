import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth_screens/login_screen.dart';
import '../../models/auth.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final GlobalKey<FormState> _fromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _fromKeyForUpdate = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task'),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await UserAuth.clearUserAuth();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (cntxt) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: firestore.collection(firebaseAuth.currentUser!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData == true &&
              snapshot.data!.docs.isEmpty == true) {
            return const Center(child: Text('No Task'));
          } else if (snapshot.data != null) {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/money1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (cntxt, index) {
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(snapshot.data!.docs[index].get('title')),
                      subtitle:
                          Text(snapshot.data!.docs[index].get('description')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: () async {
                              await updateTaskShowModalBottomSheet(
                                snapshot.data!.docs[index].get('title'),
                                snapshot.data!.docs[index].get('description'),
                                snapshot.data!.docs[index].id,
                              );
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.green,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              await firestore
                                  .collection(firebaseAuth.currentUser!.uid)
                                  .doc(snapshot.data!.docs[index].id)
                                  .delete();
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('------'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addNewTaskShowModalBottomSheet();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addNewTaskShowModalBottomSheet() async {
    showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (cntxt) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _fromKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_fromKey.currentState!.validate() == true) {
                      saveTask();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  Future<void> saveTask() async {
    String userId = firebaseAuth.currentUser!.uid;
    Map<String, String> task = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
    };
    firestore.collection(userId).doc().set(task).then((_) {
      log('Task Added.');
      _fromKey.currentState!.reset();
    }).catchError((onError) {
      log(onError.toString());
    });
  }

  Future<void> updateTaskShowModalBottomSheet(
      String title, String description, String documentId) async {
    _titleController.text = title;
    _descriptionController.text = description;
    showModalBottomSheet<void>(
      context: context,
      enableDrag: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (cntxt) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Form(
            key: _fromKeyForUpdate,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text('Update Task'),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Enter the description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_fromKeyForUpdate.currentState!.validate() == true) {
                      updateTask(
                        _titleController.text.trim(),
                        _descriptionController.text.trim(),
                        documentId,
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    ).then((value) {
      _titleController.clear();
      _descriptionController.clear();
    });
  }

  Future<void> updateTask(
      String title, String description, String taskId) async {
    String userId = firebaseAuth.currentUser!.uid;
    Map<String, String> task = {
      'title': title,
      'description': description,
    };

    firestore.collection(userId).doc(taskId).update(task).then((_) {
      log('Task Updated.');
      Navigator.pop(context);
    }).catchError((error) {
      log(error.toString());
    });
  }
}
