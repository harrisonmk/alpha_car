import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenuSidebar extends StatefulWidget {

  @override
  _MenuSidebarState createState() => _MenuSidebarState();
}

class _MenuSidebarState extends State<MenuSidebar> {


  _deslogarUSuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            color: Theme.of(context).primaryColor, //pega a cor definida como padrao
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,

                    margin: EdgeInsets.only( // da uma margem de 30 do topo e 10 do texto
                        top: 30,
                      bottom: 10,

                    ),
                    decoration: BoxDecoration( //vai ficar a imagem da pessoa
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image:AssetImage(
                              "imagens/perfil.jpg"
                          ),
                      ),
                    ),
                  ),
                  Text("Harrison Mitchell", //nome
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white
                    ),
                  ),
                  Text("harrison.mitchell@hotmail.com", //email
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Dados Pessoais",
            style: TextStyle(
              fontSize: 18
            ),
            ),

            onTap: (){


            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text("Historicos de corridas",
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            onTap: (){

            },
          ),
          ListTile(
            leading: Icon(Icons.mail),
            title: Text("Mensagens",
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            onTap: (){

            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text("Corridas Agendadas",
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            onTap: (){

            },
          ),
          ListTile(
            leading: Icon(Icons.directions_car),
            title: Text("Meus Motoristas",
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            onTap: (){

            },
          ),
          ListTile(
            leading: Icon(Icons.call),
            title: Text("Fale Conosco",
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            onTap: (){

            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text("Sair",
              style: TextStyle(
                  fontSize: 18
              ),
            ),
            onTap: (){
              setState(() {
                _deslogarUSuario();
              });
            },
          ),
        ],
      ),
    );
  }
}
