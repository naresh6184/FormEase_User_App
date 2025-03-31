import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'generate_form_UG.dart';
import 'themed_scaffold.dart';
import 'dart:async';


class LeaveApplicationFormUG extends StatefulWidget {
  const LeaveApplicationFormUG({super.key});

  @override
  _LeaveApplicationFormUGState createState() => _LeaveApplicationFormUGState();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _LeaveApplicationFormUGState extends State<LeaveApplicationFormUG> {
  final _formKey = GlobalKey<FormState>();
  final Color _primaryColor = Colors.blue[800]!;
  final Color _textColor = Colors.black87;

  // Form field controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollNoController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController hostelBlockController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  Timer? _debounce;                   // Timer for debouncing
  bool isLoading = false;             // Loader flag
  String? errorMessage;

  DateTime? leaveStartDate;
  DateTime? leaveEndDate;
  String? natureOfLeave;
  String? selectedDepartment;

  final List<String> leaveTypes = [
    'Sick Leave',
    'Casual Leave',
    'Emergency Leave'
  ];

  final List<String> departments = [
    'CSE',
    'ECE',
    'CE',
    'PE',
    'ME',
    'M&C',
  ];

  List<String> errorMessages = [];

  final _formDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.97),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 10,
        spreadRadius: 2,
      )
    ],
  );



  Future<void> fetchStudentName(String rollNo) async {
    // Clear name and show error immediately for invalid roll numbers
    if (rollNo.isEmpty || rollNo.length != 8) {
      setState(() {
        nameController.clear();
        errorMessage = "Invalid Roll No.";   // Show error immediately
      });
      return;
    } else {
      setState(() => errorMessage = null);   // Clear the error message if valid
    }

    // Debounce to prevent multiple API calls
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => isLoading = true);

      var url = Uri.parse("http://192.168.25.109:5000/get-student-name?roll_no=$rollNo");

      try {
        var response = await http.get(url);

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          setState(() {
            if (data['success'] && data['name'] != null && data['name'].isNotEmpty) {
              nameController.text = data['name'];  // Display name
              errorMessage = null;
            } else {
              nameController.clear();
              errorMessage = "Invalid Roll No.";   // Display error for invalid data
            }
          });
        } else {
          setState(() {
            nameController.clear();
            errorMessage = "Invalid Roll No.";     // Handle 404 or other errors
          });
        }
      } catch (e) {
        setState(() {
          nameController.clear();
          errorMessage = "Network error. Please try again.";
        });
      } finally {
        setState(() => isLoading = false);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? DateTime.now() : (leaveStartDate ?? DateTime.now());
    DateTime firstDate = isStart ? DateTime.now() : leaveStartDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          leaveStartDate = picked;
          leaveEndDate = null;
        } else {
          leaveEndDate = picked;
        }
        daysController.text = _calculateDateDifference().toString();
      });
    }
  }

  int _calculateDateDifference() {
    if (leaveStartDate != null && leaveEndDate != null) {
      int days = leaveEndDate!.difference(leaveStartDate!).inDays + 1;
      return days > 0 ? days : 1;
    }
    return 0;
  }

  void onRollNumberChanged(String value) {
    // Cancel any ongoing debounce timer
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Start a new timer with a delay of 500 milliseconds
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.length >= 8) {          // Trigger only if valid roll number length
        fetchStudentName(value);
      }
    });
  }

  void _validateForm() {
    setState(() {
      errorMessages.clear();
      if (nameController.text.isEmpty) errorMessages.add('Please enter your name');
      if (rollNoController.text.isEmpty) errorMessages.add('Please enter your roll number');
      if (selectedDepartment == null) errorMessages.add('Please select your department');
      if (hostelBlockController.text.isEmpty) errorMessages.add('Please enter your hostel block & room number');
      if (leaveStartDate == null) errorMessages.add('Please select a start date for leave');
      if (leaveEndDate == null) errorMessages.add('Please select an end date for leave');
      if (_calculateDateDifference() <= 0) errorMessages.add('Invalid leave duration');
      if (natureOfLeave == null) errorMessages.add('Please select the nature of leave');
      if (reasonController.text.isEmpty) errorMessages.add('Please enter a reason for leave');
      if (addressController.text.isEmpty) errorMessages.add('Please enter your address during leave');
      if (mobileController.text.isEmpty) errorMessages.add('Please enter your mobile number');
      if (mobileController.text.length!=10) errorMessages.add('Please enter your mobile number correctly');

    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: const Text('Leave Application for UG'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 5,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: _formDecoration,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormField('Name:', nameController, readOnly: true), // Name first (read-only)
                    const SizedBox(height: 15),
                    _buildFormField(
                      'Roll No.:',
                      rollNoController,
                      isUpperCase: true,
                      onChanged: (value) => fetchStudentName(value),  // Trigger on change
                      isLoading: isLoading,
                      suffixIcon: const Icon(Icons.search),
                      errorText: errorMessage,                        // Show the error message
                    ),
                    const SizedBox(height: 15),
                    _buildDepartmentDropdown(),
                    const SizedBox(height: 15),
                    _buildFormField('Hostel Block & Room No.:', hostelBlockController, isUpperCase: true),
                    const SizedBox(height: 20),
                    _buildDateFields(),
                    const SizedBox(height: 15),
                    _buildDaysField(),
                    const SizedBox(height: 15),
                    _buildLeaveTypeDropdown(),
                    const SizedBox(height: 15),
                    _buildFormField('Reason of Leave:', reasonController),
                    const SizedBox(height: 15),
                    _buildFormField('Address during Leave:', addressController),
                    const SizedBox(height: 15),
                    _buildFormField('Mobile No.:', mobileController, keyboardType: TextInputType.phone, inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,  // Allow only digits
                      LengthLimitingTextInputFormatter(10),    // Limit to 10 digits
                    ],),
                    const SizedBox(height: 15),
                    if (errorMessages.isNotEmpty) _buildErrorMessages(),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
      String label,
      TextEditingController controller, {
        bool isUpperCase = false,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters, // Optional formatters
        Function(String)? onChanged,               // Callback on text change
        bool readOnly = false,                     // Read-only property
        bool isLoading = false,                    // Loader flag
        String? errorText,                         // Error message
        Widget? suffixIcon,                        // Suffix icon (dynamic)
      }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: _textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              hintStyle: TextStyle(color: Colors.grey[600]),
              errorText: errorText,                  // Show error message if any
              suffixIcon: isLoading
                  ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
                  : suffixIcon,                     // Show suffix icon or loader
            ),
            textCapitalization: isUpperCase
                ? TextCapitalization.characters
                : TextCapitalization.none,
            inputFormatters: [
              if (isUpperCase) UpperCaseTextFormatter(),  // Apply uppercase formatting
              if (inputFormatters != null) ...inputFormatters, // Additional formatters
            ],
            keyboardType: keyboardType,
            onChanged: onChanged,              // Trigger callback on text change
            readOnly: readOnly,                // Prevent editing if true
          ),
        ),
      ],
    );
  }


  Widget _buildDepartmentDropdown() {
    return Row(
      children: [
        Text('Department:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textColor,
            )),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedDepartment,
            dropdownColor: Colors.white,
            style: TextStyle(color: _textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            hint: Text('Select Department', style: TextStyle(color: Colors.grey[600])),
            items: departments.map((String department) {
              return DropdownMenuItem<String>(
                value: department,
                child: Text(department),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() => selectedDepartment = newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leave Duration:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textColor,
            )),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildDateField(isStart: true)),
            const SizedBox(width: 2),
            Expanded(child: _buildDateField(isStart: false)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({required bool isStart}) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: AbsorbPointer(
        child: TextFormField(
          style: TextStyle(color: _textColor, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            labelText: isStart ? 'From' : 'To',
            labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            suffixIcon: (isStart && leaveStartDate == null) ||
                (!isStart && leaveEndDate == null)
                ? const Icon(Icons.calendar_today, size: 20) // Show only if no date is selected
                : null, // Hide icon when a date is selected
          ),
          controller: TextEditingController(
            text: isStart
                ? (leaveStartDate != null ? leaveStartDate!.toLocal().toString().split(' ')[0] : '')
                : (leaveEndDate != null ? leaveEndDate!.toLocal().toString().split(' ')[0] : ''),
          ),
        ),
      ),
    );
  }

  Widget _buildDaysField() {
    return Row(
      children: [
        Text('No. of Days:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textColor,
            )),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: daysController,
            readOnly: true,
            style: TextStyle(color: _textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return Row(
      children: [
        Text('Nature of Leave:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textColor,
            )),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: natureOfLeave,
            dropdownColor: Colors.white,
            style: TextStyle(color: _textColor),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            hint: Text('Select Leave Type', style: TextStyle(color: Colors.grey[600])),
            items: leaveTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) => setState(() => natureOfLeave = value),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessages() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: errorMessages.map((error) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(error,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
        )).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
        ),
        onPressed: () {
          _validateForm();
          if (errorMessages.isEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFGeneratorUGPage(
                  name: nameController.text,
                  rollNo: rollNoController.text,
                  department: selectedDepartment ?? '',
                  hostelBlock: hostelBlockController.text,
                  days: _calculateDateDifference().toString(),
                  leaveStartDate: leaveStartDate?.toLocal().toString().split(' ')[0] ?? '',
                  leaveEndDate: leaveEndDate?.toLocal().toString().split(' ')[0] ?? '',
                  natureOfLeave: natureOfLeave ?? '',
                  reason: reasonController.text,
                  address: addressController.text,
                  mobile: mobileController.text,
                ),
              ),
            );
          }
        },
        child: const Text('SUBMIT APPLICATION',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
