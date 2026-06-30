import 'package:flutter/material.dart';
import '../model/redacteur.dart';
import '../services/database_manager.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  // 16. Déclarer des TextEditingController pour la zone d'ajout principale
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final DatabaseManager _dbManager = DatabaseManager();

  // 17. Prévoir la liste de rédacteurs à afficher dans l’écran
  List<Redacteur> _redacteurs = [];

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs(); // Charger les données au démarrage
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Récupérer et stocker la liste dans la variable d'état
  Future<void> _chargerRedacteurs() async {
    final data = await _dbManager.getAllRedacteurs();
    setState(() {
      _redacteurs = data;
    });
  }

  // Ajouter un rédacteur
  Future<void> _ajouterRedacteur() async {
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    // Créer l'objet sans id (l'id est généré par SQLite)
    final nouveau = Redacteur(
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
    );

    await _dbManager.insertRedacteur(nouveau);

    // Vider les champs et rafraîchir
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();
    _chargerRedacteurs();
  }

  // Modifier via une boîte de dialogue
  void _afficherDialogueModification(Redacteur redacteur) {
    // Nouveaux contrôleurs dédiés à la boîte de dialogue, pré-remplis
    final editNomController = TextEditingController(text: redacteur.nom);
    final editPrenomController = TextEditingController(text: redacteur.prenom);
    final editEmailController = TextEditingController(text: redacteur.email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier Rédacteur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editPrenomController,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau Prénom',
                  ),
                ),
                TextField(
                  controller: editNomController,
                  decoration: const InputDecoration(labelText: 'Nouveau Nom'),
                ),
                TextField(
                  controller: editEmailController,
                  decoration: const InputDecoration(labelText: 'Nouvel Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final modifie = Redacteur(
                  id: redacteur.id, // On conserve l'id existant
                  nom: editNomController.text,
                  prenom: editPrenomController.text,
                  email: editEmailController.text,
                );
                await _dbManager.updateRedacteur(modifie);
                if (mounted) Navigator.pop(context);
                _chargerRedacteurs(); // Rafraîchir l'écran principal
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  // Boîte de dialogue de confirmation de suppression
  void _confirmerSuppression(int? id) {
    if (id == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment supprimer ce rédacteur ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () async {
                await _dbManager.deleteRedacteur(id);
                if (mounted) Navigator.pop(context);
                _chargerRedacteurs(); // Rafraîchir la liste
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des rédacteurs',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Zone supérieure : Formulaire de saisie d'ajout
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),

            // Bouton d’ajout de rédacteur
            ElevatedButton.icon(
              onPressed: _ajouterRedacteur,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un Rédacteur'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(45),
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
            const Divider(height: 32),

            // Afficher les rédacteurs dans un ListView.builder
            Expanded(
              child: _redacteurs.isEmpty
                  ? const Center(child: Text('Aucun rédacteur enregistré.'))
                  : ListView.builder(
                      itemCount: _redacteurs.length,
                      itemBuilder: (context, index) {
                        final redacteur = _redacteurs[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              '${redacteur.prenom} ${redacteur.nom.toUpperCase()}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(redacteur.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icône de modification
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () =>
                                      _afficherDialogueModification(redacteur),
                                ),
                                // Icône de suppression
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () =>
                                      _confirmerSuppression(redacteur.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
