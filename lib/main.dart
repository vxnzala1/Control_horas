import 'package:flutter/material.dart';

void main() {
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

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardShell()),
    );
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
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: const Color(0xFF1B1D29), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu usuario',
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Clave',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: const Color(0xFF1B1D29), fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu clave',
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _goToDashboard(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _goToDashboard,
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
                      child: const Text('Acceder'),
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
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 220,
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
                        Text('Control Horas',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF0A75BC),
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 8),
                        Text(
                          'Panel principal',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF4B4E65),
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
                  const _ResumenView(),
                  const _FichajesView(),
                  const _EquipoView(),
                  const _ReportesView(),
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
  const _ResumenView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('resumen'),
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
              'Visión general de los fichajes y horas trabajadas hoy.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: const [
                _SummaryCard(
                  title: 'Horas trabajadas',
                  value: '6h 15m',
                  subtitle: 'Meta diaria: 8h',
                  icon: Icons.schedule,
                ),
                _SummaryCard(
                  title: 'Fichajes pendientes',
                  value: '2',
                  subtitle: 'Solicitudes por revisar',
                  icon: Icons.pending_actions,
                ),
                _SummaryCard(
                  title: 'Equipo activo',
                  value: '12',
                  subtitle: 'De 15 colaboradores',
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
                          onPressed: () {},
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('Exportar'),
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
                  const _FichajesTable(),
                ],
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
  const _FichajesTable();

  List<DataRow> _buildRows(TextStyle? style) {
    final rows = [
      ['Laura Gómez', '08:00', '12:30', 'Activo'],
      ['Carlos Pérez', '08:15', '—', 'En pausa'],
      ['María López', '07:55', '11:45', 'Completo'],
      ['Luis Ramírez', '09:10', '—', 'Retraso'],
    ];

    return rows
        .map(
          (r) => DataRow(
            cells: [
              DataCell(Text(r[0], style: style)),
              DataCell(Text(r[1], style: style)),
              DataCell(Text(r[2], style: style)),
              DataCell(_StatusBadge(status: r[3])),
            ],
          ),
        )
        .toList();
  }

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
      rows: _buildRows(textStyle),
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
  const _FichajesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('fichajes'),
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
                          decoration: InputDecoration(
                            hintText: 'Buscar colaborador',
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo fichaje'),
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
                  const _FichajesTable(),
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
  const _EquipoView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('equipo'),
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
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: const [
                _TeamCard(
                  name: 'Laura Gómez',
                  role: 'Recursos Humanos',
                  status: 'Activo',
                  hours: '160 h',
                ),
                _TeamCard(
                  name: 'Carlos Pérez',
                  role: 'Soporte técnico',
                  status: 'En pausa',
                  hours: '142 h',
                ),
                _TeamCard(
                  name: 'María López',
                  role: 'Marketing',
                  status: 'Vacaciones',
                  hours: '120 h',
                ),
                _TeamCard(
                  name: 'Luis Ramírez',
                  role: 'Desarrollo',
                  status: 'Activo',
                  hours: '180 h',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({
    required this.name,
    required this.role,
    required this.status,
    required this.hours,
  });

  final String name;
  final String role;
  final String status;
  final String hours;

  Color _statusColor() {
    switch (status) {
      case 'Activo':
        return const Color(0xFF1C7C44);
      case 'En pausa':
        return const Color(0xFF9A6200);
      case 'Vacaciones':
        return const Color(0xFF0A75BC);
      default:
        return const Color(0xFF4B4E65);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              name.substring(0, 1),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF0A75BC),
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B1D29),
                ),
          ),
          const SizedBox(height: 6),
          Text(
            role,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B4E65),
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                hours,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
              status,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
  const _ReportesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('reportes'),
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
                children: [
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: const [
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
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.file_present_outlined),
                    label: const Text('Generar reporte'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
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
