import 'package:flutter/material.dart';
import 'package:todo_list/storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.storage, this.testing = false})
      : super(key: key);

  final ItemsStorage storage;
  final bool testing;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String newItem = '';
  List<String> todoList = [];

  @override
  void initState() {
    super.initState();
    if (!widget.testing) {
      widget.storage.localFileExists.then((bool exists) {
        if (!exists) {
          widget.storage.createLocalFile();
          Navigator.pushReplacementNamed(context, '/tour');
        }
      });

      widget.storage.readItems().then((List<String> items) {
        setState(() {
          todoList = items;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = todoList.length == 0
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.create,
                    color: Colors.deepPurpleAccent,
                    size: 64,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Тут пусто...",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Добавьте элемент, нажав на +.',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: todoList.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(todoList[index]),
                child: Card(
                  child: ListTile(
                    title: Text(todoList[index]),
                    trailing: IconButton(
                      tooltip: 'Удалить',
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          todoList.removeAt(index);
                          widget.storage.writeItems(todoList);
                        });
                      },
                    ),
                    onTap: () {
                      showAddDialog(context, index: index);
                    },
                  ),
                ),
                onDismissed: (DismissDirection direction) {
                  setState(() {
                    todoList.removeAt(index);
                    widget.storage.writeItems(todoList);
                  });
                },
              );
            },
          );

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Список дел'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              List<PopupMenuEntry> itemList = [];
              for (MenuItems item in MenuItems.values) {
                itemList.add(PopupMenuItem(
                  value: item,
                  child: Text(item.name),
                ));
              }
              return itemList;
            },
            onSelected: (value) {
              switch (value) {
                case MenuItems.clearAll:
                  setState(() {
                    todoList.clear();
                    widget.storage.writeItems(todoList);
                  });
                  break;
                case MenuItems.showStart:
                  Navigator.pushReplacementNamed(context, '/tour');
                  break;
              }
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'Добавить',
        onPressed: () {
          showAddDialog(context);
        },
      ),
    );
  }

  void showAddDialog(BuildContext context, {int? index}) {
    String? startText = index == null ? null : todoList[index];
    if (startText != null) newItem = startText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).backgroundColor,
          title: Text(
            startText == null ? 'Добавить' : 'Изменить',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: TextField(
            autofocus: true,
            onChanged: (String input) {
              newItem = input;
            },
            controller: TextEditingController(
              text: startText,
            ),
            style: TextStyle(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            cursorColor: Theme.of(context).primaryColor,
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
              ),
              onPressed: () {
                if (index != null) {
                  setState(() {
                    todoList.removeAt(index);
                    todoList.insert(index, newItem);
                  });
                } else {
                  setState(() {
                    todoList.add(newItem);
                  });
                }

                widget.storage.writeItems(todoList);

                Navigator.of(context).pop();
              },
              child: startText == null ? Text('Добавить') : Text("Изменить"),
            ),
          ],
        );
      },
    );
  }
}

enum MenuItems {
  clearAll,
  showStart,
}

extension MenuItemsExt on MenuItems {
  String get name {
    switch (this) {
      case MenuItems.clearAll:
        return 'Очистить всё';
      case MenuItems.showStart:
        return 'Показать начало';
      default:
        return this.toString();
    }
  }
}
