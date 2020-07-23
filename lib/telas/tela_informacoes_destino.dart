import 'package:flutter/material.dart';

class TelaDestino extends StatefulWidget {
  @override
  _TelaDestinoState createState() => _TelaDestinoState();
}

class _TelaDestinoState extends State<TelaDestino> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          centerTitle: true,
          title:Text("ENDEREÇO DE DESTINO"),
        ),
        body: Container(
          child: Column(

            children: <Widget>[

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                Container(
                  padding: EdgeInsets.only(top: 20.0),
                  width: 250.0,
                  height: 90.0,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10.0),
                      hintText: "Rua",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(6)),
                    ),
                    style: new TextStyle(
                        fontSize: 15.0, height: 2.0, color: Colors.black),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20.0),
                  width: 100.0,
                  height: 90.0,
                  child: new TextFormField(
                    decoration: new InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10.0),
                      hintText: "N°",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(6)),
                    ),
                    style: new TextStyle(
                        fontSize: 15.0, height: 2.0, color: Colors.black),
                    keyboardType: TextInputType.number,
                  ),
                )



              ],


            ),

              Row(

                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  Container(

                    width: 180.0,
                    height: 90.0,
                    child: new TextFormField(
                      decoration: new InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10.0),
                        hintText: "Cidade",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(6)),
                      ),
                      style: new TextStyle(
                          fontSize: 15.0, height: 2.0, color: Colors.black),
                    ),
                  ),
                  Container(

                    width: 180.0,
                    height: 90.0,
                    child: new TextFormField(
                      decoration: new InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10.0,bottom: 3.0),
                        hintText: "Bairro",
                        fillColor: Colors.white,
                        border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(6)),
                      ),
                      style: new TextStyle(
                          fontSize: 15.0, height: 2.0, color: Colors.black),

                    ),
                  )



                ],

              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: <Widget>[

                  Container(

                    width: 180.0,
                    height: 50.0,
                    child: RaisedButton(

                      child: Text("Ver no mapa",style: TextStyle(fontSize: 20,color: Colors.grey),),
                      color: Colors.white,
                      elevation: 4.0,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                      onPressed: (){

                      },

                    ),

                  ),

                  Container(
                    width: 180.0,
                    height: 50.0,
                    child: RaisedButton(

                      child: Text("Não informar",style: TextStyle(fontSize: 20,color: Colors.white),),
                      color: Colors.grey,
                      elevation: 4.0,
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                      onPressed: (){

                      },

                    ),


                  ),




                ],


              ),





            ],


          )
        ));
  }
}
