import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/domain/entities/invitation.dart';
import 'package:grocery_store/ui/view_model/session/session_controller.dart';
import 'package:provider/provider.dart';

/// Lets a user without a store join one as employee with an invitation code.
class JoinStorePage extends StatefulWidget {
  const JoinStorePage({super.key});

  @override
  State<JoinStorePage> createState() => _JoinStorePageState();
}

class _JoinStorePageState extends State<JoinStorePage> {
  final _controller = TextEditingController();
  bool _joining = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (_joining) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _joining = true;
      _error = null;
    });

    final failure =
        await context.read<SessionController>().joinStore(_controller.text);

    // On success the whole app switches to the store and this page is
    // disposed; only touch the UI if it is still mounted.
    if (!mounted) return;
    setState(() {
      _joining = false;
      _error = failure?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirme a una tienda')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.vpn_key_outlined, size: 72),
              const SizedBox(height: 16),
              Text(
                'Escribe el código que te compartió el dueño de la tienda.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: Invitation.codeLength + 1, // + dash
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9-]')),
                ],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 4,
                    ),
                decoration: InputDecoration(
                  hintText: 'XXXX-XXXX',
                  errorText: _error,
                  errorMaxLines: 3,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _join(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _joining ? null : _join,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _joining
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Unirme'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
