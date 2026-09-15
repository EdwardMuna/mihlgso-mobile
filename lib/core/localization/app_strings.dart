import 'package:flutter/widgets.dart';

/// Lightweight manual translations for app-authored UI copy (labels, buttons)
/// that isn't already covered by Flutter's built-in Material localizations.
/// Content coming from the backend (home content, news, etc.) is not covered.
class AppStrings {
  AppStrings._(this._values, this._isSwahili);

  final Map<String, String> _values;
  final bool _isSwahili;

  static const _en = {
    'appTitle': 'MIHLGSO',
    'signIn': 'Sign In',
    'donate': 'Donate',
    'learnMore': 'Learn more',
    'learnMoreAboutUs': 'Learn more about us',
    'viewAll': 'View all',
    'seeGallery': 'See gallery',
    'moreNews': 'More news',
    'makeADonation': 'Make a donation',
    // Auth
    'back': 'Back',
    'signInToYourAccount': 'Sign in to your account',
    'email': 'Email',
    'emailRequired': 'Email is required',
    'enterValidEmail': 'Enter a valid email',
    'password': 'Password',
    'passwordRequired': 'Password is required',
    'forgotPasswordQuestion': 'Forgot password?',
    'noAccountApply': "Don't have an account? Apply for membership",
    'forgotPasswordTitle': 'Forgot Password',
    'resetLinkSentMessage': 'If an account exists for that email, a reset link has been sent. Check your inbox.',
    'backToSignIn': 'Back to Sign In',
    'enterEmailResetInstructions': 'Enter your email and we will send you a link to reset your password.',
    'sendResetLink': 'Send Reset Link',
    'resetPasswordTitle': 'Reset Password',
    'pasteResetTokenInstructions': 'Paste the reset token from the link emailed to you, then choose a new password.',
    'resetToken': 'Reset Token',
    'required': 'Required',
    'newPassword': 'New Password',
    'atLeast8Characters': 'At least 8 characters',
    'confirmNewPassword': 'Confirm New Password',
    'passwordsDoNotMatch': 'Passwords do not match',
    'passwordResetSignInMessage': 'Password reset. Please sign in.',
    // Member shell / dashboard
    'dashboard': 'Dashboard',
    'payments': 'Payments',
    'donations': 'Donations',
    'profile': 'Profile',
    'home': 'Home',
    'recordPayment': 'Record Payment',
    'recordDonation': 'Record Donation',
    'welcomeBack': 'Welcome back,',
    'totalDue': 'Total Due',
    'totalPaid': 'Total Paid',
    'paymentProgress': 'Payment progress',
    'recentPayments': 'Recent Payments',
    'noPaymentsRecordedYet': 'No payments recorded yet.',
    'noPaymentsYetTapRecord': 'No payments yet. Tap "Record Payment" to add one.',
    'noDonationsYetTapRecord': 'No donations yet. Tap "Record Donation" to add one.',
    'generalPurpose': 'General',
    // Record sheets
    'editDonation': 'Edit Donation',
    'amount': 'Amount',
    'enterValidAmount': 'Enter a valid amount',
    'purposeOptional': 'Purpose (optional)',
    'referenceOptional': 'Reference (optional)',
    'notesOptional': 'Notes (optional)',
    'donationDate': 'Donation Date',
    'saveChanges': 'Save Changes',
    'submit': 'Submit',
    'contributionType': 'Contribution Type',
    'selectContributionType': 'Select a contribution type',
    'amountPaid': 'Amount Paid',
    'paymentDate': 'Payment Date',
    // Profile
    'contactAndAddress': 'Contact & Address',
    'phone': 'Phone',
    'postalAddress': 'Postal Address',
    'currentResidential': 'Current Residential',
    'gender': 'Gender',
    'education': 'Education',
    'institution': 'Institution',
    'academicDiscipline': 'Academic Discipline',
    'graduatedYear': 'Graduated Year',
    'educationLevel': 'Education Level',
    'employment': 'Employment',
    'employmentStatus': 'Employment Status',
    'employerOffice': 'Employer (Office)',
    'registerAsDonor': 'I would also like to be registered as a donor',
    'profileSaved': 'Profile saved.',
    'passwordUpdated': 'Password updated.',
    'sessionExpiredDueToInactivity': 'You were signed out after 10 minutes of inactivity. Please sign in again.',
    'savingEllipsis': 'Saving...',
    'saveProfile': 'Save profile',
    'changePassword': 'Change Password',
    'currentPassword': 'Current password',
    'newPasswordMinChars': 'New password (min 8 chars)',
    'passwordMustBeAtLeast8': 'Password must be at least 8 characters',
    'updatingEllipsis': 'Updating...',
    'updatePassword': 'Update password',
    'signOut': 'Sign Out',
    'tapPhotoToChange': 'Tap photo to change · JPG or PNG, max 2MB',
    'newPhotoSelected': 'New photo selected',
    // Admin shell
    'applications': 'Applications',
    'members': 'Members',
    'contributionTypes': 'Contribution Types',
    'mosms': 'MoSMS',
    'settings': 'Settings',
    'administrator': 'Administrator',
    'administratorAllCaps': 'ADMINISTRATOR',
    'retry': 'Retry',
    // Admin dashboard
    'beneficiariesServedTitle': 'Beneficiaries Served',
    'totalBeneficiaries': 'Total beneficiaries',
    'cancel': 'Cancel',
    'save': 'Save',
    'smsBalance': 'SMS Balance',
    'whatsappBalance': 'WhatsApp Balance',
    'donors': 'Donors',
    'pendingApplications': 'Pending Applications',
    'pendingApprovals': 'Pending Approvals',
    'totalDonated': 'Total Donated',
    'totalContributed': 'Total contributed',
    'totalContributedAndDonated': 'Overall Total',
    // Apply screen
    'applyForMembership': 'Apply for Membership',
    'applicationSubmittedMessage': 'Application submitted! We will review it and email you the outcome.',
    'stakeholder': 'Stakeholder',
    'member': 'Member',
    'fullName': 'Full Name',
    'phoneLabel': 'Phone',
    'enterValidPhone': 'Enter a valid phone',
    'currentResidentialAddress': 'Current Residential Address',
    'postalAddressOptional': 'Postal Address (optional)',
    'levelOfEducation': 'Level of Education',
    'employerOptional': 'Employer (optional)',
    'addPassportPhotoOptional': 'Add Passport Photo (optional)',
    'photoSelected': 'Photo Selected',
    'submitApplication': 'Submit Application',
    // Public: About / Vision / History / Constitution
    'aboutUsTitle': 'About Us',
    'aboutSectionsTooltip': 'About sections',
    'about': 'About',
    'aboutMihlgso': 'About MIHLGSO',
    'visionMission': 'Vision & Mission',
    'history': 'History',
    'constitution': 'Constitution',
    'couldNotOpenPdf': 'Could not open the PDF.',
    // Public: Contact / Donate
    'contactUsTitle': 'Contact Us',
    'contact': 'Contact',
    'couldNotOpenLink': 'Could not open that link.',
    // Public: Gallery
    'gallery': 'Gallery',
    'noPhotosYet': 'No photos yet.',
    // Public: Leadership
    'leadershipTitle': 'Leadership',
    'leadershipSectionsTooltip': 'Leadership sections',
    'overview': 'Overview',
    'board': 'Board',
    'executive': 'Executive',
    'departments': 'Departments',
    'noLeadershipProfilesYet': 'No leadership profiles yet.',
    'openRoles': 'Open Roles',
    'noBoardMembersYet': 'No board members published yet.',
    'noExecutiveMembersYet': 'No executive members published yet.',
    // Public: Membership
    'membership': 'Membership',
    'checkApplicationStatus': 'Check Application Status',
    'enterEmailForStatusInstructions': 'Enter the email address you used when applying to see your current status.',
    'checkStatus': 'Check Status',
    'statusApprovedMessage': 'Approved — you are already a member.',
    'statusPendingMessage': 'Your application is pending review.',
    'statusRejectedMessage': 'Your application was not approved.',
    'statusNotFoundMessage': 'No application found for this email.',
    // Public: News / Projects
    'newsAndEvents': 'News & Events',
    'newsAndMilestonesTitle': 'News & Milestones',
    'noNewsYet': 'No news yet.',
    'close': 'Close',
    'projects': 'Projects',
    'noProjectsYet': 'No projects yet.',
    'projectBeneficiaries': 'Beneficiaries',
    'atAGlance': 'At a Glance',
    'phases': 'Phases',
    'supportThisProject': 'Support This Project',
    // Widgets: drawer / footer
    'orgTagline': 'Mafia Island Higher Learning Graduates & Students Organization',
    'getInvolved': 'Get Involved',
    'quickLinks': 'Quick Links',
    'orgBlurb': 'A registered Tanzanian non-profit serving Mafia Island since 2009.',
    'registeredNgoSince': 'Registered NGO since 3 December 2012',
    'addressMafia': 'Mafia Island, Tanzania',
    'developedByPrefix': 'Developed by ',
    // Admin: shared
    'ok': 'OK',
    'reject': 'Reject',
    'approve': 'Approve',
    'delete': 'Delete',
    'edit': 'Edit',
    'name': 'Name',
    'active': 'Active',
    'inactive': 'Inactive',
    'nationality': 'Nationality',
    'placeOfLiving': 'Place of Living',
    'memberType': 'Member Type',
    'role': 'Role',
    'status': 'Status',
    'donorLabel': 'Donor',
    'yes': 'Yes',
    'no': 'No',
    'joined': 'Joined',
    'reviewedPrefix': 'Reviewed',
    'recordedPrefix': 'Recorded',
    'addedPrefix': 'Added',
    'refPrefix': 'Ref',
    'memberPrefix': 'Member',
    'graduatedPrefix': 'Graduated',
    'joinedPrefix': 'Joined',
    'dateLabel': 'Date',
    'descriptionOptional': 'Description (optional)',
    // Admin: applications
    'applicationApprovedTitle': 'Application Approved',
    'memberAccountCreatedMessage': 'A member account was created.',
    'temporaryPasswordLabel': 'Temporary password: ',
    'emailedToApplicantMessage': 'This was also emailed to the applicant.',
    'copyPasswordTooltip': 'Copy password',
    'copiedToClipboard': 'Copied to clipboard',
    'noPendingApplications': 'No pending applications.',
    // Admin: members
    'addMember': 'Add Member',
    'addMemberTooltip': 'Add Member',
    'searchMembersHint': 'Search by name, email, or phone',
    'noMembersFound': 'No members found.',
    'donorChip': 'Donor',
    'adminChip': 'Admin',
    'editMemberTitle': 'Edit Member',
    'addMemberTitleForm': 'Add Member',
    'tapToSetPassportPhoto': 'Tap to set passport photo (JPG or PNG, max 2MB)',
    'accountStatus': 'Account Status',
    'newPasswordOptional': 'New Password (optional)',
    'initialPassword': 'Initial Password',
    'activeStatus': 'Active',
    'suspendedStatus': 'Suspended',
    'nameRequired': 'Name is required',
    'registerButton': 'Register',
    'diploma': 'Diploma',
    'bachelorsDegree': "Bachelor's Degree",
    'mastersDegree': "Master's Degree",
    'phd': 'PhD',
    'prof': 'Prof',
    'employmentStatusEmployed': 'Employed',
    'employmentStatusUnemployed': 'Unemployed',
    'employmentStatusSelfEmployed': 'Self-employed',
    'employmentStatusRetired': 'Retired',
    'editTooltip': 'Edit',
    'failedToLoadMemberPrefix': 'Failed to load member: ',
    'roleLabel': 'Role',
    'educationLevelLabel': 'Education level',
    'academicDisciplineLabel': 'Academic discipline',
    'graduatedYearLabel': 'Graduated year',
    'employmentStatusLabel2': 'Employment status',
    'postalAddressLabel': 'Postal address',
    'currentResidentialAddressLabel': 'Current residential address',
    // Admin: payments
    'addPaymentTitle': 'Add Payment',
    'paymentAdminLimitationMessage':
        'The server does not yet support recording a payment for another member from the admin panel. This records a payment under your own admin account. Full member-selectable payment entry requires a backend update.',
    'recordButton': 'Record',
    'deletePaymentTitle': 'Delete Payment',
    'deletePaymentMessage': 'This permanently removes the payment record. This cannot be undone.',
    'addPaymentTooltip': 'Add Payment',
    'searchPaymentsHint': 'Search name, reference, member',
    'totalRemainingPrefix': 'Total remaining',
    'noPaymentsMatchFilters': 'No payments match your filters.',
    'duePrefix': 'Due',
    'paidPrefix': 'Paid',
    'remainingPrefix': 'Remaining',
    'paymentDatePrefix': 'Payment date',
    'deleteTooltip': 'Delete',
    'allStatuses': 'All statuses',
    'pendingApproval': 'Pending approval',
    'approvedStatus': 'Approved',
    'rejectedStatus': 'Rejected',
    'paidStatus': 'Paid',
    'partiallyPaidStatus': 'Partially paid',
    'notPaidStatus': 'Not paid',
    'dateRange': 'Date range',
    'clearDateRange': 'Clear date range',
    'editPaymentTitle': 'Edit Payment',
    'paymentEditLimitationMessage':
        'The server currently only supports approving or rejecting a payment here — editing the amount, date, member, or contribution type requires a backend update.',
    'paymentNameLabel': 'Payment Name',
    'memberLabel': 'Member',
    'amountDueLabel': 'Amount Due',
    'remainingLabel': 'Remaining',
    'approvalStatusLabel': 'Approval Status',
    'reviewedLabel': 'Reviewed',
    'recordedLabel': 'Recorded',
    'lastUpdatedLabel': 'Last Updated',
    // Admin: donations
    'deleteDonationTitle': 'Delete Donation',
    'deleteDonationMessage': 'This permanently removes the donation record. This cannot be undone.',
    'donorNameRequired': 'Donor name *',
    'donorEmail': 'Donor email',
    'donorPhone': 'Donor phone',
    'amountRequired': 'Amount *',
    'purposeLabel': 'Purpose',
    'referenceLabel': 'Reference',
    'notesLabel': 'Notes',
    'changeButton': 'Change',
    'recordDonationTooltip': 'Record donation',
    'searchDonationsHint': 'Search donor, purpose, reference, member',
    'totalDonatedPrefix': 'Total donated',
    'noDonationsMatchFilters': 'No donations match your filters.',
    'donatedPrefix': 'Donated',
    // Admin: contribution types
    'newContributionType': 'New Contribution Type',
    'editContributionType': 'Edit Contribution Type',
    'amountTsh': 'Amount (TSh)',
    'enterValidNameAmount': 'Enter a valid name and amount.',
    'deleteContributionTypeTitle': 'Delete Contribution Type',
    'noContributionTypesYet': 'No contribution types yet.',
    // Admin: settings
    'organizationSettings': 'Organization Settings',
    'enterValidNonNegativeNumber': 'Enter a valid non-negative number.',
    'settingsSaved': 'Settings saved.',
    // MoSMS
    'inbox': 'Inbox',
    'noInboundMessages': 'No inbound messages.\nMoSMS does not yet expose an inbox API.',
    'templates': 'Templates',
    'newTemplate': 'New Template',
    'editTemplate': 'Edit Template',
    'deleteTemplateTitle': 'Delete Template',
    'messageBodyLabel': 'Message Body',
    'noTemplatesYet': 'No templates yet.',
    'contacts': 'Contacts',
    'addContact': 'Add Contact',
    'editContact': 'Edit Contact',
    'deleteContactTitle': 'Delete Contact',
    'emailOptional': 'Email (optional)',
    'searchContacts': 'Search contacts',
    'noContactsFound': 'No contacts found.',
    'smsLogs': 'SMS Logs',
    'noSmsLogsFound': 'No SMS logs found.',
    'sentPrefix': 'Sent',
    'donePrefix': 'Done',
    'smsCountPrefix': 'SMS Count',
    'deliveryReports': 'Delivery Reports',
    'filterByMessageId': 'Filter by message ID',
    'noDeliveryReportsFound': 'No delivery reports found.',
    'scheduledMessages': 'Scheduled Messages',
    'scheduleMessageTitle': 'Schedule Message',
    'scheduleButton': 'Schedule',
    'pickButton': 'Pick',
    'toPhoneNumber': 'To (phone number)',
    'messageLabel': 'Message',
    'noDateTimeSelected': 'No date/time selected',
    'scheduleValidationMessage': 'To, message, and date/time are required.',
    'noScheduledMessages': 'No scheduled messages.',
    'bulkSms': 'Bulk SMS',
    'groupSms': 'Group SMS',
    'messagesNav': 'Messages',
    'scheduledNav': 'Scheduled',
    'groupsNav': 'Groups',
    'manageSectionHeader': 'MANAGE',
    'sendMessageTitle': 'Send Message',
    'sendButton': 'Send',
    'useTemplate': 'Use Template',
    'singleTab': 'Single',
    'bulkTab': 'Bulk',
    'toGroupTab': 'To Group',
    'onePerLineHint': 'One per line: phone | message',
    'onePerLineExample': 'e.g. 255700000000 | Hello from MIHLGSO',
    'groupLabel': 'Group',
    'noTemplatesYetSnack': 'No templates yet.',
    'messageSentSnack': 'Message sent.',
    'messagesTitle': 'Messages',
    'messageDetailsTitle': 'Message Details',
    'newMessageTooltip': 'New Message',
    'filterAll': 'All',
    'filterSent': 'Sent',
    'filterDelivered': 'Delivered',
    'filterFailed': 'Failed',
    'filterPending': 'Pending',
    'filterScheduled': 'Scheduled',
    'checkStatusButton': 'Check Status',
    'noMessagesYet': 'No messages yet.',
    'toLabel': 'To',
    'channelLabel': 'Channel',
    'deliveryLabel': 'Delivery',
    'deliveryErrorLabel': 'Delivery Error',
    'sentAtLabel': 'Sent At',
    'scheduledAtLabel': 'Scheduled At',
    'sentByLabel': 'Sent By',
    'doneButton': 'Done',
    'newContactButton': 'New Contact',
    'addNewContactTitle': 'Add New Contact',
    'addButton': 'Add',
    'noContactsYetTapNew': 'No contacts yet. Tap "New Contact" to add one.',
    'newGroup': 'New Group',
    'editGroup': 'Edit Group',
    'deleteGroupTitle': 'Delete Group',
    'noGroupsYet': 'No groups yet.',
    'editMenuItem': 'Edit',
    'groupFallbackTitle': 'Group',
    'messageGroupButton': 'Message Group',
    'addMembersButton': 'Add Members',
    'noContactsInGroupYet': 'No contacts in this group yet.',
  };

  static const _sw = {
    'appTitle': 'MIHLGSO',
    'signIn': 'Ingia',
    'donate': 'Changia',
    'learnMore': 'Jifunze zaidi',
    'learnMoreAboutUs': 'Jifunze zaidi kutuhusu',
    'viewAll': 'Ona zote',
    'seeGallery': 'Ona picha',
    'moreNews': 'Habari zaidi',
    'makeADonation': 'Toa mchango',
    // Auth
    'back': 'Rudi',
    'signInToYourAccount': 'Ingia kwenye akaunti yako',
    'email': 'Barua pepe',
    'emailRequired': 'Barua pepe inahitajika',
    'enterValidEmail': 'Weka barua pepe sahihi',
    'password': 'Nenosiri',
    'passwordRequired': 'Nenosiri linahitajika',
    'forgotPasswordQuestion': 'Umesahau nenosiri?',
    'noAccountApply': 'Huna akaunti? Omba uanachama',
    'forgotPasswordTitle': 'Umesahau Nenosiri',
    'resetLinkSentMessage': 'Iwapo akaunti ipo kwa barua pepe hiyo, kiungo cha kubadilisha nenosiri kimetumwa. Angalia kikasha chako.',
    'backToSignIn': 'Rudi Kuingia',
    'enterEmailResetInstructions': 'Weka barua pepe yako na tutakutumia kiungo cha kubadilisha nenosiri lako.',
    'sendResetLink': 'Tuma Kiungo cha Kubadilisha',
    'resetPasswordTitle': 'Badilisha Nenosiri',
    'pasteResetTokenInstructions': 'Bandika msimbo (token) uliotumwa kwenye barua pepe yako, kisha chagua nenosiri jipya.',
    'resetToken': 'Msimbo wa Kubadilisha',
    'required': 'Inahitajika',
    'newPassword': 'Nenosiri Jipya',
    'atLeast8Characters': 'Angalau herufi 8',
    'confirmNewPassword': 'Thibitisha Nenosiri Jipya',
    'passwordsDoNotMatch': 'Manenosiri hayafanani',
    'passwordResetSignInMessage': 'Nenosiri limebadilishwa. Tafadhali ingia.',
    // Member shell / dashboard
    'dashboard': 'Dashibodi',
    'payments': 'Malipo',
    'donations': 'Michango',
    'profile': 'Wasifu',
    'home': 'Nyumbani',
    'recordPayment': 'Weka Malipo',
    'recordDonation': 'Weka Mchango',
    'welcomeBack': 'Karibu tena,',
    'totalDue': 'Jumla Inayodaiwa',
    'totalPaid': 'Jumla Iliyolipwa',
    'paymentProgress': 'Maendeleo ya malipo',
    'recentPayments': 'Malipo ya Hivi Karibuni',
    'noPaymentsRecordedYet': 'Hakuna malipo yaliyorekodiwa bado.',
    'noPaymentsYetTapRecord': 'Hakuna malipo bado. Gusa "Weka Malipo" kuongeza moja.',
    'noDonationsYetTapRecord': 'Hakuna michango bado. Gusa "Weka Mchango" kuongeza moja.',
    'generalPurpose': 'Jumla',
    // Record sheets
    'editDonation': 'Hariri Mchango',
    'amount': 'Kiasi',
    'enterValidAmount': 'Weka kiasi sahihi',
    'purposeOptional': 'Kusudi (si lazima)',
    'referenceOptional': 'Kumbukumbu (si lazima)',
    'notesOptional': 'Maelezo (si lazima)',
    'donationDate': 'Tarehe ya Mchango',
    'saveChanges': 'Hifadhi Mabadiliko',
    'submit': 'Wasilisha',
    'contributionType': 'Aina ya Mchango',
    'selectContributionType': 'Chagua aina ya mchango',
    'amountPaid': 'Kiasi Kilicholipwa',
    'paymentDate': 'Tarehe ya Malipo',
    // Profile
    'contactAndAddress': 'Mawasiliano na Anwani',
    'phone': 'Simu',
    'postalAddress': 'Anwani ya Posta',
    'currentResidential': 'Makazi ya Sasa',
    'gender': 'Jinsia',
    'education': 'Elimu',
    'institution': 'Taasisi',
    'academicDiscipline': 'Fani ya Kitaaluma',
    'graduatedYear': 'Mwaka wa Kuhitimu',
    'educationLevel': 'Kiwango cha Elimu',
    'employment': 'Ajira',
    'employmentStatus': 'Hali ya Ajira',
    'employerOffice': 'Mwajiri (Ofisi)',
    'registerAsDonor': 'Ningependa pia kusajiliwa kama mfadhili',
    'profileSaved': 'Wasifu umehifadhiwa.',
    'passwordUpdated': 'Nenosiri limesasishwa.',
    'sessionExpiredDueToInactivity': 'Umetolewa nje baada ya dakika 10 za kutotumika. Tafadhali ingia tena.',
    'savingEllipsis': 'Inahifadhi...',
    'saveProfile': 'Hifadhi wasifu',
    'changePassword': 'Badilisha Nenosiri',
    'currentPassword': 'Nenosiri la sasa',
    'newPasswordMinChars': 'Nenosiri jipya (angalau herufi 8)',
    'passwordMustBeAtLeast8': 'Nenosiri lazima liwe na angalau herufi 8',
    'updatingEllipsis': 'Inasasisha...',
    'updatePassword': 'Sasisha nenosiri',
    'signOut': 'Toka',
    'tapPhotoToChange': 'Gusa picha kubadilisha · JPG au PNG, upeo MB 2',
    'newPhotoSelected': 'Picha mpya imechaguliwa',
    // Admin shell
    'applications': 'Maombi',
    'members': 'Wanachama',
    'contributionTypes': 'Aina za Michango',
    'mosms': 'MoSMS',
    'settings': 'Mipangilio',
    'administrator': 'Msimamizi',
    'administratorAllCaps': 'MSIMAMIZI',
    'retry': 'Jaribu tena',
    // Admin dashboard
    'beneficiariesServedTitle': 'Wanufaika Waliohudumiwa',
    'totalBeneficiaries': 'Jumla ya wanufaika',
    'cancel': 'Ghairi',
    'save': 'Hifadhi',
    'smsBalance': 'Salio la SMS',
    'whatsappBalance': 'Salio la WhatsApp',
    'donors': 'Wafadhili',
    'pendingApplications': 'Maombi Yanayosubiri',
    'pendingApprovals': 'Idhini Zinazosubiri',
    'totalDonated': 'Jumla Iliyochangwa',
    'totalContributed': 'Jumla iliyochangiwa',
    'totalContributedAndDonated': 'Jumla Kuu',
    // Apply screen
    'applyForMembership': 'Omba Uanachama',
    'applicationSubmittedMessage': 'Ombi limewasilishwa! Tutalipitia na kukutumia matokeo kwa barua pepe.',
    'stakeholder': 'Mdau',
    'member': 'Mwanachama',
    'fullName': 'Jina Kamili',
    'phoneLabel': 'Simu',
    'enterValidPhone': 'Weka namba sahihi ya simu',
    'currentResidentialAddress': 'Anwani ya Makazi ya Sasa',
    'postalAddressOptional': 'Anwani ya Posta (si lazima)',
    'levelOfEducation': 'Kiwango cha Elimu',
    'employerOptional': 'Mwajiri (si lazima)',
    'addPassportPhotoOptional': 'Ongeza Picha ya Pasipoti (si lazima)',
    'photoSelected': 'Picha Imechaguliwa',
    'submitApplication': 'Wasilisha Ombi',
    // Public: About / Vision / History / Constitution
    'aboutUsTitle': 'Kutuhusu',
    'aboutSectionsTooltip': 'Sehemu za Kutuhusu',
    'about': 'Kutuhusu',
    'aboutMihlgso': 'Kuhusu MIHLGSO',
    'visionMission': 'Dira na Dhamira',
    'history': 'Historia',
    'constitution': 'Katiba',
    'couldNotOpenPdf': 'Imeshindwa kufungua PDF.',
    // Public: Contact / Donate
    'contactUsTitle': 'Wasiliana Nasi',
    'contact': 'Mawasiliano',
    'couldNotOpenLink': 'Imeshindwa kufungua kiungo hicho.',
    // Public: Gallery
    'gallery': 'Picha',
    'noPhotosYet': 'Hakuna picha bado.',
    // Public: Leadership
    'leadershipTitle': 'Uongozi',
    'leadershipSectionsTooltip': 'Sehemu za Uongozi',
    'overview': 'Muhtasari',
    'board': 'Bodi',
    'executive': 'Watendaji',
    'departments': 'Idara',
    'noLeadershipProfilesYet': 'Hakuna wasifu wa viongozi bado.',
    'openRoles': 'Nafasi Wazi',
    'noBoardMembersYet': 'Hakuna wanabodi waliochapishwa bado.',
    'noExecutiveMembersYet': 'Hakuna watendaji waliochapishwa bado.',
    // Public: Membership
    'membership': 'Uanachama',
    'checkApplicationStatus': 'Angalia Hali ya Ombi',
    'enterEmailForStatusInstructions': 'Weka barua pepe uliyotumia kuomba ili kuona hali ya sasa.',
    'checkStatus': 'Angalia Hali',
    'statusApprovedMessage': 'Imeidhinishwa — tayari wewe ni mwanachama.',
    'statusPendingMessage': 'Ombi lako linasubiri ukaguzi.',
    'statusRejectedMessage': 'Ombi lako halikuidhinishwa.',
    'statusNotFoundMessage': 'Hakuna ombi lililopatikana kwa barua pepe hii.',
    // Public: News / Projects
    'newsAndEvents': 'Habari na Matukio',
    'newsAndMilestonesTitle': 'Habari na Mafanikio',
    'noNewsYet': 'Hakuna habari bado.',
    'close': 'Funga',
    'projects': 'Miradi',
    'noProjectsYet': 'Hakuna miradi bado.',
    'projectBeneficiaries': 'Wanufaika',
    'atAGlance': 'Kwa Muhtasari',
    'phases': 'Awamu',
    'supportThisProject': 'Changia Mradi Huu',
    // Widgets: drawer / footer
    'orgTagline': 'Chama cha Wahitimu na Wanafunzi wa Elimu ya Juu wa Kisiwa cha Mafia',
    'getInvolved': 'Shiriki',
    'quickLinks': 'Viungo vya Haraka',
    'orgBlurb': 'Ni asasi isiyo ya kiserikali iliyosajiliwa Tanzania, ikihudumia Kisiwa cha Mafia tangu 2009.',
    'registeredNgoSince': 'Imesajiliwa kama NGO tangu tarehe 3 Desemba 2012',
    'addressMafia': 'Kisiwa cha Mafia, Tanzania',
    'developedByPrefix': 'Imetengenezwa na ',
    // Admin: shared
    'ok': 'Sawa',
    'reject': 'Kataa',
    'approve': 'Idhinisha',
    'delete': 'Futa',
    'edit': 'Hariri',
    'name': 'Jina',
    'active': 'Hai',
    'inactive': 'Haipo Hai',
    'nationality': 'Uraia',
    'placeOfLiving': 'Mahali Anapoishi',
    'memberType': 'Aina ya Mwanachama',
    'role': 'Wadhifa',
    'status': 'Hali',
    'donorLabel': 'Mfadhili',
    'yes': 'Ndiyo',
    'no': 'Hapana',
    'joined': 'Alijiunga',
    'reviewedPrefix': 'Imekaguliwa',
    'recordedPrefix': 'Imerekodiwa',
    'addedPrefix': 'Imeongezwa',
    'refPrefix': 'Kumbukumbu',
    'memberPrefix': 'Mwanachama',
    'graduatedPrefix': 'Alihitimu',
    'joinedPrefix': 'Alijiunga',
    'dateLabel': 'Tarehe',
    'descriptionOptional': 'Maelezo (si lazima)',
    // Admin: applications
    'applicationApprovedTitle': 'Ombi Limeidhinishwa',
    'memberAccountCreatedMessage': 'Akaunti ya mwanachama imetengenezwa.',
    'temporaryPasswordLabel': 'Nenosiri la muda: ',
    'emailedToApplicantMessage': 'Hii pia imetumwa kwa barua pepe ya mwombaji.',
    'copyPasswordTooltip': 'Nakili nenosiri',
    'copiedToClipboard': 'Imenakiliwa',
    'noPendingApplications': 'Hakuna maombi yanayosubiri.',
    // Admin: members
    'addMember': 'Ongeza Mwanachama',
    'addMemberTooltip': 'Ongeza Mwanachama',
    'searchMembersHint': 'Tafuta kwa jina, barua pepe, au simu',
    'noMembersFound': 'Hakuna wanachama waliopatikana.',
    'donorChip': 'Mfadhili',
    'adminChip': 'Msimamizi',
    'editMemberTitle': 'Hariri Mwanachama',
    'addMemberTitleForm': 'Ongeza Mwanachama',
    'tapToSetPassportPhoto': 'Gusa kuweka picha ya pasipoti (JPG au PNG, upeo MB 2)',
    'accountStatus': 'Hali ya Akaunti',
    'newPasswordOptional': 'Nenosiri Jipya (si lazima)',
    'initialPassword': 'Nenosiri la Mwanzo',
    'activeStatus': 'Hai',
    'suspendedStatus': 'Imesimamishwa',
    'nameRequired': 'Jina linahitajika',
    'registerButton': 'Sajili',
    'diploma': 'Diploma',
    'bachelorsDegree': 'Shahada ya Kwanza',
    'mastersDegree': 'Shahada ya Uzamili',
    'phd': 'Uzamivu (PhD)',
    'prof': 'Profesa',
    'employmentStatusEmployed': 'Ameajiriwa',
    'employmentStatusUnemployed': 'Hana Ajira',
    'employmentStatusSelfEmployed': 'Anajiajiri',
    'employmentStatusRetired': 'Amestaafu',
    'editTooltip': 'Hariri',
    'failedToLoadMemberPrefix': 'Imeshindwa kupakia mwanachama: ',
    'roleLabel': 'Wadhifa',
    'educationLevelLabel': 'Kiwango cha elimu',
    'academicDisciplineLabel': 'Fani ya kitaaluma',
    'graduatedYearLabel': 'Mwaka wa kuhitimu',
    'employmentStatusLabel2': 'Hali ya ajira',
    'postalAddressLabel': 'Anwani ya posta',
    'currentResidentialAddressLabel': 'Anwani ya makazi ya sasa',
    // Admin: payments
    'addPaymentTitle': 'Ongeza Malipo',
    'paymentAdminLimitationMessage':
        'Seva bado haiwezi kurekodi malipo kwa niaba ya mwanachama mwingine kutoka kwenye jopo la usimamizi. Hii inarekodi malipo chini ya akaunti yako ya usimamizi. Uwezo kamili wa kuchagua mwanachama unahitaji usasishaji wa seva.',
    'recordButton': 'Rekodi',
    'deletePaymentTitle': 'Futa Malipo',
    'deletePaymentMessage': 'Hii itaondoa kabisa rekodi ya malipo. Haiwezi kutenduliwa.',
    'addPaymentTooltip': 'Ongeza Malipo',
    'searchPaymentsHint': 'Tafuta jina, kumbukumbu, mwanachama',
    'totalRemainingPrefix': 'Jumla Iliyobaki',
    'noPaymentsMatchFilters': 'Hakuna malipo yanayolingana na vichujio vyako.',
    'duePrefix': 'Inadaiwa',
    'paidPrefix': 'Imelipwa',
    'remainingPrefix': 'Imebaki',
    'paymentDatePrefix': 'Tarehe ya malipo',
    'deleteTooltip': 'Futa',
    'allStatuses': 'Hali zote',
    'pendingApproval': 'Inasubiri idhini',
    'approvedStatus': 'Imeidhinishwa',
    'rejectedStatus': 'Imekataliwa',
    'paidStatus': 'Imelipwa',
    'partiallyPaidStatus': 'Imelipwa Kiasi',
    'notPaidStatus': 'Haijalipwa',
    'dateRange': 'Muda wa Tarehe',
    'clearDateRange': 'Futa Muda wa Tarehe',
    'editPaymentTitle': 'Hariri Malipo',
    'paymentEditLimitationMessage':
        'Kwa sasa seva inaruhusu tu kuidhinisha au kukataa malipo hapa — kuhariri kiasi, tarehe, mwanachama, au aina ya mchango kunahitaji usasishaji wa seva.',
    'paymentNameLabel': 'Jina la Malipo',
    'memberLabel': 'Mwanachama',
    'amountDueLabel': 'Kiasi Kinachodaiwa',
    'remainingLabel': 'Kilichobaki',
    'approvalStatusLabel': 'Hali ya Idhini',
    'reviewedLabel': 'Imekaguliwa',
    'recordedLabel': 'Imerekodiwa',
    'lastUpdatedLabel': 'Ilisasishwa Mwisho',
    // Admin: donations
    'deleteDonationTitle': 'Futa Mchango',
    'deleteDonationMessage': 'Hii itaondoa kabisa rekodi ya mchango. Haiwezi kutenduliwa.',
    'donorNameRequired': 'Jina la mfadhili *',
    'donorEmail': 'Barua pepe ya mfadhili',
    'donorPhone': 'Simu ya mfadhili',
    'amountRequired': 'Kiasi *',
    'purposeLabel': 'Kusudi',
    'referenceLabel': 'Kumbukumbu',
    'notesLabel': 'Maelezo',
    'changeButton': 'Badilisha',
    'recordDonationTooltip': 'Rekodi mchango',
    'searchDonationsHint': 'Tafuta mfadhili, kusudi, kumbukumbu, mwanachama',
    'totalDonatedPrefix': 'Jumla Iliyochangwa',
    'noDonationsMatchFilters': 'Hakuna michango inayolingana na vichujio vyako.',
    'donatedPrefix': 'Alichangia',
    // Admin: contribution types
    'newContributionType': 'Aina Mpya ya Mchango',
    'editContributionType': 'Hariri Aina ya Mchango',
    'amountTsh': 'Kiasi (TSh)',
    'enterValidNameAmount': 'Weka jina na kiasi sahihi.',
    'deleteContributionTypeTitle': 'Futa Aina ya Mchango',
    'noContributionTypesYet': 'Hakuna aina za michango bado.',
    // Admin: settings
    'organizationSettings': 'Mipangilio ya Shirika',
    'enterValidNonNegativeNumber': 'Weka namba sahihi isiyo hasi.',
    'settingsSaved': 'Mipangilio imehifadhiwa.',
    // MoSMS
    'inbox': 'Kikasha',
    'noInboundMessages': 'Hakuna ujumbe uliopokelewa.\nMoSMS bado haitoi huduma ya kikasha.',
    'templates': 'Violezo',
    'newTemplate': 'Kiolezo Kipya',
    'editTemplate': 'Hariri Kiolezo',
    'deleteTemplateTitle': 'Futa Kiolezo',
    'messageBodyLabel': 'Maudhui ya Ujumbe',
    'noTemplatesYet': 'Hakuna violezo bado.',
    'contacts': 'Anwani',
    'addContact': 'Ongeza Anwani',
    'editContact': 'Hariri Anwani',
    'deleteContactTitle': 'Futa Anwani',
    'emailOptional': 'Barua pepe (si lazima)',
    'searchContacts': 'Tafuta anwani',
    'noContactsFound': 'Hakuna anwani zilizopatikana.',
    'smsLogs': 'Kumbukumbu za SMS',
    'noSmsLogsFound': 'Hakuna kumbukumbu za SMS zilizopatikana.',
    'sentPrefix': 'Imetumwa',
    'donePrefix': 'Imekamilika',
    'smsCountPrefix': 'Idadi ya SMS',
    'deliveryReports': 'Ripoti za Uwasilishaji',
    'filterByMessageId': 'Chuja kwa kitambulisho cha ujumbe',
    'noDeliveryReportsFound': 'Hakuna ripoti za uwasilishaji zilizopatikana.',
    'scheduledMessages': 'Ujumbe Uliopangwa',
    'scheduleMessageTitle': 'Panga Ujumbe',
    'scheduleButton': 'Panga',
    'pickButton': 'Chagua',
    'toPhoneNumber': 'Kwa (namba ya simu)',
    'messageLabel': 'Ujumbe',
    'noDateTimeSelected': 'Hakuna tarehe/muda uliochaguliwa',
    'scheduleValidationMessage': 'Namba, ujumbe, na tarehe/muda vinahitajika.',
    'noScheduledMessages': 'Hakuna ujumbe uliopangwa.',
    'bulkSms': 'SMS kwa Wingi',
    'groupSms': 'SMS ya Kikundi',
    'messagesNav': 'Ujumbe',
    'scheduledNav': 'Iliyopangwa',
    'groupsNav': 'Vikundi',
    'manageSectionHeader': 'SIMAMIA',
    'sendMessageTitle': 'Tuma Ujumbe',
    'sendButton': 'Tuma',
    'useTemplate': 'Tumia Kiolezo',
    'singleTab': 'Mmoja',
    'bulkTab': 'Wingi',
    'toGroupTab': 'Kwa Kikundi',
    'onePerLineHint': 'Mmoja kwa mstari: simu | ujumbe',
    'onePerLineExample': 'mfano: 255700000000 | Habari kutoka MIHLGSO',
    'groupLabel': 'Kikundi',
    'noTemplatesYetSnack': 'Hakuna violezo bado.',
    'messageSentSnack': 'Ujumbe umetumwa.',
    'messagesTitle': 'Ujumbe',
    'messageDetailsTitle': 'Maelezo ya Ujumbe',
    'newMessageTooltip': 'Ujumbe Mpya',
    'filterAll': 'Zote',
    'filterSent': 'Imetumwa',
    'filterDelivered': 'Imewasilishwa',
    'filterFailed': 'Imeshindwa',
    'filterPending': 'Inasubiri',
    'filterScheduled': 'Imepangwa',
    'checkStatusButton': 'Angalia Hali',
    'noMessagesYet': 'Hakuna ujumbe bado.',
    'toLabel': 'Kwa',
    'channelLabel': 'Njia',
    'deliveryLabel': 'Uwasilishaji',
    'deliveryErrorLabel': 'Hitilafu ya Uwasilishaji',
    'sentAtLabel': 'Ilitumwa Saa',
    'scheduledAtLabel': 'Imepangwa Saa',
    'sentByLabel': 'Ilitumwa Na',
    'doneButton': 'Imekamilika',
    'newContactButton': 'Anwani Mpya',
    'addNewContactTitle': 'Ongeza Anwani Mpya',
    'addButton': 'Ongeza',
    'noContactsYetTapNew': 'Hakuna anwani bado. Gusa "Anwani Mpya" kuongeza moja.',
    'newGroup': 'Kikundi Kipya',
    'editGroup': 'Hariri Kikundi',
    'deleteGroupTitle': 'Futa Kikundi',
    'noGroupsYet': 'Hakuna vikundi bado.',
    'editMenuItem': 'Hariri',
    'groupFallbackTitle': 'Kikundi',
    'messageGroupButton': 'Tuma Ujumbe kwa Kikundi',
    'addMembersButton': 'Ongeza Wanachama',
    'noContactsInGroupYet': 'Hakuna anwani kwenye kikundi hiki bado.',
  };

  static AppStrings of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    final isSwahili = code == 'sw';
    return AppStrings._(isSwahili ? _sw : _en, isSwahili);
  }

  String get appTitle => _values['appTitle']!;
  String get signIn => _values['signIn']!;
  String get donate => _values['donate']!;
  String get learnMore => _values['learnMore']!;
  String get learnMoreAboutUs => _values['learnMoreAboutUs']!;
  String get viewAll => _values['viewAll']!;
  String get seeGallery => _values['seeGallery']!;
  String get moreNews => _values['moreNews']!;
  String get makeADonation => _values['makeADonation']!;

  // Auth
  String get back => _values['back']!;
  String get signInToYourAccount => _values['signInToYourAccount']!;
  String get email => _values['email']!;
  String get emailRequired => _values['emailRequired']!;
  String get enterValidEmail => _values['enterValidEmail']!;
  String get password => _values['password']!;
  String get passwordRequired => _values['passwordRequired']!;
  String get forgotPasswordQuestion => _values['forgotPasswordQuestion']!;
  String get noAccountApply => _values['noAccountApply']!;
  String get forgotPasswordTitle => _values['forgotPasswordTitle']!;
  String get resetLinkSentMessage => _values['resetLinkSentMessage']!;
  String get backToSignIn => _values['backToSignIn']!;
  String get enterEmailResetInstructions => _values['enterEmailResetInstructions']!;
  String get sendResetLink => _values['sendResetLink']!;
  String get resetPasswordTitle => _values['resetPasswordTitle']!;
  String get pasteResetTokenInstructions => _values['pasteResetTokenInstructions']!;
  String get resetToken => _values['resetToken']!;
  String get required => _values['required']!;
  String get newPassword => _values['newPassword']!;
  String get atLeast8Characters => _values['atLeast8Characters']!;
  String get confirmNewPassword => _values['confirmNewPassword']!;
  String get passwordsDoNotMatch => _values['passwordsDoNotMatch']!;
  String get passwordResetSignInMessage => _values['passwordResetSignInMessage']!;

  // Member shell / dashboard
  String get dashboard => _values['dashboard']!;
  String get payments => _values['payments']!;
  String get donations => _values['donations']!;
  String get profile => _values['profile']!;
  String get home => _values['home']!;
  String get recordPayment => _values['recordPayment']!;
  String get recordDonation => _values['recordDonation']!;
  String get welcomeBack => _values['welcomeBack']!;
  String get totalDue => _values['totalDue']!;
  String get totalPaid => _values['totalPaid']!;
  String get paymentProgress => _values['paymentProgress']!;
  String get recentPayments => _values['recentPayments']!;
  String get noPaymentsRecordedYet => _values['noPaymentsRecordedYet']!;
  String get noPaymentsYetTapRecord => _values['noPaymentsYetTapRecord']!;
  String get noDonationsYetTapRecord => _values['noDonationsYetTapRecord']!;
  String get generalPurpose => _values['generalPurpose']!;

  // Record sheets
  String get editDonation => _values['editDonation']!;
  String get amount => _values['amount']!;
  String get enterValidAmount => _values['enterValidAmount']!;
  String get purposeOptional => _values['purposeOptional']!;
  String get referenceOptional => _values['referenceOptional']!;
  String get notesOptional => _values['notesOptional']!;
  String get donationDate => _values['donationDate']!;
  String get saveChanges => _values['saveChanges']!;
  String get submit => _values['submit']!;
  String get contributionType => _values['contributionType']!;
  String get selectContributionType => _values['selectContributionType']!;
  String get amountPaid => _values['amountPaid']!;
  String get paymentDate => _values['paymentDate']!;

  // Profile
  String get contactAndAddress => _values['contactAndAddress']!;
  String get phone => _values['phone']!;
  String get postalAddress => _values['postalAddress']!;
  String get currentResidential => _values['currentResidential']!;
  String get gender => _values['gender']!;
  String get education => _values['education']!;
  String get institution => _values['institution']!;
  String get academicDiscipline => _values['academicDiscipline']!;
  String get graduatedYear => _values['graduatedYear']!;
  String get educationLevel => _values['educationLevel']!;
  String get employment => _values['employment']!;
  String get employmentStatus => _values['employmentStatus']!;
  String get employerOffice => _values['employerOffice']!;
  String get registerAsDonor => _values['registerAsDonor']!;
  String get profileSaved => _values['profileSaved']!;
  String get passwordUpdated => _values['passwordUpdated']!;
  String get sessionExpiredDueToInactivity => _values['sessionExpiredDueToInactivity']!;
  String get savingEllipsis => _values['savingEllipsis']!;
  String get saveProfile => _values['saveProfile']!;
  String get changePassword => _values['changePassword']!;
  String get currentPassword => _values['currentPassword']!;
  String get newPasswordMinChars => _values['newPasswordMinChars']!;
  String get passwordMustBeAtLeast8 => _values['passwordMustBeAtLeast8']!;
  String get updatingEllipsis => _values['updatingEllipsis']!;
  String get updatePassword => _values['updatePassword']!;
  String get signOut => _values['signOut']!;
  String get tapPhotoToChange => _values['tapPhotoToChange']!;
  String get newPhotoSelected => _values['newPhotoSelected']!;

  // Admin shell
  String get applications => _values['applications']!;
  String get members => _values['members']!;
  String get contributionTypes => _values['contributionTypes']!;
  String get mosms => _values['mosms']!;
  String get settings => _values['settings']!;
  String get administrator => _values['administrator']!;
  String get administratorAllCaps => _values['administratorAllCaps']!;
  String get retry => _values['retry']!;
  String get beneficiariesServedTitle => _values['beneficiariesServedTitle']!;
  String get totalBeneficiaries => _values['totalBeneficiaries']!;
  String get cancel => _values['cancel']!;
  String get save => _values['save']!;
  String get smsBalance => _values['smsBalance']!;
  String get whatsappBalance => _values['whatsappBalance']!;
  String get donors => _values['donors']!;
  String get pendingApplications => _values['pendingApplications']!;
  String get pendingApprovals => _values['pendingApprovals']!;
  String get totalDonated => _values['totalDonated']!;
  String get totalContributed => _values['totalContributed']!;
  String get totalContributedAndDonated => _values['totalContributedAndDonated']!;

  // Apply screen
  String get applyForMembership => _values['applyForMembership']!;
  String get applicationSubmittedMessage => _values['applicationSubmittedMessage']!;
  String get stakeholder => _values['stakeholder']!;
  String get member => _values['member']!;
  String get fullName => _values['fullName']!;
  String get phoneLabel => _values['phoneLabel']!;
  String get enterValidPhone => _values['enterValidPhone']!;
  String get currentResidentialAddress => _values['currentResidentialAddress']!;
  String get postalAddressOptional => _values['postalAddressOptional']!;
  String get levelOfEducation => _values['levelOfEducation']!;
  String get employerOptional => _values['employerOptional']!;
  String get addPassportPhotoOptional => _values['addPassportPhotoOptional']!;
  String get photoSelected => _values['photoSelected']!;
  String get submitApplication => _values['submitApplication']!;

  String cannotExceedAmountDue(String due) =>
      _isSwahili ? 'Haiwezi kuzidi kiasi kinachodaiwa ($due)' : 'Cannot exceed amount due ($due)';

  String welcomeUser(String name) => _isSwahili ? 'Karibu, $name' : 'Welcome, $name';

  String copyrightLine(int year) =>
      _isSwahili ? '© $year MIHLGSO. Haki zote zimehifadhiwa.' : '© $year MIHLGSO. All rights reserved.';

  String addToGroupTitle(String groupName) => _isSwahili ? 'Ongeza kwa $groupName' : 'Add to $groupName';

  String addWithCount(int count) => _isSwahili ? 'Ongeza ($count)' : 'Add ($count)';

  String removeTemplateMessage(String name) =>
      _isSwahili ? 'Ondoa "$name"?' : 'Remove "$name"?';

  String removeContactMessage(String name) =>
      _isSwahili ? 'Ondoa $name kutoka kwenye anwani?' : 'Remove $name from contacts?';

  String removeGroupMessage(String name) => _isSwahili
      ? 'Ondoa "$name"? Hii haitafuta anwani zake.'
      : 'Remove "$name"? This does not delete its contacts.';

  String deleteContributionTypeMessage(String name) =>
      _isSwahili ? 'Futa "$name"? Hii haiwezi kutenduliwa.' : 'Delete "$name"? This cannot be undone.';

  String messageSentQueuedSnack(int count) => _isSwahili
      ? 'Ujumbe umetumwa — umepangiwa anwani $count.'
      : 'Message sent — queued for $count contacts.';

  String messageSentToContactsSnack(int count) =>
      _isSwahili ? 'Ujumbe umetumwa — kwa anwani $count.' : 'Message sent — to $count contacts.';

  String noContactsMatchSearch(String query) =>
      _isSwahili ? 'Hakuna anwani zinazolingana na "$query".' : 'No contacts match "$query".';

  // Public: About
  String get aboutUsTitle => _values['aboutUsTitle']!;
  String get aboutSectionsTooltip => _values['aboutSectionsTooltip']!;
  String get about => _values['about']!;
  String get aboutMihlgso => _values['aboutMihlgso']!;
  String get visionMission => _values['visionMission']!;
  String get history => _values['history']!;
  String get constitution => _values['constitution']!;
  String get couldNotOpenPdf => _values['couldNotOpenPdf']!;
  String get contactUsTitle => _values['contactUsTitle']!;
  String get contact => _values['contact']!;
  String get couldNotOpenLink => _values['couldNotOpenLink']!;
  String get gallery => _values['gallery']!;
  String get noPhotosYet => _values['noPhotosYet']!;
  String get leadershipTitle => _values['leadershipTitle']!;
  String get leadershipSectionsTooltip => _values['leadershipSectionsTooltip']!;
  String get overview => _values['overview']!;
  String get board => _values['board']!;
  String get executive => _values['executive']!;
  String get departments => _values['departments']!;
  String get noLeadershipProfilesYet => _values['noLeadershipProfilesYet']!;
  String get openRoles => _values['openRoles']!;
  String get noBoardMembersYet => _values['noBoardMembersYet']!;
  String get noExecutiveMembersYet => _values['noExecutiveMembersYet']!;
  String get membership => _values['membership']!;
  String get checkApplicationStatus => _values['checkApplicationStatus']!;
  String get enterEmailForStatusInstructions => _values['enterEmailForStatusInstructions']!;
  String get checkStatus => _values['checkStatus']!;
  String get statusApprovedMessage => _values['statusApprovedMessage']!;
  String get statusPendingMessage => _values['statusPendingMessage']!;
  String get statusRejectedMessage => _values['statusRejectedMessage']!;
  String get statusNotFoundMessage => _values['statusNotFoundMessage']!;
  String get newsAndEvents => _values['newsAndEvents']!;
  String get newsAndMilestonesTitle => _values['newsAndMilestonesTitle']!;
  String get noNewsYet => _values['noNewsYet']!;
  String get close => _values['close']!;
  String get projects => _values['projects']!;
  String get noProjectsYet => _values['noProjectsYet']!;
  String get projectBeneficiaries => _values['projectBeneficiaries']!;
  String get atAGlance => _values['atAGlance']!;
  String get phases => _values['phases']!;
  String get supportThisProject => _values['supportThisProject']!;

  // Widgets
  String get orgTagline => _values['orgTagline']!;
  String get getInvolved => _values['getInvolved']!;
  String get quickLinks => _values['quickLinks']!;
  String get orgBlurb => _values['orgBlurb']!;
  String get registeredNgoSince => _values['registeredNgoSince']!;
  String get addressMafia => _values['addressMafia']!;
  String get developedByPrefix => _values['developedByPrefix']!;

  // Admin shared
  String get ok => _values['ok']!;
  String get reject => _values['reject']!;
  String get approve => _values['approve']!;
  String get delete => _values['delete']!;
  String get edit => _values['edit']!;
  String get name => _values['name']!;
  String get active => _values['active']!;
  String get inactive => _values['inactive']!;
  String get nationality => _values['nationality']!;
  String get placeOfLiving => _values['placeOfLiving']!;
  String get memberType => _values['memberType']!;
  String get role => _values['role']!;
  String get status => _values['status']!;
  String get donorLabel => _values['donorLabel']!;
  String get yes => _values['yes']!;
  String get no => _values['no']!;
  String get joined => _values['joined']!;
  String get reviewedPrefix => _values['reviewedPrefix']!;
  String get recordedPrefix => _values['recordedPrefix']!;
  String get addedPrefix => _values['addedPrefix']!;
  String get refPrefix => _values['refPrefix']!;
  String get memberPrefix => _values['memberPrefix']!;
  String get graduatedPrefix => _values['graduatedPrefix']!;
  String get joinedPrefix => _values['joinedPrefix']!;
  String get dateLabel => _values['dateLabel']!;
  String get descriptionOptional => _values['descriptionOptional']!;

  // Admin: applications
  String get applicationApprovedTitle => _values['applicationApprovedTitle']!;
  String get memberAccountCreatedMessage => _values['memberAccountCreatedMessage']!;
  String get temporaryPasswordLabel => _values['temporaryPasswordLabel']!;
  String get emailedToApplicantMessage => _values['emailedToApplicantMessage']!;
  String get copyPasswordTooltip => _values['copyPasswordTooltip']!;
  String get copiedToClipboard => _values['copiedToClipboard']!;
  String get noPendingApplications => _values['noPendingApplications']!;

  // Admin: members
  String get addMember => _values['addMember']!;
  String get addMemberTooltip => _values['addMemberTooltip']!;
  String get searchMembersHint => _values['searchMembersHint']!;
  String get noMembersFound => _values['noMembersFound']!;
  String get donorChip => _values['donorChip']!;
  String get adminChip => _values['adminChip']!;
  String get editMemberTitle => _values['editMemberTitle']!;
  String get addMemberTitleForm => _values['addMemberTitleForm']!;
  String get tapToSetPassportPhoto => _values['tapToSetPassportPhoto']!;
  String get accountStatus => _values['accountStatus']!;
  String get newPasswordOptional => _values['newPasswordOptional']!;
  String get initialPassword => _values['initialPassword']!;
  String get activeStatus => _values['activeStatus']!;
  String get suspendedStatus => _values['suspendedStatus']!;
  String get nameRequired => _values['nameRequired']!;
  String get registerButton => _values['registerButton']!;
  String get diploma => _values['diploma']!;
  String get bachelorsDegree => _values['bachelorsDegree']!;
  String get mastersDegree => _values['mastersDegree']!;
  String get phd => _values['phd']!;
  String get prof => _values['prof']!;
  String get employmentStatusEmployed => _values['employmentStatusEmployed']!;
  String get employmentStatusUnemployed => _values['employmentStatusUnemployed']!;
  String get employmentStatusSelfEmployed => _values['employmentStatusSelfEmployed']!;
  String get employmentStatusRetired => _values['employmentStatusRetired']!;
  String get editTooltip => _values['editTooltip']!;
  String get failedToLoadMemberPrefix => _values['failedToLoadMemberPrefix']!;
  String get roleLabel => _values['roleLabel']!;
  String get educationLevelLabel => _values['educationLevelLabel']!;
  String get academicDisciplineLabel => _values['academicDisciplineLabel']!;
  String get graduatedYearLabel => _values['graduatedYearLabel']!;
  String get employmentStatusLabel2 => _values['employmentStatusLabel2']!;
  String get postalAddressLabel => _values['postalAddressLabel']!;
  String get currentResidentialAddressLabel => _values['currentResidentialAddressLabel']!;

  // Admin: payments
  String get addPaymentTitle => _values['addPaymentTitle']!;
  String get paymentAdminLimitationMessage => _values['paymentAdminLimitationMessage']!;
  String get recordButton => _values['recordButton']!;
  String get deletePaymentTitle => _values['deletePaymentTitle']!;
  String get deletePaymentMessage => _values['deletePaymentMessage']!;
  String get addPaymentTooltip => _values['addPaymentTooltip']!;
  String get searchPaymentsHint => _values['searchPaymentsHint']!;
  String get totalRemainingPrefix => _values['totalRemainingPrefix']!;
  String get noPaymentsMatchFilters => _values['noPaymentsMatchFilters']!;
  String get duePrefix => _values['duePrefix']!;
  String get paidPrefix => _values['paidPrefix']!;
  String get remainingPrefix => _values['remainingPrefix']!;
  String get paymentDatePrefix => _values['paymentDatePrefix']!;
  String get deleteTooltip => _values['deleteTooltip']!;
  String get allStatuses => _values['allStatuses']!;
  String get pendingApproval => _values['pendingApproval']!;
  String get approvedStatus => _values['approvedStatus']!;
  String get rejectedStatus => _values['rejectedStatus']!;
  String get paidStatus => _values['paidStatus']!;
  String get partiallyPaidStatus => _values['partiallyPaidStatus']!;
  String get notPaidStatus => _values['notPaidStatus']!;
  String get dateRange => _values['dateRange']!;
  String get clearDateRange => _values['clearDateRange']!;
  String get editPaymentTitle => _values['editPaymentTitle']!;
  String get paymentEditLimitationMessage => _values['paymentEditLimitationMessage']!;
  String get paymentNameLabel => _values['paymentNameLabel']!;
  String get memberLabel => _values['memberLabel']!;
  String get amountDueLabel => _values['amountDueLabel']!;
  String get remainingLabel => _values['remainingLabel']!;
  String get approvalStatusLabel => _values['approvalStatusLabel']!;
  String get reviewedLabel => _values['reviewedLabel']!;
  String get recordedLabel => _values['recordedLabel']!;
  String get lastUpdatedLabel => _values['lastUpdatedLabel']!;

  // Admin: donations
  String get deleteDonationTitle => _values['deleteDonationTitle']!;
  String get deleteDonationMessage => _values['deleteDonationMessage']!;
  String get donorNameRequired => _values['donorNameRequired']!;
  String get donorEmail => _values['donorEmail']!;
  String get donorPhone => _values['donorPhone']!;
  String get amountRequired => _values['amountRequired']!;
  String get purposeLabel => _values['purposeLabel']!;
  String get referenceLabel => _values['referenceLabel']!;
  String get notesLabel => _values['notesLabel']!;
  String get changeButton => _values['changeButton']!;
  String get recordDonationTooltip => _values['recordDonationTooltip']!;
  String get searchDonationsHint => _values['searchDonationsHint']!;
  String get totalDonatedPrefix => _values['totalDonatedPrefix']!;
  String get noDonationsMatchFilters => _values['noDonationsMatchFilters']!;
  String get donatedPrefix => _values['donatedPrefix']!;

  // Admin: contribution types
  String get newContributionType => _values['newContributionType']!;
  String get editContributionType => _values['editContributionType']!;
  String get amountTsh => _values['amountTsh']!;
  String get enterValidNameAmount => _values['enterValidNameAmount']!;
  String get deleteContributionTypeTitle => _values['deleteContributionTypeTitle']!;
  String get noContributionTypesYet => _values['noContributionTypesYet']!;

  // Admin: settings
  String get organizationSettings => _values['organizationSettings']!;
  String get enterValidNonNegativeNumber => _values['enterValidNonNegativeNumber']!;
  String get settingsSaved => _values['settingsSaved']!;

  // MoSMS
  String get inbox => _values['inbox']!;
  String get noInboundMessages => _values['noInboundMessages']!;
  String get templates => _values['templates']!;
  String get newTemplate => _values['newTemplate']!;
  String get editTemplate => _values['editTemplate']!;
  String get deleteTemplateTitle => _values['deleteTemplateTitle']!;
  String get messageBodyLabel => _values['messageBodyLabel']!;
  String get noTemplatesYet => _values['noTemplatesYet']!;
  String get contacts => _values['contacts']!;
  String get addContact => _values['addContact']!;
  String get editContact => _values['editContact']!;
  String get deleteContactTitle => _values['deleteContactTitle']!;
  String get emailOptional => _values['emailOptional']!;
  String get searchContacts => _values['searchContacts']!;
  String get noContactsFound => _values['noContactsFound']!;
  String get smsLogs => _values['smsLogs']!;
  String get noSmsLogsFound => _values['noSmsLogsFound']!;
  String get sentPrefix => _values['sentPrefix']!;
  String get donePrefix => _values['donePrefix']!;
  String get smsCountPrefix => _values['smsCountPrefix']!;
  String get deliveryReports => _values['deliveryReports']!;
  String get filterByMessageId => _values['filterByMessageId']!;
  String get noDeliveryReportsFound => _values['noDeliveryReportsFound']!;
  String get scheduledMessages => _values['scheduledMessages']!;
  String get scheduleMessageTitle => _values['scheduleMessageTitle']!;
  String get scheduleButton => _values['scheduleButton']!;
  String get pickButton => _values['pickButton']!;
  String get toPhoneNumber => _values['toPhoneNumber']!;
  String get messageLabel => _values['messageLabel']!;
  String get noDateTimeSelected => _values['noDateTimeSelected']!;
  String get scheduleValidationMessage => _values['scheduleValidationMessage']!;
  String get noScheduledMessages => _values['noScheduledMessages']!;
  String get bulkSms => _values['bulkSms']!;
  String get groupSms => _values['groupSms']!;
  String get messagesNav => _values['messagesNav']!;
  String get scheduledNav => _values['scheduledNav']!;
  String get groupsNav => _values['groupsNav']!;
  String get manageSectionHeader => _values['manageSectionHeader']!;
  String get sendMessageTitle => _values['sendMessageTitle']!;
  String get sendButton => _values['sendButton']!;
  String get useTemplate => _values['useTemplate']!;
  String get singleTab => _values['singleTab']!;
  String get bulkTab => _values['bulkTab']!;
  String get toGroupTab => _values['toGroupTab']!;
  String get onePerLineHint => _values['onePerLineHint']!;
  String get onePerLineExample => _values['onePerLineExample']!;
  String get groupLabel => _values['groupLabel']!;
  String get noTemplatesYetSnack => _values['noTemplatesYetSnack']!;
  String get messageSentSnack => _values['messageSentSnack']!;
  String get messagesTitle => _values['messagesTitle']!;
  String get messageDetailsTitle => _values['messageDetailsTitle']!;
  String get newMessageTooltip => _values['newMessageTooltip']!;
  String get filterAll => _values['filterAll']!;
  String get filterSent => _values['filterSent']!;
  String get filterDelivered => _values['filterDelivered']!;
  String get filterFailed => _values['filterFailed']!;
  String get filterPending => _values['filterPending']!;
  String get filterScheduled => _values['filterScheduled']!;
  String get checkStatusButton => _values['checkStatusButton']!;
  String get noMessagesYet => _values['noMessagesYet']!;
  String get toLabel => _values['toLabel']!;
  String get channelLabel => _values['channelLabel']!;
  String get deliveryLabel => _values['deliveryLabel']!;
  String get deliveryErrorLabel => _values['deliveryErrorLabel']!;
  String get sentAtLabel => _values['sentAtLabel']!;
  String get scheduledAtLabel => _values['scheduledAtLabel']!;
  String get sentByLabel => _values['sentByLabel']!;
  String get doneButton => _values['doneButton']!;
  String get newContactButton => _values['newContactButton']!;
  String get addNewContactTitle => _values['addNewContactTitle']!;
  String get addButton => _values['addButton']!;
  String get noContactsYetTapNew => _values['noContactsYetTapNew']!;
  String get newGroup => _values['newGroup']!;
  String get editGroup => _values['editGroup']!;
  String get deleteGroupTitle => _values['deleteGroupTitle']!;
  String get noGroupsYet => _values['noGroupsYet']!;
  String get editMenuItem => _values['editMenuItem']!;
  String get groupFallbackTitle => _values['groupFallbackTitle']!;
  String get messageGroupButton => _values['messageGroupButton']!;
  String get addMembersButton => _values['addMembersButton']!;
  String get noContactsInGroupYet => _values['noContactsInGroupYet']!;
}
