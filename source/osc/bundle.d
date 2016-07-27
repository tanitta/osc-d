module osc.bundle;
import std.datetime;
import osc.oscstring;
import osc.timetag;
import osc.message;

/++
+/
struct Bundle {
    public{
        ///
        this(BundleElement[] bundleElements, in SysTime utcSysTime, in bool isImmediately = false){
            _timeTag = TimeTag(utcSysTime, isImmediately);
            _elements = bundleElements;
        }
        
        ///
        this(in ubyte[] bundle){
            _timeTag = TimeTag(bundle[8..16]);
            
            ubyte[] elements = bundle[16..$].dup;
            do{
                import std.bitmanip;
                size_t size_n = elements[0..4].peek!uint;
                
                _elements ~= BundleElement(elements[0..4+size_n]);
                elements = elements[4+size_n..$];
            }while(elements != []);
        }
        unittest{
            ubyte[] buffer = [35, 98, 117, 110, 100, 108, 101, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 32, 47, 111, 115, 99, 105, 108, 108, 97, 116, 111, 114, 47, 52, 47, 102, 114, 101, 113, 117, 101, 110, 99, 121, 0, 44, 102, 0, 0, 67, 222, 0, 0];
            auto bundle = Bundle(buffer);
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
                   _elements.map!(e => e.size)
                                  .sum;
        }
        
        ///
        const(BundleElement)[] elements()const{
            return _elements[];
        }
    }//public

    private{
        immutable OscString!('\0') _header = OscString("#bundle");
        const TimeTag _timeTag;
        BundleElement[] _elements;
        
        T _opCast(T)()const{
            import std.conv;
            import std.algorithm;
            return _header.to!T ~
                   _timeTag.to!T ~
                   _elements.map!(e => e.to!T)
                                  .fold!"a~b";
        }
    }//private
}//struct Bundle

unittest{
    ubyte[] b = [35, 98, 117, 110, 100, 108, 101, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 32, 47, 111, 115, 99, 105, 108, 108, 97, 116, 111, 114, 47, 52, 47, 102, 114, 101, 113, 117, 101, 110, 99, 121, 0, 44, 102, 0, 0, 67, 222, 0, 0];
    auto bundle = Bundle(b);
    
    assert(bundle.elements[0].message.addressPattern == [AddressPart("oscillator"), AddressPart("4"), AddressPart("frequency")]);
    assert(bundle.elements[0].message.typeTagString == TypeTagString("f"));
    import std.conv;
    assert(bundle.elements[0].message.args[0].to!float == 444.0f);
}

/++
+/
struct BundleElement {
    public{
        ///
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
        
        ///
        this(in Bundle bundle){
            _hasBundle = true;
            _bundle = bundle;
            _size = bundle.size;
            
            import std.conv;
            import std.bitmanip;
            ubyte[] buffer = [0, 0, 0, 0];
            buffer.write!int(bundle.size.to!int, 0);
            _sizeUbyte = buffer;
        }
        
        ///
        this(in ubyte[] bundleElement){
            _size = bundleElement.length-4;
            
            _hasBundle = bundleElement[4] == 0x23;
            _hasMessage = bundleElement[4] != 0x23;
            
            if(_hasBundle){
                _bundle = Bundle(bundleElement[4..$]);
            }
            if(_hasMessage){
                _message = Message(bundleElement[4..$]);
            }
        }
        
        ///
        string toString()const{
            import std.conv:to;
            import std.algorithm;
            if(_hasMessage){
                return _size.to!string ~ _message.to!string;
            }else if(_hasBundle){
                return _size.to!string ~ _bundle.to!string;
            }else{
                return "";
            }
        }
        
        ///
        ubyte[] opCast(T:ubyte[])()const{
            import std.conv;
            if(_hasMessage){
                return _sizeUbyte ~ _message.to!(ubyte[]);
            }else if(_hasBundle){
                return _sizeUbyte ~ _bundle.to!(ubyte[]);
            }else{
                return [];
            }
        }
        
        size_t size()const{
            return _size;
        }
        
        ///
        const(Message) message()const{
            return _message;
        }
        
        ///
        const(Bundle) bundle()const{
            return _bundle;
        }
        
        ///
        bool hasMessage()const{
            return _hasMessage;
        }
        
        ///
        bool hasBundle()const{
            return _hasBundle;
        }
    }//public

    private{
        size_t _size;
        ubyte[] _sizeUbyte;
        bool _hasMessage = true;
        bool _hasBundle = true;
        const Message _message;
        const Bundle _bundle;
    }//private
}//struct BundleElement
unittest{
    ubyte[] bundle = [35, 98, 117, 110, 100, 108, 101, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 32, 47, 111, 115, 99, 105, 108, 108, 97, 116, 111, 114, 47, 52, 47, 102, 114, 101, 113, 117, 101, 110, 99, 121, 0, 44, 102, 0, 0, 67, 222, 0, 0];
    ubyte[] size = [0, 0, 0, 0];
    import std.bitmanip;
    import std.conv;
    size.write!int(bundle.length.to!int, 0);
    auto bundleElement = BundleElement(size ~ bundle);
    
    assert(bundleElement.bundle.elements[0].message.addressPattern == [AddressPart("oscillator"), AddressPart("4"), AddressPart("frequency")]);
}
