import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control de Horas',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: AppColors.loginLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.darkText,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: AppColors.bodyText,
            fontWeight: FontWeight.w400,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle: const TextStyle(
            color: Color(0xFF6D7F92),
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF86B7C8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF86B7C8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class AppColors {
  static const primary = Color(0xFF0A75BC);
  static const primaryDark = Color(0xFF033660);
  static const darkText = Color(0xFF10314A);
  static const bodyText = Color(0xFF4B6270);
  static const loginLight = Color(0xFFB6DEEA);
  static const loginMid = Color(0xFF8EC8DA);
  static const loginDark = Color(0xFF74B9CD);
  static const idleBackground = Color(0xFFDAF1F7);
  static const runningBackground = Color(0xFFBAE7EF);
  static const pausedBackground = Color(0xFFE0E0E0);
  static const headerDark = Color(0xFF0A2652);
  static const panelDark = Color(0xFF0F2F55);
  static const panelLight = Color(0xFFE8F3F6);
  static const accentBlue = Color(0xFF64C4DD);
  static const accentGrey = Color(0xFF9AA3AB);
  static const accentPause = Color(0xFF4AAFCB);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SessionFlowPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.loginLight, AppColors.loginMid, AppColors.loginDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -110,
              right: -30,
              child: _CirclesDecoration(
                color: Colors.white.withOpacity(0.22),
                innerStrokeColor: Colors.white.withOpacity(0.4),
                size: 360,
              ),
            ),
            Positioned(
              bottom: -40,
              right: 120,
              child: _CirclesDecoration(
                color: Colors.white.withOpacity(0.18),
                innerStrokeColor: Colors.white.withOpacity(0.35),
                size: 220,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.2),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Sistema de registro de horas.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                hintText: 'usuario',
                              ),
                              validator: (value) => (value ?? '').trim().isEmpty
                                  ? 'Introduce tu usuario'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: 'clave',
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              validator: (value) => (value ?? '').trim().isEmpty
                                  ? 'Introduce tu clave'
                                  : null,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 32),
                            FilledButton(
                              onPressed: _submit,
                              child: const Text('Acceder'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: Opacity(
                opacity: 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      'motit',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SessionStatus { idle, running, paused }

class SessionFlowPage extends StatefulWidget {
  const SessionFlowPage({super.key});

  @override
  State<SessionFlowPage> createState() => _SessionFlowPageState();
}

class _SessionFlowPageState extends State<SessionFlowPage> {
  SessionStatus _status = SessionStatus.idle;
  Duration _elapsed = Duration.zero;
  DateTime _referenceDate = DateTime(2025, 9, 23, 8, 45);
  String _selectedProject = 'LevelTech - Model P';

  static const _projects = <String>[
    'LevelTech - Model P',
    'Proyecto Alfa',
    'Onboarding interno',
  ];

  void _startSession() {
    setState(() {
      _status = SessionStatus.running;
      _referenceDate = DateTime(2025, 9, 23, 14, 25);
      _elapsed = const Duration(hours: 3, minutes: 10);
    });
  }

  void _pauseSession() {
    setState(() {
      _status = SessionStatus.paused;
      _referenceDate = DateTime(2025, 9, 23, 16, 30);
      _elapsed = const Duration(hours: 4, minutes: 45);
    });
  }

  void _resumeSession() {
    setState(() {
      _status = SessionStatus.running;
      _referenceDate = DateTime(2025, 9, 23, 16, 30);
    });
  }

  void _finishSession() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = SessionPalette.fromStatus(_status);
    return Scaffold(
      backgroundColor: palette.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -60,
              child: _CirclesDecoration(
                color: Colors.white.withOpacity(0.06),
                innerStrokeColor: Colors.white.withOpacity(0.18),
                size: 360,
              ),
            ),
            Positioned(
              bottom: -100,
              left: -40,
              child: _CirclesDecoration(
                color: Colors.white.withOpacity(0.08),
                innerStrokeColor: Colors.white.withOpacity(0.2),
                size: 300,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SessionHeader(
                  title: _status == SessionStatus.idle
                      ? 'Registro de horas'
                      : _status == SessionStatus.running
                          ? 'Jornada laboral en curso'
                          : 'Jornada laboral pausada',
                  palette: palette,
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _DateBadge(
                    palette: palette,
                    dateTime: _referenceDate,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_status != SessionStatus.idle) ...[
                            Text(
                              'Dedicación proyecto',
                              style: TextStyle(
                                color: palette.headerColor.withOpacity(0.86),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _ProjectSelector(
                              projects: _projects,
                              selected: _selectedProject,
                              palette: palette,
                              onChanged: (value) => setState(() {
                                if (value != null) {
                                  _selectedProject = value;
                                }
                              }),
                            ),
                            const SizedBox(height: 22),
                          ],
                          _SessionActionCard(
                            status: _status,
                            palette: palette,
                            elapsed: _elapsed,
                            onStart: _startSession,
                            onPause: _pauseSession,
                            onResume: _resumeSession,
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: palette.secondaryButtonColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _finishSession,
                              child: const Text('Finalizar jornada'),
                            ),
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SessionPalette {
  const SessionPalette({
    required this.backgroundColor,
    required this.headerColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.primaryButtonColor,
    required this.secondaryButtonColor,
    required this.elapsedPanelColor,
    required this.elapsedTextColor,
    required this.centralGradient,
    required this.centralIconColor,
  });

  final Color backgroundColor;
  final Color headerColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color primaryButtonColor;
  final Color secondaryButtonColor;
  final Color elapsedPanelColor;
  final Color elapsedTextColor;
  final Gradient centralGradient;
  final Color centralIconColor;

  static SessionPalette fromStatus(SessionStatus status) {
    switch (status) {
      case SessionStatus.idle:
        return SessionPalette(
          backgroundColor: AppColors.idleBackground,
          headerColor: AppColors.primaryDark,
          badgeColor: AppColors.primaryDark,
          badgeTextColor: Colors.white,
          primaryButtonColor: AppColors.primaryDark,
          secondaryButtonColor: AppColors.primaryDark,
          elapsedPanelColor: AppColors.primaryDark,
          elapsedTextColor: Colors.white,
          centralGradient: const LinearGradient(
            colors: [AppColors.primaryDark, Color(0xFF0F3F72)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          centralIconColor: Colors.white,
        );
      case SessionStatus.running:
        return SessionPalette(
          backgroundColor: AppColors.runningBackground,
          headerColor: AppColors.primaryDark,
          badgeColor: AppColors.primaryDark,
          badgeTextColor: Colors.white,
          primaryButtonColor: AppColors.accentPause,
          secondaryButtonColor: AppColors.primaryDark,
          elapsedPanelColor: AppColors.primaryDark,
          elapsedTextColor: Colors.white,
          centralGradient: const LinearGradient(
            colors: [AppColors.accentBlue, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          centralIconColor: Colors.white,
        );
      case SessionStatus.paused:
        return SessionPalette(
          backgroundColor: AppColors.pausedBackground,
          headerColor: const Color(0xFF4C4C4C),
          badgeColor: const Color(0xFF4C4C4C),
          badgeTextColor: Colors.white,
          primaryButtonColor: const Color(0xFF4C4C4C),
          secondaryButtonColor: const Color(0xFF4C4C4C),
          elapsedPanelColor: const Color(0xFF233347),
          elapsedTextColor: Colors.white,
          centralGradient: const LinearGradient(
            colors: [Color(0xFF91C7D6), Color(0xFF3788A3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          centralIconColor: Colors.white,
        );
    }
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.title,
    required this.palette,
  });

  final String title;
  final SessionPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: palette.headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({
    required this.palette,
    required this.dateTime,
  });

  final SessionPalette palette;
  final DateTime dateTime;

  String get _formattedDate {
    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(dateTime.day)}/${twoDigits(dateTime.month)}/${dateTime.year} ${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: palette.badgeColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: palette.badgeColor.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _formattedDate,
          style: TextStyle(
            color: palette.badgeTextColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProjectSelector extends StatelessWidget {
  const _ProjectSelector({
    required this.projects,
    required this.selected,
    required this.palette,
    required this.onChanged,
  });

  final List<String> projects;
  final String selected;
  final SessionPalette palette;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(18),
          style: TextStyle(
            color: palette.headerColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          onChanged: onChanged,
          items: projects
              .map(
                (project) => DropdownMenuItem<String>(
                  value: project,
                  child: Text(project),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _SessionActionCard extends StatelessWidget {
  const _SessionActionCard({
    required this.status,
    required this.palette,
    required this.elapsed,
    required this.onStart,
    required this.onPause,
    required this.onResume,
  });

  final SessionStatus status;
  final SessionPalette palette;
  final Duration elapsed;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            status == SessionStatus.idle
                ? '¡Bienvenid@!'
                : status == SessionStatus.running
                    ? 'Jornada en marcha'
                    : 'Jornada en pausa',
            style: TextStyle(
              color: palette.headerColor.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          _SessionActionButton(
            status: status,
            palette: palette,
            onPressed: () {
              if (status == SessionStatus.idle) {
                onStart();
              } else if (status == SessionStatus.running) {
                onPause();
              } else {
                onResume();
              }
            },
          ),
          const SizedBox(height: 14),
          Text(
            status == SessionStatus.idle
                ? 'Iniciar jornada laboral'
                : status == SessionStatus.running
                    ? 'Pausar jornada laboral'
                    : 'Reanudar jornada laboral',
            style: TextStyle(
              color: palette.headerColor.withOpacity(0.85),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 26),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: palette.elapsedPanelColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'TIEMPO TRANSCURRIDO',
                  style: TextStyle(
                    color: palette.elapsedTextColor.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatDuration(elapsed),
                  style: TextStyle(
                    color: palette.elapsedTextColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '${hours}h:${minutes}m';
  }
}

class _SessionActionButton extends StatelessWidget {
  const _SessionActionButton({
    required this.status,
    required this.palette,
    required this.onPressed,
  });

  final SessionStatus status;
  final SessionPalette palette;
  final VoidCallback onPressed;

  IconData get _icon {
    switch (status) {
      case SessionStatus.idle:
        return Icons.play_arrow_rounded;
      case SessionStatus.running:
        return Icons.pause_rounded;
      case SessionStatus.paused:
        return Icons.play_arrow_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.65), width: 12),
              color: Colors.transparent,
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: palette.centralGradient,
              boxShadow: [
                BoxShadow(
                  color: palette.primaryButtonColor.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox(
                  width: 124,
                  height: 124,
                  child: Icon(
                    _icon,
                    size: status == SessionStatus.running ? 60 : 68,
                    color: palette.centralIconColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CirclesDecoration extends StatelessWidget {
  const _CirclesDecoration({
    required this.color,
    required this.innerStrokeColor,
    required this.size,
  });

  final Color color;
  final Color innerStrokeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: innerStrokeColor, width: size * 0.04),
        ),
      ),
    );
  }
}
