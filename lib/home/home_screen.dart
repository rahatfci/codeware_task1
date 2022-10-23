import 'package:flutter/material.dart';
import 'package:codeware_task1/api_services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _CheckListState();
}

class _CheckListState extends State<HomeScreen> {
  final createFormKey = GlobalKey<FormState>();
  final updateFormKey = GlobalKey<FormState>();

  TextEditingController jobController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  TextEditingController jobUpdateController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();

  String url = "https://reqres.in/api/users";

  int page = 1;

  bool hasNextPage = true;

  bool isFirstLoadRunning = false;

  bool isLoadMoreRunning = false;

  bool isUpdate = false;

  List<User> users = [];

  void firstLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    try {
      final res = await http.get(Uri.parse("$url?page=$page"));
      setState(() {
        dynamic data = json.decode(res.body);
        users = List<User>.from(data['data'].map((x) => User.fromJson(x)));
      });
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "Something went wrong",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        duration: Duration(seconds: 1),
      ));
    }

    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() async {
    if (hasNextPage == true &&
        isFirstLoadRunning == false &&
        isLoadMoreRunning == false &&
        controller.position.extentAfter < 300) {
      setState(() {
        isLoadMoreRunning = true;
      });
      page += 1;
      try {
        final res = await http.get(Uri.parse("$url?page=$page"));
        dynamic data = json.decode(res.body);
        if (data['data'].isNotEmpty) {
          setState(() {
            users.addAll(
                List<User>.from(data['data'].map((x) => User.fromJson(x))));
          });
        } else {
          setState(() {
            hasNextPage = false;
          });
        }
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Something went wrong",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
        ));
      }

      setState(() {
        isLoadMoreRunning = false;
      });
    }
  }

  late ScrollController controller;

  @override
  void initState() {
    super.initState();
    firstLoad();
    controller = ScrollController()..addListener(loadMore);
  }

  @override
  void dispose() {
    controller.removeListener(loadMore);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Crud Based Application')),
      ),
      body: isFirstLoadRunning
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: controller,
                    itemCount: users.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: const Border(
                          bottom: BorderSide(width: 1.5, color: Colors.black54),
                        ),
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                    builder: (context, state) => AlertDialog(
                                      scrollable: true,
                                      contentPadding: const EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                          top: 20,
                                          bottom: 10),
                                      actionsAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      content: Visibility(
                                        visible: isUpdate,
                                        child: Form(
                                          key: updateFormKey,
                                          child: Column(
                                            children: [
                                              TextFormField(
                                                controller:
                                                    nameUpdateController,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                                cursorHeight: 25,
                                                decoration:
                                                    const InputDecoration(
                                                  border: UnderlineInputBorder(
                                                      borderSide:
                                                          BorderSide(width: 2)),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  width: 2)),
                                                  hintText: "Name",
                                                  hintStyle:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Please enter your name";
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              TextFormField(
                                                controller: jobUpdateController,
                                                style: const TextStyle(
                                                    fontSize: 18),
                                                cursorHeight: 25,
                                                decoration:
                                                    const InputDecoration(
                                                  border: UnderlineInputBorder(
                                                      borderSide:
                                                          BorderSide(width: 2)),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  width: 2)),
                                                  hintText: "Job",
                                                  hintStyle:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Please enter your job";
                                                  }
                                                  return null;
                                                },
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      state(() {
                                                        isUpdate = !isUpdate;
                                                      });
                                                      nameUpdateController
                                                          .clear();
                                                      jobUpdateController
                                                          .clear();
                                                    },
                                                    child: const Text(
                                                      "Cancel",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      if (updateFormKey
                                                          .currentState!
                                                          .validate()) {
                                                        int statusCode =
                                                            await updateUser(
                                                                nameUpdateController
                                                                    .text,
                                                                jobUpdateController
                                                                    .text,
                                                                users[i].id,
                                                                context);

                                                        String responseMsg = '';
                                                        if (statusCode == 200) {
                                                          nameUpdateController
                                                              .clear();
                                                          jobUpdateController
                                                              .clear();

                                                          responseMsg =
                                                              "User updated successfully";
                                                        } else {
                                                          responseMsg =
                                                              "Something went wrong";
                                                        }
                                                        Navigator.pop(context);

                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                SnackBar(
                                                          content: Text(
                                                            responseMsg,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                          duration:
                                                              const Duration(
                                                                  seconds: 1),
                                                        ));
                                                      }
                                                    },
                                                    child: const Text(
                                                      "Submit",
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        Visibility(
                                          visible: !isUpdate,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  state(() {
                                                    isUpdate = !isUpdate;
                                                    nameUpdateController.text =
                                                        users[i].firstName;
                                                    jobUpdateController.text =
                                                        users[i].email;
                                                  });
                                                },
                                                child: const Text(
                                                  "Update",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  int statusCode =
                                                      await deleteUser(
                                                          users[i].id, context);
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                  String responseMsg = '';
                                                  if (statusCode == 204) {
                                                    responseMsg =
                                                        "User deleted successfully";
                                                  } else {
                                                    responseMsg =
                                                        "Something went wrong";
                                                  }
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                      responseMsg,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    duration: const Duration(
                                                        seconds: 1),
                                                  ));
                                                },
                                                child: const Text(
                                                  "Delete",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )).then((val) {
                            setState(() {
                              isUpdate = false;
                            });
                          });
                        },
                        title: Row(
                          children: [
                            CircleAvatar(
                              radius: 15,
                              child: Text(
                                users[i].id.toString(),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              users[i].firstName,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(left: 48.0),
                          child: Text(users[i].email),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isLoadMoreRunning == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                hasNextPage == false
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        child: const Text(
                          "You have fetched all of the content",
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: IconButton(
                            onPressed: loadMore,
                            icon: const Icon(
                              Icons.arrow_downward,
                              size: 30,
                            )),
                      )
              ],
            ),
      floatingActionButton: addButton(),
    );
  }

  Widget addButton() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 25.0,
      ),
      child: FloatingActionButton(
        elevation: 12,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            contentPadding:
                const EdgeInsets.only(left: 12, right: 12, top: 20, bottom: 10),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            content: Form(
              key: createFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(fontSize: 18),
                    cursorHeight: 25,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(width: 2)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(width: 2)),
                      hintText: "Name",
                      hintStyle: TextStyle(fontSize: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: jobController,
                    style: const TextStyle(fontSize: 18),
                    cursorHeight: 25,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(width: 2)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(width: 2)),
                      hintText: "Job",
                      hintStyle: TextStyle(fontSize: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your job";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20)),
                onPressed: () async {
                  if (createFormKey.currentState!.validate()) {
                    int statusCode = await createUser(
                        nameController.text, jobController.text, context);
                    Navigator.pop(context);
                    String responseMsg = '';
                    if (statusCode == 201) {
                      responseMsg = "User added successfully";
                    } else {
                      responseMsg = "Something went wrong";
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        responseMsg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      duration: const Duration(seconds: 1),
                    ));
                    nameController.clear();
                    jobController.clear();
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Add User',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
