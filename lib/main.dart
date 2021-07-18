import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:todo/home_layout.dart';
import 'package:todo/my_bloc_observer.dart';
import 'package:dcdg/dcdg.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeLayout(),
        theme: ThemeData.dark(),
      );
  }
}
