import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kashsense/providers/providers.dart';

class ProfileSetting extends StatefulWidget {
  final String userId;

  const ProfileSetting({super.key, required this.userId});

  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  final TextEditingController _nameController = TextEditingController();
  String? _photoBase64;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await getUserForProfile(widget.userId);
    if (user == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _nameController.text = user.name;
      _photoBase64 = user.profilePictureUrl;
    });
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final bytes = result.files.single.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível ler a imagem selecionada.'),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _photoBase64 = base64Encode(bytes);
    });
  }

  ImageProvider<Object>? _buildPhotoProvider() {
    if (_photoBase64 == null || _photoBase64!.isEmpty) {
      return null;
    }

    try {
      final bytes = base64Decode(_photoBase64!);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite um nome válido.')));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final updatedUser = await updateUserProfileInfo(
      widget.userId,
      name: name,
      profilePictureUrl: _photoBase64,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (updatedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o perfil.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações de Perfil')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foto de perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: _buildPhotoProvider(),
                  child: _buildPhotoProvider() == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton.icon(
                  onPressed: _pickProfilePhoto,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Escolher foto da galeria'),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nome',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Digite seu nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'Salvando...' : 'Salvar alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
