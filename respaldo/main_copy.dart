
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const AlingBalanceApp());
}

const Color backgroundColor = Color(0xFF0B1120);
const Color panelColor = Color(0xFF151F32);
const Color borderColor = Color(0xFF26344A);
const Color accentColor = Color(0xFF27D7B0);
const Color secondaryText = Color(0xFF9BAAC0);

const List<String> serviceTypes = [
  'Alineación sencilla',
  'Balanceo',
  'Alineación doble',
  'Montaje de llantas',
  'Nitrógeno',
  'Rines',
];

const Map<String, Map<String, int>> suggestedPrices = {
  'Alineación sencilla': {
    'Taxi': 15000,
    'Particular': 20000,
    'Camioneta': 30000,
  },
  'Balanceo': {
    'Taxi': 30000,
    'Particular': 30000,
    'Camioneta': 50000,
  },
  'Alineación doble': {
    'Taxi': 40000,
    'Particular': 40000,
    'Camioneta': 50000,
  },
  'Montaje de llantas': {
    'Taxi': 15000,
    'Particular': 15000,
    'Camioneta': 30000,
  },
  'Nitrógeno': {
    'Taxi': 20000,
    'Particular': 20000,
    'Camioneta': 30000,
  },
  'Rines': {
    'Taxi': 50000,
    'Particular': 50000,
    'Camioneta': 50000,
  },
};

String formatMoney(int amount) {
  final value = amount.toString();
  final result = StringBuffer();

  for (int i = 0; i < value.length; i++) {
    if (i > 0 && (value.length - i) % 3 == 0) {
      result.write('.');
    }
    result.write(value[i]);
  }

  return '\$${result.toString()}';
}

class AlingBalanceApp extends StatelessWidget {
  const AlingBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlingBalance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Arial',
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void enterApp() {
    if (userController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu usuario y contraseña.'),
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: panelColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.car_repair_rounded,
                    size: 68,
                    color: accentColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'AlingBalance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gestión inteligente para tu taller',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryText),
                  ),
                  const SizedBox(height: 32),
                  const Text('Usuario'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: userController,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu usuario',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Contraseña'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    onSubmitted: (_) => enterApp(),
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: enterApp,
                    style: FilledButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: backgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Versión de demostración: cualquier usuario y '
                    'contraseña no vacíos permiten entrar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: 12,
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

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  static const String storageKey = 'aling_balance_services_v1';
static const String employeesStorageKey =
    'aling_balance_employees_v1';

final List<Map<String, dynamic>> employees = [];

  int selectedIndex = 0;
  int nextOperationNumber = 5;
  bool isLoading = true;
  String? storageError;

  late SharedPreferences preferences;

  final List<String> sections = [
    'Inicio',
    'Servicios',
    'Empleados',
    'Clientes',
    'Contabilidad',
  ];

  final List<IconData> sectionIcons = [
    Icons.dashboard_rounded,
    Icons.car_repair_rounded,
    Icons.groups_rounded,
    Icons.people_alt_rounded,
    Icons.account_balance_wallet_rounded,
  ];

  final List<Map<String, dynamic>> services = [
    {
      'operation': 1,
      'plate': 'ABC-123',
      'vehicle': 'Chevrolet Spark',
      'vehicleType': 'Particular',
      'service': 'Alineación sencilla',
      'status': 'Terminado',
      'price': 20000,
      'date': DateTime.now().toIso8601String(),
    },
    {
      'operation': 2,
      'plate': 'DEF-456',
      'vehicle': 'Toyota Hilux',
      'vehicleType': 'Camioneta',
      'service': 'Balanceo',
      'status': 'En proceso',
      'price': 50000,
      'date': DateTime.now().toIso8601String(),
    },
    {
      'operation': 3,
      'plate': 'GHI-789',
      'vehicle': 'Renault Logan',
      'vehicleType': 'Particular',
      'service': 'Montaje de llantas',
      'status': 'Terminado',
      'price': 15000,
      'date': DateTime.now().toIso8601String(),
    },
    {
      'operation': 4,
      'plate': 'JKL-321',
      'vehicle': 'Mazda CX-5',
      'vehicleType': 'Camioneta',
      'service': 'Alineación doble',
      'status': 'En proceso',
      'price': 50000,
      'date': DateTime.now().toIso8601String(),
    },
  ];

  @override
  void initState() {
    super.initState();
    loadServices();
  }


Future<void> loadServices() async {
  try {
    preferences = await SharedPreferences.getInstance();

    final savedEmployees =
        preferences.getString(employeesStorageKey);

    if (savedEmployees != null) {
      final decodedEmployees =
          jsonDecode(savedEmployees) as List<dynamic>;

      employees
        ..clear()
        ..addAll(
          decodedEmployees.map(
            (item) => Map<String, dynamic>.from(item as Map),
          ),
        );
    }

    final savedData = preferences.getString(storageKey);

    if (savedData != null) {
      final decoded = jsonDecode(savedData) as List<dynamic>;

      services
        ..clear()
        ..addAll(
          decoded.map(
            (item) {
              final service =
                  Map<String, dynamic>.from(item as Map);

              service['operation'] =
                  (service['operation'] as num).toInt();
              service['price'] =
                  (service['price'] as num).toInt();

              final dateValue = service['date'];

              if (dateValue is DateTime) {
                service['date'] = dateValue.toIso8601String();
              } else if (dateValue is! String) {
                service['date'] = DateTime.now().toIso8601String();
              }

              return service;
            },
          ),
        );
    } else {
      await saveServices();
    }

    updateNextOperationNumber();
  } catch (error) {
    storageError = 'No se pudieron cargar los datos guardados.';
    debugPrint('ERROR AL CARGAR DATOS: $error');
  }

  if (mounted) {
    setState(() {
      isLoading = false;
    });
  }
}


 
Future<void> saveServices() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(services);

    final saved = await prefs.setString(storageKey, data);

    if (!saved) {
      throw Exception('El navegador no confirmó el guardado.');
    }

    debugPrint('AlingBalance: servicios guardados correctamente.');

    if (mounted) {
      setState(() {
        storageError = null;
      });
    }
  } catch (error, stackTrace) {
    debugPrint('ERROR AL GUARDAR SERVICIOS: $error');
    debugPrintStack(stackTrace: stackTrace);

    if (mounted) {
      setState(() {
        storageError = 'Error al guardar los servicios: $error';
      });
    }
  }
}

Future<void> saveEmployees() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(employees);

    final saved = await prefs.setString(
      employeesStorageKey,
      data,
    );

    if (!saved) {
      throw Exception('No se pudo guardar la lista de empleados.');
    }

    if (mounted) {
      setState(() {
        storageError = null;
      });
    }
  } catch (error) {
    debugPrint('ERROR AL GUARDAR EMPLEADOS: $error');

    if (mounted) {
      setState(() {
        storageError = 'Error al guardar los empleados: $error';
      });
    }
  }
}

  void updateNextOperationNumber() {
    var largestNumber = 0;

    for (final service in services) {
      final number = service['operation'] as int;
      if (number > largestNumber) {
        largestNumber = number;
      }
    }

    nextOperationNumber = largestNumber + 1;
  }

  int get totalRevenue {
    return services.fold<int>(
      0,
      (total, item) => total + (item['price'] as int),
    );
  }

  int get inProgress {
    return services
        .where((item) => item['status'] == 'En proceso')
        .length;
  }

  int get completed {
    return services
        .where((item) => item['status'] == 'Terminado')
        .length;
  }

  String get currentDate {
    final now = DateTime.now();

    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }

  Future<void> addService(Map<String, dynamic> service) async {
    service['operation'] = nextOperationNumber++;
    service['date'] = DateTime.now().toIso8601String();

    setState(() {
      services.insert(0, service);
      selectedIndex = 1;
    });

    await saveServices();
  }

  Future<void> showServiceForm() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ServiceFormDialog(
        operationNumber: nextOperationNumber,
      ),
    );

    if (result != null && mounted) {
      await addService(result);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Servicio #${result['operation']} guardado correctamente.',
          ),
        ),
      );
    }
  }

  Future<void> changeServiceStatus(
    Map<String, dynamic> service,
  ) async {
    final currentStatus = service['status'] as String;
    final newStatus =
        currentStatus == 'En proceso' ? 'Terminado' : 'En proceso';

    setState(() {
      service['status'] = newStatus;
    });

    await saveServices();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Operación ${service['operation']}: estado actualizado a '
          '$newStatus.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: accentColor),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 850;

        return Scaffold(
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  backgroundColor: panelColor,
                  indicatorColor: accentColor.withValues(alpha: 0.18),
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => selectedIndex = index);
                  },
                  destinations: [
                    for (int i = 0; i < sections.length; i++)
                      NavigationDestination(
                        icon: Icon(sectionIcons[i]),
                        label: sections[i],
                      ),
                  ],
                ),
          body: Row(
            children: [
              if (desktop) _buildSidebar(),
              Expanded(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(desktop ? 30 : 18),
                        child: selectedIndex == 0
                            ? _buildOverview(desktop)
                            : _buildSection(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 245,
      decoration: const BoxDecoration(
        color: panelColor,
        border: Border(
          right: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 28, 16, 30),
            child: Row(
              children: [
                Icon(
                  Icons.car_repair_rounded,
                  color: accentColor,
                  size: 36,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AlingBalance',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 16, 12),
            child: Text(
              'MENÚ PRINCIPAL',
              style: TextStyle(
                color: secondaryText,
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (int i = 0; i < sections.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 3,
              ),
              child: ListTile(
                selected: selectedIndex == i,
                selectedTileColor: accentColor.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(
                  sectionIcons[i],
                  color: selectedIndex == i ? accentColor : secondaryText,
                ),
                title: Text(
                  sections[i],
                  style: TextStyle(
                    color: selectedIndex == i ? accentColor : Colors.white,
                    fontWeight: selectedIndex == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  setState(() => selectedIndex = i);
                },
              ),
            ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, color: accentColor),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Panel de administrador',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: panelColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              sections[selectedIndex],
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.circle, color: accentColor, size: 9),
          const SizedBox(width: 7),
          const Text(
            'Administrador',
            style: TextStyle(color: secondaryText),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: accentColor.withValues(alpha: 0.16),
            child: const Icon(Icons.person, color: accentColor),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(bool desktop) {
    final cards = [
      {
        'title': 'Servicios registrados',
        'value': '${services.length}',
        'detail': 'Operaciones en el sistema',
        'icon': Icons.car_repair_rounded,
        'color': accentColor,
      },
      {
        'title': 'Valor de servicios',
        'value': formatMoney(totalRevenue),
        'detail': 'Suma de los registros actuales',
        'icon': Icons.payments_outlined,
        'color': const Color(0xFF75A7FF),
      },
      {
        'title': 'En proceso',
        'value': '$inProgress',
        'detail': 'Vehículos pendientes',
        'icon': Icons.pending_actions_rounded,
        'color': const Color(0xFFFFBD69),
      },
      {
        'title': 'Terminados',
        'value': '$completed',
        'detail': 'Servicios finalizados',
        'icon': Icons.task_alt_rounded,
        'color': const Color(0xFFB69CFF),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen del taller',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Controla la operación diaria de tu negocio. $currentDate',
          style: const TextStyle(color: secondaryText),
        ),
        const SizedBox(height: 26),
        GridView.count(
          crossAxisCount: desktop ? 4 : 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: desktop ? 1.08 : 0.91,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final card in cards)
              _MetricCard(
                title: card['title'] as String,
                value: card['value'] as String,
                detail: card['detail'] as String,
                icon: card['icon'] as IconData,
                color: card['color'] as Color,
              ),
          ],
        ),
        const SizedBox(height: 30),
        if (desktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildRecentServices()),
              const SizedBox(width: 18),
              Expanded(flex: 2, child: _buildQuickActions()),
            ],
          )
        else ...[
          _buildQuickActions(),
          const SizedBox(height: 22),
          _buildRecentServices(),
        ],
        const SizedBox(height: 22),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF142D35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: accentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  storageError ??
                      'Los servicios se guardan en este navegador. '
                          'No se sincronizan todavía con otros dispositivos.',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'title': 'Registrar servicio',
        'subtitle': 'Agregar un vehículo al taller',
        'icon': Icons.add_circle_outline,
        'index': 1,
      },
      {
        'title': 'Gestionar empleados',
        'subtitle': 'Consultar el equipo de trabajo',
        'icon': Icons.groups_outlined,
        'index': 2,
      },
      {
        'title': 'Ver contabilidad',
        'subtitle': 'Consultar los valores registrados',
        'icon': Icons.account_balance_wallet_outlined,
        'index': 4,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accesos rápidos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          for (final action in actions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: accentColor,
                ),
              ),
              title: Text(
                action['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                action['subtitle'] as String,
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: secondaryText,
              ),
              onTap: () {
                if (action['index'] == 1) {
                  showServiceForm();
                } else {
                  setState(() {
                    selectedIndex = action['index'] as int;
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentServices() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Servicios recientes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Vehículos registrados en el taller',
            style: TextStyle(color: secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 18),
          if (services.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Todavía no hay servicios registrados.',
                  style: TextStyle(color: secondaryText),
                ),
              ),
            ),
          for (final service in services.take(5))
            _ServiceCard(
              service: service,
              onChangeStatus: () => changeServiceStatus(service),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: showServiceForm,
              icon: const Icon(Icons.add),
              label: const Text('Registrar servicio'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection() {
    final descriptions = [
      '',
      'Registra vehículos, asigna servicios y actualiza su estado.',
      'Organiza el personal y consulta las comisiones por trabajo.',
      'Administra los clientes y sus vehículos registrados.',
      'Consulta los valores de los servicios registrados.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sections[selectedIndex],
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          descriptions[selectedIndex],
          style: const TextStyle(color: secondaryText),
        ),
        const SizedBox(height: 24),
        if (selectedIndex == 1) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '${services.length} operaciones registradas',
                  style: const TextStyle(color: secondaryText),
                ),
              ),
              FilledButton.icon(
                onPressed: showServiceForm,
                icon: const Icon(Icons.add),
                label: const Text('Nuevo servicio'),
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: backgroundColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (services.isEmpty)
            _emptyModule(
              Icons.car_repair_rounded,
              'No hay servicios registrados',
              'Pulsa “Nuevo servicio” para agregar el primero.',
            ),
          for (final service in services)
            _ServiceCard(
              service: service,
              onChangeStatus: () => changeServiceStatus(service),
            ),
        ] else if (selectedIndex == 4) ...[
          GridView.count(
            crossAxisCount:
                MediaQuery.of(context).size.width >= 850 ? 3 : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            children: [
              _MetricCard(
                title: 'Valor registrado',
                value: formatMoney(totalRevenue),
                detail: 'Suma de todos los servicios',
                icon: Icons.payments_outlined,
                color: accentColor,
              ),
              _MetricCard(
                title: 'Servicios en proceso',
                value: '$inProgress',
                detail: 'Pendientes de finalizar',
                icon: Icons.pending_actions,
                color: const Color(0xFFFFBD69),
              ),
              _MetricCard(
                title: 'Comisión estimada (30%)',
                value: formatMoney((totalRevenue * 0.3).round()),
                detail: 'Cálculo ilustrativo',
                icon: Icons.percent_rounded,
                color: const Color(0xFFB69CFF),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Estos valores son estimaciones de los servicios registrados; '
            'no equivalen necesariamente a pagos recibidos.',
            style: TextStyle(color: secondaryText),
          ),
        ] else
          _emptyModule(
            sectionIcons[selectedIndex],
            'Módulo de ${sections[selectedIndex].toLowerCase()}',
            'Esta sección está preparada para construir sus funciones.',
          ),
      ],
    );
  }

  Widget _emptyModule(
    IconData icon,
    String title,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 52, color: accentColor),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: secondaryText),
          ),
        ],
      ),
    );
  }
}

class ServiceFormDialog extends StatefulWidget {
  final int operationNumber;

  const ServiceFormDialog({
    super.key,
    required this.operationNumber,
  });

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final formKey = GlobalKey<FormState>();
  final plateController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final priceController = TextEditingController();

  String vehicleType = 'Particular';
  String selectedService = 'Alineación sencilla';
  String status = 'En proceso';

  @override
  void initState() {
    super.initState();
    updateSuggestedPrice();
  }

  void updateSuggestedPrice() {
    final price =
        suggestedPrices[selectedService]?[vehicleType] ?? 0;
    priceController.text = price.toString();
  }

  @override
  void dispose() {
    plateController.dispose();
    brandController.dispose();
    modelController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void saveService() {
    if (!formKey.currentState!.validate()) return;

    final price = int.tryParse(
      priceController.text
          .replaceAll('.', '')
          .replaceAll(',', '')
          .trim(),
    );

    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un precio válido.'),
        ),
      );
      return;
    }

    final plate = plateController.text.trim().toUpperCase();
    final brand = brandController.text.trim();
    final model = modelController.text.trim();

    Navigator.pop(
      context,
      {
        'operation': widget.operationNumber,
        'plate': plate,
        'vehicle': '$brand $model',
        'vehicleType': vehicleType,
        'service': selectedService,
        'status': status,
        'price': price,
        'date': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: panelColor,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: borderColor),
      ),
      title: const Row(
        children: [
          Icon(Icons.car_repair_rounded, color: accentColor),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Registrar servicio',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        color: accentColor,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('Número de operación'),
                      ),
                      Text(
                        '#${widget.operationNumber}',
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _fieldLabel('Placa del vehículo'),
                TextFormField(
                  controller: plateController,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    hintText: 'Ej. ABC-123',
                    prefixIcon: Icon(Icons.pin_outlined),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la placa del vehículo.';
                    }
                    if (value.trim().length < 5) {
                      return 'Verifica la placa ingresada.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _fieldLabel('Marca'),
                TextFormField(
                  controller: brandController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Ej. Chevrolet',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la marca.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _fieldLabel('Modelo'),
                TextFormField(
                  controller: modelController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Ej. Spark GT',
                    prefixIcon: Icon(Icons.car_rental_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el modelo.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _fieldLabel('Tipo de vehículo'),
                DropdownButtonFormField<String>(
                  initialValue: vehicleType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Particular',
                      child: Text('Particular'),
                    ),
                    DropdownMenuItem(
                      value: 'Taxi',
                      child: Text('Taxi'),
                    ),
                    DropdownMenuItem(
                      value: 'Camioneta',
                      child: Text('Camioneta'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      vehicleType = value;
                      updateSuggestedPrice();
                    });
                  },
                ),
                const SizedBox(height: 16),
                _fieldLabel('Servicio que se realizará'),
                DropdownButtonFormField<String>(
                  initialValue: selectedService,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.build_outlined),
                  ),
                  items: [
                    for (final service in serviceTypes)
                      DropdownMenuItem(
                        value: service,
                        child: Text(service),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedService = value;
                      updateSuggestedPrice();
                    });
                  },
                ),
                const SizedBox(height: 16),
                _fieldLabel('Precio del servicio (COP)'),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Ej. 20000',
                    prefixIcon: Icon(Icons.payments_outlined),
                    helperText: 'Precio sugerido editable.',
                  ),
                  validator: (value) {
                    final price = int.tryParse(
                      (value ?? '')
                          .replaceAll('.', '')
                          .replaceAll(',', '')
                          .trim(),
                    );
                    if (price == null || price < 0) {
                      return 'Ingresa un precio válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _fieldLabel('Estado inicial'),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.pending_actions_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'En proceso',
                      child: Text('En proceso'),
                    ),
                    DropdownMenuItem(
                      value: 'Terminado',
                      child: Text('Terminado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => status = value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: saveService,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar servicio'),
          style: FilledButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: backgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onChangeStatus;

  const _ServiceCard({
    required this.service,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final operation = service['operation'] as int;
    final plate = service['plate'] as String;
    final vehicle = service['vehicle'] as String;
    final vehicleType = service['vehicleType'] as String;
    final serviceName = service['service'] as String;
    final status = service['status'] as String;
    final price = service['price'] as int;
    final date = DateTime.tryParse(
          service['date']?.toString() ?? '',
        ) ??
        DateTime.now();

    final dateText =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car_filled_outlined,
                  color: accentColor,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle,
                      style: const TextStyle(color: secondaryText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$vehicleType · $serviceName',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatMoney(price),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '#$operation',
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 24, color: borderColor),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatusTag(status: status),
                    const SizedBox(height: 7),
                    Text(
                      'Fecha: $dateText',
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onChangeStatus,
                icon: Icon(
                  status == 'En proceso'
                      ? Icons.check_circle_outline
                      : Icons.replay_rounded,
                  size: 18,
                ),
                label: Text(
                  status == 'En proceso' ? 'Finalizar' : 'Reabrir',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;

  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    final finished = status == 'Terminado';
    final color = finished
        ? accentColor
        : const Color(0xFFFFBD69);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
