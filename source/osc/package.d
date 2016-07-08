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
// struct AddressPattern {
//     public{
//     }//public
//
//     private{
//         AddressPart[] _parts;
//     }//private
// }//struct AddressPattern
alias  AddressPattern = AddressPart[];

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
    return addressPattern.isMatchRec(addressSpace._container);
}

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

