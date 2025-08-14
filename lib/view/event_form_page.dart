import '../utils/import_export.dart';
import 'package:flutter/services.dart';

class EventFormPage extends StatefulWidget {
  final Event? event;

  const EventFormPage({super.key, this.event});

  @override
  State<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final EventController _eventController = Get.find<EventController>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late DateTime _startDateTime;
  late DateTime? _endDateTime;
  int? _maxCapacity;
  String? _eventType;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title);
    _descriptionController = TextEditingController(text: event?.description);
    _addressController = TextEditingController(text: event?.address);
    _startDateTime = event?.startDateTime ?? DateTime.now();
    _endDateTime = event?.endDateTime;
    _maxCapacity = event?.maxCapacity;
    _eventType = event?.eventType;
    _latitude = event?.latitude;
    _longitude = event?.longitude;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Create Event' : 'Edit Event'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  hintText: 'Enter event title',
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  if (!value[0].toUpperCase().contains(RegExp(r'[A-Z]'))) {
                    return 'Title must start with a capital letter';
                  }
                  if (value.length < 3) {
                    return 'Title must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  hintText: 'Enter event description',
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!value[0].toUpperCase().contains(RegExp(r'[A-Z]'))) {
                      return 'Description must start with a capital letter';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters long';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Start: ${DateFormat('MMM dd, yyyy hh:mm a').format(_startDateTime)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDateTime(isStart: true),
                    child: const Text('Change'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _endDateTime == null
                          ? 'No end date'
                          : 'End: ${DateFormat('MMM dd, yyyy hh:mm a').format(_endDateTime!)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDateTime(isStart: false),
                    child: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _maxCapacity?.toString(),
                decoration: const InputDecoration(
                  labelText: 'Maximum Capacity',
                  border: OutlineInputBorder(),
                  hintText: 'Enter maximum number of attendees',
                  counterText: 'Leave empty for unlimited capacity',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final number = int.tryParse(value);
                    if (number == null) {
                      return 'Please enter a valid number';
                    }
                    if (number <= 0) {
                      return 'Capacity must be greater than 0';
                    }
                    if (number > 1000000) {
                      return 'Capacity cannot exceed 1,000,000';
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _maxCapacity = int.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.event == null ? 'Create Event' : 'Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime({required bool isStart}) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    final DateTime? date = await showDatePicker(
      context: Get.context!,
      initialDate: isStart ? _startDateTime : (_endDateTime ?? _startDateTime),
      firstDate: isStart ? today : _startDateTime,
      lastDate: today.add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        if (isStart) {
          return date.isAfter(today.subtract(const Duration(days: 1)));
        } else {
          return date.isAfter(_startDateTime.subtract(const Duration(days: 1)));
        }
      },
    );
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? _startDateTime : (_endDateTime ?? _startDateTime),
        ),
      );
      if (time != null) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        // Validate the selected date and time
        final now = DateTime.now();
        if (isStart && newDateTime.isBefore(now)) {
          Get.snackbar(
            'Invalid Date',
            'Start date and time cannot be in the past',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        setState(() {
          if (isStart) {
            _startDateTime = newDateTime;
            // Clear end date if it's before the new start date
            if (_endDateTime != null && _endDateTime!.isBefore(_startDateTime)) {
              _endDateTime = null;
              Get.snackbar(
                'End Date Cleared',
                'End date was cleared because it was before the new start date',
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } else {
            if (newDateTime.isBefore(_startDateTime)) {
              Get.snackbar(
                'Invalid Date',
                'End date cannot be before start date',
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            _endDateTime = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fix the errors in the form',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
      return;
    }

    // Additional validation for dates
    final now = DateTime.now();
    if (widget.event == null && !_startDateTime.isAfter(now)) {
      Get.snackbar(
        'Invalid Date',
        'Start date/time must be in the future',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
      return;
    }

    if (_endDateTime != null && !_endDateTime!.isAfter(_startDateTime)) {
      Get.snackbar(
        'Invalid Date',
        'End date/time must be after start date/time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
      return;
    }

    try {
      final event = widget.event;
      if (event == null) {
        // Create new event
        final success = await _eventController.createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDateTime: _startDateTime,
          endDateTime: _endDateTime,
          address: _addressController.text.trim(),
          maxCapacity: _maxCapacity,
          eventType: _eventType,
          latitude: _latitude,
          longitude: _longitude,
        );
        if (success) {
          Get.snackbar(
            'Success',
            'Event created successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
          );
          Get.offAllNamed(ROUTE_HOME); // Redirect to home page
        }
      } else {
        // Update existing event
        final updatedEvent = Event(
          id: event.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDateTime: _startDateTime,
          endDateTime: _endDateTime,
          address: _addressController.text.trim(),
          maxCapacity: _maxCapacity,
          eventType: _eventType,
          latitude: _latitude,
          longitude: _longitude,
          createdBy: event.createdBy,
          createdAt: event.createdAt,
          isCancelled: event.isCancelled,
          isCompleted: event.isCompleted,
          updatedAt: DateTime.now(),
        );
        final success = await _eventController.updateEvent(updatedEvent);
        if (success) {
          Get.snackbar(
            'Success',
            'Event updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green[100],
          );
          Get.offAllNamed(ROUTE_HOME);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save event: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    }
  }
}
