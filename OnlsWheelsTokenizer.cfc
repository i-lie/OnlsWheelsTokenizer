<cfcomponent accessors="true" output="false" persistent="false" mixin="controller,view">
	<cfparam name="application.onlsWheelsTokenizer.tokenName" type="string" default="token">
	<cfparam name="application.onlsWheelsTokenizer.tokenTimeout" default="300">
	<cfparam name="application.onlsWheelsTokenizer.inputName" default="csrf_token">

	<cffunction name="init">
		<cfset this.version = "1.1.8">
		<cfreturn this>
	</cffunction>

	<cffunction name="onlsWTCreateCSRFToken" access="public" returntype="void" output="false" hint="Create token">
		<cfargument name="tokenName" type="string" required="false" default="#onlsWTGetDefaultCSRFTokenName()#" hint="The token name">
		<cfargument name="tokenTimeout" type="numeric" required="false" default="#onlsWTGetDefaultCSRFTokenTimeout()#" hint="How long the token should last (in seconds)?">

		<cfset $onlsWTGetCSRFTokenizer().createToken(arguments.tokenName, arguments.tokenTimeout)>
	</cffunction>

	<cffunction name="onlsWTValidateCSRFToken" access="public" returntype="boolean" output="false" hint="check whether the token is valid or not">
		<cfargument name="token" type="string" required="true" hint="The token to be validated">
		<cfargument name="tokenName" type="string" required="false" default="#onlsWTGetDefaultCSRFTokenName()#" hint="The token name">

		<cfreturn $onlsWTGetCSRFTokenizer().checkToken(arguments.tokenName, arguments.token)>
	</cffunction>

	<cffunction name="onlsWTRemoveCSRFToken" access="public" returntype="void" output="false" hint="Remove the CSRF token">
		<cfargument name="tokenName" type="string" required="false" default="#onlsWTGetDefaultCSRFTokenName()#" hint="The token name">

		<cfset $onlsWTGetCSRFTokenizer().removeToken(arguments.tokenName)>
	</cffunction>

	<cffunction name="onlsWTLinkTo" access="public" returntype="string" output="false" hint="LinkTo function">
		<cfargument name="params" type="string" required="false" default="" hint="See @URLTo">
		<cfargument name="remote" type="boolean" required="false" default="false" hint="Parameter from RemoteFormHelpers plugin">
		<cfargument name="useCSRFToken" type="boolean" required="false" default="true" hint="Append the csrf token to link?">
		<cfargument name="csrfTokenName" type="string" required="false" default="#onlsWTGetDefaultCSRFTokenName()#" hint="The token name">
		<cfargument name="csrfParamName" type="string" required="false" default="#onlsWTGetDefaultCSRFInputName()#" hint="The param name. Default is using the default input name">

		<cfscript>
			var loc = {};

			$args(name: "onlsWTLinkTo", args: arguments);
		</cfscript>

		<cfif arguments.useCSRFToken>
			<!--- if this is an ajax called (from RemoteFormHelpers plugin), then we need to add the token as meta tags --->
			<cfif arguments.remote>

				<cfset onlsWTAddCSRFMetaTags(tokenName: arguments.csrfTokenName,
											inputName: arguments.csrfParamName)>

			<!--- for non-ajax link, we need to append the token to the url --->
			<cfelse>
				<!--- add ampersand at the end of params if it already exists --->
				<cfif Len(arguments.params)>
					<cfset arguments.params = arguments.params & "&">
				</cfif>

				<cfset arguments.params = arguments.params & onlsWTGetCSRFTokenAsURLParam()>
			</cfif>
		</cfif>

		<cfscript>
			// remove the new csrf arguments so it doesn't get passed to linkTo() function
			loc.skipArgs = "useCSRFToken,csrfTokenName,csrfParamName";

			// skip the remote argument if it isn't set
			if (!arguments.remote) loc.skipArgs = ListAppend(loc.skipArgs, "remote", ",");

			loc.iEnd = ListLen(loc.skipArgs, ",");
			for (loc.i = 1; loc.i <= loc.iEnd; loc.i++) {
				StructDelete(arguments, ListGetAt(loc.skipArgs, loc.i, ","));
			}

			return linkTo(argumentcollection: arguments);
		</cfscript>
	</cffunction>

	<cffunction name="onlsWTStartFormTag" access="public" returntype="string" output="false" hint="LinkTo function">
		<cfargument name="useCSRFToken" type="boolean" required="false" default="true" hint="Append the csrf token to link?">
		<cfargument name="csrfTokenName" type="string" required="false" default="#onlsWTGetDefaultCSRFTokenName()#" hint="The token name">
		<cfargument name="csrfParamName" type="string" required="false" default="#onlsWTGetDefaultCSRFInputName()#" hint="The param name. Default is using the default input name">

		<cfscript>
			var loc = {};

			$args(name: "onlsWTStartFormTag", args: arguments);

			loc.args = Duplicate(arguments);
			loc.skipArgs = "useCSRFToken,csrfTokenName,csrfParamName";
			loc.iEnd = ListLen(loc.skipArgs, ",");
			for (loc.i = 1; loc.i <= loc.iEnd; loc.i++) {
				StructDelete(loc.args, ListGetAt(loc.skipArgs, loc.i, ","));
			}

			loc.output = startFormTag(argumentcollection: loc.args);

			if (arguments.useCSRFToken) {
				loc.output = loc.output &
							onlsWTDisplayCSRFTokenAsFormInput(tokenName: arguments.csrfTokenName,
																inputName: arguments.csrfParamName);
			}

			return loc.output;
		</cfscript>
	</cffunction>

	<cffunction name="onlsWTDisplayCSRFTokenAsFormInput" access="public" returntype="string" output="false" hint="Display the CSRF token as html hidden input">
		<cfargument name="tokenName" type="string" required="false" default="#onlsWTGetDefaultCSRFTokenName()#" hint="The token name">
		<cfargument name="inputName" type="string" required="false" default="#onlsWTGetDefaultCSRFInputName()#" hint="The input name">

		<cfreturn $onlsWTGetCSRFTokenizer().writeTokenToPage(arguments.tokenName, inputName)>
	</cffunction>

	<cffunction name="onlsWTGetCSRFTokenAsURLParam" access="public" returntype="string" output="false" hint="Display the CSRF token as html hidden input">
		<cfargument name="tokenName" type="string" required="false" default="#onlsWTGetDefaultCSRFTokenName()#" hint="The token name">
		<cfargument name="inputName" type="string" required="false" default="#onlsWTGetDefaultCSRFInputName()#" hint="The input name">

		<cfreturn arguments.inputName & "=" & $onlsWTGetCSRFTokenizer().getTokenValue(arguments.tokenName)>
	</cffunction>

	<cffunction name="onlsWTAddCSRFMetaTags" access="public" returntype="void" output="false" hint="Add the CSRF meta tags. This is used for RemoteFormHelpers plugin.">
		<cfargument name="tokenName" type="string" required="false" default="#onlsWTGetDefaultCSRFTokenName()#" hint="The token name">
		<cfargument name="inputName" type="string" required="false" default="#onlsWTGetDefaultCSRFInputName()#" hint="The input name">

		<cfscript>
			var loc = {};

			// don't need to add the meta tags if it is already exists for the current request
			if (IsDefined("request.hasOnlsWTCSRFMetaTags") && YesNoFormat(request.hasOnlsWTCSRFMetaTags))
				return;

			// flag the request already has the CSRF meta tags
			request.hasOnlsWTCSRFMetaTags = true;

			// set the csrf-token (token value)
			loc.args = {
				name = "meta",
				attributes = {
					name = "csrf-token",
					content = $onlsWTGetCSRFTokenizer().getTokenValue(arguments.tokenName)
				},
				close = true
			};
			loc.output = $tag(argumentcollection: loc.args);

			// set the csrf-param (input name)
			loc.args.attributes = {
				name = "csrf-param",
				content = arguments.inputName
			};
			loc.output = loc.output & $tag(argumentcollection: loc.args);
		</cfscript>

		<cfhtmlhead text="#loc.output#">
	</cffunction>

	<cffunction name="onlsWTGetDefaultCSRFTokenName" access="public" returntype="string" output="false" hint="Get the default token name">
		<cfreturn application.onlsWheelsTokenizer.tokenName>
	</cffunction>

	<cffunction name="onlsWTGetDefaultCSRFTokenTimeout" access="public" returntype="numeric" output="false" hint="Get the default token timeout">
		<cfreturn Val(application.onlsWheelsTokenizer.tokenTimeout)>
	</cffunction>

	<cffunction name="onlsWTGetDefaultCSRFInputName" access="public" returntype="string" output="false" hint="Get the default token name">
		<cfreturn application.onlsWheelsTokenizer.inputName>
	</cffunction>

	<cffunction name="$onlsWTGetCSRFTokenizer" access="public" returntype="any" output="false" hint="">
		<cfreturn CreateObject("component", "tokenizer").init(session)>
	</cffunction>
</cfcomponent>