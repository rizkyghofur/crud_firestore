import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Beranda extends StatefulWidget {
  Beranda({Key key}) : super(key: key);

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  @override
  Widget build(BuildContext context) {
    TextEditingController namaProdukController = TextEditingController();
    TextEditingController hargaProdukController = TextEditingController();

    final CollectionReference _produk =
        FirebaseFirestore.instance.collection('produk');

    Future<void> buatUpdate([DocumentSnapshot documentSnapshot]) async {
      String aksi = 'buat';
      if (documentSnapshot != null) {
        aksi = 'perbarui';
        namaProdukController.text = documentSnapshot['nama'];
        hargaProdukController.text = documentSnapshot['harga'].toString();
      }

      await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext ctx) {
            return Padding(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: namaProdukController,
                    decoration: const InputDecoration(labelText: 'Nama'),
                  ),
                  TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    controller: hargaProdukController,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text(aksi == 'buat' ? 'Buat' : 'Perbarui'),
                    onPressed: () async {
                      final String nama = namaProdukController.text;
                      final int harga =
                          int.tryParse(hargaProdukController.text);
                      if (nama != null && harga != null) {
                        if (aksi == 'buat') {
                          await _produk.add({
                            "nama": nama,
                            "harga": harga
                          }).whenComplete(() => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Anda berhasil membuat data produk.'))));
                        }

                        if (aksi == 'perbarui') {
                          await _produk.doc(documentSnapshot.id).update({
                            "nama": nama,
                            "harga": harga
                          }).whenComplete(() => ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Anda berhasil memperbarui data produk.'))));
                        }
                        namaProdukController.text = '';
                        hargaProdukController.text = '';
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              ),
            );
          });
    }

    Future<void> hapusProduk(String productId) async {
      await _produk.doc(productId).delete().whenComplete(() =>
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Anda berhasil menghapus data produk.'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD Firestore'),
      ),
      body: StreamBuilder(
        stream: _produk.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data.docs[index];
                return Card(
                  margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                  child: ListTile(
                    title: Text(documentSnapshot['nama']),
                    subtitle: Text(documentSnapshot['harga'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => buatUpdate(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  hapusProduk(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => buatUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
