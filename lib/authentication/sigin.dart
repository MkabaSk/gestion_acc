import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'login.dart';



class Pageinscription extends StatefulWidget {
  const Pageinscription({super.key});

  @override
  State<Pageinscription> createState() => _PageinscriptionState();
}
// TODO: Puis on crée notre page d'inscription



class _PageinscriptionState extends State<Pageinscription> {
  TextEditingController firstNameTextEditingController = TextEditingController();
  TextEditingController lastNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController passwordConfirmTextEditingController = TextEditingController();
  XFile? imageFile;
  String urlOfUploadedImage = "";




  // Vérifier si une image a été choisie
  void checkIfNetworkIsAvailable() {
    if (imageFile != null) {
      signUpFormValidation();
    } else {
      Get.snackbar(
        "Erreur",
        "Choisissez une photo.",
        backgroundColor: Colors.yellow,
      );
    }
  }


  // Validation du formulaire d'inscription
  void signUpFormValidation() async {
    if (firstNameTextEditingController.text.trim().length < 4) {
      Get.snackbar(
        "Erreur",
        "Votre nom doit comporter au moins 4 caractères.",
        backgroundColor: Colors.yellow,
      );
    }
    else if (lastNameTextEditingController.text.trim().length < 2) {
      Get.snackbar(
        "Erreur",
        "Donnez votre vrai nom de famille.",
        backgroundColor: Colors.yellow,
      );
    }
    else if (!emailTextEditingController.text.contains("@")) {
      Get.snackbar(
        "Erreur",
        "Veuillez fournir une adresse e-mail valide.",
        backgroundColor: Colors.yellow,
      );
    }
    else if (passwordTextEditingController.text.trim().length < 6) {
      Get.snackbar(
        "Erreur",
        "Votre mot de passe doit comporter au moins 6 caractères.",
        backgroundColor: Colors.yellow,
      );
    }

    else if (passwordConfirmTextEditingController.text != passwordTextEditingController.text) {
      Get.snackbar(
        "Erreur",
        "Votre mot de passe ne correspond pas.",
        backgroundColor: Colors.yellow,
      );
    }


    else {
      // Vérifier si l'adresse e-mail existe déjà
      List<String> methods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(emailTextEditingController.text.trim());
      if (methods.isNotEmpty) {
        // L'adresse e-mail existe déjà
        Get.snackbar(
          "Erreur",
          "Cette adresse e-mail est déjà associée à un compte.",
          backgroundColor: Colors.yellow,
        );
      } else {
        // L'adresse e-mail n'existe pas encore, continuer avec l'inscription
        uploadImageToStorage();
      }
    }
  }


  // Télécharger l'image vers Firebase Storage
  Future<void> uploadImageToStorage() async {
    try {
      String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);
      UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
      TaskSnapshot snapshot = await uploadTask;
      urlOfUploadedImage = await snapshot.ref.getDownloadURL();
      registerNewUser();
    } catch (error) {
      Get.snackbar(
        "Erreur",
        error.toString(),
        backgroundColor: Colors.yellow,
      );
    }
  }



  // Enregistrer le nouvel utilisateur dans Firebase Authentication et Real-time Database
  void registerNewUser() async {
    Get.dialog(
      const AlertDialog(
        backgroundColor: Colors.yellow,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 4,
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Text("Création..."),
          ],
        ),
      ),
    );

    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );

      DatabaseReference usersRef = FirebaseDatabase.instance.reference().child("users").child(userCredential.user!.uid);

      Map<String, dynamic> userDataMap = {
        "photo": urlOfUploadedImage,
        "firstName": firstNameTextEditingController.text.trim(),
        "lastName": lastNameTextEditingController.text.trim(),
        "email": emailTextEditingController.text.trim(),
        "id": userCredential.user!.uid,
      };
      await usersRef.set(userDataMap);

      // Inscription réussie, naviguer vers la page appropriée
      Get.off(
          Pageconnexion()); // Assurez-vous d'importer la classe BottomNavigation
      // Afficher le SnackBar pour informer l'utilisateur
      Get.snackbar(
        "Succès",
        "Inscription réussie!",
        backgroundColor: Colors.green,
      );
    } catch (error) {
      Get.snackbar(
        "Erreur",
        error.toString(),
        backgroundColor: Colors.yellow,
      );
    } finally {
      Get.back();
    }
  }


  // Choisir une image depuis la galerie
  chooseImageFromGallery() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
      });
    }
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(height: 80),
              Center(
                child: Text(
                  "INSCRIPTION",
                  style: TextStyle(
                    color: Colors.yellow.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),


              const SizedBox(height: 40),
              // Afficher l'image sélectionnée ou une image par défaut si aucune image n'a été sélectionnée
              imageFile == null
                  ? const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/OMEN_Tori.jpg"),
              )
                  : Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: FileImage(
                      File(
                        imageFile!.path,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  chooseImageFromGallery();
                },
                child: Text(
                  "Votre photo",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    // Champs de texte pour le prénom
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: TextField(
                        autofocus: true,
                        controller: firstNameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.yellow,
                          ),
                          fillColor: Colors.yellow,
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.yellow,
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Prenom',
                          labelStyle: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Champs de texte pour le nom de famille
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: TextField(
                        controller: lastNameTextEditingController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.yellow,
                          ),
                          fillColor: Colors.yellow,
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.yellow,
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Nom',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 18),
                    // Champs de texte pour l'adresse e-mail
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: TextField(
                        controller: emailTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          hintStyle: TextStyle(color: Colors.yellow),
                          fillColor: Colors.yellow,
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.yellow,
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Addresse mail',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: 18),

                    // Champs de texte pour le mot de passe
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: TextField(
                        controller: passwordTextEditingController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          hintStyle: TextStyle(color: Colors.yellow),
                          fillColor: Colors.yellow,
                          prefixIcon: Icon(
                            Icons.password,
                            color: Colors.yellow,
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Mot de passe',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    SizedBox(height: 18),

                    // Champs de texte pour la confirmation du mot de passe
                    Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: TextField(
                        controller: passwordConfirmTextEditingController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: Colors.yellow),
                          ),
                          hintStyle: TextStyle(color: Colors.yellow),
                          fillColor: Colors.yellow,
                          prefixIcon: Icon(
                            Icons.password,
                            color: Colors.yellow,
                          ),
                          border: OutlineInputBorder(),
                          hintText: 'Confimer mot de passe',
                          labelStyle: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    SizedBox(height: 22),

                    // Bouton d'inscription
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable(); // Utiliser cette méthode pour la validation complète
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow.withOpacity(0.9),
                        padding:
                        EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                      ),
                      child: Text(
                        "Inscription",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton de navigation vers la page de connexion
              TextButton(
                onPressed: () {
                  Get.off(Pageconnexion());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Vous avez un Compte? ",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      "Connexion",
                      style: TextStyle(
                        color: Colors.yellow,
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
