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
  * [Counts](#counts)
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
  * [Creating Appacitive.File Object](#creating-appacitivefile-object)  
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

Similarly you can also create a user with Twitter Oauth v1.0 and oath v2.0.

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
// the access token
// var token = /* ... */

// setting it in the SDK
Appacitive.session.setUserAuthHeader(token);
// now the sdk will send this token with all requests to the server
// Access control has started

// removing the auth token
Appacitive.session.removeUserAuthHeader();
// Access control has been disabled
```
User session validation is used to check whether the user is authenticated and his usertoken is valid or not.
```objectivec

// to check whether user is loggedin locally. This won't make any explicit apicall to validate user
Appacitive.Users.validateCurrentUser().then(function(isValid) {
  if(isValid) //user is logged in
});
// to check whether user is loggedin, explicitly making apicall to validate usertoken
// pass true as first argument to validate usertoken making an apicall
Appacitive.Users.validateCurrentUser(true).then(function(isValid) {
  if (isValid)  //user is logged in
});
```

### Linking and Unlinking accounts

#### Linking Facebook account

**NOTE:** here, we consider that the user has already logged-in with Facebook using `Appacitive.Facebook.requestLogin` method

If you want to associate an existing loggedin Appacitive.User to a Facebook account, you can link it like so

```objectivec
var user = Appacitive.User.current();
user.linkFacebook(global.Appacitive.Facebook.accessToken()).then(function(obj) {
  //You can access linked accounts of a user, using this field
  console.dir(user.linkedAccounts());
});
```

#### Create Facebook linked accounts

**NOTE:** here, we consider that the user has already logged-in with Facebook using `Appacitive.Facebook.requestLogin` method

If you want to associate a new Appacitive.User to a Facebook account, you can link it like so

```objectivec
//create user object
var user = new Appacitive.User({
  username: 'john.doe@appacitive.com',
  password: /* password as string */,
  email: 'johndoe@appacitive.com',
  firstname: 'John',
  lastname: 'Doe'
});

//link Facebook account
user.linkFacebook(global.Appacitive.Facebook.accessToken());

//create the user on server
user.save().then(function(obj) {
  console.dir(user.linkedAccounts());
});

```
#### Linking Twitter account

**NOTE:** here, we consider that the user has already logged-in with twitter

If you want to associate an existing loggedin Appacitive.User to a Twitter account, you can link it like so

```objectivec
var user = Appacitive.User.current();
user.linkTwitter({
  oauthtoken: {{twitterObj.oAuthToken}} ,
  oauthtokensecret: {{twitterObj.oAuthTokenSecret}},
  consumerKey: {{twitterObj.consumerKey}},
  consumerSecret: {{twitterObj.consumerSecret}}
}).then(function(obj) {
  //You can access linked accounts of a user, using this field
  console.dir(user.linkedAccounts());
});
```

#### Create Twitter linked accounts

**NOTE:** here, we consider that the user has already logged-in with twitter

If you want to associate a new Appacitive.User to a Twitter account, you can link it like so
```objectivec
//create user object
var user = new Appacitive.User({
  username: 'john.doe@appacitive.com',
  password: /* password as string */,
  email: 'johndoe@appacitive.com',
  firstname: 'John',
  lastname: 'Doe'
});

//link Facebook account
user.linkTwitter({
  oauthtoken: {{twitterObj.oAuthToken}} ,
  oauthtokensecret: {{twitterObj.oAuthTokenSecret}},
  consumerKey: {{twitterObj.consumerKey}},
  consumerSecret: {{twitterObj.consumerSecret}}
});

//create the user on server
user.save().then(function(obj) {
  console.dir(user.linkedAccounts());
});

```


#### Retreiving all linked accounts
```objectivec
Appacitive.Users.current().getAllLinkedAccounts().then(function() {
  console.dir(Appacitive.Users.current().linkedAccounts());
});
```

#### Delinking Facebook account
```objectivec
//specify account which needs to be delinked
Appacitive.Users.current().unlink('Facebook').then(function() {
  alert("Facebook account delinked successfully");
});
```
### Password Management

#### Reset Password

Users often forget their passwords for your app. So you are provided with an API to reset their passwords.To start, you ask the user for his username and call

```objectivec
Appacitive.Users.sendResetPasswordEmail("{username}", "{subject for the mail}").then(function(){
  alert("Password reset mail sent successfully");
});
```

This'll basically send the user an email, with a reset password link. When user clicks on the link, he'll be redirected to an Appacitive page, which will allow him to enter new password and save it.

You can also create a custom reset password page or provide a custom reset password page URL from our UI.

On setting custom URL, the reset password link in the email will redirect user to that URL with a reset password token appended in the query string.

```objectivec
//consider your url is
http://help.appacitive.com

//after user clicks on the link, he'll be redirected to this url
http://help.appacitive.com?token=dfwfer43243tfdhghfog909043094
```
The token provided in url can then be used to change the password for that user.

So basically, following flow can be utilized for reset password

1. Validate token specified in URL

```objectivec
Appacitive.Users.validateResetPasswordToken(token).then(function(user) {
  //token is valid and json user object is returned for that token
});
```
2.If valid then allow the user to enter his new password and save it
```objectivec
Appacitive.Users.resetPassword(token, newPassword).then(function() {
  //password for user has been updated successfully
});
```

#### Update Password
Users need to change their passwords whenever they've compromised it. You can update it using this call:
```objectivec
//You can make this call only for a loggedin user
Appacitive.Users.current().updatePassword('{oldPassword}','{newPassword}').then(function(){
  alert("Password updated successfully");
});
```
### Check-in

Users can check-in at a particular co-ordinate uing this call. Basically this call updates users location.
```objectivec
Appacitive.Users.current().checkin(new Appacitive.GeoCoord(18.57, 75.55)).then(function() {
  alert("Checked in successfully");
});
```

----------

## Emails

### Configuring

Sending emails from the sdk is quite easy. There are primarily two types of emails that can be sent

* Raw Emails
* Templated Emails

Email is accessed through the Appacitive.Email module. Before you get to sending emails, you need to configure smtp settings. You can either configure it from the portal or in the `Email` module with your mail provider's settings.

```objectivec
Appacitive.Email.setupEmail({
username: /* username of the sender email account */,
from: /* display name of the sender email account*/,
password: /* password of the sender */,
host: /* the smtp host, eg. smtp.gmail.com */,
port: /* the smtp port, eg. 465 */,
enablessl: /* is email provider ssl enabled, true or false, default is true */,
replyto: /* the reply-to email address */
});
```
Now you are ready to send emails.

### Sending Raw Emails

A raw email is one where you can specify the entire body of the email. An email has the structure

```objectivec
var email = {
to: /* a string array containing the recipient email addresses */,
cc: /* a string array containing the cc'd email addresses */,
bcc: /* a string array containing the bcc'd email addresses */,
from: /* email id of user */,
subject: /* string containing the subject of the email */,
body: /* html or string that will be the body of the email */,
ishtml: /* bool value specifying the body is html or string, default is true */,
useConfig: /* set true to use configure settings in email module in SDK */
};
```

And to send the email

```objectivec
Appacitive.Email.sendRawEmail(email).then(function (email) {
alert('Successfully sent.');
});
```

### Sending Templated Emails

You can also save email templates in Appacitive and use these templates for sending mails. The template can contain placeholders that can be substituted before sending the mail.

For example, if you want to send an email to every new registration, it is useful to have an email template with placeholders for username and confirmation link.

Consider we have created an email template where the templatedata is -

```objectivec
"Welcome [#username] ! Thank you for downloading [#appname]."
```

Here, [#username] and [#appname] denote the placeholders that we would want to substitute while sending an email. An email has the structure

```objectivec
var email = {
to: /* a string array containing the recipient email addresses */,
cc: /* a string array containing the cc'd email addresses */,
bcc: /* a string array containing the bcc'd email addresses */,
subject: /* string containing the subject of the email */,
from: /* email id of user */,
templateName: /*name of template to be send */,
data: /*an object with placeholder names and their data eg: {username:"test"} */
useConfig: /* set true to use configure settings in email module in SDK*/
};
```
And to send the email,

```objectivec
Appacitive.Email.sendTemplatedEmail(email).then(function (email) {
alert('Successfully sent.');
});
```

`Note`: Emails are not transactional. This implies that a successful send operation would mean that your email provider was able to dispatch the email. It DOES NOT mean that the intended recipient(s) actually received that email.

----------

## Push Notifications

Using Appacitive platform you can send push notification to iOS devices, Android base devices and Windows phone.

We recommend you to go through **[this](http://appacitive.github.io/docs/current/rest/push/index.html)** section, which explains how you can configure Appacitive app for Push notification. You will need to provide some basic one time configurations like certificates, using which we will setup push notification channels for different platforms for you. Also we provide a Push Console using which you can send push notification to the users.

In Javascript SDK, static object `Appacitive.Push` provides methods to send push notification.

Appacitive provides four ways to select the sender list

* Broadcast
* Platform specific Devices
* Specific List of Devices
* To List of Channels
* Query

First we'll see how to send a push notification and then we will discuss the above methods with their options one by one.

```objectivec
var options = {..}; //Some options specific to senders
Appacitive.Push.send(options).then(function(notification) {
  alert('Push notification sent successfully');
});
```

### Broadcast

If you want to send a push notification to all active devices, you can use the following options

```objectivec
var options = {
  "broadcast": true, // set this to true for broadcast
  "platformoptions": {
  // platform specific options
"ios": {
  "sound": "test"
},
"android": {
  "title": "test title"
}
  },
"data": {
  // message to send
"alert": "Push works!!!",
    // Increment existing badge by 1
"badge": "+1",
    //Custom data field1 and field2
"field1": "my custom value",
    "field2": "my custom value"
  },
  "expireafter": "100000" // Expiry in seconds
}
```

### Platform specific Devices

If you want to send push notifications to specific platforms, you can use this option. To do so you will need to provide the devicetype in the query.

```objectivec
var options = {
  "query": "*devicetype == 'ios'",
  "broadcast": false, // set this to true for broadcast
  "platformoptions": {
  // platform specific options
"ios": {
  "sound": "test"
},
"android": {
  "title": "test title"
}
  },
"data": {
  // message to send
"alert": "Push works!!!",
    // Increment existing badge by 1
"badge": "+1",
    //Custom data field1 and field2
"field1": "my custom value",
    "field2": "my custom value"
  },
  "expireafter": "100000" // Expiry in seconds
}
```

### Specific List of Devices

If you want to send push notifications to specific devices, you can use this option. To do so you will need to provide the device ids.

```objectivec
var options = {
  "deviceids": [
"{deviceId}",
"{deviceId2}",
"{deviceId3}"
  ],
  "broadcast": false, // set this to true for broadcast
  "platformoptions": {
  // platform specific options
"ios": {
  "sound": "test"
},
"android": {
  "title": "test title"
}
  },
"data": {
  // message to send
"alert": "Push works!!!",
    // Increment existing badge by 1
"badge": "+1",
    //Custom data field1 and field2
"field1": "my custom value",
    "field2": "my custom value"
  },
  "expireafter": "100000" // Expiry in seconds
}
```

### To List of Channels

Device object has a Channel property, using which you can club multiple devices. This is helpful if you want to send push notification using channel.

```objectivec
var options = {
  "channels": [
"{nameOfChannel}"
  ],
  "broadcast": false, // set this to true for broadcast
  "platformoptions": {
  // platform specific options
"ios": {
  "sound": "test"
},
"android": {
  "title": "test title"
}
  },
"data": {
  // message to send
"alert": "Push works!!!",
    // Increment existing badge by 1
"badge": "+1",
    //Custom data field1 and field2
"field1": "my custom value",
    "field2": "my custom value"
  },
  "expireafter": "100000" // Expiry in seconds
}
```

### Query

You can send push notifications to devices using a Query. All the devices which comes out as result of the query will receive the push notification.

```objectivec
var options = {
  "query": "{{add your query here}}",
  "broadcast": false, // set this to true for broadcast
  "platformoptions": {
  // platform specific options
"ios": {
  "sound": "test"
},
"android": {
  "title": "test title"
}
  },
"data": {
  // message to send
"alert": "Push works!!!",
    // Increment existing badge by 1
"badge": "+1",
    //Custom data field1 and field2
"field1": "my custom value",
    "field2": "my custom value"
  },
  "expireafter": "100000" // Expiry in seconds
}
```

----------------

## Files

Appacitive supports file storage and provides api's for you to easily upload and download file. In the background we use amazon's S3 services for persistance. To upload or download files, the SDK provides `Appacitive.File` class, which you can instantiate to perform operations on file.

### Creating Appacitive.File Object

To construct an instance of `Appacitive.File` class, you must know the content type (mimeType) of the file because this is a required parameter. Optionally you can provide name/id of the file by which it will be saved on the server.

Thses are the options you need to initialize a file object
```objectivec
var options = {
  fileId: //  a unique string representing the filename on server,
contentType: // Mimetype of file,
fileData: // data to be uploaded, this could be bytes or HTML5 fileupload instance data
};
```

If you don't provide contentType, then the SDK will try to get the MimeType from the HTML5 fileData object or it'll set it as 'text/plain'.

To upload a file, the SDK provides three ways.

#### Byte Stream

If you have a byte stream, you can use the following interface to upload data.
```objectivec
var bytes = [ 0xAB, 0xDE, 0xCA, 0xAC, 0XAE ];

//create file object
var file = new Appacitive.File({
  fileId: 'serverFile.png',
fileData: bytes,
contentType: 'image/png'
});
```

#### HTML5 File Object

If you've a fileupload control in your HTML5 app which allows the user to pick a file from their local drive to upload, you can simply create the object as
```objectivec
//consider this as your fileupload control
<input type="file" id="imgUpload">

//in a handler or in a function you could get a reference to it, if you've selected a file
var fileData = $('#imgUpload')[0].files[0];

//create file object
var file = new Appacitive.File({
  fileId: fileData.name,
fileData: fileData
});
```
Here, we gave the fileId as the name of the original file. There're three things to be noted :

1. If you don't provide a fileId, a unique id for the file is generated and saved by the server.

2. If you provide a fileId which already exists on the server, then on saving, this new file will replace the old file.

3. If you don't provide contentType, then the SDK will infer it from the fileData object or set it as text/plain.

#### Custom Upload

If you want to upload a file without using SDK, you can get an upload URL by calling its instance method `getUploadUrl`, and simply upload your file onto this url.
```objectivec
file.getUploadUrl().then(function(url) {
   //alert("Upload url:" + url);
});
```

### Uploading

Once you're done creating `Appacitive.File` object, simply call save to save it on the server.
```objectivec
// save it on server
file.save().then(function(url) {
  alert('Download url is ' + url);
});
```

After save, the onSuccess callback gets a url in response which can be saved in your object and is also reflected in the file object. This url is basically a download url which you could use to render it in your DOM.

```objectivec
//file object after upload
{
  fileId: 'test.png',
  contentType: 'image/png',
  url: '{{some url}}'
}

//if you don't provide fileId while upload, then you'll get a unique fileId set in you file object
{
  fileId: '3212jgfjs93798',
  contentType: 'image/png',
  url: '{{some url}}'
}
```

### Downloading

Using the method `getDownloadUrl` in file object you can download a file which was uploaded to the Appacitive system.

To construct the instance of `Appacitive.File`, you will need to provide the fileId of the file, which was returned by the system or set by you when you uploaded the file.
```objectivec
//create file object
var file = new Appacitive.File({
  fileId: "test.png"
});

// call to get donwload url
file.getDownloadUrl().then(function(url) {
alert("Download url:" + url);
$("#imgUpload").attr('src',file.url);
});
```
