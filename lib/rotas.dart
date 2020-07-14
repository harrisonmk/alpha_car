

import 'package:alpha_car/telas/Home.dart';
import 'package:alpha_car/telas/cadastro.dart';
import 'package:alpha_car/telas/painel_passageiro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Rotas {
  static Route<dynamic> gerarRotas(RouteSettings settings) {

    final argumentos = settings.arguments;

    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (_) => Home());
      case "/cadastro":
        return MaterialPageRoute(builder: (_) => Cadastro());

      case "/painel-passageiro":
        return MaterialPageRoute(builder: (_) => PainelPassageiro());
      //case "/corrida":
        //return MaterialPageRoute(builder: (_) => Corrida(argumentos));
      default:
        _erroRota();
    }
  }

  static Route<dynamic> _erroRota(){

    return MaterialPageRoute(
        builder: (_){
          return Scaffold(
            appBar: AppBar(title: Text("Tela nao encontrada!"),),
            body: Center(
              child: Text("Tela Nao Encontrada"),
            ),
          );
        }
    );

  }

}