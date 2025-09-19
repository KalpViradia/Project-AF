import '../utils/import_export.dart';
import '../controller/category_controller.dart';
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
  late CategoryController _categoryController;
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late DateTime _startDateTime;
  late DateTime? _endDateTime;
  int? _maxCapacity;
  String? _eventType;
  
  // Recurring event fields
  bool _isRecurring = false;
  String? _recurrenceType;
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;

  @override
  void initState() {
    super.initState();
    _categoryController = Get.put(CategoryController(Get.find()));
    _initializeControllers();
  }

  String? _normalizeRecurrenceType(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      case 'yearly':
        return 'Yearly';
      default:
        // If it's not one of the allowed values, return null so dropdown shows hint
        return null;
    }
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
    
    // Initialize recurring event fields
    _isRecurring = event?.isRecurring ?? false;
    _recurrenceType = _normalizeRecurrenceType(event?.recurrenceType);
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
        title: Text(widget.event == null ? 'Create Event' : 'Edit Event'),
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.event == null ? Icons.event_note : Icons.edit_note,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.event == null ? 'Create New Event' : 'Edit Event',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event == null
                          ? 'Fill in the details to create your event'
                          : 'Update your event information',
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
                hintText: 'Enter a catchy title for your event',
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
                  if (value.trim().length > 100) {
                    return 'Title cannot exceed 100 characters';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9\s\-_.,!?()]+$').hasMatch(value.trim())) {
                    return 'Title contains invalid characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Description field
              ModernTextField(
                controller: _descriptionController,
                labelText: 'Event Description',
                hintText: 'Describe what your event is about',
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
                    if (value.trim().length > 500) {
                      return 'Description cannot exceed 500 characters';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Date and Time Section
              Text(
                'Event Schedule',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Start Date/Time
              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date & Time',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a').format(_startDateTime),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectDateTime(isStart: true),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // End Date/Time
              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_rounded,
                      color: theme.colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'End Date & Time',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _endDateTime == null
                                ? 'No end date set'
                                : DateFormat('MMM dd, yyyy • hh:mm a').format(_endDateTime!),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: _endDateTime == null
                                  ? theme.colorScheme.onSurfaceVariant
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _selectDateTime(isStart: false),
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Change'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Location Section
              Text(
                'Event Location',
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
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (value.trim().length < 5) {
                      return 'Address must be at least 5 characters';
                    }
                    if (value.trim().length > 200) {
                      return 'Address cannot exceed 200 characters';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Category Section
              Text(
                'Event Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Category Selection
              Obx(() => _buildCategorySelection(theme)),

              const SizedBox(height: 24),

              // Event Settings Section
              Text(
                'Event Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              ModernTextField(
                labelText: 'Maximum Capacity',
                hintText: 'Enter maximum number of attendees',
                prefixIcon: Icons.people_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(7), // Max 1,000,000
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

              const SizedBox(height: 8),
              Text(
                'Leave empty for unlimited capacity',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 24),

              // Recurring Event Section
              Text(
                'Recurring Event',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Recurring toggle
              ModernCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.repeat,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Make this a recurring event',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Perfect for birthdays, anniversaries, and regular events',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value;
                          if (!value) {
                            _recurrenceType = null;
                            _recurrenceInterval = 1;
                            _recurrenceEndDate = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Recurring options (only show when recurring is enabled)
              if (_isRecurring) ...[
                const SizedBox(height: 16),
                
                // Recurrence type dropdown
                ModernCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repeat every',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
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
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final number = int.tryParse(value);
                                if (number == null || number < 1 || number > 99) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                final number = int.tryParse(value);
                                if (number != null && number > 0) {
                                  setState(() {
                                    _recurrenceInterval = number;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Recurrence type dropdown
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _recurrenceType,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              hint: const Text('Select frequency'),
                              items: const [
                                DropdownMenuItem(value: 'Daily', child: Text('Day(s)')),
                                DropdownMenuItem(value: 'Weekly', child: Text('Week(s)')),
                                DropdownMenuItem(value: 'Monthly', child: Text('Month(s)')),
                                DropdownMenuItem(value: 'Yearly', child: Text('Year(s)')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _recurrenceType = value;
                                });
                              },
                              validator: (value) {
                                if (_isRecurring && (value == null || value.isEmpty)) {
                                  return 'Please select frequency';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // End date for recurrence
                ModernCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stop repeating (optional)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.event_repeat,
                            color: theme.colorScheme.secondary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _recurrenceEndDate == null
                                  ? 'No end date (repeats forever)'
                                  : 'Ends on ${DateFormat('MMM dd, yyyy').format(_recurrenceEndDate!)}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: _recurrenceEndDate == null
                                    ? theme.colorScheme.onSurfaceVariant
                                    : null,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _recurrenceEndDate ?? _startDateTime.add(const Duration(days: 365)),
                                firstDate: _startDateTime,
                                lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
                              );
                              if (date != null) {
                                setState(() {
                                  _recurrenceEndDate = date;
                                });
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(_recurrenceEndDate == null ? 'Set' : 'Change'),
                          ),
                          if (_recurrenceEndDate != null)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _recurrenceEndDate = null;
                                });
                              },
                              icon: const Icon(Icons.clear, size: 18),
                              tooltip: 'Remove end date',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Save Button
              ModernButton(
                text: widget.event == null ? 'Create Event' : 'Update Event',
                icon: widget.event == null ? Icons.add_rounded : Icons.save_rounded,
                width: double.infinity,
                onPressed: _submitForm,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection(ThemeData theme) {
    if (_categoryController.isLoading.value) {
      return const ModernCard(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final categories = _categoryController.activeCategories;
    if (categories.isEmpty) {
      return ModernCard(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No categories available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a category for your event',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((category) {
              final isSelected = _categoryController.selectedCategory.value?.categoryId == category.categoryId;
              return GestureDetector(
                onTap: () => _categoryController.selectCategory(category),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.iconData,
                        size: 16,
                        color: isSelected 
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected 
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateTime({required bool isStart}) async {
    
    final DateTime? date = await showDatePicker(
      context: Get.context!,
      initialDate: isStart ? _startDateTime : (_endDateTime ?? _startDateTime),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      selectableDayPredicate: (DateTime date) {
        if (!isStart) {
          return date.isAfter(_startDateTime.subtract(const Duration(days: 1)));
        }
        return true;
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
        // Removed past date validation - events can be created for past dates

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
    // Removed past date validation - events can be created for past dates

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
          categoryId: _categoryController.selectedCategory.value?.categoryId,
          isRecurring: _isRecurring,
          recurrenceType: _recurrenceType,
          recurrenceInterval: _recurrenceInterval,
          recurrenceEndDate: _recurrenceEndDate,
        );
        if (success) {
          ModernSnackbar.success(
            title: 'Event Created',
            message: 'Your event has been created successfully',
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
          categoryId: _categoryController.selectedCategory.value?.categoryId,
          createdBy: event.createdBy,
          createdAt: event.createdAt,
          isCancelled: event.isCancelled,
          isCompleted: event.isCompleted,
          updatedAt: DateTime.now(),
          isRecurring: _isRecurring,
          recurrenceType: _recurrenceType,
          recurrenceInterval: _recurrenceInterval,
          recurrenceEndDate: _recurrenceEndDate,
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
      ModernSnackbar.error(
        title: 'Save Failed',
        message: 'Failed to save event. Please try again.',
      );
    }
  }
}
