import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/address_helper.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/address/providers/location_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/common/widgets/custom_button_widget.dart';
import 'package:flutter_grocery/common/widgets/custom_loader_widget.dart';
import 'package:flutter_grocery/features/address/widgets/search_dialog_widget.dart';
import 'package:flutter_grocery/common/widgets/web_app_bar_widget.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class SelectLocationScreen extends StatefulWidget {
  final GoogleMapController? googleMapController;
  const SelectLocationScreen({Key? key, required this.googleMapController})
      : super(key: key);

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapController? _controller;
  final TextEditingController _locationController = TextEditingController();
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();
    _initialPosition = LatLng(
      double.parse(Provider.of<SplashProvider>(context, listen: false)
          .configModel!
          .branches![0]
          .latitude!),
      double.parse(Provider.of<SplashProvider>(context, listen: false)
          .configModel!
          .branches![0]
          .longitude!),
    );
    Provider.of<LocationProvider>(context, listen: false).setPickData();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  void _openSearchDialog(
      BuildContext context, GoogleMapController? mapController) async {
    showDialog(
        context: context,
        builder: (context) => SearchDialogWidget(mapController: mapController));
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<LocationProvider>(context).address != null) {
      _locationController.text =
          Provider.of<LocationProvider>(context).address ?? '';
    }

    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(
              preferredSize: Size.fromHeight(120), child: WebAppBarWidget())
          : AppBar(
              backgroundColor: Theme.of(context).cardColor,
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.chevron_left,
                  size: 30,
                ),
              ),
              centerTitle: true,
              title: Text(
                getTranslated('select_location', context),
                style: poppinsSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            )) as PreferredSizeWidget?,
      body: Center(
        child: SizedBox(
          width: 1170,
          child: Consumer<LocationProvider>(
            builder: (context, locationProvider, child) => Stack(
              clipBehavior: Clip.none,
              children: [
                Stack(
                  children: [
                    GoogleMap(
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition,
                        zoom: 15,
                      ),
                      zoomControlsEnabled: false,
                      compassEnabled: false,
                      indoorViewEnabled: true,
                      mapToolbarEnabled: true,
                      style: "[]",
                      onCameraIdle: () {
                        locationProvider.updatePosition(
                            _cameraPosition, false, null, false);
                      },
                      onCameraMove: ((position) => _cameraPosition = position),
                      // markers: Set<Marker>.of(locationProvider.markers),
                      onMapCreated: (GoogleMapController controller) {
                        Future.delayed(const Duration(milliseconds: 800))
                            .then((value) {
                          _controller = controller;
                          _controller!.moveCamera(
                              CameraUpdate.newCameraPosition(CameraPosition(
                                  target: locationProvider
                                                  .pickPosition.longitude
                                                  .toInt() ==
                                              0 &&
                                          locationProvider.pickPosition.latitude
                                                  .toInt() ==
                                              0
                                      ? _initialPosition
                                      : LatLng(
                                          locationProvider
                                              .pickPosition.latitude,
                                          locationProvider
                                              .pickPosition.longitude,
                                        ),
                                  zoom: 15)));
                        });
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 320,
                        decoration: const BoxDecoration(
                          color: Color(0xFF133051),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(50),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              getTranslated(
                                "select_location",
                                context,
                              ),
                              style: poppinsMedium.copyWith(
                                fontSize: Dimensions.fontSizeOverLarge,
                                color: Colors.white,
                                letterSpacing: 1.1,
                                wordSpacing: 2,
                              ),
                            ),
                            locationProvider.pickAddress != null
                                ? SearchBarView(
                                    onTap: () =>
                                        _openSearchDialog(context, _controller))
                                : const SizedBox.shrink(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: CustomButtonWidget(
                                icon: Icons.my_location_rounded,
                                buttonText: getTranslated(
                                    'use_my_current_location', context),
                                onPressed: locationProvider.loading
                                    ? null
                                    : () {
                                        locationProvider.getCurrentLocation(
                                            context, false,
                                            mapController: _controller);
                                      },
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: CustomButtonWidget(
                                buttonText: getTranslated('confirm', context),
                                onPressed: locationProvider.loading
                                    ? null
                                    : () {
                                        if (widget.googleMapController !=
                                            null) {
                                          widget.googleMapController!
                                              .animateCamera(CameraUpdate
                                                  .newCameraPosition(
                                                      CameraPosition(
                                                          target: LatLng(
                                                            locationProvider
                                                                .pickPosition
                                                                .latitude,
                                                            locationProvider
                                                                .pickPosition
                                                                .longitude,
                                                          ),
                                                          zoom: 16)));

                                          if (ResponsiveHelper.isWeb()) {
                                            locationProvider
                                                .setAddAddressData(true);
                                          }
                                        }
                                        Navigator.of(context).pop();
                                      },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => AddressHelper.checkPermission(() {
                        locationProvider.getCurrentLocation(context, false,
                            mapController: _controller);
                      }),
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(
                            right: Dimensions.paddingSizeLarge),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              Dimensions.paddingSizeSmall),
                          color: Theme.of(context).cardColor,
                        ),
                        child: Icon(
                          Icons.my_location,
                          color: Theme.of(context).primaryColor,
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                    child: Icon(
                  Icons.location_on,
                  color: Theme.of(context).primaryColor,
                  size: 50,
                )),
                locationProvider.loading
                    ? Center(
                        child: CustomLoaderWidget(
                            color: Theme.of(context).primaryColor))
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchBarView extends StatelessWidget {
  final Function onTap;
  final double margin;
  const SearchBarView({
    Key? key,
    required this.onTap,
    this.margin = Dimensions.paddingSizeExtraLarge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
            vertical: Dimensions.paddingSizeDefault),
        margin: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge, vertical: margin),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
        ),
        child: Row(children: [
          Expanded(
              child: Text(
            locationProvider.pickAddress != null &&
                    locationProvider.pickAddress!.isNotEmpty
                ? locationProvider.pickAddress!
                : getTranslated('search_here', context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: poppinsMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          )),
          SvgPicture.asset('assets/svg/web.svg'),
        ]),
      ),
    );
  }
}


// Login
// Signup
// Home
// Product Details
// Wallet
// Whishlist
// Splash