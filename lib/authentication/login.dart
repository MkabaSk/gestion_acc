import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gestion_acc/authentication/sigin.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../screens/home.dart';


class Pageconnexion extends StatefulWidget {
  const Pageconnexion({super.key});

  @override
  State<Pageconnexion> createState() => _PageconnexionState();
}

// TODO: Puis on crée notre page de connexion

class _PageconnexionState extends State<Pageconnexion> {
  final _formKeyLo = GlobalKey<FormBuilderState>();




  void loginUser(BuildContext context) async {
    if (_formKeyLo.currentState!.validate()) {
      _formKeyLo.currentState!.save();

      // Affichage d'une boîte de dialogue de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.yellow,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                strokeWidth: 4,
                color: Colors.black,
              ),
              SizedBox(height: 16),
              Text("Connexion"),
            ],
          ),
        ),
      );

      try {
        // Tentative de connexion
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _formKeyLo.currentState!.value['email'],
          password: _formKeyLo.currentState!.value['password'],
        );

        // Fermeture de la boîte de dialogue
        Navigator.of(context).pop();

        // Naviguer vers la page d'accueil après la connexion réussie
        Get.off(() => Accueil());

      } on FirebaseAuthException catch (e) {
        // Fermeture de la boîte de dialogue en cas d'erreur
        Navigator.of(context).pop();

        String errorMessage;
        switch (e.code) {
          case 'wrong-password':
            errorMessage = "Mot de passe incorrect. Veuillez réessayer.";
            break;
          case 'user-not-found':
            errorMessage = "Aucun utilisateur trouvé avec cette adresse email.";
            break;
          case 'invalid-email':
            errorMessage = "L'adresse email est mal formée.";
            break;
          case 'too-many-requests':
            errorMessage = "Trop de tentatives de connexion infructueuses. Veuillez réessayer plus tard.";
            break;
          case 'network-request-failed':
            errorMessage = "Vérifiez votre connexion Internet et réessayez.";
            break;
          default:
            errorMessage = "Une erreur est survenue. Veuillez réessayer.";
        }

        Get.snackbar(
          "Erreur de connexion",
          errorMessage,
          icon: const Icon(
            Icons.error,
            color: Colors.red,
            size: 25,
          ),
          colorText: Colors.red,
          backgroundColor: Colors.yellow,
          isDismissible: true,
          messageText: Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        );
      } catch (e) {
        // Fermeture de la boîte de dialogue pour toute autre erreur
        Navigator.of(context).pop();

        Get.snackbar(
          "Erreur de connexion",
          "Une erreur est survenue. Veuillez réessayer.",
          icon: const Icon(
            Icons.error,
            color: Colors.red,
            size: 25,
          ),
          colorText: Colors.red,
          backgroundColor: Colors.yellow,
          isDismissible: true,
          messageText: Text(
            "Une erreur est survenue. Veuillez réessayer.",
            style: const TextStyle(color: Colors.red),
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1f1f1f),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: 100.0,),

              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "CONNEXION",
                      style: TextStyle(
                          color: Colors.yellow.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    )
                  ],
                ),
              ),

              SizedBox(height: 30.0,),

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
                  "assets/images/inscripiton.jpeg",
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 20.0,),

              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 30),
                  child: FormBuilder(
                    key: _formKeyLo,
                    child: Column(
                      children: [
                        FormBuilderTextField(
                          style: const TextStyle(color: Colors.yellow),
                          autofocus: true,
                          cursorColor: Colors.yellow,
                          name: 'email',
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(
                                color: Colors.yellow
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              size: 24,
                              color: Colors.yellow,
                            ),
                            hintText: 'Addresse mail',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.yellow, width: 1),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        FormBuilderTextField(
                          obscureText: true,
                          style: const TextStyle(color: Colors.yellow),
                          autofocus: true,
                          cursorColor: Colors.yellow,
                          name: 'password',
                          decoration: const InputDecoration(
                            hintStyle: TextStyle(color: Colors.yellow),
                            prefixIcon: Icon(
                              Icons.password,
                              size: 24,
                              color: Colors.yellow,
                            ),
                            hintText: 'Mot de passe',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.yellow, width: 1),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        Container(
                          width: 280,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.yellow
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              loginUser(context);
                              //Get.off(() => Accueil());
                            },
                            child: const SizedBox(
                              child: Text(
                                'Connexion',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30,),

              // TextButton pour l'inscription
              TextButton(
                onPressed: () {
                  Get.off(() => Pageinscription());
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous n'avez pas un Compte? ",
                      style: TextStyle(
                        color:  Colors.grey,
                      ),
                    ),
                    Text(
                      "Inscription",
                      style: TextStyle(
                        color:  Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
