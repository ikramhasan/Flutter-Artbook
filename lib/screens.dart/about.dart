import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:universal_html/html.dart' as html;

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String githubUrl = 'https://github.com/ikramhasan';
    final String facebookUrl = 'https://www.facebook.com/ihni7/';
    final String twitterUrl = 'https://twitter.com/ikramhasandev';
    final String redditUrl = 'https://www.reddit.com/user/ikramhasan';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF444974),
        elevation: 0,
        title: Text(
          'About',
          style: GoogleFonts.quicksand(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          color: Color(0xFF2D2F41),
          child: Column(
            children: [
              SizedBox(height: 30),
              Text(
                'List curation and app development was done by',
                style: GoogleFonts.quicksand(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEAECFF),
                ),
              ),
              SizedBox(height: 100),
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(width: 10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset('assets/author.jpg'),
              ),
              SizedBox(height: 15),
              Text(
                'Ikram Hasan',
                style: GoogleFonts.quicksand(fontSize: 32),
              ),
              SizedBox(height: MediaQuery.of(context).size.height/2 - 300),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'All design credits can be found ',
                    style: GoogleFonts.quicksand(fontSize: 22),
                  ),
                  InkWell(
                    onTap: () {
                      html.window.open(
                          'https://github.com/ikramhasan/Flutter-Artbook/blob/master/README.md',
                          'Credits');
                    },
                    child: Text(
                      '[here]',
                      style: GoogleFonts.quicksand(
                        fontSize: 22,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Socials',
                style: GoogleFonts.quicksand(fontSize: 22),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      html.window.open(githubUrl, 'GitHub');
                    },
                    child: FaIcon(
                      FontAwesomeIcons.github,
                      size: 40,
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      html.window.open(facebookUrl, 'FaceBook');
                    },
                    child: FaIcon(
                      FontAwesomeIcons.facebook,
                      size: 40,
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      html.window.open(twitterUrl, 'Twitter');
                    },
                    child: FaIcon(
                      FontAwesomeIcons.twitter,
                      size: 40,
                    ),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      html.window.open(redditUrl, 'Reddit');
                    },
                    child: FaIcon(
                      FontAwesomeIcons.reddit,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
