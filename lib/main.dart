import 'package:flutter/material.dart';

void main() {
  runApp(const CalcestruzziApp());
}

class CalcestruzziApp extends StatelessWidget {
  const CalcestruzziApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestione Operativa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E21), // Sfondo blu notte profondo
        primaryColor: Colors.cyanAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.orangeAccent,
        ),
        cardColor: const Color(0xFF1D1E33), // Schede in contrasto elegante
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ==========================================
// SCHERMATA 1: DASHBOARD
// ==========================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Dati di esempio
  final double spesaQ8 = 1750.0;
  final double fidoQ8 = 2000.0;
  final double spesaRadius = 600.0;
  final double fidoRadius = 1500.0;

  void _apriMenuAzioni(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1E33),
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
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Seleziona Operazione',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.document_scanner, color: Colors.cyanAccent, size: 30),
                title: const Text('Nuovo DDT', style: TextStyle(fontSize: 18, color: Colors.white)),
                subtitle: const Text('Scansiona bolla o inserimento manuale', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DdtScreen()));
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.local_gas_station, color: Colors.orangeAccent, size: 30),
                title: const Text('Nuovo Rifornimento', style: TextStyle(fontSize: 18, color: Colors.white)),
                subtitle: const Text('Registra scontrino carburante', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RifornimentoScreen()));
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OPERAZIONI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riepilogo Trasporti', style: TextStyle(fontSize: 14, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Viaggi Oggi', '4', Icons.local_shipping, Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Metri Cubi', '35.5', Icons.layers, Colors.white)),
              ],
            ),
            const SizedBox(height: 30),
            const Text('Stato Plafond Carburante', style: TextStyle(fontSize: 14, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1E33),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildFuelBar('Cartissima Q8', spesaQ8, fidoQ8, Colors.orangeAccent),
                  const SizedBox(height: 24),
                  _buildFuelBar('Radius', spesaRadius, fidoRadius, Colors.blueAccent),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _apriMenuAzioni(context),
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('NUOVO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.cyanAccent),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFuelBar(String label, double spesa, double fido, Color baseColor) {
    double percentuale = spesa / fido;
    bool inAllerta = percentuale > 0.85;
    Color barColor = inAllerta ? Colors.redAccent : baseColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, size: 18, color: barColor),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              ],
            ),
            Text('€${spesa.toStringAsFixed(0)} / €${fido.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: inAllerta ? Colors.redAccent : Colors.white)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentuale,
            minHeight: 10,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SCHERMATA 2: INSERIMENTO DDT
// ==========================================
class DdtScreen extends StatefulWidget {
  const DdtScreen({Key? key}) : super(key: key);

  @override
  State<DdtScreen> createState() => _DdtScreenState();
}

class _DdtScreenState extends State<DdtScreen> {
  String? _committente;
  String? _mezzo;
  String? _autista;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NUOVO DDT')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulazione: Avvio OCR fotocamera...')));
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('SCANSIONA'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('FATTURAZIONE'),
            _buildDropdown('Committente', ['Buzzi Unical', 'Calcestruzzi SpA', 'Gruppo Edil Piras', 'Batzu'], (v) => setState(() => _committente = v), _committente),
            const SizedBox(height: 20),
            _buildSectionTitle('RIFERIMENTI OPERATIVI'),
            _buildTextField('Cliente Finale (Opzionale)', Icons.person),
            const SizedBox(height: 12),
            _buildTextField('Cantiere / Destinazione', Icons.location_on, iconColor: Colors.redAccent),
            const SizedBox(height: 20),
            _buildSectionTitle('LOGISTICA E QUANTITÀ'),
            Row(
              children: [
                Expanded(child: _buildDropdown('Mezzo', ['Iveco Trakker', 'Pompa', 'Betoniera 1'], (v) => setState(() => _mezzo = v), _mezzo)),
                const SizedBox(width: 12),
                Expanded(child: _buildDropdown('Autista', ['Valentino Vacca', 'Autista 2'], (v) => setState(() => _autista = v), _autista)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField('Metri Cubi (mc)', Icons.layers, isNumber: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('DDT Salvato e Sincronizzato con Calendar!')));
              },
              child: const Text('SALVA E SINCRONIZZA'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// SCHERMATA 3: INSERIMENTO RIFORNIMENTO
// ==========================================
class RifornimentoScreen extends StatefulWidget {
  const RifornimentoScreen({Key? key}) : super(key: key);

  @override
  State<RifornimentoScreen> createState() => _RifornimentoScreenState();
}

class _RifornimentoScreenState extends State<RifornimentoScreen> {
  String? _carta;
  String? _mezzo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NUOVO RIFORNIMENTO')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('METODO DI PAGAMENTO'),
            _buildDropdown('Carta Carburante', ['Cartissima Q8', 'Radius'], (v) => setState(() => _carta = v), _carta, icon: Icons.credit_card),
            const SizedBox(height: 20),
            _buildSectionTitle('DETTAGLI VEICOLO E IMPORTO'),
            _buildDropdown('Mezzo', ['Iveco Trakker', 'Pompa', 'Alfa 159'], (v) => setState(() => _mezzo = v), _mezzo, icon: Icons.directions_car),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Importo (€)', Icons.euro, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Km / Ore moto', Icons.speed, isNumber: true)),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rifornimento registrato!')));
              },
              child: const Text('REGISTRA SPESA'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET DI SUPPORTO (UI)
// ==========================================
Widget _buildSectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Text(
      title,
      style: const TextStyle(fontSize: 12, color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    ),
  );
}

Widget _buildTextField(String label, IconData icon, {bool isNumber = false, Color iconColor = Colors.grey}) {
  return TextField(
    keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: iconColor),
      filled: true,
      fillColor: const Color(0xFF1D1E33),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent, width: 1),
      ),
    ),
  );
}

Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged, String? value, {IconData? icon}) {
  return DropdownButtonFormField<String>(
    value: value,
    dropdownColor: const Color(0xFF1D1E33),
    style: const TextStyle(color: Colors.white, fontSize: 16),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
      filled: true,
      fillColor: const Color(0xFF1D1E33),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
    onChanged: onChanged,
  );
}
