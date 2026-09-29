// lib/shared/ui/viaje_mapa_widget.dart
//
// Mapa OSM reutilizable que muestra el recorrido GPS de un viaje.
// Usa flutter_map (ya en pubspec.yaml) + latlong2 (también ya incluido).
//
// Uso mínimo:
//   ViajeMapa(registros: _registros)

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../conductor/models/telemetria.dart';
import '../../core/theme/app_colors.dart';

class ViajeMapa extends StatefulWidget {
  const ViajeMapa({super.key, required this.registros, this.height = 280});

  /// Lista de registros de telemetría (puede estar vacía).
  final List<TelemetriaRegistro> registros;

  /// Alto del mapa en píxeles lógicos.
  final double height;

  @override
  State<ViajeMapa> createState() => _ViajeMapaState();
}

class _ViajeMapaState extends State<ViajeMapa> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  /// Filtra solo los registros que tienen coordenadas reales (no 0,0).
  List<TelemetriaRegistro> get _conGps =>
      widget.registros.where((r) => r.latitud != 0 || r.longitud != 0).toList();

  List<LatLng> get _puntos =>
      _conGps.map((r) => LatLng(r.latitud, r.longitud)).toList();

  /// Centro del mapa: último punto GPS conocido, o Bogotá como fallback.
  LatLng get _centro {
    if (_conGps.isEmpty) return const LatLng(4.711, -74.0721); // Bogotá
    final ultimo = _conGps.last;
    return LatLng(ultimo.latitud, ultimo.longitud);
  }

  /// Zoom inicial: más cercano si hay varios puntos, alejado si solo hay uno.
  double get _zoom => _conGps.length > 1 ? 14.0 : 13.0;

  void _centrarEnUltimo() {
    if (_conGps.isEmpty) return;
    _mapController.move(_centro, _zoom);
  }

  @override
  Widget build(BuildContext context) {
    final puntos = _puntos;
    final sinDatos = puntos.isEmpty;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // ── Mapa base ────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _centro,
                initialZoom: _zoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // Capa de tiles OpenStreetMap (no requiere API key)
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.metro_gps',
                  maxZoom: 19,
                ),

                // Línea de recorrido minimalista
                if (puntos.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: puntos,
                        strokeWidth: 3.0,
                        color: AppColors.primaryAccent,
                      ),
                    ],
                  ),

                // Marcadores: puntos intermedios + último
                if (_conGps.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      // Puntos intermedios
                      ..._conGps.take(_conGps.length - 1).map(
                            (r) => Marker(
                              point: LatLng(r.latitud, r.longitud),
                              width: 8,
                              height: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      // Último punto (posición actual)
                      Marker(
                        point: _centro,
                        width: 40,
                        height: 40,
                        child: const _PosicionActualPin(),
                      ),
                    ],
                  ),
              ],
            ),

            // ── Overlay "Sin datos GPS" ──────────────────────────────────
            if (sinDatos)
              Container(
                color: Colors.white.withOpacity(0.85),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.location_off_rounded,
                        size: 22,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Esperando coordenadas GPS…',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Botón "centrar" (esquina inferior derecha) ───────────────
            if (!sinDatos)
              Positioned(
                bottom: 12,
                right: 12,
                child: _MapButton(
                  icon: Icons.my_location_rounded,
                  tooltip: 'Centrar en posición actual',
                  onTap: _centrarEnUltimo,
                ),
              ),

            // ── Atribución OSM ───────────────────────────────────────────
            Positioned(
              bottom: 4,
              left: 8,
              child: Text(
                '© OpenStreetMap contributors',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pin animado para la posición actual ──────────────────────────────────────

class _PosicionActualPin extends StatelessWidget {
  const _PosicionActualPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo exterior sutil
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
        ),
        // Punto central
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primaryAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Botón flotante sobre el mapa ─────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.onTap,
    this.tooltip = '',
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
