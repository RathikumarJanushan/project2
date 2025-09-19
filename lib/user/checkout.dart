import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const kPrimary = Color(0xFFA63334);
const kBg = Color(0xFF2A2928);
const kMuted = Color(0xFFB7B7B6);
const kWhite = Color(0xFFFFFFFF);

class CheckoutPage extends StatelessWidget {
  final String uid;
  const CheckoutPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final itemsRef = FirebaseFirestore.instance
        .collection('chat')
        .doc(uid)
        .collection('items');

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        foregroundColor: kWhite,
        title: const Text('Checkout'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: itemsRef.snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Error: ${snap.error}',
                    style: const TextStyle(color: Colors.redAccent)));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
                child: Text('Your chat is empty',
                    style: TextStyle(color: kWhite)));
          }

          double total = 0;
          for (final d in docs) {
            final m = (d.data() as Map<String, dynamic>? ?? {});
            final p = (m['price'] as num?)?.toDouble() ?? 0;
            final q = (m['qty'] as num?)?.toInt() ?? 1;
            total += p * q;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final id = docs[i].id;
                    final m = (docs[i].data() as Map<String, dynamic>? ?? {});
                    final name = (m['name'] as String?) ?? '';
                    final price = (m['price'] as num?)?.toDouble() ?? 0;
                    final qty = (m['qty'] as num?)?.toInt() ?? 1;
                    final imageUrl = (m['imageUrl'] as String?) ?? '';
                    final kind = (m['kind'] as String?) ?? '';
                    final type = (m['type'] as String?) ?? '';
                    final sugar = (m['sugar'] as String?) ?? '';
                    final note = (m['note'] as String?) ?? '';
                    final extraNote = (m['extraNote'] as String?) ?? '';

                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F2E2D),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kMuted),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageUrl.isNotEmpty
                                ? Image.network(imageUrl,
                                    width: 70, height: 70, fit: BoxFit.cover)
                                : Container(
                                    width: 70,
                                    height: 70,
                                    color: const Color(0xFF3A3938)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DefaultTextStyle(
                              style: const TextStyle(color: kWhite),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  if (kind == 'drink')
                                    Text('Type: $type • Sugar: $sugar',
                                        style: const TextStyle(
                                            color: kMuted, fontSize: 12)),
                                  if (kind == 'food')
                                    Text(
                                      [
                                        if (note.isNotEmpty) 'Note: $note',
                                        if (extraNote.isNotEmpty)
                                          'Extra: $extraNote'
                                      ].join('  •  '),
                                      style: const TextStyle(
                                          color: kMuted, fontSize: 12),
                                    ),
                                  const SizedBox(height: 6),
                                  Text(
                                      'LKR ${(price * qty).toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  final newQty = qty > 1 ? qty - 1 : 1;
                                  await itemsRef
                                      .doc(id)
                                      .update({'qty': newQty});
                                },
                                icon: const Icon(Icons.remove, color: kWhite),
                              ),
                              Text('$qty',
                                  style: const TextStyle(color: kWhite)),
                              IconButton(
                                onPressed: () async {
                                  await itemsRef
                                      .doc(id)
                                      .update({'qty': qty + 1});
                                },
                                icon: const Icon(Icons.add, color: kWhite),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await itemsRef.doc(id).delete();
                                },
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF242322),
                  border: Border(top: BorderSide(color: kMuted)),
                ),
                child: Row(
                  children: [
                    Text('Total: LKR ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                    const Spacer(),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: kPrimary, foregroundColor: kWhite),
                      onPressed: () {
                        // TODO: integrate payment/checkout
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Proceeding to payment...')));
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
