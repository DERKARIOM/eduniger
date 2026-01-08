import 'package:flutter/material.dart';

class EdunaPage extends StatefulWidget {
  const EdunaPage({super.key});

  @override
  State<EdunaPage> createState() => _EdunaPageState();
}

class _EdunaPageState extends State<EdunaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('assets/icon_bootomBart/ia.png',color: Colors.green,width: 30,height: 30,),
                Spacer(),
                IconButton(onPressed: () {}, icon: Icon(Icons.history,color: Colors.black,size: 30,)),
              ],
            ),
          ),
          Expanded(child: Center(child: Text("Eduna ")))
        ],
      ),
      bottomNavigationBar:
      Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child:Container(
                  margin: const EdgeInsets.only(right: 5),
                  height: 49,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.4,
                    ),
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon:  IconButton(onPressed: () {}, icon: Icon(Icons.mic,color: Colors.black,size: 27,)),
                      suffixIcon:  IconButton(onPressed: () {}, icon: Icon(Icons.document_scanner,color: Colors.black,size: 27,)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      hintText: 'message',
                      hintStyle: TextStyle(color: Colors.grey[600]),

                  ),
                )
            ),
            ),
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green,
              child: IconButton(onPressed: () {}, icon: Icon(Icons.send,color: Colors.white,size: 30,) ),
            )
          ],

        ),
      ),
    );
  }
}
