import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:callup247/src/chat/pages/chathistory.dart';
import 'package:callup247/src/notification.dart';
import 'package:callup247/src/online.dart';
import 'package:callup247/src/profile/pages/edit_servicepovider_profile_page.dart';
import 'package:callup247/src/profile/pages/serviceprovider_profilepage.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart';
import '../../authentication/pages/user_login.dart';
import '../../profile/pages/view_profilepage.dart';
import '../../responsive_text_styles.dart';
import 'package:http/http.dart' as http;
import '../widgets/service_provider_card.dart';

class ServiceProviderHomePage extends StatefulWidget {
  const ServiceProviderHomePage({super.key});

  @override
  State<ServiceProviderHomePage> createState() =>
      _ServiceProviderHomePageState();
}

class _ServiceProviderHomePageState extends State<ServiceProviderHomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // 01 - use case initialize data

  Future<void> _initializeData() async {
    _acontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Adjust the duration as needed
    )..repeat(); // This will make the animation loop
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    final userSavedSearches = prefs.getStringList('savedSearches');
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
    _loadLastCheckedMessageId();
  }

  // 02 - use case online

  Future<void> _online() async {
    try {
      await supabase.from('online').upsert({
        'user_id': supabase.auth.currentUser!.id,
        'last_seen': DateTime.now().toString()
      });
      if (mounted) {}
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    }
  }

  // 04 - use case update user information online and locally (location change)

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

  // 05 - use case check valid image

  Future<bool> checkPfpValidity() async {
    try {
      final response = await http.get(Uri.parse(pfp));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 06 - use case display userpfp

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

  // 07 - use case pick image

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 08 - use case upload image

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

  // 09 - use case sign out

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

  // 10 - use case create saved search

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

// 11 - use case delete saved search

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
    _lastSeenTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _online();
    });
  }

  // dispose

  @override
  void dispose() {
    _acontroller.dispose();
    _controller.dispose();
    _countryValue.dispose();
    _stateValue.dispose();
    _cityValue.dispose();
    _lastSeenTimer.cancel();
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
  bool hasNewMessage = false;
  String? lastCheckedMessageId;
  bool isCustomer = false;
  late Timer _lastSeenTimer;

  // services list

  List<String> servicesList = [
    'Accountant',
    'Accounts Clerk',
    'Actor',
    'Actuary',
    'Acupuncturist',
    'Advertising Specialist',
    'Aeronautical Engineer',
    'Aged Person Carer',
    'Air Traffic Controller',
    'Aircraft Maintenance Engineer',
    'Aircraft Pilot',
    'Aircraft Safety Equipment Worker',
    'Ambulance Officer',
    'Amusement Centre',
    'Anaesthetist',
    'Anatomist',
    'Animal Attendant',
    'Animal Trainers',
    'Apiarist',
    'Apparel Cutter',
    'Application Programmer',
    'Aquaculture Farmer',
    'Architect',
    'Archivist',
    'Armoured Car Escort',
    'Art Director (Film, Television or Stage)',
    'Art Teacher (Private)',
    'Artistic Director',
    'Auctioneer',
    'Audiologist',
    'Author',
    'Automobile Driver',
    'Bailiff',
    'Baker',
    'Baking Factory',
    'Bar Attendant',
    'Barrister',
    'Beauty Therapist',
    'Binder and Finisher',
    'Biochemist',
    'Biomedical Engineer',
    'Blacksmith',
    'Blogger',
    'Boat Builder and Repairer',
    'Book Editor',
    'Bookkeeper',
    'Bookmaker',
    'Botanist',
    'Bricklayer',
    'Butcher',
    'Cabinetmaker',
    'Cable Jointer',
    'Café',
    'Camera Operator (Film, Television or Video)',
    'Canvas Goods Maker',
    'Car Park',
    'Car Rental Agency',
    'Car Wash',
    'Caravan Park and Camping Ground',
    'Careers Counsellor',
    'Caretaker',
    'Carpenter',
    'Carpet Cleaner',
    'Cartographer',
    'Chef',
    'Chemist',
    'Child Minder',
    'Chiropractor',
    'Cinema',
    'Clinical Psychologist',
    'Club',
    'Coding Clerk',
    'Consultant',
    'Commercial Cleaner',
    'Company Secretary',
    'Composer',
    'Computer Systems Auditor',
    'Computing Technician',
    'Cook',
    'Copywriter',
    'Dance Teacher (Private)',
    'Dancer or Choreographer',
    'Debt Collector',
    'Delivery Driver',
    'Dental Hygienist',
    'Dentist',
    'Dermatologist',
    'Desktop Publishing Operator',
    'Dietitian',
    'Disabled Person Carer',
    'Diver',
    'Domestic Cleaner',
    'Domestic Housekeeper',
    'Door-to-Door Salesperson',
    'Doorperson',
    'Drainer',
    'Drama Teacher (Private)',
    'Dressmaker',
    'Driller',
    'Driving Instructor',
    'Drug and Alcohol Counsellor',
    'Economist',
    'Editor',
    'Educational Psychologist',
    'Electrical Engineer',
    'Electrical Engineering Technician',
    'Electrician',
    'Engine or Boiler Operator',
    'Examination Supervisor',
    'Excavator Operator',
    'External Auditor',
    'Fabric and Textile Factory',
    'Family Counsellor',
    'Family Day Care',
    'Family Support Worker',
    'Farm Overseer',
    'Fashion Designer',
    'Fast Food Cook',
    'Fence Erector',
    'Film and Video Editor',
    'Financial Investment Adviser',
    'Financial Market Dealer',
    'Fire Fighter',
    'Fisherman',
    'Fitness Centre',
    'Fitness Instructor',
    'Fitter',
    'Flight Engineer',
    'Floor Finisher',
    'Florist',
    'Flying Instructor',
    'Footballer',
    'Forester',
    'Forklift Driver',
    'Freight Handler',
    'Fruit, Vegetable or Nut Farm Hand',
    'Funeral Director',
    'Furniture Removers',
    'Furniture Upholsterer',
    'Garbage Collector',
    'Garden Labourer',
    'Gasfitter',
    'Gem Cutter and Polisher',
    'General Construction Plant Operator',
    'General Electrician',
    'Gymnastics Coach',
    'Gynaecologist',
    'Hair and Beauty Salon',
    'Hairdresser',
    'Hand Packer',
    'Handyperson',
    'Heavy Truck Driver',
    'Historian',
    'Home Improvements Installer',
    'Horse Breeder',
    'Horse Trainer',
    'Horse-riding Coach',
    'Hospital',
    'Hospitality Agency',
    'Hotel or Motel',
    'Illustrator',
    'Importer or Exporter',
    'Instrumental Musician',
    'Insurance Agent',
    'Insurance Broker',
    'Interior Decorator/Design',
    'Internal Auditor',
    'Interpreter',
    'Interviewer',
    'Jeweller',
    'Judge',
    'Kitchen Porter',
    'Kitchenhand',
    'Landscape Architect',
    'Landscape Gardener',
    'Launderette',
    'Leaflet and Newspaper Deliverer',
    'Legal Professionals',
    'Librarian',
    'Lift Mechanic',
    'Light Technician',
    'Loader Operator',
    'Locksmith',
    'Luggage Porter',
    'Magistrate court',
    'Make Up Artist',
    'Management Consultant',
    'Manufacturer',
    'Marketing Specialist',
    'Marketing Officer',
    'Massage Therapist',
    'Masseuse',
    'Master Fisher',
    'Materials Engineer',
    'Materials Recycler',
    'Mathematician (Teacher)',
    'Mechanical Engineer',
    'Mechanical Services and Air-conditioning Plumber',
    'Media Producer',
    'Metal Fabricator',
    'Metal Machinist',
    'Meteorologist',
    'Meter Reader',
    'Miner',
    'Minister of Religion',
    'Model',
    'Motor Mechanic',
    'Motor Vehicle and Caravan Salesperson',
    'Museum or Art Gallery',
    'Music Director',
    'Music Teacher (Private)',
    'Nanny',
    'Natural Remedy Consultant',
    'Naturopath',
    'Naval Architect',
    'Nuclear Medicine Technologist',
    'Nurse',
    'Nurseryperson',
    'Obstetrician',
    'Occupational Health and Safety Officer',
    'Occupational Therapist',
    'Oenologist',
    'Ophthalmologist',
    'Optical Mechanic',
    'Optometrist',
    'Orthoptist',
    'Osteopath',
    'Others - Please Specify',
    'Packager and Container Filler',
    'Paediatrician',
    'Painter (Visual Arts)',
    'Painter and Decorator',
    'Park Ranger',
    'Parking Inspector',
    'Paving and Surfacing Labourer',
    'Paving Plant Operator',
    'Personal Assistant',
    'Pest and Weed Controller',
    'Petroleum and Gas Plant Operator',
    'Petroleum Engineer',
    'Photographer',
    'Photographic Developer and Printer',
    'Physicist',
    'Physiologist',
    'Physiotherapist',
    'Plumber',
    'Plumbing Inspector',
    'Podiatrist',
    'Police Station',
    'Post Office',
    'Postal Delivery Office',
    'Postal Sorting Office',
    'Poultry Farm',
    'Pre-Primary School Teacher',
    'Pressure Welder',
    'Primary School Teacher',
    'Print Journalist',
    'Printing Machinist',
    'Private Investigator',
    'Product Assembler',
    'Product Examiner',
    'Production manager (Film, Television or Radio)',
    'Program Director (Radio or Television)',
    'Project Builder',
    'Proof Reader',
    'Property Manager',
    'Psychiatrist',
    'Purchasing Officer',
    'Quality Assurer',
    'Quantity Surveyor',
    'Radiation Therapist',
    'Radio Journalist',
    'Radio Operator',
    'Radio Presenter',
    'Radiologist',
    'Real Estate Agency',
    'Real Estate Salesperson',
    'Receptionist',
    'Refrigeration and Air-conditioning Mechanic',
    'Registered Developmental Disability Nurse',
    'Registered Mental Health Nurse',
    'Registered Midwife',
    'Registered Nurse',
    'Registry or Filing Office',
    'Residential Care Office',
    'Restaurant',
    'Roof Plumber',
    'Roof Slater and Tiler',
    'Scaffolder',
    'Script Editor',
    'Sculptor',
    'Secondary School Tutor',
    'Secretary',
    'Security Officer',
    'Sewing Machinist',
    'Shoemaker',
    'Signwriter',
    'Singer',
    'Social Worker',
    'Solicitor',
    'Sound Technician',
    'Special Needs Teacher',
    'Specialist Physician',
    'Speech Pathologist',
    'Stockbroking Dealer',
    'Studio',
    'Surgeon',
    'Surveyor',
    'Swimming Coach',
    'Switchboard Operator',
    'Systems Designer',
    'Tailor',
    'Technical Director',
    'Technical Writer',
    'Telemarketer',
    'Television Journalist',
    'Television Presenter',
    'Tennis Coach',
    'Theatre',
    'Tourist/Tour office',
    'Tram Driver',
    'Translator',
    'Travel Agency',
    'Travel Agent',
    'Truck Driver',
    'Typist and Word Processing Operator',
    'Valuer',
    'Vehicle Body Maker',
    'Vehicle Cleaner',
    'Vehicle Painter',
    'Veterinarian',
    'Veterinary Nurse',
    'Visual Arts and Crafts Professionals',
    'Visual Merchandiser',
    'Wall and Floor Tiler',
    'Watch and Clock Maker and Repairer',
    'Water and Waste Water Plant Operator',
    'Water Inspector',
    'Weaving Machine Operator',
    'Weight Loss Consultant',
    'Welder',
    'Wholesale',
    'Window Cleaner',
    'Wood Machinist',
    'Wood Tradespersons',
    'Wood Turner',
    'Wool Classer',
    'Xylophonist',
    'Zoologist',
  ];
  // end of list of services

  // 12 - use case get ids of users within searchers city

  Future<List<dynamic>> _queryProfilesTable(
      {String? city, String? state}) async {
    try {
      // Check if city or state is provided, and build the query accordingly
      final query = city != null && city != ''
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

// 13 use case - get service provider profiles within searchers city

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
      final tError = error.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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

  // 14 - use case query profiles table

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

  // 15 - use case save last messageid

  Future<void> _saveLastCheckedMessageId(String messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastCheckedMessageId', messageId);
  }

  // 16 - use case load messageid

  Future<void> _loadLastCheckedMessageId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastCheckedMessageId = prefs.getString('lastCheckedMessageId') ?? '';
    });
  }

  // 17 - use case handle new message

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
          child: ListView(
            children: [
              StreamBuilder<List<Map<String, dynamic>>>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      // get the latest message id if it's different than the last on this gets triggered
                      String latestMessageId = (snapshot.data!.first)['id'];

                      Future.delayed(Duration.zero, () {
                        _handleNewMessage(latestMessageId);
                      });

                      // Return the notification widget
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
                              child: GestureDetector(
                                child: Image.asset(
                                  'assets/logo_t.png',
                                  height: 75,
                                ),
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
                                                  backgroundImage:
                                                      snapshot.data,
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
                                            value: 'editProfile',
                                            child: const Text(
                                              'Edit Profile',
                                            ),
                                          ),
                                          PopupMenuItem(
                                            textStyle: responsiveTextStyle(
                                                context,
                                                16,
                                                Colors.black,
                                                FontWeight.bold),
                                            value: 'viewProfile',
                                            child: const Text('View profile'),
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
                                                                context:
                                                                    context,
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
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              const Text('Cancel'))
                                                                    ],
                                                                  );
                                                                });
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Refresh')),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Cancel'))
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
                                                        CrossAxisAlignment
                                                            .start,
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
                                                      )
                                                    ],
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      CountryStateCityPicker(
                                                          country:
                                                              _countryValue,
                                                          state: _stateValue,
                                                          city: _cityValue),
                                                    ],
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          _updateUserLocation();
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Confirm')),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'Cancel'))
                                                  ],
                                                );
                                              });
                                        } else if (value == 'signOut') {
                                          _signOut();
                                        } else if (value == 'viewProfile') {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      const ServiceProviderProfile()));
                                        } else if (value == 'editProfile') {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      const EditServiceProviderProfile()));
                                        } else if (value == 'customerCare') {}
                                        // Add more cases for other menu items
                                      },
                                    ),
                                  ],
                                ),
                                // customer name
                                Text(
                                  fullname,
                                  style: responsiveTextStyle(context, 16,
                                      Colors.white, FontWeight.bold),
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
                                      "Sorry, we don't have this service currently. Please pick a registered service.",
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
                                          style: responsiveTextStyle(
                                              context,
                                              16,
                                              Colors.black,
                                              FontWeight.bold),
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
                                          List<dynamic>
                                              filteredServiceProviders =
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
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.15),
                                  Text(
                                    'Saved Searches',
                                    style: responsiveTextStyle(
                                        context, 20, null, FontWeight.bold),
                                  ),
                                  SizedBox(
                                      height:
                                          MediaQuery.sizeOf(context).height *
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

                                        // Check if the future is complete and savedSearchProviders is still empty
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            savedSearchProviders!.isEmpty) {
                                          // Display a message when there are no saved searches
                                          return Column(
                                            children: [
                                              Image.asset('assets/search.png'),
                                              SizedBox(
                                                height:
                                                    MediaQuery.sizeOf(context)
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

                                        // Display the saved searches
                                        return SizedBox(
                                            height: MediaQuery.sizeOf(context)
                                                    .height *
                                                0.6,
                                            child: ListView.builder(
                                                itemCount: savedSearchProviders!
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  // Use savedSearchProviders[index] to display the saved searches
                                                  // Implement your UI accordingly
                                                  // ...
                                                  dynamic
                                                      savedSearchProviderData =
                                                      savedSearchProviders[
                                                          index];

                                                  return FutureBuilder(
                                                      future: _getProfileData(
                                                          savedSearchProviderData[
                                                              'id']),
                                                      builder: (context,
                                                          AsyncSnapshot<dynamic>
                                                              snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const SpinKitPianoWave(
                                                            size: 30,
                                                            color: Color(
                                                                0xFF13CAF1),
                                                            itemCount: 4,
                                                          ); // or any loading indicator
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Image.asset(
                                                                'assets/logo_t.png',
                                                                height: 75,
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.sizeOf(
                                                                            context)
                                                                        .height *
                                                                    0.15,
                                                              ),
                                                              Text(
                                                                'Error loading saved searches. Please try again.',
                                                                style: responsiveTextStyle(
                                                                    context,
                                                                    16,
                                                                    Colors.red,
                                                                    FontWeight
                                                                        .bold),
                                                              ),
                                                            ],
                                                          );
                                                        } else {
                                                          dynamic
                                                              additionalProfileData =
                                                              snapshot.data;

                                                          return Column(
                                                            children: [
                                                              ServiceProviderCard(
                                                                name: additionalProfileData[
                                                                    'full_name'],
                                                                bio:
                                                                    savedSearchProviderData[
                                                                        'bio'],
                                                                img: savedSearchProviderData[
                                                                    'media_url1'],
                                                                guest: false,
                                                                // view profile
                                                                onPressedButton1:
                                                                    () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(
                                                                    MaterialPageRoute(
                                                                      builder: (BuildContext
                                                                              context) =>
                                                                          ViewProfilePage(
                                                                        availability:
                                                                            savedSearchProviderData['availability'],
                                                                        experience:
                                                                            savedSearchProviderData['experience'],
                                                                        fbLink:
                                                                            savedSearchProviderData['fb_url'],
                                                                        fullname:
                                                                            additionalProfileData['full_name'],
                                                                        igLink:
                                                                            savedSearchProviderData['ig_url'],
                                                                        mailLink:
                                                                            savedSearchProviderData['gmail_link'],
                                                                        media1:
                                                                            savedSearchProviderData['media_url1'],
                                                                        media2:
                                                                            savedSearchProviderData['media_url2'],
                                                                        media3:
                                                                            savedSearchProviderData['media_url3'],
                                                                        pfp: additionalProfileData[
                                                                            'avatar_url'],
                                                                        specialoffers:
                                                                            savedSearchProviderData['special_offers'],
                                                                        webLink:
                                                                            savedSearchProviderData['web_link'],
                                                                        xLink: savedSearchProviderData[
                                                                            'x_url'],
                                                                        id: savedSearchProviderData[
                                                                            'id'],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                isOnline: Online(
                                                                    userId:
                                                                        savedSearchProviderData[
                                                                            'id']),
                                                                saved: true,
                                                                onPressedButton2:
                                                                    () {
                                                                  final userid =
                                                                      supabase
                                                                          .auth
                                                                          .currentUser!
                                                                          .id;
                                                                  final serviceproviderid =
                                                                      additionalProfileData[
                                                                          'id'];
                                                                  _deleteSavedSearch(
                                                                      userid,
                                                                      serviceproviderid);
                                                                },
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.sizeOf(
                                                                            context)
                                                                        .height *
                                                                    0.0125,
                                                              )
                                                            ],
                                                          );
                                                        }
                                                      });
                                                }));
                                      }
                                    },
                                  )
                                ],
                              )),
                          Visibility(
                            visible:
                                isSearching, // Content is visible when typing searching
                            child: Positioned(
                              child: Container(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.95,
                                color: Colors.transparent,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.05),
                                    Text(
                                      '$searchchoice(s)',
                                      style: responsiveTextStyle(
                                          context, 20, null, FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.025),
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
                                                    height: MediaQuery.sizeOf(
                                                                context)
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
                                                    height: MediaQuery.sizeOf(
                                                                context)
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

                                                return Column(
                                                  children: [
                                                    ServiceProviderCard(
                                                      saved: false,
                                                      name:
                                                          additionalProfileData[
                                                              'full_name'],
                                                      bio: serviceProviderData[
                                                          'bio'],
                                                      // view profile
                                                      onPressedButton1: () {
                                                        // Implement the action for Button 1 here.
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                ViewProfilePage(
                                                              availability:
                                                                  serviceProviderData[
                                                                      'availability'],
                                                              experience:
                                                                  serviceProviderData[
                                                                      'experience'],
                                                              fbLink:
                                                                  serviceProviderData[
                                                                      'fb_url'],
                                                              fullname:
                                                                  additionalProfileData[
                                                                      'full_name'],
                                                              igLink:
                                                                  serviceProviderData[
                                                                      'ig_url'],
                                                              mailLink:
                                                                  serviceProviderData[
                                                                      'gmail_link'],
                                                              media1: serviceProviderData[
                                                                  'media_url1'],
                                                              media2: serviceProviderData[
                                                                  'media_url2'],
                                                              media3: serviceProviderData[
                                                                  'media_url3'],
                                                              pfp: additionalProfileData[
                                                                  'avatar_url'],
                                                              specialoffers:
                                                                  serviceProviderData[
                                                                      'special_offers'],
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
                                                            .auth
                                                            .currentUser!
                                                            .id;
                                                        final serviceproviderid =
                                                            additionalProfileData[
                                                                'id'];
                                                        _createSavedSearch(
                                                            userid,
                                                            serviceproviderid);
                                                      },
                                                      isOnline: Online(
                                                          userId:
                                                              serviceProviderData[
                                                                  'id']),
                                                      guest: false,
                                                      img: serviceProviderData[
                                                          'media_url1'],
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
            ],
          ),
        ),
      ),
    );
  }
}
