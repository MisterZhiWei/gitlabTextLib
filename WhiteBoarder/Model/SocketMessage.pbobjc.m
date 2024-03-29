// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: SocketMessage.proto

// This CPP symbol can be defined to use imports that match up to the framework
// imports needed when using CocoaPods.
#if !defined(GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS)
#define GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS 0
#endif

#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
#import <Protobuf/GPBProtocolBuffers_RuntimeSupport.h>
#else
#import "GPBProtocolBuffers_RuntimeSupport.h"
#endif

#import <stdatomic.h>

#import "SocketMessage.pbobjc.h"
// @@protoc_insertion_point(imports)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - SocketMessageRoot

@implementation SocketMessageRoot

// No extensions in the file and no imports, so no need to generate
// +extensionRegistry.

@end

#pragma mark - SocketMessageRoot_FileDescriptor

static GPBFileDescriptor *SocketMessageRoot_FileDescriptor(void) {
    // This is called by +initialize so there is no need to worry
    // about thread safety of the singleton.
    static GPBFileDescriptor *descriptor = NULL;
    if (!descriptor) {
        GPB_DEBUG_CHECK_RUNTIME_VERSIONS();
        descriptor = [[GPBFileDescriptor alloc] initWithPackage:@""
                                                         syntax:GPBFileSyntaxProto3];
    }
    return descriptor;
}

#pragma mark - Enum SCScoketMessageType

GPBEnumDescriptor *SCScoketMessageType_EnumDescriptor(void) {
    static _Atomic(GPBEnumDescriptor*) descriptor = nil;
    if (!descriptor) {
        static const char *valueNames =
        "Unknown\000Heartbeat\000Kicked\000Enter\000Data\000Hist"
        "ory\000Start\000End\000Patch\000Failed\000Receipt\000Image"
        "\000Cleanup\000";
        static const int32_t values[] = {
            SCScoketMessageType_Unknown,
            SCScoketMessageType_Heartbeat,
            SCScoketMessageType_Kicked,
            SCScoketMessageType_Enter,
            SCScoketMessageType_Data,
            SCScoketMessageType_History,
            SCScoketMessageType_Start,
            SCScoketMessageType_End,
            SCScoketMessageType_Patch,
            SCScoketMessageType_Failed,
            SCScoketMessageType_Receipt,
            SCScoketMessageType_Image,
            SCScoketMessageType_Cleanup,
        };
        GPBEnumDescriptor *worker =
        [GPBEnumDescriptor allocDescriptorForName:GPBNSStringifySymbol(SCScoketMessageType)
                                       valueNames:valueNames
                                           values:values
                                            count:(uint32_t)(sizeof(values) / sizeof(int32_t))
                                     enumVerifier:SCScoketMessageType_IsValidValue];
        GPBEnumDescriptor *expected = nil;
        if (!atomic_compare_exchange_strong(&descriptor, &expected, worker)) {
            [worker release];
        }
    }
    return descriptor;
}

BOOL SCScoketMessageType_IsValidValue(int32_t value__) {
    switch (value__) {
        case SCScoketMessageType_Unknown:
        case SCScoketMessageType_Heartbeat:
        case SCScoketMessageType_Kicked:
        case SCScoketMessageType_Enter:
        case SCScoketMessageType_Data:
        case SCScoketMessageType_History:
        case SCScoketMessageType_Start:
        case SCScoketMessageType_End:
        case SCScoketMessageType_Patch:
        case SCScoketMessageType_Failed:
        case SCScoketMessageType_Receipt:
        case SCScoketMessageType_Image:
        case SCScoketMessageType_Cleanup:
            return YES;
        default:
            return NO;
    }
}

#pragma mark - SCSocketMessage

@implementation SCSocketMessage

@dynamic type;
@dynamic bodyArray, bodyArray_Count;

typedef struct SCSocketMessage__storage_ {
    uint32_t _has_storage_[1];
    SCScoketMessageType type;
    NSMutableArray *bodyArray;
} SCSocketMessage__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
    static GPBDescriptor *descriptor = nil;
    if (!descriptor) {
        static GPBMessageFieldDescription fields[] = {
            {
                .name = "type",
                .dataTypeSpecific.enumDescFunc = SCScoketMessageType_EnumDescriptor,
                .number = SCSocketMessage_FieldNumber_Type,
                .hasIndex = 0,
                .offset = (uint32_t)offsetof(SCSocketMessage__storage_, type),
                .flags = (GPBFieldFlags)(GPBFieldOptional | GPBFieldHasEnumDescriptor),
                .dataType = GPBDataTypeEnum,
            },
            {
                .name = "bodyArray",
                .dataTypeSpecific.className = GPBStringifySymbol(SCSocketContentMessage),
                .number = SCSocketMessage_FieldNumber_BodyArray,
                .hasIndex = GPBNoHasBit,
                .offset = (uint32_t)offsetof(SCSocketMessage__storage_, bodyArray),
                .flags = GPBFieldRepeated,
                .dataType = GPBDataTypeMessage,
            },
        };
        GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SCSocketMessage class]
                                     rootClass:[SocketMessageRoot class]
                                          file:SocketMessageRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SCSocketMessage__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if defined(DEBUG) && DEBUG
        NSAssert(descriptor == nil, @"Startup recursed!");
#endif  // DEBUG
        descriptor = localDescriptor;
    }
    return descriptor;
}

@end

int32_t SCSocketMessage_Type_RawValue(SCSocketMessage *message) {
    GPBDescriptor *descriptor = [SCSocketMessage descriptor];
    GPBFieldDescriptor *field = [descriptor fieldWithNumber:SCSocketMessage_FieldNumber_Type];
    return GPBGetMessageInt32Field(message, field);
}

void SetSCSocketMessage_Type_RawValue(SCSocketMessage *message, int32_t value) {
    GPBDescriptor *descriptor = [SCSocketMessage descriptor];
    GPBFieldDescriptor *field = [descriptor fieldWithNumber:SCSocketMessage_FieldNumber_Type];
    GPBSetInt32IvarWithFieldInternal(message, field, value, descriptor.file.syntax);
}

#pragma mark - SCSocketContentMessage

@implementation SCSocketContentMessage

@dynamic roomid;
@dynamic index;
@dynamic msgid;
@dynamic timestamp;
@dynamic from;
@dynamic to;
@dynamic contentArray, contentArray_Count;

typedef struct SCSocketContentMessage__storage_ {
    uint32_t _has_storage_[1];
    NSString *roomid;
    NSString *from;
    NSString *to;
    NSMutableArray *contentArray;
    int64_t index;
    int64_t msgid;
    int64_t timestamp;
} SCSocketContentMessage__storage_;

// This method is threadsafe because it is initially called
// in +initialize for each subclass.
+ (GPBDescriptor *)descriptor {
    static GPBDescriptor *descriptor = nil;
    if (!descriptor) {
        static GPBMessageFieldDescription fields[] = {
            {
                .name = "roomid",
                .dataTypeSpecific.className = NULL,
                .number = SCSocketContentMessage_FieldNumber_Roomid,
                .hasIndex = 0,
                .offset = (uint32_t)offsetof(SCSocketContentMessage__storage_, roomid),
                .flags = GPBFieldOptional,
                .dataType = GPBDataTypeString,
            },
            {
                .name = "index",
                .dataTypeSpecific.className = NULL,
                .number = SCSocketContentMessage_FieldNumber_Index,
                .hasIndex = 1,
                .offset = (uint32_t)offsetof(SCSocketContentMessage__storage_, index),
                .flags = GPBFieldOptional,
                .dataType = GPBDataTypeInt64,
            },
            {
                .name = "msgid",
                .dataTypeSpecific.className = NULL,
                .number = SCSocketContentMessage_FieldNumber_Msgid,
                .hasIndex = 2,
                .offset = (uint32_t)offsetof(SCSocketContentMessage__storage_, msgid),
                .flags = GPBFieldOptional,
                .dataType = GPBDataTypeInt64,
            },
            {
                .name = "timestamp",
                .dataTypeSpecific.className = NULL,
                .number = SCSocketContentMessage_FieldNumber_Timestamp,
                .hasIndex = 3,
                .offset = (uint32_t)offsetof(SCSocketContentMessage__storage_, timestamp),
                .flags = GPBFieldOptional,
                .dataType = GPBDataTypeInt64,
            },
            {
                .name = "from",
                .dataTypeSpecific.className = NULL,
                .number = SCSocketContentMessage_FieldNumber_From,
                .hasIndex = 4,
                .offset = (uint32_t)offsetof(SCSocketContentMessage__storage_, from),
                .flags = GPBFieldOptional,
                .dataType = GPBDataTypeString,
            },
            {
                .name = "to",
                .dataTypeSpecific.className = NULL,
                .number = SCSocketContentMessage_FieldNumber_To,
                .hasIndex = 5,
                .offset = (uint32_t)offsetof(SCSocketContentMessage__storage_, to),
                .flags = GPBFieldOptional,
                .dataType = GPBDataTypeString,
            },
            {
                .name = "contentArray",
                .dataTypeSpecific.className = NULL,
                .number = SCSocketContentMessage_FieldNumber_ContentArray,
                .hasIndex = GPBNoHasBit,
                .offset = (uint32_t)offsetof(SCSocketContentMessage__storage_, contentArray),
                .flags = GPBFieldRepeated,
                .dataType = GPBDataTypeString,
            },
        };
        GPBDescriptor *localDescriptor =
        [GPBDescriptor allocDescriptorForClass:[SCSocketContentMessage class]
                                     rootClass:[SocketMessageRoot class]
                                          file:SocketMessageRoot_FileDescriptor()
                                        fields:fields
                                    fieldCount:(uint32_t)(sizeof(fields) / sizeof(GPBMessageFieldDescription))
                                   storageSize:sizeof(SCSocketContentMessage__storage_)
                                         flags:GPBDescriptorInitializationFlag_None];
#if defined(DEBUG) && DEBUG
        NSAssert(descriptor == nil, @"Startup recursed!");
#endif  // DEBUG
        descriptor = localDescriptor;
    }
    return descriptor;
}

@end


#pragma clang diagnostic pop

// @@protoc_insertion_point(global_scope)
