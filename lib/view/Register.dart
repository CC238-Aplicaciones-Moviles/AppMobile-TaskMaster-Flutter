// view/Register.dart
import 'package:flutter/material.dart';
import 'package:taskmaster_flutter/models/auth/SignUpRequest.dart';
import 'package:taskmaster_flutter/sharedPreferences/TaskmasterPrefs.dart';

import '../core/auth/AuthApi.dart';

class Register extends StatefulWidget {
  final TaskmasterPrefs prefs;

  const Register({super.key, required this.prefs});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _authApi = AuthApi();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _passVisible = false;
  bool _isLoading = false;
  String? _error;

  late TaskmasterPrefs _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = widget.prefs;
  }

  Future<void> _onSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final parts = username
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    String name;
    String lastName;
    if (parts.length == 1) {
      name = parts[0];
      lastName = parts[0];
    } else {
      name = parts.first;
      lastName = parts.sublist(1).join(' ');
    }

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      setState(() => _error = 'Completa correo, contraseña y username');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final req = SignUpRequest(
        name: name,
        lastName: lastName,
        email: email,
        password: password,
        roles: const ['ROLE_MEMBER'],
      );

      await _authApi.signUp(req);

      await _prefs.saveEmailAndPassword(email: email, password: password);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al crear la cuenta';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final maxHeight = constraints.maxHeight;

            final isExpanded = maxWidth >= 840;
            final isMedium = maxWidth >= 600 && maxWidth < 840;

            final horizontalPadding =
            isExpanded ? 48.0 : (isMedium ? 32.0 : 16.0);

            final contentMaxWidth = isExpanded
                ? 520.0
                : isMedium
                ? 440.0
                : maxWidth - horizontalPadding * 2;

            final headerHeight = isExpanded
                ? 0.0
                : maxHeight < 600
                ? maxHeight * 0.42
                : maxHeight < 720
                ? maxHeight * 0.46
                : maxHeight * 0.50;

            final vSpace = maxHeight < 640
                ? 12.0
                : maxHeight < 720
                ? 16.0
                : 24.0;

            final logoSize = maxWidth < 360 ? 96.0 : 112.0;

            if (isExpanded) {
              // desktop / tablet grande
              return Row(
                children: [
                  Expanded(
                    child: _buildHeaderDesktop(
                      logoSize: 140,
                      colorScheme: colorScheme,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(maxWidth: contentMaxWidth),
                          child: _buildForm(
                            title: 'Crea una cuenta',
                            vSpace: vSpace,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              // móvil
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeaderMobile(
                      height: headerHeight,
                      logoSize: logoSize,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                          BoxConstraints(maxWidth: contentMaxWidth),
                          child: _buildForm(
                            title: 'Crea una cuenta',
                            vSpace: vSpace,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
// ---------- HEADER DESKTOP ----------
  Widget _buildHeaderDesktop({
    required double logoSize,
    required ColorScheme colorScheme,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: colorScheme.primary),

        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: ClipPath(
              clipper: BottomWhiteTriangleClipper(),
              child: Container(color: colorScheme.background),
            ),
          ),
        ),

        Column(
          children: [
            const SizedBox(height: 24),
            SizedBox(
              width: logoSize,
              height: logoSize,
              child: Image.asset(
                'assets/img/TaskMaster_logoBlanco.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'TaskMaster',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderMobile({
    required double height,
    required double logoSize,
    required ColorScheme colorScheme,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: colorScheme.primary),

          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: height * 0.50,
              width: double.infinity,
              child: ClipPath(
                clipper: BottomWhiteTriangleClipper(),
                child: Container(color: colorScheme.background),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 16),
              SizedBox(
                width: logoSize,
                height: logoSize,
                child: Image.asset(
                  'assets/img/TaskMaster_logoBlanco.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TaskMaster',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // ---------- FORM ----------
  Widget _buildForm({
    required String title,
    required double vSpace,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: vSpace + 16),

        // Correo
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Correo',
            filled: true,
            fillColor: colorScheme.secondaryContainer,
            suffixIcon: Icon(Icons.email, color: colorScheme.onSurface),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        SizedBox(height: vSpace),

        // Contraseña
        TextField(
          controller: _passwordController,
          obscureText: !_passVisible,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            filled: true,
            fillColor: colorScheme.secondaryContainer,
            suffixIcon: IconButton(
              icon: Icon(
                _passVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => _passVisible = !_passVisible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        SizedBox(height: vSpace),

        // Username
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: 'Username',
            filled: true,
            fillColor: colorScheme.secondaryContainer,
            suffixIcon:
            Icon(Icons.account_circle, color: colorScheme.onSurface),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        SizedBox(height: vSpace + 8),

        // Botón Crear cuenta
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onSignUp,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Creando...'),
              ],
            )
                : const Text('Crear cuenta'),
          ),
        ),

        if (_error != null) ...[
          SizedBox(height: vSpace / 2),
          Text(
            _error!,
            style: TextStyle(color: colorScheme.error),
          ),
        ],

        SizedBox(height: vSpace + 4),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ya tienes una cuenta?',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text(
                'Ingresa',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BottomWhiteTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width / 2, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
