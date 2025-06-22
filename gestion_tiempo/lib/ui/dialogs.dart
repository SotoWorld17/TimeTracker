import 'package:flutter/material.dart';

Future<String?> showAddItemDialog(BuildContext context, String label) {
  final _ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Añadir $label'),
      content: TextField(
        controller: _ctrl,
        decoration: InputDecoration(
          labelText: 'Nombre de la $label',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _ctrl.text.trim();
            Navigator.pop(context, text.isEmpty ? null : text);
          },
          child: const Text('AÑADIR'),
        ),
      ],
    ),
  );
}
