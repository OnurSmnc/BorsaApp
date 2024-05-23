import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rounded_background_text/rounded_background_text.dart';

class GoldPage extends StatefulWidget {
  const GoldPage({super.key});

  @override
  State<GoldPage> createState() => _GoldPageState();
}

class _GoldPageState extends State<GoldPage> {
  late List<dynamic> _data = [];
  Future<void> _getData() async {
    final response =
        await http.get(Uri.parse('https://doviz-api.onrender.com/api/altin'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] is Map) {
        setState(() {
          _data = (responseData['data'] as Map<String, dynamic>)
              .entries
              .map((entry) {
            return {
              'name': entry.key,
              ...entry.value,
            };
          }).toList();
        });
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  double _parseDegisim(String degisim) {
    return double.parse(
        degisim.replaceAll('%', '').replaceAll(',', '.').trim());
  }

  @override
  Widget build(BuildContext context) {
    double myHeight = MediaQuery.of(context).size.height;
    double myWidht = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ALTIN',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        height: myHeight,
        width: myWidht,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey, Colors.white]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: myWidht,
              height: myHeight * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: _data.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemCount: _data.length,
                      itemBuilder: (context, index) {
                        var item = _data[index];
                        var degisim = _parseDegisim(item['Degisim']);
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                          color: Color.fromARGB(255, 23, 23, 23),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    SizedBox(width: 8),
                                    RoundedBackgroundText(
                                      'Değişim: ${item['Degisim']}',
                                      style: TextStyle(
                                          fontSize: 15,
                                          backgroundColor: degisim < 0
                                              ? Colors.red
                                              : Colors.green,
                                          color: Colors.white),
                                      innerRadius: 15.0,
                                      outerRadius: 10.0,
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
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
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
