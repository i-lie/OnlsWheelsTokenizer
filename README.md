OnlsWheelsTokenizer
===================

CFWheels plugin to prevent Cross-Site Request Forgery (CSRF) attack.
It uses the [tokenizer](http://tokenizer.riaforge.org/)

# Usage overview:
1. Call the onlsWTCreateCSRFToken()
2. Inside your form, call onlsWTDisplayCSRFTokenAsFormInput()
3. In your controller, validate the token using onlsWTValidateCSRFToken()
4. At the end, remove the token using onlsWTRemoveCSRFToken()

For more details, see [Wiki page](https://github.com/i-lie/OnlsWheelsTokenizer/wiki)

# History

version 0.0.3
* Add a helper functions onlsWTLinkTo and onlsWTStartFormTag for linkTo and startFormTag functions
* Add onlsWTAddCSRFMetaTags to create the meta tags for RemoteFormHelpers plugin
