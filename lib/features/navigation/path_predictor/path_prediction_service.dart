import 'package:fieldforce/features/navigation/map/domain/entities/map_point.dart';

abstract class PathPredictionService {
  Future<List<MapPoint>> predictPaths(List<MapPoint> points);
}