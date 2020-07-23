import 'package:alpha_car/rotas.dart';
import 'package:alpha_car/telas/Home.dart';
import 'package:flutter/material.dart';


final ThemeData temaPadrao = ThemeData(
    primaryColor: Color(0xff37474f),
    accentColor: Color(0xff546e7a)
);

void main() {
  runApp(
      MaterialApp(
        title: "Alpha Car",
        home: Home(),
        theme: temaPadrao,
        initialRoute: "/",
        onGenerateRoute: Rotas.gerarRotas,
        debugShowCheckedModeBanner: false,

      ));
}


