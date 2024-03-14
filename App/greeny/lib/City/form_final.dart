import 'package:flutter/material.dart';

class FormFinalPage extends StatefulWidget {
  const FormFinalPage({super.key});

  @override
  State<FormFinalPage> createState() => _FormFinalPageState();
}

class _FormFinalPageState extends State<FormFinalPage> {
  final isSelected_ = <bool>[false, false, false, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 40, 5, 0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: information,
                        child: const Icon(Icons.info_outline_rounded, size: 35),
                      ),
                    ],
                  ),
                  const Text("Which transports have \nyou used?",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(isSelected_.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelected_[index] = !isSelected_[index];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: isSelected_[index]
                                ? const Color.fromARGB(131, 1, 164, 167)
                                : null,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Icon(
                            index == 0
                                ? Icons.directions_walk
                                : index == 1
                                    ? Icons.directions_bike
                                    : index == 2
                                        ? Icons.directions_bus
                                        : index == 3
                                            ? Icons.train
                                            : index == 4
                                                ? Icons.motorcycle
                                                : index == 5
                                                    ? Icons.electric_car
                                                    : Icons.directions_car,
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
            ),
            const SizedBox(height: 450),
            ElevatedButton(
              onPressed: submit,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void information() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              const SizedBox(height: 20),
              const Center(
                  child: Text('Information',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold))),
              const SizedBox(height: 20),
              _buildRow(Icons.directions_walk, 'Walking'),
              _buildRow(Icons.directions_bike, 'Cycling'),
              _buildRow(Icons.directions_bus, 'By bus'),
              _buildRow(Icons.train, 'By train, tram, metro or FGC'),
              _buildRow(Icons.motorcycle, 'By motorcycle'),
              _buildRow(Icons.electric_car, 'By electric car'),
              _buildRow(Icons.directions_car, 'By car'),
              TextButton(onPressed: close, child: const Text('Exit')),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRow(IconData icon, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 5),
          Container(height: 2, color: const Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              const SizedBox(width: 16),
              Text(name),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Icon(icon),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void submit() {
    print('Submitted!');
  }

  void close() {
    Navigator.of(context).pop();
  }
}
