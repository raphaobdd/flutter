import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewPokemonScreen extends StatefulWidget {
  const NewPokemonScreen({super.key});

  @override
  State<NewPokemonScreen> createState() => _NewPokemonScreenState();
}

class _NewPokemonScreenState extends State<NewPokemonScreen> {
  final _nameController = TextEditingController();
  final _spriteIdController = TextEditingController();
  final _levelController = TextEditingController();
  final _spriteIdFocusNode = FocusNode();
  final _levelFocusNode = FocusNode();
  String? _selectedType;
  String _previewName = '';
  final _formKey = GlobalKey<FormState>();

  final collection = FirebaseFirestore.instance.collection('pokemons');

  @override
  void dispose() {
    _nameController.dispose();
    _spriteIdController.dispose();
    _levelController.dispose();
    _spriteIdFocusNode.dispose();
    _levelFocusNode.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    await collection.add({
      'name': _nameController.text.trim(),
      'spriteId': int.parse(_spriteIdController.text.trim()),
      'level': int.parse(_levelController.text.trim()),
      'types': [_selectedType],
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Novo Pokémon'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_previewName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Cadastrando: $_previewName…',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

              // Campo nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Pokémon',
                  hintText: 'Ex: Charizard',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onChanged: (value) =>
                    setState(() => _previewName = value.trim()),
                onFieldSubmitted: (_) =>
                    _spriteIdFocusNode.requestFocus(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome não pode estar vazio';
                  }
                  if (value.trim().length < 2) {
                    return 'Nome deve ter ao menos 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo spriteId
              TextFormField(
                controller: _spriteIdController,
                focusNode: _spriteIdFocusNode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Sprite ID',
                  hintText: 'Ex: 6',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _levelFocusNode.requestFocus(),
                validator: (value) {
                  final id = int.tryParse(value ?? '');
                  if (id == null) return 'Digite um número';
                  if (id < 1 || id > 1025) return 'ID deve ser entre 1 e 1025';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo nível
              TextFormField(
                controller: _levelController,
                focusNode: _levelFocusNode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nível inicial',
                  hintText: 'Ex: 5',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final lvl = int.tryParse(value ?? '');
                  if (lvl == null) return 'Digite um número';
                  if (lvl < 1 || lvl > 100) {
                    return 'Nível deve ser entre 1 e 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown tipo
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Fogo',
                  'Água',
                  'Planta',
                  'Elétrico',
                  'Normal',
                  'Psíquico',
                  'Gelo',
                  'Dragão',
                ]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedType = value),
                validator: (value) =>
                    value == null ? 'Selecione um tipo' : null,
              ),
              const SizedBox(height: 24),

              // Botão salvar
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Salvar Pokémon',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}