# Let me go

This application has been made during the lockdown period in Cyprus in April 2020 when everyone
has to get permission to go out. The automated SMS system has been made by the Government. 

This application helps to compose an SMS message with the permission request.

Three languages are supported: Greek, English, Russian.

## Demo

A demo is hosted on GitHub Pages: https://lalex.github.io/let-me-go

Better to view in the mobile browser.

## Privacy Policy

As the application deals with Geolocation and personal ID number it doesn't store or transmit
such data in any form. There is no server-side or on-device storage.

## Tech specs

### Flutter

The application is made with the Flutter framework (Dart language) 
and it's built as a web-application.

### Geolocation

The application uses a `getCurrentPosition()` browser's method to get the current location of the device.

To obtain a postal code number there is a set of predefined polygons of each postal code area.
The set is sorted by the distance to the current location. Then every area starting from the nearest 
is checked if it contains the current Geo location point. So all positioning operations are made
at the device with no server requests.
