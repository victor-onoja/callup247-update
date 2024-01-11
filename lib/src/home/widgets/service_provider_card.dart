import 'package:flutter/material.dart';
import '../../responsive_text_styles.dart';

class ServiceProviderCard extends StatelessWidget {
  final String name;
  final String bio;
  final ImageProvider? image;
  final String img;
  final Function() onPressedButton1;
  final Function() onPressedButton2;
  final Widget isOnline;
  final bool saved;
  final bool guest;

  const ServiceProviderCard(
      {super.key,
      required this.name,
      required this.bio,
      this.image,
      required this.onPressedButton1,
      required this.onPressedButton2,
      required this.isOnline,
      required this.saved,
      required this.guest,
      required this.img});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black, width: 2),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF039fdc), Color(0xFF13CAF1)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style:
                        responsiveTextStyle(context, 18, Colors.white, null)),
                isOnline
              ],
            ),
            const SizedBox(height: 2),
            Center(
                child: guest
                    ? Image(
                        image: image!,
                      )
                    : Image.network(
                        img,
                        loadingBuilder: (context, child, loadingProgress) {
                          final totalBytes =
                              loadingProgress?.expectedTotalBytes;
                          final bytesLoaded =
                              loadingProgress?.cumulativeBytesLoaded;
                          if (totalBytes != null && bytesLoaded != null) {
                            return CircularProgressIndicator(
                              backgroundColor: Colors.white70,
                              value: bytesLoaded / totalBytes,
                              color: Colors.blue[900],
                              strokeWidth: 5.0,
                            );
                          } else {
                            return child;
                          }
                        },
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeOut,
                            child: child,
                          );
                        },
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/logo_t.png',
                                height: 75,
                              ),
                              const SizedBox(
                                height: 10, // Adjust the size as needed
                              ),
                              const Text(
                                'Error loading Image. Please try again.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      )),
            const SizedBox(height: 2),
            Text(bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: responsiveTextStyle(context, 16, Colors.white, null)),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF039fdc)),
                  onPressed: onPressedButton1,
                  child: const Text('View Profile'),
                ),
                saved
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF039fdc)),
                        onPressed: onPressedButton2,
                        child: const Text('Remove Saved'))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF039fdc)),
                        onPressed: onPressedButton2,
                        child: const Text('Add to Saved'))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
