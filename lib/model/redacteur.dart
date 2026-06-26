class Redacteur {
  final int? id;
  final String nom;
  final String prenom;
  final String email;

  // constructeur pour recuperer les redacteurs
  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // constructeur pour creer un redacteurs en dans la base avec id de type AUTO INCREMENT
  Redacteur.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
  }) : id = null;

  // convertir la classe Redacteur en un Objet map de type cle : valeur
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom, 
      'prenom': prenom, 
      'email': email
    };
  }

  // conertis un map en une instence de Redacteur
  factory Redacteur.fromMap(Map<String, dynamic> map) {
    return Redacteur(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
    );
  }
}
