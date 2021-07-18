import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/archived_screen.dart';
import 'package:todo/cubit/states.dart';
import 'package:todo/done_screen.dart';
import 'package:todo/new_tasks_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  int currentIndex = 0;
  Database database;
  bool isBottomSheetShown = false;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase('todo.db', version: 1, onCreate: (database, version) {
      print('Database Created');
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
          .then((value) {
        // emit(AppCreateDatabase());
        print('table created');
      }).catchError((onError) {
        print('Error when creating Table ${onError.toString()}');
      });
    }, onOpen: (database) {
      getDataFromDatabase(database);
      print('Database Opened');
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    @required String title,
    @required String date,
    @required String time,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")')
          .then((value) {
        emit(AppInsertIntoDatabaseState());
        print('$value inserted successfully');

        getDataFromDatabase(database);
      }).catchError((onError) {
        print('Error when creating Table ${onError.toString()}');
      });

      return null;
    });
  }

  void getDataFromDatabase(database) {

    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element){
        if(element['status'] == 'new')
            newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });

      emit(AppGetFromDatabaseState());
    });
  }

  void updateData({
    @required String status,
    @required int id,
  })
  {
    database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
          getDataFromDatabase(database);
          emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    @required int id,
  })
  {
    database.rawUpdate('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
          getDataFromDatabase(database);
          emit(AppDeleteDatabaseState());
    });
  }


  void changeBottomSheetState(bool isShow) {
    isBottomSheetShown = isShow;
    emit(AppChangeBottomSheetState());
  }
}
