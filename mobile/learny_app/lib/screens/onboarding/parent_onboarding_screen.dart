import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../shared/gradient_scaffold.dart';

class ParentOnboardingScreen extends StatefulWidget {
  const ParentOnboardingScreen({super.key});

  @override
  State<ParentOnboardingScreen> createState() => _ParentOnboardingScreenState();
}

class _ParentOnboardingScreenState extends State<ParentOnboardingScreen> {
  final _nameController = TextEditingController(text: 'Parent');
  final _emailController = TextEditingController(text: 'parent@example.com');
  final _passwordController = TextEditingController(text: 'secret123');
  final _childNameController = TextEditingController(text: 'Alex');
  final _childGradeController = TextEditingController(text: '6th');

  bool _isLoginMode = true;
  bool _busy = false;
  String? _error;
  String? _selectedChildId;
  String? _latestCode;
  List<Map<String, dynamic>> _devices = const [];
  bool _dailySummary = true;
  bool _contentGuardrails = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _childNameController.dispose();
    _childGradeController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    final state = AppStateScope.of(context);
    final ok = await state.parentAuthenticateForOnboarding(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      loginMode: _isLoginMode,
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = ok ? null : 'Authentication failed. Check credentials.';
      _selectedChildId ??= state.children.isNotEmpty
          ? state.children.first.id
          : null;
    });
  }

  Future<void> _addChild() async {
    final state = AppStateScope.of(context);
    final created = await state.createChildForOnboarding(
      name: _childNameController.text.trim(),
      gradeLevel: _childGradeController.text.trim(),
      preferredLanguage: 'en',
    );

    if (!mounted) return;
    setState(() {
      _selectedChildId = created?.id ?? _selectedChildId;
      _childNameController.text = 'Child ${state.children.length + 1}';
    });
  }

  Future<void> _generateCode() async {
    if (_selectedChildId == null) return;
    final state = AppStateScope.of(context);
    final code = await state.generateParentLinkCode(_selectedChildId!);
    if (!mounted) return;
    setState(() => _latestCode = code);
  }

  Future<void> _loadDevices() async {
    if (_selectedChildId == null) return;
    final state = AppStateScope.of(context);
    final devices = await state.fetchLinkedDevices(_selectedChildId!);
    if (!mounted) return;
    setState(() => _devices = devices);
  }

  Future<void> _revokeDevice(String deviceId) async {
    if (_selectedChildId == null) return;
    final state = AppStateScope.of(context);
    await state.revokeLinkedDevice(_selectedChildId!, deviceId);
    await _loadDevices();
  }

  Future<void> _complete() async {
    final state = AppStateScope.of(context);
    final ok = await state.completeParentOnboarding(
      controls: {
        'daily_summary': _dailySummary,
        'content_guardrails': _contentGuardrails,
      },
    );
    if (!ok) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not complete onboarding. Please retry.';
      });
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return GradientScaffold(
      gradient: LearnyGradients.trust,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text(
                'Parent setup',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.welcome),
                child: const Text('Switch role'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your account, add children, link devices, and set baseline controls.',
          ),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(value: true, label: Text('Login')),
              ButtonSegment<bool>(value: false, label: Text('Sign up')),
            ],
            selected: {_isLoginMode},
            onSelectionChanged: (next) {
              setState(() => _isLoginMode = next.first);
            },
          ),
          const SizedBox(height: 12),
          if (!_isLoginMode) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _busy ? null : _authenticate,
            child: Text(
              _isLoginMode ? 'Login as parent' : 'Create parent account',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 28),
          Text(
            'Children (${state.children.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _childNameController,
                  decoration: const InputDecoration(labelText: 'Child name'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _childGradeController,
                  decoration: const InputDecoration(labelText: 'Grade'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _busy ? null : _addChild,
            child: const Text('Add child profile'),
          ),
          if (state.children.isNotEmpty) ...[
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedChildId ?? state.children.first.id,
              decoration: const InputDecoration(labelText: 'Active child'),
              items: state.children
                  .map(
                    (child) => DropdownMenuItem(
                      value: child.id,
                      child: Text('${child.name} (${child.gradeLabel})'),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedChildId = value),
            ),
          ],
          const SizedBox(height: 24),
          Text('Device linking', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: _selectedChildId == null ? null : _generateCode,
                child: const Text('Generate link code'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _selectedChildId == null ? null : _loadDevices,
                child: const Text('Refresh devices'),
              ),
            ],
          ),
          if (_latestCode != null) ...[
            const SizedBox(height: 8),
            SelectableText(
              'Code: $_latestCode',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (_devices.isNotEmpty) ...[
            const SizedBox(height: 8),
            ..._devices.map(
              (device) => ListTile(
                title: Text(device['name']?.toString() ?? 'Unknown device'),
                subtitle: Text(device['platform']?.toString() ?? 'unknown'),
                trailing: IconButton(
                  onPressed: () =>
                      _revokeDevice(device['id']?.toString() ?? ''),
                  icon: const Icon(Icons.link_off_rounded),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Baseline controls',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily parent summary'),
            value: _dailySummary,
            onChanged: (value) => setState(() => _dailySummary = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Content guardrails'),
            value: _contentGuardrails,
            onChanged: (value) => setState(() => _contentGuardrails = value),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: state.children.length < 2 ? null : _complete,
            child: const Text('Complete parent onboarding'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Need at least 2 child profiles before finishing parent onboarding.',
          ),
        ],
      ),
    );
  }
}
