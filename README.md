OnlsWheelsTokenizer
===================

CFWheels plugin to prevent Cross-Site Request Forgery (CSRF) attack.
It uses the [tokenizer](http://tokenizer.riaforge.org/)

# Requires
1. [jQuery](http://jquery.com)
2. [jquery-ujs](https://github.com/rails/jquery-ujs)
Browse to "src" directory, copy "rails.js" to your CFWheels javascripts directory and include it in the layout

# Usage overview:
1. Call the onlsWTCreateCSRFToken()
2. In your layout file, call the onlsWTGetCSRFTokenAsMetaTags function inside the head tag
3. In your controller action where you want to validate, call onlsWTValidateCSRFToken()
4. At the end, remove the token using onlsWTRemoveCSRFToken()

For more details, see [Wiki page](https://github.com/i-lie/OnlsWheelsTokenizer/wiki)

# History

version 0.0.6
* Add the dependancy to jquery-ujs

version 0.0.3
* Add a helper functions onlsWTLinkTo and onlsWTStartFormTag for linkTo and startFormTag functions
* Add onlsWTAddCSRFMetaTags to create the meta tags for RemoteFormHelpers plugin
