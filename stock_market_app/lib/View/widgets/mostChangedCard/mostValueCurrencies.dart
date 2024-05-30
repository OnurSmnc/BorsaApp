import 'package:flutter/material.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

class MostValualeCurrencies extends StatelessWidget {
  final List<MapEntry<String, num>> mostChanged;
  final double myWidth;
  final double myHeight;
  List<MapEntry<String, num>> mostUsed;

  MostValualeCurrencies(
      {required this.mostChanged,
      required this.myWidth,
      required this.myHeight,
      required this.mostUsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: myWidth,
      height: myHeight * 0.2,
      margin: EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Expanded(
              child: mostChanged.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mostUsed.length,
                      itemBuilder: (context, index) {
                        var item = mostUsed[index].key;
                        var value =
                            (1 / mostUsed[index].value).toStringAsFixed(2);
                        return Container(
                          width: myWidth * 0.33,
                          child: Card(
                            color: Color.fromARGB(255, 23, 23, 23),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${item}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(
                                  height: 1,
                                ),
                                Text('1 $item = ${value} ₺',
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        );
                      },
                    ))
        ],
      ),
    );
  }
}
