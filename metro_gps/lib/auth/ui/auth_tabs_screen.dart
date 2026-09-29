// lib/auth/ui/auth_tabs_screen.dart

import 'package:flutter/material.dart';

import '../../admin/clinica_api.dart';
import '../../admin/ui/admin_panel_screen.dart';
import '../../conductor/ui/conductor_home_screen.dart';
import '../../receptor/ui/receptor_home_screen.dart';
import '../../core/api_constants.dart';
import '../../core/session_store.dart';
import '../../core/theme/app_colors.dart';
import '../auth_api.dart';
import '../models/auth_models.dart';
import '../models/usuario_rol_opciones.dart';

class AuthTabsScreen extends StatefulWidget {
  const AuthTabsScreen({super.key});

  @override
  State<AuthTabsScreen> createState() => _AuthTabsScreenState();
}

class _AuthTabsScreenState extends State<AuthTabsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _abrirSiHaySesion());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _enLogin => _tabController.index == 0;

  bool _esAdmin(String? rol) =>
      rol != null && rol.trim().toLowerCase() == UsuarioRolBd.admin;
  bool _esConductor(String? rol) =>
      rol != null && rol.trim().toLowerCase() == UsuarioRolBd.coductor;
  bool _esReceptor(String? rol) =>
      rol != null && rol.trim().toLowerCase() == UsuarioRolBd.receptor;

  void _abrirSiHaySesion() {
    if (!ClinicaApi.sharedClient.hasSession) return;
    final rol = SessionStore.instance.rol;
    _navegar(rol);
  }

  void _navegar(String? rol) {
    if (!mounted) return;
    if (_esAdmin(rol)) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AdminPanelScreen()),
      );
    } else if (_esConductor(rol)) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => ConductorHomeScreen()),
      );
    } else if (_esReceptor(rol)) {
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ReceptorHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo y encabezado minimalista ────────────────────────
                  const _BrandHeader(),
                  const SizedBox(height: 28),

                  // ── Selector de pestañas segmentado (Pill minimalista) ─────
                  _SegmentedTabPicker(
                    index: _tabController.index,
                    onTabSelected: (i) => _tabController.animateTo(i),
                  ),
                  const SizedBox(height: 20),

                  // ── Contenedor de formulario principal ─────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: EdgeInsets.all(isDesktop ? 28 : 20),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeInOutCubic,
                      child: _enLogin
                          ? _LoginForm(
                              onRegistrarse: () => _tabController.animateTo(1),
                            )
                          : _RegisterForm(
                              onIniciarSesion: () => _tabController.animateTo(0),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // ── Pie de página sutil ──────────────────────────────────
                  const Center(
                    child: Text(
                      'SmartCase Telemetry • Dispositivo y Transporte Seguro',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Cabecera de marca minimalista ──────────────────────────────────────────

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Icon(
              Icons.sensors_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'SmartCase',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Cadena de custodia y telemetría en tiempo real',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ─── Selector Segmentado Tipo Pill ───────────────────────────────────────────

class _SegmentedTabPicker extends StatelessWidget {
  const _SegmentedTabPicker({
    required this.index,
    required this.onTabSelected,
  });

  final int index;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentItem(
              label: 'Iniciar sesión',
              isSelected: index == 0,
              onTap: () => onTabSelected(0),
            ),
          ),
          Expanded(
            child: _SegmentItem(
              label: 'Crear cuenta',
              isSelected: index == 1,
              onTap: () => onTabSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

// ─── Formulario de Login ──────────────────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.onRegistrarse});
  final VoidCallback onRegistrarse;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _api = AuthApi();
  bool _cargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _esAdmin(String? r) =>
      r != null && r.trim().toLowerCase() == UsuarioRolBd.admin;
  bool _esConductor(String? r) =>
      r != null && r.trim().toLowerCase() == UsuarioRolBd.coductor;
  bool _esReceptor(String? r) =>
      r != null && r.trim().toLowerCase() == UsuarioRolBd.receptor;

  Future<void> _navegar(String? rol) async {
    if (_esAdmin(rol)) {
      await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AdminPanelScreen()),
        (_) => false,
      );
    } else if (_esConductor(rol)) {
      await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => ConductorHomeScreen()),
        (_) => false,
      );
    } else if (_esReceptor(rol)) {
      await Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const ReceptorHomeScreen()),
        (_) => false,
      );
    }
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final res = await _api.login(
        LoginInput(email: _email.text.trim(), password: _password.text),
      );
      if (!mounted) return;
      if (res.isSuccess) {
        final rol = SessionStore.instance.rol ?? res.rol;
        await _navegar(rol);
        if (!mounted) return;
        if (!_esAdmin(rol) && !_esConductor(rol) && !_esReceptor(rol)) {
          _showSnack(
            rol == null || rol.isEmpty
                ? 'Sesión iniciada, pero no se detectó el rol'
                : 'Sesión iniciada (${UsuarioRolBd.etiqueta(rol)})',
            isError: false,
          );
        }
      } else {
        _showSnack(
          res.errorMessage ?? 'Error (${res.statusCode})',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack(
        'No se pudo conectar al servidor (${ApiConstants.baseUrl})',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MinimalField(
            controller: _email,
            label: 'Correo electrónico',
            hint: 'usuario@clinica.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Ingresa tu correo'
                : null,
          ),
          const SizedBox(height: 16),
          _MinimalField(
            controller: _password,
            label: 'Contraseña',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscureText: _ocultarPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!_cargando) _enviar();
            },
            suffixIcon: IconButton(
              splashRadius: 18,
              onPressed: () =>
                  setState(() => _ocultarPassword = !_ocultarPassword),
              icon: Icon(
                _ocultarPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingresa la contraseña' : null,
          ),
          const SizedBox(height: 24),
          _PrimaryActionButton(
            label: 'Entrar',
            isLoading: _cargando,
            onPressed: _enviar,
          ),
          const SizedBox(height: 16),
          _AuthFooterText(
            prompt: '¿No tienes cuenta aún?',
            action: 'Crear cuenta',
            onTap: widget.onRegistrarse,
          ),
        ],
      ),
    );
  }
}

// ─── Formulario de Registro ──────────────────────────────────────────────────

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({required this.onIniciarSesion});
  final VoidCallback onIniciarSesion;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCompleto = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _api = AuthApi();
  bool _cargando = false;
  bool _ocultarPassword = true;
  String _rol = UsuarioRolBd.coductor;

  @override
  void dispose() {
    _nombreCompleto.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    final res = await _api.registro(
      RegistroInput(
        nombreCompleto: _nombreCompleto.text.trim(),
        rol: _rol,
        email: _email.text.trim(),
        password: _password.text,
      ),
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.isSuccess
              ? 'Cuenta creada con éxito. Inicia sesión.'
              : (res.errorMessage ?? 'Error (${res.statusCode})'),
        ),
        backgroundColor: res.isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
    if (res.isSuccess) widget.onIniciarSesion();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MinimalField(
            controller: _nombreCompleto,
            label: 'Nombre completo',
            hint: 'Ej. Dra. Camila Rojas',
            icon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Ingresa el nombre completo'
                : null,
          ),
          const SizedBox(height: 16),

          // Selector de rol minimalista
          const Text(
            'Rol en el sistema',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: UsuarioRolBd.todos.map((r) {
              final isSelected = _rol == r;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: r == UsuarioRolBd.todos.last ? 0 : 8,
                  ),
                  child: InkWell(
                    onTap: _cargando ? null : () => setState(() => _rol = r),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primarySubtle
                            : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        UsuarioRolBd.etiqueta(r),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryAccent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          _MinimalField(
            controller: _email,
            label: 'Correo electrónico',
            hint: 'correo@ejemplo.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Ingresa el correo'
                : null,
          ),
          const SizedBox(height: 16),

          _MinimalField(
            controller: _password,
            label: 'Contraseña',
            hint: 'Mínimo 6 caracteres',
            icon: Icons.lock_outline_rounded,
            obscureText: _ocultarPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!_cargando) _enviar();
            },
            suffixIcon: IconButton(
              splashRadius: 18,
              onPressed: () =>
                  setState(() => _ocultarPassword = !_ocultarPassword),
              icon: Icon(
                _ocultarPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Ingresa la contraseña' : null,
          ),
          const SizedBox(height: 24),

          _PrimaryActionButton(
            label: 'Crear cuenta',
            isLoading: _cargando,
            onPressed: _enviar,
          ),
          const SizedBox(height: 16),

          _AuthFooterText(
            prompt: '¿Ya estás registrado?',
            action: 'Inicia sesión',
            onTap: widget.onIniciarSesion,
          ),
        ],
      ),
    );
  }
}

// ─── Campo de entrada minimalista ─────────────────────────────────────────────

class _MinimalField extends StatelessWidget {
  const _MinimalField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofillHints: autofillHints,
          onFieldSubmitted: onFieldSubmitted,
          validator: validator,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ─── Botón Principal Minimalista ──────────────────────────────────────────────

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
      ),
    );
  }
}

// ─── Enlace de pie de formulario ──────────────────────────────────────────────

class _AuthFooterText extends StatelessWidget {
  const _AuthFooterText({
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            children: [
              TextSpan(text: '$prompt '),
              TextSpan(
                text: action,
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}