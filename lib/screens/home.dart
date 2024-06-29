import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gestion_acc/Models/accident.dart';
import 'package:gestion_acc/screens/splash_scree.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import '../global/variables_global.dart';
import 'details.dart';




class Accueil extends StatefulWidget {
  const Accueil({super.key});


  @override
  State<Accueil> createState() => _AccueilState();
}



// TODO: ON crée notre Home Page qui va contenir notre éléments
class _AccueilState extends State<Accueil> {
  final _formKeyTask = GlobalKey<FormBuilderState>();
  final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

  /// Liste des taches
  final List<Accident> accidents = [];


  final DatabaseReference data = FirebaseDatabase.instance.ref().child("accidents");




  /// Méthode pour ajouter un accident à la base
  void addAccidentToDatabase(String titreAccident, String descriptionAccident, String startDate) {
    try {
      /// Générez une nouvelle clé pour l'accident
      String? accidentId = databaseReference.child('accidents').push().key;

      /// Map pour stocker les informations de la tâche
      Map<String, dynamic> accidentData = {
        'titre': titreAccident,
        'description': descriptionAccident,
        'startDate': startDate,
      };

      // Ajout de la tâche à la base de données en utilisant sa clé
      databaseReference.child('accidents').child(accidentId!).set(accidentData);

      // Afficher un message ou effectuer d'autres actions si nécessaire
      Get.snackbar(
        "Succès",
        "L'accident a été ajouté à la base de données avec succès.",
        backgroundColor: Colors.yellow,
        messageText:
        Text("L'accident a été ajoutée à la base de données avec succès.'"),
      );
    }
    catch (e) {
      // Message d'erreurs si l'ajout de tâche échoue
      Get.snackbar("Erreur", 'Erreur lors de l\'ajout de l\'accident : $e');
    }
  }



  /// La méthode pour récupérer les information de l'utilisateur connecter
  Future<void> getUserInfo() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
    await usersRef
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once()
        .then((snap) {
      final data = snap.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          userFirstName = (data["firstName"] ?? '').toString();
          userLastName = (data["lastName"] ?? '').toString();
          userMail = (data["email"] ?? '').toString();
          userPhoto = (data["photo"] ?? '').toString();
        });
      }
    }).catchError((error) {
      print("Failed to get user info: $error");
    });
  }


  /// Méthode pour ajouter un accident quand on clique sur le button Ajouter
  void addAccident() {
    if (_formKeyTask.currentState != null &&
        _formKeyTask.currentState!.validate()) {
      var formFields = _formKeyTask.currentState!.fields;
      String titre = formFields['titre']!.value as String;
      String description = formFields['description']!.value as String;
      DateTime startDate = formFields['startDate']!.value as DateTime;
      // Convertir les dates en chaînes de caractères
      String startDateString = startDate.toString();
      addAccidentToDatabase(
          titre, description, startDateString);
      _formKeyTask.currentState!.reset();
    }
  }




  /// Méthode pour supprimer un accident de la base
  void deleteTaskFromDatabase(String accidentId) {
    DatabaseReference accidentRef = FirebaseDatabase.instance.reference().child('accidents');
    accidentRef.child(accidentId).remove().then((_) {
      print('accident deleted successfully from database');
      Get.snackbar(
        "Success",
        "L'accident à été supprimer avec succès",
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    }).catchError((error) {
      print('Error deleting accident: $error');
      Get.snackbar(
        "Error",
        "Erreur lors de la suppression de l'accident",
        backgroundColor: Colors.yellow,
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
      );
    });
  }




  getUserInfoAndCheckBlockStatus() async
  {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        setState(() {
          userFirstName = (snap.snapshot.value as Map)["firstName"];
          userPhone = (snap.snapshot.value as Map)["lastName"];
          userMail = (snap.snapshot.value as Map)["email"];
        });
      }
   /*   else
      {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }*/
    });
  }




  /// Méthode pour recuperer les données dans la base
  Future<void> getData() async {
    final DatabaseReference data = FirebaseDatabase.instance.ref().child("accidents");

    await data.get().then((DataSnapshot snapshot) {
      if (snapshot.value != null && snapshot.value is Map) {
        Map<dynamic, dynamic>? accidentsData = snapshot.value as Map<dynamic, dynamic>?;

        if (accidentsData != null) {
          accidents.clear(); // Efface la liste des tâches existantes avant de la remplir avec les nouvelles données

          accidentsData.forEach((key, value) {
            // Crée une nouvelle tâche et l'ajoute à la liste
            Accident accident = Accident.fromMap(value, key);
            accidents.add(accident);
          });

          // Rafraîchit l'interface utilisateur après avoir ajouté toutes les tâches à la liste
          // (ceci déclenchera la reconstruction de la ListView avec les nouvelles données)
          // Si cela ne fonctionne pas correctement, tu peux appeler setState(() {}) ici
        }
      } else {
        print("Aucune donnée disponible.");
      }
    }).catchError((error) {
      print("Erreur lors de la récupération des données: $error");
    });
  }


  ///Méthode pour faire la mise à jours
  Future<void> upgrade() async {
    // Appelle la méthode getData() pour mettre à jour les données
    await getData();

    // Rafraîchit l'interface utilisateur après avoir récupéré les données
    setState(() {}); // Assure-toi que cette méthode setState est accessible dans ton widget
  }



  @override
  void initState() {
    super.initState();
    getData();
    getUserInfo();

    print(userMail);
    print("User image ${userPhoto}");
    print(userFirstName + userLastName);

  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1f1f1f),

      appBar: AppBar(

        backgroundColor: Colors.yellow,
        centerTitle: true,
        title: Text(
            "Gestion accident"
        ),
      ),

      drawer: Container(
        width: 255,
        color: Colors.yellow,
        child: Drawer(
          backgroundColor: Colors.yellow,
          child: ListView(
            children: [

              Divider(
                height: 1,
                color: Colors.yellow.withOpacity(0.3),
                thickness: 1,
              ),

              //header
              Container(
                color: Colors.black54,
                height: 170,
                child: DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          /// Photo de l'utilisateurs
                          Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100)
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  userPhoto,
                                ),
                              )
                          ),


                          const SizedBox(width: 80,),

                          Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100)
                              ),
                              child: const CircleAvatar(
                                backgroundImage: AssetImage( "assets/images/OMEN_Tori.jpg",),
                              )
                          ),
                        ],
                      ),

                      const SizedBox(height: 10,),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              maxLines: 1,
                              "Nom: ${userFirstName +" "+ userLastName}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4,),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              maxLines: 1,
                              "Email: ${userMail}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Divider(
                height: 1,
                color: Colors.yellow.withOpacity(0.2),
                thickness: 1,
              ),

              const SizedBox(height: 10,),

              //body
              GestureDetector(
                onTap: ()
                {
                  //Get.to(() => ProfilePage());
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {

                    },
                    icon:  Icon(CupertinoIcons.person_alt_circle, color: Colors.black,),
                  ),
                  title: const Text("Profile", style: TextStyle(color: Colors.black),),
                  trailing: Icon(Icons.navigate_next),
                ),
              ),

              Divider(
                height: 1,
                color: Colors.black.withOpacity(0.2),
                thickness: 1,
              ),

              GestureDetector(
                onTap: ()
                {
                  //Navigator.push(context, MaterialPageRoute(builder: (c)=> AboutPage()));
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.info, color: Colors.black,),
                  ),
                  title: const Text("A propos", style: TextStyle(color: Colors.black),),
                  trailing: Icon(Icons.navigate_next),
                ),
              ),


              const Divider(
                height: 1,
                color: Colors.black,
                thickness: 1,
              ),


              GestureDetector(
                onTap: ()
                {
                  FirebaseAuth.instance.signOut();
                  Get.off(() => Pageaccueil());
                },
                child: ListTile(
                  leading: IconButton(
                    onPressed: (){

                    },
                    icon: const Icon(Icons.logout, color: Colors.black,),
                  ),
                  title: const Text("Déconnexion", style: TextStyle(color: Colors.pink
                  ),),
                ),
              ),

            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        elevation: 5,

        backgroundColor: Colors.yellow,
        onPressed: (){
          /// Ajouter un accident
          /// on va revoir cet widget quand on a la connexion
          Get.bottomSheet(
            SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.yellow,
                  borderRadius:
                  BorderRadius.only(
                    topRight:
                    Radius.circular(20),
                    topLeft:
                    Radius.circular(20),
                  ),
                ),
                height: MediaQuery.of(context).size.height - 10.0,
                width: double.infinity,
                child: Padding(
                  padding:
                  const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const ListTile(
                        title: Center(
                          child: Text(
                            "Ajout d'un accident",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                        ),
                      ),
                      FormBuilder(
                        key: _formKeyTask,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            const Text(
                              "Titre de l'accident",
                              style: TextStyle(
                                color: Colors
                                    .black,
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            FormBuilderTextField(
                              name: 'titre',
                              decoration:
                              const InputDecoration(
                                hintText:
                                "Entrer un titre",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                enabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 1
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              "Description",
                              style: TextStyle(
                                color: Colors
                                    .black,
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            FormBuilderTextField(
                              name:
                              'description',
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText:
                                'détails ou description ',
                                border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                                  borderSide: BorderSide(
                                    color: Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                enabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors
                                          .black,
                                      width: 1),
                                ),
                                focusedBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors
                                          .black,
                                      width: 1),
                                ),
                              ),
                            ),
                            const  SizedBox(
                                height: 20),
                            const Text(
                              "Date",
                              style: TextStyle(
                                color: Colors
                                    .black,
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            FormBuilderDateTimePicker(
                              name: 'startDate',
                              inputType:
                              InputType
                                  .date,
                              decoration:
                              const InputDecoration(
                                hintText:
                                'Selectionner une date',
                                border:
                                OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(
                                      Radius.circular(
                                          20)),
                                  borderSide:
                                  BorderSide(
                                    color: Colors
                                        .black,
                                    style: BorderStyle
                                        .solid,
                                  ),
                                ),
                                enabledBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors
                                          .black,
                                      width: 1),
                                ),
                                focusedBorder:
                                OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors
                                          .black,
                                      width: 1),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height: 20),


                            // Bouton de création de tâche
                            Center(
                              child: Container(
                                width: 250,
                                height: 55,
                                child:
                                FloatingActionButton(
                                  elevation: 5,
                                  shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(60)),
                                  backgroundColor: Colors.black,
                                  onPressed: () {
                                    addAccident();
                                    Get.snackbar(
                                      "Success",
                                      "Accident ajouter avec succès",
                                      backgroundColor: Colors
                                          .yellow
                                          .withOpacity(
                                          0.8),
                                      colorText:
                                      Colors
                                          .black,
                                      snackPosition:
                                      SnackPosition
                                          .TOP,
                                    );
                                    Get.to(() => Accueil());
                                    setState(() {
                                    });
                                    Get.back();
                                  },
                                  child: const Text(
                                    "Ajouter",
                                    style:
                                    TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                      15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,

        ),
      ),
      body: Container(
        height: double.infinity,
        width: MediaQuery.of(context).size.width,
        child: RefreshIndicator(
          color: Colors.black,
          backgroundColor: Colors.yellow,
          onRefresh: upgrade,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                const SizedBox(height: 50),

                /// Widget qui contient nos taches
                Stack(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: accidents.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.black,
                                      Colors.black54,
                                    ],
                                  ),
                              ),
                              child: Column(
                                children: [
                                  GFListTile(
                                    title:   Text(
                                      accidents[index].titre,
                                      style: const TextStyle(
                                          color: Colors.yellow,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subTitle:   Text(
                                      maxLines: 3,
                                      accidents[index].description,
                                      style: const TextStyle(
                                          color: Colors.yellow,
                                        overflow: TextOverflow.ellipsis
                                      ),
                                    ),
                                  ),

                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 35.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            accidents[index].startDate,
                                            style: const TextStyle(
                                                color: Colors.yellow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 35.0, top: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                     Text(
                                          "Voir plus",
                                          style: TextStyle(
                                              color: Colors.yellow
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: (){
                                              //Get.to(() =>  Pagedetail(accident: accidents[index]));
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => Pagedetail(accident: accidents[index])));
                                            },
                                            icon: const Icon(
                                              Icons.arrow_forward_ios_outlined
                                            ),
                                        )
                                      ],
                                    ),
                                  )
                                  
                                ],
                              )
                            ),
                          ),
                        );
                      },
                    ),
                    // Indicateur de progression
                    accidents.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                          backgroundColor: Colors.yellow,
                        ),
                      ),
                    )
                        : SizedBox(), // S'il n'y a pas de chargement, afficher un SizedBox()
                  ],
                ),



                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );

      /*FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              /// Afficher un indicateur de chargement
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                  color: Colors.yellow,
                )
            );
          } else if (snapshot.hasError) {
            /// Afficher le snackbar de manière asynchrone en utilisant Get.snackbar()
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              Get.snackbar(
                  backgroundColor: Colors.yellow,
                  messageText: const Text("Erreur de chargement des données"),
                  colorText: Colors.black,
                  "Erreur", "Erreur de chargement des données"
              );
            });
            return Container();
          }
          else {
            return Scaffold(
              backgroundColor: const Color(0xFF1f1f1f),

              appBar: AppBar(

                backgroundColor: Colors.yellow,
                centerTitle: true,
                title: Text(
                    "Gestion accident"
                ),
              ),

              drawer: Container(
                width: 255,
                color: Colors.yellow,
                child: Drawer(
                  backgroundColor: Colors.yellow,
                  child: ListView(
                    children: [

                      Divider(
                        height: 1,
                        color: Colors.yellow.withOpacity(0.3),
                        thickness: 1,
                      ),

                      //header
                      Container(
                        color: Colors.black54,
                        height: 170,
                        child: DrawerHeader(
                          decoration: const BoxDecoration(
                            color: Colors.white10,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  /// Photo de l'utilisateurs
                                  Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100)
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: AssetImage(
                                          "assets/images/OMEN_Tori.jpg",
                                        ),
                                      )
                                  ),


                                  const SizedBox(width: 80,),

                                  Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(100)
                                      ),
                                      child: const CircleAvatar(
                                        backgroundImage: AssetImage( "assets/images/OMEN_Tori.jpg",),
                                      )
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10,),

                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Nom: ${userName}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Email: ${userMail}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Divider(
                        height: 1,
                        color: Colors.yellow.withOpacity(0.2),
                        thickness: 1,
                      ),

                      const SizedBox(height: 10,),

                      //body
                      GestureDetector(
                        onTap: ()
                        {
                          //Get.to(() => ProfilePage());
                        },
                        child: ListTile(
                          leading: IconButton(
                            onPressed: () {

                            },
                            icon:  Icon(CupertinoIcons.person_alt_circle, color: Colors.black,),
                          ),
                          title: const Text("Profile", style: TextStyle(color: Colors.black),),
                          trailing: Icon(Icons.navigate_next),
                        ),
                      ),

                      Divider(
                        height: 1,
                        color: Colors.black.withOpacity(0.2),
                        thickness: 1,
                      ),

                      GestureDetector(
                        onTap: ()
                        {
                          //Navigator.push(context, MaterialPageRoute(builder: (c)=> AboutPage()));
                        },
                        child: ListTile(
                          leading: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.info, color: Colors.black,),
                          ),
                          title: const Text("A propos", style: TextStyle(color: Colors.black),),
                          trailing: Icon(Icons.navigate_next),
                        ),
                      ),


                      const Divider(
                        height: 1,
                        color: Colors.black,
                        thickness: 1,
                      ),


                      GestureDetector(
                        onTap: ()
                        {
                          FirebaseAuth.instance.signOut();
                          Get.off(() => Pageaccueil());
                        },
                        child: ListTile(
                          leading: IconButton(
                            onPressed: (){

                            },
                            icon: const Icon(Icons.logout, color: Colors.black,),
                          ),
                          title: const Text("Déconnexion", style: TextStyle(color: Colors.pink
                          ),),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.yellow,
                onPressed: (){
                  /// Ajouter un accident
                  /// on va revoir cet widget quand on a la connexion
                  Get.bottomSheet(
                    SingleChildScrollView(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                          borderRadius:
                          BorderRadius.only(
                            topRight:
                            Radius.circular(20),
                            topLeft:
                            Radius.circular(20),
                          ),
                        ),
                        height: MediaQuery.of(context).size.height - 10.0,
                        width: double.infinity,
                        child: Padding(
                          padding:
                          const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const ListTile(
                                title: Center(
                                  child: Text(
                                    "Ajout d'un accident",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 23,
                                    ),
                                  ),
                                ),
                              ),
                              FormBuilder(
                                key: _formKeyTask,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    const Text(
                                      "Titre de l'accident",
                                      style: TextStyle(
                                        color: Colors
                                            .black,
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    FormBuilderTextField(
                                      name: 'titre',
                                      decoration:
                                      const InputDecoration(
                                        hintText:
                                        "Entrer un titre",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        enabledBorder:
                                        OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black,
                                              width: 1
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black,
                                              width: 1
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    const Text(
                                      "Description",
                                      style: TextStyle(
                                        color: Colors
                                            .black,
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    FormBuilderTextField(
                                      name:
                                      'description',
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        hintText:
                                        'détails ou description ',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                          borderSide: BorderSide(
                                            color: Colors.black,
                                            style: BorderStyle.solid,
                                          ),
                                        ),
                                        enabledBorder:
                                        OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .black,
                                              width: 1),
                                        ),
                                        focusedBorder:
                                        OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .black,
                                              width: 1),
                                        ),
                                      ),
                                    ),
                                    const  SizedBox(
                                        height: 20),
                                    const Text(
                                      "Date",
                                      style: TextStyle(
                                        color: Colors
                                            .black,
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    FormBuilderDateTimePicker(
                                      name: 'startDate',
                                      inputType:
                                      InputType
                                          .date,
                                      decoration:
                                      const InputDecoration(
                                        hintText:
                                        'Selectionner une date',
                                        border:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  20)),
                                          borderSide:
                                          BorderSide(
                                            color: Colors
                                                .black,
                                            style: BorderStyle
                                                .solid,
                                          ),
                                        ),
                                        enabledBorder:
                                        OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .black,
                                              width: 1),
                                        ),
                                        focusedBorder:
                                        OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .black,
                                              width: 1),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height: 20),
                                    const Text(
                                      "Heure",
                                      style: TextStyle(
                                        color: Colors
                                            .black,
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight
                                            .bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    FormBuilderDateTimePicker(
                                      name: 'heure',
                                      inputType:
                                      InputType
                                          .date,
                                      decoration:
                                      const InputDecoration(
                                        hintText:
                                        "Donner l'heure",
                                        border:
                                        OutlineInputBorder(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  20)),
                                          borderSide:
                                          BorderSide(
                                            color: Colors
                                                .black,
                                            style: BorderStyle
                                                .solid,
                                          ),
                                        ),
                                        enabledBorder:
                                        OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .black,
                                              width: 1),
                                        ),
                                        focusedBorder:
                                        OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors
                                                  .black,
                                              width: 1),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // Bouton de création de tâche
                                    Center(
                                      child: Container(
                                        width: 250,
                                        height: 55,
                                        child:
                                        FloatingActionButton(
                                          elevation: 5,
                                          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(60)),
                                          backgroundColor: Colors.black,
                                          onPressed: () {
                                            addAccident();
                                            Get.snackbar(
                                              "Success",
                                              "Accident ajouter avec succès",
                                              backgroundColor: Colors
                                                  .yellow
                                                  .withOpacity(
                                                  0.8),
                                              colorText:
                                              Colors
                                                  .black,
                                              snackPosition:
                                              SnackPosition
                                                  .TOP,
                                            );
                                            setState(() {
                                            });
                                            Get.back();
                                          },
                                          child: const Text(
                                            "Ajouter",
                                            style:
                                            TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                              15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.add,
                  color: Colors.black,

                ),
              ),
              body: Container(
                height: double.infinity,
                width: MediaQuery.of(context).size.width,
                child: RefreshIndicator(
                  color: Colors.black,
                  backgroundColor: Colors.yellow,
                  onRefresh: upgrade,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),

                        /// Widget qui contient nos taches
                        Stack(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: accidents.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Container(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.black
                                      ),
                                      child: ListTile(
                                        leading: Text(
                                          accidents[index].titre,
                                        ),
                                        subtitle: Text(
                                          accidents[index].description,
                                        ),

                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Indicateur de progression
                            accidents.isEmpty
                                ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                  backgroundColor: Colors.yellow,
                                ),
                              ),
                            )
                                : SizedBox(), // S'il n'y a pas de chargement, afficher un SizedBox()
                          ],
                        ),



                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                      ],
                    ),
                  ),
                ),
              ),
            );


          }
        }

        );*/




  }
}
