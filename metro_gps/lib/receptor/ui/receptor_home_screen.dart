// lib/receptor/ui/receptor_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:metro_gps/receptor/models/viaje.dart';

import '../../auth/logout_action.dart';
import '../../core/telemetria_ws_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/ui/viaje_telemetria_screen.dart';
import '../receptor_viaje_api.dart';

class ReceptorHomeScreen extends StatefulWidget {
  const ReceptorHomeScreen({super.key});

  @override
  State<ReceptorHomeScreen> createState() => _ReceptorHomeScreenState();
}

class _ReceptorHomeScreenState extends State<ReceptorHomeScreen>
    with SingleTickerProviderStateMixin {
  final _api = ReceptorViajeApi();
  bool _cargando = true;
  String? _error;
  List<Viaje> _viajes = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _cargar();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    _fadeController.reset();
    final res = await _api.listarMisViajes();
    if (!mounted) return;
    setState(() {
      _cargando = false;
      if (res.isSuccess && res.data != null) {
        _viajes = res.data!;
      } else {
        _error = res.errorMessage;
      }
    });
    if (!_cargando) _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recepción de Envíos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Receptor de Clínica / Sede',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
          const LogoutAppBarButton(),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_cargando) return _buildLoading();
    if (_error != null) return _buildError();
    if (_viajes.isEmpty) return _buildEmpty();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _cargar,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: _viajes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _ViajeCard(
            viaje: _viajes[i],
            onTap: () => _abrirTelemetria(_viajes[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.errorSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 28,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Error de conexión',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _cargar,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 28,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin viajes asignados para recepción',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Los traslados destinados a tu clínica o sede aparecerán aquí con su código PIN.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirTelemetria(Viaje v) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ViajeTelemetriaScreen(
          viaje: v.toConductorViaje(),
          rolWs: TelemetriaWsRol.receptor,
          pinEntrega: v.pinEntrega,
        ),
      ),
    );
  }
}

// ─── Tarjeta de viaje ────────────────────────────────────────────────────────

class _ViajeCard extends StatelessWidget {
  const _ViajeCard({required this.viaje, required this.onTap});

  final Viaje viaje;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 14),
              _buildDetails(),
              if (viaje.pinEntrega != null && viaje.pinEntrega!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PinEntregaWidget(pin: viaje.pinEntrega!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.local_shipping_outlined,
            color: AppColors.primaryAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VIAJE #${viaje.idCorto}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              _EstadoBadge(estado: viaje.estadoViaje),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppColors.textMuted,
          size: 14,
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Row(
      children: [
        const Icon(
          Icons.person_outline_rounded,
          size: 15,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        const Text(
          'Conductor: ',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _idCorto(viaje.idUsuarioConductor),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        const Text(
          'Monitorear telemetría',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryAccent,
          ),
        ),
      ],
    );
  }

  static String _idCorto(String id) =>
      id.length > 8 ? '${id.substring(0, 8)}…' : id;
}

// ─── Badge de estado ─────────────────────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado});
  final String? estado;

  @override
  Widget build(BuildContext context) {
    final (color, bg, label) = _mapEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  static (Color, Color, String) _mapEstado(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'en_curso':
      case 'en curso':
      case 'transito':
        return (
          AppColors.primaryAccent,
          AppColors.primarySubtle,
          'En tránsito'
        );
      case 'pendiente':
        return (
          AppColors.warning,
          AppColors.warningSubtle,
          'Pendiente'
        );
      case 'finalizado':
      case 'entregado':
      case 'completado':
        return (
          AppColors.success,
          AppColors.successSubtle,
          'Entregado'
        );
      case 'cancelado':
      case 'muestra comprometida':
        return (
          AppColors.error,
          AppColors.errorSubtle,
          'Alerta crítica'
        );
      default:
        return (
          AppColors.textSecondary,
          AppColors.surfaceSubtle,
          estado ?? '—'
        );
    }
  }
}

// ─── PIN de entrega ───────────────────────────────────────────────────────────

class _PinEntregaWidget extends StatefulWidget {
  const _PinEntregaWidget({required this.pin});
  final String pin;

  @override
  State<_PinEntregaWidget> createState() => _PinEntregaWidgetState();
}

class _PinEntregaWidgetState extends State<_PinEntregaWidget> {
  bool _visible = false;

  void _copiarPin() {
    Clipboard.setData(ClipboardData(text: widget.pin));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'PIN copiado al portapapeles',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_rounded, size: 16, color: AppColors.primaryAccent),
          const SizedBox(width: 8),
          const Text(
            'PIN de entrega:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _visible ? widget.pin : '••••••',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: _visible ? 2 : 4,
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: _visible ? 'Ocultar PIN' : 'Mostrar PIN',
            onPressed: () => setState(() => _visible = !_visible),
            icon: Icon(
              _visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Copiar PIN',
            onPressed: _copiarPin,
            icon: const Icon(
              Icons.copy_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}