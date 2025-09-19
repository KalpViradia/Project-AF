import '../utils/import_export.dart';
import '../controller/category_controller.dart';
import 'package:flutter/services.dart';

class RecurringEventFormPage extends StatefulWidget {
  final Event? event;

  const RecurringEventFormPage({super.key, this.event});

  @override
  State<RecurringEventFormPage> createState() => _RecurringEventFormPageState();
}

class _RecurringEventFormPageState extends State<RecurringEventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final EventController _eventController = Get.find<EventController>();
  late CategoryController _categoryController;
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late DateTime _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  int? _maxCapacity;
  String? _eventType;
  
  // Recurring event fields
  String _recurrenceType = 'yearly';
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;
  bool _includeTime = false;

  @override
  void initState() {
    super.initState();
    _categoryController = Get.put(CategoryController(Get.find()));
    _initializeControllers();
  }

  void _initializeControllers() {
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title);
    _descriptionController = TextEditingController(text: event?.description);
    _addressController = TextEditingController(text: event?.address);
    
    if (event != null) {
      _startDate = DateTime(event.startDateTime.year, event.startDateTime.month, event.startDateTime.day);
      _startTime = TimeOfDay.fromDateTime(event.startDateTime);
      _includeTime = true; // If editing existing event, assume time is included
      
      if (event.endDateTime != null) {
        _endDate = DateTime(event.endDateTime!.year, event.endDateTime!.month, event.endDateTime!.day);
        _endTime = TimeOfDay.fromDateTime(event.endDateTime!);
      }
    } else {
      _startDate = DateTime.now();
      _startTime = TimeOfDay.now();
    }
    
    _maxCapacity = event?.maxCapacity;
    _eventType = event?.eventType;
    
    // Initialize recurring event fields
    final validRecurrenceTypes = ['daily', 'weekly', 'monthly', 'yearly'];
    _recurrenceType = validRecurrenceTypes.contains(event?.recurrenceType) 
        ? event!.recurrenceType! 
        : 'yearly';
    _recurrenceInterval = event?.recurrenceInterval ?? 1;
    _recurrenceEndDate = event?.recurrenceEndDate;
    
    // Set selected category if editing existing event
    if (event?.categoryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final category = _categoryController.getCategoryById(event!.categoryId!);
        if (category != null) {
          _categoryController.selectCategory(category);
        }
      });
    }
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Create Recurring Event' : 'Edit Recurring Event'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.event == null ? Icons.repeat : Icons.edit,
                      size: 48,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.event == null ? 'Create Recurring Event' : 'Edit Recurring Event',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event == null
                          ? 'Create events that repeat automatically'
                          : 'Update your recurring event settings',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Title field
              ModernTextField(
                controller: _titleController,
                labelText: 'Event Title',
                hintText: 'e.g., John\'s Birthday, Weekly Team Meeting',
                prefixIcon: Icons.title,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description field
              ModernTextField(
                controller: _descriptionController,
                labelText: 'Event Description',
                hintText: 'Describe what this recurring event is about',
                prefixIcon: Icons.description,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(500),
                ],
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 10) {
                      return 'Description must be at least 10 characters long';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Recurrence Pattern Section
              Text(
                'Recurrence Pattern',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Recurrence Type
              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Repeat Every',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Interval input
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: _recurrenceInterval.toString(),
                            decoration: InputDecoration(
                              labelText: 'Count',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            onChanged: (value) {
                              _recurrenceInterval = int.tryParse(value) ?? 1;
                            },
                            validator: (value) {
                              final num = int.tryParse(value ?? '');
                              if (num == null || num < 1) {
                                return 'Min 1';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Recurrence type dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _recurrenceType,
                            decoration: InputDecoration(
                              labelText: 'Period',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'daily', child: Text('Day(s)')),
                              DropdownMenuItem(value: 'weekly', child: Text('Week(s)')),
                              DropdownMenuItem(value: 'monthly', child: Text('Month(s)')),
                              DropdownMenuItem(value: 'yearly', child: Text('Year(s)')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _recurrenceType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Date and Time Section
              Text(
                'Event Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Include time toggle
              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Include Specific Time',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Turn off for all-day events like birthdays',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _includeTime,
                      onChanged: (value) {
                        setState(() {
                          _includeTime = value;
                          if (!value) {
                            _startTime = null;
                            _endTime = null;
                            _endDate = null;
                          } else {
                            _startTime = TimeOfDay.now();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Start Date
              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date' + (_includeTime ? ' & Time' : ''),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _includeTime && _startTime != null
                                ? DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime(
                                    _startDate.year,
                                    _startDate.month,
                                    _startDate.day,
                                    _startTime!.hour,
                                    _startTime!.minute,
                                  ))
                                : DateFormat('MMM dd, yyyy').format(_startDate),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectStartDateTime(),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ),

              // End Date/Time (only if time is included)
              if (_includeTime) ...[
                const SizedBox(height: 12),
                ModernCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_busy,
                        color: theme.colorScheme.secondary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date & Time (Optional)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _endDate == null || _endTime == null
                                  ? 'No end date set'
                                  : DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime(
                                      _endDate!.year,
                                      _endDate!.month,
                                      _endDate!.day,
                                      _endTime!.hour,
                                      _endTime!.minute,
                                    )),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: _endDate == null || _endTime == null
                                    ? theme.colorScheme.onSurfaceVariant
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _selectEndDateTime(),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Change'),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Recurrence End Date
              Text(
                'Recurrence End (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_repeat,
                      color: theme.colorScheme.tertiary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stop Repeating On',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _recurrenceEndDate == null
                                ? 'Never (repeats indefinitely)'
                                : DateFormat('MMM dd, yyyy').format(_recurrenceEndDate!),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: _recurrenceEndDate == null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectRecurrenceEndDate(),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Location Section
              Text(
                'Event Location (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              ModernTextField(
                controller: _addressController,
                labelText: 'Event Address',
                hintText: 'Enter the venue address',
                prefixIcon: Icons.location_on,
                keyboardType: TextInputType.streetAddress,
                textCapitalization: TextCapitalization.words,
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Category Selection
              Text(
                'Event Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              Obx(() {
                if (_categoryController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final categories = _categoryController.activeCategories;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final isSelected = _categoryController.selectedCategory.value?.categoryId == category.categoryId;
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.iconData,
                            size: 16,
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(category.name),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _categoryController.selectCategory(category);
                        } else {
                          _categoryController.clearSelection();
                        }
                      },
                      backgroundColor: theme.colorScheme.surface,
                      selectedColor: theme.colorScheme.primary,
                      checkmarkColor: theme.colorScheme.onPrimary,
                      labelStyle: TextStyle(
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                );
              }),

              const SizedBox(height: 32),

              // Submit Button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.tertiary,
                      theme.colorScheme.tertiary.withValues(alpha: 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.event == null ? 'Create Recurring Event' : 'Update Recurring Event',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectStartDateTime() async {
    final DateTime? date = await showDatePicker(
      context: this.context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
      });
      
      if (_includeTime) {
        if (!mounted) return;
        final TimeOfDay? time = await showTimePicker(
          context: this.context,
          initialTime: _startTime ?? TimeOfDay.now(),
        );
        
        if (time != null) {
          setState(() {
            _startTime = time;
          });
        }
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final DateTime? date = await showDatePicker(
      context: this.context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      setState(() {
        _endDate = date;
      });
      
      if (!mounted) return;
      final TimeOfDay? time = await showTimePicker(
        context: this.context,
        initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
      );
      
      if (time != null) {
        setState(() {
          _endTime = time;
        });
      }
    }
  }

  Future<void> _selectRecurrenceEndDate() async {
    final DateTime? date = await showDatePicker(
      context: this.context,
      initialDate: _recurrenceEndDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    
    if (date != null) {
      setState(() {
        _recurrenceEndDate = date;
      });
    } else {
      // Allow clearing the end date
      setState(() {
        _recurrenceEndDate = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ModernSnackbar.error(
        title: 'Validation Error',
        message: 'Please fix the errors in the form',
      );
      return;
    }

    try {
      DateTime startDateTime;
      DateTime? endDateTime;
      
      if (_includeTime && _startTime != null) {
        startDateTime = DateTime(
          _startDate.year,
          _startDate.month,
          _startDate.day,
          _startTime!.hour,
          _startTime!.minute,
        );
        
        if (_endDate != null && _endTime != null) {
          endDateTime = DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
            _endTime!.hour,
            _endTime!.minute,
          );
          
          if (endDateTime.isBefore(startDateTime)) {
            ModernSnackbar.error(
              title: 'Invalid Date',
              message: 'End date/time must be after start date/time',
            );
            return;
          }
        }
      } else {
        // All-day event - set to start of day
        startDateTime = DateTime(_startDate.year, _startDate.month, _startDate.day);
        endDateTime = null;
      }

      final event = widget.event;
      if (event == null) {
        // Create new recurring event
        final success = await _eventController.createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDateTime: startDateTime,
          endDateTime: endDateTime,
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          maxCapacity: _maxCapacity,
          eventType: _eventType,
          categoryId: _categoryController.selectedCategory.value?.categoryId,
          isRecurring: true,
          recurrenceType: _recurrenceType,
          recurrenceInterval: _recurrenceInterval,
          recurrenceEndDate: _recurrenceEndDate,
        );
        
        if (success) {
          ModernSnackbar.success(
            title: 'Recurring Event Created',
            message: 'Your recurring event has been created successfully',
          );
          Get.offAllNamed(ROUTE_RECURRING_EVENTS);
        }
      } else {
        // Update existing recurring event
        final updatedEvent = Event(
          id: event.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDateTime: startDateTime,
          endDateTime: endDateTime,
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
          maxCapacity: _maxCapacity,
          eventType: _eventType,
          categoryId: _categoryController.selectedCategory.value?.categoryId,
          createdBy: event.createdBy,
          createdAt: event.createdAt,
          isCancelled: event.isCancelled,
          isCompleted: event.isCompleted,
          updatedAt: DateTime.now(),
          isRecurring: true,
          recurrenceType: _recurrenceType,
          recurrenceInterval: _recurrenceInterval,
          recurrenceEndDate: _recurrenceEndDate,
        );
        
        final success = await _eventController.updateEvent(updatedEvent);
        if (success) {
          ModernSnackbar.success(
            title: 'Event Updated',
            message: 'Recurring event updated successfully',
          );
          Get.offAllNamed(ROUTE_RECURRING_EVENTS);
        }
      }
    } catch (e) {
      ModernSnackbar.error(
        title: 'Save Failed',
        message: 'Failed to save recurring event. Please try again.',
      );
    }
  }
}
