#import <Foundation/NSString.h>
#include "DictionaryAdapter.h"
#include "DataWrapper.h"
#include "Helpers.h"
#include "Interop.h"
#include "Caches.h"

using namespace v8;
using namespace tns;

@interface DictionaryAdapterMapKeysEnumerator : NSEnumerator

- (instancetype)initWithMap:(std::shared_ptr<Persistent<Value>>)map isolate:(Isolate*)isolate;

@end

@implementation DictionaryAdapterMapKeysEnumerator {
    Isolate* isolate_;
    uint32_t index_;
    std::shared_ptr<Persistent<Value>> map_;
}

- (instancetype)initWithMap:(std::shared_ptr<Persistent<Value>>)map isolate:(Isolate*)isolate {
    if (self) {
        self->isolate_ = isolate;
        self->index_ = 0;
        self->map_ = map;
    }

    return self;
}

- (id)nextObject {
    Isolate* isolate = self->isolate_;
    Local<Context> context = isolate->GetCurrentContext();
    Local<v8::Array> array = self->map_->Get(isolate).As<Map>()->AsArray();

    if (self->index_ < array->Length() - 1) {
        Local<Value> key;
        bool success = array->Get(context, self->index_).ToLocal(&key);
        tns::Assert(success, isolate);
        self->index_ += 2;
        std::string keyStr = tns::ToString(self->isolate_, key);
        NSString* result = [NSString stringWithUTF8String:keyStr.c_str()];
        return result;
    }

    return nil;
}

- (void)dealloc {
    [super dealloc];
}

@end

@interface DictionaryAdapterObjectKeysEnumerator : NSEnumerator

- (instancetype)initWithProperties:(std::shared_ptr<Persistent<Value>>)dictionary isolate:(Isolate*)isolate;
- (Local<v8::Array>)getProperties;

@end

@implementation DictionaryAdapterObjectKeysEnumerator {
    Isolate* isolate_;
    std::shared_ptr<Persistent<Value>> dictionary_;
    NSUInteger index_;
}

- (instancetype)initWithProperties:(std::shared_ptr<Persistent<Value>>)dictionary isolate:(Isolate*)isolate {
    if (self) {
        self->isolate_ = isolate;
        self->dictionary_ = dictionary;
        self->index_ = 0;
    }

    return self;
}

- (Local<v8::Array>)getProperties {
    Local<Context> context = self->isolate_->GetCurrentContext();
    Local<v8::Array> properties;
    Local<Object> dictionary = self->dictionary_->Get(self->isolate_).As<Object>();
    tns::Assert(dictionary->GetOwnPropertyNames(context).ToLocal(&properties), self->isolate_);
    return properties;
}

- (id)nextObject {
    Isolate* isolate = self->isolate_;
    Local<Context> context = isolate->GetCurrentContext();
    Local<v8::Array> properties = [self getProperties];
    if (self->index_ < properties->Length()) {
        Local<Value> value;
        bool success = properties->Get(context, (uint)self->index_).ToLocal(&value);
        tns::Assert(success, isolate);
        self->index_++;
        std::string result = tns::ToString(self->isolate_, value);
        return [NSString stringWithUTF8String:result.c_str()];
    }

    return nil;
}

- (NSArray*)allObjects {
    Isolate* isolate = self->isolate_;
    Local<Context> context = isolate->GetCurrentContext();
    NSMutableArray* array = [NSMutableArray array];
    Local<v8::Array> properties = [self getProperties];
    for (int i = 0; i < properties->Length(); i++) {
        Local<Value> value;
        bool success = properties->Get(context, i).ToLocal(&value);
        tns::Assert(success, isolate);
        std::string result = tns::ToString(self->isolate_, value);
        [array addObject:[NSString stringWithUTF8String:result.c_str()]];
    }

    return array;
}

- (void)dealloc {
    [super dealloc];
}

@end

@implementation DictionaryAdapter {
    Isolate* isolate_;
    std::shared_ptr<Persistent<Value>> object_;
}

- (instancetype)initWithJSObject:(Local<Object>)jsObject isolate:(Isolate*)isolate {
    if (self) {
        self->isolate_ = isolate;
        std::shared_ptr<Caches> cache = Caches::Get(isolate);
        // TODO: Handle the lifetime of this persistent js object

        self->object_ = std::make_shared<Persistent<Value>>(isolate, jsObject);
        cache->Instances.emplace(self, self->object_);
        tns::SetValue(isolate, jsObject, new ObjCDataWrapper(self));
    }

    return self;
}

- (NSUInteger)count {
    Local<Object> obj = self->object_->Get(self->isolate_).As<Object>();

    if (obj->IsMap()) {
        return obj.As<Map>()->Size();
    }

    Local<Context> context = self->isolate_->GetCurrentContext();
    Local<v8::Array> properties;
    tns::Assert(obj->GetOwnPropertyNames(context).ToLocal(&properties), self->isolate_);

    uint32_t length = properties->Length();

    return length;
}

- (id)objectForKey:(id)aKey {
    Isolate* isolate = self->isolate_;
    Local<Context> context = isolate->GetCurrentContext();
    Local<Object> obj = self->object_->Get(self->isolate_).As<Object>();

    Local<Value> value;
    if ([aKey isKindOfClass:[NSNumber class]]) {
        unsigned int key = [aKey unsignedIntValue];
        bool success = obj->Get(context, key).ToLocal(&value);
        tns::Assert(success, isolate);
    } else if ([aKey isKindOfClass:[NSString class]]) {
        const char* key = [aKey UTF8String];
        Local<v8::String> keyV8Str = tns::ToV8String(isolate, key);

        if (obj->IsMap()) {
            Local<Context> context = isolate->GetCurrentContext();
            Local<Map> map = obj.As<Map>();
            bool success = map->Get(context, keyV8Str).ToLocal(&value);
            tns::Assert(success, isolate);
        } else {
            bool success = obj->Get(context, keyV8Str).ToLocal(&value);
            tns::Assert(success, isolate);
        }
    } else {
        // TODO: unsupported key type
        tns::Assert(false, isolate);
    }

    id result = Interop::ToObject(context, value);

    return result;
}

- (NSEnumerator*)keyEnumerator {
    Local<Value> obj = self->object_->Get(self->isolate_);

    if (obj->IsMap()) {
        return [[DictionaryAdapterMapKeysEnumerator alloc] initWithMap:self->object_ isolate:self->isolate_];
    }

    return [[DictionaryAdapterObjectKeysEnumerator alloc] initWithProperties:self->object_ isolate:self->isolate_];
}

- (void)dealloc {
    self->object_->Reset();
    [super dealloc];
}

@end
