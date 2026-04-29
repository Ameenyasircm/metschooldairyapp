
import 'package:flutter/material.dart';
import 'package:met_school/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Update extends StatefulWidget {
  String text;
  String button;
  String ADDRESS;
  Update({Key? key,required this.text,required this.button,required this.ADDRESS}) : super(key: key);

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      AuthProvider authPro= Provider.of<AuthProvider>(context, listen: false);
      authPro.getAppVersion();
      authPro.lockAppUpdateScreen();
    });
  }


  @override
  Widget build(BuildContext context) {
    AuthProvider authPro= Provider.of<AuthProvider>(context, listen: false);
    authPro.lockAppUpdateScreen();
    return  WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 40),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/SchoolLogoNewPng.png",
                  ),
                  scale: 1,
                  fit: BoxFit.fitHeight,
                ),
              ),

            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(widget.text,style: TextStyle(
                  fontFamily: 'PoppinsMedium',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color:Colors.black
              ),),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: InkWell(
                splashColor: Colors.white,
                onTap: (){
                  _launchURL(widget.ADDRESS);
                },
                child: Container(
                  height: 40,
                  width: 150,

                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [
                            // cl1177BB,cl323A71
                            Colors.white,   Color(0xFF0191D7),
                          ]
                      ),
                      borderRadius: BorderRadius.circular(30)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10,),
                          child: Text(widget.button,style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                            color: Colors.black,
                          ),),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/codematesLogo.png",scale:10),
            ],
          ),
        ),


      ),
    );

  }

  void _launchURL(String _url) async {
    if (!await launch(_url)) throw 'Could not launch $_url';
  }
}
