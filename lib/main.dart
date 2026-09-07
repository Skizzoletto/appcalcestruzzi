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
  bool isBeton = _mezzoSelezionato.tipo == 'BTP';

  return Scaffold(
    appBar: AppBar(title: const Text('NUOVO DDT & SERVIZIO')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dataController,
                  decoration: const InputDecoration(
                    labelText: 'Data DDT',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _numDdtController,
                  decoration: const InputDecoration(
                    labelText: 'N. DDT',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<MezzoConfig>(
            value: _mezzoSelezionato,
            decoration: const InputDecoration(
              labelText: 'Seleziona Mezzo (Flotta)',
              border: OutlineInputBorder(),
            ),
            items: appConfig.mezziAzienda.map((m) {
              return DropdownMenuItem(
                value: m,
                child: Text('${m.nome} [${m.tipo} - Targa: ${m.targa}]'),
              );
            }).toList(),
            onChanged: (v) {
              setState(() {
                _mezzoSelezionato = v!;
                _aggiornaMinorCarico(_mcController.text);
              });
            },
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _cantiereController,
            decoration: const InputDecoration(
              labelText: 'Cantiere / Destinazione',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _mcController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Metri Cubi (mc)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _aggiornaMinorCarico,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _radialeSelezionato,
                  decoration: const InputDecoration(
                    labelText: 'Radiale Contratto',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(
                    10,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('Radiale ${i + 1}'),
                    ),
                  ),
                  onChanged: (v) => setState(() => _radialeSelezionato = v!),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Minor Carico automatico (${_mezzoSelezionato.tipo}): '
              '${_minorCaricoCalcolato.toStringAsFixed(1)} mc '
              '(Standard a ${_mezzoSelezionato.minorCaricoStandard} mc)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.cyanAccent,
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _sostaMinutiController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Sosta (Minuti oltre 60 min franchigia)',
              border: OutlineInputBorder(),
            ),
          ),

          if (isBeton) ...[
            const SizedBox(height: 20),
            const Text(
              'DETTAGLI POMPAGGIO (BTP)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pompaggioMcController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Pompaggio (mc)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _piazzamentiController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'N. Piazzamenti',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 30),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              double mc = double.tryParse(_mcController.text) ?? 0.0;
              double minutiSosta =
                  double.tryParse(_sostaMinutiController.text) ?? 0.0;
              double pompaggioMc =
                  double.tryParse(_pompaggioMcController.text) ?? 0.0;
              int piazzamenti =
                  int.tryParse(_piazzamentiController.text) ?? 0;

              double mcRiconosciuti = mc + _minorCaricoCalcolato;
              double tariffaRadiale =
                  appConfig.tariffeRadiali[_radialeSelezionato] ?? 10.90;

              double importoBase = mcRiconosciuti * tariffaRadiale;

              double importoSosta = minutiSosta > 60
                  ? (minutiSosta - 60) * appConfig.tariffaMinutoSosta
                  : 0.0;

              double importoPompaggio = 0.0;
              if (isBeton) {
                importoPompaggio =
                    (piazzamenti * appConfig.tariffaPiazzamentoPompa) +
                        (pompaggioMc * appConfig.tariffaMqPompa);
              }

              double totaleDdt =
                  importoBase + importoSosta + importoPompaggio;

              listaViaggiGlobali.insert(
                0,
                ViaggioModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  dataDdt: _dataController.text,
                  numeroDdt: _numDdtController.text.isEmpty
                      ? 'S/N'
                      : _numDdtController.text,
                  mezzoInfo:
                      '${_mezzoSelezionato.nome} [${_mezzoSelezionato.tipo} - ${_mezzoSelezionato.targa}]',
                  cantiere: _cantiereController.text.isEmpty
                      ? 'Cantiere Standard'
                      : _cantiereController.text,
                  mcEffettivi: mc,
                  minorCarico: _minorCaricoCalcolato,
                  minutiSosta: minutiSosta,
                  pompaggioMc: pompaggioMc,
                  piazzamenti: piazzamenti,
                  importoTotale: totaleDdt,
                ),
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'DDT Registrato! Totale: €${totaleDdt.toStringAsFixed(2)}',
                  ),
                ),
              );
            },
            child: const Text(
              'SALVA E CALCOLA RICAVO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
