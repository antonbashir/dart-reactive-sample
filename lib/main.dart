import 'dart:async';
import 'dart:io';

import 'package:iouring_transport/iouring_transport.dart';
import 'package:reactive_transport/reactive_transport.dart';

Future<void> main(List<String> args) async {
  final transport = Transport();
  final worker = TransportWorker(transport.worker(TransportDefaults.worker()));
  await worker.initialize();
  final reactive = ReactiveTransport(transport, worker, ReactiveTransportDefaults.transport());
  final completer = Completer();

  reactive.serve(InternetAddress.anyIPv4, 1234, (connection) {
    connection.subscriber.subscribe(
      "key",
      onPayload: (payload, producer) {
        print("Hello, $payload");
        completer.complete();
      },
    );
  });

  reactive.connect(InternetAddress.loopbackIPv4, 1234, (connection) {
    connection.subscriber.subscribe(
      "key",
      onSubscribe: (producer) => producer.payload("world"),
    );
  });

  await completer.future;

  await reactive.shutdown(transport: true);
}
