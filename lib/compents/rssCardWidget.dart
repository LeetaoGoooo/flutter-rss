import 'package:flutter/material.dart';

class RssCard extends StatefulWidget {

  final Widget avatar;
  final String title;
  final String subTitle;
  final int all;
  final int read;
  final int unread;

  RssCard({Key key, this.avatar, this.title, this.subTitle, this.all, this.read, this.unread}) : super(key: key);


  @override
  State<StatefulWidget> createState() => RssCardStateWidget(avatar,title,subTitle,all,read,unread);
}


class RssCardStateWidget extends State<RssCard> {
  final Widget avatar;
  final String title;
  final String subTitle;
  final int all;
  final int read;
  final int unread;

  final double circleRadius = 60.0;

  RssCardStateWidget(this.avatar, this.title, this.subTitle, this.all, this.read, this.unread);


  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      // color: Color(0xffE0E0E0),
      child: Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: circleRadius / 2.0,
                ),

                ///here we create space for the circle avatar to get ut of the box
                child: Container(
                  height: 320.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8.0,
                        offset: Offset(0.0, 5.0),
                      ),
                    ],
                  ),
                  width: double.infinity,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: circleRadius / 2,
                          ),
                          Text(
                            title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12.0),
                          ),
                          Text(
                            subTitle,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 8.0,
                                color: Colors.lightBlueAccent),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text(
                                      'ALL',
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      all.toString(),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black87,
                                          fontFamily: ''),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      'READED',
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.black54),
                                    ),
                                    Text(
                                      read.toString(),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black87,
                                          fontFamily: ''),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    Text(
                                      "UNREAD",
                                      style: TextStyle(
                                          fontSize: 10.0,
                                          color: Colors.black54),
                                    ),
                                    Text(
                                      unread.toString(),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black87,
                                          fontFamily: ''),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                ),
              ),

              ///Image Avatar
              Container(
                width: circleRadius,
                height: circleRadius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: Offset(0.0, 5.0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Center(
                    child: Container(
                      child: avatar,

                      /// replace your image with the Icon
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
  
}