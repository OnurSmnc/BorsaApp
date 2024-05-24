import 'package:flutter/material.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

class MostChanged extends StatelessWidget {
  final List<dynamic> mostChanged;
  final double myWidth;
  final double myHeight;

  MostChanged(
      {required this.mostChanged,
      required this.myWidth,
      required this.myHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: myWidth,
      height: myHeight * 0.2, // En çok değişen ilk dört altın için ayrılan alan
      margin: EdgeInsets.symmetric(vertical: 1), // Kenar boşluğu ekleme
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          mostChanged.isEmpty
              ? Text(
                  '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              : Text(
                  'En Çok Değişen Altın',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
          Expanded(
            child: mostChanged.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mostChanged.length,
                    itemBuilder: (context, index) {
                      var item = mostChanged[index];
                      return Container(
                        width: myWidth * 0.5,
                        padding: EdgeInsets.all(1),
                        child: Card(
                          color: Color.fromARGB(255, 23, 23, 23),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                item['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              RoundedBackgroundText(
                                'Değişim: ${item['Degisim']}',
                                style: TextStyle(
                                  fontSize: 15,
                                  backgroundColor: item['degisim'] < 0
                                      ? Colors.red
                                      : Colors.green,
                                  color: Colors.white,
                                ),
                                innerRadius: 15.0,
                                outerRadius: 10.0,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Alış: ${item['Alis']}',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                'Satış: ${item['Satis']}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
