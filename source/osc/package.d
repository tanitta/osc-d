module osc;
import osc.oscstring;
import osc.message;
import osc.timetag;

/++
+/
struct Packet {
    public{
        //TODO toString
        //TODO to!(ubyte[])
    }//public

    private{
        int _size;
        Bundle _bundle;
        Message _message;
    }//private
}//struct Packet

import std.datetime;
/++
+/
struct Bundle {
    public{
        ///
        this(in BundleElement[] bundleElement, in SysTime utcSysTime, in bool isImmediately = false){
            _timeTag = TimeTag(utcSysTime, isImmediately);
            _bundleElements = bundleElement;
        }
        
        ///
        string toString()const{
            return _opCast!string;
        }
        
        ///
        ubyte[] opCast(T:ubyte[])()const{
            return _opCast!T;
        }
        
        ///
        size_t size()const{
            import std.conv;
            import std.algorithm;
            return _header.size + 
                   _timeTag.size + 
                   _bundleElements.map!(e => e.size)
                                  .sum;
        }
    }//public

    private{
        immutable OscString!('\0') _header = OscString("#bundle");
        const TimeTag _timeTag;
        const BundleElement[] _bundleElements;
        
        T _opCast(T)()const{
            import std.conv;
            import std.algorithm;
            return _header.to!T ~
                   _timeTag.to!T ~
                   _bundleElements.map!(e => e.to!T)
                                  .fold!"a~b";
        }
    }//private
}//struct Bundle

/++
+/
//TODO support for bundle
struct BundleElement {
    public{
        this(in Message message){
            _hasMessage = true;
            _message = message;
            _size = message.size;
            
            import std.conv;
            import std.bitmanip;
            ubyte[] buffer = [0, 0, 0, 0];
            buffer.write!int(message.size.to!int, 0);
            _sizeUbyte = buffer;
        }
        
        //TODO support for bundle
        // this(in Bundle bundle){
        //     _bundle = bundle;
        // }
        
        
        ///
        string toString()const{
            import std.conv:to;
            import std.algorithm;
            if(_hasMessage){
                return _size.to!string ~ _message.to!string;
            }else{
                return "";
            }
            //TODO support for bundle
        }
        
        ///
        ubyte[] opCast(T:ubyte[])()const{
            import std.conv;
            if(_hasMessage){
                return _sizeUbyte ~ _message.to!(ubyte[]);
            }
            
            //TODO support for bundle
            if(_hasBundle){
                //TODO append size to bundle.
                return _bundle.to!(ubyte[]);
            }
        }
        
        size_t size()const{
            return _size;
        }
    }//public

    private{
        size_t _size;
        ubyte[] _sizeUbyte;
        bool _hasMessage = true;
        bool _hasBundle = true;
        const Message _message;
        const Bundle _bundle;
        
        // ubyte[] size()const{
        //     import std.bitmanip;
        //     ubyte[] buffer = [0, 0, 0, 0];
        //     buffer.write!int(_size, 0);
        //     return buffer;
        // }
    }//private
}//struct BundleElement



/++
+/
class Client {
    public{
    }//public

    private{
    }//private
}//class Client

/++
+/
class Server {
    public{
    }//public

    private{
        AddressSpace _addressSpace;
    }//private
}//class Server

/++
+/
class AddressSpace {
    public{
    }//public

    private{
        Container _container;
    }//private
}//class AddressSpace

///
bool isMatch(in AddressPattern addressPattern, const AddressSpace addressSpace){
    return addressPattern.isMatchRec(addressSpace._container);
}

// TODO enable to work pattern match.
///
private bool isMatchRec(in AddressPattern addressPattern, const Container container){
    if(addressPattern.length > 1){
        if(container.hasContainer(addressPattern[0].content)){
            return container.hasContainer(addressPattern[0].content) && addressPattern[1..$].isMatchRec(container._containers[addressPattern[0].content]);
        }else{
            return false;
        }
    }else{
        return container.hasMethod(addressPattern[0].content);
    }
}

unittest{
    auto addressSpace = new AddressSpace;
    addressSpace._container._containers["hoge"] = Container();
    addressSpace._container._containers["hoge"]._methods["moge"] = Method();
    
    {
        AddressPattern addressPattern = [AddressPart("hoge"), AddressPart("moge")];
        assert(addressPattern.isMatch(addressSpace));
    }
    
    {
        AddressPattern addressPattern = [AddressPart("hoge"), AddressPart("invalid")];
        assert(!addressPattern.isMatch(addressSpace));
    }
}

/++
+/
struct Container {
    public{
    }//public

    private{
        Container[string] _containers;
        Method[string] _methods;
        
            
    }//private
}//struct Container

///
bool hasMethod(in Container container, in string methodName){
    import std.algorithm;
    return container._methods.keys.canFind(methodName);
}

unittest{
    auto container = Container();
    assert(!container.hasMethod("hoge"));
    container._methods["hoge"] = Method();
    assert(container.hasMethod("hoge"));
}

///
bool hasContainer(in Container container, in string containerName){
    import std.algorithm;
    return container._containers.keys.canFind(containerName);
}

unittest{
    auto container = Container();
    assert(!container.hasContainer("hoge"));
    container._containers["hoge"] = Container();
    assert(container.hasContainer("hoge"));
}

/++
+/
struct Method {
    public{
    }//public

    private{
    }//private
}//struct Method

