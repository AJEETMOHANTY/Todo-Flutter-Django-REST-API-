import 'package:flutter/material.dart';
import 'package:frontend/constants/api.dart';
import 'package:frontend/models/todo.dart';
import 'package:http/http.dart' as http; // Request
import 'dart:convert'; // Decode.
import 'package:frontend/widgets/app_bar.dart';
import 'package:frontend/widgets/todo_container.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:frontend/constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Todo> myTodos = [];
  bool isloading = true;
  int done = 0;

// Logic to fetch data.
  void fetchData() async {
    try {
      http.Response response = await http.get(Uri.parse(api));
      var data = jsonDecode(response.body);

      data.forEach((i) {
        Todo t = Todo(
          id: i['id'],
          title: i['title'],
          desc: i['desc'],
          isDone: i['isdone'],
          date: i['date'],
        );

        // Pie chart data change.
        if (i['isdone']) {
          done += 1;
        }

        // Add data to the list.
        myTodos.add(t);
      });

      setState(() {
        isloading = false;
      });
    } catch (e) {
      print('Error while fetch is $e');
    }
  }

// Logic to add data.
  void postdata({String title = "", String desc = ""}) async {
    try {
      http.Response response = await http.post(Uri.parse(api),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'title': title,
            'desc': desc,
            'isDone': false,
          }));
      if (response.statusCode == 201) {
        setState(() {
          myTodos = [];
        });
        fetchData();
      } else {
        print("Something went wrong in adding.");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print("Error, $e");
    }
  }

// Logic to delete data.
  void deletetodo(String id) async {
    try {
      // Request to delete.
      http.Response response = await http.delete(Uri.parse(api + '/' + id));
      // If we not add this code than the new data's gets append in previous list which cause duplicating data.
      setState(() {
        myTodos = [];
      });
      fetchData();
    } catch (e) {
      print("Error while deleting is, $e");
    }
  }

// When the app start data is retrived.
  @override
  void initState() {
    fetchData();
    super.initState();
  }

// ShowModel on Pressing Floating action button.
  void showmodel() {
    String title = "";
    String desc = "";
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Colors.white,
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Add Task",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        label: Text("Title")),
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        label: Text("Description")),
                    onChanged: (value) {
                      setState(() {
                        desc = value;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () => postdata(title: title, desc: desc),
                      child: Text("Add"))
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: customAppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            PieChart(dataMap: {
              "Done": done.toDouble(),
              "Incomplete": (myTodos.length - done).toDouble(),
            }),
            isloading
                ? CircularProgressIndicator()
                : Column(
                    children: myTodos.map((e) {
                    return TodoContainer(
                        onPress: () => deletetodo(
                            e.id.toString()), //function pass to todo_container.
                        title: e.title,
                        desc: e.desc,
                        isDone: e.isDone,
                        id: e.id);
                  }).toList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showmodel();
          },
          child: Icon(Icons.add)),
    );
  }
}
