import 'package:flutter/material.dart';
import 'corrida_colors.dart';

class CorridaHeaderWidget extends StatelessWidget {
  final VoidCallback onVoltar;

  const CorridaHeaderWidget({
    super.key,
    required this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 17, 25, 0),
      child: Row(
        children: [
          Material(
            color: CorridaColors.primaryBlue,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onVoltar,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            'Detalhes da corrida',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: CorridaColors.darkBlue,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
