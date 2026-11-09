import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreFunction {
  // Connection to Firestore Collection
  final CollectionReference roomPayments =
      FirebaseFirestore.instance.collection('room_payments');

  // Create
  Future<void> addRoomPayment(String tenantName, double rentAmount,
      double downPayment, String rentDate) async {
    try {
      await roomPayments.add({
        'tenant_name': tenantName,
        'rent_amount': rentAmount,
        'down_payment': downPayment,
        'rent_date': rentDate,
        'timestamp': FieldValue
            .serverTimestamp(), // Best practice: Uses server time for accuracy across devices
      });
    } catch (e) {
      print('Error adding room payment: $e');
      rethrow;
    }
  }

  // Read
  Stream<QuerySnapshot> readRoomPaymentsFromCollection() {
    return roomPayments.orderBy('timestamp', descending: true).snapshots();
  }

  // Update
  Future<void> updateRoomPayment(String docID, double newRentAmount,
      double newDownPayment, String newRentDate) async {
    try {
      await roomPayments.doc(docID).update({
        'rent_amount': newRentAmount,
        'down_payment': newDownPayment,
        'rent_date': newRentDate,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating room payment: $e');
      rethrow;
    }
  }

  // Delete
  Future<void> deleteRoomPayment(String docID) async {
    try {
      await roomPayments.doc(docID).delete();
    } catch (e) {
      print('Error deleting room payment: $e');
      rethrow;
    }
  }

  // Calculate Total Room Payments (Fixed Type Casting & Null Safety)
  Future<double> calculateTotalRoomPayments() async {
    double totalPayments = 0;

    try {
      QuerySnapshot snapshot = await roomPayments.get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('rent_amount')) {
          // Safe cast: handles both int (e.g. 500) and double (e.g. 500.50) without crashing
          final rent = (data['rent_amount'] as num?)?.toDouble() ?? 0.0;
          totalPayments += rent;
        }
      }
    } catch (e) {
      print('Error calculating total room payments: $e');
    }

    return totalPayments;
  }

  // Additional Helper: Calculate Outstanding Balance (Rent Amount - Down Payment)
  Future<double> calculateTotalRemainingBalance() async {
    double totalBalance = 0;

    try {
      QuerySnapshot snapshot = await roomPayments.get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final rent = (data['rent_amount'] as num?)?.toDouble() ?? 0.0;
          final down = (data['down_payment'] as num?)?.toDouble() ?? 0.0;
          totalBalance += (rent - down);
        }
      }
    } catch (e) {
      print('Error calculating remaining balance: $e');
    }

    return totalBalance;
  }
}
