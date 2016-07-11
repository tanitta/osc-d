module osc.message;
import osc.oscstring;

///
alias  AddressPattern = AddressPart[];

/++
+/
struct Message {
    public{
        ///
        string toString()const
        in{
            assert(_args.length > 0);
        }body{
            import std.algorithm:map, fold;
            import std.conv;
            // return _addressPattern.to!string ~ _typeTagString.to!string ~ _args.fold!((a, b)=> a.to!string ~ b.to!string);
            return _addressPattern.map!(oStr=> oStr.to!string)
                                  .fold!((a, b)=> a~b)
                                  .to!string
                 ~ _typeTagString.to!string
                 ~ _args.map!(oStr=> oStr.to!string)
                        .fold!((a, b)=> a~b)
                        .to!string;
        }
        
        unittest{
            auto message = Message();
            message._addressPattern = [AddressPart("foo")];
            message._typeTagString = TypeTagString("s");
            message._args = [OscString("hoge")];
            import std.stdio; 
            import std.conv; 
            assert(message.to!string == "/foo\0\0\0\0,s\0\0hoge\0\0\0\0");
        }

        ///
        ubyte[] opCast(T:ubyte[])()const{
            ubyte[] b = [0, 0, 0, 0];
            import std.conv;
            import std.algorithm;
            // return _typeTagString.to!(ubyte[]);
            return  _addressPattern.map!(oStr => oStr.to!(ubyte[]))
                                  .fold!((a, b)=> a~b)
                                  .to!(ubyte[]).dup
                 ~ _typeTagString.to!(ubyte[])
                 ~ _args.map!(oStr=> oStr.to!(ubyte[]))
                        .fold!((a, b)=> a~b)
                        .to!(ubyte[]);
        }
        
        ///
        void addValue(T)(T v){
            import std.conv;
            char c;
            static if(is(T == int)){
                c = 'i';
            }else if(is(T == float)){
                c = 'f';
            }else if(is(T == string)){
                c = 's';
            }//TODO blob
            
            _typeTagString.add(c);
            _args ~= OscString(v);
        }
    }//public

    private{
        AddressPattern _addressPattern;
        TypeTagString _typeTagString;
        OscString!'\0'[] _args;
    }//private
}//struct Message

unittest{
    auto message = Message();
    message._addressPattern = [AddressPart("foo")];
    message.addValue(1000);
    message.addValue(-1);
    message.addValue("hello");
    message.addValue(1.234f);
    message.addValue(5.678f);

    import std.conv; 
    ubyte[] a = [0x2f, 0x66, 0x6f, 0x6f, 0x0, 0x0, 0x0, 0x0, 0x2c, 0x69, 0x69, 0x73, 0x66, 0x66, 0x0, 0x0, 0x0, 0x0, 0x3, 0xe8, 0xff, 0xff, 0xff, 0xff, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x0, 0x0, 0x0, 0x3f, 0x9d, 0xf3, 0xb6, 0x40, 0xb5, 0xb2, 0x2d];
    assert(message.to!(ubyte[]) == a);
}
