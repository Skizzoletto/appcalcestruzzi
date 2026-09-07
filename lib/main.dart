
import 'package:flutter/material.dart';

void main() {
  runApp(const CalcestruzziApp());
}

class MezzoConfig {
  String nome;
  String targa;
  String tipo;
  double minorCaricoStandard;

  MezzoConfig({
    required this.nome,
    required this.targa,
    required this.tipo,
    required this.minorCaricoStandard,
  });
}

class AppConfig with ChangeNotifier {
  String nomeAzienda = "CALCESTRUZZI OGLIASTRA S.R.L.";
  String temaSelezionato = "Futuristico";

  String carta1Nome = "Cartissima Q8";
  double carta1Fido = 2000.0;
  double carta1Spesa = 1750.0;

  String carta2Nome = "Radius";
  double carta2Fido = 1500.0;
  double carta2Spesa = 600.0;

  List<MezzoConfig> mezziAzienda = [
    MezzoConfig(nome: 'Iveco Trakker', targa: 'CT728EC', tipo: 'ATB', minorCaricoStandard: 8.0),
    MezzoConfig(nome: 'Betonpompa Principale', targa: 'AB123CD', tipo: 'BTP', minorCaricoStandard: 7.0),
  ];

  Map<int, double> tariffeRadiali = {
    1: 10.90, 2: 12.70, 3: 14.50, 4: 16.30, 5: 18.10,
    6: 19.90, 7: 21.70, 8: 23.50, 9: 25.30, 10: 27.10,
  };

  double tariffaPiazzamentoPompa = 68.0;
  double tariffaMqPompa = 6.70;
  double tariffaMinutoSosta = 0.70;

  void aggiornaConfig({
    required String nuovoNome,
    required String nuovoTema,
    required String c1Nome,
    required double c1Fido,
    required String c2Nome,
    required double c2Fido,
  }) {
    nomeAzienda = nuovoNome;
    temaSelezionato = nuovoTema;
    carta1Nome = c1Nome;
    carta1Fido = c1Fido;
    carta2Nome = c2Nome;
    carta2Fido = c2Fido;
    notifyListeners();
  }
}

final appConfig = AppConfig();

class CalcestruzziApp extends StatefulWidget {
  const CalcestruzziApp({Key? key}) : super(key: key);

  @override
  State<CalcestruzziApp> createState() => _CalcestruzziAppState();
}

class _CalcestruzziAppState extends State<CalcestruzziApp> {
  @override
  void initState() {
    super.initState();
    appConfig.addListener(() => setState(() {}));
  }

  ThemeData _getTheme() {
    switch (appConfig.temaSelezionato) {
      case 'Dark':
        return ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.grey[900]);
      case 'Semplice':
        return ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white);
      case 'Elegante':
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF111111),
          primaryColor: Colors.amber,
        );
      case 'Militare':
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF2E332A),
          primaryColor: const Color(0xFF8A9A86),
        );
      case 'Futuristico':
      default:
        return ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF0A0E21),
          primaryColor: Colors.cyanAccent,
          cardColor: const Color(0xFF1D1E33),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appConfig.nomeAzienda,
      debugShowCheckedModeBanner: false,
      theme: _getTheme(),
      home: const DashboardScreen(),
    );
  }
}

class ViaggioModel {
  final String id;
  final String dataDdt;
  final String numeroDdt;
  final String mezzoInfo;
  final String cantiere;
  final double mcEffettivi;
  final double minorCarico;
  final double minutiSosta;
  final double pompaggioMc;
  final int piazzamenti;
  final double importoTotale;

  ViaggioModel({
    required this.id,
    required this.dataDdt,
    required this.numeroDdt,
    required this.mezzoInfo,
    required this.cantiere,
    required this.mcEffettivi,
    required this.minorCarico,
    required this.minutiSosta,
    required this.pompaggioMc,
    required this.piazzamenti,
    required this.importoTotale,
  });
}

List<ViaggioModel> listaViaggiGlobali = [
  ViaggioModel(
    id: '1',
    dataDdt: '07/09/2026',
    numeroDdt: '104/A',
    mezzoInfo: 'Iveco Trakker [ATB - CT728EC]',
    cantiere: 'Macomer',
    mcEffettivi: 6.0,
    minorCarico: 2.0,
    minutiSosta: 15.0,
    pompaggioMc: 0.0,
    piazzamenti: 0,
    importoTotale: 109.00,
  ),
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _apriMenuAzioni(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Seleziona Operazione',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.document_scanner, size: 30),
                title: const Text('Nuovo DDT', style: TextStyle(fontSize: 18)),
                subtitle: const Text('Registra bolla, minor carico e pompaggio'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DdtScreen()),
                  ).then((_) => setState(() {}));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.local_gas_station, size: 30),
                title: const Text('Nuovo Rifornimento', style: TextStyle(fontSize: 18)),
                subtitle: const Text('Registra scontrino carburante'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RifornimentoScreen()),
                  ).then((_) => setState(() {}));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double produzioneOggi = listaViaggiGlobali
        .where((v) => v.dataDdt == '07/09/2026')
        .fold(0.0, (sum, item) => sum + item.importoTotale);

    double produzioneMese =
        listaViaggiGlobali.fold(0.0, (sum, item) => sum + item.importoTotale);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appConfig.nomeAzienda,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OpzioniScreen()),
            ).then((_) => setState(() {})),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PRODUZIONE & GESTIONE MEZZI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoricoViaggiScreen(),
                      ),
                    ).then((_) => setState(() {})),
                    child: _buildStatCard(
                      'Viaggi Totali',
                      '${listaViaggiGlobali.length}',
                      Icons.local_shipping,
                      subtitle: 'Tocca per storico',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Mc Mese',
                    '${listaViaggiGlobali.fold(0.0, (s, i) => s + i.mcEffettivi).toStringAsFixed(1)} mc',
                    Icons.layers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Fatturato Oggi',
                    '€${produzioneOggi.toStringAsFixed(2)}',
                    Icons.euro,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Fatturato Mese',
                    '€${produzioneMese.toStringAsFixed(2)}',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'STATO PLAFOND CARBURANTE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildFuelBar(
                    appConfig.carta1Nome,
                    appConfig.carta1Spesa,
                    appConfig.carta1Fido,
                    Colors.orangeAccent,
                  ),
                  const SizedBox(height: 24),
                  _buildFuelBar(
                    appConfig.carta2Nome,
                    appConfig.carta2Spesa,
                    appConfig.carta2Fido,
                    Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _apriMenuAzioni(context),
        icon: const Icon(Icons.add),
        label: const Text(
          'NUOVO',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon,
      {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).primaryColor),
              if (subtitle != null)
                const Icon(Icons.touch_app, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelBar(String label, double spesa, double fido, Color baseColor) {
    double percentuale = fido > 0 ? spesa / fido : 0;
    bool inAllerta = percentuale > 0.85;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              '€${spesa.toStringAsFixed(0)} / €${fido.toStringAsFixed(0)}',
              style: TextStyle(
                color: inAllerta ? Colors.redAccent : Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentuale > 1 ? 1 : percentuale,
          minHeight: 10,
          color: inAllerta ? Colors.redAccent : baseColor,
        ),
      ],
    );
  }
}

class StoricoViaggiScreen extends StatefulWidget {
  const StoricoViaggiScreen({Key? key}) : super(key: key);

  @override
  State<StoricoViaggiScreen> createState() => _StoricoViaggiScreenState();
}

class _StoricoViaggiScreenState extends State<StoricoViaggiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Storico DDT per Mezzo')),
      body: listaViaggiGlobali.isEmpty
          ? const Center(child: Text('Nessun DDT registrato'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listaViaggiGlobali.length,
              itemBuilder: (context, index) {
                final v = listaViaggiGlobali[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      'DDT n. ${v.numeroDdt} - ${v.mezzoInfo}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Data: ${v.dataDdt} | Cantiere: ${v.cantiere}\n'
                      'MC: ${v.mcEffettivi} | Minor Carico: ${v.minorCarico} mc | Sosta: ${v.minutiSosta} min\n'
                      'Pompaggio: ${v.pompaggioMc} mc | Piazzamenti: ${v.piazzamenti}',
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '€${v.importoTotale.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                            fontSize: 15,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                          onPressed: () => setState(() => listaViaggiGlobali.removeAt(index)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class DdtScreen extends StatefulWidget {
  const DdtScreen({Key? key}) : super(key: key);

  @override
  State<DdtScreen> createState() => _DdtScreenState();
}

class _DdtScreenState extends State<DdtScreen> {
  final TextEditingController _dataController =
      TextEditingController(text: '07/09/2026');
  final TextEditingController _numDdtController = TextEditingController();
  final TextEditingController _cantiereController = TextEditingController();
  final TextEditingController _mcController = TextEditingController();
  final TextEditingController _sostaMinutiController =
      TextEditingController(text: '0');
  final TextEditingController _pompaggioMcController =
      TextEditingController(text: '0');
  final TextEditingController _piazzamentiController =
      TextEditingController(text: '0');

  late MezzoConfig _mezzoSelezionato;
  int _radialeSelezionato = 1;
  double _minorCaricoCalcolato =
