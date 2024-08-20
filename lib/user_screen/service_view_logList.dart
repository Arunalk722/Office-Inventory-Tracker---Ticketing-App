import 'package:flutter/material.dart';
import '../widgets/input_style_decoration.dart';
import '../widgets/system_functions_manager.dart';

class ServiceLogList extends StatefulWidget {
  final String ticketNo;

  const ServiceLogList({required this.ticketNo, Key? key}) : super(key: key);

  @override
  State<ServiceLogList> createState() => _ServiceLogListState();
}

class _ServiceLogListState extends State<ServiceLogList> {
  TextEditingController _tktNo = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tktNo.text = widget.ticketNo;
    getTicketLog();
  }

  final List<String> logHader = [];
  final List<String> tktEvent = [];
  final List<String> enterDate = [];
  final List<String> enterTime = [];
  final List<String> enterBy = [];

  Future<void> getTicketLog() async {
    final conn = await ConnectionManager.createConnection();
    await conn.connect();
    logHader.clear();
    tktEvent.clear();
    enterBy.clear();
    enterDate.clear();
    enterTime.clear();
    String formattedIDno;
    if (_tktNo.text.isNotEmpty) {
      if (int.tryParse(_tktNo.text) != null) {
        int idOnly = int.parse(_tktNo.text);
        formattedIDno =
            '0' * (5 - idOnly.toString().length) + idOnly.toString();
        _tktNo.text = formattedIDno;
      } else {
        formattedIDno = _tktNo.text;
      }
    } else {
      formattedIDno = '';
    }
    await conn
        .execute(
            'SELECT el.TktEvent,el.TktLogHeader,el.EnterDate,el.EnterTime,ul.Name FROM tbl_tkteventlog as el join tbl_userlist as ul on ul.UserID=el.EnterBy  where el.TktIdString="${_tktNo.text}" order by el.idtbl_tkteventlog asc')
        .then((results) {
      for (var row in results.rows) {
        tktEvent.add(row.assoc()["TktEvent"].toString());
        logHader.add(row.assoc()["TktLogHeader"].toString());
        enterDate.add(row.assoc()["EnterDate"].toString());
        enterTime.add(row.assoc()["EnterTime"].toString());
        enterBy.add(row.assoc()["Name"].toString());
      }

      setState(() {});
    });
    conn.close();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          'TICKET EVENT LOG',
          style: TextStyle(fontSize: sw * 0.07),
        )),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tktNo,
                    decoration: InputDecorations.inputDecoration(
                        hinttext: '000001',
                        labletext: 'TICKET NO',
                        icons: const Icon(Icons.airplane_ticket)),
                  ),
                ),
                Expanded(
                    child: ButtonDecorations.buttonDecoration(
                        btnText: '',
                        btnIcon: Icon(Icons.scanner),
                        pcolors: Colors.grey,
                        tcolors: Colors.indigo,
                        onPressed: () {
                          getTicketLog();
                        }))
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tktEvent.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${logHader[index]}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${tktEvent[index]}',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: sw * 0.04,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.calendar_month),
                              Text(
                                'Enter Time: ${enterDate[index]} ${enterTime[index]}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.person),
                              Text(
                                '${enterBy[index]}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: sw * 0.035,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          )
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
