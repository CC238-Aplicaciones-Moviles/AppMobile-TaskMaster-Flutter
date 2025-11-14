import 'package:flutter/material.dart';

class EmptyTask extends StatelessWidget {
  const EmptyTask({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 12),
            child: Image.asset(
              'assets/img/ic_emptytask.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "¡No cuentas con ninguna tarea, espera a que te asignen una!",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onBackground,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
