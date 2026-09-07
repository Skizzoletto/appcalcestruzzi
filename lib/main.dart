import 'package:flutter/material.dart';

void main() {
  runApp(const CalcestruzziApp());
}

// ==========================================
// MODELLO MEZZO E CONFIGURAZIONE GLOBALE
// ==========================================
class MezzoConfig {
  String nome;
  String targa;
  String tipo; // 'ATB' (Betoniera) o 'BTP' (Betonpompa)
  double minorCaricoStandard; // 8 per ATB, 7 per BTP

  MezzoConfig({required this.nome, required this.targa, required this.tipo, required this.minorCaricoStandard});
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

  // Lista mezzi configurabili
  List<MezzoConfig> mezziAzienda = [
    MezzoConfig(nome: 'Iveco Trakker', targa: 'CT728EC', tipo: 'ATB', minorCaricoStandard: 8.0),
    MezzoConfig(nome: 'Betonpompa Principale', targa: 'AB123CD', tipo: 'BTP', minorCaricoStandard: 7.0),
  ];

  Map<int, double> tariffeRadiali = {
    1: 10.90, 2: 12.70, 3: 14.50, 4: 16.30, 5: 18.10,
    6: 19.90, 7: 21.70, 8: 23.50, 9: 25.30, 10: 27.10,
  };

  double tariffaPiazzamentoPompa = 68.0; //[cite: 1]
  double tariffaMqPompa = 6.70;         //[cite: 1]
  double tariffaMinutoSosta = 0.70;     //[cite: 1]

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
      case 'Dark': return ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.grey[900]);
      case 'Semplice': return ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white);
      case 'Elegante': return ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF111111), primaryColor: Colors.amber);
      case 'Militare': return ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF2E332A), primaryColor: const Color(0xFF8A9A86));
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

// ==========================================
// MODELLO DATI PER I VIAGGI (DDT DETTAGLIATO)
// ==========================================
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

// ==========================================
// SCHERMATA 1: DASHBOARD
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _apriMenuAzioni(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              const Text('Seleziona Operazione', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.document_scanner, size: 30),
                title: const Text('Nuovo DDT', style: TextStyle(fontSize: 18)),
                subtitle: const Text('Registra bolla, minor carico e pompaggio'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DdtScreen())).then((_) => setState(() {}));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.local_gas_station, size: 30),
                title: const Text('Nuovo Rifornimento', style: TextStyle(fontSize: 18)),
                subtitle: const Text('Registra scontrino carburante'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RifornimentoScreen())).then((_) => setState(() {}));
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
    double produzioneOggi = listaViaggiGlobali.where((v) => v.dataDdt == '07/09/2026').fold(0.0, (sum, item) => sum + item.importoTotale);
    double produzioneMese = listaViaggiGlobali.fold(0.0, (sum, item) => sum + item.importoTotale);

    return Scaffold(
      appBar: AppBar(
        title: Text(appConfig.nomeAzienda, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OpzioniScreen())).then((_) => setState(() {})),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PRODUZIONE & GESTIONE MEZZI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StoricoViaggiScreen())).then((_) => setState(() {})),
                    child: _buildStatCard('Viaggi Totali', '${listaViaggiGlobali.length}', Icons.local_shipping, subtitle: 'Tocca per storico'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Mc Mese', '${listaViaggiGlobali.fold(0.0, (s, i) => s + i.mcEffettivi).toStringAsFixed(1)} mc', Icons.layers)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Fatturato Oggi', '€${produzioneOggi.toStringAsFixed(2)}', Icons.euro)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Fatturato Mese', '€${produzioneMese.toStringAsFixed(2)}', Icons.trending_up)),
              ],
            ),
            const SizedBox(height: 30),
            const Text('STATO PLAFOND CARBURANTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildFuelBar(appConfig.carta1Nome, appConfig.carta1Spesa, appConfig.carta1Fido, Colors.orangeAccent),
                  const SizedBox(height: 24),
                  _buildFuelBar(appConfig.carta2Nome, appConfig.carta2Spesa, appConfig.carta2Fido, Colors.blueAccent),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _apriMenuAzioni(context),
        icon: const Icon(Icons.add),
        label: const Text('NUOVO', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 28, color: Theme.of(context).primaryColor),
              if (subtitle != null) const Icon(Icons.touch_app, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('€${spesa.toStringAsFixed(0)} / €${fido.toStringAsFixed(0)}', style: TextStyle(color: inAllerta ? Colors.redAccent : Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: percentuale > 1 ? 1 : percentuale, minHeight: 10, color: inAllerta ? Colors.redAccent : baseColor),
      ],
    );
  }
}

// ==========================================
// SCHERMATA 2: STORICO VIAGGI INTERATTIVO
// ==========================================
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
                    title: Text('DDT n. ${v.numeroDdt} - ${v.mezzoInfo}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Data: ${v.dataDdt} | Cantiere: ${v.cantiere}\nMC: ${v.mcEffettivi} | Minor Carico: ${v.minorCarico} mc | Sosta: ${v.minutiSosta} min\nPompaggio: ${v.pompaggioMc} mc | Piazzamenti: ${v.piazzamenti}'),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('€${v.importoTotale.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 15)),
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

// ==========================================
// SCHERMATA 3: INSERIMENTO DDT CON CALCOLO AUTOMATICO
// ==========================================
class DdtScreen extends StatefulWidget {
  const DdtScreen({Key? key}) : super(key: key);

  @override
  State<DdtScreen> createState() => _DdtScreenState();
}

class _DdtScreenState extends State<DdtScreen> {
  final TextEditingController _dataController = TextEditingController(text: '07/09/2026');
  final TextEditingController _numDdtController = TextEditingController();
  final TextEditingController _cantiereController = TextEditingController();
  final TextEditingController _mcController = TextEditingController();
  final TextEditingController _sostaMinutiController = TextEditingController(text: '0');
  final TextEditingController _pompaggioMcController = TextEditingController(text: '0');
  final TextEditingController _piazzamentiController = TextEditingController(text: '0');

  late MezzoConfig _mezzoSelezionato;
  int _radialeSelezionato = 1;
  double _minorCaricoCalcolato = 0.0;

  @override
  void initState() {
    super.initState();
    _mezzoSelezionato = appConfig.mezziAzienda.first;
  }

  void _aggiornaMinorCarico(String val) {
    double mcInseriti = double.tryParse(val) ?? 0.0;
    setState(() {
      if (mcInseriti < _mezzoSelezionato.minorCaricoStandard) {
        _minorCaricoCalcolato = _mezzoSelezionato.minorCaricoStandard - mcInseriti;
      } else {
        _minorCaricoCalcolato = 0.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isBetonpompa = _mezzoSelezionato.tipo == 'BTP';

    return Scaffold(
      appBar: AppBar(title: const Text('NUOVO DDT & SERVIZIO')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _dataController, decoration: const InputDecoration(labelText: 'Data DDT', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _numDdtController, decoration: const InputDecoration(labelText: 'N. DDT', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MezzoConfig>(
              value: _mezzoSelezionato,
              decoration: const InputDecoration(labelText: 'Seleziona Mezzo (Flotta)', border: OutlineInputBorder()),
              items: appConfig.mezziAzienda.map((m) => DropdownMenuItem(
                value: m,
                child: Text('${m.nome} [${m.tipo} - Targa: ${m.targa}]'),
              )).toList(),
              onChanged: (v) {
                setState(() {
                  _mezzoSelezionato = v!;
                  _aggiornaMinorCarico(_mcController.text);
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(controller: _cantiereController, decoration: const InputDecoration(labelText: 'Cantiere / Destinazione', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mcController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Metri Cubi (mc)', border: OutlineInputBorder()),
                    onChanged: _aggiornaMinorCarico,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _radialeSelezionato,
                    decoration: const InputDecoration(labelText: 'Radiale Contratto', border: OutlineInputBorder()),
                    items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((r) => DropdownMenuItem(value: r, child: Text('Radiale $r'))).toList(),
                    onChanged: (v) => setState(() => _radialeSelezionato = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blueGrey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Minor Carico automatico (${_mezzoSelezionato.tipo}): ${_minorCaricoCalcolato.toStringAsFixed(1)} mc (Standard a ${_mezzoSelezionato.minorCaricoStandard} mc)',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
              ),
            ),
            const SizedBox(height: 16),
            TextField(controller: _sostaMinutiController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Sosta (Minuti oltre 60 min franchigia)', border: OutlineInputBorder())),
            if (isBetonpompa) ...[
              const SizedBox(height: 20),
              const Text('DETTAGLI POMPAGGIO (BTP)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: _pompaggioMcController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pompaggio (mc)', border: OutlineInputBorder()))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _piazzamentiController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'N. Piazzamenti', border: OutlineInputBorder()))),
                ],
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                double mc = double.tryParse(_mcController.text) ?? 0.0;
                double minutiSosta = double.tryParse(_sostaMinutiController.text) ?? 0.0;
                double pompaggioMc = double.tryParse(_pompaggioMcController.text) ?? 0.0;
                int piazzamenti = int.tryParse(_piazzamentiController.text) ?? 0;

                // Calcolo importo base radiale (considerando mc effettivi + minor carico riconosciuto)
                double mcRiconosciuti = mc + _minorCaricoCalcolato;
                double tariffaRadiale = appConfig.tariffeRadiali[_radialeSelezionato] ?? 10.90;
                double importoBase = mcRiconosciuti * tariffaRadiale;

                // Sosta (oltre 60 minuti a 0.70 €/min)[cite: 1]
                double importoSosta = minutiSosta > 60 ? (minutiSosta - 60) * appConfig.tariffaMinutoSosta : 0.0;

                // Pompaggio se BTP
                double importoPompaggio = 0.0;
                if (isBetonpompa) {
                  importoPompaggio = (piazzamenti * appConfig.tariffaPiazzamentoPompa) + (pompaggioMc * appConfig.tariffaMqPompa);
                }

                double totaleDdt = importoBase + importoSosta + importoPompaggio;

                listaViaggiGlobali.insert(
                  0,
                  ViaggioModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    dataDdt: _dataController.text,
                    numeroDdt: _numDdtController.text.isEmpty ? 'S/N' : _numDdtController.text,
                    mezzoInfo: '${_mezzoSelezionato.nome} [${_mezzoSelezionato.tipo} - ${_mezzoSelezionato.targa}]',
                    cantiere: _cantiereController.text.isEmpty ? 'Cantiere Standard' : _cantiereController.text,
                    mcEffettivi: mc,
                    minorCarico: _minorCaricoCalcolato,
                    minutiSosta: minutiSosta,
                    pompaggioMc: pompaggioMc,
                    piazzamenti: piazzamenti,
                    importoTotale: totaleDdt,
                  ),
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('DDT Registrato! Totale: €${totaleDdt.toStringAsFixed(2)}')));
              },
              child: const Text('SALVA E CALCOLA RICAVO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SCHERMATA 4: OPZIONI & GESTIONE MEZZI
// ==========================================
class OpzioniScreen extends StatefulWidget {
  const OpzioniScreen({Key? key}) : super(key: key);

  @override
  State<OpzioniScreen> createState() => _OpzioniScreenState();
}

class _OpzioniScreenState extends State<OpzioniScreen> {
  late TextEditingController _nomeAziendaController;
  late TextEditingController _c1NomeController;
  late TextEditingController _c1FidoController;
  late TextEditingController _c2NomeController;
  late TextEditingController _c2FidoController;
  late String _temaSelezionato;

  final List<String> _temiDisponibili = ['Futuristico', 'Dark', 'Semplice', 'Elegante', 'Militare'];

  @override
  void initState() {
    super.initState();
    _nomeAziendaController = TextEditingController(text: appConfig.nomeAzienda);
    _c1NomeController = TextEditingController(text: appConfig.carta1Nome);
    _c1FidoController = TextEditingController(text: appConfig.carta1Fido.toString());
    _c2NomeController = TextEditingController(text: appConfig.carta2Nome);
    _c2FidoController = TextEditingController(text: appConfig.carta2Fido.toString());
    _temaSelezionato = appConfig.temaSelezionato;
  }

  void _aggiungiMezzoDialog() {
    final nomeCtrl = TextEditingController();
    final targaCtrl = TextEditingController();
    String tipoSelezionato = 'ATB';
    double minorCaricoStd = 8.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Nuovo Mezzo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome Mezzo (es. Trakker)')),
            TextField(controller: targaCtrl, decoration: const InputDecoration(labelText: 'Targa')),
            DropdownButtonFormField<String>(
              value: tipoSelezionato,
              decoration: const InputDecoration(labelText: 'Tipo Mezzo'),
              items: const [
                DropdownMenuItem(value: 'ATB', child: Text('ATB (Betoniera - 8mc standard)')),
                DropdownMenuItem(value: 'BTP', child: Text('BTP (Betonpompa - 7mc standard)')),
              ],
              onChanged: (v) {
                tipoSelezionato = v!;
                minorCaricoStd = (tipoSelezionato == 'ATB') ? 8.0 : 7.0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                appConfig.mezziAzienda.add(MezzoConfig(
                  nome: nomeCtrl.text.isEmpty ? 'Mezzo' : nomeCtrl.text,
                  targa: targaCtrl.text.isEmpty ? 'XX000XX' : targaCtrl.text,
                  tipo: tipoSelezionato,
                  minorCaricoStandard: minorCaricoStd,
                ));
              });
              Navigator.pop(context);
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opzioni & Gestione Flotta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('AZIENDA & TEMA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
            const SizedBox(height: 12),
            TextField(controller: _nomeAziendaController, decoration: const InputDecoration(labelText: 'Nome Azienda', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _temaSelezionato,
              decoration: const InputDecoration(labelText: 'Stile Tema', border: OutlineInputBorder()),
              items: _temiDisponibili.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _temaSelezionato = val!),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text('PARCO MEZZI (ATB / BTP)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.greenAccent), onPressed: _aggiungiMezzoDialog),
              ],
            ),
            const SizedBox(height: 8),
            ...appConfig.mezziAzienda.map((m) => Card(
              child: ListTile(
                title: Text('${m.nome} (${m.targa})'),
                subtitle: Text('Tipo: ${m.tipo} | Minor Carico Standard: ${m.minorCaricoStandard} mc'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => appConfig.mezziAzienda.remove(m)),
                ),
              ),
            )),
            const SizedBox(height: 30),
            const Text('CARTE CARBURANTE & FIDI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _c1NomeController, decoration: const InputDecoration(labelText: 'Carta 1', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _c1FidoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fido € 1', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _c2NomeController, decoration: const InputDecoration(labelText: 'Carta 2', border: OutlineInputBorder()))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _c2FidoController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fido € 2', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                appConfig.aggiornaConfig(
                  nuovoNome: _nomeAziendaController.text,
                  nuovoTema: _temaSelezionato,
                  c1Nome: _c1NomeController.text,
                  c1Fido: double.tryParse(_c1FidoController.text) ?? 2000.0,
                  c2Nome: _c2NomeController.text,
                  c2Fido: double.tryParse(_c2FidoController.text)gester() ?? 1500.0,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurazione salvata con successo!')));
              },
              child: const Text('SALVA OPZIONI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SCHERMATA 5: INSERIMENTO RIFORNIMENTO
// ==========================================
class RifornimentoScreen extends StatefulWidget {
  const RifornimentoScreen({Key? key}) : super(key: key);

  @override
  State<RifornimentoScreen> createState() => _RifornimentoScreenState();
}

class _RifornimentoScreenState extends State<RifornimentoScreen> {
  late String _cartaSelezionata;
  final TextEditingController _importoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cartaSelezionata = appConfig.carta1Nome;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NUOVO RIFORNIMENTO')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _cartaSelezionata,
              decoration: const InputDecoration(labelText: 'Carta Carburante', border: OutlineInputBorder()),
              items: [appConfig.carta1Nome, appConfig.carta2Nome].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _cartaSelezionata = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _importoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Importo Spesa (€)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                double importo = double.tryParse(_importoController.text) ?? 0.0;
                if (_cartaSelezionata == appConfig.carta1Nome) {
                  appConfig.carta1Spesa += importo;
                } else {
                  appConfig.carta2Spesa += importo;
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Spesa carburante registrata!')));
              },
              child: const Text('REGISTRA SPESA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
