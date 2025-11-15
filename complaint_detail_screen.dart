
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cybershield/models/Complaints.dart';

// PDF + File handling
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final String? preSelectedCategory;

  ComplaintDetailScreen({this.preSelectedCategory});

  @override
  _ComplaintDetailScreenState createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _postalAddressController = TextEditingController();
  final TextEditingController _complaintDetailsController =
  TextEditingController();
  final TextEditingController _orgNameController = TextEditingController();
  String? _selectedOrganization;

  // final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _customCategoryController =
  TextEditingController();

  String? _selectedWorkplaceType;
  String? _selectedCategory;
  String? _selectedGender;
  String? _selectedOccupation;
  String? _selectedCity;
  File? _selectedFile;
  String? _fileUrl;
  bool _fileAttached = false;
  bool _isSubmitting = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _occupations = [
    'Student',
    'Business',
    'Job Holder',
    'Other'
  ];
  final List<String> _cities = [
    'Sahiwal',
    'Okara',
    'Lahore',
    'Islamabad',
    'Peshawar',
    'Karachi',
    'Other'
  ];

  final phoneFormatter = MaskTextInputFormatter(mask: '+## (###) ###-####');
  final whatsappFormatter = MaskTextInputFormatter(mask: '+## (###) ###-####');
  final cnicFormatter = MaskTextInputFormatter(mask: '#####-#######-#');

  @override
  void initState() {
    super.initState();
    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.email != null) {
      _emailController.text = currentUser.email!;
    }
    if (widget.preSelectedCategory != null) {
      _selectedCategory = widget.preSelectedCategory;
    }
  }

  Future<bool> _hasRecentComplaint(String email) async {
    try {
      final now = DateTime.now();
      final twentyFourHoursAgo = now.subtract(Duration(hours: 24));

      final querySnapshot = await _firestore
          .collection('complaints')
          .where('email', isEqualTo: email)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lastComplaint = querySnapshot.docs.first;
        final lastComplaintTime =
        (lastComplaint.data()['createdAt'] as Timestamp).toDate();
        return lastComplaintTime.isAfter(twentyFourHoursAgo);
      }
      return false;
    } catch (e) {
      print('Error checking recent complaints: $e');
      return false;
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);

        if (await file.length() > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('File size exceeds the 5MB limit.')));
        } else {
          setState(() {
            _selectedFile = file;
            _fileAttached = true;
            _fileUrl = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('File attached successfully!',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ));
        }
      }
    } catch (e) {
      print('File pick error: $e');
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    const uploadPreset = 'flutter_unsigned_upload';
    final mimeType = lookupMimeType(file.path)?.split('/');
    final fileBytes = await file.readAsBytes();
    final uri =
    Uri.parse('https://api.cloudinary.com/v1_1/dcn0zto1x/auto/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: path.basename(file.path),
        contentType:
        mimeType != null ? MediaType(mimeType[0], mimeType[1]) : null,
      ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['secure_url'];
    } else {
      print('Cloudinary upload failed: $responseBody');
      return null;
    }
  }

  Future<void> _generatePdf(Map<String, dynamic> data, {File? file}) async {
    final pdf = pw.Document();

    pw.MemoryImage? attachedFileImage;
    if (file != null &&
        (file.path.endsWith('.jpg') ||
            file.path.endsWith('.jpeg') ||
            file.path.endsWith('.png'))) {
      final bytes = await file.readAsBytes();
      attachedFileImage = pw.MemoryImage(bytes);
    }

    pw.MemoryImage? appLogo;
    try {
      final bytes = await rootBundle.load('assets/icon.jpg');
      appLogo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (e) {
      print("App logo not found: $e");
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (appLogo != null)
                  pw.Align(
                    child: pw.Image(appLogo, width: 100, height: 100),
                  ),
                pw.SizedBox(height: 10),
                pw.Align(
                  child: pw.Text(
                    "ProtectU",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    "Complaint Registration Form",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  children: [
                    _buildTableRow("Name", data['name']),
                    _buildTableRow("Email", data['email']),
                    _buildTableRow("CNIC", data['cnic']),
                    _buildTableRow("Phone", data['phone']),
                    _buildTableRow("WhatsApp", data['whatsapp']),
                    _buildTableRow("Gender", data['gender']),
                    _buildTableRow("Occupation", data['occupation']),
                    _buildTableRow("Postal Address", data['postalAddress']),
                    _buildTableRow("City", data['city']),
                    _buildTableRow("Workplace Type", data['workplaceType']),
                    _buildTableRow("Institution", data['institutionName']),
                    _buildTableRow("Department", data['department']),
                    _buildTableRow("Category", data['category']),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text("Complaint Details:",
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(10),
                  margin: pw.EdgeInsets.only(top: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Text(data['complaintDetails'] ?? ""),
                ),
                pw.SizedBox(height: 20),

                // ✅ Attached file section
                if (attachedFileImage != null) ...[
                  pw.Text("Attached File:",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.UrlLink(
                    destination: data['fileUrl'],
                    child: pw.Text(
                      "Click here to open attached file",
                      style: pw.TextStyle(
                        color: PdfColors.blue,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ] else if (data['fileUrl'] != null && data['fileUrl'].toString().isNotEmpty) ...[
                  pw.Text("Attached File:",
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  // 🔗 Clickable file link
                  pw.UrlLink(
                    destination: data['fileUrl'],
                    child: pw.Text(
                      "Click here to open attached file",
                      style: pw.TextStyle(
                        color: PdfColors.blue,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],

                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    "Submitted on: ${DateTime.now()}",
                    style: pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final fileOut =
    File("${dir.path}/complaint_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await fileOut.writeAsBytes(await pdf.save());

    await OpenFile.open(fileOut.path);
  }


  pw.TableRow _buildTableRow(String field, String? value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: pw.EdgeInsets.all(8),
          color: PdfColors.grey300,
          child: pw.Text(field,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Container(
          padding: pw.EdgeInsets.all(8),
          child: pw.Text(value ?? ""),
        ),
      ],
    );
  }

  Future<void> _submitComplaint() async {
    final category = (_selectedCategory == 'Other(specify)')
        ? _customCategoryController.text.trim()
        : (_selectedCategory ?? widget.preSelectedCategory ?? '');

    if (_formKey.currentState!.validate() &&
        _selectedGender != null &&
        _selectedOccupation != null &&
        _selectedCity != null &&
        category.isNotEmpty &&
        _selectedWorkplaceType != null) {
      setState(() => _isSubmitting = true);

      final hasRecent = await _hasRecentComplaint(_emailController.text);
      if (hasRecent) {
        final querySnapshot = await _firestore
            .collection('complaints')
            .where('email', isEqualTo: _emailController.text)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final lastComplaint = querySnapshot.docs.first;
          final lastComplaintTime =
          (lastComplaint.data()['createdAt'] as Timestamp).toDate();
          final nextSubmissionTime =
          lastComplaintTime.add(Duration(hours: 24));
          final timeLeft =
          nextSubmissionTime.difference(DateTime.now());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'You can submit again in ${timeLeft.inHours} hours and ${timeLeft.inMinutes % 60} minutes'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }

      if (_selectedFile != null) {
        try {
          _fileUrl = await _uploadToCloudinary(_selectedFile!);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload file: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }


        try {
          // ✅ Create a Complaint model instance
          Complaint complaint = Complaint(
            name: _nameController.text,
            email: _emailController.text,
            cnic: _cnicController.text,
            phone: _phoneController.text,
            whatsapp: _whatsappController.text,
            gender: _selectedGender!,
            occupation: _selectedOccupation!,
            postalAddress: _postalAddressController.text,
            city: _selectedCity!,
            complaintDetails: _complaintDetailsController.text,
            fileUrl: _fileUrl ?? '',
            category: category,
            createdAt: Timestamp.now(),
            userId: _auth.currentUser?.uid ?? '',
            workplaceType: _selectedWorkplaceType ?? '',
            institutionName: _orgNameController.text,
            department: _departmentController.text,
          );

          // ✅ Save to Firestore
          await _firestore.collection('complaints').add(complaint.toMap());


        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint submitted successfully!'),
            backgroundColor: Colors.black,
          ),
        );
        await _generatePdf({
          'name': _nameController.text,
          'email': _emailController.text,
          'cnic': _cnicController.text,
          'phone': _phoneController.text,
          'whatsapp': _whatsappController.text,
          'gender': _selectedGender,
          'occupation': _selectedOccupation,
          'postalAddress': _postalAddressController.text,
          'city': _selectedCity,
          'complaintDetails': _complaintDetailsController.text,
          'category': category,
          'workplaceType': _selectedWorkplaceType,
          'institutionName': _orgNameController.text,
          'department': _departmentController.text,
          // 🔑 pass fileUrl here
          'fileUrl': _fileUrl ?? '',
        }, file: _selectedFile);



        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit complaint: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTextField(
      String label,
      IconData icon,
      TextEditingController controller, [
        List<TextInputFormatter>? inputFormatters,
        TextInputType? keyboardType,
        bool enabled = true,
      ]) {
    return TextFormField(
      controller: controller,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF154688)),
        border: OutlineInputBorder(),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
  void _showReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Review Your Complaint",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF154688),
                    ),
                  ),
                  SizedBox(height: 16),

                  // 📌 Scrollable Section
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        _buildReviewCard("Personal Info", [
                          "Name: ${_nameController.text}",
                          "Email: ${_emailController.text}",
                          "CNIC: ${_cnicController.text}",
                          "Phone: ${_phoneController.text}",
                          "WhatsApp: ${_whatsappController.text}",
                          "Gender: $_selectedGender",
                          "Occupation: $_selectedOccupation",
                          "City: $_selectedCity",
                        ]),
                        _buildReviewCard("Workplace Info", [
                          "Workplace: $_selectedWorkplaceType",
                          "Institution: ${_orgNameController.text}",
                          "Department: ${_departmentController.text}",
                        ]),
                        // _buildReviewCard("Complaint Info", [
                        //   "Category: ${_selectedCategory ?? widget.preSelectedCategory}",
                        //   "Details: ${_complaintDetailsController.text}",
                        // ]),
                        _buildReviewCard("Complaint Info", [
                          "Category: ${_selectedCategory == 'Other(specify)' && _customCategoryController.text.isNotEmpty
                              ? _customCategoryController.text
                              : (_selectedCategory ?? widget.preSelectedCategory)}",
                          "Details: ${_complaintDetailsController.text}",
                        ]),

                        if (_selectedFile != null)
                          _buildReviewCard("Attached File", [
                            "File: ${path.basename(_selectedFile!.path)}",
                          ]),
                      ],
                    ),
                  ),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFF070707),
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context), // go back
                          // icon: Icon(Icons.edit),
                          label: Text("Modify", style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color(0xFF070707),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _submitComplaint(); // call original function
                          },
                          // icon: Icon(Icons.check_circle),
                          label: Text("Looks Good", style: TextStyle(fontSize: 16) ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewCard(String title, List<String> items) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF154688),
              ),
            ),
            SizedBox(height: 8),
            ...items.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline_outlined, size: 16, color: Colors.black),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      e,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Complaint'),
        backgroundColor: Color(0xFF154688),
        foregroundColor: Color(0xFFFFFFFF),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField('Name', Icons.person, _nameController),
              SizedBox(height: 12),
              _buildTextField('Email', Icons.email, _emailController, null,
                  TextInputType.emailAddress, false),
              SizedBox(height: 12),
              _buildTextField('CNIC', Icons.credit_card, _cnicController,
                  [cnicFormatter], TextInputType.number),
              SizedBox(height: 12),
              _buildTextField('Phone No.', Icons.phone, _phoneController,
                  [phoneFormatter], TextInputType.phone),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.transgender, color: Color(0xFF154688)),
                  border: OutlineInputBorder(),
                ),
                value: _selectedGender,
                hint: Text('Select Gender'),
                items: _genders
                    .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) =>
                value == null ? 'Please select gender' : null,
              ),
              SizedBox(height: 12),
              _buildTextField('WhatsApp Number', Icons.chat, _whatsappController,
                  [whatsappFormatter], TextInputType.phone),
              SizedBox(height: 12),
              _buildTextField('Postal Address', Icons.home, _postalAddressController),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Occupation',
                  prefixIcon: Icon(Icons.work, color: Color(0xFF154688)),
                  border: OutlineInputBorder(),
                ),
                value: _selectedOccupation,
                hint: Text('Select Occupation'),
                items: _occupations
                    .map((occupation) =>
                    DropdownMenuItem(value: occupation, child: Text(occupation)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedOccupation = value),
                validator: (value) =>
                value == null ? 'Please select occupation' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city, color: Color(0xFF154688)),
                  border: OutlineInputBorder(),
                ),
                value: _selectedCity,
                hint: Text('Select City'),
                items: _cities
                    .map((city) =>
                    DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCity = value),
                validator: (value) => value == null ? 'Please select city' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Workplace Type',
                  prefixIcon: Icon(Icons.business, color: Color(0xFF154688)),
                  border: OutlineInputBorder(),
                ),
                value: _selectedWorkplaceType,
                hint: Text('Select Workplace Type'),
                items: ['School', 'College', 'University', 'Office', 'Other']
                    .map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedWorkplaceType = value),
                validator: (value) =>
                value == null ? 'Please select workplace type' : null,
              ),
              SizedBox(height: 12),
              // Organization Dropdown
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('organizations')
                    .orderBy('organizationName')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  List<DropdownMenuItem<String>> orgItems = snapshot.data!.docs.map((doc) {
                    final orgName = doc['organizationName'] as String;
                    return DropdownMenuItem<String>(
                      value: orgName,
                      child: Text(orgName),
                    );
                  }).toList();

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Institution Name',
                      prefixIcon: Icon(Icons.account_balance, color: Color(0xFF154688)),
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedOrganization,
                    items: orgItems,
                    onChanged: (value) {
                      setState(() {
                        _selectedOrganization = value;
                        _orgNameController.text = value ?? '';
                      });
                    },
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please select an institution' : null,
                  );
                },
              ),

              // _buildTextField('Institution Name', Icons.account_balance, _institutionController),
              SizedBox(height: 12),
              _buildTextField('Department', Icons.apartment, _departmentController),
              SizedBox(height: 12),

              TextFormField(
                controller: _selectedCategory == 'Other(specify)'
                    ? _customCategoryController
                    : TextEditingController(
                  text: _selectedCategory ?? widget.preSelectedCategory ?? '',
                ),
                readOnly: !(_selectedCategory == 'Other(specify)'), // only editable if "Others (Specify)"
                decoration: InputDecoration(
                  labelText: 'Complaint Category',
                  prefixIcon: Icon(Icons.category, color: Color(0xFF154688)),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if ((_selectedCategory == 'Other(specify)') && (value == null || value.isEmpty)) {
                    return 'Please enter custom category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              _buildTextField('Complaint Details', Icons.description, _complaintDetailsController),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: Icon(Icons.attach_file),
                 label: Text('Attach File'),
              ),
              if (_selectedFile != null) ...[
                SizedBox(height: 10),
                _selectedFile!.path.endsWith('.jpg') ||
                    _selectedFile!.path.endsWith('.png') ||
                    _selectedFile!.path.endsWith('.jpeg')
                    ? Image.file(_selectedFile!, height: 150)
                    : Text("Selected File: ${path.basename(_selectedFile!.path)}"),
              ],
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _showReviewDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF154688),
                  foregroundColor: Color(0xFFFFFFFF),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Submit Complaint', style: TextStyle(fontSize: 15)),
              ),


            ],
          ),
        ),
      ),
    );
  }
}





