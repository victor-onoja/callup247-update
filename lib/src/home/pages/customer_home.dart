import 'dart:convert';
import 'dart:io';
import 'package:callup247/main.dart';
import 'package:callup247/src/authentication/pages/user_login.dart';
import 'package:callup247/src/profile/pages/serviceprovider_profile_creation_page.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../profile/pages/guest_profile_page.dart';
import '../../responsive_text_styles.dart';
import '../widgets/service_provider_card.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  // use case initialize data

  Future<void> _initializeData() async {
    _acontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Adjust the duration as needed
    )..repeat(); // This will make the animation loop
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    if (userProfileJson != null) {
      final userProfileMap = json.decode(userProfileJson);
      // To access specific fields like full name and email address:
      final userFullName = userProfileMap['fullname'];
      final userPfp = userProfileMap['displaypicture'];
      setState(() {
        fullname = userFullName;
        pfp = userPfp;
      });
      // You can now use fullName and emailAddress as needed.
    } else {
      // Handle the case where no user profile data is found in SharedPreferences.
      // error in signup, please go back to signup ==> snackbar
      print('no data found');
    }
  }

  // use case update user information online and locally (location change)
  Future<void> _updateUserLocation() async {
    final country = countryValue as String;
    final state = stateValue as String;
    final city = cityValue;
    final displaypicture =
        supabase.storage.from('avatars').getPublicUrl(fullname);
    final user = supabase.auth.currentUser;
    final details = {
      'id': user!.id,
      'updated_at': DateTime.now().toIso8601String(),
      'full_name': fullname,
      'country': country,
      'state': state,
      'city': city,
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
      print(error.message + 'update profile');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      print(error);
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

      userProfileMap['country'] = country;
      userProfileMap['state'] = state;
      userProfileMap['city'] = city;

      // Convert the updated user data back to a JSON string
      final updatedUserProfileJson = json.encode(userProfileMap);

      // Save the updated user data back to shared preferences
      await prefs.setString('userprofile', updatedUserProfileJson);
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

  // use case display userpfp

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
    final filename = fullname;
    try {
      // print('upload image start');
      // print(filename);
      // print(_image);
      await supabase.storage.from('avatars').update(
            filename,
            _image!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
      if (mounted) {
        // print('img uploaded');
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
      // print('postgres error: ${error.message}');
    } catch (error) {
      // print(error);
    }
  }

  // use case sign out

  Future<void> _signOut() async {
    try {
      await supabase.auth.signOut();
      if (mounted) {
        // navigate
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const SignIn()));
      }
    } on PostgrestException catch (error) {
      print(error.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Server Error, Please try again in a bit :)',
          style:
              responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ));
    } catch (error) {
      print(error);
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
    super.dispose();
  }

  // variables
  late AnimationController _acontroller;
  final searchFocusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  List<String> filteredServices = []; // Initialize it as an empty list
  String searchchoice = '';
  bool isTyping = false; // Initially, the user is not typing
  bool isSearching = false; // Initially the user is not searching
  String fullname = '';
  String pfp = '';
  File? _image;
  bool pfpChange = false;
  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
            child: FocusScope(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RotationTransition(
                        turns:
                            Tween(begin: 0.0, end: 1.0).animate(_acontroller),
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
                                          // print('object');

                                          return CircleAvatar(
                                            backgroundImage: snapshot.data,
                                            radius: 30,
                                          );
                                        } else {
                                          // While the future is loading, you can show a placeholder or loading indicator
                                          return const CircularProgressIndicator(); // or any other placeholder widget
                                        }
                                      },
                                    ),

                              // end of customer pfp
                              PopupMenuButton(
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem(
                                      textStyle: responsiveTextStyle(context,
                                          16, Colors.black, FontWeight.bold),
                                      value: 'changeDisplayPicture',
                                      child: const Text(
                                        'Change Display Picture',
                                      ),
                                    ),
                                    PopupMenuItem(
                                      textStyle: responsiveTextStyle(context,
                                          16, Colors.black, FontWeight.bold),
                                      value: 'editLocation',
                                      child: const Text(
                                        'Edit Location',
                                      ),
                                    ),
                                    PopupMenuItem(
                                      textStyle: responsiveTextStyle(context,
                                          16, Colors.black, FontWeight.bold),
                                      value: 'becomeAServiceProvider',
                                      child: const Text(
                                        'Become a Service Provider',
                                      ),
                                    ),
                                    PopupMenuItem(
                                      textStyle: responsiveTextStyle(context,
                                          16, Colors.black, FontWeight.bold),
                                      value: 'customerCare',
                                      child: const Text('Customer Care'),
                                    ),
                                    PopupMenuItem(
                                      textStyle: responsiveTextStyle(context,
                                          16, Colors.black, FontWeight.bold),
                                      value: 'termsAndConditions',
                                      child: const Text('Terms and Conditions'),
                                    ),
                                    PopupMenuItem(
                                      textStyle: responsiveTextStyle(context,
                                          16, Colors.black, FontWeight.bold),
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
                                              mainAxisSize: MainAxisSize.min,
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
                                                      Navigator.pop(context);
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: const Text(
                                                                  'Here\'s your image :)'),
                                                              content:
                                                                  Image.file(
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
                                                  child: const Text('Refresh')),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'))
                                            ],
                                          );
                                        });
                                  } else if (value == 'editLocation') {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Set your new Location'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CSCPicker(
                                                  flagState: CountryFlag
                                                      .SHOW_IN_DROP_DOWN_ONLY,
                                                  dropdownDecoration:
                                                      BoxDecoration(
                                                          color:
                                                              const Color(
                                                                  0xFF13CAF1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6)),
                                                  disabledDropdownDecoration:
                                                      BoxDecoration(
                                                          color: const Color(
                                                              0xFF039fdc),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6)),
                                                  selectedItemStyle:
                                                      responsiveTextStyle(
                                                          context,
                                                          14,
                                                          Colors.black,
                                                          null),
                                                  onCountryChanged: (value) {
                                                    // Handle the selected country value here.
                                                    setState(() {
                                                      // Store the selected country value in a variable.
                                                      countryValue = value;
                                                    });
                                                  },
                                                  onStateChanged: (value) {
                                                    // Handle the selected state value here.
                                                    setState(() {
                                                      // Store the selected state value in a variable.
                                                      stateValue = value;
                                                    });
                                                  },
                                                  onCityChanged: (value) {
                                                    // Handle the selected city value here.
                                                    setState(() {
                                                      // Store the selected city value in a variable.
                                                      cityValue = value;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    _updateUserLocation();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Confirm')),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel'))
                                            ],
                                          );
                                        });
                                  } else if (value == 'signOut') {
                                    _signOut();
                                  } else if (value ==
                                      'becomeAServiceProvider') {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const ServiceProviderProfileCreation()),
                                    );
                                  }
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
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
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
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              filteredServices[index],
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, FontWeight.bold),
                            ),
                            onTap: () {
                              // Handle user selection here.
                              FocusScope.of(context).unfocus();
                              setState(() {
                                isSearching = true;
                                // When tile is tapped, set isTyping to false
                                isTyping = false;
                                searchchoice = filteredServices[index];
                                _controller.text = filteredServices[index];

                                // Update the filtered services here as well
                                filteredServices = [];
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
                                    MediaQuery.of(context).size.height * 0.15),
                            Text(
                              'Saved Searches',
                              style: responsiveTextStyle(
                                  context, 20, null, FontWeight.bold),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.0125),
                            Image.asset('assets/search.png'),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.0125),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No saved search yet?\nStart searching now',
                                  style: responsiveTextStyle(
                                      context, 16, Colors.black, null),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                            // saved searches
                            // ServiceProviderCard(
                            //   saved: true,
                            //   name: 'John Doe',
                            //   bio:
                            //       'Experienced plumber with 5+ years of experience in fixing pipes.',
                            //   image: 'assets/plumber.jpg',
                            //   onPressedButton1: () {
                            //     // Implement the action for Button 1 here.
                            //     Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //         builder: (BuildContext context) =>
                            //             const GuestProfilePage(),
                            //       ),
                            //     );
                            //   },

                            //   isOnline:
                            //       true, // Set whether the service provider is online or offline.
                            // ),
                            // SizedBox(
                            //     height: MediaQuery.of(context).size.height *
                            //         0.0125),
                            // ServiceProviderCard(
                            //   saved: true,
                            //   name: 'Senior Centy',
                            //   bio:
                            //       'Experienced barber with 5+ years of experience in cutting hair.',
                            //   image: 'assets/barber.jpg',
                            //   onPressedButton1: () {
                            //     // Implement the action for Button 1 here.
                            //     Navigator.of(context).push(
                            //       MaterialPageRoute(
                            //         builder: (BuildContext context) =>
                            //             const GuestProfilePage(),
                            //       ),
                            //     );
                            //   },
                            //   isOnline:
                            //       false, // Set whether the service provider is online or offline.
                            // ),
                            // end of saved search
                          ],
                        )),
                    Visibility(
                      visible:
                          isSearching, // Content is visible when typing searching
                      child: Positioned(
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.05),
                              Text(
                                '${searchchoice}s',
                                style: responsiveTextStyle(
                                    context, 20, null, FontWeight.bold),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.0125),
                              ServiceProviderCard(
                                saved: false,
                                name: 'John Doe',
                                bio:
                                    'Experienced plumber with 5+ years of experience in fixing pipes.',
                                image: 'assets/plumber.jpg',
                                onPressedButton1: () {
                                  // Implement the action for Button 1 here.
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const GuestProfilePage(),
                                    ),
                                  );
                                },
                                onPressedButton2: () {
                                  // Implement the action for Button 2 here.
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
                                isOnline:
                                    true, // Set whether the service provider is online or offline.
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.0125),
                              ServiceProviderCard(
                                saved: false,
                                name: 'Senior Centy',
                                bio:
                                    'Experienced barber with 5+ years of experience in cutting hair.',
                                image: 'assets/barber.jpg',
                                onPressedButton1: () {
                                  // Implement the action for Button 1 here.
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const GuestProfilePage(),
                                    ),
                                  );
                                },
                                onPressedButton2: () {
                                  // Implement the action for Button 2 here.
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
                                isOnline:
                                    false, // Set whether the service provider is online or offline.
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
      ),
    );
  }
}
