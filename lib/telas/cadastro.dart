import 'dart:io';

import 'package:alpha_car/modelo/usuario.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:image_picker/image_picker.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {

  TextEditingController _controleNome = TextEditingController();
  TextEditingController _controleTelefone = TextEditingController();
  TextEditingController _controleEmail = TextEditingController();
  TextEditingController _controlesenha = TextEditingController();
  var maskFormatter = new MaskTextInputFormatter(mask: '(###) #####-####', filter: { "#": RegExp(r'[0-9]') });


  //bool _tipoUsuario = false;
  String _mensagemErro = "";



 File _imagem;
 final picker = ImagePicker();


  //metodo para pegar uma imagem da camera ou galeria | se for true pega imagem da camera se for false pega imagem da galeria
 Future getImage(bool dacamera)async{

   if (dacamera == true) { //da camera
     final pickedFile = await picker.getImage(source: ImageSource.camera);
     setState(() {
       _imagem = File(pickedFile.path);
     });
   }else{

     final pickedFile = await picker.getImage(source: ImageSource.gallery);
     setState(() {
       _imagem = File(pickedFile.path);
     });
   }

 }

 verificaImagemVazia(){
   _imagem == null ? Icons.add_a_photo : Image.file(_imagem);
 }


  _validarCampos(){

    //Recuperar dados dos campos
    String nome = _controleNome.text;
    String telefone = _controleTelefone.text;
    String email = _controleEmail.text;
    String senha = _controlesenha.text;

    //validar campos
    if(nome.isNotEmpty){
      if(telefone.isNotEmpty && telefone.length >=15) {
        if (email.isNotEmpty && email.contains("@")) {
          if (senha.isNotEmpty && senha.length > 6) {
            Usuario usuario = Usuario();
            usuario.nome = nome;
            usuario.telefone = telefone;
            usuario.email = email;
            usuario.senha = senha;
            //usuario.tipoUsuario = usuario.verificaTipoUsuario(_tipoUsuario);

            _cadastrarUsuario(usuario);
          } else {
            _mensagemErro = "Preencha a senha digite mais de 6 letras";
          }
        } else {
          setState(() {
            _mensagemErro = "Preencha o E-mail valido";
          });
        }
      }else{
        _mensagemErro = "Preencha seu Telefone";
      }

    }else{
      setState(() {
        _mensagemErro = "Preencha o Nome";
      });
    }

  }

  _cadastrarUsuario(Usuario usuario){

    FirebaseAuth auth = FirebaseAuth.instance;
    Firestore db = Firestore.instance;

    auth.createUserWithEmailAndPassword(email: usuario.email, password: usuario.senha).then((firebaseUser){
      db.collection("usuarios").document(firebaseUser.user.uid).setData(usuario.toMap());

      Navigator.pushNamedAndRemoveUntil( //remove a opcao de voltar
          context,
          "/painel-passageiro",
              (_)=>false
      );

      //redireciona para o painel, de acordo com o tipo de usuario "tipoUsuario"
      /*switch(usuario.tipoUsuario){

        case "passageiro":
          Navigator.pushNamedAndRemoveUntil( //remove a opcao de voltar
              context,
              "/painel-passageiro",
                  (_)=>false
          );
          break;
      }*/

    }).catchError((error){
      _mensagemErro = "Erro ao autenticar usuario, verifique e-mail e senha e tente novamente!";
    });

  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
      ),
      body: Container(


        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[    //vai o logo e as caixas de textos

              Container(
                margin: EdgeInsets.all(30),
                height: 200,
              child:
               GestureDetector(

                  onTap: (){
                    getImage(false);
                  },
                  child: _imagem == null ? Image(image:AssetImage("imagens/ui.png"),height: 30,width: 20,) : Image.file(_imagem),
               ),
              ),

               /* Container(
                   margin: EdgeInsets.all(30),
                   height: 200,
                   child: _imagem == null ? Text("") : Image.file(_imagem),

                 ),
                FloatingActionButton(

                  onPressed: (){
                    getImage(false);
                   },
                  tooltip: 'Pick Image',
                  child: Icon(Icons.add_a_photo),

                ),*/


              /*  Container(

                  width: 400, //300
                  height: 200,//100

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

                ),*/
               SizedBox(height: 30,),
                TextField(
                  controller: _controleNome,
                  autofocus: true,
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Nome Completo",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                      )
                  ),
                ),
                SizedBox(height: 16,), //espacamento de 16 de altura
                TextField(
                  controller: _controleTelefone,
                  inputFormatters: [maskFormatter],
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Telefone (DDD) 99999-1919",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                      )
                  ),
                ),
                SizedBox(height: 16,), //espacamento de 16 de altura
                TextField(
                  controller: _controleEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "E-mail",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                      )
                  ),
                ),
                SizedBox(height: 16,), //espacamento de 16 de altura
                TextField(
                  controller: _controlesenha,
                  obscureText: true, //mascara a senha
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                      hintText: "Senha",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6)
                      )
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 16,bottom: 10),
                  child: RaisedButton(
                    child: Text("Cadastrar",style: TextStyle(color: Colors.white,fontSize: 20),),
                    color: Color(0xff1ebbd8),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: (){
                   _validarCampos();
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(_mensagemErro,style: TextStyle(color:Colors.red,fontSize: 20),),
                  ),
                )
              ],
            ),
          ),
        ),
      ),

    );
  }
}
