import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_screen.dart';
import 'new_pokemon_screen.dart';
import 'trainer_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final collection = FirebaseFirestore.instance.collection('pokemons');
  late Future<int> _avatarFuture;

  @override
  void initState() {
    super.initState();
    _avatarFuture = _loadAvatarIndex();
  }

  Future<int> _loadAvatarIndex() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('treinador')
        .get();
    if (doc.exists) {
      return doc.data()?['avatarIndex'] as int? ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pokédex', style: TextStyle(fontSize: 18)),
            Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          FutureBuilder<int>(
            future: _avatarFuture,
            builder: (context, snapshot) {
              final index = snapshot.data ?? 0;
              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrainerProfileScreen(),
                    ),
                  );
                  if (result != null) {
                    setState(() => _avatarFuture = Future.value(result));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Image.asset(
                    'assets/trainers/trainer_${index + 1}.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NewPokemonScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: collection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum Pokémon cadastrado.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final docId = docs[index].id;
              final pokemon = Pokemon(
                name: data['name'] as String,
                types: List<String>.from(data['types'] as List),
                spriteUrl: data['spriteUrl'] as String,
                level: data['level'] as int,
              );
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    backgroundImage: NetworkImage(pokemon.spriteUrl),
                  ),
                  title: Text(pokemon.name),
                  subtitle: Text(
                      '${pokemon.types.join(' / ')} · Nível ${pokemon.level}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Colors.red.shade300),
                    onPressed: () => collection.doc(docId).delete(),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PokemonScreen(pokemon: pokemon, docId: docId),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}