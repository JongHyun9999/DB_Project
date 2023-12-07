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
  void tryTest() async {
    Map<String, dynamic> postData = {};
    bool isPostSucceeded = await PostServices.postTest(postData);
  }

  void tryinsertTest() async {
    Map<String, dynamic> postData = {};
    bool isPostSucceeded = await PostServices.postinsertTest(postData);
  }

  // List<Marker> markers = [
  //   Marker(
  //     point: LatLng(38.072178, 129.649330),
  //     width: 80,
  //     height: 80,
  //     child: IconButton(
  //       icon: Icon(
  //         Icons.location_on,
  //         size: 30,
  //         color: Colors.blueAccent,
  //       ),
  //       onPressed: () {
  //         tryTest();
  //       },
  //     ),
  //   ),
  //   Marker(
  //     point: LatLng(35.227672, 129.073069),
  //     width: 80,
  //     height: 80,
  //     child: Icon(
  //       Icons.location_on,
  //       size: 30,
  //       color: Colors.blueAccent,
  //     ),
  //   ),
  // ];

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
                Marker(
                  point: LatLng(38.072178, 129.649330),
                  width: 80,
                  height: 80,
                  child: IconButton(
                    icon: Icon(
                      Icons.location_on,
                      size: 30,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      tryTest();
                    },
                  ),
                ),
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
                      tryinsertTest();
                    },
                  ),
                ),
              ],
              builder: (context, markers) {
                return Stack(children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    child: Icon(
                      Icons.mail,
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
