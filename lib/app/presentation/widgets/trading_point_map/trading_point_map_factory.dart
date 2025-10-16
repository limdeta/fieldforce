import 'package:fieldforce/app/domain/entities/regular_point_of_interest.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as app_route;
import 'package:fieldforce/app/domain/entities/point_of_interest.dart';
import 'package:fieldforce/app/presentation/widgets/combined_map_widget.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Контракт фабрики карт торговых точек для внедрения через app-слой
abstract class TradingPointMapFactory {
  Widget build({
    required TradingPoint tradingPoint,
    double height,
    BorderRadius borderRadius,
    double? zoom,
  });
}

class DefaultTradingPointMapFactory implements TradingPointMapFactory {
  static const double _defaultHeight = 220;
  static const BorderRadius _defaultRadius = BorderRadius.all(Radius.circular(10));
  static const double _defaultZoom = 16;

  @override
  Widget build({
    required TradingPoint tradingPoint,
    double height = _defaultHeight,
    BorderRadius borderRadius = _defaultRadius,
    double? zoom,
  }) {
    final latitude = tradingPoint.latitude;
    final longitude = tradingPoint.longitude;

    if (latitude == null || longitude == null) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: borderRadius,
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: const Text(
          'Координаты торговой точки отсутствуют',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    final latLng = LatLng(latitude, longitude);
    final route = app_route.Route(
      name: tradingPoint.name,
      pointsOfInterest: [
        RegularPointOfInterest(
          id: tradingPoint.id,
          name: tradingPoint.name,
          coordinates: latLng,
          type: PointType.client,
          status: VisitStatus.planned,
        ),
      ],
      status: app_route.RouteStatus.planned,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CombinedMapWidget(
          route: route,
          center: latLng,
          initialZoom: zoom ?? _defaultZoom,
        ),
      ),
    );
  }
}
