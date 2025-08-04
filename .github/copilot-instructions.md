# GitHub Copilot Instructions for send_sms_test_app

## CRITICAL: Memory Bank MCP Usage Required
**Before providing any assistance on this project, ALWAYS:**
1. Execute `mcp_memory-bank-m_list_projects` to check for existing context
2. If "send_sms_test_app" exists, run `mcp_memory-bank-m_list_project_files` 
3. Read relevant files using `mcp_memory-bank-m_memory_bank_read`
4. Use stored context to provide enhanced, consistent assistance
5. Store new discoveries and solutions using Memory Bank MCP tools

## Project Overview
This is a Flutter SMS application that allows users to send bulk SMS messages and test SMS functionality. The app supports multiple languages and has a modern Material Design interface.

## Key Information for Copilot

### Project Structure
- **Framework**: Flutter (Dart)
- **Architecture**: StatefulWidget-based screens with service layer
- **State Management**: Basic setState with custom services
- **UI**: Material Design with custom widgets

### Localization Setup
- **Languages**: Uzbek (default), English, Russian
- **Framework**: flutter_localizations with intl package
- **Files**: ARB-based translations in `lib/l10n/`
- **Service**: `LanguageService` for dynamic language switching
- **Widget**: `LanguageSelector` for UI language selection

### Key Services
- `SmsService`: Handles SMS sending functionality
- `FileService`: Manages file picking and contact importing
- `PermissionService`: Manages app permissions
- `LanguageService`: Handles localization and language switching

### Important Patterns

#### Localization Pattern
```dart
// Always use localized strings
Text(AppLocalizations.of(context).buttonLabel)

// For nullable fields, use fallback pattern
String? fileLabel;
// In widget:
label: fileLabel ?? AppLocalizations.of(context).noFileSelected
```

#### File Structure
```
lib/
├── main.dart
├── models/
│   └── contact.dart
├── screens/
│   ├── main_screen.dart
│   ├── settings_screen.dart
│   ├── test_sms_screen.dart
│   └── bulk_sms_screen.dart
├── services/
│   ├── sms_service.dart
│   ├── file_service.dart
│   ├── permission_service.dart
│   └── language_service.dart
├── widgets/
│   ├── animated_card.dart
│   ├── file_picker_widget.dart
│   ├── contacts_list_widget.dart
│   └── language_selector.dart
└── l10n/
    ├── app_en.arb
    ├── app_uz.arb
    └── app_ru.arb
```

### Coding Preferences
- Use meaningful variable names and clear comments
- Follow Flutter/Dart naming conventions
- Implement proper error handling with user-friendly messages
- Always use localized strings (no hardcoded text)
- Prefer StatefulWidget for screens with state
- Use custom widgets for reusable components
- Include proper null safety and type checking

### Dependencies to Consider
- `flutter_localizations` - Already configured
- `intl: ^0.20.2` - Already configured
- `file_picker` - For file selection
- `permission_handler` - For app permissions
- `sms_sender` - For SMS functionality

### Common Issues and Solutions

#### Localization Issues
- **Problem**: Cannot use `AppLocalizations.of(context)` in field initialization
- **Solution**: Use nullable fields with fallback in build methods

#### File Picker Integration
- Always show header configuration dialog before file picking
- Handle CSV and Excel file formats
- Provide clear user feedback for file selection status

#### SMS Functionality
- Always check permissions before sending SMS
- Provide SIM slot selection for dual-SIM devices
- Show clear progress indicators during bulk operations

### When Working on This Project
1. **Always** check for existing localization before adding new strings
2. **Always** use the established service layer patterns
3. **Always** maintain the existing widget structure and naming
4. **Always** test on both single and dual-SIM scenarios
5. **Always** provide proper error handling and user feedback

### Memory Bank MCP Integration
**ALWAYS USE Memory Bank MCP for this project:**
- **Required**: Check for existing project context using `mcp_memory-bank-m_list_projects` at session start
- **Required**: Load project files with `mcp_memory-bank-m_list_project_files` for "send_sms_test_app"
- **Required**: Read relevant context using `mcp_memory-bank-m_memory_bank_read` before providing assistance
- **Required**: Store complex implementation details using `mcp_memory-bank-m_memory_bank_write`
- **Required**: Update existing documentation with `mcp_memory-bank-m_memory_bank_update`

**What to store in Memory Bank:**
- Localization patterns and solutions discovered
- User's specific coding preferences and requirements
- Complex setup instructions and configurations
- Troubleshooting solutions and workarounds
- Architecture decisions and reasoning
- New patterns or solutions found during development

### Testing Considerations
- Test all three languages (Uzbek, English, Russian)
- Test file picker with different CSV/Excel formats
- Test SMS functionality on different Android versions
- Verify permission handling on different devices
- Test SIM slot selection on dual-SIM devices

### Future Enhancement Areas
- Add more languages for broader international support
- Implement contact management features
- Add SMS scheduling functionality
- Enhance file format support (JSON, XML)
- Add SMS templates and message history

This file ensures GitHub Copilot has consistent context about the project structure, patterns, and preferences for all future interactions.
