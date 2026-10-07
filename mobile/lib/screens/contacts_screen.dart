import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/emergency_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _contacts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final list = await EmergencyService.getLocalContacts();
    setState(() => _contacts = list);
  }

  void _add() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !_contacts.contains(text)) {
      final updated = List<String>.from(_contacts)..add(text);
      await EmergencyService.saveLocalContacts(updated);
      _controller.clear();
      setState(() => _contacts = updated);
    }
  }

  void _remove(int index) async {
    final updated = List<String>.from(_contacts)..removeAt(index);
    await EmergencyService.saveLocalContacts(updated);
    setState(() => _contacts = updated);
  }

  void _testDirectSimSms() async {
    final launched = await EmergencyService.sendNativeSimSms(
      recipients: _contacts,
      message: 'TEST ALERT: AlleyPilot direct SIM SMS is working from mobile.',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: launched ? Colors.green : AppColors.primaryRed,
          content: Text(launched ? 'Opened native phone SMS app with SIM direct!' : 'Could not launch SMS app'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Enter phone (e.g. +919876543210)',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppColors.primaryRed, size: 28),
                    onPressed: _add,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SAVED CONTACTS (STORED ON DEVICE)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDarkGrey),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.send_rounded, size: 14, color: AppColors.primaryRed),
                  label: const Text('TEST SIM SMS', style: TextStyle(color: AppColors.primaryRed, fontSize: 11)),
                  onPressed: _testDirectSimSms,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _contacts.isEmpty
                  ? const Center(child: Text('No emergency contacts added yet.'))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (ctx, i) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.lightBorder),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.softRed,
                              child: Icon(Icons.person, color: AppColors.primaryRed),
                            ),
                            title: Text(_contacts[i], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Direct SIM SMS + Cloud recipient'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.grey),
                              onPressed: () => _remove(i),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
