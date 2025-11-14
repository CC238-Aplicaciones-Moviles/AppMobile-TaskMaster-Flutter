import 'package:flutter/material.dart';
import 'package:taskmaster_flutter/models/auth/LoginRequest.dart';
import 'package:taskmaster_flutter/sharedPreferences/TaskmasterPrefs.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../core/auth/AuthApi.dart';
import '../core/auth/TokenStore.dart';
import '../core/users/UsersApi.dart';

class Login extends StatefulWidget {
  final TaskmasterPrefs prefs;

  const Login({super.key, required this.prefs});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _authApi = AuthApi();
  final _usersApi = UsersApi();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late TaskmasterPrefs _prefs;

  bool _passVisible = false;
  bool _rememberMe = true;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prefs = widget.prefs;

    _emailController.text = _prefs.email;
    _passwordController.text = _prefs.password;
  }

  Future<void> _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Completa correo y contraseña');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final req = LoginRequest(email: email, password: password);
      final res = await _authApi.signIn(req);
      final token = res.token;
      final userId = res.id;

      if (token.isEmpty) {
        throw Exception('Token vacío');
      }

      await _prefs.saveUserId(userId);

      if (_rememberMe) {
        await _prefs.saveAll(email: email, password: password, token: token, userId: userId);
      } else {
        await _prefs.saveEmailAndPassword(email: email, password: password);
        await _prefs.clearToken();
      }

      await TokenStore.saveToken(token);

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al iniciar sesión';
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

            final horizontalPadding = isExpanded
                ? 48.0
                : isMedium
                ? 32.0
                : 16.0;

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
                            vSpace: vSpace,
                            topPadding: vSpace,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
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
                            vSpace: vSpace,
                            topPadding: 2,
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

  Widget _buildHeaderDesktop({
    required double logoSize,
    required ColorScheme colorScheme,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo rojo completo
        Container(color: colorScheme.primary),

        // Triángulo blanco que entra desde abajo
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 120, // profundidad del triángulo, ajústalo a tu gusto
            width: double.infinity,
            child: ClipPath(
              clipper: BottomWhiteTriangleClipper(),
              child: Container(color: colorScheme.background),
            ),
          ),
        ),

        // Logo + texto
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


  Widget _buildForm({
    required double vSpace,
    required double topPadding,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: topPadding),
        Text(
          'Inicia Sesión',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colorScheme.onBackground,
          ),
        ),
        SizedBox(height: vSpace),

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
              onPressed: () {
                setState(() => _passVisible = !_passVisible);
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: vSpace),

        if (_error != null) ...[
          Text(
            _error!,
            style: TextStyle(color: colorScheme.error),
          ),
          SizedBox(height: vSpace),
        ],

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _onLogin,
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
                const Text('Ingresando...'),
              ],
            )
                : const Text('Iniciar Sesión'),
          ),
        ),
        SizedBox(height: vSpace),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Switch(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v),
            ),
            const SizedBox(width: 12),
            Text(
              'Recordar credenciales',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
          ],
        ),
        SizedBox(height: vSpace * 1.2),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿No tienes una cuenta? ',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onBackground,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text(
                'Crea una',
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
