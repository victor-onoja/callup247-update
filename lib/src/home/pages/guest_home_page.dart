import 'package:flutter/material.dart';
import '../../profile/pages/guest_profile_page.dart';
import '../../responsive_text_styles.dart';
import '../widgets/service_provider_card.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage>
    with SingleTickerProviderStateMixin {
  // init
  @override
  void initState() {
    super.initState();
    _acontroller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Adjust the duration as needed
    )..repeat(); // This will make the animation loop
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
  @override
  Widget build(BuildContext context) {
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
                                const CircleAvatar(
                                  backgroundImage:
                                      AssetImage('assets/guest_dp.png'),
                                  radius: 30,
                                ),
                                // end of customer pfp
                                PopupMenuButton(
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem(
                                        textStyle: responsiveTextStyle(context,
                                            16, Colors.black, FontWeight.bold),
                                        value: 'editProfile',
                                        child: const Text(
                                          'Edit Profile',
                                        ),
                                      ),
                                      PopupMenuItem(
                                        textStyle: responsiveTextStyle(context,
                                            16, Colors.black, FontWeight.bold),
                                        value: 'theme',
                                        child: const Text(
                                          'Theme',
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
                                        child:
                                            const Text('Terms and Conditions'),
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
                                    if (value == 'editProfile') {
                                      // Navigate to the edit profile screen
                                    } else if (value == 'theme') {
                                      // Navigate to the theme screen
                                    } else if (value == 'signOut') {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ],
                            ),
                            // customer name
                            Text(
                              'guestuser',
                              style: responsiveTextStyle(
                                  context, 16, Colors.white, FontWeight.bold),
                            ),
                            // end of customer name
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
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
                                      MediaQuery.sizeOf(context).height * 0.15),
                              Text(
                                'Saved Searches',
                                style: responsiveTextStyle(
                                    context, 20, null, FontWeight.bold),
                              ),
                              SizedBox(
                                  height: MediaQuery.sizeOf(context).height *
                                      0.0125),
                              // saved searches
                              ServiceProviderCard(
                                saved: true,
                                name: 'John Doe',
                                bio:
                                    'Experienced plumber with 5+ years of experience in fixing pipes.',
                                image: const AssetImage('assets/plumber.jpg'),
                                onPressedButton1: () {
                                  // Implement the action for Button 1 here.
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const GuestProfilePage(),
                                    ),
                                  );
                                },
                                isOnline: const Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                      size: 12,
                                    ),
                                  ],
                                ),
                                onPressedButton2: () {},
                                guest: true,
                                img: '',
                                distance: '17 mins away',
                              ),
                              SizedBox(
                                  height: MediaQuery.sizeOf(context).height *
                                      0.0125),
                              ServiceProviderCard(
                                saved: true,
                                name: 'Senior Centy',
                                bio:
                                    'Experienced barber with 5+ years of experience in cutting hair.',
                                image: const AssetImage('assets/barber.jpg'),
                                onPressedButton1: () {
                                  // Implement the action for Button 1 here.
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const GuestProfilePage(),
                                    ),
                                  );
                                },
                                isOnline: const Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                      size: 12,
                                    ),
                                  ],
                                ),
                                onPressedButton2: () {},
                                guest: true,
                                img: '',
                                distance: '45 mins away',
                              ),
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
                                    height: MediaQuery.sizeOf(context).height *
                                        0.05),
                                Text(
                                  '${searchchoice}s',
                                  style: responsiveTextStyle(
                                      context, 20, null, FontWeight.bold),
                                ),
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.0125),
                                ServiceProviderCard(
                                  saved: false,
                                  name: 'John Doe',
                                  bio:
                                      'Experienced plumber with 5+ years of experience in fixing pipes.',
                                  image: const AssetImage('assets/barber.jpg'),
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
                                  isOnline: const Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                    ],
                                  ), // Set whether the service provider is online or offline.
                                  guest: true,
                                  img: '', distance: '33 mins away',
                                ),
                                SizedBox(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.0125),
                                ServiceProviderCard(
                                  saved: false,
                                  name: 'Senior Centy',
                                  bio:
                                      'Experienced barber with 5+ years of experience in cutting hair.',
                                  image: const AssetImage('assets/barber.jpg'),
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
                                  isOnline: const Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                    ],
                                  ), // Set whether the service provider is online or offline.
                                  guest: true,
                                  img: '', distance: '36 mins away',
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
      ),
    );
  }
}
