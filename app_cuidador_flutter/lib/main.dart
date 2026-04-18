import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'config/app_config.dart';

void main() {
  runApp(const HallameApp());
}

class HallameApp extends StatelessWidget {
  const HallameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hallame Cuidador',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF10B981),
          error: Color(0xFFEF4444),
          surface: Color(0xFF131B2F),
        ),
        fontFamily: 'Inter',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool hasEmergency = false;

  final List<Map<String, dynamic>> profiles = [
    {
      'id': '1',
      'name': 'Abuelo Juan',
      'diagnosis': 'Enfermedad de Alzheimer',
      'contact': '+56 9 1234 5678',
      'status': 'Seguro',
      'color': const Color(0xFF10B981),
    },
    {
      'id': '2',
      'name': 'Sofía',
      'diagnosis': 'Trastorno del Espectro Autista (TEA)',
      'contact': '+56 9 8765 4321',
      'status': 'Seguro',
      'color': const Color(0xFF10B981),
    },
  ];

  final Map<String, List<String>> diagnosisCategories = {
    'Enfermedades Neurodegenerativas': [
      'Enfermedad de Alzheimer',
      'Enfermedad de Parkinson',
      'Esclerosis Lateral Amiotrófica (ELA)',
      'Enfermedad de Huntington',
      'Demencia con cuerpos de Lewy',
      'Demencia vascular',
      'Ataxias espinocerebelosas',
      'Esclerosis múltiple',
    ],
    'Condiciones de Neurodivergencia': [
      'Trastorno del Espectro Autista (TEA)',
      'Trastorno por Déficit de Atención con Hiperactividad (TDAH)',
      'Dislexia',
      'Discalculia',
      'Disgrafía',
      'Trastorno del Procesamiento Sensorial',
      'Síndrome de Tourette',
    ],
    'Otros': ['Otro / No especificado']
  };

  Widget _buildDiagnosisDropdown({
    required String? value,
    required Function(String?) onChanged,
  }) {
    List<DropdownMenuItem<String>> items = [];
    
    diagnosisCategories.forEach((category, list) {
      items.add(
        DropdownMenuItem<String>(
          enabled: false,
          value: 'header_$category',
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
      
      items.addAll(list.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      )));
    });

    return DropdownButtonFormField<String>(
      value: (value == null || value.isEmpty) ? null : value,
      dropdownColor: const Color(0xFF1E293B),
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
      decoration: InputDecoration(
        labelText: 'Diagnóstico/Condición',
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF3B82F6)), borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items,
      onChanged: onChanged,
      selectedItemBuilder: (BuildContext context) {
        return items.map((DropdownMenuItem<String> item) {
          return Text(
            value ?? '',
            style: const TextStyle(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },
      validator: (val) => val == null || val.startsWith('header_') ? 'Seleccione una opción' : null,
    );
  }

  void _showEditProfileDialog(Map<String, dynamic> profile) {
    final nameController = TextEditingController(text: profile['name']);
    final diagnosisController = TextEditingController(text: profile['diagnosis']);
    final contactController = TextEditingController(text: profile['contact'] ?? '');
    final contact2Controller = TextEditingController(text: profile['contact2'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131B2F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return _buildDiagnosisDropdown(
                      value: diagnosisController.text.isEmpty ? null : diagnosisController.text,
                      onChanged: (val) => setDialogState(() => diagnosisController.text = val!),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Número de Contacto Principal',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFF94A3B8)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contact2Controller,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Número de Contacto Alternativo (Opcional)',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF94A3B8)),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              onPressed: () async {
                // Variables para la actualización
                final updatedName = nameController.text;
                final updatedDiagnosis = diagnosisController.text;
                final updatedContact = contactController.text;
                final updatedContact2 = contact2Controller.text;

                if (updatedName.isEmpty || updatedContact.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre y un contacto son obligatorios'), backgroundColor: Color(0xFFEF4444)));
                  return;
                }
                
                Navigator.pop(context); // Cierra la ventana de inmediato

                // 1. Mostrar un indicador de carga o simplemente ejecutar
                // En un entorno real se mostraría un CircularProgressIndicator
                
                try {
                  // 2. Realizar petición HTTP al backend (NestJS)
                  // Nota: Cambia localhost por la IP de tu PC si usas un dispositivo físico o 10.0.2.2 en emulador Android.
                  final url = Uri.parse('${AppConfig.backendBaseUrl}/profiles/${profile['id']}');
                  
                  final response = await http.patch(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'fullName': updatedName,
                      'diagnosis': updatedDiagnosis,
                      'emergencyContact': updatedContact,
                      'emergencyContact2': updatedContact2,
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    setState(() {
                      profile['name'] = updatedName;
                      profile['diagnosis'] = updatedDiagnosis;
                      profile['contact'] = updatedContact;
                      profile['contact2'] = updatedContact2;
                    });
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datos guardados y encriptados en el servidor'),
                          backgroundColor: Color(0xFF10B981),
                        )
                      );
                    }
                  } else {
                    // Solo actualizamos localmente si falla por ser un prototipo de prueba, 
                    // en producción deberías mostrar un error
                    setState(() {
                      profile['name'] = updatedName;
                      profile['diagnosis'] = updatedDiagnosis;
                      profile['contact'] = updatedContact;
                      profile['contact2'] = updatedContact2;
                    });
                  }
                } catch (e) {
                  // Si no hay conexión (ej: backend apagado), actualizamos local para la demostración
                  setState(() {
                    profile['name'] = updatedName;
                    profile['diagnosis'] = updatedDiagnosis;
                    profile['contact'] = updatedContact;
                    profile['contact2'] = updatedContact2;
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Guardado localmente. Error de conexión con el backend: $e'),
                        backgroundColor: const Color(0xFFEF4444),
                      )
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCreateProfileDialog() {
    final nameController = TextEditingController();
    final diagnosisController = TextEditingController();
    final contactController = TextEditingController();
    final contact2Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131B2F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Nuevo Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF3B82F6)), borderRadius: BorderRadius.circular(12)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setDialogState) {
                  return _buildDiagnosisDropdown(
                    value: diagnosisController.text.isEmpty ? null : diagnosisController.text,
                    onChanged: (val) => setDialogState(() => diagnosisController.text = val!),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Número de Contacto Principal',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF3B82F6)), borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF94A3B8)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contact2Controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Número de Contacto Alternativo (Opcional)',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF3B82F6)), borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF94A3B8)),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newDiagnosis = diagnosisController.text;
                final newContact = contactController.text;
                final newContact2 = contact2Controller.text;

                if (newName.isEmpty || newContact.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre y el contacto principal son obligatorios'), backgroundColor: Color(0xFFEF4444)));
                  return;
                }

                if (profiles.any((p) => p['name'].toString().toLowerCase() == newName.toLowerCase())) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ya existe una persona con ese nombre'), backgroundColor: Color(0xFFEF4444)));
                  return;
                }

                Navigator.pop(context); // Cierra la ventana inmediatamente

                try {
                  final url = Uri.parse('${AppConfig.backendBaseUrl}/profiles');
                  final response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'fullName': newName,
                      'diagnosis': newDiagnosis,
                      'emergencyContact': newContact,
                      'emergencyContact2': newContact2,
                    }),
                  );

                  if (response.statusCode == 200 || response.statusCode == 201) {
                    final data = jsonDecode(response.body);
                    setState(() {
                      profiles.add({
                        'id': data['profileId'],
                        'qrUuid': data['qrUuid'],
                        'name': newName,
                        'diagnosis': newDiagnosis,
                        'contact': newContact,
                        'contact2': newContact2,
                        'status': 'Seguro',
                        'color': const Color(0xFF10B981),
                      });
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfil creado y QR generado'), backgroundColor: Color(0xFF10B981))
                      );
                    }
                  } else {
                    throw Exception('Error del servidor');
                  }
                } catch (e) {
                  // Fallback local
                  setState(() {
                    profiles.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'qrUuid': 'mock-qr-${DateTime.now().millisecondsSinceEpoch}',
                      'name': newName,
                      'diagnosis': newDiagnosis,
                      'contact': newContact,
                      'contact2': newContact2,
                      'status': 'Seguro',
                      'color': const Color(0xFF10B981),
                    });
                  });
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Guardado localmente. Sin backend: $e'), backgroundColor: const Color(0xFFEF4444))
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showQRDialog(Map<String, dynamic> profile) {
    // Si no tiene qrUuid aún (ej. mock inicial), le inventamos uno para la demo
    final qrUuid = profile['qrUuid'] ?? 'mock-qr-1234';
    // URL que el Encontrador web va a abrir. 
    // Usando el túnel temporal de localtunnel para acceso desde cualquier red.
    final scanUrl = AppConfig.getQrUrl(qrUuid);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF131B2F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Código QR de ${profile['name']}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: QrImageView(
                  data: scanUrl,
                  version: QrVersions.auto,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cualquier persona que escanee este código será dirigida al perfil de emergencia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.share, size: 18, color: Colors.white),
              label: const Text('Compartir enlace', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Share.share(
                  '🚨 Perfil de emergencia de ${profile['name']}\n\nEscanea o abre este enlace para ver los datos de contacto y compartir tu ubicación:\n$scanUrl',
                  subject: 'Perfil de emergencia - Hallame',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hola, Cuidador',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            color: Colors.white,
                          ),
                          children: [
                            TextSpan(text: 'Hall'),
                            TextSpan(
                              text: 'ame',
                              style: TextStyle(color: Color(0xFF3B82F6)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        hasEmergency = !hasEmergency;
                      });
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                          if (hasEmergency)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Emergency Widget
              if (hasEmergency)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '¡ALERTA DE ESCANEO!',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: 'El código QR de '),
                            TextSpan(
                              text: 'Abuelo Juan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' acaba de ser escaneado.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'VER UBICACIÓN EN EL MAPA',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text('🛡️', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 8),
                      Text(
                        'Todo está tranquilo',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'No hay alertas de emergencia en este momento.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Profiles Section
              const Text(
                'Perfiles a tu cuidado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              ...profiles.map((profile) {
                final isDanger = hasEmergency && profile['id'] == '1';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          profile['name'][0],
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile['diagnosis'],
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (profile['contact'] != null && profile['contact'].toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone, color: Color(0xFF3B82F6), size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      profile['contact'],
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (profile['contact2'] != null && profile['contact2'].toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.phone_android, color: Color(0xFF3B82F6), size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      profile['contact2'],
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isDanger)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.qr_code_2, color: Color(0xFF3B82F6), size: 24),
                        tooltip: 'Ver QR',
                        onPressed: () => _showQRDialog(profile),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                        color: const Color(0xFF131B2F),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditProfileDialog(profile);
                          } else if (value == 'delete') {
                            setState(() {
                              profiles.removeWhere((p) => p['id'] == profile['id']);
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(children: [Icon(Icons.edit_outlined, color: Color(0xFF94A3B8), size: 20), SizedBox(width: 8), Text('Editar', style: TextStyle(color: Colors.white))]),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20), SizedBox(width: 8), Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444)))]),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Add Profile Button
              GestureDetector(
                onTap: _showCreateProfileDialog,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '+ NUEVO PERFIL Y QR',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
