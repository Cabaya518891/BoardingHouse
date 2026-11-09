import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/firestore_function.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key, required this.rentAmount});
  final double rentAmount;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final FireStoreFunction _function = FireStoreFunction();

  void openInputBox({String? noteId, String? initialNote}) {
    List<String> noteParts = initialNote != null ? initialNote.split(' ') : [];
    TextEditingController firstNameController =
        TextEditingController(text: noteParts.isNotEmpty ? noteParts[0] : '');
    TextEditingController lastNameController =
        TextEditingController(text: noteParts.length > 1 ? noteParts[1] : '');
    TextEditingController contactNumberController =
        TextEditingController(text: noteParts.length > 2 ? noteParts[2] : '');
    TextEditingController rentDateController =
        TextEditingController(text: noteParts.length > 3 ? noteParts[3] : '');
    TextEditingController downPaymentController =
        TextEditingController(text: noteParts.length > 4 ? noteParts[4] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                noteId == null ? Icons.person_add : Icons.edit_note,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              noteId == null ? 'Add New Tenant' : 'Edit Tenant Details',
              style: GoogleFonts.lato(
                color: Colors.blueGrey[900],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildStyledTextField(
                controller: firstNameController,
                label: 'First Name',
                hint: 'e.g. John',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildStyledTextField(
                controller: lastNameController,
                label: 'Last Name',
                hint: 'e.g. Doe',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              _buildStyledTextField(
                controller: contactNumberController,
                label: 'Contact Number',
                hint: '09123456789',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _buildStyledTextField(
                controller: rentDateController,
                label: 'Rent Date',
                hint: 'e.g. Nov 15',
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 12),
              _buildStyledTextField(
                controller: downPaymentController,
                label: 'Down Payment',
                hint: '0.00',
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String firstName = firstNameController.text.trim();
              String lastName = lastNameController.text.trim();
              String contactNumber = contactNumberController.text.trim();
              String rentDate = rentDateController.text.trim();
              double downPayment =
                  double.tryParse(downPaymentController.text.trim()) ?? 0.0;

              String noteText =
                  '$firstName $lastName $contactNumber $rentDate $downPayment';

              if (noteId == null) {
                _function.addNoteToCollection({'note': noteText});
              } else {
                _function.updateNoteInCollection(noteId, {'note': noteText});
              }

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Save Tenant',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueAccent, size: 20),
        filled: true,
        fillColor: Colors.blueGrey[50],
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: Text(
          'List of Tenants',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          openInputBox();
        },
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          'Add Tenant',
          style: GoogleFonts.lato(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _function.readFromCollection(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            List noteList = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = noteList[index];
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'] ?? '';
                String noteId = document.id;

                List<String> parts = noteText.split(' ');
                String fullName =
                    parts.length >= 2 ? '${parts[0]} ${parts[1]}' : noteText;
                String contact = parts.length > 2 ? parts[2] : 'N/A';
                String rDate = parts.length > 3 ? parts[3] : 'N/A';
                String dPayment = parts.length > 4 ? parts[4] : '0.0';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.blueAccent.withOpacity(0.12),
                          child: Text(
                            fullName.isNotEmpty
                                ? fullName[0].toUpperCase()
                                : 'T',
                            style: GoogleFonts.lato(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: GoogleFonts.lato(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.phone_outlined,
                                      size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    contact,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Date: $rDate',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Paid: ₱$dPayment',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: Colors.blueAccent),
                              onPressed: () {
                                openInputBox(
                                    noteId: noteId, initialNote: noteText);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () {
                                _function.deleteNoteFromCollection(noteId);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No tenant available',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap "+ Add Tenant" to register a new tenant.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
