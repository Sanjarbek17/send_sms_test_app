import 'package:flutter/material.dart';
import '../services/sms_service.dart';

class SimCardSelector extends StatefulWidget {
  final Function(int?) onSimSelected;
  final int? selectedSimSlot;

  const SimCardSelector({
    Key? key,
    required this.onSimSelected,
    this.selectedSimSlot,
  }) : super(key: key);

  @override
  State<SimCardSelector> createState() => _SimCardSelectorState();
}

class _SimCardSelectorState extends State<SimCardSelector> {
  List<Map<String, dynamic>> simCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimCards();
  }

  Future<void> _loadSimCards() async {
    try {
      final cards = await SmsService.getAvailableSimCards();
      setState(() {
        simCards = cards;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading SIM cards...'),
            ],
          ),
        ),
      );
    }

    if (simCards.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('No SIM cards detected'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sim_card, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'SIM Card Selection (${simCards.length} available)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...simCards.map((sim) => _buildSimCardOption(sim)),
            const SizedBox(height: 8),
            _buildAutoSelectOption(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimCardOption(Map<String, dynamic> sim) {
    final int simSlot = sim['simSlot'] ?? 0;
    final String carrierName = sim['carrierName'] ?? 'Unknown Carrier';
    final String displayName = sim['displayName'] ?? 'SIM ${simSlot + 1}';

    return RadioListTile<int>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text('$displayName - $carrierName'),
      subtitle: Text('Slot ${simSlot + 1}'),
      value: simSlot,
      groupValue: widget.selectedSimSlot,
      onChanged: (value) => widget.onSimSelected(value),
    );
  }

  Widget _buildAutoSelectOption() {
    return RadioListTile<int?>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: const Text('Auto-select'),
      subtitle: const Text('Use default SIM card'),
      value: null,
      groupValue: widget.selectedSimSlot,
      onChanged: widget.onSimSelected,
    );
  }
}
