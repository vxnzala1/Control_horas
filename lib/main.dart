import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'data/app_database.dart';
import 'models/punch_record.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0A75BC);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control de Horas',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1D29),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4B4E65),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E5ED)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E5ED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.4),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    final username = _userController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa usuario y clave.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AppDatabase.instance.authenticate(username, password);
      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales no válidas. Inténtalo de nuevo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      await AppDatabase.instance.recordLogin(user);
      if (!mounted) return;

      _passwordController.clear();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardShell(user: user),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo iniciar sesión: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Control de horas',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Inicia sesión para gestionar tus jornadas de forma sencilla.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Usuario',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF1B1D29),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu usuario',
                    ),
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Clave',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF1B1D29),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu clave',
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _attemptLogin(),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _attemptLogin,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Acceder'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key, required this.user});

  final AppUser user;

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}
class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;
  bool _loadingData = false;
  bool _exporting = false;
  bool _generatingReport = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  List<AppUser> _teamMembers = const [];
  List<LoginEntry> _loginHistory = const [];
  List<PunchRecord> _punches = const [];

  @override
  void initState() {
    super.initState();
    _refreshData();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() => _loadingData = true);
    try {
      final users = await AppDatabase.instance.fetchUsers();
      final logins = await AppDatabase.instance.fetchRecentLogins(limit: 12);
      final punches = await AppDatabase.instance.fetchPunches();
      if (!mounted) return;
      setState(() {
        _teamMembers = users;
        _loginHistory = logins;
        _punches = punches;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingData = false);
      }
    }
  }

  List<PunchRecord> get _filteredPunches {
    if (_searchTerm.isEmpty) {
      return _punches;
    }
    final lower = _searchTerm.toLowerCase();
    return _punches
        .where((record) => record.userName.toLowerCase().contains(lower))
        .toList();
  }

  Map<int, double> get _hoursByUser {
    final summary = <int, double>{};
    for (final record in _punches) {
      final hours = record.workedHours;
      if (hours <= 0) continue;
      summary.update(record.userId, (value) => value + hours,
          ifAbsent: () => hours);
    }
    return summary;
  }

  Future<void> _handleExport() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      if (kIsWeb) {
        throw const UnsupportedError('Exportar en web no está disponible.');
      }

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = p.join(directory.path, 'fichajes_$timestamp.csv');
      final formatter = DateFormat('yyyy-MM-dd HH:mm');
      final buffer = StringBuffer()
        ..writeln('Colaborador,Entrada,Salida,Estado');
      for (final record in _punches) {
        final entry = formatter.format(record.entryTime);
        final exit =
            record.exitTime != null ? formatter.format(record.exitTime!) : '';
        buffer.writeln(
          '${record.userName},$entry,$exit,${record.status}',
        );
      }
      final file = File(filePath);
      await file.writeAsString(buffer.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichajes exportados en $filePath')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo exportar: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _exporting = false);
      }
    }
  }

  Future<void> _handleGenerateReport() async {
    if (_generatingReport) return;
    setState(() => _generatingReport = true);
    try {
      final totalHours = _punches.fold<double>(
        0,
        (value, record) => value + record.workedHours,
      );
      final pending = _punches.where((record) => record.exitTime == null).length;
      final activeTeam =
          _teamMembers.where((member) => member.status == 'Activo').length;

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Reporte generado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReportRow(
                  label: 'Total de fichajes',
                  value: _punches.length.toString(),
                ),
                _ReportRow(
                  label: 'Horas registradas',
                  value: '${totalHours.toStringAsFixed(1)} h',
                ),
                _ReportRow(
                  label: 'Pendientes de salida',
                  value: pending.toString(),
                ),
                _ReportRow(
                  label: 'Colaboradores activos',
                  value: activeTeam.toString(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _generatingReport = false);
      }
    }
  }

  Future<void> _handleCreatePunch() async {
    if (!widget.user.canManageFichajes) {
      return;
    }
    if (_teamMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay colaboradores cargados.')),
      );
      return;
    }

    final result = await showDialog<PunchRecord>(
      context: context,
      builder: (context) => _NewPunchDialog(teamMembers: _teamMembers),
    );

    if (result != null) {
      try {
        final created = await AppDatabase.instance.createPunch(
          userId: result.userId,
          userName: result.userName,
          entryTime: result.entryTime,
          exitTime: result.exitTime,
          status: result.status,
        );
        if (!mounted) return;
        setState(() {
          final updated = [created, ..._punches]
            ..sort((a, b) => b.entryTime.compareTo(a.entryTime));
          _punches = updated;
        });
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo registrar el fichaje: $error')),
        );
        return;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fichaje añadido para ${result.userName}'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 240,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A0B0D1A),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control Horas',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF0A75BC),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hola, ${widget.user.displayName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4B4E65),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F3FB),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Rol: ${_roleLabel(widget.user.role)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A75BC),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        _DashboardDestination(
                          icon: Icons.dashboard_outlined,
                          label: 'Resumen',
                          selected: _selectedIndex == 0,
                          onTap: () => setState(() => _selectedIndex = 0),
                        ),
                        _DashboardDestination(
                          icon: Icons.access_time,
                          label: 'Fichajes',
                          selected: _selectedIndex == 1,
                          onTap: () => setState(() => _selectedIndex = 1),
                        ),
                        _DashboardDestination(
                          icon: Icons.people_outline,
                          label: 'Equipo',
                          selected: _selectedIndex == 2,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                        _DashboardDestination(
                          icon: Icons.bar_chart_outlined,
                          label: 'Reportes',
                          selected: _selectedIndex == 3,
                          onTap: () => setState(() => _selectedIndex = 3),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: FilledButton.tonalIcon(
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: [
                  _ResumenView(
                    key: const ValueKey('resumen'),
                    user: widget.user,
                    punches: _punches,
                    teamMembers: _teamMembers,
                    loginHistory: _loginHistory,
                    onExport: widget.user.canExport ? _handleExport : null,
                    isExporting: _exporting,
                    isLoading: _loadingData,
                  ),
                  _FichajesView(
                    key: const ValueKey('fichajes'),
                    punches: _filteredPunches,
                    searchController: _searchController,
                    onCreatePunch:
                        widget.user.canManageFichajes ? _handleCreatePunch : null,
                    onExport: widget.user.canExport ? _handleExport : null,
                    canManage: widget.user.canManageFichajes,
                    canExport: widget.user.canExport,
                    isExporting: _exporting,
                  ),
                  _EquipoView(
                    key: const ValueKey('equipo'),
                    teamMembers: _teamMembers,
                    hoursWorked: _hoursByUser,
                    isLoading: _loadingData,
                  ),
                  _ReportesView(
                    key: const ValueKey('reportes'),
                    canGenerateReports: widget.user.canGenerateReports,
                    onGenerateReport: widget.user.canGenerateReports
                        ? _handleGenerateReport
                        : null,
                    isGenerating: _generatingReport,
                  ),
                ][_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _DashboardDestination extends StatelessWidget {
  const _DashboardDestination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE8F3FB) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    selected ? const Color(0xFF0A75BC) : const Color(0xFF4B4E65),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? const Color(0xFF0A75BC)
                      : const Color(0xFF4B4E65),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResumenView extends StatelessWidget {
  const _ResumenView({
    super.key,
    required this.user,
    required this.punches,
    required this.teamMembers,
    required this.loginHistory,
    required this.onExport,
    required this.isExporting,
    required this.isLoading,
  });

  final AppUser user;
  final List<PunchRecord> punches;
  final List<AppUser> teamMembers;
  final List<LoginEntry> loginHistory;
  final VoidCallback? onExport;
  final bool isExporting;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalHours = punches.fold<double>(
      0,
      (value, record) => value + record.workedHours,
    );
    final pending = punches.where((record) => record.exitTime == null).length;
    final activeTeam =
        teamMembers.where((member) => member.status == 'Activo').length;

    return Container(
      color: const Color(0xFFF5F6FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de jornada',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Visión general de los fichajes y actividad reciente.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _SummaryCard(
                  title: 'Horas trabajadas',
                  value: '${totalHours.toStringAsFixed(1)} h',
                  subtitle: 'Meta diaria: 8h',
                  icon: Icons.schedule,
                ),
                _SummaryCard(
                  title: 'Fichajes pendientes',
                  value: '$pending',
                  subtitle: 'Entradas sin salida registrada',
                  icon: Icons.pending_actions,
                ),
                _SummaryCard(
                  title: 'Equipo activo',
                  value: '$activeTeam',
                  subtitle: 'Colaboradores disponibles',
                  icon: Icons.groups,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140B0D1A),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registro de hoy',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1B1D29),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Listado de entradas y salidas del equipo.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF4B4E65),
                              ),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: (onExport != null && !isExporting)
                              ? onExport
                              : null,
                          icon: isExporting
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.file_download_outlined),
                          label: Text(isExporting ? 'Exportando…' : 'Exportar'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _FichajesTable(punches: punches),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140B0D1A),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Actividad de inicio de sesión',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1B1D29),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Actualizar',
                          onPressed: isLoading
                              ? null
                              : () =>
                                  context.findAncestorStateOfType<_DashboardShellState>()?._refreshData(),
                          icon: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (loginHistory.isEmpty)
                      Text(
                        isLoading
                            ? 'Cargando actividad…'
                            : 'No hay inicios registrados recientemente.',
                        style: theme.textTheme.bodyMedium,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final entry = loginHistory[index];
                          final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                              .format(entry.loggedAt);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              entry.displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1B1D29),
                              ),
                            ),
                            subtitle: Text(
                              'Rol: ${_roleLabel(entry.role)} · $formattedDate',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF4B4E65),
                              ),
                            ),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFE8F3FB),
                              child: Text(
                                entry.displayName.substring(0, 1),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFF0A75BC),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(),
                        itemCount: loginHistory.length,
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
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B0D1A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE8F3FB),
            child: Icon(icon, color: const Color(0xFF0A75BC)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF4B4E65),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B1D29),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7E8095),
                ),
          ),
        ],
      ),
    );
  }
}

class _FichajesTable extends StatelessWidget {
  const _FichajesTable({required this.punches});

  final List<PunchRecord> punches;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF1B1D29),
          fontWeight: FontWeight.w500,
        );
    return DataTable(
      columns: const [
        DataColumn(label: Text('Colaborador')),
        DataColumn(label: Text('Entrada')),
        DataColumn(label: Text('Salida')),
        DataColumn(label: Text('Estado')),
      ],
      rows: punches
          .map(
            (record) => DataRow(
              cells: [
                DataCell(Text(record.userName, style: textStyle)),
                DataCell(Text(record.formattedEntry, style: textStyle)),
                DataCell(Text(record.formattedExit, style: textStyle)),
                DataCell(_StatusBadge(status: record.status)),
              ],
            ),
          )
          .toList(),
      headingTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4B4E65),
          ),
      dataRowColor: MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.hovered)
            ? const Color(0xFFF2F7FB)
            : Colors.white,
      ),
      dataRowHeight: 64,
      headingRowColor:
          MaterialStateProperty.all(const Color(0xFFF0F3F8)),
      dividerThickness: 0,
      horizontalMargin: 24,
      columnSpacing: 56,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  Color _backgroundColor() {
    switch (status) {
      case 'Activo':
        return const Color(0xFFE6F6EC);
      case 'En pausa':
        return const Color(0xFFFFF4E6);
      case 'Retraso':
        return const Color(0xFFFFE6E6);
      case 'Completo':
        return const Color(0xFFE6F0FF);
      case 'Remoto':
        return const Color(0xFFE4F2FF);
      default:
        return const Color(0xFFE3E5ED);
    }
  }

  Color _textColor() {
    switch (status) {
      case 'Activo':
        return const Color(0xFF1C7C44);
      case 'En pausa':
        return const Color(0xFF9A6200);
      case 'Retraso':
        return const Color(0xFFB3261E);
      case 'Completo':
        return const Color(0xFF0A55BC);
      case 'Remoto':
        return const Color(0xFF0A75BC);
      default:
        return const Color(0xFF4B4E65);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _backgroundColor(),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _textColor(),
            ),
      ),
    );
  }
}
class _FichajesView extends StatelessWidget {
  const _FichajesView({
    super.key,
    required this.punches,
    required this.searchController,
    required this.onCreatePunch,
    required this.onExport,
    required this.canManage,
    required this.canExport,
    required this.isExporting,
  });

  final List<PunchRecord> punches;
  final TextEditingController searchController;
  final VoidCallback? onCreatePunch;
  final VoidCallback? onExport;
  final bool canManage;
  final bool canExport;
  final bool isExporting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fichajes', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Gestiona entradas, salidas y pausas del personal.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140B0D1A),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Buscar colaborador',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: canManage ? onCreatePunch : null,
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo fichaje'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed:
                            (canExport && !isExporting) ? onExport : null,
                        icon: isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.file_download_outlined),
                        label: Text(isExporting ? 'Exportando…' : 'Exportar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (punches.isEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'No hay registros que coincidan con la búsqueda.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    )
                  else
                    _FichajesTable(punches: punches),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipoView extends StatelessWidget {
  const _EquipoView({
    super.key,
    required this.teamMembers,
    required this.hoursWorked,
    required this.isLoading,
  });

  final List<AppUser> teamMembers;
  final Map<int, double> hoursWorked;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Equipo', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Lista de colaboradores, roles y estado laboral.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (teamMembers.isEmpty)
              Text(
                'No hay colaboradores registrados en la base de datos.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: teamMembers
                    .map(
                      (member) => _TeamCard(
                        user: member,
                        workedHours:
                            hoursWorked[member.id] ?? member.monthlyHours.toDouble(),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.user, required this.workedHours});

  final AppUser user;
  final double workedHours;

  Color _statusColor() {
    switch (user.status) {
      case 'Activo':
        return const Color(0xFF1C7C44);
      case 'En pausa':
        return const Color(0xFF9A6200);
      case 'Vacaciones':
        return const Color(0xFF0A75BC);
      case 'Remoto':
        return const Color(0xFF0A55BC);
      default:
        return const Color(0xFF4B4E65);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hoursLabel = workedHours % 1 == 0
        ? workedHours.toStringAsFixed(0)
        : workedHours.toStringAsFixed(1);
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140B0D1A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE8F3FB),
            child: Text(
              user.displayName.substring(0, 1),
              style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF0A75BC),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B1D29),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            _roleLabel(user.role),
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B4E65),
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF7E8095)),
              const SizedBox(width: 8),
              Text(
                '$hoursLabel h registradas',
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1D29),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _statusColor().withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.status,
              style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _statusColor(),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ReportesView extends StatelessWidget {
  const _ReportesView({
    super.key,
    required this.canGenerateReports,
    required this.onGenerateReport,
    required this.isGenerating,
  });

  final bool canGenerateReports;
  final VoidCallback? onGenerateReport;
  final bool isGenerating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reportes', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Genera informes personalizados de jornadas y ausencias.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140B0D1A),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _ReportCard(
                        title: 'Resumen mensual',
                        description:
                            'Comparativa de horas trabajadas vs. planificadas.',
                        icon: Icons.calendar_month,
                      ),
                      _ReportCard(
                        title: 'Incidencias',
                        description:
                            'Listado de retrasos, ausencias y fichajes pendientes.',
                        icon: Icons.report_problem_outlined,
                      ),
                      _ReportCard(
                        title: 'Productividad',
                        description:
                            'Horas invertidas por proyecto y por colaborador.',
                        icon: Icons.stacked_line_chart,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  (canGenerateReports && !isGenerating) ? onGenerateReport : null,
              icon: isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_present_outlined),
              label: Text(isGenerating ? 'Generando…' : 'Generar reporte'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
            if (!canGenerateReports)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Solo administradores y responsables pueden generar reportes.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9A6200),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE8F3FB),
            child: Icon(icon, color: const Color(0xFF0A75BC)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B1D29),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B4E65),
                ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
class _NewPunchDialog extends StatefulWidget {
  const _NewPunchDialog({required this.teamMembers});

  final List<AppUser> teamMembers;

  @override
  State<_NewPunchDialog> createState() => _NewPunchDialogState();
}

class _NewPunchDialogState extends State<_NewPunchDialog> {
  late int? _selectedUserId =
      widget.teamMembers.isNotEmpty ? widget.teamMembers.first.id : null;
  TimeOfDay? _entryTime = TimeOfDay.now();
  TimeOfDay? _exitTime;
  String _status = 'Activo';
  String? _error;

  List<String> get _statuses =>
      const ['Activo', 'En pausa', 'Completo', 'Retraso'];

  Future<void> _pickTime({required bool isEntry}) async {
    final initialTime = isEntry
        ? (_entryTime ?? TimeOfDay.now())
        : (_exitTime ?? TimeOfDay.now());
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isEntry) {
          _entryTime = picked;
        } else {
          _exitTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) {
      return '--:--';
    }
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Registrar fichaje'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _selectedUserId,
              decoration: const InputDecoration(labelText: 'Colaborador'),
              items: widget.teamMembers
                  .map(
                    (member) => DropdownMenuItem<int>(
                      value: member.id,
                      child: Text(member.displayName),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedUserId = value),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isEntry: true),
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: Text('Entrada ${_formatTime(_entryTime)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(isEntry: false),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: Text('Salida ${_formatTime(_exitTime)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: _statuses
                  .map(
                    (status) => DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? 'Activo'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_selectedUserId == null || _entryTime == null) {
              setState(() =>
                  _error = 'Selecciona colaborador y hora de entrada.');
              return;
            }
            if (_exitTime != null) {
              final entryMinutes = _entryTime!.hour * 60 + _entryTime!.minute;
              final exitMinutes = _exitTime!.hour * 60 + _exitTime!.minute;
              if (exitMinutes <= entryMinutes) {
                setState(() => _error =
                    'La hora de salida debe ser posterior a la entrada.');
                return;
              }
            }
            final user = widget.teamMembers
                .firstWhere((member) => member.id == _selectedUserId);
            final now = DateTime.now();
            final entryDate = DateTime(
              now.year,
              now.month,
              now.day,
              _entryTime!.hour,
              _entryTime!.minute,
            );
            DateTime? exitDate;
            if (_exitTime != null) {
              exitDate = DateTime(
                now.year,
                now.month,
                now.day,
                _exitTime!.hour,
                _exitTime!.minute,
              );
            }

            setState(() => _error = null);
            Navigator.of(context).pop(
              PunchRecord(
                userId: user.id,
                userName: user.displayName,
                entryTime: entryDate,
                exitTime: exitDate,
                status: _status,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

String _roleLabel(String role) {
  switch (role) {
    case 'admin':
      return 'Administrador';
    case 'manager':
      return 'Responsable';
    case 'empleado':
      return 'Empleado';
    default:
      return role;
  }
}
