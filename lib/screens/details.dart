import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gestion_acc/Models/accident.dart';
import 'package:gestion_acc/screens/home.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:intl/intl.dart';


class Pagedetail extends StatefulWidget {
  late  Accident accident;

   Pagedetail({Key? key, required this.accident}) : super(key: key);

  @override
  State<Pagedetail> createState() => _PagedetailState();
}

class _PagedetailState extends State<Pagedetail> {
  final _formKeyAccidentEdit = GlobalKey<FormBuilderState>();




  /// Fonction pour convertir une chaîne de date au format "jj/mm/aaaa" en objet DateTime
  DateTime? parseDateString(String dateString) {
    print('Parsing date string: $dateString');

    try {
      // Si la chaîne est au format "yyyy-MM-dd HH:mm:ss.SSS"
      DateTime parsedDate = DateTime.parse(dateString);

      // Utiliser DateFormat pour formater la date sans le "T"
      String formattedDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(parsedDate);
      print('Formatted date: $formattedDate');

      return parsedDate;
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }








  /// Méthode pour mettre à jours la têche en cours
  void updateAccidentInDatabase(String accidentId, String titre, String description, String startDateString) {
    /// Convertir les dates de chaînes de caractères en objets DateTime
    DateTime? startDate = parseDateString(startDateString);

    /// Vérifier si les dates sont valides
    if (startDate == null) {
      print('Invalid date format');
      Get.snackbar(
        "Error",
        "Invalid date format",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    /// Référence à la base de données Firebase
    DatabaseReference accidentsRef = FirebaseDatabase.instance.reference().child('accidents');

    /// Créer un objet Accident avec les nouvelles informations
    Map<String, dynamic> updatedAccident = {
      'titre': titre,
      'description': description,
      'startDate': startDate.toIso8601String(),
    };

    /// Mettre à jour l'accident dans la base de données en utilisant son ID
    accidentsRef.child(accidentId).update(updatedAccident).then((_) {
      /// Si la mise à jour est réussie, afficher une notification de succès
      print('Accident updated successfully in database');
      Get.snackbar(
        "Succès",
        "L'accident a été modifié avec succès!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }).catchError((error) {
      // En cas d'erreur lors de la mise à jour, afficher une notification d'erreur
      print('Error updating accident: $error');
      Get.snackbar(
        "Erreur",
        "Échec de la modification de l'accident",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    });
  }




  /// Méthode pour ouvrir le formulaire avec les information de la tâche en cours

  void openEditForm(String accidentId, Map<String, dynamic> accidentData) {
    TextEditingController titreAccidentController = TextEditingController(text: accidentData['titre']);
    TextEditingController descriptionAccidentController = TextEditingController(text: accidentData['description']);
    String startDateString = accidentData['startDate'];


    /// Convertir les dates en objets DateTime
    DateTime? startDate = startDateString.isNotEmpty ? DateTime.parse(startDateString) : null;


    /// Formatter les dates en format "jj/mm/aaaa"
    String formattedStartDate = startDate != null ? DateFormat('dd/MM/yyyy').format(startDate) : '';
    TextEditingController startDateController = TextEditingController(text: startDateString);

    Get.bottomSheet(
      SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
          ),
          height: MediaQuery.of(context).size.height - 10.0,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Center(
                    child: Text(
                      "Modification d'un accident",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 23,
                      ),
                    ),
                  ),
                ),
                FormBuilder(
                  key: _formKeyAccidentEdit,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Titre de l'accident",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FormBuilderTextField(
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                        name: 'titre',
                        controller: titreAccidentController,
                        decoration: const InputDecoration(
                          hintStyle: TextStyle(color: Colors.black),
                          hintText: 'Donner un titre',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: Colors.black,
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        cursorColor: Colors.black,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Détails de l'accident",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FormBuilderTextField(
                        name: 'description',
                        controller: descriptionAccidentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: "Donner une description ou un détail de l'accident",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: Colors.black,
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Date de l'accident",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FormBuilderTextField(
                        name: 'startDate',
                        controller: startDateController,
                        decoration: const InputDecoration(
                          hintText: 'Choisir la date de l\'accident',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            borderSide: BorderSide(
                              color: Colors.black,
                              style: BorderStyle.solid,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Container(
                          width: 250,
                          height: 55,
                          child: FloatingActionButton(
                            elevation: 5,
                            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(60)),
                            backgroundColor: Colors.black,
                            onPressed: () {
                              if (_formKeyAccidentEdit.currentState!.validate()) {
                                var formData = _formKeyAccidentEdit.currentState!.value;
                                print("Form Data: $formData");
                                updateAccidentInDatabase(
                                  accidentId,
                                  titreAccidentController.text,
                                  descriptionAccidentController.text,
                                  startDateController.text,
                                );

                                Future.delayed(Duration(seconds: 2), () {
                                  if (mounted) {
                                    Get.back();
                                  }
                                }
                                );
                              }
                              else {
                                print("Validation failed");
                              }
                              Get.off(() => Accueil());
                            },
                            child: const Text(
                              "Modifier",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
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
  }



  /// Méthode pour supprimer la tache de la base
  void deleteAccidentFromDatabase(String accidentId) {
    DatabaseReference tasksRef = FirebaseDatabase.instance.reference().child('accidents');
    tasksRef.child(accidentId).remove().then((_) {
      print('Accident deleted successfully from database');
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


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        centerTitle: true,
        title: Text(
          "Détails",
          style: TextStyle(
            color: Colors.black
          ),
        ),
        leading: IconButton(
          onPressed: (){
            // l'action qui va s'exécuter quand on va cliqeur le l'iconButton, notre action ici c'est de se retourner là où l'on vient c'est à dire l'ancienne page
            Navigator.pop(context);
            //Get.back();
          },
          icon: Icon(
              Icons.arrow_back_ios
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// j'ai mis la connexion, je vais ajouter quelques images
            // ON va gerer la suspréssion pour cela on fait, quand on appuis très longtemps sur l'élément on va demande si la personne veut supprier ou pas
            GestureDetector(
              // Je veux qu'on change la logique ici regarde ce qu'on va faire hein
              onLongPress: (){
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        backgroundColor: Colors.black87,
                        title: const Text(
                            "Actions",
                          style: TextStyle(
                            color: Colors.yellow
                          ),
                        ),
                        content: const Text(
                            "Veillez choisir une action svp, "
                                "NB: cette action est irréversible.",
                          style: TextStyle(
                              color: Colors.yellow
                          ),
                        ),
                        actions: [
                          Row(
                            children: [
                              /// Button annconst uler
                              Expanded(
                                child: TextButton(
                                    onPressed: (){
                                      // Toujours c'est dans cette partie on gère l'action à éffectuer quand on clique
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "ANNULER",
                                      style: TextStyle(
                                          color: Colors.yellow,
                                        fontSize: 12,
                                      ),
                                    )
                                ),
                              ),

                              /// Button modifier
                              Expanded(
                                child: TextButton(
                                    onPressed: (){
                                      // On va appeler notre méthode modifier ici, pour cela on va appeler un bottomSheet avec un formulaire
                                      openEditForm(
                                        widget.accident.id,
                                        {
                                          'titre': widget.accident.titre,
                                          'description': widget.accident.description,
                                          'startDate': widget.accident.startDate,
                                        },

                                      );
                                    },
                                    child: const Text(
                                      "MODIFIER",
                                      style: TextStyle(
                                          color: Colors.yellow,
                                        fontSize: 12,
                                      ),
                                    )
                                ),
                              ),

                              /// Button supprimer
                              Expanded(
                                child: TextButton(
                                    onPressed: (){
                                      // je veux que quad il choisi supprimer qu'on  lui montre un message d'avertissement
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context){
                                            return AlertDialog(
                                              backgroundColor: Colors.black87,
                                              title: const Text(
                                                "Susppréssion",
                                                style: TextStyle(
                                                    color: Colors.yellow
                                                ),
                                              ),
                                              content: const Text(
                                                  "Voulez-vous supprimer cet élément ? \n"
                                                      "NB: cette action est irréversible.",
                                                style: TextStyle(
                                                    color: Colors.pink
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: (){
                                                      // On se retourne en arrière
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "NON",
                                                      style: TextStyle(
                                                          color: Colors.yellow
                                                      ),
                                                    )
                                                ),
                                                TextButton(
                                                    onPressed: (){
                                                      // On fait la suspréssion, tout en appellant notre méthode supprimer ici
                                                      deleteAccidentFromDatabase(widget.accident.id);
                                                      Get.off(() => Accueil());
                                                    },
                                                    child: const Text(
                                                      "OUI",
                                                      style: TextStyle(
                                                          color: Colors.red
                                                      ),
                                                    )
                                                ),
                                              ],
                                            );
                                          }
                                      );
                                    },
                                    child: const Text(
                                      "SUPPRIMER",
                                      style: TextStyle(
                                          color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                );
              },
              child: Container(
                color: Colors.black87,
                child: Column(
                  children: [
                    GFListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.accident.titre,
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subTitle: Column(
                        children: [
                          Text(
                            widget.accident.description,
                            style: const TextStyle(
                              color: Colors.yellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: Center(
                            child: Text(
                              widget.accident.startDate,
                              style: const TextStyle(
                                color: Colors.yellow,
                              ),
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (String value) {
                            if (value == 'Modifier') {
                              // Code à exécuter lorsque l'utilisateur choisit "Modifier"
                              openEditForm(
                                widget.accident.id,
                                {
                                  'titre': widget.accident.titre,
                                  'description': widget.accident.description,
                                  'startDate': widget.accident.startDate,
                                },

                              );
                            }
                            else if (value == 'Supprimer') {
                              // Code à exécuter lorsque l'utilisateur choisit "Paramètres"
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context){
                                    return AlertDialog(
                                      backgroundColor: Colors.black87,
                                      title: const Text(
                                        "Susppréssion",
                                        style: TextStyle(
                                            color: Colors.yellow
                                        ),
                                      ),
                                      content: const Text(
                                        "Voulez-vous supprimer cet élément ? \n"
                                            "NB: cette action est irréversible.",
                                        style: TextStyle(
                                            color: Colors.pink
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: (){
                                              // On se retourne en arrière
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "NON",
                                              style: TextStyle(
                                                  color: Colors.yellow
                                              ),
                                            )
                                        ),
                                        TextButton(
                                            onPressed: (){
                                              // On fait la suspréssion, tout en appellant notre méthode supprimer ici
                                              deleteAccidentFromDatabase(widget.accident.id);
                                              Get.off(() => Accueil());
                                            },
                                            child: const Text(
                                              "OUI",
                                              style: TextStyle(
                                                  color: Colors.red
                                              ),
                                            )
                                        ),
                                      ],
                                    );
                                  }
                              );
                            }
                            else if (value == 'Annuler') {
                              // Code à exécuter lorsque l'utilisateur choisit "Paramètres"
                             Navigator.pop(context);
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'Modifier',
                              child: Text(
                                'Modifier',
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15
                                ),
                              ),
                            ),

                            const PopupMenuItem<String>(
                              value: 'Supprimer',
                              child: Text(
                                'Supprimer',
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15
                                ),
                              ),
                            ),

                            const PopupMenuItem<String>(
                              value: 'Annuler',
                              child: Text(
                                'Annuler',
                                style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15
                                ),
                              ),
                            ),
                          ],
                          color: Color(0xFF1f1f1f),
                          iconColor: Colors.yellow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

            ),
          ],
        ),
      ),
    );
  }

}
