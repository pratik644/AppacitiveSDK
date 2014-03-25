Appacitive-iOS-SDK
==================

iOS client SDK for Appacitive platform.

---
# Documentation

##### Table of Contents  

* [Setup](#setup)  
* [Initialize](#initialize)  
* [Conventions](#conventions)  
* [Data storage and retrieval](#data-storage-and-retrieval)  
  * [Creating](#creating)  
  * [Retrieving](#retrieving)  
  * [Updating](#updating)  
  * [Deleting](#deleting)  
* [Connections](#connections)  
  * [Creating & Saving](#creating--saving)  
  * [Retrieving](#retrieving-1)  
 * [Get Connection by Id](#get-connection-by-id)  
 * [Get all Connections for an Endpoint Object Id](#get-all-connections-for-an-endpoint-object-id)
 * [Get Connected Objects](#get-connected-objects)  
 * [Get Connection by Endpoint Object Ids](#get-connection-by-endpoint-object-ids)  
 * [Get all connections between two Object Ids](#get-all-connections-between-two-object-ids)  
 * [Get Interconnections between one and multiple Object Ids](#get-interconnections-between-one-and-multiple-object-ids)
  * [Updating](#updating-1)  
  * [Deleting](#deleting-1)  
* [Queries](#queries)
  * [Modifiers](#modifiers)
* [Paging](#pagination)
* [Sorting](#sorting)
* [Fields](#fields)
* [Filter](#filter)
* [Geolocation](#geolocation)
  * [Radial Search](#radial-search)
  * [Polygon Search](#polygon-search)
* [Tag Based Searches](#tag-based-searches)
  * [Query data tagged with one or more of the given tags](#query-data-tagged-with-one-or-more-of-the-given-tags)
  * [Query data tagged with all of the given tags](#query-data-tagged-with-all-of-the-given-tags)
* [Composite Filters](#composite-filters)
* [FreeText](#freetext)
* [Graph Search](#graph-search)  
  * [Creating graph queries](#creating-graph-queries)  
  * [Executing Filter graph queries](#executing-filter-graph-queries)
  * [Executing projection graph queries](#executing-projection-graph-queries)  
* [User Management](#user-management)  
  * [Create](#create)  
  * [Retrieve](#retrieve)
  * [Update](#update)  
  * [Delete](#delete)  
  * [Authentication](#authentication)  
  * [User Session Management](#user-session-management)  
  * [Linking and Unlinking accounts](#linking-and-unlinking-accounts)  
  * [Password Management](#password-management)  
  * [Check-in](#check-in)  
* [Emails](#emails)  
  * [Configuring](#configuring)  
  * [Sending Raw Emails](#sending-raw-emails)
  * [Sending Templated Emails](#sending-templated-emails)  
* [Push Notifications](#push-notifications)  
  * [Broadcast](#broadcast)  
  * [Platform specific Devices](#platform-specific-devices)  
  * [Specific List of Devices](#specific-list-of-devices)  
  * [To List of Channels](#to-list-of-channels)  
  * [Query](#query)  
* [Files](#files)  
  * [Uploading](#uploading)  
  * [Downloading](#downloading)

## Setup

There are two ways to integrate the Appacitive iOS SDK into your Xcode project.

**1. Adding the framework bundle to your project:** Simply drag and drop the framework bundle into your Xcode project and check the box that says *copy items into destination group's folder (if needed)* and also check the box against the target name in the *Add to targets* section. You can download the framework bundle from [here](http://somelink.com).

**2. Using the CocoPods dependency manager:** Check [this link](http://appacitive.github.io/docs/current/ios/guides/) for a comprehensive guide on integrating the Appacitive iOS SDK using CocoaPods.

## Initialize

Before we dive into using the SDK, we need to grok a couple of things about the apikey.

ApiKey is central to interacting with the API as every call to the API needs to be authenticated. To access the ApiKey for your app, go to app listing via the [portal](https://portal.appacitive.com) and click on the key icon on right side.

!["Getting your apikey"](http:\/\/appacitive.github.io\/images\/portal-apikey-small.png)

Make sure you add the import statement for AppacitiveSDK.

####Initialize your SDK

```objectivec
[Appacitive initWithAPIKey:@"<insert_apiKey_here>"];
```

The above line of code will initialize the Appacitive SDK with the default environment setting set to _sandbox_. To enable the _live_ environment add the following line of code.

```objectivec
[Appacitive useLiveEnvironment:YES];
```

When you initialize Appacitive, it creates an Appacitive APDevice object by default for you. You can use this APDevice object for device related operations. To get a reference to the instance of the APDevice object, see the code below.

```objectivec
APDevice *myPhone = [APDevice alloc] init];
myphone = [Appacitive getCurrentAPDevice];
```

## Conventions
All the network calls made by the Appacitive iOS SDK are asynchronous. Therefore, most of the methods in the SDK make use of blocks. There are two types of blocks, _successBlocks_ and _failureBlocks_ usually called _successHandler_ and _failureHandler_ in method names. When using an SDK method, put the code that you wish to get executed when the operation is successful into the _successBlock_ and put the code that you wish to get executed when the operation fails in the _failureBlock_. Whatever you pass in the success or failure blocks will be executed on the main thread. refer the code below to get an idea of how the blocks work.

```objectivec
APObject *post = [[APObject alloc] initWithTypeName:@"post"];

[post addAttributeWithKey:@"title" value:@"sample post"];
[post addAttributeWithKey:@"text" value:@"This is a sample post"];

[post saveObjectWithSuccessHandler:^(NSDictionary *result)
{
    //This is the successBlock.
    //The code that you wish to get executed, when the operation is successful, goes here.
    NSLog(@"Object saved successfully!");
}

failureHandler:^(APError *error)
{
    //This is the failureBlock.
    //The code that you wish to get executed, when the operation fails, goes here.
    NSLog(@"Error occurred: %@",[error description]);
}
];
```

----------

## Data storage and retrieval

All data is represented as entities. This will become clearer as you read on. Lets assume that we are building a game and we need to store player data on the server.

### Creating

```objectivec
APObject *player = [[APObject alloc] initWithTypeName:@"player"];
```

An `APObject` comprises of an entity (referred to as 'object' in Appacitive jargon). To initialize an object, we need to provide it some options. The mandatory argument is the `type` argument.

What is a type? In short, think of types as tables in a contemporary relational database. A type has properties which hold values just like columns in a table. A property has a data type and additional constraints are configured according to your application's need. Thus we are specifying that the player is supposed to contain an entity of the type 'player' (which should already be defined in your application).

The player object is an instance of `APObject`. An `APObject` is a class which encapsulates the data (the actual entity or the object) and methods that provide ways to update it, delete it etc.

#### Setting Values
Now we need to name our player 'John Doe'. This can be done as follows

```objectivec
APObject *player = [[APObject] initWithType:@"player"];

[player addPropertyWithKey:@"name" value:@"John Doe"];

```

#### Getting values
Lets verify that our player is indeed called 'John Doe'.

```objectivec
// using the getters
NSLog(@"Player Name: %@",[player getPropertyWithKey:@"name"]);

// direct access via the raw object data
NSLog(@"Player Name: %@",[player.properties valueForKey:@"name"]);  // John Doe

```

#### Saving
Saving a player to the server is easy.

```objectivec
[player addPropertyWithKey:@"age" value:25];
[player saveObjectWithSuccessHandler:^(NSDictionary *result){
    NSLog(@"Player Object saved successfully!");
}failureHandler:^(APError *error){
    NSLog(@"Error occurred: %@",[error description]);
}];
```

When you call save, the entity is taken and stored on Appacitive's servers. A unique identifier called `__id` is generated and is stored along with the player object. This identifier is also returned to the object on the client-side. You can access it using `player.objectId`.
This is what is available in the `player` object after a successful save.

```objectivec
{
"__id": "14696753262625025",
"__type": "player",
"__typeid": "12709596281045355",
"__revision": "1",
"__createdby": "System",
"__lastmodifiedby": "System",
"__tags": [],
"__utcdatecreated": "2013-01-10T05:18:36.0000000",
"__utclastupdateddate": "2013-01-10T05:18:36.0000000",
"name": "John Doe",
"__attributes": {}
}
```

You'll see a bunch of fields that were created automatically by the server. They are used for housekeeping and storing meta-information about the object. All system generated fields start with `__`, avoid changing their values. Your values will be different than the ones shown here.

### Retrieving
 To retrieve an object, simply call the fetch method on the instance and on success the instance will be populated with the object from Appacitive.

```objectivec
// retrieve the player
[player fetchWithSuccessHandler:^(){
NSLog(@"Player: %@",[player description]);
}failureHandler:^(APError *error) {
NSLog(@"Error occurred: %@",[error description]);
}];
```

You can also retrieve multiple objects at a time, which will return an array of `APObject` objects in the successBlock. Here's an example

```objectivec
NSArray *objectIdList = [[NSArray alloc] initWithObjects:@"33017891581461312",@"33017891581461313", nil];
[APObject fetchObjectsWithObjectIds:objectIdList typeName:@"post"
        successHandler:^(NSArray *objects){
            NSLog("%@ number of objects fetched.", [objects count]);
        } failureHandler:^(APError *error) {
            NSLog(@"Error occurred: %@",[error description]);
        }];
});
```

**NOTE:** When performing fetch, search operations, you can choose to retrieve only specific properties of your object stored on Appacitive. This feature applies to all, system defined as well as user defined properties except *__id* and *__type*, which will always be fetched. Using this feature essentially results in lesser usage of network resources, faster response times and lesser memory usage for object storage on the device. Look for fetch methods that accept an  NSArray type of parameter named _propertiesToFetch_ and pass it an array of properties you wish to fetch. For search methods, set the _propertiesToFetch_ NSArray type property of an instance of APQuery class and pass that instance of APQuery to the query parameter of the search methods. More on the APQuery class in the __Queries__ section.

```objectivec
// retrieve the player
[player fetchWithPropertiesToFetch:@[@"name",@"score"] successHandler:^(){
NSLog(@"Player: %@",[player description]);
}failureHandler:^(APError *error) {
NSLog(@"Error occurred: %@",[error description]);
}];
```

### Updating
You can update your existing objects and save them to Appacitive.

```objectivec
// Incase the object is not already retrieved from the system,
// simply create a new instance of an object with the id.
// This creates a "handle" to the object on the client
// without actually retrieving the data from the server.
// Simply update the fields that you want to update and call the update method on the object.

// This will simply create a handle or reference to the existing object.
APObject *post = [[APObject alloc] initWithTypeName:@"post" objectId:@"33017891581461312"];
//Update properties
[post updatePropertyWithKey:@"title" value:@"UpdatedTitle"];
[post updatePropertyWithKey:@"text" :@ "This is updated text for the post."];
// Add a new attribute
[post addAttributeWithKey:@"topic" value:@"testing"];
// Add/remove tags
[post addTag:@"tagA"];
[post removeTag:@"tabC"];
[post updateWithSuccessHandler:^(){
NSLog(@"post title:%@, post text:%@",[object getTitle],[object getText]);
}failureHandler:^(APError *error){
NSLog(@"Error occurred: %@",[error description]);
}];

```

### Deleting
Lets say we've had enough of John Doe and want to remove him from the server, here's what we'd do.

```objectivec
[player deleteObjectWithSuccessHandler:^(){
  NSLog(@"JohnDoe player object has been deleted!");
}failureHandler:^(APError *error){
  NSLog(@"Error occurred: %@",[error description]);
}];

//You can also delete object with its connections in a simple call.
APObject *player = [[APObject alloc] initWithTypeName:@"player" objectId:@"123456678809"];
[friend deleteObjectWithConnectingConnectionsSuccessHandler:^(){
  NSLog(@"friend object deleted with its connections!");
}failureHandler:^(APError *error){
  NSLog(@"Error occurred: %@",[error description]);
}];

// Multiple objects can also be deleted at a time. Here's an example
[APObjects deleteObjectsWithIds:@["14696753262625025",@"14696753262625026"] typeName:@"player" successHandler:^(){
  NSLog(@"player objects deleted!");
}failureHandler:^(APError *error){
  NSLog(@"Error occurred: %@",[error description]);
}];
```

----------
## Connections

All data that resides in the Appacitive platform is relational, like in the real world. This means you can do operations like fetching all games that any particular player has played, adding a new player to a team or disbanding a team whilst still keeping the other teams and their `players` data perfectly intact.

Two entities can be connected via a relation, for example two entities of type `person` might be connected via a relation `friend` or `enemy` and so on. An entity of type `person` might be connected to an entity of type `house` via a relation `owns`. Still here? OK, lets carry on.

One more thing to grok is the concept of labels. Consider an entity of type `person`. This entity is connected to another `person` via relation `marriage`. Within the context of the relation `marriage`, one person is the `husband` and the other is the `wife`. Similarly the same entity can be connected to an entity of type `house` via the relation `owns_house`. In context of this relation, the entity of type `person` can be referred to as the `owner`.

`Wife`, `husband` and `owner` from the previous example are `labels`. Labels are used within the scope of a relation to give contextual meaning to the entities involved in that relation. They have no meaning or impact outside of the relation.

As with entities (objects), relations are also contained in collections.

Let's jump in!


### Creating &amp; Saving

#### New Connection between two existing Objects

Connections represent relations between objects. Consider the following.

```objectivec
//`reviewer` and `hotel` are the endpoint labels
APObject *reviewer = [[APObject alloc] initWithTypeName:@"reviewer" objectId:@"123445678"];

APObject *hotel = [[APObject alloc] initWithTypeName:@"hotel" objectId:@"987654321"];

//`review` is relation name
APConnection *connection = [[APConnection alloc] initWithRelationType:@"review"];

[connection createConnectionWithObjectA:reviewer objectB:hotel successHandler^() {
  NSLog(@"Connection created!");
}failureHandler:^(APError *error){
  NSLog(@"Error occurred: %@",[error description]);
}];
```

#### New Connection between two new Objects

There is another easier way to connect two new entities. You can pass the new entities themselves to the connection while creating it.

```objectivec
/* Will create a new myScore connection between
- new player object which will be created along with the connection.
- new score object which will be created along with the connection.
*/ The myScore relation defines two endpoints "player" and "score" for this information.

//Create an instance of object of type score
APObject *score = [[APObject alloc] initWithTypeName:@"score"];
[score addPropertyWithKey:@"points" value:@"150"];

//Create an instance of object of type player
APObject *score = [[APObject alloc] initWithTypeName:@"player"];
[score addPropertyWithKey:@"points" value:@"150"];

APConnection *connection = [[APConnection alloc] initWithRelationType:@"myScore"];
[connection createConnectionWithObjectA:player objectB:score labelA:@"player" labelB:@"score" successHandler^() {
  NSLog(@"Connection created!");
}failureHandler:^(APError *error){
  NSLog(@"Error occurred: %@",[error description]);
}];
```

This is the recommended way to do it. In this case, the myScore relation will create the entities player and score first and then connect them using the relation `marriage`.

**NOTE:** It doesn't matter whether player and score have been saved to the server yet. If they've been saved, then they will get connected via the relation 'myScore'. And if both (or one) hasn't been saved yet, the required entities will get connected and stored on the server. So you could create the two entities and connect them via a single call, and if you see the two entities will also get reflected with saved changes, so your objects are synced.

#### Setting Values

```objectivec
//This works exactly the same as in case of APObjects.
[myScore addPropertyWithKey:@"matchname" value:@"European Premier League"];
```

#### Getting values

```objectivec
NSLog(@"Match name: %@", [myScore getPropertyWithKey:@"matchname"]);
```

### Retrieving

#### Get Connection by Id

```objectivec
[APConnections fetchConnectionWithRelationType:@"review" objectId:@"33017891581461312" successHandler^(NSArray objects) {
  NSLog(@"Connection fetched:%@",[[objects lastObject] description]);
}failureHandler:^(APError *error){
  NSLog(@"Error occurred: %@",[error description]);
}];
```

Retrieving can also be done via the `fetch` method. Here's an example

```objectivec
APConnection *review = [[APConnection alloc] initWithTypeName:@"review" objectId:@"35097613532529604"];
[review fetchWithSuccessHandler:^()
	{
		NSLog(@"Connection fetched: %@",[review description]);
	}
	failureHandler:^(APError *error) {
		NSLog(@"Error occurred: %@",[error description]);
	}
];
```

The review object is similar to the object, except you get two new fields viz. endpointA and endpointB which contain the id and label of the two entities that this review object connects.

#### Get Connected Objects

Consider `Jane` has a lot of friends whom she wants to invite to her marriage. She can simply get all her friends who're of type `person` connected with `Jane` through a relation `friends` with label for Jane as `me` and friends as `friend` using this search

```objectivec
[APConnections fetchConnectedObjectsOfType:@"person" withObjectId:@"1234567890" withRelationType:@"friends" successHandler:^(NSArray *objects)
	{
		NSLog(@"Jane's friends:\n");
		for(APObject *obj in objects)
		{
			NSLog(@"%@ \n"[obj getPropertyWithKey:@"name"]);
		}
	}
```

#### Get all Connections for an Endpoint Object Id

Scenarios where you may need to just get all connections of a particular relation for an objectId, this query comes to rescue.

Consider `Jane` is connected to some objects of type `person` via `invite` relationship, that also contains a `bool` property viz. `attending`,  which is false by default and will be set to true if that person is attending marriage.

Now she wants to know who all are attending her marriage without actually fetching their connected `person` object, this can be done as

```objectivec
APObject *Jane = [[APObject alloc] initWithTypeName:@"person" objectId:@"12345678"];

APQuery *queryObj = [[APQuery alloc] init];
queryObj.filterQuery = [[APQuery queryExpressionWithProperty:@"attending"] isEqualTo:@"true"];

[APConnections searchAllConnectionsWithRelationType:@"invite" byObjectId:Jane.objectId withLabel:@"attendee" withQuery:[queryObj stringValue] successHandler:^(NSArray *objects) {
    NSLog(@"Attendees:");
    for(APObject *obj in objects)
        NSLog(@"%@ \n",[obj getPropertyWithKey:@"name"]);
}];

```

In this query, you provide a relation type (name) and a label of opposite side whose connection you want to fetch and what is returned is a list of all the connections for above object.

#### Get Connection by Endpoint Object Ids

Appacitive also provides a reverse way to fetch a connection  between two objects.
If you provide two object ids of same or different type types, all connections between those two objects are returned.

Consider you want to check whether `John` and `Jane` are married, you can do it as

```objectivec
//'marriage' is the relation between person type
//and 'husband' and 'wife' are the endpoint labels
[APConnections searchAllConnectionsWithRelationType:@"marriage" fromObjectId:@"22322" toObjectId:@"33422" labelB:@"wife" withQuery:nil successHandler:^(NSArray *objects) {
        if([objects count] <= 0)
            NSLog(@"John and Jane are married");
        else
            NSLog(@"John and Jane are not married");
    }];
//For a relation between same type type and different endpoint labels
//'label' parameter becomes mandatory for the get call

```

#### Get all connections between two Object Ids

Consider `Jane` is connected to `John` via a `marriage` and a `friend` relationship. If we want to fetch all connections between them we could do this as

```objectivec
[APConnections searchAllConnectionsFromObjectId:@"12345" toObjectId:@"67890" withQuery:nil successHandler:^(NSArray *objects) {
    NSLog(@"John and Jane share the following relations:");
    for(APConnection *obj in objects)
        NSLog(@"\n%@",[obj description]);
}];
```

On success, we get a list of all connections that connects `Jane` and `John`.

#### Get Interconnections between one and multiple Object Ids

Consider, `Jane` wants to what type of connections exists between her and a group of persons and houses , she could do this as

```objectivec
[APConnections searchAllConnectionsFromObjectId:@"12345" toObjectIds:@[@"24356", @"56732", @"74657"] withQuery:nil successHandler:^(NSArray *objects) {
        NSLog(@"Jane share the following relations:");
        for(APConnection *obj in objects)
            NSLog(@"\n%@",[obj description]);
    }];
});
```

### Updating


Updating is done exactly in the same way as entities, i.e. via the `updateConnection` method.

*Important*: While updating, changing the endpoint objects (the `__endpointa` and the `__endpointb` property) will not have any effect and the operation will fail. In case you need to change the connected endpoints, you need to delete the connection and create a new one.

```objectivec
APConnection *newConnection = [[APConnection alloc] initWithRelationType:@"myconnection"];
[newConnection fetchConnection];
[newConnection updatePropertyWithKey:@"name" value:@"newName"];
[newConnection updateConnection];
```

### Deleting

Deleting is provided via the `del` method.

```objectivec
APConnection *newConnection = [[APConnection alloc] initWithRelationType:@"myconnection"];
[newConnection fetchConnection];
[newConnection deleteConnection];
});


// Multiple connection can also be deleted at a time. Here's an example
[APConnections deleteConnectionsWithRelationType:@"myConnections" objectIds:@[@"123123",@"234234",@"345345"] failureHandler:^(APError *error) {
    NSLog(@"Some error occurred: %@", [error description]);
}];

```

----------

## Queries

All searching in SDK is done via `APQuery` object. You can retrieve many objects at once, put conditions on the objects you wish to retrieve, and more.

```objectivec

APSimpleQuery *nameQuery = [[APQuery queryExpressionWithProperty:@"name"] isEqualTo:@"John Doe"];
APQuery *queryObj = [[APQuery alloc] init];
queryObj.filterQuery = nameQuery;

[APObject searchAllObjectsWithTypeName:@"user" withQuery:[queryObj stringValue] successHandler:^(NSArray *objects) {
    NSLog(@"All users with John as their first name:");
    for(APObject *obj in objects) {
        NSLog(@"\n%@",[obj description]);
    }
}];

```
The above query will return all the players with 'John' as the first name. We first instantiated an APSimpleQuery object by using two class methods `queryExpressionWithProperty:` and `isEqualTo:`. We then instantiated an APQuery object and assigned the APSimpleQuery object that we just instantiated before to its `filterQuery` property. Finally, we used the APObject's class method `searchAllObjectsWithTypeName:withQuery:successHandler:` and passed the NSString representation of the query object to its `withQuery:` parameter.

Take a look at the documentation of the `APQuery` class to get the complete list of all types of queries you can construct.

### Modifiers

The APQuery interface provides various modifiers in the form of properties like `pageSize`, `pageNumber`, `orderBy`, `isAscending`, `filterQuery`, `fields`  and `freeText`. These are the options that you can specify in a query. Lets get to those.

```objectivec
//A filter query that will filter the objects based on the first name.
APSimpleQuery *nameQuery = [[APQuery queryExpressionWithProperty:@"firstname"] isEqualTo:@"John"];

APQuery *queryObj = [[APQuery alloc] init];

//Set the page number to the first page.
queryObj.pageNumber = 1;

//Set the page size to 10. i.e. 10 records per page.
queryObj.pageSize = 10;

//Sort the objects by name.
queryObj.orderBy = @"lastname";

//Set the sorting order to ascending.
queryObj.isAsc = YES;

//Set the filter query i.e. an instance of APSimpleQuery or APCompoundQuery.
queryObj.filterQuery = nameQuery;

//Set the properties to be fetched. All other properties of the object will be
queryObj.propertiesToFetch = @[@"firstname", @"lastname", @"username", @"location"];

//Set the free text search.
queryObj.freeText = @"xyz123";

//The APQuery class has a class method called 'stringValue' that will give the NSString representation of the APQuery object.
NSLog(@"String Representation of the queryObj:"[queryObj stringValue]);
});
```

#### Pagination

All search queries on the Appacitive platform support pagination. To specify pagination on your queries, you need to  set the properties as shown in the above code sample.


**NOTE**: By default, pageNumber is 1 and pageSize is 50

#### Sorting

The data fetched using the query object can be sorted on any existing property of the object. In the above example we are sorting the results by the `lastname` property of the object. The sorting order is set to Ascending by setting the `isAsc` property to `YES`. If you do not set the `isAsc` property to `YES` , then the default sorting order would be descending.

#### Fields

You can also mention exactly which fields/properties you need to be fetched in query results.

The `__id` and `__type`/`__relationtype` fields will always be returned.

In the above example we set the propertiesToFetch property of the queryObj to to an array with objects: `firstname`, `lastname`, `username` and `location`. Doing so will fetch only the specified properties along with `__type` and `__id` for all the objects returned as a result of a fetch or search operation.


**NOTE**: If you do not set the `propertiesToFetch` property, then all the proper tie for the objects will be fetched.

#### Filter

Filters are useful for limiting or funneling your results. They can be added on properties, attributes, aggregates and tags.

You can use the `APSimpleQuery` and `APCompoundQuery` interfaces to construct custom filters. The documentation will provide more insight into constructing custom filters.

You can filter on `property`, `attribute`, `aggregate` or `tags`.

In the above example we have filtered based on the first name property using the APSimpleQuery interface object. You can also find some more examples [here](http://help.appacitive.com/v1.0/index.html#ios/data_querying-data) for the filter queries.


#### Geolocation

You can specify a property type as a geography type for a given type or relation. These properties are essential latitude-longitude pairs. Such properties support geo queries based on a user defined radial or polygonal region on the map. These are extremely useful for making map based or location based searches. E.g., searching for a list of all restaurants within 20 miles of a given users locations.

##### Radial Search

A radial search allows you to search for all records of a specific type which contain a geocode property which lies within a predefined distance from a point on the map. the following example query will filter the objects based on the `location` property whose value lies within the 5 miles of current location.

```objectivec
CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:23.2 longitude:72.3];
    APSimpleQuery *radialSearch = [APQuery queryWithRadialSearchForProperty:@"location" nearLocation:currentLocation withinRadius:@5 usingDistanceMetric:kMiles];
```

##### Polygon Search

A polygon search is a more generic form of geographical search. It allows you to specify a polygon region on the map via a set of geocodes indicating the vertices of the polygon. The search will allow you to query for all data of a specific type that lies within the given polygon. This is typically useful when you want finer grained control on the shape of the region to search.

```objectivec
CLLocation *point1 = [[CLLocation alloc] initWithLatitude:1 longitude:1];
CLLocation *point2 = [[CLLocation alloc] initWithLatitude:1 longitude:5];
CLLocation *point3 = [[CLLocation alloc] initWithLatitude:5 longitude:5];
CLLocation *point4 = [[CLLocation alloc] initWithLatitude:5 longitude:1];

CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:5.3 longitude:5.9];

APSimpleQuery *polygonSearch = [APQuery queryWithPolygonSearchForProperty:@"location" withPolygonCoordinates:@[point1, point2, point3, point4]];
```

#### Tag Based Searches

The Appacitive platform provides inbuilt support for tagging data (objects, connections, users and devices). You can use this tag information to query for a specific data set. The different options available for searching based on tags is detailed in the sections below.

##### Query data tagged with one or more of the given tags

For data of a given type, you can query for all records that are tagged with one or more tags from a given list. For example - querying for all objects of type message that are tagged with the names `Gina`, `George`, `Walt`.

```objectivec
APSimpleQuery *tagQuery = [APQuery queryWithSearchUsingOneOrMoreTags:@[@"Gina", @"George", @"Walt"]];
```

##### Query data tagged with all of the given tags

An alternative variation of the above tag based search allows you to query for all records that are tagged with all the tags from a given list. For example, querying for all objects that are tagged with `football`, `soccer` and `rugby`.

```objectivec
APSimpleQuery *tagQuery = [APQuery queryWithSearchUsingAllTags:@[@"football", @"soccer", @"rugby"]];
```

#### Composite Filters

Compound queries allow you to combine multiple queries into one single query. The multiple queries can be combined using `logical OR` and `logical And` operators. NOTE: All queries of type APSimpleQuery with the exception of free text queries can be combined into a compound query.

```objectivec
APCompoundQuery *complexQuery = [APQuery booleanAnd:@[[[APQuery queryExpressionWithProperty:@"name"] isLike:@"John"], [[APQuery queryExpressionWithAttribute:@"height"] isGreaterThan:@"6.0"]]];

```

Similarly you can also construct a complex query with the boolean OR operator.

```objectivec
APCompoundQuery *complexQuery = [APQuery booleanOr:@[[[APQuery queryExpressionWithProperty:@"name"] isLike:@"John"], [[APQuery queryExpressionWithAttribute:@"eye color"] isEqualTo:@"brown"]]];
```

#### FreeText

There are situations when you would want the ability to search across all text content inside your data. Free text queries are ideal for implementing this kind of functionality. As an example, consider a free text lookup for users which searches across the username, firstname, lastname, profile description etc.You can pass multiple values inside a free text search. It also supports passing certain modifiers that allow you to control how each search term should be used. This is detailed below.

```objectivec
APQuery *freeTextQuery = [[APQuery alloc] init];
    freeTextQuery.freeText = @"Jonathan White";
```

----------

## Graph Search

Graph queries offer immense potential when it comes to traversing and mining for connected data. There are two kinds of graph queries, filter and projection.

### Creating graph queries

You can create filter and projection graph queries from the management portal. When you create such queries from the portal, you are required to assign a unique name with every saved search query. You can then use this name to execute the query from your app by making the appropriate api call to Appacitive.

### Executing Filter graph queries

You can execute a saved graph query (filter or projection) by using it’s name that you assigned to it while creating it from the management portal. You will need to send any placeholders you might have set up while creating the query.

```objectivec
[APGraphNode applyFilterGraphQuery:@"namefilter" usingPlaceHolders:@{@"firstname":@"Jonathan", @"lastname":@"White"} successHandler:^(NSArray *objects) {
        NSLog(@"ObjectIds:");
        for(NSString *obj in objects)
            NSLog(@"\n%@",obj);
    }];
```

### Executing projection graph queries

Executing saved projection queries works the same way as executing saved filter queries. The only difference is that you also need to pass the initial ids as an array of strings to feed the projection query. The response to a projection query will depend on how you design your projection query. Do test them out using the query builder from the query tab on the management portal and from the test harness.

```objectivec
APGraphNode *projectionGraphQuery = [[APGraphNode alloc] init];
    [projectionGraphQuery applyProjectionGraphQuery:@"project_sales" usingPlaceHolders:nil forObjectsIds:@[@"12345",@"34567"] successHandler:^(APGraphNode *node) {
        NSLog(@"Sales Projection:%@",[node description]);
    }];
```
-----------

## User Management

Users represent your app's users. There is a host of different functions/features available in the SDK to make managing users easier. The `APUser` interface deals with user management.

### Create

There are multiple ways to create users.

#### Basic

You create users the same way you create any other data.

```objectivec
APUser *spencer = [[APUser alloc] init];
spencer.username = @"spencemag";
spencer.firstName = @"Spencer";
spencer.lastName = @"Maguire";
spencer.email = @"spencer.maguire@email.com";
spencer.phone = @"9421234567";
spencer.password = @"H3LL0_K177Y";

[spencer createUser];
```

#### Creating Users via Facebook

You can give your users the option of signing up or logging in via Facebook. For this you need to

 1. [Setup Facebook app](https://developers.Facebook.com/apps).
 2. Follow [these](https://developers.Facebook.com/docs/reference/ios/current/) instructions to [include Facebook SDK](https://developers.Facebook.com/docs/reference/ios/current/) in your app.


To create a user with Facebook, you need the user's Facebook access token and you need to pass it to the `createUserWithFacebook:` method.

```objectivec
APUser *spencer = [[APUser alloc] init];
[spencer createUserWithFacebook:@"Hsdfbk234kjnbkb23k4JLKJ234kjnkkJK2341nkjnJSD"];
```

Similarly you can also create a user with Twitter Oauth v1.0 and Oauth v2.0.

### Retrieve

There are three ways you could retrieve the user

#### By id.
Fetching users by id is exactly like fetching objects/data. Let's say you want to fetch user with `__id` 12345.

```objectivec
APUser *johndoe = [[APUser alloc] initWithTypeName:@"user" objectId:@"12345"];
    [johndoe fetch];
```

**NOTE**:  The `APUser` class is a subclass of `APObject` class. Therefore, all `APObject` operations can be performed on an `APUser` object, but you will need a user logged in to perform user-specific operations like update, fetch and delete.

#### By username

```objectivec
APUser *spencer = [[APUser alloc] init];
spencer.username = @"spencemag";
[spencer fetch];    ```

#### By UserToken

```objectivec
APUser *spencer = [[APUser alloc] init];
[spencer fetchUserWithUserToken:@"25jkhv5k7h8vl4jh5b26l3j45"];
```

### Update
Again, there's no difference between updating a user and updating any other data. It is done via the `update` method.

```objectivec
APUser *spencer = [[APUser alloc] init];
[spencer fetchUserByUserName:@"spencemag"];
[spencer setUsername:@"spencer.maguire"];
[spencer updateObject];
```

### Delete
There are 2 ways of deleting a user.
#### Via the user id

```objectivec
APUser *spencer = [[APUser alloc] initWithTypeName:@"user" objectId:@"123456"];
[spencer deleteObject];
    ```

#### Via the username

```objectivec
APUser *spencer = [[APUser alloc] init];
[spencer deleteObjectWithUserName:@"spencer.maguire"];
```

### Authentication

Authentication is the core of user management. You can authenticate (log in) users in multiple ways. Once the user has authenticated successfully, you will be provided the user's details and an access token. This access token identifies the currently logged in user and will be used to implement access control. Each instance of an app can have one logged in user at any given time. When you call any of the authenticate methods provided by the SDK, on successful authentication, the SDK will set the user's access token to the token provided by Appacitive. The APUser class also provides a static instance called `currentUser`. This instance will also be instantiated with the user object returned by appacitive when the call to the `authenticate` method returns success. The `userToken` and `currentUser` are read-only and can only be set by successfully authenticating a user.

#### Login via username + password

You can ask your users to authenticate via their username and password.

```objectivec
[APUser authenticateUserWithUserName:@"spencer.maguire" password:@"H3LL0_K177Y"];
```


#### Login with Facebook

You can ask your users to log in via Facebook. The process is very similar to signing up with fFacebook.

```objectivec
[APUser authenticateUserWithFacebook:@"23klj4bkjl23bn4knb23k4ln"];
```

#### Login with Twitter

You can ask your users to log in via Twitter. This'll require you to implement twitter login and provide the SDK with consumerkey, consumersecret, oauthtoken and oauthtokensecret. There are two version of Twitter's Oauth authentication that the SDK provides, viz. the Oauth1.0 and Oauth2.0

```objectivec
//Oauth1.0
[APUser authenticateUserWithTwitter:@"kjbknkn23k4234" oauthSecret:@"5n33h4b5b"];

//Oauth2.0
    [APUser authenticateUserWithTwitter:@"3kjn2k34n" oauthSecret:@"2m34234n" consumerKey:@"2vhgv34v32hg" consumerSecret:@"sdfg087fd9"];
```

### User Session Management

Once the user has authenticated successfully, you will be provided the user's details and an access token. This access token identifies the currently logged in user and will be used to implement access control. Each instance of an app can have one logged in user at any given time.By default the SDK takes care of setting and unsetting this token. However, you can explicitly tell the SDK to start using another access token.

```objectivec
//Get the currently logged-in user object.
APUser *user = [APUser currentUser];

//Log out the currently logged-in user.
[APUser logOutCurrentUser];

//Validate the currentUser's sesion.
[APUser validateCurrentUserSessionWithSuccessHandler:^(NSDictionary *result) {
    NSLog(@"Current user session is valid");
} failureHandler:^(APError *error) {
    NSLog(@"Current user session is invalid");
}];
```

### Linking and Unlinking accounts

#### Linking Facebook account

**NOTE:** Here, we assume that the user has already logged-in with Facebook.

If you want to associate an existing loggedin APUser to a Facebook account, you can do it as shown below.

```objectivec
APUser *user = [APUser currentUser];
[user linkFacebookAccountWithAccessToken:@"jlj4jl2lj34jl324ljhb23lj4b"];
});
```

#### Create Facebook linked accounts

**NOTE:** Here, we assume that the user has already logged-in with Facebook.

If you want to associate a new APUser to a Facebook account, you can simply use the `authenticateUserWihFacebook` method.


#### Linking Twitter account

**NOTE:** Here, we assume that the user has already logged-in with Twitter.

If you want to associate an existing loggedin APUser to a Twitter account, you can link it like so

```objectivec
//Oauth1.0
[user linkTwitterAccountWithOauthToken:@"234kjb23k4bk23b4" oauthSecret:@"23d4kj32n4kjbk32bn4k"];

//Oauth2.0
 [user linkTwitterAccountWithOauthToken:@"kj3h24k234b" oauthSecret:@"23hb4jh2b3j4" consumerKey:@"2jh3lb4jh2b34" consumerSecret:@"2j3b4j234jb"];
```

#### Create Twitter linked accounts

**NOTE:** Here, we assume that the user has already logged-in with Twitter.

If you want to associate a new APUser to a Twitter account, you can simply use the authenticateUserWithTwitter method.


#### Retreiving linked accounts

```objectivec
//Retrieveing a specific linked account with service name viz. facebook or twitter.
[user getLinkedAccountWithServiceName:@"twitter" successHandler:^(NSDictionary *result) {
    NSLog(@"Linked twitter account details:%@",[result description]);
}];

//Retrieving 
[user getAllLinkedAccountsWithSuccessHandler:^(NSDictionary *result) {
    NSLog(@"All Linked account details:%@",[result description]);
}];

```

#### Delinking Facebook account

```objectivec
[user delinkAccountWithServiceName:@"facebook"];
});
```

### Password Management

#### Reset Password

Users often forget their passwords for your app. So you are provided with an API to reset their passwords.To start, you ask the user for his username and call

```objectivec
[user sendResetPasswordEmailWithSubject:@"APPACITIVE : Reset your password"];
```

This will send the user an email, with a reset password link. When user clicks on the link, he'll be redirected to an Appacitive page, which will allow him to enter new password and save it.

#### Update Password
Users need to change their passwords whenever they've compromised it. You can update it using this call:

```objectivec
[user changePasswordFromOldPassword:@"0LDP4$$W0RD" toNewPassword:@"N3WP4$$W0RD"];});
```
### Check-in

Users can check-in at a particular co-ordinate using this call.

```objectivec
[APUser setUserLocationToLatitude:@"23.27" longitude:@"72.30" forUserWithUserId:@"spencer.maguire"];
});
```

----------

## Emails

### Configuring

Sending emails from the SDK is quite easy. There are primarily two types of emails that can be sent

* Raw Emails
* Templated Emails

Email is accessed through the APEmail interface. Before you get to sending emails, you need to configure SMTP settings. You can either configure it from the portal or in the `APEmail` interface with your mail provider's settings.

### Sending Raw Emails

A raw email is one where you can specify the entire body of the email. An email has the structure

```objectivec
APEmail *emailObj = [[APEmail alloc] initWithRecipients:@[@"joe.stevens@mail.com", @"alicia.burke@mail.com", @"liam.jones@mail.com"] subject:@"Welcome to my app" body:@"Hey Guys, Welcome to app. Hope you enjoy the experience. Regards,Allan Matthews"];

//Sending email with default SMTP settings from Appacitive.
[emailObj sendEmail];

//Sending email with your email providers SMTP configuration parameters.
[emailObj sendEmailUsingSMTPConfig:[APEmail makeSMTPConfigurationDictionaryWithUsername:@"allan.matthews" password:@"4V3NG3R$" host:@"smtp.email.com" port:@443 enableSSL:YES]];
});

//Alternative way for setting all the APEmail properties individually.
APEmail *emailObj = [[APEmail alloc] init];
emailObj.toRecipients = @[@"joe.stevens@mail.com", @"alicia.burke@mail.com", @"liam.jones@mail.com"];
emailObj.ccRecipients = @[@"katherine.wesley@mail.com", @"jennifer.riley@mail.com", @"toby.salvadore@mail.com"];
emailObj.bccRecipients = @[@"justin.stevenson@mail.com", @"phillip.jones@mail.com"];
emailObj.subjectText = @"Welcome to my app.";
emailObj.bodyText = @"Hey Guys, Welcome to app. Hope you enjoy the experience. Regards,Allan Matthews";
emailObj.fromSender = @"allan.matthews@mail.com";
emailObj.isHTMLBody = NO;
emailObj.replyToEmail = @"jessica.osborne@mail.com";
[emailObj sendEmail];
```

### Sending Templated Emails

You can also save email templates in Appacitive and use these templates for sending mails. The template can contain placeholders that can be substituted before sending the mail.

For example, if you want to send an email to every new registration, it is useful to have an email template with placeholders for username and confirmation link.

Consider we have created an email template named `welcome_email` where the templatedata is -

```objectivec
"Welcome [#username] ! Thank you for downloading [#appname]."
```

Here, [#username] and [#appname] denote the placeholders that we would want to substitute while sending an email. An email has the structure

```objectivec
APEmail *emailObj = [[APEmail alloc] init];
emailObj.toRecipients = @[@"joe.stevens@mail.com", @"alicia.burke@mail.com", @"liam.jones@mail.com"];
emailObj.ccRecipients = @[@"katherine.wesley@mail.com", @"jennifer.riley@mail.com", @"toby.salvadore@mail.com"];
emailObj.bccRecipients = @[@"justin.stevenson@mail.com", @"phillip.jones@mail.com"];
emailObj.subjectText = @"Welcome to my app.";
emailObj.bodyText = @"Hey Guys, Welcome to app. Hope you enjoy the experience. Regards,Allan Matthews";
emailObj.fromSender = @"allan.matthews@mail.com";
emailObj.isHTMLBody = NO;
emailObj.replyToEmail = @"jessica.osborne@mail.com";
emailObj.templateBody = @{@"username":@"Robin", @"appname":@"DealHunter"};
[emailObj sendTemplatedEmailUsingTemplate:@"welcome_email"];
```

**NOTE**: Emails are not transactional. This implies that a successful send operation would mean that your email provider was able to dispatch the email. It DOES NOT mean that the intended recipient(s) actually received that email.

----------

## Push Notifications

Using Appacitive platform you can send push notification to iOS, Android and Windows Phone devices.

We recommend you to go through **[this](http://appacitive.github.io/docs/current/rest/push/index.html)** section, which explains how you can configure Appacitive app for Push notification. You will need to provide some basic one time configurations like certificates, using which we will setup push notification channels for different platforms for you. Also we provide a Push Console using which you can send push notification to the users.

Appacitive provides four ways to select the sender list

* Broadcast
* Platform specific Devices
* Specific List of Devices
* To List of Channels
* Query

### Broadcast

If you want to send a push notification to all active devices, you can use the following options

```objectivec
APPushNotification *notification = [[APPushNotification alloc] initWithMessage:@"Bonjour!"];
notification.isBroadcast = YES;
[notification sendPushWithSuccessHandler:^{
		NSLog(@"Push Sent!");
} failureHandler:^(APError *error) {
		NSLog(@"Error occurred: %@",[error description]);
}];
```

### Platform specific Devices

If you want to send push notifications to specific platforms, you can do so in the following way.

```objectivec
APPushNotification *notification = [[APPushNotification alloc] initWithMessage:@"Bonjour!"];
notification.query = [[[APQuery queryExpressionWithProperty:@"devicetype"] isEqualTo:@"ios"] stringValue];
[notification sendPushWithSuccessHandler:^{
	NSLog(@"Push Sent!");
} failureHandler:^(APError *error) {
	NSLog(@"Error occurred: %@",[error description]);
}];
```

### Specific List of Devices

If you want to send push notifications to specific devices, will need to provide the device ids.

```objectivec
APPushNotification *notification = [[APPushNotification alloc] initWithMessage:@"Bonjour!"];
notification.deviceIds = @[@"23423432545", @"4353452352"];
[notification sendPushWithSuccessHandler:^{
	NSLog(@"Push sent to requested devices!"]);
} failureHandler:^(APError *error) {
	NSLog(@"Error occurred: %@",[error description]);
}];
```

### To List of Channels

You can also send PUSH messages to specific channels.

```objectivec
APPushNotification *notification = [[APPushNotification alloc] initWithMessage:@"Bonjour!"];
notification.channels = @[@"updates", @"upgrades"];
[notification sendPushWithSuccessHandler:^{
		NSLog(@"Push sent on selected channels!");
} failureHandler:^(APError *error) {
		NSLog(@"Error occurred: %@",[error description]);
}];
```

### Query

You can send push notifications to devices using a Query. All the devices which comes out as result of the query will receive the push notification.

```objectivec
APPushNotification *notification = [[APPushNotification alloc] initWithMessage:@"Bonjour!"];
notification.query = [[[APQuery queryExpressionWithProperty:@"devicetype"] isEqualTo:@"ios"] stringValue];
[notification sendPushWithSuccessHandler:^{
	NSLog(@"Push Sent!");
} failureHandler:^(APError *error) {
	NSLog(@"Error occurred: %@",[error description]);
}];
}
```

----------------

## Files

Appacitive supports file storage and provides api's for you to easily upload and download files. In the background we use amazon's S3 services for persistence. To upload or download files, the SDK provides `APFile` class, which you can instantiate to perform operations on file.

### Uploading

```objectivec
APFile *fileObj = [[APFile alloc] init];
[fileObj uploadFileWithName:@"BannerImage" data:[NSData dataWithContentsOfFile:@"BannerImage.png"] validUrlForTime:@10 contentType:@"image/png"];
```

### Downloading

```objectivec
APFile *fileObj = [[APFile alloc] init];
[fileObj downloadFileWithName:@"BannerImage" validUrlForTime:@10 successHandler:^(NSData *data) {
    UIImage *bannerImage = [UIImage imageWithData:data];
}];
```

