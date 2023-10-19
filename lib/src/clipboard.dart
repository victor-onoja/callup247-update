// try {
    //   print(0);
    //   await supabase.from('customers').insert(details);
    //   if (mounted) {
    //     print('1');
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       content: Text(
    //         'Welcome to callup247',
    //         style:
    //             responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
    //       ),
    //       backgroundColor: Colors.green,
    //     ));
    //   }
    // } on PostgrestException catch (error) {
    //   print(error.message);
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(
    //       error.message,
    //       style:
    //           responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
    //     ),
    //     backgroundColor: Colors.red,
    //   ));
    // } catch (error) {
    //   print('3');
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(
    //       'Unexpected Error Occured',
    //       style:
    //           responsiveTextStyle(context, 16, Colors.black, FontWeight.bold),
    //     ),
    //     backgroundColor: Colors.red,
    //   ));
    // } finally {
    //   print(4);
    //   if (mounted) {
    //     print('5');
    //     setState(() {
    //       loading = false;
    //     });
    //   }
    // }

        // final AuthResponse res = await supabase.auth.signUp(
    //   email: 'example@email.com',
    //   password: 'example-password',
    // );
    // final Session? session = res.session;
    // final User? user = res.user;



// final displaypicture =
//     supabase.storage.from('avatars').getPublicUrl(_fullnameController.text);

// final details = {
//   'full_name': fullname,
//   'phone_number': phonenumber,
//   'email_address': emailaddress,
//   'country': country,
//   'state': state,
//   'city': city,
//   'home_address': homeaddress,
//   'password': password,
//   'display_picture': displaypicture
// };

// if (_formKey.currentState!.validate()) {
//                               _uploadImage();
//                               _signup(context);
//                             }



// use case sign up (create user and update customer table)
  // Future<void> _signup() async {
  //   setState(() {
  //     loading = true;
  //   });

  //   final fullname = _fullnameController.text.trim();
  //   final phonenumber = _phonenumberController.text.trim();
  //   final country = countryValue;
  //   final state = stateValue;
  //   final city = cityValue;
  //   final homeaddress = _homeadressController.text.trim();
  //   final password = _passwordController.text.trim();
  //   final emailaddress = _emailaddressController.text.trim();

  //   try {
  //     print('0');
  //     final AuthResponse res =
  //         await supabase.auth.signUp(password: password, email: emailaddress,phone: phonenumber);
  //     session = res.session;
  //     user = res.user;
  //     if (mounted) {
  //       print('1');
  //     }
  //   } on PostgrestException catch (error) {
  //     print(error.message);
  //   } catch (error) {
  //     print(error);
  //   } finally {
  //     print('4');
  //     if (mounted) {
  //       print('5');
  //       setState(() {
  //         loading = false;
  //       });
  //     }
  //   }
  // }