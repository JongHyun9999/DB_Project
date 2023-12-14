import 'package:db_project/service/post_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void getData(location) async {
    Map<String, dynamic> postData = {'location': location};
    await PostServices.getRadiation(postData);
  }

  void getSeaData(location) async {
    Map<String, dynamic> postData = {'location': location};
    await PostServices.getTriplehCesium(postData);
  }

  // void tryinsertTest() async {
  //   Map<String, dynamic> postData = {};
  //   await PostServices.postinsertTest(postData);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 여기부터 보시면 됩니다.

      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(37.3744667, 126.63472), // 지도의 초기중심
          initialZoom: 6.0, // 지도의 초기배율
        ),
        children: [
          TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'

              // "https://api.mapbox.com/styles/v1/comjke33/cloplyo3w005x01r7aih9emcr/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiY29tamtlMzMiLCJhIjoiY2xvcGw1NDJqMDhjdjJrcHR6YmdxZnJ2OSJ9.i8yj4Qj9cDrFQB29Uvwogw",
              ),
          MarkerLayer(markers: [
            Marker(
                point: LatLng(37.3744667, 126.63472),
                height: 200,
                width: 200,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.redAccent,
                      width: 1.0, // Adjust the width of the border as needed
                    ),
                  ),
                )),
            Marker(
                point: LatLng(37.3744667, 126.63472),
                height: 20,
                width: 20,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blueAccent),
                )),
          ]),
          MarkerClusterLayerWidget(
            options: MarkerClusterLayerOptions(
              maxClusterRadius: 45,
              size: const Size(40, 40),
              // anchor: AnchorPos.align(AnchorAlign.center),
              // fitBoundsOptions: const FitBoundsOptions(
              //   padding: EdgeInsets.all(50),
              //   maxZoom: 15,
              // ),
              markers: [
                // 부산 마커
                Marker(
                  point: LatLng(35.227672, 129.073069),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('부산');
                    },
                  ),
                ),
                // 포항 마커
                Marker(
                  point: LatLng(36.094278, 129.351573),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('포항');
                    },
                  ),
                ),
                // 평택 마커
                Marker(
                  point: LatLng(37.008465, 126.788861),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('평택');
                    },
                  ),
                ),
                // 통영 마커
                Marker(
                  point: LatLng(34.838904, 128.433859),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('통영');
                    },
                  ),
                ),
                // 제주 마커
                Marker(
                  point: LatLng(33.237763, 126.484734),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('제주');
                    },
                  ),
                ),
                // 전주 마커
                Marker(
                  point: LatLng(35.842721, 126.660557),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('전주');
                    },
                  ),
                ),
                // 장항 마커
                Marker(
                  point: LatLng(36.069545, 126.634638),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('장항');
                    },
                  ),
                ),
                // 인천 마커
                Marker(
                  point: LatLng(37.425516, 126.590826),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('인천');
                    },
                  ),
                ),
                // 완도 마커
                Marker(
                  point: LatLng(34.294321, 126.760395),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('완도');
                    },
                  ),
                ),
                // 여수 마커
                Marker(
                  point: LatLng(34.709787, 127.641631),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('여수');
                    },
                  ),
                ),
                // 목포 마커
                Marker(
                  point: LatLng(34.802495, 126.356356),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('목포');
                    },
                  ),
                ),
                // 강릉 마커
                Marker(
                  point: LatLng(37.757816, 128.960802),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      getData('강릉');
                    },
                  ),
                ),
                // 남해 동부
                Marker(
                  point: LatLng(34.649090, 129.096924),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('남해동부');
                    },
                  ),
                ),
                // 남해 서부
                Marker(
                  point: LatLng(34.067230, 126.301252),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('남해서부');
                    },
                  ),
                ),
                // 남해 중부
                Marker(
                  point: LatLng(34.253592, 127.888776),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('남해중부');
                    },
                  ),
                ),
                // 동해 북부
                Marker(
                  point: LatLng(38.699237, 129.031354),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('동해북부');
                    },
                  ),
                ),
                // 동해 중부
                Marker(
                  point: LatLng(37.318633, 129.893781),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('동해중부');
                    },
                  ),
                ),
                // 서해 남부
                Marker(
                  point: LatLng(34.906207, 125.228815),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('서해남부');
                    },
                  ),
                ),
                // 서해 북부
                Marker(
                  point: LatLng(37.504407, 125.143892),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('서해북부');
                    },
                  ),
                ),
                // 서해 중부
                Marker(
                  point: LatLng(36.039334, 125.254945),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('서해중부');
                    },
                  ),
                ),
                // 제주 해역
                Marker(
                  point: LatLng(33.092075, 126.639837),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      getSeaData('제주해역');
                    },
                  ),
                ),
              ],
              builder: (context, markers) {
                return Stack(children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Icon(
                      Icons.location_on,
                      // color: Colors.transparent,
                      color: Colors.blue,
                      size: 50,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.redAccent),
                      child: Center(
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
