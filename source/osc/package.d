module osc;
import osc.oscstring;

/++
+/
struct Packet {
    public{
    }//public

    private{
        int _size;
        Message _message;
        Bundle _bundle;
    }//private
}//struct Packet

/++
+/
struct Bundle {
    public{
    }//public

    private{
        OscString!('\0') _header = OscString("#bundle");
        // _timeTag
        //first size
        //first content
        
        //secont size
        //secont content 
    }//private
}//struct Bundle

/++
+/
struct BundleElement {
    public{
    }//public

    private{
        int _size;
        //content 
    }//private
}//struct BundleElement

/++
+/
struct Message {
    public{
    }//public

    private{
        AddressPattern _addressPattern;
        TypeTagString _typeTagString;
        // args
    }//private
}//struct Message

/++
+/
enum TypeTag {
    Int    = "i",
    Float  = "f",
    String = "s",
    Blob   = "b" 
}//enum TypeTag


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

// TODO
bool isMatch(in AddressPattern addressPattern, const AddressSpace addressSpace){
    return false;
}

// bool isMatchRec(in Container container, in AddressSpace addressSpace){
// }

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

