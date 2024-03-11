import 'dart:convert';
import 'dart:io';
import 'package:callup247/main.dart';
import 'package:callup247/src/authentication/pages/user_login.dart';
import 'package:callup247/src/chat/pages/chathistory.dart';
import 'package:callup247/src/distance.dart';
import 'package:callup247/src/notification.dart';
import 'package:callup247/src/online.dart';
import 'package:callup247/src/profile/pages/serviceprovider_profile_creation_page.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/pages/view_profilepage.dart';
import '../../responsive_text_styles.dart';
import '../widgets/service_provider_card.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  // 01 - use case initialize data

  Future<void> _initializeData() async {
    _acontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Adjust the duration as needed
    )..repeat(); // This will make the animation loop
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    final userSavedSearches = prefs.getStringList('savedSearches');
    final userLatitude = prefs.getDouble('userLatitude');
    final userLongitude = prefs.getDouble('userLongitude');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);
      // To access specific fields like full name and email address:
      final userFullName = userProfileMap['fullname'];
      final userPfp = userProfileMap['displaypicture'];
      final userCity = userProfileMap['city'];
      final userState = userProfileMap['state'];
      final userCountry = userProfileMap['country'];
      setState(() {
        fullname = userFullName;
        pfp = userPfp;
        city = userCity;
        state = userState;
        country = userCountry;
      });
      // You can now use fullName and emailAddress as needed.
    } else {
      // Handle the case where no user profile data is found in SharedPreferences.
      // error in signup, please go back to signup ==> snackbar
    }
    if (userSavedSearches != null) {
      setState(() {
        savedSearches = userSavedSearches;
      });
    } else {
      try {
        final List<dynamic> response = await supabase
            .from('savedsearches')
            .select('serviceproviderid')
            .eq('userid', supabase.auth.currentUser!.id);
        if (mounted) {
          final data =
              response.map((e) => e['serviceproviderid'].toString()).toList();
          setState(() {
            savedSearches = data;
          });
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setStringList('savedSearches', data);
        }
      } on PostgrestException catch (error) {
        //
      } catch (e) {
        //
      }
    }
    if (userLongitude != null && userLatitude != null) {
      setState(() {
        latitude = userLatitude;
        longitude = userLongitude;
      });
    } else {
      // do something to make the code tighter
    }
    _loadLastCheckedMessageId();
  }

  // 02 - use case update user information online and locally (location change)

  Future<void> _updateUserLocation() async {
    final newcountry = _countryValue.text;
    final newstate = _stateValue.text;
    final newcity = _cityValue.text;
    final displaypicture =
        supabase.storage.from('avatars').getPublicUrl(fullname);
    final user = supabase.auth.currentUser;
    final details = {
      'id': user!.id,
      'updated_at': DateTime.now().toIso8601String(),
      'full_name': fullname,
      'country': newcountry,
      'state': newstate,
      'city': newcity,
      'avatar_url': displaypicture
    };

    try {
      await supabase.from('profiles').upsert(details);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Location Updated Successfully :)',
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
    } finally {}

    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);

      userProfileMap['country'] = newcountry;
      userProfileMap['state'] = newstate;
      userProfileMap['city'] = newcity;

      // Convert the updated user data back to a JSON string
      final updatedUserProfileJson = json.encode(userProfileMap);

      // Save the updated user data back to shared preferences
      await prefs.setString('userprofile', updatedUserProfileJson);

      setState(() {
        city = newcity;
        state = newstate;
        country = newcountry;
      });
    } else {}
  }

  // 03 - use case check valid image

  Future<bool> checkPfpValidity() async {
    try {
      final response = await http.get(Uri.parse(pfp));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 04 - use case display userpfp

  Future<ImageProvider> _pfpImageProvider(String imageUrl) async {
    // Check if the image URL is valid
    bool isImageValid = await checkPfpValidity();

    if (isImageValid) {
      // Image URL is valid, return the NetworkImage
      return NetworkImage(imageUrl);
    } else {
      // Image URL is not valid, return a placeholder image using AssetImage
      return const AssetImage('assets/guest_dp.png');
    }
  }

  // 05 - use case pick image

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 06 - use case upload image

  Future<void> _uploadImage() async {
    final filename = fullname;
    try {
      await supabase.storage.from('avatars').update(
            filename,
            _image!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Profile picture updated successfully :)',
            style:
                responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ));
        setState(() {
          pfpChange = true;
        });
      }
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    }
  }

  // 07 - use case sign out

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        // navigate
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const SignIn()));
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
    }
  }

  // 08 - use case create saved search

  Future<void> _createSavedSearch(userid, serviceproviderid) async {
    try {
      // Get existing saved searches from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<dynamic>? savedSearchesCreation =
          prefs.getStringList('savedSearches') ?? <dynamic>[];
      // Check if the serviceproviderid is not already in the list
      if (!savedSearchesCreation.contains(serviceproviderid)) {
        // Add the new serviceproviderid to the list
        savedSearchesCreation.add(serviceproviderid);

        // Save the updated list back to SharedPreferences
        prefs.setStringList('savedSearches',
            savedSearchesCreation.map((e) => e.toString()).toList());

        setState(() {
          savedSearches = savedSearchesCreation;
        });

        // Insert the saved search into the database
        await supabase
            .from('savedsearches')
            .insert({'userid': userid, 'serviceproviderid': serviceproviderid});

        // Show a success message to the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'ServiceProvider has been added to your saved search successfully',
              style: responsiveTextStyle(
                  context, 16, Colors.black, FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        // Show a message indicating that the service provider is already in saved searches
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'ServiceProvider is already in your saved searches',
              style: responsiveTextStyle(
                  context, 16, Colors.black, FontWeight.bold),
            ),
            backgroundColor: Colors.orange,
          ));
        }
      }
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :(',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please check your network settings & try again',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  // 09 - use case delete saved search

  Future<void> _deleteSavedSearch(userid, serviceproviderid) async {
    try {
      // Get existing saved searches from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<dynamic>? savedSearchesDeletion =
          prefs.getStringList('savedSearches') ?? <dynamic>[];

      // Check if the serviceproviderid is in the list
      if (savedSearchesDeletion.contains(serviceproviderid)) {
        // Remove the serviceproviderid from the list
        savedSearchesDeletion.remove(serviceproviderid);

        // Save the updated list back to SharedPreferences
        prefs.setStringList('savedSearches',
            savedSearchesDeletion.map((e) => e.toString()).toList());

        setState(() {
          savedSearches = savedSearchesDeletion;
        });

        // Delete the saved search from the database
        await supabase
            .from('savedsearches')
            .delete()
            .eq('userid', userid)
            .eq('serviceproviderid', serviceproviderid);

        // Show a success message to the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'ServiceProvider has been removed from your saved searches successfully',
              style: responsiveTextStyle(
                  context, 16, Colors.black, FontWeight.bold),
            ),
            backgroundColor: Colors.green,
          ));
        }
      } else {
        // Show a message indicating that the service provider is not in saved searches
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'ServiceProvider is not in your saved searches. Please contact customer care',
              style: responsiveTextStyle(
                  context, 16, Colors.black, FontWeight.bold),
            ),
            backgroundColor: Colors.orange,
          ));
        }
      }
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      // Handle Supabase exception
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :(',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      if (!context.mounted) return;
      // Handle other potential errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please check your network settings & try again',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  // init

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // dispose

  @override
  void dispose() {
    _acontroller.dispose();
    _controller.dispose();
    _countryValue.dispose();
    _cityValue.dispose();
    _stateValue.dispose();
    super.dispose();
  }

  // variables

  late AnimationController _acontroller;
  final searchFocusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  List<String> filteredServices = []; // Initialize it as an empty list
  List<dynamic> appFilteredServiceProviders =
      []; // Initialize it as an empty list
  List<dynamic> savedSearches = [];
  String searchchoice = '';
  bool isTyping = false; // Initially, the user is not typing
  bool isSearching = false; // Initially the user is not searching
  String fullname = '';
  String pfp = '';
  String? city = '';
  String state = '';
  String country = '';
  File? _image;
  bool pfpChange = false;
  final _countryValue = TextEditingController();
  final _stateValue = TextEditingController();
  final _cityValue = TextEditingController();
  bool isCustomer = true;
  bool hasNewMessage = false;
  String? lastCheckedMessageId;
  double latitude = 0.0;
  double longitude = 0.0;

  // todo: save services list on user's phone
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

  // 09 - use case search feature

  // 09A - use case get ids of users within searchers city

  Future<List<dynamic>> _queryProfilesTable(
      {String? city, String? state}) async {
    try {
      // Check if city or state is provided, and build the query accordingly
      final query = (city != null && city.isNotEmpty)
          ? supabase.from('profiles').select('id').eq('city', city)
          : state != null
              ? supabase.from('profiles').select('id').eq('state', state)
              : null;

      if (query != null) {
        final response = await query;
        List<dynamic> profileIds = (response).map((row) => row['id']).toList();
        return profileIds;
      }
    } on PostgrestException catch (error) {
      final tError = error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error: $tError, Please try again',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please check your network settings & try again',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    }

    return [];
  }

// 09B - use case get service provider profiles within searchers city

  Future<List<dynamic>> _queryServiceProvidersTable(
      List<dynamic> profileIds) async {
    try {
      final response = await supabase
          .from('serviceproviders_profile')
          .select()
          .inFilter('id', profileIds); // Use 'in_' to filter by multiple IDs

      return response;
    } on PostgrestException catch (error) {
      if (!context.mounted) return [];
      final messenger = ScaffoldMessenger.of(context);
      final tError = error.message;
      messenger.showSnackBar(SnackBar(
        content: Text(
          'Server Error: $tError, Please try again',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      return [];
    } catch (error) {
      if (!context.mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please check your network settings & try again',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      return [];
    }
  }

  // 09C - use case query profiles table

  Future<dynamic> _getProfileData(String profileId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', profileId)
          .single(); // Assume there's only one profile with a given ID

      return response;
    } on PostgrestException catch (error) {
      if (!context.mounted) return;
      final tError = error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error: $tError, Please try again',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      return null;
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Unexpected Error, Please check your network settings & try again',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  // 10 - use case save last messageid

  Future<void> _saveLastCheckedMessageId(String messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastCheckedMessageId', messageId);
  }

  // 11 - use case load messageid

  Future<void> _loadLastCheckedMessageId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastCheckedMessageId = prefs.getString('lastCheckedMessageId') ?? '';
    });
  }

  // 12 - use case handle new message

  void _handleNewMessage(String latestMessageId) {
    if (latestMessageId != lastCheckedMessageId) {
      setState(() {
        hasNewMessage = true;
      });

      // Update the last checked message ID
      lastCheckedMessageId = latestMessageId;

      // Store lastCheckedMessageId in shared preferences
      _saveLastCheckedMessageId(lastCheckedMessageId!);
    }
  }

  // build saved search serviceprovider card

  Widget _buildSavedSearchItem(
      dynamic savedSearchProviderData, dynamic additionalProfileData) {
    // calculate the distance and convert it to estimated time
    final double customerLat = latitude;
    final double customerLon = longitude;
    final double serviceProviderLat = savedSearchProviderData['latitude'];
    final double serviceProviderLon = savedSearchProviderData['longitude'];

    final double distance = GeoUtils.calculateDistance(
      customerLat,
      customerLon,
      serviceProviderLat,
      serviceProviderLon,
    );

    String estimatedTimeText;
    if (distance < 1) {
      // If the service provider is less than 1 km away, display the time in seconds
      estimatedTimeText = '${(distance * 3600).toInt()} secs away';
    } else if (distance < 60) {
      // If the service provider is less than 60 km away, calculate the time in minutes
      final int estimatedTime = (distance / 50 * 60).ceil();
      estimatedTimeText = '$estimatedTime mins away';
    } else if (distance < 1440) {
      // If the service provider is less than 1440 km away (1 day), calculate the time in hours
      final int estimatedTime = (distance / 50).ceil();
      estimatedTimeText =
          estimatedTime == 1 ? '1 hr away' : '$estimatedTime hrs away';
    } else {
      // If the service provider is more than 1 day away, calculate the time in days
      final int estimatedTime = (distance / 50 / 24).ceil();
      estimatedTimeText =
          estimatedTime == 1 ? '1 day away' : '$estimatedTime days away';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ServiceProviderCard(
        name: additionalProfileData['full_name'],
        bio: savedSearchProviderData['bio'],

        // view profile
        onPressedButton1: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => ViewProfilePage(
                availability: savedSearchProviderData['availability'],
                // experience: savedSearchProviderData['experience'],
                fbLink: savedSearchProviderData['fb_url'],
                fullname: additionalProfileData['full_name'],
                igLink: savedSearchProviderData['ig_url'],
                linkedinLink: savedSearchProviderData['linkedin_url'],
                mailLink: savedSearchProviderData['gmail_link'],
                // media1: savedSearchProviderData['media_url1'],
                // media2: savedSearchProviderData['media_url2'],
                // media3: savedSearchProviderData['media_url3'],
                pfp: additionalProfileData['avatar_url'],
                // specialoffers: savedSearchProviderData['special_offers'],
                webLink: savedSearchProviderData['web_link'],
                xLink: savedSearchProviderData['x_url'],
                id: savedSearchProviderData['id'],
              ),
            ),
          );
        },
        isOnline: Online(userId: savedSearchProviderData['id']),
        saved: true,
        onPressedButton2: () {
          final userid = supabase.auth.currentUser!.id;
          final serviceproviderid = additionalProfileData['id'];
          _deleteSavedSearch(userid, serviceproviderid);
        },
        guest: false,
        img: additionalProfileData['avatar_url'],
        distance: estimatedTimeText,
      ),
    );
  }

  // build saved search list from backend

  Widget _buildSavedSearchList(List<dynamic> savedSearchProviders) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: ListView.builder(
        itemCount: savedSearchProviders.length,
        itemBuilder: (context, index) {
          dynamic savedSearchProviderData = savedSearchProviders[index];
          return FutureBuilder(
            future: _getProfileData(savedSearchProviderData['id']),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SpinKitPianoWave(
                  size: 30,
                  color: Color(0xFF13CAF1),
                  itemCount: 4,
                ); // or any loading indicator
              } else if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo_t.png',
                      height: 75,
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.15,
                    ),
                    Text(
                      'Error loading saved searches. Please try again.',
                      style: responsiveTextStyle(
                          context, 16, Colors.red, FontWeight.bold),
                    ),
                  ],
                );
              } else {
                dynamic additionalProfileData = snapshot.data;
                return _buildSavedSearchItem(
                    savedSearchProviderData, additionalProfileData);
              }
            },
          );
        },
      ),
    );
  }

// build method

  @override
  Widget build(BuildContext context) {
    final notificationUserId = supabase.auth.currentUser!.id;
    final stream = supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('receiverid', notificationUserId)
        .order('created_at', ascending: false)
        .map((maps) => maps.toList());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color(0xFF039fdc),
                Color(0xFF13CAF1),
              ],
            ),
          ),
          child: ListView(children: [
            StreamBuilder<List<Map<String, dynamic>>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    String latestMessageId = (snapshot.data!.first)['id'];
                    Future.delayed(Duration.zero, () {
                      _handleNewMessage(latestMessageId);
                    });
                    return Visibility(
                      visible: hasNewMessage,
                      child: NewMessageNotification(
                        onTap: () {
                          setState(() {
                            hasNewMessage = false;
                          });
                          // Handle tap to open chat history page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatHistory(
                                isCustomer: isCustomer,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return Container();
                }),
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
                child: FocusScope(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RotationTransition(
                            turns: Tween(begin: 0.0, end: 1.0)
                                .animate(_acontroller),
                            child: Image.asset(
                              'assets/logo_t.png',
                              height: 75,
                            ),
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  // customer pfp
                                  pfpChange
                                      ? CircleAvatar(
                                          backgroundImage: FileImage(_image!),
                                          radius: 30,
                                        )
                                      :
                                      // Wrap your CircleAvatar with a FutureBuilder
                                      // todo: cache the image
                                      FutureBuilder<ImageProvider>(
                                          future: _pfpImageProvider(pfp),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              // If the future is complete, you can use the ImageProvider

                                              return CircleAvatar(
                                                backgroundImage: snapshot.data,
                                                radius: 30,
                                              );
                                            } else {
                                              // While the future is loading, you can show a placeholder or loading indicator

                                              return const SpinKitPianoWave(
                                                size: 30,
                                                color: Color(0xFF13CAF1),
                                                itemCount: 4,
                                              );
                                            }
                                          },
                                        ),

                                  // end of customer pfp
                                  PopupMenuButton(
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        PopupMenuItem(
                                          textStyle: responsiveTextStyle(
                                              context,
                                              16,
                                              Colors.black,
                                              FontWeight.bold),
                                          value: 'changeDisplayPicture',
                                          child: const Text(
                                            'Change Display Picture',
                                          ),
                                        ),
                                        PopupMenuItem(
                                          textStyle: responsiveTextStyle(
                                              context,
                                              16,
                                              Colors.black,
                                              FontWeight.bold),
                                          value: 'editLocation',
                                          child: const Text(
                                            'Edit Location',
                                          ),
                                        ),
                                        PopupMenuItem(
                                          textStyle: responsiveTextStyle(
                                              context,
                                              16,
                                              Colors.black,
                                              FontWeight.bold),
                                          value: 'becomeAServiceProvider',
                                          child: const Text(
                                            'Become a Service Provider',
                                          ),
                                        ),
                                        PopupMenuItem(
                                          textStyle: responsiveTextStyle(
                                              context,
                                              16,
                                              Colors.black,
                                              FontWeight.bold),
                                          value: 'chatHistory',
                                          child: const Text(
                                            'Chat History',
                                          ),
                                        ),
                                        PopupMenuItem(
                                          textStyle: responsiveTextStyle(
                                              context,
                                              16,
                                              Colors.black,
                                              FontWeight.bold),
                                          value: 'customerCare',
                                          child: const Text('Customer Care'),
                                        ),
                                        PopupMenuItem(
                                          textStyle: responsiveTextStyle(
                                              context,
                                              16,
                                              Colors.black,
                                              FontWeight.bold),
                                          value: 'termsAndConditions',
                                          child: const Text(
                                              'Terms and Conditions'),
                                        ),
                                        PopupMenuItem(
                                          textStyle: responsiveTextStyle(
                                              context,
                                              16,
                                              Colors.black,
                                              FontWeight.bold),
                                          value: 'signOut',
                                          child: const Text('Sign Out'),
                                        ),
                                      ];
                                    },
                                    onSelected: (value) {
                                      // Handle the selected menu item (navigate to the corresponding screen)
                                      if (value == 'changeDisplayPicture') {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Please Pick a new Image'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          pfpChange = false;
                                                        });
                                                        _pickImage();
                                                      },
                                                      child: const Icon(
                                                        Icons.camera_alt,
                                                        size: 100,
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    const Text(
                                                        '1) Tap the camera icon to pick an image\n2) Tap the refresh button to confirm your image before uploading :)')
                                                  ],
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        if (_image != null) {
                                                          Navigator.pop(
                                                              context);
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      'Here\'s your image :)'),
                                                                  content: Image
                                                                      .file(
                                                                          _image!),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        _uploadImage();

                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child: const Text(
                                                                          'Upload'),
                                                                    ),
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: const Text(
                                                                            'Cancel'))
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      },
                                                      child: const Text(
                                                          'Refresh')),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Cancel'))
                                                ],
                                              );
                                            });
                                      } else if (value == 'editLocation') {
                                        _countryValue.text = country;
                                        _stateValue.text = state;
                                        _cityValue.text = city!;
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                        'Set your new Location'),
                                                    Text(
                                                      'reset from country, city then state for best performance 🤚',
                                                      style:
                                                          responsiveTextStyle(
                                                              context,
                                                              8,
                                                              Colors.blueGrey,
                                                              null),
                                                    ),
                                                  ],
                                                ),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CountryStateCityPicker(
                                                        country: _countryValue,
                                                        state: _stateValue,
                                                        city: _cityValue),
                                                  ],
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        _updateUserLocation();
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                          'Confirm')),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('Cancel'))
                                                ],
                                              );
                                            });
                                      } else if (value == 'chatHistory') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  ChatHistory(
                                                    isCustomer: isCustomer,
                                                  )),
                                        );
                                      } else if (value == 'signOut') {
                                        _signOut();
                                      } else if (value ==
                                          'becomeAServiceProvider') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  const ServiceProviderProfileCreation()),
                                        );
                                      } else if (value == 'customerCare') {}
                                      // Add more cases for other menu items
                                    },
                                  ),
                                ],
                              ),
                              // customer name
                              Text(
                                fullname,
                                style: responsiveTextStyle(
                                    context, 16, Colors.white, FontWeight.bold),
                              ),
                              // end of customer name
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.15),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _controller,
                              focusNode: searchFocusNode,
                              showCursor: false,
                              style: responsiveTextStyle(
                                  context, 16, Colors.white, FontWeight.bold),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                suffixIcon: InkWell(
                                    radius: 50,
                                    splashColor: Colors.greenAccent,
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        isSearching = false;
                                        // When suffix icon is tapped, set isTyping to false
                                        isTyping = false;
                                        // You can also clear the text field if needed
                                        _controller.clear();
                                        // Update the filtered services here as well
                                        filteredServices = [];
                                      });
                                    },
                                    child: const Icon(
                                      Icons.cancel,
                                      color: Colors.black54,
                                    )),
                                hintText: 'Search...',
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
                                    style: responsiveTextStyle(context, 16,
                                        Colors.black, FontWeight.bold),
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
                                      onTap: () async {
                                        // Handle user selection here.
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          isSearching = true;
                                          // When tile is tapped, set isTyping to false
                                          isTyping = false;
                                          searchchoice =
                                              filteredServices[index];
                                          _controller.text =
                                              filteredServices[index];

                                          // Update the filtered services here as well
                                          filteredServices = [];
                                        });
                                        List<dynamic> profileIds;

                                        if (city != null && city != '') {
                                          profileIds =
                                              await _queryProfilesTable(
                                                  city: city);
                                        } else {
                                          profileIds =
                                              await _queryProfilesTable(
                                                  state: state);
                                        }

                                        List<dynamic> serviceProviders =
                                            await _queryServiceProvidersTable(
                                                profileIds);
                                        List<dynamic> filteredServiceProviders =
                                            serviceProviders
                                                .where((provider) =>
                                                    provider[
                                                        'service_provided'] ==
                                                    searchchoice)
                                                .toList();

                                        setState(() {
                                          appFilteredServiceProviders =
                                              filteredServiceProviders;
                                        });
                                      },
                                    );
                                  },
                                ),
                        ),
                      ),
                      // saved searches
                      Stack(children: [
                        Visibility(
                            visible: isSearching
                                ? isTyping
                                : !isTyping, // Content is visible when not typing
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.15),
                                Text(
                                  'Saved Searches',
                                  style: responsiveTextStyle(
                                      context, 20, null, FontWeight.bold),
                                ),
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.0125),
                                FutureBuilder(
                                  future: _queryServiceProvidersTable(
                                      savedSearches),
                                  builder: (context,
                                      AsyncSnapshot<List<dynamic>> snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SpinKitPianoWave(
                                        size: 30,
                                        color: Color(0xFF13CAF1),
                                        itemCount: 4,
                                      ); // or any loading indicator
                                    } else if (snapshot.hasError) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/logo_t.png',
                                            height: 75,
                                          ),
                                          SizedBox(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.15,
                                          ),
                                          Text(
                                            'Error loading saved searches. Please try again.',
                                            style: responsiveTextStyle(
                                                context,
                                                16,
                                                Colors.red,
                                                FontWeight.bold),
                                          ),
                                        ],
                                      );
                                    } else {
                                      List<dynamic>? savedSearchProviders =
                                          snapshot.data;

                                      // // Check if the future is complete and savedSearchProviders is still empty
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          savedSearchProviders!.isEmpty) {
                                        // Display a message when there are no saved searches
                                        return Column(
                                          children: [
                                            Image.asset('assets/search.png'),
                                            SizedBox(
                                              height: MediaQuery.sizeOf(context)
                                                      .height *
                                                  0.0125,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'No saved searches yet?\nStart searching now',
                                                  style: responsiveTextStyle(
                                                      context,
                                                      16,
                                                      Colors.black,
                                                      null),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }

                                      return _buildSavedSearchList(
                                          savedSearchProviders!);
                                    }
                                  },
                                )

                                // end of saved search
                              ],
                            )),
                        Visibility(
                          visible:
                              isSearching, // Content is visible when typing searching
                          child: Positioned(
                            child: Container(
                              height: MediaQuery.sizeOf(context).height * 0.95,
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.05),
                                  Text(
                                    // todo: provide support for other pronouns
                                    '$searchchoice(s)',
                                    style: responsiveTextStyle(
                                        context, 20, null, FontWeight.bold),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.0125),
                                  Expanded(
                                    child: FutureBuilder(
                                      future: Future.wait(
                                          appFilteredServiceProviders.map(
                                              (serviceProviderData) =>
                                                  _getProfileData(
                                                      serviceProviderData[
                                                          'id']))),
                                      builder: (context,
                                          AsyncSnapshot<List<dynamic>>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SpinKitPianoWave(
                                            size: 30,
                                            color: Color(0xFF13CAF1),
                                            itemCount: 4,
                                          ); // or any loading indicator
                                        } else if (snapshot.hasError) {
                                          return Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/logo_t.png',
                                                height: 75,
                                              ),
                                              SizedBox(
                                                  height:
                                                      MediaQuery.sizeOf(context)
                                                              .height *
                                                          0.15),
                                              Text(
                                                'Error loading data. Please try again.',
                                                style: responsiveTextStyle(
                                                    context,
                                                    16,
                                                    Colors.red,
                                                    FontWeight.bold),
                                              ),
                                            ],
                                          );
                                        } else {
                                          List<dynamic>?
                                              additionalProfileDataList =
                                              snapshot.data;

                                          // Check if the future is complete and app_filteredServiceProviders is still empty
                                          if (snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              appFilteredServiceProviders
                                                  .isEmpty) {
                                            // Display a message when there are no service providers
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Sorry, We don\'t have any service providers offering this service in your city.',
                                                  style: responsiveTextStyle(
                                                    context,
                                                    16,
                                                    Colors.black,
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      MediaQuery.sizeOf(context)
                                                              .height *
                                                          0.025,
                                                ),
                                                Text(
                                                  'Share this link to invite them:',
                                                  style: responsiveTextStyle(
                                                    context,
                                                    16,
                                                    Colors.black,
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                                // todo:
                                                // Add your shareable link widget here
                                                // For example, you can use a TextFormField to display and copy the link
                                              ],
                                            );
                                          }

                                          return ListView.builder(
                                            itemCount:
                                                appFilteredServiceProviders
                                                    .length,
                                            itemBuilder: (context, index) {
                                              dynamic serviceProviderData =
                                                  appFilteredServiceProviders[
                                                      index];
                                              dynamic additionalProfileData =
                                                  additionalProfileDataList![
                                                      index];

                                              // calculate the distance and convert it to estimated time
                                              final double customerLat =
                                                  latitude;
                                              final double customerLon =
                                                  longitude;
                                              final double serviceProviderLat =
                                                  serviceProviderData[
                                                      'latitude'];
                                              final double serviceProviderLon =
                                                  serviceProviderData[
                                                      'longitude'];

                                              final double distance =
                                                  GeoUtils.calculateDistance(
                                                customerLat,
                                                customerLon,
                                                serviceProviderLat,
                                                serviceProviderLon,
                                              );

                                              String estimatedTimeText;
                                              if (distance < 1) {
                                                // If the service provider is less than 1 km away, display the time in seconds
                                                estimatedTimeText =
                                                    '${(distance * 3600).toInt()} secs away';
                                              } else if (distance < 60) {
                                                // If the service provider is less than 60 km away, calculate the time in minutes
                                                final int estimatedTime =
                                                    (distance / 50 * 60).ceil();
                                                estimatedTimeText =
                                                    '$estimatedTime mins away';
                                              } else if (distance < 1440) {
                                                // If the service provider is less than 1440 km away (1 day), calculate the time in hours
                                                final int estimatedTime =
                                                    (distance / 50).ceil();
                                                estimatedTimeText =
                                                    estimatedTime == 1
                                                        ? '1 hr away'
                                                        : '$estimatedTime hrs away';
                                              } else {
                                                // If the service provider is more than 1 day away, calculate the time in days
                                                final int estimatedTime =
                                                    (distance / 50 / 24).ceil();
                                                estimatedTimeText =
                                                    estimatedTime == 1
                                                        ? '1 day away'
                                                        : '$estimatedTime days away';
                                              }

                                              return Column(
                                                children: [
                                                  ServiceProviderCard(
                                                    saved: false,
                                                    name: additionalProfileData[
                                                        'full_name'],
                                                    bio: serviceProviderData[
                                                        'bio'],
                                                    // view profile
                                                    onPressedButton1: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              ViewProfilePage(
                                                            availability:
                                                                serviceProviderData[
                                                                    'availability'],
                                                            // experience:
                                                            //     serviceProviderData[
                                                            //         'experience'],
                                                            fbLink:
                                                                serviceProviderData[
                                                                    'fb_url'],
                                                            fullname:
                                                                additionalProfileData[
                                                                    'full_name'],
                                                            igLink:
                                                                serviceProviderData[
                                                                    'ig_url'],
                                                            linkedinLink:
                                                                serviceProviderData[
                                                                    'linkedin_url'],
                                                            mailLink:
                                                                serviceProviderData[
                                                                    'gmail_link'],
                                                            // media1:
                                                            //     serviceProviderData[
                                                            //         'media_url1'],
                                                            // media2:
                                                            //     serviceProviderData[
                                                            //         'media_url2'],
                                                            // media3:
                                                            //     serviceProviderData[
                                                            //         'media_url3'],
                                                            pfp: additionalProfileData[
                                                                'avatar_url'],
                                                            // specialoffers:
                                                            //     serviceProviderData[
                                                            //         'special_offers'],
                                                            webLink:
                                                                serviceProviderData[
                                                                    'web_link'],
                                                            xLink:
                                                                serviceProviderData[
                                                                    'x_url'],
                                                            id: serviceProviderData[
                                                                'id'],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    // add to saved
                                                    onPressedButton2: () {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      setState(() {
                                                        isSearching = false;
                                                        isTyping = false;
                                                        _controller.clear();
                                                        filteredServices = [];
                                                      });
                                                      final userid = supabase
                                                          .auth.currentUser!.id;
                                                      final serviceproviderid =
                                                          additionalProfileData[
                                                              'id'];
                                                      _createSavedSearch(userid,
                                                          serviceproviderid);
                                                    },
                                                    isOnline: Online(
                                                        userId:
                                                            serviceProviderData[
                                                                'id']),
                                                    guest: false,
                                                    img: additionalProfileData[
                                                        'avatar_url'],
                                                    distance: estimatedTimeText,
                                                  ),
                                                  SizedBox(
                                                    height: MediaQuery.sizeOf(
                                                                context)
                                                            .height *
                                                        0.0125,
                                                  )
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
