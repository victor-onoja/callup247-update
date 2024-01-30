import 'dart:convert';
import 'dart:io';
import 'package:callup247/src/home/pages/serviceprovider_homepage.dart';
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

  Future<void> _pickImage1() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image1 = File(pickedFile.path);
      });
    }
  }

  // 02A - use case pick image2

  Future<void> _pickImage2() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image2 = File(pickedFile.path);
      });
    }
  }

  // 02B - use case pick image3

  Future<void> _pickImage3() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image3 = File(pickedFile.path);
      });
    }
  }

  // 03 - use case check network

  Future<bool> _checkInternetConnectivity() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

// variables

  final searchFocusNode = FocusNode();
  final TextEditingController _serviceProvidedController =
      TextEditingController();
  List<String> filteredServices = []; // Initialize it as an empty list
  String searchchoice = '';
  File? _image1;
  File? _image2;
  File? _image3;
  bool isTyping = false; // Initially, the user is not typing
  bool isSearching = false; // Initially the user is not searching
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _availabilityController = TextEditingController();
  final TextEditingController _specialOffersController =
      TextEditingController();
  String emailaddress = '';
  String fullname = '';
  var loading = false;

  // dispose

  @override
  void dispose() {
    _instagramController.dispose();
    _xController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    _gmailController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _availabilityController.dispose();
    _specialOffersController.dispose();
    super.dispose();
  }

  // 04 - use case upload image1

  Future<void> _uploadImage1() async {
    try {
      await supabase.storage.from('media1').upload(
            fullname,
            _image1!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      if (mounted) {}
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    }
  }

  // 04B - use case upload image2

  Future<void> _uploadImage2() async {
    try {
      await supabase.storage.from('media2').upload(
            fullname,
            _image2!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      if (mounted) {}
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    }
  }

  // 04C - use case upload image3

  Future<void> _uploadImage3() async {
    try {
      await supabase.storage.from('media3').upload(
            fullname,
            _image3!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      if (mounted) {}
    } on PostgrestException catch (error) {
      //
    } catch (error) {
      //
    }
  }

  // init

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // 05 - use case initialize data

  Future<void> _initializeData() async {
    final prefs = await SharedPreferences.getInstance();
    final userProfileJson = prefs.getString('userprofile');
    final serviceProvider = prefs.getString('serviceproviderprofile');
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
  }

  // 06 - create service provider profile

  Future<void> _createServiceProviderProfile() async {
    final serviceprovided = _serviceProvidedController.text.trim();
    final media1 = supabase.storage.from('media1').getPublicUrl(fullname);
    final media2 = supabase.storage.from('media2').getPublicUrl(fullname);
    final media3 = supabase.storage.from('media3').getPublicUrl(fullname);
    final ig = _instagramController.text.trim();
    final x = _xController.text.trim();
    final fb = _facebookController.text.trim();
    final web = _websiteController.text.trim();
    final gmail = emailaddress;
    final bio = _bioController.text.trim();
    final experience = _experienceController.text.trim();
    final availability = _availabilityController.text.trim();
    final specialoffers = _specialOffersController.text.trim();

    final user = supabase.auth.currentUser;

    final details = {
      'id': user!.id,
      'created_at': DateTime.now().toIso8601String(),
      'service_provided': serviceprovided,
      'media_url1': media1,
      'media_url2': media2,
      'media_url3': media3,
      'ig_url': ig,
      'x_url': x,
      'fb_url': fb,
      'web_link': web,
      'gmail_link': gmail,
      'bio': bio,
      'experience': experience,
      'availability': availability,
      'special_offers': specialoffers,
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

  // 07 - use save service provider profile locally

  Future<void> _saveServiceProviderProfilelocally() async {
    final serviceprovided = _serviceProvidedController.text.trim();
    final media1 = supabase.storage.from('media1').getPublicUrl(fullname);
    final media2 = supabase.storage.from('media2').getPublicUrl(fullname);
    final media3 = supabase.storage.from('media3').getPublicUrl(fullname);
    final ig = _instagramController.text.trim();
    final x = _xController.text.trim();
    final fb = _facebookController.text.trim();
    final web = _websiteController.text.trim();
    final gmail = emailaddress;
    final bio = _bioController.text.trim();
    final experience = _experienceController.text.trim();
    final availability = _availabilityController.text.trim();
    final specialoffers = _specialOffersController.text.trim();

    final details = {
      'service_provided': serviceprovided,
      'media_url1': media1,
      'media_url2': media2,
      'media_url3': media3,
      'ig_url': ig,
      'x_url': x,
      'fb_url': fb,
      'web_link': web,
      'gmail_link': gmail,
      'bio': bio,
      'experience': experience,
      'availability': availability,
      'special_offers': specialoffers,
    };

    final jsonString = json.encode(details);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('serviceproviderprofile', jsonString);
  }

// build method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
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
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Set up your Profile',
                        style: responsiveTextStyle(
                            context, 20, Colors.black, FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),

                  // add service

                  Text(
                    'What Service will you be providing ?',
                    style: responsiveTextStyle(context, 20, Colors.black, null),
                  ),
                  Text(
                    'hint: this can\'t be changed later, only through customer care :)',
                    style:
                        responsiveTextStyle(context, 12, Colors.black45, null),
                  ),

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _serviceProvidedController,
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
                                "Sorry, we don't have this service currently. Please pick a registered service.",
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

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),

                  // add media

                  Text(
                    'Add Media :',
                    style: responsiveTextStyle(context, 20, Colors.black, null),
                  ),
                  Text(
                    'hint: you can add up to three images that showcase your work :)',
                    style:
                        responsiveTextStyle(context, 12, Colors.black45, null),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // image 1
                        Container(
                          color: Colors.black45,
                          height: 250,
                          width: 250,
                          child: GestureDetector(
                            onTap: () {
                              _pickImage1();
                            },
                            child: Column(
                              children: <Widget>[
                                if (_image1 != null)
                                  Image.file(
                                    _image1!,
                                    height: 250,
                                    width: 250,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  const Icon(
                                    Icons.camera_alt,
                                    size: 250,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.025),
                        // image 2
                        Container(
                          color: Colors.black45,
                          height: 250,
                          width: 250,
                          child: GestureDetector(
                            onTap: () {
                              _pickImage2();
                            },
                            child: Column(
                              children: <Widget>[
                                if (_image2 != null)
                                  Image.file(
                                    _image2!,
                                    height: 250,
                                    width: 250,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  const Icon(
                                    Icons.camera_alt,
                                    size: 250,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.025),
                        // image 3
                        Container(
                          color: Colors.black45,
                          height: 250,
                          width: 250,
                          child: GestureDetector(
                            onTap: () {
                              _pickImage3();
                            },
                            child: Column(
                              children: <Widget>[
                                if (_image3 != null)
                                  Image.file(
                                    _image3!,
                                    height: 250,
                                    width: 250,
                                    fit: BoxFit.cover,
                                  )
                                else
                                  const Icon(
                                    Icons.camera_alt,
                                    size: 250,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),

                  Text(
                      'hint: you can always edit your profile from your hoemepage... if you don\'t have all your details now just hit submit and provide them later :)',
                      style: responsiveTextStyle(
                          context, 12, Colors.black45, null)),

                  // add social links

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                  Text(
                    'Add Your Social links :',
                    style: responsiveTextStyle(context, 20, Colors.black, null),
                  ),
                  Text(
                      'hint: click on the app icons for easy navigation to share your proile :)',
                      style: responsiveTextStyle(
                          context, 12, Colors.black45, null)),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                  Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final Uri url =
                                  Uri.parse('https://www.instagram.com/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {}
                            },
                            child: Image.asset(
                              'assets/ig-icon.png',
                              width: 25,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Text('Instagram :',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null)),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Flexible(
                            child: TextField(
                              controller: _instagramController,
                              style: responsiveTextStyle(
                                  context, 16, Colors.white, null),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse('https://twitter.com/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {}
                            },
                            child: Image.asset(
                              'assets/x-icon.webp',
                              width: 25,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Text('X :',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null)),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Flexible(
                            child: TextField(
                              controller: _xController,
                              style: responsiveTextStyle(
                                  context, 16, Colors.white, null),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  'https://web.facebook.com/?_rdc=1&_rdr');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {}
                            },
                            child: Image.asset(
                              'assets/facebook.png',
                              width: 25,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Text('Facebook :',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null)),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Flexible(
                            child: TextField(
                              controller: _facebookController,
                              style: responsiveTextStyle(
                                  context, 16, Colors.white, null),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final Uri url =
                                  Uri.parse('https://www.google.com/');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {}
                            },
                            child: Image.asset(
                              'assets/web-icon.png',
                              width: 25,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Text('Website :',
                              style: responsiveTextStyle(
                                  context, 16, Colors.black, null)),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02),
                          Flexible(
                            child: TextField(
                              controller: _websiteController,
                              style: responsiveTextStyle(
                                  context, 16, Colors.white, null),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),

                  // add details

                  Text(
                    'Add Your Details :',
                    style: responsiveTextStyle(context, 20, Colors.black, null),
                  ),
                  Text(
                    'hint: you can be as expressive as you like :)',
                    style:
                        responsiveTextStyle(context, 12, Colors.black45, null),
                  ),
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
                  Row(
                    children: [
                      Text('Bio :',
                          style: responsiveTextStyle(
                              context, 16, Colors.black, null)),
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                      Flexible(
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: _bioController,
                          style: responsiveTextStyle(
                              context, 16, Colors.white, null),
                          decoration: const InputDecoration(
                            hintText:
                                'E.g Experienced plumber with 5+ years of experience in fixing pipes.',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Experience :',
                          style: responsiveTextStyle(
                              context, 16, Colors.black, null)),
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                      Flexible(
                        child: TextField(
                          controller: _experienceController,
                          style: responsiveTextStyle(
                              context, 16, Colors.white, null),
                          decoration: const InputDecoration(
                            hintText: 'E.g 5+ years',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Availability :',
                          style: responsiveTextStyle(
                              context, 16, Colors.black, null)),
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                      Flexible(
                        child: TextField(
                          controller: _availabilityController,
                          style: responsiveTextStyle(
                              context, 16, Colors.white, null),
                          decoration: const InputDecoration(
                            hintText: 'E.g 9am - 5pm, Mon - Sat',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          'hint: you can let customers know if you\'re available or not by tapping available on your profile :)',
                          style: responsiveTextStyle(
                              context, 12, Colors.black45, null),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Special Offers :',
                          style: responsiveTextStyle(
                              context, 16, Colors.black, null)),
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.02),
                      Flexible(
                        child: TextField(
                          controller: _specialOffersController,
                          style: responsiveTextStyle(
                              context, 16, Colors.white, null),
                          decoration: const InputDecoration(
                            hintText: 'E.g 20% off till Jan 2024',
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.06),

                  // submit button

                  Center(
                    child: loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              // prevent unregistered services
                              if (isTyping ||
                                  _serviceProvidedController.text.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    'Please pick a registered service :(',
                                    style: responsiveTextStyle(context, 16,
                                        Colors.black, FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                                setState(() {
                                  loading = false;
                                });
                                return;
                              }
                              // Check network connectivity
                              bool isConnected =
                                  await _checkInternetConnectivity();
                              if (!isConnected) {
                                if (!context.mounted) return;
                                // Show a snackbar for no network
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                    'No internet connection. Please check your network settings.',
                                    style: responsiveTextStyle(context, 16,
                                        Colors.black, FontWeight.bold),
                                  ),
                                  backgroundColor: Colors.red,
                                ));
                                setState(() {
                                  loading = false;
                                });
                                return; // Exit the function if there's no network
                              }

                              // todo: make this one request
                              try {
                                if (_image1 != null) {
                                  await _uploadImage1();
                                }
                                if (_image2 != null) {
                                  await _uploadImage2();
                                }
                                if (_image3 != null) {
                                  await _uploadImage3();
                                }

                                await _becomeAServiceProvider();
                                await _createServiceProviderProfile();
                                await _saveServiceProviderProfilelocally();

                                await Future.delayed(
                                    const Duration(seconds: 2));
                                if (!context.mounted) return;
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const ServiceProviderHomePage()),
                                );
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
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
                              'Submit',
                              style: responsiveTextStyle(
                                  context, 14, Colors.black, FontWeight.bold),
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
