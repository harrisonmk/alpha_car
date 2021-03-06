import 'package:alpha_car/modelo/usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  TextEditingController _controleEmail = TextEditingController();
  TextEditingController _controlesenha = TextEditingController();
  String _mensagemErro = "";
  bool _carregando = false;

  _validarCampos(){

    //Recuperar dados dos campos

    String email = _controleEmail.text;
    String senha = _controlesenha.text;


    //validar campos
    if(email.isNotEmpty && email.contains("@")){
      if(senha.isNotEmpty && senha.length > 6){

        Usuario usuario = Usuario();

        usuario.email = email;
        usuario.senha = senha;


        _logarUsuario(usuario);
      }else{
        _mensagemErro = "Preencha a senha digite mais de 6 letras";
      }

    }else{
      setState(() {
        _mensagemErro = "Preencha o E-mail valido";
      });
    }

  }

  _logarUsuario(Usuario usuario){

    setState(() {
      _carregando = true;
    });

    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword( //metodo para logar no firebase
        email: usuario.email,
        password: usuario.senha
    ).then((firebaseUser) {
      _redirecionaPainelPorTipoUsuario(firebaseUser.user.uid);

    }).catchError((error){
      _mensagemErro = "Erro ao autenticar usuario, verifique e-mail e senha e tente novamente!";
    });

  }


  _redirecionaPainelPorTipoUsuario(String idUsuario) async{

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot = await db.collection("usuarios").document(idUsuario).get();

    Map<String,dynamic> dados = snapshot.data;
    String tipoUsuario = dados["tipoUsuario"];

    setState(() {
      _carregando = false;
    });
    Navigator.pushReplacementNamed(context, "/painel-passageiro");


  }

  //metodo para que o usuario se ele nao deslogar na proxima vez que abrir ele já entra no painel do usuario ou motorista
  _VerificaUsuarioLogado()async{

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser(); //recupera o usuario atual logado

    if(usuarioLogado != null){
      String idUsuario = usuarioLogado.uid;
      _redirecionaPainelPorTipoUsuario(idUsuario);
    }

  }

  @override
  void initState() {
    super.initState();

    _VerificaUsuarioLogado();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        color: Colors.black,
       /* decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/fundo.png"), //AssetImage("imagens/fundo.png")
            fit: BoxFit.cover
          )
        ), */
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[ //vai o logo e as caixas de textos
                Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: Image.asset("imagens/ALPHA-CAR.png",width: 200,height: 150,),

                ),
                TextField(
                  controller: _controleEmail,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    hintText: "e-mail",
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
                      hintText: "senha",
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
                    child: Text("Entrar",style: TextStyle(color: Colors.white,fontSize: 20),),
                    color: Color(0xff1ebbd8),
                    padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                    onPressed: (){
                     _validarCampos();
                    },
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Text("Não tem conta? cadastre-se!",style: TextStyle(color: Colors.white),),
                    onTap: (){
                     Navigator.pushNamed(context,"/cadastro");
                    },
                  ),
                ),
                _carregando ? Center(child: CircularProgressIndicator(backgroundColor: Colors.white,),): Container(),
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
