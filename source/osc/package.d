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
        ///
        string toString()const{
            //TODO add args;
            import std.algorithm:map, fold;
            import std.conv;
            // return _addressPattern.to!string ~ _typeTagString.to!string ~ _args.fold!((a, b)=> a.to!string ~ b.to!string);
            return _addressPattern.map!(oStr=> oStr.to!string)
                                  .fold!((a, b)=> a~b)
                                  .to!string 
            ~ _typeTagString.to!string;
        }
        unittest{
            auto message = Message();
            message._addressPattern = [AddressPart("hoge"), AddressPart("moge")];
            import std.stdio; 
            import std.conv; 
            message.to!string.writeln;
        }

        ///
        ubyte[] opCast(T:ubyte[])(){
            //TODO add args;
            return _addressPattern.to!(ubyte[]) ~ _typeTagString.to!(ubyte[]);
        }
        unittest{
            auto message = Message();
            // message.to!string == 
        }
    }//public

    private{
        AddressPattern _addressPattern;
        TypeTagString _typeTagString;
        OscString!'\0'[] _args;
    }//private
}//struct Message



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

