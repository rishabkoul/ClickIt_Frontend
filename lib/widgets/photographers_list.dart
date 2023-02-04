import 'package:click_it/pages/photographer_page.dart';
import 'package:flutter/material.dart';
import '../constants.dart' as constants;

class PhotographersList extends StatefulWidget {
  final List data;
  const PhotographersList({Key? key, this.data = const []}) : super(key: key);

  @override
  State<PhotographersList> createState() => _PhotographersListState();
}

class _PhotographersListState extends State<PhotographersList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(widget.data[index]["name"]!),
            subtitle: Row(children: [
              for (int i = 0; i < int.parse("5"); i = i + 1)
                const Icon(
                  Icons.star,
                  color: Color(0xFFfe7f28),
                )
            ]),
            leading: Image.network(
                "${constants.imageProxyUrl}https://cdn2.vectorstock.com/i/1000x1000/20/76/man-avatar-profile-vector-21372076.jpg"),
            trailing: Text("${widget.data[index]["ratePerDay"]} ₹/Day"),
            children: [
              const SizedBox(
                height: 20,
              ),
              Text(widget.data[index]["kit"]!),
              const SizedBox(
                height: 20,
              ),
              if (widget.data[index]["categories"] != null)
                Column(
                  children: [
                    Text(widget.data[index]["categories"]!.join(', ')),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              Text(
                  'Distance: ${widget.data[index]["distance"].toStringAsFixed(2)} m'),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MaterialButton(
                      color: const Color(0xFFfe7f28),
                      child: const Text(
                        'Reviews',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {}),
                  MaterialButton(
                      color: const Color(0xFFfe7f28),
                      child: const Text(
                        'Ask',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PhotographerPage(data: widget.data[index]!),
                          ),
                        );
                      })
                ],
              ),
            ],
          ),
        );
      },
      itemCount: widget.data.length,
    );
  }
}
