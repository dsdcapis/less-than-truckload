# eBOL

In July 2023, the NMFTA Digital LTL Council announced the first-of-its kind eBOL API standard to improve supply chain efficiency for the LTL industry. This standard reduces costs & errors and improves overall communication and service.

## FAQs

### How do I identify the purpose of the API request?

There are two possible ways, as of current versions, to determine the purpose:

- (RECOMMENDED) Align your purpose with the HTTP verbs used in RESTful API transactions. Use a POST verb to create a BOL request, use a PUT verb to update a BOL request, and use a DELETE verb to cancel/delete a BOL request.
- Use a single POST call and describe intent in the "function" variable. Valid values are CREATE, UPDATE, and DELETE; however this use is discouraged in favor of RESTful API best practices.

### How do I reject a BOL for bad data?

It is recommended that when you are rejecting a BOL for bad data, your code returns a 400 error to the API consumer. To accomplish this, use one of the following options:

- Use the standard’s error responses in the error response payload; or,
- Append custom errors as needed for your implementation.

The programming stack you are using determines how your API returns error messages. Microsoft .NET Core Web API lets you pass an object or array of objects to its BadRequest response. Java Spring Boot or NodeJS contain a variety of mechanisms for easily returning meaningful HTTP 400 error messages in a RESTful API implementation.

If a BOL cannot be found when using DELETE or UPDATE requests, we also recommend returning a HTTP 404 response rather than a 400.

### Are there examples of the eBOL API usage available?

Yes. See the NMFTA eBOL website at https://digitalltl.nmfta.org for details beginning with version 2.0.2.

### Can non-required fields be nullable?

The OpenAPI 2.0 specification supports nulls. See https://swagger.io/specification/v2 for details on usage.

Ensure your development stack marks up nullable fields accordingly.