import 'dart:async';
import 'package:alpha_car/modelo/destino.dart';
import 'package:alpha_car/modelo/marcador.dart';
import 'package:alpha_car/modelo/requisicao.dart';
import 'package:alpha_car/modelo/usuario.dart';
import 'package:alpha_car/telas/menu_sidebar.dart';
import 'package:alpha_car/telas/tela_informacoes_destino.dart';
import 'package:alpha_car/util/status_requisicao.dart';
import 'package:alpha_car/util/usuario_firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import 'dart:io';



class PainelPassageiro extends StatefulWidget {
  @override
  _PainelPassageiroState createState() => _PainelPassageiroState();
}

TextEditingController _controllerDestino = TextEditingController();

class _PainelPassageiroState extends State<PainelPassageiro> {

  List<String> itensMenu = [
    "Configuracoes","Deslogar"

  ];

  Completer<GoogleMapController> _controller = Completer();

  CameraPosition _posicaoCamera = CameraPosition(
      target: LatLng(0, 0),
  );

  Set<Marker> _marcadores = {};
  String _idRequisicao;
  Position _localPassageiro;
  Map<String,dynamic> _dadosRequisicao;
  StreamSubscription<DocumentSnapshot> _streamSubscriptionRequisicoes;

  //Controles para exibicao na tela
  bool _exibirCaixaEnderecoDestino = true;
  String _textoBotao = "Chamar Carro";
  Color _corBotao = Color(0xff1ebbd8);
  Function _funcaoBotao;


  _deslogarUSuario() async{
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    Navigator.pushReplacementNamed(context, "/");
  }

 _escolhaMenuItem(String escolha){

   switch(escolha){
     case "Deslogar":
    _deslogarUSuario();
       break;
     case "Configuracoes":

       break;

   }

 }

  _onMapCreated(GoogleMapController controle){

    _controller.complete(controle);

  }


  _adicionarListenerLocalizacao(){

    var geolocator = Geolocator();
    var locationOptions = LocationOptions(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10
    );

    geolocator.getPositionStream(locationOptions).listen((Position position){

      if(_idRequisicao != null && _idRequisicao.isNotEmpty){

        //Atualiza local do passageiro
        USuarioFirebase.atualizarDadosLocalizacao(_idRequisicao,position.latitude, position.longitude);


      }else {

        setState(() {
          _localPassageiro = position;
        });
        _statusUberNaoChamado();

      }


    });

  }

  //Recupera a localizacao do usuario quando ele loga no app
  _recuperarUltimaLocalizacaoConhecida()async{

    Position posicao = await Geolocator().getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);

    setState(() {
      if(posicao != null){
        _exibirMarcadorPassageiro(posicao);
        _posicaoCamera = CameraPosition(
          target: LatLng(posicao.latitude,posicao.longitude),
          zoom: 19
        );
         _localPassageiro = posicao;
        _movimentarCamera(_posicaoCamera);
      }
    });

  }

  _movimentarCamera(CameraPosition cameraposicao)async{

    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        cameraposicao
      ),
    );

  }

  _exibirMarcadorPassageiro(Position local) async{

    Usuario usu = await USuarioFirebase.getDadosUsuarioLogado();

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        "imagens/passageiro.png"
    ).then((BitmapDescriptor icone){

      Marker marcadorPassageiro = Marker(
          markerId: MarkerId("marcador-passageiro"),
          position: LatLng(local.latitude,local.longitude),
          infoWindow: InfoWindow(
              title: usu.nome  //exibe o nome do usuario no icone
          ),
          icon:icone

      );
      
      setState(() {
        _marcadores.add(marcadorPassageiro);
      });

    });



  }


  _chamarUber()async{

    String enderecoDestino = _controllerDestino.text;

    if(enderecoDestino.isNotEmpty){

      List<Placemark> listaEnderecos = await Geolocator().placemarkFromAddress(enderecoDestino);

      if(listaEnderecos != null && listaEnderecos.length > 0){
        Placemark endereco = listaEnderecos[0];
        Destino destino = Destino();
        destino.cidade = endereco.administrativeArea;
        destino.cep = endereco.postalCode;
        destino.bairro = endereco.subLocality;
        destino.rua = endereco.thoroughfare;
        destino.numero = endereco.subThoroughfare;
        destino.latitude = endereco.position.latitude;
        destino.longitude = endereco.position.longitude;

        String enderecoConfirmacao;
        enderecoConfirmacao = "\n Cidade: "+destino.cidade;
        enderecoConfirmacao += "\n Rua: "+destino.rua+ ", "+destino.numero;
        enderecoConfirmacao += "\n Rua: "+destino.bairro;
        enderecoConfirmacao += "\n Cep: "+destino.cep;

        showDialog(
            context: context,
          builder: (context){
              return AlertDialog(
                title: Text("Confirmacao de endereco"),
                content: Text(enderecoConfirmacao),
                contentPadding: EdgeInsets.all(16),
                actions: <Widget>[
                  FlatButton(
                    child: Text("cancelar",style: TextStyle(color: Colors.red),),
                    onPressed: ()=>Navigator.pop(context),
                  ),
                  FlatButton(
                    child: Text("Confirmar",style: TextStyle(color: Colors.green),),
                    onPressed: (){

                      //salvar requisicao
                      _salvarRequisicao(destino);

                      Navigator.pop(context);
                    },
                  ),
                ],
              );
          }
        );

      }

    }else{
             // TODO: COLOCAR UM ALERT DIALOG AQUI PARA O USUARIO DIGITAR O DESTINO
    }

  }


  _salvarRequisicao(Destino destino) async{

    Usuario passageiro = await USuarioFirebase.getDadosUsuarioLogado();
    passageiro.latitude = _localPassageiro.latitude;
    passageiro.longitude = _localPassageiro.longitude;

    Requisicao requisicao = Requisicao();
    requisicao.destino = destino;
    requisicao.passageiro = passageiro;
    requisicao.status = StatusRequisicao.AGUARDANDO;

    Firestore db = Firestore.instance;
    //Salvar Requisicao
    db.collection("requisicoes").document(requisicao.id).setData(requisicao.toMap());


    //Salvar requisicao ativa
    Map<String,dynamic> dadosRequisicaoAtiva = {};
    dadosRequisicaoAtiva["id_requisicao"] = requisicao.id;
    dadosRequisicaoAtiva["id_usuario"] = passageiro.idUsuario;
    dadosRequisicaoAtiva["status"] = StatusRequisicao.AGUARDANDO;

    db.collection("requisicao_ativa").document(passageiro.idUsuario).setData(dadosRequisicaoAtiva);



    //Adicionar listener requisicao
    if(_streamSubscriptionRequisicoes == null){
      _adicionarListenerRequisicao(requisicao.id);
    }



  }

  _alterarBotaoPrincipal(String texto,Color cor,Function funcao){

    setState(() {
      _textoBotao = texto;
      _corBotao = cor;
      _funcaoBotao = funcao;
    });

  }

  _statusUberNaoChamado(){

    _exibirCaixaEnderecoDestino = true;

    //Metodo
   /* _alterarBotaoPrincipal("Chamar Carro",Color(0xff1ebbd8),(){
      _chamarUber();
    });*/
    _alterarBotaoPrincipal("Escolher Destino",Color(0xff1ebbd8),(){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>TelaDestino()));
    });

    if(_localPassageiro != null){

      Position position = Position(
          latitude: _localPassageiro.latitude,
          longitude: _localPassageiro.longitude
      );

      _exibirMarcadorPassageiro(position);
      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(position.latitude,position.longitude),
          zoom: 19
      );

      _movimentarCamera(cameraPosition);

    }




  }


  _statusAguardando(){

    _exibirCaixaEnderecoDestino = false;

    //Metodo
    _alterarBotaoPrincipal("Cancelar",Colors.red,(){
      _cancelarUber();
    });


    double passageiroLat = _dadosRequisicao["passageiro"]["latitude"];
    double passageiroLong = _dadosRequisicao["passageiro"]["longitude"];
    Position position = Position(
        latitude: passageiroLat,
        longitude: passageiroLong
    );

    _exibirMarcadorPassageiro(position);
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude,position.longitude),
        zoom: 19
    );

    _movimentarCamera(cameraPosition);


  }


  _statusACaminho(){

    _exibirCaixaEnderecoDestino = false; //esconde os textField para colocar o endereco

    //Metodo
    _alterarBotaoPrincipal("Motorista a caminho",Colors.grey,(){
      //_cancelarUber(); //TODO: metodo para cancelar o uber
    });


    double latitudeDestino = _dadosRequisicao["passageiro"]["latitude"];
    double longitudeDestino = _dadosRequisicao["passageiro"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["motorista"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["motorista"]["longitude"];


    Marcador marcadorOrigem = Marcador(
        LatLng(latitudeOrigem,longitudeOrigem),
        "imagens/motorista.png",
        "Local Motorista"
    );


    Marcador marcadorDestino = Marcador(
        LatLng(latitudeDestino,longitudeDestino),
        "imagens/passageiro.png",
        "Local Destino"
    );



    //Exibir dois marcadores
    _exibirDoisMArcadores(marcadorOrigem,marcadorDestino);



  }


  _statusEmViagem(){


    _exibirCaixaEnderecoDestino = false; //esconde os textField para colocar o endereco

    _alterarBotaoPrincipal("Em viagem", Colors.grey,null);


    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["motorista"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["motorista"]["longitude"];

    Marcador marcadorOrigem = Marcador(
      LatLng(latitudeOrigem,longitudeOrigem),
      "imagens/motorista.png",
      "Local Motorista"
    );


    Marcador marcadorDestino = Marcador(
        LatLng(latitudeDestino,longitudeDestino),
        "imagens/destino.png",
        "Local Destino"
    );

    _exibirCentralizarDoisMarcadores(marcadorOrigem,marcadorDestino);


  }


  _statusFinalizada() async{


    //Calcula valor da corrida
    double latitudeDestino = _dadosRequisicao["destino"]["latitude"];
    double longitudeDestino = _dadosRequisicao["destino"]["longitude"];

    double latitudeOrigem = _dadosRequisicao["origem"]["latitude"];
    double longitudeOrigem = _dadosRequisicao["origem"]["longitude"];

    //calcula a distancia entre o ponto de origem e o ponto de destino
    double distanciaEmMetros = await Geolocator().distanceBetween(
        latitudeOrigem,
        longitudeOrigem,
        latitudeDestino,
        longitudeDestino
    );

    //Converte pra KM
    double distanciaKm = distanciaEmMetros / 1000;

    //8 reais eh o valor cobrado por KM
    double valorViagem = distanciaKm * 8;

    //Formatar valor viagem
    var valorFormatado = new NumberFormat("#,##0.00","pt_BR");
    var valorViagemFormatado = valorFormatado.format(valorViagem);



    _alterarBotaoPrincipal("Total -R\$ ${valorViagemFormatado}", Colors.green,(){

    });

    _marcadores = {};
    Position position = Position(
        latitude: latitudeDestino,
        longitude:longitudeDestino
    );

    _exibirMarcador(position,"imagens/destino.png","Motorista");
    CameraPosition  cameraPosition = CameraPosition(
        target: LatLng(position.latitude,position.longitude),
        zoom: 19
    );
    _movimentarCamera(cameraPosition);


  }

  _statusConfirmada(){

    if(_streamSubscriptionRequisicoes != null){

      _streamSubscriptionRequisicoes.cancel();

      _exibirCaixaEnderecoDestino = true;
      _alterarBotaoPrincipal("Chamar Uber",Color(0xff1ebbd8), (){
        _chamarUber();
      });

      _dadosRequisicao = {};

    }

  }


  //TODO: criar uma classe apenas para os marcadores depois
  _exibirMarcador(Position local,String icone,String infoWindow) async{

    Usuario usu = await USuarioFirebase.getDadosUsuarioLogado();

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        icone
    ).then((BitmapDescriptor bitmapDescriptor){

      Marker marcador = Marker(
          markerId: MarkerId(icone),
          position: LatLng(local.latitude,local.longitude),
          infoWindow: InfoWindow(
              title: usu.nome  //exibe o nome do usuario no icone
          ),
          icon:bitmapDescriptor

      );

      setState(() {
        _marcadores.add(marcador);
      });

    });



  }


  _exibirCentralizarDoisMarcadores(Marcador marcadorOrigem,Marcador marcadorDestino){

    double latitudeOrigem = marcadorOrigem.local.latitude;
    double longitudeOrigem = marcadorOrigem.local.longitude;

    double latitudeDestino = marcadorOrigem.local.latitude;
    double longitudeDestino = marcadorOrigem.local.longitude;

    //Exibir dois marcadores
    _exibirDoisMArcadores(marcadorOrigem,marcadorDestino);

    var nLat,nLong,sLat,sLong;

    if(latitudeOrigem <= latitudeDestino){
      sLat = latitudeOrigem;
      nLat = latitudeDestino;
    }else{

      sLat = latitudeDestino;
      nLat = latitudeOrigem;

    }


    if(longitudeOrigem <= longitudeDestino){
      sLong = longitudeOrigem;
      nLong = longitudeDestino;
    }else{

      sLong = longitudeDestino;
      nLong = longitudeOrigem;

    }

    _movimentarCameraBounds(LatLngBounds(
        northeast: LatLng(nLat,nLong), //nordeste
        southwest:LatLng(sLat,sLong) //sudoeste
    )
    );


  }



  //cria um quadrado entre os dois marcadores
  _movimentarCameraBounds(LatLngBounds latLngBounds)async{

    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(latLngBounds, 100) //100 eh o padding entre o marcador e o canto da tela
    );

  }


  //Metodo para exibir dois marcadores o de motorista e passageiro
  _exibirDoisMArcadores(Marcador marcadorOrigem,Marcador marcadorDestino)async{

    Set<Marker> _listaMarcadores = {};

    Usuario usu = await USuarioFirebase.getDadosUsuarioLogado();

    double pixelRatio = MediaQuery.of(context).devicePixelRatio;

    LatLng latLngOrigem = marcadorOrigem.local;
    LatLng latLngDestino = marcadorDestino.local;

    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        marcadorOrigem.caminhoImagem
    ).then((BitmapDescriptor icone){

      Marker mOrigem = Marker(
          markerId: MarkerId(marcadorOrigem.caminhoImagem),
          position: LatLng(latLngOrigem.latitude,latLngOrigem.longitude),
          infoWindow: InfoWindow(
              title: usu.nome  //exibe o nome do usuario no icone //TODO: colocar depois marcadorOrigem.titulo
          ),
          icon:icone

      );
      _listaMarcadores.add(mOrigem);


    });


    BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: pixelRatio),
        marcadorDestino.caminhoImagem
    ).then((BitmapDescriptor icone){

      Marker mDestino = Marker(
          markerId: MarkerId(marcadorDestino.caminhoImagem),
          position: LatLng(latLngDestino.latitude,latLngDestino.longitude),
          infoWindow: InfoWindow(
              title: usu.nome  //exibe o nome do usuario no icone //TODO: colocar depois marcadorDestino.titulo
          ),
          icon:icone

      );
      _listaMarcadores.add(mDestino);


    });

    setState(() {
      _marcadores = _listaMarcadores;

    });


  }


  //Metoto para cancelar a requisicao "pedido" do uber
  _cancelarUber() async{

    FirebaseUser firebaseUser = await USuarioFirebase.getUsuarioAtual();
     Firestore db = Firestore.instance;
     db.collection("requisicoes").document(_idRequisicao).updateData({
       "status":StatusRequisicao.CANCELADA
     }).then((_){
       db.collection("requisicao_ativa").document(firebaseUser.uid).delete();
     });

  }


  _recuperarRequisicaoAtiva()async{

    FirebaseUser firebaseUser = await USuarioFirebase.getUsuarioAtual();
    Firestore db = Firestore.instance;
   DocumentSnapshot documentSnapshot = await db.collection("requisicao_ativa").document(firebaseUser.uid).get();

   if(documentSnapshot.data != null){

     Map<String,dynamic> dados = documentSnapshot.data;
      _idRequisicao = dados["id_requisicao"];
     _adicionarListenerRequisicao(_idRequisicao);

   }else{
     _statusUberNaoChamado();
   }

  }


  _adicionarListenerRequisicao(String idRequisicao)async{

    Firestore db = Firestore.instance;
   _streamSubscriptionRequisicoes = await db.collection("requisicoes").document(idRequisicao).snapshots().listen((snapshot){

      if(snapshot.data != null){
        Map<String,dynamic> dados = snapshot.data;
        _dadosRequisicao = dados;
        String status = dados["status"];
        _idRequisicao = dados["id_requisicao"];

        switch(status){
          case StatusRequisicao.AGUARDANDO:
            _statusAguardando();
            break;
          case StatusRequisicao.A_CAMINHO:
            _statusACaminho();
            break;
          case StatusRequisicao.VIAGEM:
            _statusEmViagem();
            break;
          case StatusRequisicao.FINALIZADA:
            _statusFinalizada();
            break;
          case StatusRequisicao.CONFIRMADA:
            _statusConfirmada();
            break;
        }

      }


    });



  }


  @override
  void initState() {
    super.initState();



    //adicionar listener para requisicao ativa
    _recuperarRequisicaoAtiva();


    _recuperarUltimaLocalizacaoConhecida(); //estava comentado
    _adicionarListenerLocalizacao();



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Painel passageiro"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context){
              return itensMenu.map((String item) {

                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),
      drawer: MenuSidebar(),
      body: Container(

        child: Stack(
          children: <Widget>[
            GoogleMap( //TODO:alterar aqui depois
              mapType: MapType.normal,
              initialCameraPosition: _posicaoCamera,
              onMapCreated:_onMapCreated,
              //myLocationEnabled: true,
              myLocationButtonEnabled: false, //tira o botaozinho de centralizar minha localizacao
              markers: _marcadores,
            ),


           Visibility(
             visible: _exibirCaixaEnderecoDestino,
             child: Stack(
               children: <Widget>[
                 Positioned(
                   top: 0,
                   left: 0,
                   right: 0,
                   child: Padding(
                     padding: EdgeInsets.all(10),
                     child: Container(
                       height: 50,
                       width: double.infinity, //ocupa toda a largura possivel
                       decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey),
                           borderRadius: BorderRadius.circular(3),
                           color: Colors.white
                       ),
                       child: TextField(
                         readOnly: true, //o usuario nao vai conseguir clicar nesse textField
                         decoration: InputDecoration(
                             icon: Container( //margem do icone
                               margin: EdgeInsets.only(left: 20),
                               width: 10,
                               height: 25,
                               child: Icon(Icons.location_on,color: Colors.green,),
                             ),
                             hintText: "Meu local",
                             border: InputBorder.none, //tira a borda que fica embaixo da caixa de texto
                             contentPadding: EdgeInsets.only(left: 10,top: 5) //margem interna do texto

                         ),
                       ),
                     ),
                   ),
                 ),


                 Positioned(
                   top: 55,
                   left: 0,
                   right: 0,
                   child: Padding(
                     padding: EdgeInsets.all(10),
                     child: Container(
                       height: 50,
                       width: double.infinity, //ocupa toda a largura possivel
                       decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey),
                           borderRadius: BorderRadius.circular(3),
                           color: Colors.white
                       ),
                       child: TextField(
                         controller: _controllerDestino,
                         decoration: InputDecoration(
                             icon: Container( //margem do icone
                               margin: EdgeInsets.only(left: 20),
                               width: 10,
                               height: 25,
                               child: Icon(Icons.local_taxi,color: Colors.black,),
                             ),
                             hintText: "Digite o destino",
                             border: InputBorder.none, //tira a borda que fica embaixo da caixa de texto
                             contentPadding: EdgeInsets.only(left: 10,top: 5) //margem interna do texto

                         ),
                       ),
                     ),
                   ),
                 )
               ],
             ),

           ),


            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: Padding(
                padding: Platform.isIOS ? EdgeInsets.fromLTRB(20, 10, 20, 25) : EdgeInsets.all(10),
                child: RaisedButton(

                  child: Text(_textoBotao,style: TextStyle(color: Colors.white,fontSize: 20),),
                  color: _corBotao,
                  padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                  onPressed: _funcaoBotao,
                ),
              ),
            )
          ],
        ),

      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscriptionRequisicoes.cancel();
  }
}
