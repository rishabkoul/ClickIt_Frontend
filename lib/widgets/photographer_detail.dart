import 'package:flutter/material.dart';
import '../constants.dart' as constants;

class PhotographerDetail extends StatelessWidget {
  final Map data;
  const PhotographerDetail({Key? key, this.data = const {}}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width / 5,
            backgroundImage: const NetworkImage(
                "${constants.imageProxyUrl}https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8cHJvZmlsZSUyMHBpY3R1cmUlMjBtYW58ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60"),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (int i = 0; i < int.parse("5"); i = i + 1)
              const Icon(
                Icons.star,
                color: Color(0xFFfe7f28),
                size: 30,
              )
          ]),
          const SizedBox(
            height: 20,
          ),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Email: ${data['email']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Phone no: +91 ${data['phone']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  if (data['address'] != null)
                    if (data['address'] != '')
                      const SizedBox(
                        height: 10,
                      ),
                  if (data['address'] != null)
                    if (data['address'] != '')
                      Text('Address: ${data['address']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Rate per Day : ${data['ratePerDay']} ₹',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('Kit: ${data['kit']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  if (data['categories'] != null)
                    if (data['categories'].length != 0)
                      const SizedBox(
                        height: 10,
                      ),
                  if (data['categories'] != null)
                    if (data['categories'].length != 0)
                      Text('Categorized as: ${data['categories']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
