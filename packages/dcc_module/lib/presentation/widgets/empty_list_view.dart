/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 07/08/2025
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EmptyListView extends StatelessWidget {
  const EmptyListView({super.key, required this.emptyText});
  final String emptyText;



  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              width: 135,
              height: 135,
              'assets/svgs/empty_list_sky_blue.svg',
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
