import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pokemon_service.dart';

class NewPokemonScreen extends StatefulWidget {
  const NewPokemonScreen({super.key});

  @override
  State<NewPokemonScreen> createState() => _NewPokemonScreenState();
}

class _NewPokemonScreenState extends State<NewPokemonScreen> {
  late Future<List<String>> _searchFuture;
  final _queryController = TextEditingController();
  Map<String, dynamic>? _selected;
  bool _loadingDetails = false;
  final _levelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final collection = FirebaseFirestore.instance.collection('pokemons');

  @override
  void initState() {
    super.initState();
    _searchFuture = fetchPokemonNames();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _buscar() {
    final query = _queryController.text.trim();
    setState(() {
      _searchFuture =
          query.isEmpty ? fetchPokemonNames() : fetchPokemonByName(query);
    });
  }

  Future<void> _selectPokemon(String name) async {
    setState(() => _loadingDetails = true);
    try {
      final details = await fetchPokemonDetails(name);
      setState(() {
        _selected = details;
        _loadingDetails = false;
      });
    } catch (e) {
      setState(() => _loadingDetails = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar detalhes: $e')),
        );
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    await collection.add({
      'name': _selected!['name'],
      'spriteUrl': _selected!['spriteUrl'],
      'types': _selected!['types'],
      'level': int.parse(_levelController.text.trim()),
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Pokémon'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: _loadingDetails
          ? const Center(child: CircularProgressIndicator())
          : (_selected == null ? _buildList() : _buildForm()),
    );
  }

  Widget _buildList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar Pokémon',
                    hintText: 'Ex: pikachu',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _buscar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Buscar'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<String>>(
            future: _searchFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final names = snapshot.data!;
              return ListView.builder(
                itemCount: names.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(
                    names[i],
                    style: const TextStyle(textBaseline: TextBaseline.alphabetic),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectPokemon(names[i]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final spriteUrl = _selected!['spriteUrl'] as String;
    final name = _selected!['name'] as String;
    final types = _selected!['types'] as List<dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Image.network(
                      spriteUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: types
                          .map((t) => Chip(label: Text(t as String)))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => setState(() => _selected = null),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Trocar'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _levelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nível inicial',
                hintText: 'Ex: 5',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final lvl = int.tryParse(value ?? '');
                if (lvl == null) return 'Digite um número';
                if (lvl < 1 || lvl > 100) return 'Nível deve ser entre 1 e 100';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}