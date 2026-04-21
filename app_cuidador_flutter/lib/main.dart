import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'config/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'services/notification_service.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
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
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0090C1), // Azul Confianza
          secondary: Color(0xFF00BFA5), // Teal Salud
          tertiary: Color(0xFF8E44AD), // Violeta Empatía
          error: Color(0xFFEF4444),
          surface: Color(0xFFF8FAFC),
          onSurface: Color(0xFF1A1A1A),
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          elevation: 2,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
      ),
      home: const AppStartupSequence(),
    );
  }
}

class AppStartupSequence extends StatefulWidget {
  const AppStartupSequence({super.key});

  @override
  State<AppStartupSequence> createState() => _AppStartupSequenceState();
}

class _AppStartupSequenceState extends State<AppStartupSequence> {
  int _currentStep = 0; // 0: Creator, 1: Logo, 2: Loading/Bridge

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  void _startSequence() async {
    // 1. Pantalla del Creador (2 segundos)
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _currentStep = 1);

    // 2. Pantalla del Logo (2.5 segundos)
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) setState(() => _currentStep = 2);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 0) return const CreatorSplash();
    if (_currentStep == 1) return const LogoSplash();
    
    // 3. Puente hacia Auth
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingBridge();
        }
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

class CreatorSplash extends StatelessWidget {
  const CreatorSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro solicitado
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo del Creador
            Image.asset(
              'assets/images/logo_creador.png',
              width: 140,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.code_rounded, size: 60, color: Colors.white24);
              },
            ),
            const SizedBox(height: 32),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
                children: [
                  TextSpan(
                    text: 'Desarrollado por ',
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                  TextSpan(
                    text: 'Felipe Zúñiga',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Efecto Bold solicitado
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LogoSplash extends StatefulWidget {
  const LogoSplash({super.key});

  @override
  State<LogoSplash> createState() => _LogoSplashState();
}

class _LogoSplashState extends State<LogoSplash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_hallame.png',
                width: 180,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.qr_code_2_rounded, size: 100, color: Color(0xFF00BFA5));
                },
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                  children: [
                    TextSpan(text: 'Hall'),
                    TextSpan(
                      text: 'ame',
                      style: TextStyle(color: Color(0xFF00BFA5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoadingBridge extends StatelessWidget {
  const LoadingBridge({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Sincronizando...',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
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

  List<Map<String, dynamic>> profiles = [];
  bool _isLoading = true;
  File? _selectedImage;
  bool _isUploading = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  final String defaultAvatar = 'https://api.dicebear.com/9.x/avataaars/png?seed=Generico';

  Future<void> _checkConnection() async {
    try {
      final url = Uri.parse('${AppConfig.backendBaseUrl}/profiles/ping');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Conexión Exitosa: ${data['message']}'),
              backgroundColor: const Color(0xFF00BFA5),
            ),
          );
        }
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error de Conexión: Verifica que el servidor en tu Mac esté corriendo y que estés en el mismo Wi-Fi. ($e)'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  void _showLegalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Información Legal',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Política de Privacidad',
                  style: TextStyle(
                    color: Color(0xFF0090C1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Hallame respeta tu privacidad. Los datos médicos son encriptados y solo se muestran a quienes escaneen el código QR físico. No compartimos tus datos con terceros para fines comerciales.',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 13),
                ),
                SizedBox(height: 16),
                Text(
                  'Términos de Uso',
                  style: TextStyle(
                    color: Color(0xFF0090C1),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'El uso de Hallame es bajo responsabilidad del usuario. La precisión del GPS depende del dispositivo móvil del "Encontrador". Hallame no garantiza la ubicación exacta en todas las condiciones.',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 13),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Entendido',
                style: TextStyle(
                  color: Color(0xFF0090C1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _syncFcmToken();
  }

  Future<void> _syncFcmToken() async {
    // Sincronizar el token cada vez que se abre el dashboard para asegurar que el backend lo tenga
    final token = await NotificationService.initialize();
    // Nota: El init ya llama a sync, pero podemos forzarlo si queremos
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final url = Uri.parse('${AppConfig.backendBaseUrl}/profiles');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          profiles = data
              .map(
                (p) => {
                  'id': p['id'],
                  'qrUuid': p['qrUuid'],
                  'name': p['fullName'],
                  'diagnosis': p['diagnosis'],
                  'contact': p['emergencyContact'],
                  'contact2': p['emergencyContact2'],
                  'status': 'Seguro',
                  'photoUrl': p['photoUrl'],
                  'color': const Color(0xFF10B981),
                },
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error cargando perfiles: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      setState(() => _isUploading = true);
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(
        'profiles/$userId/$fileName',
      );

      final uploadTask = await storageRef.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage(StateSetter setDialogState) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF0090C1),
                ),
                title: const Text(
                  'Galería',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 70,
                  );
                  if (image != null) {
                    setDialogState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF00BFA5),
                ),
                title: const Text(
                  'Cámara',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 70,
                  );
                  if (image != null) {
                    setDialogState(() {
                      _selectedImage = File(image.path);
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final Map<String, String> countryCodes = {
    'Seleccionar': '',
    'Chile': '+56',
    'Argentina': '+54',
    'Perú': '+51',
    'Colombia': '+57',
    'México': '+52',
    'España': '+34',
    'Bolivia': '+591',
    'EE.UU.': '+1',
  };

  String _getPrefixFromNumber(String? fullNumber) {
    if (fullNumber == null || !fullNumber.startsWith('+')) return '+56';
    for (var prefix in countryCodes.values) {
      if (fullNumber.startsWith(prefix)) return prefix;
    }
    return '+56';
  }

  String _getNumberWithoutPrefix(String? fullNumber) {
    if (fullNumber == null) return '';
    final prefix = _getPrefixFromNumber(fullNumber);
    if (fullNumber.startsWith(prefix)) {
      return fullNumber.substring(prefix.length);
    }
    return fullNumber;
  }

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
    'Otros': ['Otro / No especificado'],
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
              color: Color(0xFF6366F1),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );

      items.addAll(
        list.map(
          (item) => DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                item,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
              ),
            ),
          ),
        ),
      );
    });

    return DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF94A3B8)),
      decoration: InputDecoration(
        labelText: 'Diagnóstico/Condición',
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF0090C1)),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items: items,
      onChanged: onChanged,
      selectedItemBuilder: (BuildContext context) {
        return items.map((DropdownMenuItem<String> item) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Text(
              (value == null || value.isEmpty) ? '' : value,
              style: const TextStyle(color: Color(0xFF1A1A1A)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          );
        }).toList();
      },
      validator: (val) => val == null || val.startsWith('header_') || val.isEmpty
          ? 'Seleccione una opción'
          : null,
    );
  }

  Widget _buildPhoneInputField({
    required String label,
    required TextEditingController controller,
    required String currentPrefix,
    required Function(String?) onPrefixChanged,
    required IconData icon,
  }) {
    final bool isEnabled = currentPrefix.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled 
              ? const Color(0xFF0090C1).withOpacity(0.3) 
              : Colors.black.withOpacity(0.05)
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            icon, 
            color: isEnabled ? const Color(0xFF0090C1) : const Color(0xFF94A3B8), 
            size: 20
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentPrefix,
              dropdownColor: Colors.white,
              onChanged: onPrefixChanged,
              items: countryCodes.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.value,
                  child: Text(
                    entry.value.isEmpty ? 'País' : '${entry.value} (${entry.key})',
                    style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13),
                  ),
                );
              }).toList(),
              selectedItemBuilder: (context) {
                return countryCodes.values.map((p) => Center(
                  child: Text(
                    p.isEmpty ? '...' : p,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )).toList();
              },
            ),
          ),
          Container(
            height: 24,
            width: 1,
            color: Colors.black.withOpacity(0.05),
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEnabled,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: isEnabled ? label : 'Seleccione país primero',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              ),
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(Map<String, dynamic> profile) {
    final nameController = TextEditingController(text: profile['name']);
    final diagnosisController = TextEditingController(
      text: profile['diagnosis'],
    );

    final contactFull = profile['contact']?.toString() ?? '';
    final contact2Full = profile['contact2']?.toString() ?? '';

    String prefix1 = _getPrefixFromNumber(contactFull);
    String prefix2 = _getPrefixFromNumber(contact2Full);

    final contactController = TextEditingController(
      text: _getNumberWithoutPrefix(contactFull),
    );
    final contact2Controller = TextEditingController(
      text: _getNumberWithoutPrefix(contact2Full),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Editar Perfil',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(setDialogState),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0090C1).withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: const Color(0xFFF1F5F9),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (profile['photoUrl'] != null
                                        ? NetworkImage(profile['photoUrl'])
                                        : null)
                                    as ImageProvider?,
                          child:
                              _selectedImage == null &&
                                  profile['photoUrl'] == null
                              ? const Icon(
                                  Icons.add_a_photo,
                                  size: 32,
                                  color: Color(0xFF0090C1),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    _buildDiagnosisDropdown(
                      value: diagnosisController.text.isEmpty
                          ? null
                          : diagnosisController.text,
                      onChanged: (val) =>
                          setDialogState(() => diagnosisController.text = val!),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contacto Principal',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPhoneInputField(
                      label: 'Número de Contacto Principal',
                      controller: contactController,
                      currentPrefix: prefix1,
                      onPrefixChanged: (val) =>
                          setDialogState(() => prefix1 = val!),
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contacto Alternativo',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPhoneInputField(
                      label: 'Número Alternativo (Opcional)',
                      controller: contact2Controller,
                      currentPrefix: prefix2,
                      onPrefixChanged: (val) =>
                          setDialogState(() => prefix2 = val!),
                      icon: Icons.phone_android,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final updatedName = nameController.text.trim();
                    final updatedDiagnosis = diagnosisController.text;
                    final updatedContact =
                        prefix1 + contactController.text.trim();
                    final updatedContact2 =
                        contact2Controller.text.trim().isEmpty
                        ? ''
                        : prefix2 + contact2Controller.text.trim();

                    if (updatedName.isEmpty ||
                        contactController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nombre y número son obligatorios'),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    String? updatedPhotoUrl = profile['photoUrl'];
                    if (_selectedImage != null) {
                      updatedPhotoUrl = await _uploadImage(_selectedImage!);
                    }

                    try {
                      final url = Uri.parse(
                        '${AppConfig.backendBaseUrl}/profiles/${profile['id']}',
                      );
                      final idToken = await FirebaseAuth.instance.currentUser
                          ?.getIdToken();
                      final response = await http.patch(
                        url,
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $idToken',
                        },
                        body: jsonEncode({
                          'fullName': updatedName,
                          'diagnosis': updatedDiagnosis,
                          'emergencyContact': updatedContact,
                          'emergencyContact2': updatedContact2,
                          'photoUrl': updatedPhotoUrl,
                        }),
                      );

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        setState(() {
                          profile['name'] = updatedName;
                          profile['diagnosis'] = updatedDiagnosis;
                          profile['contact'] = updatedContact;
                          profile['contact2'] = updatedContact2;
                          profile['photoUrl'] = updatedPhotoUrl;
                          _selectedImage = null;
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Perfil actualizado con éxito'),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint('Error updating: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0090C1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateProfileDialog() {
    final nameController = TextEditingController();
    final diagnosisController = TextEditingController();
    final contactController = TextEditingController();
    final contact2Controller = TextEditingController();

    String prefix1 = '+56';
    String prefix2 = '+56';
    bool isCreating = false; // Movido aquí para que sea válido

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Nuevo Perfil',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _pickImage(setDialogState),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0090C1).withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: const Color(0xFFF1F5F9),
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : null,
                          child: _selectedImage == null
                              ? const Icon(
                                  Icons.add_a_photo,
                                  size: 32,
                                  color: Color(0xFF0090C1),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre Completo',
                        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black.withOpacity(0.1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0xFF0090C1),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      style: const TextStyle(color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 16),
                    _buildDiagnosisDropdown(
                      value: diagnosisController.text.isEmpty
                          ? null
                          : diagnosisController.text,
                      onChanged: (val) =>
                          setDialogState(() => diagnosisController.text = val!),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contacto Principal',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPhoneInputField(
                      label: 'Número de Contacto Principal',
                      controller: contactController,
                      currentPrefix: prefix1,
                      onPrefixChanged: (val) =>
                          setDialogState(() => prefix1 = val!),
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Contacto Alternativo',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPhoneInputField(
                      label: 'Número Alternativo (Opcional)',
                      controller: contact2Controller,
                      currentPrefix: prefix2,
                      onPrefixChanged: (val) =>
                          setDialogState(() => prefix2 = val!),
                      icon: Icons.phone_android,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  ),
                ),

                ElevatedButton(
                  onPressed: isCreating ? null : () async {
                    final newName = nameController.text.trim();
                    final newDiagnosis = diagnosisController.text;
                    final newContact = prefix1 + contactController.text.trim();
                    final newContact2 = contact2Controller.text.trim().isEmpty
                        ? ''
                        : prefix2 + contact2Controller.text.trim();

                    if (newName.isEmpty ||
                        contactController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nombre y contacto principal obligatorios',
                          ),
                          backgroundColor: Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }

                    setDialogState(() => isCreating = true);

                    try {
                      String? uploadedUrl;
                      if (_selectedImage != null) {
                        uploadedUrl = await _uploadImage(_selectedImage!);
                      }

                      final idToken = await FirebaseAuth.instance.currentUser
                          ?.getIdToken();
                      final url = Uri.parse(
                        '${AppConfig.backendBaseUrl}/profiles',
                      );
                      final response = await http.post(
                        url,
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer $idToken',
                        },
                        body: jsonEncode({
                          'fullName': newName,
                          'diagnosis': newDiagnosis,
                          'emergencyContact': newContact,
                          'emergencyContact2': newContact2,
                          'photoUrl': uploadedUrl,
                        }),
                      ).timeout(const Duration(seconds: 10));

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        final data = jsonDecode(response.body);
                        setState(() {
                          profiles.add({
                            'id': data['profileId'],
                            'qrUuid': data['qrUuid'],
                            'name': newName,
                            'diagnosis': newDiagnosis,
                            'contact': newContact,
                            'contact2': newContact2,
                            'photoUrl': uploadedUrl,
                            'status': 'Seguro',
                            'color': const Color(0xFF6366F1),
                          });
                          _selectedImage = null;
                        });
                        if (context.mounted) Navigator.pop(context);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al crear (${response.statusCode}): ${response.body}'),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Fallo crítico: $e'),
                            backgroundColor: const Color(0xFFEF4444),
                          ),
                        );
                      }
                    } finally {
                      if (context.mounted) setDialogState(() => isCreating = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0090C1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isCreating 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        'Crear',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                ),
              ],
            );
          },
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Código QR de ${profile['name']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(data: scanUrl, version: QrVersions.auto),
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
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.download, size: 18, color: Colors.white),
              label: const Text(
                'Descargar QR',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                try {
                  final image = await _screenshotController.capture();
                  if (image != null) {
                    final directory = await getTemporaryDirectory();
                    final imagePath = await File(
                      '${directory.path}/qr_${profile['name']}.png',
                    ).create();
                    await imagePath.writeAsBytes(image);

                    // Compartir el archivo permite al usuario guardarlo o imprimirlo
                    await Share.shareXFiles([
                      XFile(imagePath.path),
                    ], text: 'Código QR de ${profile['name']}');
                  }
                } catch (e) {
                  debugPrint('Error exportando QR: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.share, size: 18, color: Colors.white),
              label: const Text(
                'Compartir enlace',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Share.share(
                  '🚨 Perfil de emergencia de ${profile['name']}\n\nEscanea o abre este enlace para ver los datos de contacto y compartir tu ubicación:\n$scanUrl',
                  subject: 'Perfil de emergencia - Hallame',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hola, Cuidador',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                              color: Color(0xFF1A1A1A),
                            ),
                            children: [
                              TextSpan(text: 'Hall'),
                              TextSpan(
                                text: 'ame',
                                style: TextStyle(color: Color(0xFF00BFA5)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Icons Section
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1A1A1A)),
                      onPressed: _loadProfiles,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      tooltip: 'Actualizar lista',
                    ),
                    IconButton(
                      icon: const Icon(Icons.lan_outlined, color: Color(0xFF0090C1)),
                      onPressed: _checkConnection,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      tooltip: 'Probar conexión',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF94A3B8),
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      onPressed: () => _showLegalDialog(),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFFB7185),
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      onPressed: () async {
                        await GoogleSignIn().signOut();
                        await FirebaseAuth.instance.signOut();
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 8),
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
                        color: const Color(0xFFF1F5F9), // Gris claro sólido
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_active_rounded,
                            color: Color(0xFF1A1A1A), // Máximo contraste
                            size: 24,
                          ),
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
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.1),
                        const Color(0xFFFB7185).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.2),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text('🤝', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 8),
                      const Text(
                        'Todo en calma',
                        style: TextStyle(
                          color: Color(0xFF0090C1),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Estamos velando por la seguridad de tus seres queridos.',
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
                  color: Color(0xFF1A1A1A),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (profiles.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No tienes perfiles registrados.\nUsa el botón "+" para agregar uno.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF475569)),
                    ),
                  ),
                )
              else
                ...profiles.map((profile) {
                  final isDanger = hasEmergency && profile['id'] == '1';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0090C1), Color(0xFF00BFA5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: profile['photoUrl'] != null && profile['photoUrl'].toString().isNotEmpty
                                ? Image.network(
                                    profile['photoUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          profile['name'] != null && profile['name'].toString().isNotEmpty 
                                              ? profile['name'][0].toUpperCase() 
                                              : '?',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Text(
                                      profile['name'] != null && profile['name'].toString().isNotEmpty 
                                          ? profile['name'][0].toUpperCase() 
                                          : '?',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00BFA5,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  profile['diagnosis'],
                                  style: const TextStyle(
                                    color: Color(0xFF00BFA5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_2_rounded,
                            color: Color(0xFF8E44AD),
                            size: 28,
                          ),
                          tooltip: 'Ver QR',
                          onPressed: () => _showQRDialog(profile),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: Color(0xFF94A3B8),
                          ),
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: Colors.white,
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditProfileDialog(profile);
                            } else if (value == 'delete') {
                              _confirmDeleteProfile(profile);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Editar',
                                    style: TextStyle(color: Color(0xFF1A1A1A)),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(color: Color(0xFFEF4444)),
                                  ),
                                ],
                              ),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF0090C1),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0090C1).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '+ NUEVO PERFIL Y QR',
                    style: TextStyle(
                      color: Color(0xFF0090C1),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
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
  Future<void> _confirmDeleteProfile(Map<String, dynamic> profile) async {
    bool isDeleting = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('¿Eliminar Perfil?', 
              style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold)),
            content: Text('¿Realmente deseas eliminar a ${profile['name']}? Esta acción es permanente.', 
              style: const TextStyle(color: Color(0xFF1A1A1A))),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(context, false),
                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
              ),
              ElevatedButton(
                onPressed: isDeleting ? null : () async {
                  setDialogState(() => isDeleting = true);
                  try {
                    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
                    final url = Uri.parse('${AppConfig.backendBaseUrl}/profiles/${profile['id']}');
                    
                    final response = await http.delete(
                      url,
                      headers: {'Authorization': 'Bearer $idToken'},
                    ).timeout(const Duration(seconds: 10));

                    if (response.statusCode == 200) {
                      if (context.mounted) Navigator.pop(context, true);
                    } else if (response.statusCode == 404) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Servidor actualizándose en la nube. Por favor, reintenta en 1 minuto.'),
                            backgroundColor: Color(0xFF64748B),
                          ),
                        );
                        Navigator.pop(context, false);
                      }
                    } else {
                      throw Exception('Error ${response.statusCode}');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFEF4444)),
                      );
                      Navigator.pop(context, false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isDeleting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Eliminar'),
              ),
            ],
          );
        }
      ),
    );

    if (confirmed == true) {
      setState(() {
        profiles.removeWhere((p) => p['id'] == profile['id']);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil eliminado con éxito'), backgroundColor: Color(0xFF00BFA5)),
        );
      }
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al iniciar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'logo',
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        color: Color(0xFF1A1A1A),
                      ),
                      children: [
                        TextSpan(text: 'Hall'),
                        TextSpan(
                          text: 'ame',
                          style: TextStyle(color: Color(0xFF00BFA5)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cerca de ti,\nprotegiendo lo que importa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 64),
                if (_isLoading)
                  const CircularProgressIndicator(color: Color(0xFFFB7185))
                else
                  ElevatedButton(
                    onPressed: _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0090C1),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF0090C1).withOpacity(0.4),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Empezar ahora',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Al continuar, aceptas nuestros términos y políticas de privacidad.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF475569), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
