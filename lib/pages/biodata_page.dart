import 'package:flutter/material.dart';
import 'package:test_1/theme/app_theme.dart';

class BiodataPage extends StatefulWidget {
  const BiodataPage({super.key});

  @override
  State<BiodataPage> createState() => _BiodataPageState();
}

class _BiodataPageState extends State<BiodataPage> {
  bool _showForm = false;
  final _nameCtrl = TextEditingController(text: 'Firman FF');
  final _ageCtrl = TextEditingController(text: '23');
  final _heightCtrl = TextEditingController(text: '170');
  final _weightCtrl = TextEditingController(text: '65');
  // new form fields
  String _gender = 'male';
  String _bloodType = 'A';
  DateTime? _birthDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final age = int.tryParse(_ageCtrl.text) ?? 0;
    final height = double.tryParse(_heightCtrl.text) ?? 0.0;
    final weight = double.tryParse(_weightCtrl.text) ?? 0.0;
    final bmi = (height > 0)
        ? (weight / ((height / 100) * (height / 100)))
        : 0.0;

    final fill = Theme.of(context).colorScheme.surfaceVariant;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Biodata',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Top summary: avatar + inline name / birthdate / age / gender
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          child: Text(
                            _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0] : 'U',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name + small edit icon
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _nameCtrl.text.isNotEmpty
                                          ? _nameCtrl.text
                                          : 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 16,
                                    onPressed: () =>
                                        setState(() => _showForm = true),
                                    icon: const Icon(Icons.edit),
                                  ),
                                ],
                              ),

                              Row(
                                children: [
                                  Text(
                                    'Birth: ${_birthDate != null ? '${_birthDate!.toLocal()}'.split(' ')[0] : '-'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color.fromARGB(
                                        75,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Age: $age',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color.fromARGB(
                                        75,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Gender: ${_gender[0].toUpperCase()}${_gender.substring(1)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color.fromARGB(
                                        75,
                                        255,
                                        255,
                                        255,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Theme.of(context).colorScheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _infoTile('Blood', _bloodType)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _infoTile(
                                    'Height',
                                    '${height.toStringAsFixed(1)} cm',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _infoTile(
                                    'Weight',
                                    '${weight.toStringAsFixed(1)} kg',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _infoTile(
                                    'BMI',
                                    bmi.isFinite ? bmi.toStringAsFixed(1) : '-',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Vitals group: Blood Type, Height, Weight, BMI
            const SizedBox(height: 12),

            // Toggle form
            Row(
              children: [
                const Text('Show input form'),
                const SizedBox(width: 8),
                Switch(
                  value: _showForm,
                  onChanged: (v) => setState(() => _showForm = v),
                ),
              ],
            ),

            if (_showForm)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Full name',
                          filled: true,
                          fillColor: fill,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(64, 255, 255, 255),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Row: Birthdate + Age (age read-only)
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _birthDate ??
                                      DateTime(
                                        now.year - 23,
                                        now.month,
                                        now.day,
                                      ),
                                  firstDate: DateTime(1900),
                                  lastDate: now,
                                );
                                if (picked != null)
                                  setState(() => _birthDate = picked);
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Birth Date',
                                  filled: true,
                                  fillColor: fill,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  _birthDate != null
                                      ? '${_birthDate!.toLocal()}'.split(' ')[0]
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 110,
                            child: TextField(
                              controller: _ageCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Age',
                                filled: true,
                                fillColor: fill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Gender radios (styled)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gender'),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              _roundedRadio('male', 'Male', fill),
                              const SizedBox(width: 8),
                              _roundedRadio('female', 'Female', fill),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Group: Blood type + Height + Weight
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _bloodType,
                              decoration: InputDecoration(
                                labelText: 'Blood Type',
                                filled: true,
                                fillColor: fill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'A', child: Text('A')),
                                DropdownMenuItem(value: 'B', child: Text('B')),
                                DropdownMenuItem(
                                  value: 'AB',
                                  child: Text('AB'),
                                ),
                                DropdownMenuItem(value: 'O', child: Text('O')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _bloodType = v ?? 'A'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _heightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Height (cm)',
                                filled: true,
                                fillColor: fill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _weightCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Weight (kg)',
                                filled: true,
                                fillColor: fill,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: const Text('Update'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _nameCtrl.text = '';
                                  _ageCtrl.text = '';
                                  _heightCtrl.text = '';
                                  _weightCtrl.text = '';
                                  _gender = 'male';
                                  _bloodType = 'A';
                                  _birthDate = null;
                                });
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                        ],
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

  Widget _infoTile(String title, String value) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12, right: 4, left: 4),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: const Color.fromARGB(25, 66, 66, 66),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _roundedRadio(String value, String label, Color? fill) {
    final selected = _gender == value;
    return InkWell(
      onTap: () => setState(() => _gender = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          border: selected
              ? BoxBorder.all(
                  color: Theme.of(context).colorScheme.primaryContainer,
                )
              : BoxBorder.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v ?? value),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
