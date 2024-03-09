import 'dart:convert';
import 'dart:io';
import 'package:callup247/src/home/pages/serviceprovider_homepage.dart';
import 'package:callup247/src/profile/widgets/socialmedia_links_entry.dart';
import 'package:callup247/src/responsive_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../main.dart';
import 'package:http/http.dart' as http;

class ServiceProviderProfileCreation extends StatefulWidget {
  const ServiceProviderProfileCreation({super.key});

  @override
  State<ServiceProviderProfileCreation> createState() =>
      _ServiceProviderProfileCreationState();
}

class _ServiceProviderProfileCreationState
    extends State<ServiceProviderProfileCreation> {
  // services list

  List<String> servicesList = [
    'Accountant - Management',
    'Accountant - Private Practice',
    'Accountant - Public Sector',
    'Accounting Technician',
    'Accounts Assistant',
    'Actor',
    'Actuary',
    'Acupuncturist',
    'Administrative Assistant or Officer - Courts',
    'Advertising Account Executive',
    'Advertising Account Planner',
    'Advertising Copywriter',
    'Advice Worker',
    'Advocate',
    'Advocates\' Clerk',
    'Aerospace Engineer',
    'Agricultural Consultant',
    'Agricultural Scientist',
    'Air Cabin Crew',
    'Air Conditioning Engineer',
    'Air Quality Consultant',
    'Air Traffic Controller',
    'Aircraft Maintenance Technician',
    'Airline or Airport Passenger Service Assistant',
    'Ambulance Care Assistant',
    'Ambulance Technician',
    'Anatomical Pathology Technologist',
    'Animal Care Assistant',
    'Animal Technician',
    'Animator',
    'Applications Developer ',
    'Arborist',
    'Archaeologist',
    'Architect',
    'Architectural Technologist',
    'Archivist',
    'Army – Officer',
    'Army – Soldier',
    'Aromatherapist',
    'Art Therapist',
    'Arts Administrator',
    'Assembler - Electronics',
    'Assistance Dog Trainer',
    'Astronomer or Astrophysicist',
    'Auctioneer',
    'Audiologist',
    'Author',
    'Automotive Engineer',
    'Baker or Confectioner',
    'Bank or Building Society Customer Adviser',
    'Bank or Building Society Manager',
    'Bar Worker',
    'Barber',
    'Beauty Therapist',
    'BIM Technician',
    'Biochemist',
    'Biologist',
    'Biomedical Scientist',
    'Biotechnologist',
    'Blacksmith',
    'Boat or Ship Builder',
    'Body Piercer',
    'Bookbinder',
    'Border Force Officer or Assistant Officer',
    'Botanist',
    'Brewery Worker',
    'Bricklayer',
    'British Sign Language Interpreter',
    'Broadcast Assistant',
    'Broadcast Engineer',
    'Broadcast Journalist',
    'Builders\' Merchant',
    'Building Services Engineer',
    'Building Standards Surveyor',
    'Building Technician',
    'Bus or Coach Driver',
    'Butcher ',
    'Cabinet Maker',
    'CAD Technician',
    'Call Centre Agent',
    'Camera Operator',
    'Car Valet',
    'Cardiac Physiologist',
    'Care Assistant or Support Worker',
    'Care Home Manager',
    'Careers Adviser',
    'Cartographer',
    'Casino Dealer',
    'Catering Manager',
    'CCTV Operator',
    'Ceiling Fixer',
    'Cemetery Worker',
    'Ceramic Designer',
    'Character Artist',
    'Charity Fundraiser',
    'Chef or Cook',
    'Chemical Engineer',
    'Chemical Engineering Technician',
    'Chemical Plant Process Operative',
    'Chemist',
    'Childminder',
    'Children’s Holiday Representative',
    'Chiropractor',
    'Choreographer',
    'Cinema or Theatre Assistant',
    'Cinema or Theatre Manager',
    'Civil Engineer',
    'Civil Engineering Technician',
    'Civil Service Administrative Assistant and Officer',
    'Civil Service Administrator - Fast Stream',
    'Classroom Assistant - Primary or Early Years',
    'Cleaner',
    'Clerical or Administrative Assistant',
    'Clerk of Court',
    'Clerk of Works',
    'Clinical or Biomedical Engineer',
    'Clinical Perfusionist',
    'Clinical Photographer',
    'Clinical Technologist',
    'Cloud Engineer',
    'CNC Machinist',
    'Coastguard',
    'Commissioning Editor',
    'Community Arts Worker',
    'Community Learning and Development Officer',
    'Community Warden',
    'Community Waste Officer',
    'Company Secretary',
    'Composer or Songwriter',
    'Conference Producer',
    'Construction Manager or Site Manager',
    'Construction Plant Mechanic',
    'Control and Instrument Engineer',
    'Copy Editor',
    'Costume Designer',
    'Counsellor',
    'Countryside Ranger or Warden',
    'Craft Designer',
    'Credit Manager',
    'Crematorium Technician',
    'Crime Scene Examiner',
    'Customer Service Administrator',
    'Cyber Security Analyst',
    'Cycle Mechanic',
    'Dance Movement Psychotherapist',
    'Dance Teacher',
    'Dancer',
    'Data Analyst',
    'Data Scientist',
    'Database Administrator',
    'Decontamination Technician',
    'Delivery Driver',
    'Demolition Operative',
    'Dental Hygienist or Therapist',
    'Dental Nurse',
    'Dental Technician',
    'Dentist',
    'Derrickhand',
    'Design Engineer',
    'Dietetic Support Worker',
    'Dietitian',
    'Digital Content Editor',
    'Digital Marketer',
    'Diplomatic Service Operational Officer',
    'Disc Jockey – DJ',
    'Dispensing Optician',
    'Distillery Worker',
    'Diver',
    'Doctor – GP',
    'Doctor – Hospital',
    'Document Controller',
    'Dog Groomer',
    'Dog Handler',
    'Dramatherapist',
    'Driller',
    'Drilling Engineer',
    'Driving Examiner',
    'Driving Instructor',
    'Drone Pilot',
    'Dryliner',
    'Dynamic Positioning Operator',
    'Early Years Practitioner',
    'Economic Development Officer',
    'Economist',
    'Electrical Engineer',
    'Electrical or Electronic Engineering Technician',
    'Electrician',
    'Electricity Distribution Worker',
    'Electronics Engineer',
    'Embalmer',
    'Emergency Call Handler',
    'Engineering Operative',
    'Environmental Consultant',
    'Environmental Health Officer',
    'Environmental Manager',
    'Ergonomist',
    'Estate Agent',
    'Estate or Land Manager',
    'Estimator',
    'Events Manager',
    'Exhibition Designer',
    'Export Sales Manager',
    'Fabric Cutter',
    'Fabricator or Plater',
    'Facilities Manager',
    'Farm Manager',
    'Farm Worker or Stockperson',
    'Farrier',
    'Fashion Designer',
    'Fashion Model',
    'Field Service Technician',
    'Film or Video Editor',
    'Financial Adviser',
    'Fine Artist',
    'Firefighter',
    'Fish Farm Manager',
    'Fish Farm Worker',
    'Fishing Vessel Worker',
    'Fitness Instructor ',
    'Flight Dispatcher',
    'Floor Layer or Carpet Fitter',
    'Floor Manager – Television',
    'Florist',
    'Food Scientist or Technologist',
    'Forensic Computer Analyst',
    'Forensic Scientist',
    'Forest or Wildlife Manager',
    'Forest or Wildlife Ranger',
    'Forest Worker',
    'Forklift Truck Operator',
    'Formworker',
    'Freight Forwarder',
    'Front End Developer',
    'Fundraising Manager',
    'Funeral Director',
    'Furniture Designer',
    'Gamekeeper',
    'Games Designer',
    'Games Programmer',
    'Games Tester',
    'Garden Centre Worker',
    'Gardener',
    'Garment or Textile Technologist',
    'Gas Heating Engineer',
    'Gas Service Engineer',
    'General Construction Operative',
    'Geneticist',
    'Geologist',
    'Geophysicist',
    'Glass Designer or Maker',
    'Glazier',
    'Glazing Technician',
    'Government Intelligence Officer or Analyst',
    'Graphic Designer',
    'Groundsperson',
    'Gym Instructor',
    'Hair Stylist',
    'Health and Safety Inspector',
    'Health and Safety Officer',
    'Health Improvement Officer',
    'Health Records Staff',
    'Health Service Manager',
    'Health Visitor or Public Health Nurse',
    'Heating and Ventilation Engineer',
    'Herbalist',
    'Holiday Centre Worker',
    'Home Media Engineer',
    'Homeopath',
    'Horticultural Scientist',
    'Hospital Porter',
    'Hotel General Manager',
    'Hotel Porter',
    'Hotel Receptionist',
    'Housekeeping Manager',
    'Housing Officer',
    'Human Resources Officer or Manager',
    'Hypnotherapist',
    'Illustrator',
    'Immigration Enforcement Officer ',
    'Insurance Account Manager',
    'Insurance Broker',
    'Insurance Claims Handler',
    'Insurance Loss Adjuster',
    'Insurance Risk Surveyor',
    'Insurance Underwriter',
    'Interior Designer',
    'Interpreter',
    'Investment Analyst',
    'Investment Banker',
    'Investment Operations Administrator',
    'IT Helpdesk Analyst',
    'IT Support Engineer',
    'Jeweller - Retail',
    'Jewellery Designer',
    'Joiner or Carpenter',
    'Journalist or Reporter',
    'Judge or Sheriff',
    'Kitchen Assistant',
    'Laboratory Technician',
    'Landbased Service Engineer',
    'Landscape Architect',
    'Landscaper',
    'Learning Support Assistant',
    'Lecturer - Further Education',
    'Lecturer - Higher Education',
    'Legal Secretary',
    'Librarian or Information Professional',
    'Library or Information Assistant',
    'Lifeguard',
    'Lighting Technician',
    'Lightning Protection Engineer',
    'Literary Agent',
    'Local Government Administrative Assistant or Officer',
    'Local Government Officer',
    'Locksmith',
    'Loft and Cavity Insulation Technician',
    'Logistics Manager',
    'Lorry or LGV Driver',
    'Machine Printer',
    'Make-up Artist',
    'Management Consultant',
    'Manufacturing Systems Engineer',
    'Marine Biologist',
    'Marine Engineer',
    'Market Research Executive',
    'Market Research Interviewer',
    'Marketing Manager',
    'Mastic Asphalter',
    'Materials Scientist or Engineer',
    'Maternity Support Worker',
    'Mathematician',
    'Meat Process Worker',
    'Mechanical Engineer',
    'Mechanical Engineering Technician',
    'Medical Pathologist',
    'Medical Physicist',
    'Medical Representative',
    'Medical Secretary',
    'Member of Parliament',
    'Merchant Navy Deck Officer',
    'Merchant Navy Engineering Officer',
    'Merchant Navy Rating',
    'Meteorologist',
    'Meter Reader',
    'Microbiologist',
    'Midwife',
    'Mining Engineer',
    'Model',
    'Motor Vehicle Technician',
    'Motorcycle Instructor',
    'Motorcycle Technician',
    'Mudlogger',
    'Museum Assistant or Visitor Assistant',
    'Museum Conservation Officer',
    'Museum or Art Gallery Curator',
    'Music Promotions Manager',
    'Music Therapist',
    'Musical Instrument Technologist',
    'Musician - Classical',
    'Musician - Popular',
    'Nail Technician',
    'Nanny',
    'Nanotechnologist',
    'Nature Conservationist',
    'Naturopath',
    'Naval Architect',
    'Network Architect',
    'Network Engineer',
    'Neurophysiologist',
    'Nuclear Engineer',
    'Nurse - Adult',
    'Nurse - Child',
    'Nurse - District',
    'Nurse - General Practice',
    'Nurse - Learning Disabilities',
    'Nurse - Mental Health',
    'Nursing Support Worker',
    'Occupational Therapist',
    'Occupational Therapy Support Worker',
    'Oceanographer',
    'Office Manager',
    'Offshore Medic',
    'Offshore Service Technician',
    'Operating Department Practitioner',
    'Operational Researcher',
    'Optical Assistant',
    'Optical Technician',
    'Optometrist',
    'Orthodontist',
    'Orthoptist',
    'Osteopath',
    'Outdoor Activities Instructor or Leader',
    'Painter and Decorator',
    'Paralegal',
    'Paramedic',
    'Parking Warden',
    'Parliamentary Assistant',
    'Patent Attorney',
    'Patent Examiner',
    'Pattern Cutter or Grader',
    'Personal Assistant',
    'Personal Trainer',
    'Pest Control Technician',
    'Pet Shop Assistant',
    'Petroleum or Reservoir Engineer',
    'Pharmacist',
    'Pharmacologist',
    'Pharmacy Support Worker',
    'Pharmacy Technician',
    'Phlebotomist',
    'Photographer',
    'Photographic Stylist',
    'Physicist',
    'Physiotherapist',
    'Physiotherapy Support Worker',
    'Piano Tuner',
    'Picture Framer',
    'Picture Researcher',
    'Pilot - Airline',
    'Pilot - Helicopter',
    'Plant Operator',
    'Plasterer',
    'Play Therapist',
    'Playworker or Play Leader',
    'Plumber',
    'Podiatrist',
    'Podiatry Support Worker',
    'Police Officer',
    'Pool Attendant',
    'Port Operative',
    'Post Office Customer Service Consultant',
    'Postie',
    'Pre-press Operator',
    'Previsualisation Artist',
    'Print Finisher',
    'Print Production Planner',
    'Prison Officer',
    'Private Tutor',
    'Procurator Fiscal',
    'Procurement Administrator',
    'Procurement Manager',
    'Producer – Radio',
    'Producer – TV or Film',
    'Product Designer',
    'Production Assistant',
    'Production Controller or Manager',
    'Production Worker',
    'Project Manager',
    'Prop Master',
    'Prosthetic or Orthotic Support Worker',
    'Prosthetist or Orthotist',
    'Psychologist',
    'Psychologist - Clinical',
    'Psychologist - Counselling',
    'Psychologist - Educational',
    'Psychologist - Forensic',
    'Psychologist - Health',
    'Psychologist - Occupational',
    'Psychologist - Sport and Exercise',
    'Psychotherapist',
    'Public Relations Officer',
    'Quality Control Technician',
    'Radiographer - Diagnostic',
    'Radiographer - Therapeutic',
    'Radiography Support Worker',
    'Railway Maintenance Engineering Technician - Distribution and Plant',
    'Railway Maintenance Engineering Technician - Overhead Line',
    'Railway Maintenance Engineering Technician - Signalling',
    'Railway Maintenance Engineering Technician - Telecoms',
    'Railway Maintenance Engineering Technician - Track',
    'Railway Station Assistant',
    'Ramp Agent',
    'Receptionist',
    'Recruitment Consultant',
    'Recycling Operative',
    'Reflexologist',
    'Refrigeration Engineer',
    'Refuse Collector',
    'Registrar of Births, Deaths, Marriages and Civil Partnerships',
    'Rehabilitation Engineering Technician',
    'Removals Operative',
    'Renewable Energy Consultant',
    'Renewable Energy Engineer',
    'Reprographic Assistant',
    'Resort Representative',
    'Respiratory Physiologist',
    'Restaurant Manager',
    'Retail Assistant',
    'Retail Buyer',
    'Retail Manager',
    'Revenue and Customs Officer',
    'Riding Instructor',
    'Risk Manager',
    'Road Worker',
    'Roadie',
    'Roof Sheeter and Cladder',
    'Roofer',
    'Roofer – Felt',
    'Room Attendant',
    'Roustabout',
    'ROV Pilot Technician',
    'Royal Air Force Airman or Airwoman',
    'Royal Air Force Officer',
    'Royal Marine',
    'Royal Marines Officer',
    'Royal Navy Officer',
    'Royal Navy Rating',
    'Runner',
    'Sales Representative',
    'Scaffolder',
    'Scenic Artist',
    'School Janitor',
    'Scientific or Technical Illustrator',
    'Scottish SPCA Animal Rescue Officer',
    'Scottish SPCA Inspector',
    'Sculptor',
    'Security Officer or Guard',
    'Security Systems Installer',
    'SEO Specialist',
    'Server',
    'Set Designer',
    'Sewing Machinist',
    'Sheet Metal Worker',
    'Sheriff Officer or Messenger-at-Arms',
    'Shoe Repairer',
    'Shopfitter',
    'Signaller',
    'Signwriter',
    'Smart Meter Engineer',
    'Social Worker',
    'Software Engineer or Developer',
    'Software Tester',
    'Solicitor',
    'Sound Technician',
    'Special Effects Technician',
    'Speech and Language Therapist',
    'Speech and Language Therapy Support Worker',
    'Sport and Exercise Scientist',
    'Sports Coach or Instructor',
    'Sports Development Officer',
    'Sports or Leisure Centre Assistant',
    'Sports or Leisure Centre Manager',
    'Sports Professional',
    'Sports Therapist',
    'Stablehand or Groom',
    'Stage Manager',
    'Stagehand',
    'Statistician',
    'Steeplejack',
    'Stockbroker',
    'Stonemason',
    'Store Detective',
    'Storyboard Artist',
    'Street Cleaning Operative',
    'Structural Engineer',
    'Structural Engineering Technician',
    'Stunt Performer',
    'Sub-editor — Journalism',
    'Subsea Engineer',
    'Supermarket Assistant',
    'Surgeon',
    'Surveyor',
    'Surveyor - Building',
    'Surveyor - Hydrographic',
    'Surveyor - Land or Geomatics',
    'Surveyor - Minerals or Waste Management',
    'Surveyor - Planning and Development',
    'Surveyor - Quantity',
    'Surveyor - Rural Practice',
    'Surveyor - Valuation',
    'Swimming Teacher',
    'Systems Analyst',
    'Tailor or Dressmaker',
    'Tax Officer',
    'Taxi or Car Driver',
    'Teacher - Additional Support for Learning',
    'Teacher - Primary or Early Years',
    'Teacher - Secondary School',
    'Teacher - Secondary School - Art and Design',
    'Teacher - Secondary School - Biology with Science',
    'Teacher - Secondary School - Business Education',
    'Teacher - Secondary School - Chemistry with Science',
    'Teacher - Secondary School - Computing',
    'Teacher - Secondary School - Design and Technology/Technological Education',
    'Teacher - Secondary School - Drama',
    'Teacher - Secondary School - English',
    'Teacher - Secondary School - Gaelic',
    'Teacher - Secondary School - Geography',
    'Teacher - Secondary School - History',
    'Teacher - Secondary School - Home Economics',
    'Teacher - Secondary School - Mathematics',
    'Teacher - Secondary School - Modern Foreign Languages',
    'Teacher - Secondary School - Modern Studies',
    'Teacher - Secondary School - Music',
    'Teacher - Secondary School - Physical Education',
    'Teacher - Secondary School - Physics with Science',
    'Teacher - Secondary School - Religious Education',
    'Teacher of English as a Foreign Language',
    'Technical Author',
    'Technical Brewer',
    'Technical Distiller',
    'Technical Surveyor',
    'Telecommunications Engineer',
    'Textile Designer',
    'Textile Operative',
    'Theatre Support Worker',
    'Thermal Insulation Engineer',
    'Toolmaker',
    'Toolpusher',
    'Tour Guide',
    'Tour Leader or Manager',
    'Town Planner',
    'Trade Union Official',
    'Trading Standards Officer',
    'Train Conductor',
    'Train Driver',
    'Train Maintenance Technician',
    'Training Officer or Manager',
    'Translator',
    'Travel Agency Manager',
    'Travel Consultant',
    'TV or Film Director',
    'TV or Radio Presenter',
    'Tyre or Exhaust Fitter',
    'Upholsterer',
    'User Experience (UX) Designer',
    'Vehicle Body Repairer',
    'Vehicle Breakdown Engineer',
    'Vehicle Examiner',
    'Vehicle MET Technician',
    'Vehicle Parts Advisor',
    'Vehicle Salesperson',
    'Vehicle Spray Painter',
    'Veterinary Nurse',
    'Veterinary Surgeon',
    'Virtual Assistant',
    'Visitor Attraction Manager',
    'Visitor Services Adviser',
    'Visual Merchandiser',
    'Wall and Floor Tiler',
    'Warden or Housing Support Officer - Sheltered Housing',
    'Wardrobe Assistant - Film, TV or Theatre',
    'Warehouse Operative',
    'Waste Energy Engineer',
    'Watch and Clock Repairer',
    'Water or Waste Water Network Operative',
    'Water or Waste Water Treatment Operative',
    'Waterway Operative',
    'Web Designer',
    'Web Developer',
    'Welder',
    'Wind Turbine Technician',
    'Window Fitter',
    'Wood Machinist',
    'Writer',
    'Yoga Teacher',
    'Youth Worker',
    'Zookeeper',
    'Zoologist',
  ];
  // end of list of services

  // 01 - use case become a service provider

  Future<void> _becomeAServiceProvider() async {
    try {
      await supabase.from('profiles').update(
          {'service_provider': 'TRUE'}).match({'service_provider': 'FALSE'});
      if (mounted) {}
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    } finally {
      if (mounted) {}
    }

    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);

      userProfileMap['service_provider'] = 'TRUE';

      final updatedUserProfileJson = json.encode(userProfileMap);

      await prefs.setString('userprofile', updatedUserProfileJson);
    } else {}
  }

  // 02 - use case pick image1

  // Future<void> _pickImage1() async {
  //   final ImagePicker picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image1 = File(pickedFile.path);
  //     });
  //   }
  // }

  // 02A - use case pick image2

  // Future<void> _pickImage2() async {
  //   final ImagePicker picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image2 = File(pickedFile.path);
  //     });
  //   }
  // }

  // 02B - use case pick image3

  // Future<void> _pickImage3() async {
  //   final ImagePicker picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image3 = File(pickedFile.path);
  //     });
  //   }
  // }

  // 03 - use case check network

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 04 - use case submit logic

  Future<void> _performSubmit() async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      // if (_image1 != null) {
      //   await _uploadImage1();
      // }
      // if (_image2 != null) {
      //   await _uploadImage2();
      // }
      // if (_image3 != null) {
      //   await _uploadImage3();
      // }

      await _becomeAServiceProvider();
      await _createServiceProviderProfile();
      await _saveServiceProviderProfilelocally();
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'An error occurred. Please try again later.',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

// variables

  final searchFocusNode = FocusNode();
  final TextEditingController _serviceProvidedController =
      TextEditingController();
  List<String> filteredServices = []; // Initialize it as an empty list
  String searchchoice = '';
  // File? _image1;
  // File? _image2;
  // File? _image3;
  bool isTyping = false; // Initially, the user is not typing
  bool isSearching = false; // Initially the user is not searching
  // final TextEditingController _instagramController = TextEditingController();
  // final TextEditingController _linkedinController = TextEditingController();
  // final TextEditingController _xController = TextEditingController();
  // final TextEditingController _facebookController = TextEditingController();
  // final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  // final TextEditingController _experienceController = TextEditingController();
  // final TextEditingController _availabilityController = TextEditingController();
  // final TextEditingController _specialOffersController =
  //     TextEditingController();
  String emailaddress = '';
  String fullname = '';
  var loading = false;
  double latitude = 0.0;
  double longitude = 0.0;
  List<SocialMediaLink> socialMediaLinks = [];
  File? _image;

  // dispose

  @override
  void dispose() {
    // _instagramController.dispose();
    // _xController.dispose();
    // _linkedinController.dispose();
    // _facebookController.dispose();
    // _websiteController.dispose();
    _gmailController.dispose();
    _bioController.dispose();
    // _experienceController.dispose();
    // _availabilityController.dispose();
    // _specialOffersController.dispose();
    super.dispose();
  }

  // 05 - use case upload image1

  // Future<void> _uploadImage1() async {
  //   try {
  //     await supabase.storage.from('media1').upload(
  //           fullname,
  //           _image1!,
  //           fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
  //         );
  //     if (mounted) {}
  //   } on PostgrestException catch (error) {
  //     //
  //   } catch (error) {
  //     //
  //   }
  // }

  // 05B - use case upload image2

  // Future<void> _uploadImage2() async {
  //   try {
  //     await supabase.storage.from('media2').upload(
  //           fullname,
  //           _image2!,
  //           fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
  //         );
  //     if (mounted) {}
  //   } on PostgrestException catch (error) {
  //     //
  //   } catch (error) {
  //     //
  //   }
  // }

  // 05C - use case upload image3

  // Future<void> _uploadImage3() async {
  //   try {
  //     await supabase.storage.from('media3').upload(
  //           fullname,
  //           _image3!,
  //           fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
  //         );
  //     if (mounted) {}
  //   } on PostgrestException catch (error) {
  //     //
  //   } catch (error) {
  //     //
  //   }
  // }

  // init

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // 06 - use case initialize data

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    final serviceProvider = prefs.getString('serviceproviderprofile');
    final userLatitude = prefs.getDouble('userLatitude');
    final userLongitude = prefs.getDouble('userLongitude');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);
      // To access specific fields like full name and email address:
      final userEmailAddress = userProfileMap['email'];
      final fullName = userProfileMap['fullname'];
      setState(() {
        emailaddress = userEmailAddress;
        fullname = fullName;
      });
      // You can now use `emailaddress` as needed.
    } else {
      // Handle the case where no user profile data is found in SharedPreferences.
      // For example, show a snackbar.
    }

    if (serviceProvider != null) {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => const ServiceProviderHomePage()),
      );
    }

    if (userLongitude != null && userLatitude != null) {
      setState(() {
        latitude = userLatitude;
        longitude = userLongitude;
      });
    } else {
      // do something to make the code tighter
    }
  }

  // 07 - create service provider profile

  Future<void> _createServiceProviderProfile() async {
    final serviceprovided = _serviceProvidedController.text.trim();
    final media1 = supabase.storage.from('media1').getPublicUrl(fullname);
    final media2 = supabase.storage.from('media2').getPublicUrl(fullname);
    final media3 = supabase.storage.from('media3').getPublicUrl(fullname);
    // final ig = _instagramController.text.trim();
    // final x = _xController.text.trim();
    // final linkedin = _linkedinController.text.trim();
    // final fb = _facebookController.text.trim();
    // final web = _websiteController.text.trim();
    final gmail = emailaddress;
    final bio = _bioController.text.trim();
    // final experience = _experienceController.text.trim();
    // final availability = _availabilityController.text.trim();
    // final specialoffers = _specialOffersController.text.trim();

    final user = supabase.auth.currentUser;

    final details = {
      'id': user!.id,
      'created_at': DateTime.now().toIso8601String(),
      'service_provided': serviceprovided,
      'media_url1': media1,
      'media_url2': media2,
      'media_url3': media3,
      // 'ig_url': ig,
      // 'x_url': x,
      // 'linkedin_url': linkedin,
      // 'fb_url': fb,
      // 'web_link': web,
      'gmail_link': gmail,
      'bio': bio,
      // 'experience': experience,
      // 'availability': availability,
      // 'special_offers': specialoffers,
      'latitude': latitude,
      'longitude': longitude
    };

    try {
      await supabase.from('serviceproviders_profile').insert(details);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Happy Service Providing!!',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
      }
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loading = false;
      });
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      setState(() {
        loading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // 08 - use save service provider profile locally

  Future<void> _saveServiceProviderProfilelocally() async {
    final serviceprovided = _serviceProvidedController.text.trim();
    final media1 = supabase.storage.from('media1').getPublicUrl(fullname);
    final media2 = supabase.storage.from('media2').getPublicUrl(fullname);
    final media3 = supabase.storage.from('media3').getPublicUrl(fullname);
    // final ig = _instagramController.text.trim();
    // final x = _xController.text.trim();
    // final linkedin = _linkedinController.text.trim();
    // final fb = _facebookController.text.trim();
    // final web = _websiteController.text.trim();
    final gmail = emailaddress;
    final bio = _bioController.text.trim();
    // final experience = _experienceController.text.trim();
    // final availability = _availabilityController.text.trim();
    // final specialoffers = _specialOffersController.text.trim();

    final details = {
      'service_provided': serviceprovided,
      'media_url1': media1,
      'media_url2': media2,
      'media_url3': media3,
      // 'ig_url': ig,
      // 'x_url': x,
      // 'linkedin_url': linkedin,
      // 'fb_url': fb,
      // 'web_link': web,
      'gmail_link': gmail,
      'bio': bio,
      // 'experience': experience,
      // 'availability': availability,
      // 'special_offers': specialoffers,
    };

    final jsonString = json.encode(details);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('serviceproviderprofile', jsonString);
  }

  void _addLinkOG(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            'Select Social Media Platform',
            style: responsiveTextStyle(
                context, 14, const Color(0xFF000000), FontWeight.w500),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildSocialMediaButton('LinkedIn', 'assets/linkedin-icon.png'),
                _buildSocialMediaButton('Instagram', 'assets/ig-icon.png'),
                _buildSocialMediaButton('X', 'assets/x-icon.webp'),
                _buildSocialMediaButton('Facebook', 'assets/facebook.png'),
                _buildSocialMediaButton('Website', 'assets/web-icon.png'),
                // Add more social media options as needed
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialMediaButton(String platform, String icon) {
    return TextButton(
      onPressed: () {
        // Close the dialog and display text field for the selected platform
        Navigator.of(context).pop();
        _showTextFieldForPlatform(platform);
      },
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 20,
          ),
          const SizedBox(width: 8),
          Text(
            platform,
            style: responsiveTextStyle(
                context, 12, const Color(0xFF6F6C6C), FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showTextFieldForPlatform(String platform) {
    String link = '';
    String nav = '';
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Text(
                'Add Link for $platform',
                style: responsiveTextStyle(
                    context, 14, const Color(0xFF000000), FontWeight.w500),
              ),
              IconButton(
                onPressed: () async {
                  if (platform == 'LinkedIn') {
                    nav = 'https://www.linkedin.com/';
                  } else if (platform == 'Instagram') {
                    nav = 'https://www.instagram.com/';
                  } else if (platform == 'X') {
                    nav = 'https://twitter.com/';
                  } else if (platform == 'Facebook') {
                    nav = 'https://web.facebook.com/?_rdc=1&_rdr';
                  } else {
                    nav = 'https://www.google.com/';
                  }
                  final Uri url = Uri.parse(nav);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {}
                },
                icon: const Icon(
                  Icons.open_in_new,
                  color: Color(0xFF000000),
                ),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  style: responsiveTextStyle(
                      context, 16, const Color(0xFFA6A6A6), FontWeight.w500),
                  onChanged: (value) {
                    link = value; // Update the link as the user types
                  },
                  decoration: InputDecoration(
                      hintText: 'Enter link',
                      hintStyle: responsiveTextStyle(context, 14,
                          const Color(0xFFA6A6A6), FontWeight.w500)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF36DDFF)),
                  onPressed: () {
                    _addLink(context, platform,
                        link); // Add the link when the user clicks the button
                  },
                  child: Text('Add Link',
                      style: responsiveTextStyle(context, 14,
                          const Color(0xFF000000), FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeLink(String platform) {
    setState(() {
      socialMediaLinks.removeWhere((link) => link.platform == platform);
    });
  }

  void _addLink(BuildContext context, String platform, String link) {
    Navigator.of(context).pop(); // Close the dialog
    setState(() {
      socialMediaLinks.add(SocialMediaLink(platform: platform, link: link));
    });
  }

  // 01 - use case pick image

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 02 - use case upload image

  Future<void> _uploadImage() async {
    // final filename = _fullnameController.text.trim();
    const filename = '';
    try {
      await supabase.storage.from('avatars').upload(
            filename,
            _image!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      if (mounted) {}
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    }
  }

  // todo: update image on supabase

// todo: update image locally

// build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Set up your Profile',
              style: responsiveTextStyle(
                  context, 20, Colors.black, FontWeight.bold),
            ),
            Text(
              'Don\'t worry you can always change it later',
              style: responsiveTextStyle(
                  context, 10, const Color(0xFF373737), FontWeight.w500),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFB3F2FF),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: [
                              _image != null
                                  ? CircleAvatar(
                                      backgroundImage: FileImage(_image!),
                                      radius: 45,
                                    )
                                  : const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/guest_dp.png'),
                                      radius: 45,
                                    ),
                              Positioned(
                                bottom: 8,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.black.withOpacity(
                                        0.6), // Dark background color
                                  ),
                                  padding: const EdgeInsets.all(
                                      3), // Adjust padding as needed
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.15,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFB3F2FF),
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Text(
                              'Full Name',
                              style: responsiveTextStyle(context, 14,
                                  const Color(0xFF000000), FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(
                                  Icons.mail_outline_outlined,
                                  size: 16,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  'Email',
                                  style: responsiveTextStyle(context, 12,
                                      const Color(0xFF000000), FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),

                // add service

                Text(
                  'Applicable Title',
                  style: responsiveTextStyle(
                      context, 16, Colors.black, FontWeight.w600),
                ),

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _serviceProvidedController,
                        focusNode: searchFocusNode,
                        showCursor: false,
                        style: responsiveTextStyle(context, 16,
                            const Color(0xFFA6A6A6), FontWeight.bold),
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color(0xFFE2E2E5), width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black54,
                          ),
                          suffixIcon: InkWell(
                              radius: 50,
                              splashColor: Colors.greenAccent,
                              onTap: () {
                                print(socialMediaLinks);
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  isSearching = false;
                                  // When suffix icon is tapped, set isTyping to false
                                  isTyping = false;
                                  // You can also clear the text field if needed
                                  _serviceProvidedController.clear();
                                  // Update the filtered services here as well
                                  filteredServices = [];
                                });
                              },
                              child: const Icon(
                                Icons.cancel,
                                color: Colors.black54,
                              )),
                          hintText: 'Start typing to search...',
                        ),
                        onChanged: (value) {
                          setState(() {
                            // Filter services here and update UI.
                            filteredServices = servicesList
                                .where((service) => service
                                    .toLowerCase()
                                    .startsWith(value.toLowerCase()))
                                .toList();
                            if (value.isNotEmpty) {
                              isTyping =
                                  true; // User is typing, hide the content above
                            } else {
                              isTyping =
                                  false; // User has stopped typing, show the content above
                            }
                            isSearching = false;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                Visibility(
                  visible: isTyping, // Content is visible when typing
                  child: Container(
                    color: Colors.white,
                    height: MediaQuery.sizeOf(context).height * 0.7,
                    child: filteredServices.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Sorry, we don't have this service currently. Please pick a registered service.\nhint: try a different name for the service e.g author, writer or journalist, reporter",
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredServices.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  filteredServices[index],
                                  style: responsiveTextStyle(context, 16,
                                      Colors.black, FontWeight.bold),
                                ),
                                onTap: () {
                                  // Handle user selection here.
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    isSearching = true;
                                    // When tile is tapped, set isTyping to false
                                    isTyping = false;
                                    searchchoice = filteredServices[index];
                                    _serviceProvidedController.text =
                                        filteredServices[index];

                                    // Update the filtered services here as well
                                    filteredServices = [];
                                  });
                                },
                              );
                            },
                          ),
                  ),
                ),

// bio

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                Text(
                  'Bio',
                  style: responsiveTextStyle(
                      context, 14, Colors.black, FontWeight.w600),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.008),
                TextField(
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  controller: _bioController,
                  cursorColor: const Color(0xFFA6A6A6),
                  keyboardType: TextInputType.multiline,
                  style: responsiveTextStyle(
                      context, 16, const Color(0xFFA6A6A6), FontWeight.w500),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFFE2E2E5), width: 2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFFE2E2E5), width: 2),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),

//  social media

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                Text(
                  'Social Media',
                  style: responsiveTextStyle(
                      context, 14, Colors.black, FontWeight.w600),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.008),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: socialMediaLinks.map((link) {
                    return SocialMediaLinkEntry(
                      platform: link.platform,
                      link: link.link,
                      onDelete: _removeLink,
                    );
                  }).toList(),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.008),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: const Color(0xFFE2E2E5))),
                  child: Center(
                    child: TextButton.icon(
                        onPressed: () => _addLinkOG(context),
                        icon: const Icon(
                          Icons.add,
                          color: Color(0xFF625B5B),
                        ),
                        label: Text(
                          'Add Link',
                          style: responsiveTextStyle(context, 12,
                              const Color(0xFF625B5B), FontWeight.w500),
                        )),
                  ),
                ),

                // add media

                // Text(
                //   'Add Media :',
                //   style: responsiveTextStyle(context, 20, Colors.black, null),
                // ),
                // Text(
                //   'hint: you can add up to three images that showcase your work :)',
                //   style: responsiveTextStyle(context, 12, Colors.black45, null),
                // ),
                // SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       // image 1
                //       Container(
                //         color: Colors.black45,
                //         height: 250,
                //         width: 250,
                //         child: GestureDetector(
                //           onTap: () {
                //             _pickImage1();
                //           },
                //           child: Column(
                //             children: <Widget>[
                //               if (_image1 != null)
                //                 Image.file(
                //                   _image1!,
                //                   height: 250,
                //                   width: 250,
                //                   fit: BoxFit.cover,
                //                 )
                //               else
                //                 const Icon(
                //                   Icons.camera_alt,
                //                   size: 250,
                //                 ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       SizedBox(width: MediaQuery.sizeOf(context).width * 0.025),
                //       // image 2
                //       Container(
                //         color: Colors.black45,
                //         height: 250,
                //         width: 250,
                //         child: GestureDetector(
                //           onTap: () {
                //             _pickImage2();
                //           },
                //           child: Column(
                //             children: <Widget>[
                //               if (_image2 != null)
                //                 Image.file(
                //                   _image2!,
                //                   height: 250,
                //                   width: 250,
                //                   fit: BoxFit.cover,
                //                 )
                //               else
                //                 const Icon(
                //                   Icons.camera_alt,
                //                   size: 250,
                //                 ),
                //             ],
                //           ),
                //         ),
                //       ),
                //       SizedBox(width: MediaQuery.sizeOf(context).width * 0.025),
                //       // image 3
                //       Container(
                //         color: Colors.black45,
                //         height: 250,
                //         width: 250,
                //         child: GestureDetector(
                //           onTap: () {
                //             _pickImage3();
                //           },
                //           child: Column(
                //             children: <Widget>[
                //               if (_image3 != null)
                //                 Image.file(
                //                   _image3!,
                //                   height: 250,
                //                   width: 250,
                //                   fit: BoxFit.cover,
                //                 )
                //               else
                //                 const Icon(
                //                   Icons.camera_alt,
                //                   size: 250,
                //                 ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),

                // Text(
                //     'hint: you can always edit your profile from your hoemepage... if you don\'t have all your details now just hit submit and provide them later :)',
                //     style:
                //         responsiveTextStyle(context, 12, Colors.black45, null)),

                // add social links

                // SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                // Text(
                //   'Add Your Social links :',
                //   style: responsiveTextStyle(context, 20, Colors.black, null),
                // ),
                // Text(
                //     'hint: click on the app icons for easy navigation to share your proile :)',
                //     style:
                //         responsiveTextStyle(context, 12, Colors.black45, null)),
                // SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                // Column(
                //   children: [
                //     Row(
                //       children: [
                //         GestureDetector(
                //           onTap: () async {
                //             final Uri url =
                //                 Uri.parse('https://www.linkedin.com/');
                //             if (await canLaunchUrl(url)) {
                //               await launchUrl(url);
                //             } else {}
                //           },
                //           child: Image.asset(
                //             'assets/linkedin-icon.png',
                //             width: 25,
                //           ),
                //         ),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Text('LinkedIn :',
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.black, null)),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Flexible(
                //           child: TextField(
                //             controller: _linkedinController,
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.white, null),
                //           ),
                //         ),
                //       ],
                //     ),
                //     Row(
                //       children: [
                //         GestureDetector(
                //           onTap: () async {
                //             final Uri url =
                //                 Uri.parse('https://www.instagram.com/');
                //             if (await canLaunchUrl(url)) {
                //               await launchUrl(url);
                //             } else {}
                //           },
                //           child: Image.asset(
                //             'assets/ig-icon.png',
                //             width: 25,
                //           ),
                //         ),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Text('Instagram :',
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.black, null)),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Flexible(
                //           child: TextField(
                //             controller: _instagramController,
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.white, null),
                //           ),
                //         ),
                //       ],
                //     ),
                //     Row(
                //       children: [
                //         GestureDetector(
                //           onTap: () async {
                //             final Uri url = Uri.parse('https://twitter.com/');
                //             if (await canLaunchUrl(url)) {
                //               await launchUrl(url);
                //             } else {}
                //           },
                //           child: Image.asset(
                //             'assets/x-icon.webp',
                //             width: 25,
                //           ),
                //         ),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Text('X :',
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.black, null)),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Flexible(
                //           child: TextField(
                //             controller: _xController,
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.white, null),
                //           ),
                //         ),
                //       ],
                //     ),
                //     Row(
                //       children: [
                //         GestureDetector(
                //           onTap: () async {
                //             final Uri url = Uri.parse(
                //                 'https://web.facebook.com/?_rdc=1&_rdr');
                //             if (await canLaunchUrl(url)) {
                //               await launchUrl(url);
                //             } else {}
                //           },
                //           child: Image.asset(
                //             'assets/facebook.png',
                //             width: 25,
                //           ),
                //         ),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Text('Facebook :',
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.black, null)),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Flexible(
                //           child: TextField(
                //             controller: _facebookController,
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.white, null),
                //           ),
                //         ),
                //       ],
                //     ),
                //     Row(
                //       children: [
                //         GestureDetector(
                //           onTap: () async {
                //             final Uri url =
                //                 Uri.parse('https://www.google.com/');
                //             if (await canLaunchUrl(url)) {
                //               await launchUrl(url);
                //             } else {}
                //           },
                //           child: Image.asset(
                //             'assets/web-icon.png',
                //             width: 25,
                //           ),
                //         ),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Text('Website :',
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.black, null)),
                //         SizedBox(
                //             width: MediaQuery.sizeOf(context).width * 0.02),
                //         Flexible(
                //           child: TextField(
                //             controller: _websiteController,
                //             style: responsiveTextStyle(
                //                 context, 16, Colors.white, null),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ],
                // ),

                // SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),

                // add details

                // Text(
                //   'Add Your Details :',
                //   style: responsiveTextStyle(context, 20, Colors.black, null),
                // ),
                // Text(
                //   'hint: you can be as expressive as you like :)',
                //   style: responsiveTextStyle(context, 12, Colors.black45, null),
                // ),
                // SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                // Row(
                //   children: [
                //     Text('Bio :',
                //         style: responsiveTextStyle(
                //             context, 16, Colors.black, null)),
                //     SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                //     Flexible(
                //       child: TextField(
                //         textCapitalization: TextCapitalization.sentences,
                //         controller: _bioController,
                //         style: responsiveTextStyle(
                //             context, 16, Colors.white, null),
                //         decoration: const InputDecoration(
                //           hintText:
                //               'E.g Experienced plumber with 5+ years of experience in fixing pipes.',
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Text('Experience :',
                //         style: responsiveTextStyle(
                //             context, 16, Colors.black, null)),
                //     SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                //     Flexible(
                //       child: TextField(
                //         controller: _experienceController,
                //         style: responsiveTextStyle(
                //             context, 16, Colors.white, null),
                //         decoration: const InputDecoration(
                //           hintText: 'E.g 5+ years',
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Text('Availability :',
                //         style: responsiveTextStyle(
                //             context, 16, Colors.black, null)),
                //     SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                //     Flexible(
                //       child: TextField(
                //         controller: _availabilityController,
                //         style: responsiveTextStyle(
                //             context, 16, Colors.white, null),
                //         decoration: const InputDecoration(
                //           hintText: 'E.g 9am - 5pm, Mon - Sat',
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Flexible(
                //       child: Text(
                //         'hint: you can let customers know if you\'re available or not by tapping available on your profile :)',
                //         style: responsiveTextStyle(
                //             context, 12, Colors.black45, null),
                //       ),
                //     ),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Text('Special Offers :',
                //         style: responsiveTextStyle(
                //             context, 16, Colors.black, null)),
                //     SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                //     Flexible(
                //       child: TextField(
                //         controller: _specialOffersController,
                //         style: responsiveTextStyle(
                //             context, 16, Colors.white, null),
                //         decoration: const InputDecoration(
                //           hintText: 'E.g 20% off till Jan 2024',
                //         ),
                //       ),
                //     ),
                //   ],
                // ),

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),

                // submit button

                Center(
                  child: loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            // prevent unregistered services
                            if (isTyping ||
                                _serviceProvidedController.text.isEmpty) {
                              messenger.showSnackBar(SnackBar(
                                content: Text(
                                  'Please pick a registered service :(',
                                  style: responsiveTextStyle(context, 16,
                                      Colors.black, FontWeight.bold),
                                ),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }
                            // Check network connectivity
                            bool isConnected =
                                await _checkInternetConnectivity();
                            if (!isConnected) {
                              if (!context.mounted) return;
                              // Show a snackbar for no network
                              messenger.showSnackBar(SnackBar(
                                content: Text(
                                  'No internet connection. Please check your network settings.',
                                  style: responsiveTextStyle(context, 16,
                                      Colors.black, FontWeight.bold),
                                ),
                                backgroundColor: Colors.red,
                              ));
                              return; // Exit the function if there's no network
                            }

                            setState(() {
                              loading = true;
                            });
                            try {
                              await _performSubmit().then((_) {
                                if (!context.mounted) return;
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const ServiceProviderHomePage()),
                                );
                              });
                            } catch (error) {
                              if (!context.mounted) return;
                              messenger.showSnackBar(SnackBar(
                                content: Text(
                                  'An error occurred. Please try again later.',
                                  style: responsiveTextStyle(context, 16,
                                      Colors.black, FontWeight.bold),
                                ),
                                backgroundColor: Colors.red,
                              ));
                            } finally {
                              setState(() {
                                loading = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF13CAF1),
                            minimumSize: Size(
                                MediaQuery.sizeOf(context).width * 0.5,
                                MediaQuery.sizeOf(context).height *
                                    0.06), // Set the button's width and height
                          ),
                          child: Text(
                            'Submit Profile',
                            style: responsiveTextStyle(
                                context, 14, Colors.white, FontWeight.bold),
                          ),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SocialMediaLink {
  final String platform;
  final String link;

  SocialMediaLink({required this.platform, required this.link});

  @override
  String toString() {
    return 'SocialMediaLink(platform: $platform, link: $link)';
  }
}
