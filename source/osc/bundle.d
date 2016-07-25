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
            _bundleElements = bundleElements;
        }
        
        ///
        this(in ubyte[] bundle){
            _timeTag = TimeTag(bundle[8..16]);
            
            ubyte[] elements = bundle[16..$].dup;
            do{
                import std.bitmanip;
                ubyte[] sizeBuffer = elements[0..4];
                size_t size_n = sizeBuffer.read!uint;
                
                _bundleElements ~= BundleElement(elements[0..4+size_n]);
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
                   _bundleElements.map!(e => e.size)
                                  .sum;
        }
    }//public

    private{
        immutable OscString!('\0') _header = OscString("#bundle");
        const TimeTag _timeTag;
        BundleElement[] _bundleElements;
        
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
        
        //TODO support for bundle
        // this(in Bundle bundle){
        //     _bundle = bundle;
        // }
        
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
