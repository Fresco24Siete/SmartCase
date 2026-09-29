import 'package:flutter/material.dart';

import '../../conductor/models/viaje.dart';
import '../../core/telemetria_ws_paths.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/ui/viaje_telemetria_screen.dart';
import '../viaje_api.dart';
import 'admin_theme.dart';

class AdminViajesScreen extends StatefulWidget {
  const AdminViajesScreen({super.key});

  @override
  State<AdminViajesScreen> createState() =>
      _AdminViajesScreenState();
}

class _AdminViajesScreenState extends State<AdminViajesScreen> {
  final _api = ViajeApi();
  bool _cargando = true;
  String? _error;
  List<Viaje> _viajes = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    final res = await _api.listarPorEstado('transito');
    if (!mounted) return;
    setState(() {
      _cargando = false;
      if (res.isSuccess && res.data != null) {
        _viajes = res.data!;
      } else {
        _error = res.errorMessage ??
            'No se pudieron cargar viajes';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Telemetría en vivo'),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? AdminErrorState(
                      message: _error!, onRetry: _cargar)
                  : _viajes.isEmpty
                      ? const AdminEmptyState(
                          message: 'No hay viajes en tránsito',
                          icon: Icons.route_outlined,
                        )
                      : Column(
                          children: [
                            // Cabecera de estado
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${_viajes.length} viaje${_viajes.length == 1 ? '' : 's'} activo${_viajes.length == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'En tránsito',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: _cargar,
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(
                                          16, 12, 16, 32),
                                  itemCount: _viajes.length,
                                  itemBuilder: (context, i) {
                                    final v = _viajes[i];
                                    return _ViajeCard(
                                      viaje: v,
                                      onTap: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              ViajeTelemetriaScreen(
                                            viaje: v,
                                            rolWs:
                                                TelemetriaWsRol.admin,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }
}

class _ViajeCard extends StatelessWidget {
  const _ViajeCard({required this.viaje, required this.onTap});
  final Viaje viaje;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final estado = viaje.estadoViaje ?? 'tránsito';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AdminColors.divider),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AdminIconAvatar(
                    icon: Icons.local_shipping_outlined,
                    color: AdminColors.cyanDim,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Viaje ${viaje.idCorto}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        Text(
                          viaje.fechaInicio ?? '—',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AdminColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminStatusBadge(
                    label: estado,
                    color: _colorEstado(estado),
                  ),
                ],
              ),
              if (viaje.idUsuarioReceptor != null &&
                  viaje.idUsuarioReceptor!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: AdminColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Receptor: ${_idCorto(viaje.idUsuarioReceptor)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AdminColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Ver telemetría →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AdminColors.cyanDim,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'transito':
      case 'tránsito':
        return AdminColors.cyanDim;
      case 'entregado':
        return AdminColors.success;
      case 'muestra comprometida':
        return AdminColors.danger;
      default:
        return AdminColors.textSecondary;
    }
  }

  static String _idCorto(String? id) {
    if (id == null || id.isEmpty) return '—';
    return id.length > 8 ? '${id.substring(0, 8)}…' : id;
  }
}