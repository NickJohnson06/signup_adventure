import 'package:flutter/material.dart';
import 'success_screen.dart';
import '../widgets/progress_tracker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Avatar picker
  final List<String> _avatars = const ['🤑', '🤠', '👽', '🤖', '🧟‍♂️'];
  String _selectedAvatar = '🤑';

  // Password strength state
  int _pwdScore = 0;            // 0..5
  double _pwdStrength = 0;      // 0..1
  String _pwdLabel = 'Very Weak';
  Color _pwdColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_recalc);
    _emailController.addListener(_recalc);
    _passwordController.addListener(() {
      _recalc();
      _updatePasswordStrength(_passwordController.text);
    });
    _dobController.addListener(_recalc);
  }

  void _recalc() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_recalc);
    _emailController.removeListener(_recalc);
    _passwordController.removeListener(_recalc);
    _dobController.removeListener(_recalc);

    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Password strength evaluation (0..5) + label/color
  void _updatePasswordStrength(String input) {
    final lengthOK = input.length >= 8;
    final hasLower = RegExp(r'[a-z]').hasMatch(input);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(input);
    final hasDigit = RegExp(r'\d').hasMatch(input);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(input);

    int score = 0;
    if (lengthOK) score++;
    if (hasLower) score++;
    if (hasUpper) score++;
    if (hasDigit) score++;
    if (hasSymbol) score++;

    String label;
    Color color;
    if (score <= 1) {
      label = 'Very Weak';
      color = Colors.red;
    } else if (score == 2) {
      label = 'Weak';
      color = Colors.orange;
    } else if (score == 3) {
      label = 'Fair';
      color = Colors.amber;
    } else if (score == 4) {
      label = 'Good';
      color = Colors.lightGreen;
    } else {
      label = 'Strong';
      color = Colors.green;
    }

    setState(() {
      _pwdScore = score;
      _pwdLabel = label;
      _pwdColor = color;
      _pwdStrength = (score / 5).clamp(0, 1);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _isLoading = false);

        // Badge eligibility
        final nameOk = _nameController.text.trim().isNotEmpty;
        final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
            .hasMatch(_emailController.text.trim());
        final passwordOk = _pwdScore >= 2; 
        final dobOk = _dobController.text.trim().isNotEmpty;
        final avatarOk = _selectedAvatar.isNotEmpty;

        final isProfileComplete = nameOk && emailOk && passwordOk && dobOk && avatarOk;
        final isStrongPassword = _pwdScore >= 4;
        final isEarlyBird = DateTime.now().hour < 12;

        final List<String> badges = [];
        if (isStrongPassword) badges.add('Strong Password Master');
        if (isEarlyBird) badges.add('The Early Bird Special');
        if (isProfileComplete) badges.add('Profile Completer');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(
              userName: _nameController.text.trim(),
              avatarEmoji: _selectedAvatar,
              badges: badges,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Progress steps 
    final nameOk = _nameController.text.trim().isNotEmpty;
    final emailOk =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_emailController.text.trim());
    final passwordOk = _pwdScore >= 2;
    final dobOk = _dobController.text.trim().isNotEmpty;
    final avatarOk = _selectedAvatar.isNotEmpty;
    final steps = [nameOk, emailOk, passwordOk, dobOk, avatarOk];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Progress bar + milestone
                ProgressTracker(steps: steps),
                const SizedBox(height: 16),

                // Header
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.deepPurple[800]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your adventure profile!',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Name
                _buildTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'What should we call you on this adventure?' : null,
                ),
                const SizedBox(height: 20),

                // Email
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'We need your email for adventure updates!';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Oops! That doesn\'t look like a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // DOB
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: _selectDate,
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'When did your adventure begin?' : null,
                ),
                const SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  onChanged: _updatePasswordStrength,
                  decoration: InputDecoration(
                    labelText: 'Secret Password',
                    prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Every adventurer needs a secret password!';
                    if (v.length < 6) return 'Make it stronger! At least 6 characters';
                    return null;
                  },
                ),

                // Strength meter
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _pwdStrength),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 8,
                            backgroundColor: Colors.deepPurple.withOpacity(0.15),
                            color: Color.lerp(Colors.red, Colors.green, value),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_pwdLabel, style: TextStyle(color: _pwdColor, fontWeight: FontWeight.w700)),
                            Text('${(_pwdStrength * 100).round()}%'),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Avatar picker
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose your avatar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.deepPurple[800]),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _avatars.map((emoji) {
                    final selected = _selectedAvatar == emoji;
                    return ChoiceChip(
                      label: Text(emoji, style: const TextStyle(fontSize: 18)),
                      selected: selected,
                      selectedColor: Colors.deepPurple[200],
                      onSelected: (_) => setState(() => _selectedAvatar = emoji),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: selected ? Colors.deepPurple : Colors.deepPurple.shade100,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Submit
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Start My Adventure', style: TextStyle(fontSize: 18, color: Colors.white)),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: validator,
    );
  }
}
