import 'dart:io';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const CalcestruzziApp());
}

class MezzoConfig {
  String nome;
  String targa;
  String tipo; // 'ATB' (Betoniera) o 'BTP' (Betonpompa)
  double minorCaricoStandard;
  String anno;
  String stato;
  String note;

  MezzoConfig({required this.nome, required this.targa, required this.tipo, required this.minorCaricoStandard, this.anno = '—', this.stato = 'ATTIVO', this.note = ''});
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
    MezzoConfig(nome: 'Iveco Trakker', targa: 'CT728EC', tipo: 'ATB', minorCaricoStandard: 8.0, anno: '2019'),
    MezzoConfig(nome: 'DK727DZ', targa: 'DK727DZ', tipo: 'ATB', minorCaricoStandard: 8.0, anno: '2018'),
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


class DipendenteModel {
  String nome;
  String ruolo;
  String categoria;
  String patente;
  String dataPatente;
  String telefono;
  String email;
  String stato;
  List<String> mezziAssegnati;
  bool assegnazioneDaVerificare;

  DipendenteModel({
    required this.nome,
    required this.ruolo,
    required this.categoria,
    required this.patente,
    required this.dataPatente,
    required this.telefono,
    required this.email,
    required this.stato,
    this.mezziAssegnati = const [],
    this.assegnazioneDaVerificare = false,
  });
}

// Anagrafica iniziale ricavata dal DVR 2026.
// Le assegnazioni ISM discordanti rispetto all'anagrafica principale
// vengono marcate per verifica e non vengono considerate definitive.
final List<DipendenteModel> listaDipendenti = [
  DipendenteModel(
    nome: 'Leoni Angelo',
    ruolo: 'Amministratore',
    categoria: 'Direzione',
    patente: 'CA550347H',
    dataPatente: '14/09/2015',
    telefono: '3270457439',
    email: 'skizzo_83@msn.com',
    stato: 'ATTIVO',
  ),
  DipendenteModel(
    nome: 'Leoni Francesco',
    ruolo: 'Socio / RSPP',
    categoria: 'Direzione',
    patente: 'U1F8665F9C',
    dataPatente: '24/04/2013',
    telefono: '3334923993',
    email: 'Dittaleonifrancesco@gmail.com',
    stato: 'ATTIVO',
  ),
  DipendenteModel(
    nome: 'Vacca Valentino',
    ruolo: 'Conducente ATB',
    categoria: 'Autisti',
    patente: '—',
    dataPatente: '18/10/2022',
    telefono: '3393270234',
    email: 'valevacca66@hotmail.it',
    stato: 'ATTIVO',
  ),
  DipendenteModel(
    nome: 'Melas Francesco',
    ruolo: 'Conducente ATB',
    categoria: 'Autisti',
    patente: '—',
    dataPatente: '24/01/2024',
    telefono: '3496522058',
    email: 'francescomelas240979@gmail.com',
    stato: 'ATTIVO',
  ),
  DipendenteModel(nome: 'Serra Andrea', ruolo: 'Collaboratore Esterno', categoria: 'Collaboratori', patente: '—', dataPatente: '—', telefono: '—', email: '—', stato: 'ATTIVO'),
  DipendenteModel(nome: 'Mariatina Crispu', ruolo: 'Consulente del Lavoro', categoria: 'Consulenti', patente: '—', dataPatente: '—', telefono: '—', email: '—', stato: 'ATTIVO'),
  DipendenteModel(nome: 'Casa Artigiani Cagliari', ruolo: 'Commercialista', categoria: 'Consulenti', patente: '—', dataPatente: '—', telefono: '—', email: '—', stato: 'ATTIVO'),
  DipendenteModel(nome: 'Dott. Sette', ruolo: 'Medico Competente', categoria: 'Consulenti', patente: '—', dataPatente: '—', telefono: '—', email: '—', stato: 'ATTIVO'),
  DipendenteModel(nome: 'Maria Rita Caddeo', ruolo: 'Assistenza Sanitaria', categoria: 'Consulenti', patente: '—', dataPatente: '—', telefono: '—', email: '—', stato: 'ATTIVO'),
  DipendenteModel(nome: '[Pos. disponibile]', ruolo: '[Ruolo aperto]', categoria: 'Posizioni aperte', patente: '—', dataPatente: '—', telefono: '—', email: '—', stato: 'VUOTO'),
];

final Map<String, List<String>> assegnazioniIsmDaVerificare = {
  'DK727DZ': ['Rossi Marco', 'Bianchi Antonio'],
  'CT728EC': ['Rossi Marco', 'Verdi Paolo'],
};

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
                leading: const Icon(Icons.groups, size: 30),
                title: const Text('Azienda & Personale', style: TextStyle(fontSize: 18)),
                subtitle: const Text('Organigramma, dipendenti e assegnazioni mezzi'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AziendaScreen()));
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
            tooltip: 'Azienda e personale',
            icon: const Icon(Icons.groups),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AziendaScreen())),
          ),
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
      class AziendaScreen extends StatefulWidget {
  const AziendaScreen({Key? key}) : super(key: key);

  @override
  State<AziendaScreen> createState() => _AziendaScreenState();
}

class _AziendaScreenState extends State<AziendaScreen> {
  String _filtro = 'Tutti';
  String _cerca = '';

  List<DipendenteModel> get _visibili {
    return listaDipendenti.where((d) {
      final matchFiltro = _filtro == 'Tutti' || d.categoria == _filtro;
      final q = _cerca.trim().toLowerCase();
      final matchRicerca = q.isEmpty || d.nome.toLowerCase().contains(q) || d.ruolo.toLowerCase().contains(q);
      return matchFiltro && matchRicerca;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final attivi = listaDipendenti.where((d) => d.stato == 'ATTIVO').length;
    final autisti = listaDipendenti.where((d) => d.categoria == 'Autisti').length;
    final mezziAttivi = appConfig.mezziAzienda.where((m) => m.stato == 'ATTIVO').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AZIENDA & PERSONALE'),
        actions: [
          IconButton(icon: const Icon(Icons.download), tooltip: 'Esporta Excel/CSV', onPressed: _esportaDati),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: _miniStat('PERSONALE', '$attivi', Icons.groups)),
                  const SizedBox(width: 8),
                  Expanded(child: _miniStat('AUTISTI', '$autisti', Icons.local_shipping)),
                  const SizedBox(width: 8),
                  Expanded(child: _miniStat('MEZZI', '$mezziAttivi', Icons.fire_truck)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Cerca persona o ruolo...', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() => _cerca = v),
                  )),
                  const SizedBox(width: 8),
                  IconButton.filled(onPressed: _mostraDipendenteDialog, icon: const Icon(Icons.person_add), tooltip: 'Nuovo dipendente'),
                ]),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: ['Tutti', 'Direzione', 'Autisti', 'Collaboratori', 'Consulenti', 'Posizioni aperte'].map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(f), selected: _filtro == f, onSelected: (_) => setState(() => _filtro = f)),
                  )).toList()),
                ),
              ],
            ),
          ),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
            itemCount: _visibili.length,
            itemBuilder: (context, index) {
              final d = _visibili[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () => _apriScheda(d),
                  leading: CircleAvatar(child: Icon(d.categoria == 'Autisti' ? Icons.local_shipping : Icons.person)),
                  title: Text(d.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${d.ruolo}\nStato: ${d.stato}${d.mezziAssegnati.isNotEmpty ? '\n🚛 ${d.mezziAssegnati.join(', ')}' : ''}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') _mostraDipendenteDialog(d: d);
                      if (v == 'archive') _archiviaDipendente(d);
                      if (v == 'delete') _eliminaDipendente(d);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('✏️ Modifica')),
                      PopupMenuItem(value: 'archive', child: Text('🗄️ Archivia')),
                      PopupMenuItem(value: 'delete', child: Text('🗑️ Elimina definitivamente')),
                    ],
                  ),
                ),
              );
            },
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _mostraOrganigramma, icon: const Icon(Icons.account_tree), label: const Text('ORGANIGRAMMA')),
    );
  }

  Widget _miniStat(String label, String value, IconData icon) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [Icon(icon, color: Theme.of(context).primaryColor, size: 20), const SizedBox(width: 7), Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey))]))]),
  );

  Future<void> _mostraDipendenteDialog({DipendenteModel? d}) async {
    final nome = TextEditingController(text: d?.nome ?? '');
    final ruolo = TextEditingController(text: d?.ruolo ?? '');
    final patente = TextEditingController(text: d?.patente ?? '');
    final dataPatente = TextEditingController(text: d?.dataPatente ?? '');
    final telefono = TextEditingController(text: d?.telefono ?? '');
    final email = TextEditingController(text: d?.email ?? '');
    String categoria = d?.categoria ?? 'Autisti';
    String stato = d?.stato ?? 'ATTIVO';

    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) => AlertDialog(
      title: Text(d == null ? 'NUOVO DIPENDENTE' : 'MODIFICA ANAGRAFICA'),
      content: SingleChildScrollView(child: Column(children: [
        _field(nome, 'Nome e cognome'), _field(ruolo, 'Ruolo / mansione'),
        DropdownButtonFormField<String>(value: categoria, decoration: const InputDecoration(labelText: 'Categoria'), items: ['Direzione','Autisti','Collaboratori','Consulenti','Posizioni aperte'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => categoria = v!)),
        DropdownButtonFormField<String>(value: stato, decoration: const InputDecoration(labelText: 'Stato'), items: ['ATTIVO','SOSPESO','CESSATO','VUOTO'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => stato = v!)),
        _field(patente, 'Patente / abilitazioni'), _field(dataPatente, 'Data patente / abilitazione'), _field(telefono, 'Telefono', keyboard: TextInputType.phone), _field(email, 'Email'),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULLA')), ElevatedButton(onPressed: () {
        if (nome.text.trim().isEmpty) return;
        if (d == null) {
          listaDipendenti.add(DipendenteModel(nome: nome.text.trim(), ruolo: ruolo.text.trim(), categoria: categoria, patente: patente.text.trim(), dataPatente: dataPatente.text.trim(), telefono: telefono.text.trim(), email: email.text.trim(), stato: stato));
        } else {
          d.nome = nome.text.trim(); d.ruolo = ruolo.text.trim(); d.categoria = categoria; d.patente = patente.text.trim(); d.dataPatente = dataPatente.text.trim(); d.telefono = telefono.text.trim(); d.email = email.text.trim(); d.stato = stato;
        }
        setState(() {}); Navigator.pop(ctx); _snack(d == null ? 'Dipendente aggiunto' : 'Anagrafica aggiornata');
      }, child: const Text('SALVA'))],
    )));
  }

  Widget _field(TextEditingController c, String label, {TextInputType? keyboard}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, keyboardType: keyboard, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));

  void _apriScheda(DipendenteModel d) {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text(d.nome, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.edit), onPressed: () { Navigator.pop(context); _mostraDipendenteDialog(d: d); })]),
      Text(d.ruolo, style: const TextStyle(color: Colors.cyanAccent)), const Divider(height: 28),
      Text('Categoria: ${d.categoria}'), Text('Stato: ${d.stato}'), Text('Patente: ${d.patente}'), Text('Data patente: ${d.dataPatente}'), if (d.telefono != '—' && d.telefono.isNotEmpty) Text('Telefono: ${d.telefono}'), if (d.email != '—' && d.email.isNotEmpty) Text('Email: ${d.email}'),
      const SizedBox(height: 12), const Text('MEZZI ASSEGNATI', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
      if (d.mezziAssegnati.isEmpty) const Text('Nessun mezzo assegnato'), ...d.mezziAssegnati.map((m) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.local_shipping), title: Text(m))),
      if (d.assegnazioneDaVerificare) const Text('⚠️ Assegnazione ISM da verificare', style: TextStyle(color: Colors.orangeAccent)),
      const SizedBox(height: 8), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); _mostraDipendenteDialog(d: d); }, icon: const Icon(Icons.edit), label: const Text('MODIFICA'))), const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); _archiviaDipendente(d); }, icon: const Icon(Icons.archive), label: const Text('ARCHIVIA')))]),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); _assegnaMezzi(d); }, icon: const Icon(Icons.local_shipping), label: const Text('ASSEGNA / MODIFICA MEZZI'))),
    ]))));
  }

  Future<void> _assegnaMezzi(DipendenteModel d) async {
    final selezionati = Set<String>.from(d.mezziAssegnati);
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) => AlertDialog(
      title: Text('MEZZI DI ${d.nome.toUpperCase()}'),
      content: appConfig.mezziAzienda.isEmpty ? const Text('Nessun mezzo presente in flotta.') : SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: appConfig.mezziAzienda.map((m) => CheckboxListTile(
        value: selezionati.contains(m.targa),
        title: Text(m.nome), subtitle: Text('${m.targa} • ${m.tipo}'),
        onChanged: (v) => setLocal(() { if (v == true) { selezionati.add(m.targa); } else { selezionati.remove(m.targa); } }),
      )).toList())),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULLA')), ElevatedButton(onPressed: () { d.mezziAssegnati = selezionati.toList(); setState(() {}); Navigator.pop(ctx); _snack('Assegnazioni aggiornate'); }, child: const Text('SALVA'))],
    )));
  }

  void _archiviaDipendente(DipendenteModel d) { setState(() => d.stato = 'CESSATO'); _snack('${d.nome} archiviato'); }
  Future<void> _eliminaDipendente(DipendenteModel d) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Eliminare definitivamente?'), content: Text('Questa operazione rimuove ${d.nome} dall\'anagrafica. Se ha dati storici collegati, è preferibile archiviarlo.'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULLA')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ELIMINA'))]));
    if (ok == true) setState(() => listaDipendenti.remove(d));
  }

  void _mostraOrganigramma() => showModalBottomSheet(context: context, isScrollControlled: true, builder: (_) => SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    const Text('ORGANIGRAMMA AZIENDALE', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('Struttura dinamica dell\'azienda. Tocca una persona per modificarla.'), const SizedBox(height: 18),
    _orgCard('👔 DIREZIONE', listaDipendenti.where((d) => d.categoria == 'Direzione').toList()), _orgCard('🚛 AUTISTI', listaDipendenti.where((d) => d.categoria == 'Autisti').toList()), _orgCard('🤝 COLLABORATORI', listaDipendenti.where((d) => d.categoria == 'Collaboratori').toList()), _orgCard('📋 CONSULENTI', listaDipendenti.where((d) => d.categoria == 'Consulenti').toList()),
    const SizedBox(height: 12), const Text('⚠️ ASSEGNAZIONI ISM DA VERIFICARE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)), ...assegnazioniIsmDaVerificare.entries.map((e) => ListTile(title: Text(e.key), subtitle: Text(e.value.join(' • ')))),
  ]))));

  Widget _orgCard(String title, List<DipendenteModel> persone) => Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), ...persone.map((p) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.person_outline), title: Text(p.nome), subtitle: Text(p.ruolo), onTap: () { Navigator.pop(context); _mostraDipendenteDialog(d: p); }))])));

  Future<void> _esportaDati() async {
    final workbook = Excel.createExcel();
    final personale = workbook['Personale'];
    personale.appendRow([TextCellValue('Nome'), TextCellValue('Ruolo'), TextCellValue('Categoria'), TextCellValue('Stato'), TextCellValue('Patente'), TextCellValue('Data patente'), TextCellValue('Telefono'), TextCellValue('Email'), TextCellValue('Mezzi assegnati')]);
    for (final d in listaDipendenti) personale.appendRow([TextCellValue(d.nome), TextCellValue(d.ruolo), TextCellValue(d.categoria), TextCellValue(d.stato), TextCellValue(d.patente), TextCellValue(d.dataPatente), TextCellValue(d.telefono), TextCellValue(d.email), TextCellValue(d.mezziAssegnati.join(' | '))]);

    final flotta = workbook['Parco Mezzi'];
    flotta.appendRow([TextCellValue('Nome/Modello'), TextCellValue('Targa'), TextCellValue('Tipo'), TextCellValue('Capacita mc'), TextCellValue('Anno'), TextCellValue('Stato'), TextCellValue('Note'), TextCellValue('Autisti')]);
    for (final m in appConfig.mezziAzienda) flotta.appendRow([TextCellValue(m.nome), TextCellValue(m.targa), TextCellValue(m.tipo), DoubleCellValue(m.minorCaricoStandard), TextCellValue(m.anno), TextCellValue(m.stato), TextCellValue(m.note), TextCellValue(listaDipendenti.where((d) => d.mezziAssegnati.contains(m.targa)).map((d) => d.nome).join(' | '))]);

    final viaggi = workbook['Viaggi'];
    viaggi.appendRow([TextCellValue('Data'), TextCellValue('DDT'), TextCellValue('Mezzo'), TextCellValue('Cantiere'), TextCellValue('Mc'), TextCellValue('Minor carico'), TextCellValue('Sosta min'), TextCellValue('Pompaggio mc'), TextCellValue('Piazzamenti'), TextCellValue('Importo')]);
    for (final v in listaViaggiGlobali) viaggi.appendRow([TextCellValue(v.dataDdt), TextCellValue(v.numeroDdt), TextCellValue(v.mezzoInfo), TextCellValue(v.cantiere), DoubleCellValue(v.mcEffettivi), DoubleCellValue(v.minorCarico), DoubleCellValue(v.minutiSosta), DoubleCellValue(v.pompaggioMc), IntCellValue(v.piazzamenti), DoubleCellValue(v.importoTotale)]);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Calcestruzzi_Ogliastra_Export.xlsx');
    final bytes = workbook.save();
    if (bytes == null) return;
    await file.writeAsBytes(bytes, flush: true);
    await Share.shareXFiles([XFile(file.path)], text: 'Esportazione Excel Calcestruzzi Ogliastra');
  }
  String _csv(String v) => '"${v.replaceAll('"', '""')}"';
  void _snack(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
}

 ),
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

class DdtScreen extends StatefulWidget {
  const DdtScreen({Key? key}) : super(key: key);

  @override
  State<DdtScreen> createState() => _DdtScreenState();
}

class _DdtScreenState extends State<DdtScreen> {
  final TextEditingController _dataController = TextEditingController(text: '07/09/2026');
  final TextEditingController _oraPartenzaController = TextEditingController(text: '07:30');
  final TextEditingController _oraFineController = TextEditingController(text: '08:30');
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
      appBar: AppBar(title: const Text('NUOVO DDT & SERVIZIO'), actions: [IconButton(tooltip: 'Google Calendar', icon: const Icon(Icons.event), onPressed: _aggiungiGoogleCalendar)]),
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
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _oraPartenzaController, decoration: const InputDecoration(labelText: 'Ora partenza', border: OutlineInputBorder()))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _oraFineController, decoration: const InputDecoration(labelText: 'Ora fine / rientro', border: OutlineInputBorder()))),
            ],),
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

                double mcRiconosciuti = mc + _minorCaricoCalcolato;
                double tariffaRadiale = appConfig.tariffeRadiali[_radialeSelezionato] ?? 10.90;
                double importoBase = mcRiconosciuti * tariffaRadiale;

                double importoSosta = minutiSosta > 60 ? (minutiSosta - 60) * appConfig.tariffaMinutoSosta : 0.0;

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

  Future<void> _aggiungiGoogleCalendar() async {
    DateTime parseDateTime(String date, String time) {
      final p = date.split('/');
      final t = time.split(':');
      final day = int.tryParse(p.length > 0 ? p[0] : '') ?? DateTime.now().day;
      final month = int.tryParse(p.length > 1 ? p[1] : '') ?? DateTime.now().month;
      final year = int.tryParse(p.length > 2 ? p[2] : '') ?? DateTime.now().year;
      final hour = int.tryParse(t.length > 0 ? t[0] : '') ?? 7;
      final minute = int.tryParse(t.length > 1 ? t[1] : '') ?? 30;
      return DateTime(year, month, day, hour, minute);
    }
    final start = parseDateTime(_dataController.text, _oraPartenzaController.text);
    final end = parseDateTime(_dataController.text, _oraFineController.text);
    String fmt(DateTime d) => d.toUtc().toIso8601String().replaceAll('-', '').replaceAll(':', '').split('.').first + 'Z';
    final uri = Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': 'Viaggio – ${_cantiereController.text.isEmpty ? 'Cantiere' : _cantiereController.text}',
      'dates': '${fmt(start)}/${fmt(end)}',
      'details': 'DDT: ${_numDdtController.text}\nMezzo: ${_mezzoSelezionato.nome} - ${_mezzoSelezionato.targa}\nCalcestruzzo: ${_mcController.text} mc',
    });
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossibile aprire Google Calendar')));
    }
  }

}

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
                DropdownMenuItem(value: 'BTP', child: Text('Betonpompa - 7mc standard)')),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('PARCO MEZZI (ATB / BTP)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.greenAccent), onPressed: _aggiungiMezzoDialog),
              ],
            ),
            const SizedBox(height: 8),
            ...appConfig.mezziAzienda.map((m) => Card(
              child: ListTile(
                title: Text('${m.nome} (${m.targa})'),
                subtitle: Text('Tipo: ${m.tipo} | Capacità: ${m.minorCaricoStandard} mc | Stato: ${m.stato}\nAutisti: ${listaDipendenti.where((d) => d.mezziAssegnati.contains(m.targa)).map((d) => d.nome).join(', ')}'),
                onTap: () => _modificaMezzoDialog(m),
                trailing: PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') _modificaMezzoDialog(m);
                    if (v == 'archive') setState(() => m.stato = 'FUORI SERVIZIO');
                    if (v == 'delete') setState(() => appConfig.mezziAzienda.remove(m));
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('✏️ Modifica')),
                    PopupMenuItem(value: 'archive', child: Text('🗄️ Metti fuori servizio')),
                    PopupMenuItem(value: 'delete', child: Text('🗑️ Elimina')),
                  ],
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
                  c2Fido: double.tryParse(_c2FidoController.text) ?? 1500.0,
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
  Future<void> _modificaMezzoDialog(MezzoConfig? m) async {
    final nome = TextEditingController(text: m?.nome ?? '');
    final targa = TextEditingController(text: m?.targa ?? '');
    final cap = TextEditingController(text: m?.minorCaricoStandard.toString() ?? '8');
    final anno = TextEditingController(text: m?.anno ?? '');
    final note = TextEditingController(text: m?.note ?? '');
    String tipo = m?.tipo ?? 'ATB';
    String stato = m?.stato ?? 'ATTIVO';
    await showDialog(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setLocal) => AlertDialog(
      title: Text(m == null ? 'NUOVO MEZZO' : 'MODIFICA MEZZO'),
      content: SingleChildScrollView(child: Column(children: [
        _mezzoField(nome, 'Marca / modello'), _mezzoField(targa, 'Targa'),
        DropdownButtonFormField<String>(value: tipo, decoration: const InputDecoration(labelText: 'Tipo'), items: ['ATB','BTP','ALTRO'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => tipo = v!)),
        _mezzoField(cap, 'Capacità standard mc', keyboard: TextInputType.number), _mezzoField(anno, 'Anno'),
        DropdownButtonFormField<String>(value: stato, decoration: const InputDecoration(labelText: 'Stato'), items: ['ATTIVO','IN MANUTENZIONE','FUORI SERVIZIO','ARCHIVIATO'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setLocal(() => stato = v!)),
        _mezzoField(note, 'Note'),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULLA')), ElevatedButton(onPressed: () {
        final capacita = double.tryParse(cap.text.replaceAll(',', '.')) ?? 8;
        if (nome.text.trim().isEmpty || targa.text.trim().isEmpty) return;
        if (m == null) appConfig.mezziAzienda.add(MezzoConfig(nome: nome.text.trim(), targa: targa.text.trim().toUpperCase(), tipo: tipo, minorCaricoStandard: capacita, anno: anno.text.trim(), stato: stato, note: note.text.trim()));
        else { m.nome = nome.text.trim(); m.targa = targa.text.trim().toUpperCase(); m.tipo = tipo; m.minorCaricoStandard = capacita; m.anno = anno.text.trim(); m.stato = stato; m.note = note.text.trim(); }
        setState(() {}); Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m == null ? 'Mezzo aggiunto' : 'Mezzo aggiornato')));
      }, child: const Text('SALVA'))],
    )));
  }

  Widget _mezzoField(TextEditingController c, String label, {TextInputType? keyboard}) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: c, keyboardType: keyboard, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));

}


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
