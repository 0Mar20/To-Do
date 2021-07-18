import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo/constants.dart';
import 'package:todo/cubit/cubit.dart';
import 'package:todo/cubit/states.dart';

class HomeLayout extends StatelessWidget {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if(state is AppInsertIntoDatabaseState)
          {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text("To Do"),
            ),
            body: cubit.screens[cubit.currentIndex],
            floatingActionButton: FloatingActionButton(
              child: Icon(cubit.isBottomSheetShown ? Icons.add : Icons.edit),
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formKey.currentState.validate()) {
                    cubit.insertToDatabase(title: titleController.text, date: dateController.text, time: timeController.text);
                  }
                } else {
                  scaffoldKey.currentState
                      .showBottomSheet((context) {
                    return Container(
                      padding: EdgeInsets.all(20.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                              controller: titleController,
                              prefix: Icons.title,
                              label: 'Task Title',
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return ("Task title must not be empty");
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            defaultFormField(
                              controller: timeController,
                              prefix: Icons.watch_later_outlined,
                              label: 'Task Time',
                              type: TextInputType.datetime,
                              onTap: () {
                                showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                ).then((value) {
                                  timeController.text =
                                      value.format(context).toString();
                                  print(value.format(context));
                                });
                              },
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return ("Task time must not be empty");
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            defaultFormField(
                              controller: dateController,
                              prefix: Icons.calendar_today_outlined,
                              label: 'Task Date',
                              type: TextInputType.datetime,
                              onTap: () {
                                showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.parse("2021-07-20"),
                                ).then((value) {
                                  dateController.text =
                                      DateFormat.yMMMd().format(value).toString();
                                });
                              },
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return ("Task date must not be empty");
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }, elevation: 20.0,
                  )
                      .closed
                      .then((value) {
                    cubit.changeBottomSheetState(false);
                  });
                  cubit.changeBottomSheetState(true);
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: cubit.currentIndex,
              onTap: (index) {
                cubit.changeIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Tasks"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.check_circle_outline), label: "Done"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: "Archived"),
              ],
            ),
          );
        },
      ),
    );
  }
}