import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../authentication/login.dart';
import '../authentication/sigin.dart';


class Pageaccueil extends StatefulWidget {
  const Pageaccueil({super.key});

  @override
  State<Pageaccueil> createState() => _PageaccueilState();
}
// TODO: On crée d'abord notre page d'accueil

class _PageaccueilState extends State<Pageaccueil> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.only(top: 150.0, left: 50, right: 50),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Bienvenue",
                        style: TextStyle(
                            color: Colors.yellow.withOpacity(0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 30
                        ),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 50,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 260,
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFFcad87c),
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      width: 100,
                      height: 100,
                      "assets/images/splash.jpeg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40,),
              Container(
                width: 280,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.yellow
                ),
                child: MaterialButton(
                  onPressed: () {
                    //loginUser(context);
                    Get.off(() => Pageinscription());
                  },
                  child: const SizedBox(
                    child: Text(
                      'INSCRIPTION',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              Container(
                width: 280,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.yellow
                ),
                child: MaterialButton(
                  onPressed: () {
                    //loginUser(context);
                    Get.off(() => Pageconnexion());
                  },
                  child: const SizedBox(
                    child: Text(
                      'CONNEXION',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }
}
