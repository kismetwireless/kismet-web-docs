---
title: "Tracked components"
description: ""
lead: ""
date: 2022-11-11T00:54:43-05:00
lastmod: 2022-11-11T00:54:43-05:00
images: []
menu:
  docs:
    parent: ""
    identifier: "tracked_components-0cc6234f32d0c11e2290064dc927e428"
weight: 999
toc: true
---

Kismet manages complex objects with arbitrary serialization and logging by implementing "tracked elements"; Tracked elements are introspectable in C++ and can be dynamically exported to other formats via the serialization API, such as JSON which is used heavily in the web interface.

Tracked elements represent a compromise between the efficiency of native C++ types and the necessity of dynamic data handling and serialization.

Unless you are writing a native C++ plugin, you do not need to worry about tracked elements at all; if you ARE, then there are some guidelines to follow.

## Anatomy of a tracker_element

Generally speaking a plugin should not define a new `tracker_element` itself, it should implement a `tracked_component` (more on these in the next section); however they form the basic building blocks of both `tracked_component` and of the data held by custom components.

All tracked elements are derived from `tracker_element`; This super-class contains no actual data storage.

Via subclassing and templates, `tracker_element` implements basic scalar data types (non-POD basic data types such as `std::string`, `uuid`, `mac_addr` and similar), basic numeric types of the standard sizes (`uint8_t` through `uint64_t`, 4-byte `float` and 8-byte `double`), and various complex data types such as `vector` and `map`.  Optimized versions of vectors and maps are provided for common combinations.

`tracker_element` subtypes are named accordingly, i.e.:

* `tracker_element_string`
* `tracker_element_uint8`
* `tracker_element_int32`
* `tracker_element_vector`
* `tracker_element_double_map`

and can be found in `tracked_element.h`.

### Vectors and Maps

`tracker_element` represents complex data types in two main formats:

1. A `vector` or `map` (typically implemented as an unordered map or as a robinhood hash map for high speed access) of `tracker_element` records.  This allows constructing complex dictionary-like or list-like records of arbitrary fields, `tracked_component` complex records, MAC addresses, and so on.
2. Optimized containers like `tracked_element_vector_double` and `tracked_element_double_map_double` which contain, respectively, raw `double` values and raw `double:double` key:value pairs.  Other, similar containers are also defined.

If your plugin stores purely numerical data, such as a vector of signal values, it is *significantly* more efficient to use the `tracked_element_vector_double` (or equivalent DoubleMapDouble) objects, and will consume less than half the RAM using a traditional `tracker_element_vector` would use.

Each `tracker_element` derivative also contains:

1. A `trackertype::...` type which enforces type-safety on get/set operations
2. A `uint32_t` signature which is used to enforce type-safety on complex types
3. An optional local name
4. A 16-bit unique ID which is used to map the field name
5. A reset function used to reset the object when it is recycled

Each derived type contains:

1. A get/set function for its type
2. Optional `coercive_set` functions which allow importing generic types (such as strings to UUID or mac_addr, and various precision numbers to numeric types)
3. A `clone_type` function which is responsible for returning a `std::shared_ptr` instance of a new object of this type, which is integral to the field creation and tracking system.
4. Optional additional support functions, such as standard STL iterator implementations for vector and map elements

## `tracker_element` Lifecycle

`tracker_elements` are nearly always stored and processed as C++11 `std::shared_ptr` smart-pointer managed objects.  This allows usage counting and automatic deletion of a `tracker_element`, which may be found hosted in many dynamic representations of data over its lifecycle.

To reduce RAM fragmentation, memory allocation tracking, and generally improve performance, all basic tracker_element types are maintained in dynamic object pools where they are automatically cached and reset.

Tracked elements can be manually created from the pool using the `Globalreg::new_from_pool<type>()` system.

It is almost never necessary (or wise, or even possible) to create a naked `tracked_element` or a naked `tracked_element *` pointer.

## `tracker_component`

A `tracker_component` is derived from a `tracked_element_map`, which implements a dictionary of fields.

Collections of data maintained and exposed by a plugin should be derived from the `tracker_component` class; Kismet uses this class to maintain all internal state about devices and other data, and a `tracker_component` can be directly inserted into an existing device record.

The `tracker_component` also implements a collection of helper macros which will automatically define getter/setter functions, with optional casting, as well as support for dynamic field creation on first use.

The `tracker_component` has all of the existing `tracked_element` features, but also specifies two additional core functions:

1. `register_fields()` which is called during construction and is responsible for defining all the fields that this object needs (typically using the `register_field` function)
2. `reserve_fields(std::shared_ptr<TrackerElement> e)` which is called during construction and is responsible for allocating any *custom fields* which cannot, for some reason, be allocated automatically by the registration system.  Typically the only actions which are needed here are re-typing complex fields during loading from stored data.

Tracker components can be registered with the global object pools via `Globalreg::enable_pool_type` (defined in `globalregistry.h`).  If registered in the object pool, it *must* define the `reset()` method.

## Deriving from `tracker_component`

Any data you wish to expose as an object must be derived from `tracker_component`.  To do this, there are a number of functions you must implement.

### First, the Boilerplate:

For our example, we want to mimic the behavior of the Kismet messagebus so that we can display messages on the web UI.

We need to create a message record which has a timestamp, the message content, and a set of flags.

```C++
class web_tracked_message : public tracker_component {
public:
    // tracker_component base constructor
    web_tracked_message() :
    tracker_component() {
        // We always have to call register and reserve
        register_fields();
        reserve_fields(NULL);
    }

    // Constructor which takes the ID
    web_tracked_message(int in_id) :
    tracker_component(in_id) {
        // We always have to call register and reserve
        register_fields();
        reserve_fields(NULL);
    }

    // The final default constructor, which takes both and ID and a pointer to
    // existing object data; this is used to craft a custom object from a base
    // which already contains these fields; this can happen when loading stored
    // data or deserializing IPC data
    web_tracked_message(int in_id, std::shared_ptr<TrackerElement> e) :
        tracker_component(in_id) {
        // Again the register and reserve, but this time we pass the
        // pre-existing element to the reserve_fields object
        register_fields();
        reserve_fields(e);
    }

    // We need to provide a signature for this type, since all tracker_components
    // are TrackerType::TrackerMap at their base; typically this signature can be
    // a quick checksum of the type name.
    virtual uint32_t get_signature() const override {
        return adler32_checksum("web_tracked_message");
    }

    // We need to provide the clone type function; in this case we can decide if we
    // want to generate the new object from the global pool or from a std::make_shared.
    // In this case we'll use pools.
    virtual std::shared_ptr<tracker_element> clone_type() override {
        using this_t = typename std::remove_pointer<decltype(this)>::type;
        auto r = Globalreg::new_from_pool<this_t>();
        r->set_id(this->get_id());
        return r;
    }

    // Since we're using the object pool, we have to provide a reset function; we'll
    // call reset on our fields (defined next)
    virtual void reset() override {
        timestamp->reset();
        message->reset();
        flags->reset();
    }

}
```

This creates a tracked object, but there is nothing inside of it.  To do that, we need to add some data fields.

### TrackerElement Fields

For fields that are always present, we only need to track the field itself.  Lets define some basic type fields; notice that we always define them as `std::shared_ptr`, and that we use the proper `TrackerElementXyz` sub-type for each.

```C++
protected:
	std::shared_ptr<tracker_element_uint64> timestamp;
	std::shared_ptr<tracker_element_string> message;
	std::shared_ptr<tracker_element_int32> flags;
```

### Registering Fields

To actually use the fields, they need to be initialized with a type and name.  This is done in the `register_fields()` class method.

```C++
protected:
    virtual void register_fields() override {
        // Call the parent register_fields() function, you MUST do this
        tracker_component::register_fields();

        register_field("webmsg.message.timestamp", "message timestamp", &timestampt);
        register_field("webmsg.message.message", "message content", &message);
        register_field("webmsg.message.flags", "message flags", &flags);
    }
```

`register_field(...)` is part of the base tracker_component class, and handles the connection between a tracked data set and the tracking system which assigns fields.

To register a field, you need:

1. A field name (which must be unique, you can ensure uniqueness by including your plugin type in the name; Kismet uses basic namespacing conventions to keep fields unique)
2. A human-readable description; this will be shown in the tracked_fields page and is helpful for future developers and consumers of your API
3. A *pointer* to the *shared pointer* where your field resides.  This allows the field registration system to automatically create your fields and place them in your variables for you.

`register_field` will return the internal id of the field which is created - most of the time this is not necessary, however when registering more complex objects or a dynamic object it may be necessary to save this ID.

### Accessing the Data:  Proxy Functions

Now that we have some data structures, we need to define how to access them.

It's certainly possible to define your own get/set methods, but there are some macros to help you.

The `__Proxy(...)` macro allows easy definition of a handful of methods in one line, at the expense of slightly obtuse syntax:

`__Proxy(name, tracker type, input type, return type, variable)`

This expands to define get and set functions (get_*name* and set_*name*) which accept *input type* variables and return *return type*, while automatically casting it to the type required by the tracker_element, indicated by *tracker type*.

What this really allows you to define in a single line cast-conversions between compatible types and define standard get/set mechanisms.  For example, for a simple unsigned int element, `flags`, defined as `tracker_uint32`, you might use:

```C++
public:
    __Proxy(flags, uint32_t, uint32_t, uint32_t, flags);
```

This would expand to define:

```C++
public:
    virtual uint32_t get_flags() const {
        return (uint32_t) get_tracker_value<uint32_t>(flags);
    }
    virtual void set_flags(uint32_t in) {
        flags->set((uint32_t) in);
    }
```

This looks fairly standard, but allows for more interesting behavior to be defined simply.  For instance, we want to hold a standard unix timestamp (`time_t`) in the timestamp field, however there is no tracker_element primitive for timestamps.  However, if we do the following:

```C++
public:
    __Proxy(timestamp, uint64_t, time_t, time_t, timestamp);
```

Now we have a get and set pair of functions which accept `time_t` and transparently cast it to a `uint64_t` when saving or reading from the tracker_element variable.  The same trick can be used to make automatic get and set functions for any data type which can be cast directly to the internal tracked type.

Additionally, individual get and set functions can be proxied via `__ProxyGet(...)` and `__ProxySet(...)` if you wish to only expose the get or set, or if you provide a custom get or set function which is more complex.  Numerical values can also define `__ProxyIncDec(...)` or `__ProxyAddSub(...)` to generate increment/decrement (++ and --) and addition/subtraction functions automatically.  Fields which represent a bitset can use `__ProxyBitset(...)` to define bitwise set and clear functions.

There are some other tricks for accessing data which is represented by complex data types, we'll cover them later.

### Building from other Data Structures

Often you will want to automatically populate a tracked component from an existing data structure.

Due to how trackercomponents are generated, it is not possible to extend the constructors and import data that way, however creating a function for importing data is trivial, especially once the `__Proxy(...)` functions are defined.

To continue our Messagebus example, let's define a method for adapting a message to our tracker_component:

```C++
public:
    void set_from_message(string in_msg, int in_flags) {
        // Since we used __Proxy to define get and set functions, we'll
        // call them instead of doing custom get/set and risking doing
        // it wrong.

        set_timestamp(globalreg->timestamp.tv_sec);
        set_message(in_msg);
        set_flags(in_flags);
    }
```

#### Accessing from outside the object

It may be necessary to allow access from outside callers.  This is only required for other code directly accessing your object; for exporting your data via the REST interface and other serialization methods, so long as your data is in `tracker_element` objects it will be handled automatically.

If you do need to provide access to your data objects, there are several methods you can utilize:

##### Method one: Provide functions which interface to the complex type

In some instances you may wish to write methods which provide access to the complex type.  For example, assuming that `Sharedtracker_element example_vec` is a TrackerVector, and you wish to add the record `e` to it, it may make sense to implement access thusly:

```C++
public:
    void example_vec_push_back(Sharedtracker_element e) {
        example_vec->push_back(e);
    }
```

Essentially the same is hiding the internal data structure via your object API:  `add_foo(...)` may internally add to the vector, without ever explicitly exposing the actual data types.

##### Method two: Proxy the TrackedElement directly

By directly returning a pointer to the TrackedElement you can allow consumers to wrap the complex data themselves.  A proxy macro similar to the others is provided:

```C++
public:
    __ProxyTrackable(example_vec, TrackedElementVector, example_vec);
```

`__ProxyTrackable(...)` takes a name, and the type of shared pointer to return.  This can be used to automatically cast custom data objects to the proper type on access, here, we use TrackedElement and don't change anything.  Finally, it takes the variable.

A caller could use this via:

```C++
    ...
    TrackedElementVector ev(foo->get_example_vec);
    for (TrackedElementVector::iterator i = foo->begin;
            i != foo->end(); ++i) {
        ...
    }
    ...
```

## Serialization

Serialization is handled by the `tracker_component` and `tracker_element` system automatically.  Since the types of the fields are introspectable, serialization systems should be able to export nested data automatically.

The only aspect of serialization that a custom `tracker_component` class needs to consider is what happens prior to serialization.  This is handled by the `pre_serialize()` method, and is called by any serialization/export class.

This method allows the class to do any updating, averaging, etc before its contents are delivered to a REST endpoing, XML serialization, or other export.

For example, the RRD object uses this method to ensure that the data is synced to the current time:

```C++
public:
    virtual void pre_serialize() {
        // Always call the parent in case work needs to be done
        tracker_component::pre_serialize();

        // Call an internal function for adding a sample; we add '0' to our
        // current sample and set the time, this fast-forwards the RRD to
        // 'now' and computes history for us in case we didn't see an update
        // in a long time
        add_sample(0, time(0));
    }
```

### Using `tracker_component` objects elsewhere

Sometimes you will want to use a `tracker_component` in a class that is not, itself, a component: creating data for serialization is a good example.

`tracker_component` objects can be created and used as normal, with one important exception: The internal object management system expects them to be managed via `shared_ptr<>`.  Failure to pass the proper owning shared_ptr record can result in memory being freed prematurely.

One uncommon condition happens when implementing high-level global constructs which are, themselves, trackable elements:  for example, the `system_monitor` class provides its data by directly serializing itself.  This must be accounted for by creating a `create_xyz(...)` method and assigning the initial `shared_ptr<>` reference to a `GlobalRegistry` variable.

A more common condition is when creating temporary records for exporting, for instance, a temporary list of devices.  In these cases, the `shared_ptr<>` reference can be held by the calling function until the task is complete:

```C++

int foo::bar() {
    auto c = std::make_shared<some_component>(some_component_id);

    // Do stuff, 'c' is automatically freed when all references expire.
    // This can include passing it to a serializer, embedding it in an object
    // via add_map or similar, etc.

}
```

It is important to remember that due to the mechanics of `shared_ptr<>` that two shared pointers created referencing the same object *are not identical*.  There must be *one, single, canonical shared_ptr which defines an object*, and all other references must be copied from that pointer.  Attempting to cast an existing object to a `shared_ptr<>` or creating a `shared_ptr<>` from a `this` pointer will result in multiple usage counts to the same memory and premature freeing of the object.

### Dynamic fields

Since tracked objects tend to be used to assign attributes to devices, and there can be tens or hundreds of thousands of devices per session, it can be important to balance the demands on RAM with the demands on CPU.  Even a single `std::shared_ptr` to a field can consume up to 16 bytes of ram per device (two 8-byte pointers).

Kismet offers two, similar, ways to deal with this.
