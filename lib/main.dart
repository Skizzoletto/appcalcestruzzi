class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  DateTime _oraAttuale = DateTime.now();

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _oraAttuale = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _dueCifre(int valore) {
    return valore.toString().padLeft(2, '0');
  }

  String _nomeGiorno(int giorno) {
    const giorni = [
      'Lunedì',
      'Martedì',
      'Mercoledì',
      'Giovedì',
      'Venerdì',
      'Sabato',
      'Domenica'
    ];

    return giorni[giorno - 1];
  }

  String _nomeMese(int mese) {
    const mesi = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre'
    ];

    return mesi[mese - 1];
  }

  String get _dataCompleta {
    return '${_nomeGiorno(_oraAttuale.weekday)} '
        '${_oraAttuale.day} '
        '${_nomeMese(_oraAttuale.month)} '
        '${_oraAttuale.year}';
  }

  String get _orologio {
    return '${_dueCifre(_oraAttuale.hour)}:'
        '${_dueCifre(_oraAttuale.minute)}:'
        '${_dueCifre(_oraAttuale.second)}';
  }

  void _apriMenuAzioni(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
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
                'SELEZIONA OPERAZIONE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(
                  Icons.document_scanner,
                  size: 30,
                ),
                title: const Text(
                  'Nuovo DDT',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: const Text(
                  'Registra bolla, minor carico e pompaggio',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DdtScreen(),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(
                  Icons.groups,
                  size: 30,
                ),
                title: const Text(
                  'Azienda & Personale',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: const Text(
                  'Organigramma, dipendenti e assegnazioni mezzi',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AziendaScreen(),
                    ),
                  );
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(
                  Icons.local_gas_station,
                  size: 30,
                ),
                title: const Text(
                  'Nuovo Rifornimento',
                  style: TextStyle(fontSize: 18),
                ),
                subtitle: const Text(
                  'Registra scontrino carburante',
                ),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RifornimentoScreen(),
                    ),
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
    final oggi =
        '${_dueCifre(_oraAttuale.day)}/${_dueCifre(_oraAttuale.month)}/${_oraAttuale.year}';

    final produzioneOggi = listaViaggiGlobali
        .where((v) => v.dataDdt == oggi)
        .fold<double>(
          0.0,
          (sum, item) => sum + item.importoTotale,
        );

    final produzioneMese = listaViaggiGlobali
        .where(
          (v) =>
              v.dataDdt.length >= 7 &&
              v.dataDdt.substring(3, 10) ==
                  '${_dueCifre(_oraAttuale.month)}/${_oraAttuale.year}',
        )
        .fold<double>(
          0.0,
          (sum, item) => sum + item.importoTotale,
        );

    final mcMese = listaViaggiGlobali
        .where(
          (v) =>
              v.dataDdt.length >= 7 &&
              v.dataDdt.substring(3, 10) ==
                  '${_dueCifre(_oraAttuale.month)}/${_oraAttuale.year}',
        )
        .fold<double>(
          0.0,
          (sum, item) => sum + item.mcEffettivi,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appConfig.nomeAzienda,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Azienda e personale',
            icon: const Icon(Icons.groups),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AziendaScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Impostazioni',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OpzioniScreen(),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // =========================================================
            // OROLOGIO
            // =========================================================

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).cardColor,
                    Theme.of(context)
                        .primaryColor
                        .withOpacity(0.12),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Theme.of(context)
                      .primaryColor
                      .withOpacity(0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .primaryColor
                        .withOpacity(0.08),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 25,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _orologio,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    _dataCompleta,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'CRUSCOTTO OPERATIVO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 12),

            // =========================================================
            // VIAGGI + MC
            // =========================================================

            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    title: 'VIAGGI',
                    value: '${listaViaggiGlobali.length}',
                    subtitle: 'Totali',
                    icon: Icons.local_shipping,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StoricoViaggiScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildDashboardCard(
                    title: 'MC MESE',
                    value: mcMese.toStringAsFixed(1),
                    subtitle: 'Metri cubi',
                    icon: Icons.layers,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StoricoViaggiScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =========================================================
            // FATTURATO
            // =========================================================

            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    title: 'OGGI',
                    value:
                        '€${produzioneOggi.toStringAsFixed(2)}',
                    subtitle: 'Produzione',
                    icon: Icons.euro,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StoricoViaggiScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildDashboardCard(
                    title: 'MESE',
                    value:
                        '€${produzioneMese.toStringAsFixed(2)}',
                    subtitle: 'Produzione',
                    icon: Icons.trending_up,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StoricoViaggiScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // =========================================================
            // CARBURANTE
            // =========================================================

            const Text(
              'CARBURANTE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 12),

            _buildFuelCard(
              appConfig.carta1Nome,
              appConfig.carta1Spesa,
              appConfig.carta1Fido,
              Colors.orangeAccent,
            ),

            const SizedBox(height: 12),

            _buildFuelCard(
              appConfig.carta2Nome,
              appConfig.carta2Spesa,
              appConfig.carta2Fido,
              Colors.blueAccent,
            ),

            const SizedBox(height: 25),

            // =========================================================
            // OPERAZIONI RAPIDE
            // =========================================================

            const Text(
              'OPERAZIONI RAPIDE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.document_scanner,
                    label: 'NUOVO DDT',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DdtScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.local_gas_station,
                    label: 'RIFORNIMENTO',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RifornimentoScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _apriMenuAzioni(context),
        icon: const Icon(Icons.add),
        label: const Text(
          'NUOVO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context)
                  .primaryColor
                  .withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: Colors.grey[600],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Tocca per dettagli',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFuelCard(
    String label,
    double spesa,
    double fido,
    Color baseColor,
  ) {
    final percentuale =
        fido > 0 ? spesa / fido : 0.0;

    final inAllerta = percentuale > 0.85;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Dettaglio carta carburante',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const Divider(height: 30),

                    Text(
                      'Spesa registrata: €${spesa.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Fido disponibile: €${(fido - spesa).toStringAsFixed(2)}',
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Fido totale: €${fido.toStringAsFixed(2)}',
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const RifornimentoScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'NUOVO RIFORNIMENTO',
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: baseColor.withOpacity(0.25),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_gas_station,
                        color: baseColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '€${spesa.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Fido €${fido.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: percentuale > 1
                    ? 1
                    : percentuale,
                minHeight: 9,
                borderRadius:
                    BorderRadius.circular(10),
                color: inAllerta
                    ? Colors.redAccent
                    : baseColor,
              ),

              const SizedBox(height: 7),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tocca per dettagli',
                  style: TextStyle(
                    fontSize: 9,
                    color: baseColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
      ),
    );
  }
}
