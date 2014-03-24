//
//  APQuery.m
//  Appacitive-iOS-SDK
//
//  Created by Kauserali Hafizji on 05/09/12.
//  Copyright (c) 2012 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "APQuery.h"

#pragma mark - APBaseQuery

@implementation APBaseQuery

- (NSString*)stringValue {
    if([self isKindOfClass:[APSimpleQuery class]])
        return [(APSimpleQuery*)self stringValue];
    else if([self isKindOfClass:[APCompoundQuery class]])
        return [(APCompoundQuery*)self stringValue];
    else
        return nil;
}

@end

#pragma mark - SimpleQuery

@implementation APSimpleQuery

- (NSString*) stringValue {
    if(self.fieldName != nil && self.fieldType != nil && self.operation != nil && self.value != nil)
        return [NSString stringWithFormat:@"%@ %@ %@",
                [self getFormattedFieldNameFor:self.fieldName  WithFieldType:self.fieldType],
                self.operation,
                self.value];
    return nil;
}

- (NSString*) getFormattedFieldNameFor:(NSString*)name WithFieldType:(NSString*)type {
    if ([type isEqualToString:@"attribute"])
        return [NSString stringWithFormat:@"@%@",name];
    else if ([type isEqualToString:@"aggregate"])
        return [NSString stringWithFormat:@"$%@",name];
    else if ([type isEqualToString:@"property"])
        return [NSString stringWithFormat:@"*%@",name];
    else
        return [NSString stringWithFormat:@"%@",name];
}

@end

#pragma mark - CompundQuery

@implementation APCompoundQuery

- (instancetype) init {
    _innerQueries = [[NSMutableArray alloc] init];
    return self;
}

- (NSString*) stringValue {
    NSString *query = [[NSString alloc] init];
    query = @"(";
    for(int i =0; i<self.innerQueries.count-1; i++)
        if(self.boolOperator == kAnd)
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%@ AND ",[self.innerQueries[i] stringValue]]];
        else {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%@ OR ",[self.innerQueries[i] stringValue]]];
        }
    query = [query stringByAppendingString:[NSString stringWithFormat:@"%@)",[[self.innerQueries lastObject] stringValue]]];
    return query;
}

@end

#pragma mark - QueryExpression

@implementation APQueryExpression

- (instancetype) initWithProperty:(NSString*)name ofType:(NSString*)type {
    _type = type;
    _name = name;
    return self;
}

- (APSimpleQuery *) isEqualTo:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"==";
        query.value = [NSString stringWithFormat:@"'%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isEqualToDate:(NSDate*)date {
    if(date != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"==";
        query.value = [NSString stringWithFormat:@"date('%@')",date];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isNotEqualTo:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"<>";
        query.value = [NSString stringWithFormat:@"'%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isNotEqualToDate:(NSDate*)date {
    if(date != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"<>";
        query.value = [NSString stringWithFormat:@"date('%@')",date];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isLike:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"like";
        query.value = [NSString stringWithFormat:@"'%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) startsWith:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"like";
        query.value = [NSString stringWithFormat:@"'%@*'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) endsWith:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"like";
        query.value = [NSString stringWithFormat:@"'*%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) matches:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"match";
        query.value = [NSString stringWithFormat:@"'%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isGreaterThan:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @">";
        query.value = [NSString stringWithFormat:@"'%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isLessThan:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"<";
        query.value = [NSString stringWithFormat:@"'%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isGreaterThanOrEqualTo:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @">=";
        query.value = [NSString stringWithFormat:@"'%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isLessThanOrEqualTo:(NSString*)value {
    if (value != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"<=";
        query.value = [NSString stringWithFormat:@"'%@'",value];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isBetween:(NSString*)value1 and:(NSString*)value2 {
    if (value1 != nil && value2 != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"between";
        query.value = [NSString stringWithFormat:@"('%@','%@')",value1,value2];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isGreaterThanDate:(NSDate*)date {
    if (date != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @">";
        query.value = [NSString stringWithFormat:@"date('%@')",date];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isLessThanDate:(NSDate*)date {
    if (date != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"<";
        query.value = [NSString stringWithFormat:@"date('%@')",date];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isGreaterThanOrEqualToDate:(NSDate*)date {
    if (date != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @">=";
        query.value = [NSString stringWithFormat:@"date('%@')",date];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isLessThanOrEqualToDate:(NSDate*)date {
    if (date != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"<=";
        query.value = [NSString stringWithFormat:@"date('%@')",date];
        return query;
    }
    return nil;
}

- (APSimpleQuery *) isBetweenDates:(NSDate*)date1 and:(NSDate*)date2 {
    if (date1 != nil && date2 != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = _name;
        query.fieldType = _type;
        query.operation = @"between";
        query.value = [NSString stringWithFormat:@"(date('%@'),date('%@'))",date1,date2];
        return query;
    }
    return nil;
}

@end

#pragma mark - QueryString

@implementation APQuery

- (void) queryWithSearchUsingFreeText:(NSArray*)freeTextTokens {
    if (freeTextTokens != nil && freeTextTokens.count > 0) {
        __block NSString *queryString = @"freeText=";
        [freeTextTokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                queryString = [queryString stringByAppendingString:obj];
                if(idx != freeTextTokens.count - 1) {
                    queryString = [queryString stringByAppendingString:@" "];
                }
            }
        }];
        _freeText = queryString;
    }
    else _freeText = nil;
}

- (NSString*)stringValue {
    NSString *queryString = [[NSString alloc] init];
    queryString = @"?";
    if(self.propertiesToFetch != nil && self.propertiesToFetch.count > 0) {
        queryString = [queryString stringByAppendingString:@"fields="];
        for(int i = 0; i < self.propertiesToFetch.count; i++)
            queryString = [queryString stringByAppendingFormat:@"%@,",self.propertiesToFetch[i]];
        queryString = [queryString stringByAppendingString:@"&"];
    }
    if(self.pageNumber)
        queryString = [queryString stringByAppendingFormat:@"pnum=%ld&",(long)self.pageNumber];
    if(self.pageSize)
        queryString = [queryString stringByAppendingFormat:@"psize=%ld&",(long)self.pageSize];
    if(self.orderBy != nil && ![[self.orderBy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        if(self.isAsc == YES)
            queryString = [queryString stringByAppendingFormat:@"orderBy=%@&isAsc=false&",self.orderBy];
        else
            queryString = [queryString stringByAppendingFormat:@"orderBy=%@&isAsc=true&",self.orderBy];
    }
    if(self.freeText)
        queryString = [queryString stringByAppendingFormat:@"%@&",self.freeText];
    if(self.filterQuery != nil)
        queryString = [queryString stringByAppendingFormat:@"query=%@",[self.filterQuery stringValue]];
    if([queryString hasSuffix:@"&"])
        queryString = [queryString substringToIndex:[queryString length]-1];
    return queryString;
}

+ (APQueryExpression*) queryExpressionWithProperty:(NSString*)propertyName {
    return [[APQueryExpression alloc] initWithProperty:propertyName ofType:@"property"];
}

+ (APQueryExpression*) queryExpressionWithAttribute:(NSString*)attributeName {
    return [[APQueryExpression alloc] initWithProperty:attributeName ofType:@"attribute"];
}

+ (APQueryExpression*) queryExpressionWithAggregate:(NSString*)aggregateName {
    return [[APQueryExpression alloc] initWithProperty:aggregateName ofType:@"aggergate"];
}

+ (APCompoundQuery *) booleanAnd:(NSArray*)queries {
    APCompoundQuery* compoundQuery = [[APCompoundQuery alloc] init];
    compoundQuery.boolOperator = kAnd;
    [[compoundQuery innerQueries] addObjectsFromArray:queries];
    return compoundQuery;
}

+ (APCompoundQuery *) booleanOr:(NSArray*)queries {
    APCompoundQuery* compoundQuery = [[APCompoundQuery alloc] init];
    compoundQuery.boolOperator = kOr;
    [[compoundQuery innerQueries] addObjectsFromArray:queries];
    return compoundQuery;
}

+ (APSimpleQuery*) queryWithRadialSearchForProperty:(NSString*)propertyName nearLocation:(CLLocation*)location withinRadius:(NSNumber*)radius usingDistanceMetric:(DistanceMetric)distanceMetric {
    if(location != nil && radius != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = propertyName;
        query.fieldType = @"property";
        query.operation = @"within_circle";
        
        query.value = [NSString stringWithFormat:@"%lf, %lf, %lf", location.coordinate.latitude, location.coordinate.longitude, radius.doubleValue];
        if (distanceMetric == kKilometers) {
            query.value = [query.value stringByAppendingFormat:@" km"];
        } else {
            query.value = [query.value stringByAppendingFormat:@" m"];
        }
        return query;
    }
    return nil;
}

+ (APSimpleQuery*) queryWithPolygonSearchForProperty:(NSString*)propertyName withPolygonCoordinates:(NSArray*)coordinates {
    if (coordinates != nil && coordinates.count >= 3) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = propertyName;
        query.fieldType = @"property";
        query.operation = @"within_polygon";
        query.value = [[NSString alloc] init];
        
        for(int idx = 0; idx < coordinates.count; idx++) {
            if ([coordinates[idx] isKindOfClass:[CLLocation class]]) {
                CLLocation *location = (CLLocation*)coordinates[idx];
                query.value = [query.value stringByAppendingFormat:@"%lf,%lf", location.coordinate.latitude, location.coordinate.longitude];
                if (idx != coordinates.count - 1) {
                    query.value = [query.value stringByAppendingString:@"|"];
                }
            }
        }
        return query;
    }
    return nil;
}

+ (APSimpleQuery*) queryWithSearchUsingOneOrMoreTags:(NSArray*)tags {
    if (tags != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = @"";
        query.fieldType = @"";
        query.operation = @"tagged_with_one_or_more";
        
        __block NSString *valString = @"('";
        [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                valString = [valString stringByAppendingFormat:@"%@", obj];
                if (idx != tags.count - 1) {
                    valString = [valString stringByAppendingString:@","];
                } else {
                    valString = [valString stringByAppendingString:@"')"];
                }
            }
        }];
        query.value = valString;
        return query;
    }
    return nil;
}

+ (APSimpleQuery*) queryWithSearchUsingAllTags:(NSArray*)tags {
    if (tags != nil) {
        APSimpleQuery *query = [[APSimpleQuery alloc] init];
        query.fieldName = @"";
        query.fieldType = @"";
        query.operation = @"tagged_with_all";
        
        __block NSString *valString= @"('";
        [tags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[NSString class]]) {
                valString = [valString stringByAppendingFormat:@"%@", obj];
                if (idx != tags.count - 1) {
                    valString = [valString stringByAppendingString:@","];
                } else {
                    valString = [valString stringByAppendingString:@"')"];
                }
            }
        }];
        query.value = valString;
        return query;
    }
    return nil;
}

@end
