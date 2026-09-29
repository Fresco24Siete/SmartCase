import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../auth/logout_action.dart';
import '../../core/theme/app_colors.dart';
import '../../debug/ui/debug_telemetria_screen.dart';
import 'admin_ambulancia_screen.dart';
import 'admin_clinica_screen.dart';
import 'admin_crear_viaje_screen.dart';
import 'admin_sede_screen.dart';
import 'admin_smartcase_screen.dart';
import 'admin_theme.dart';
import 'admin_viajes_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 760;

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
                Icons.admin_panel_settings_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panel Administrador',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Gestión y monitoreo general',
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
        actions: const [
          LogoutAppBarButton(),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 28 : 16,
              vertical: 24,
            ),
            children: [
              // ── Banner resumen minimalista ────────────────────────────
              _SummaryBanner(),
              const SizedBox(height: 28),

              // ── Sección Gestión ──────────────────────────────────────
              const _SectionLabel('Gestión de Recursos'),
              const SizedBox(height: 12),
              _MenuGrid(
                crossAxisCount: isWide ? 4 : 2,
                items: [
                  _MenuItem(
                    icon: Icons.local_hospital_outlined,
                    title: 'Clínicas',
                    subtitle: 'Centros médicos',
                    color: AppColors.primaryAccent,
                    onTap: () => _push(context, const AdminClinicaScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.location_city_outlined,
                    title: 'Sedes',
                    subtitle: 'Sedes por clínica',
                    color: AppColors.secondary,
                    onTap: () => _push(context, const AdminSedeScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.emergency_outlined,
                    title: 'Ambulancias',
                    subtitle: 'Flota y vehículos',
                    color: const Color(0xFF6366F1), // Indigo suave
                    onTap: () => _push(context, const AdminAmbulanciaScreen()),
                  ),
                  _MenuItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'SmartCase',
                    subtitle: 'Cajas de órganos',
                    color: const Color(0xFFD97706), // Amber sobrio
                    onTap: () => _push(context, const AdminSmartCaseScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Sección Operaciones ──────────────────────────────────
              const _SectionLabel('Operaciones y Tránsito'),
              const SizedBox(height: 12),
              _LargeMenuTile(
                icon: Icons.monitor_heart_outlined,
                title: 'Telemetría en vivo',
                subtitle: 'Supervisar viajes activos y sensores en tiempo real',
                color: AppColors.primaryAccent,
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.successSubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'EN VIVO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                onTap: () => _push(context, const AdminViajesScreen()),
              ),
              const SizedBox(height: 10),
              _LargeMenuTile(
                icon: Icons.local_shipping_outlined,
                title: 'Crear nuevo viaje',
                subtitle: 'Asignar SmartCase, clínica destino, ambulancia y conductor',
                color: AppColors.secondary,
                onTap: () => _push(context, const AdminCrearViajeScreen()),
              ),

              // ── Sección Desarrollo (Debug) ───────────────────────────
              if (kDebugMode) ...[
                const SizedBox(height: 28),
                const _SectionLabel('Desarrollo y Pruebas'),
                const SizedBox(height: 12),
                _LargeMenuTile(
                  icon: Icons.bug_report_outlined,
                  title: 'Simulador de Telemetría',
                  subtitle: 'Emulación de sensores y mapa con datos ficticios',
                  color: AppColors.warning,
                  onTap: () => _push(context, const DebugTelemetriaScreen()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}

// ─── Banner Resumen Minimalista ───────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plataforma SmartCase Operativa',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Servicios de telemetría y sincronización en tiempo real conectados',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Etiqueta de Sección ──────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: AppColors.textSecondary,
      ),
    );
  }
}

// ─── Grid de Gestión ──────────────────────────────────────────────────────────

class _MenuGrid extends StatelessWidget {
  const _MenuGrid({
    required this.items,
    required this.crossAxisCount,
  });

  final List<_MenuItem> items;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: crossAxisCount > 2 ? 1.4 : 1.3,
      children: items,
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tile Grande de Operación ─────────────────────────────────────────────────

class _LargeMenuTile extends StatelessWidget {
  const _LargeMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          badge!,
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}