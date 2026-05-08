import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedAvatar = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('treinador')
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] as String? ?? '';
        _selectedAvatar = data['avatarIndex'] as int? ?? 0;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    await FirebaseFirestore.instance
        .collection('config')
        .doc('treinador')
        .set(
          {'name': _nameController.text.trim(), 'avatarIndex': _selectedAvatar},
          SetOptions(merge: true),
        );
    if (mounted) Navigator.pop(context, _selectedAvatar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Treinador'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Escolha seu avatar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(6, (i) {
                  final isSelected = _selectedAvatar == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = i),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple.shade50
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'assets/trainers/trainer_${i + 1}.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Treinador',
                  hintText: 'Ex: Ash',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'O nome não pode estar vazio';
                  }
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
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}