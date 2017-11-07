module osc.message;
import osc.oscstring;
import osc.typetagstring;
import osc.addresspattern;

AddressPattern toAddressPattern(in ubyte[] b){
    import std.algorithm;
    import std.conv;
    import std.array;
    string[] parts = b.map!(c => c.to!char)
                      .to!string[1..$]
                      .replace("\0", "")
                      .split("/");
    return parts.map!(p => AddressPart(p))
                .array;
}
unittest{
    const ubyte[] b = [0x2f, 0x66, 0x6f, 0x6f, 0x0, 0x0, 0x0, 0x0];
    import std.algorithm;
    import std.stdio;
    assert(b.toAddressPattern == [AddressPart("foo")]);
}
/++
+/
struct Message {
    public{
        ///
        this(in ubyte[] message){
            import std.algorithm;
            const(ubyte)[] addressPattern = message[0..message.countUntil(0)];
            _addressPattern = addressPattern.toAddressPattern;
            const(ubyte)[] remaining = message[message.countUntil(0)..$].find!"a!=0";
            
            assert(remaining.length%4 == 0);
            
            const(ubyte)[] typeTagString = remaining[1..remaining.countUntil(0)];
            _typeTagString = TypeTagString(typeTagString);
            import std.conv;

            remaining = remaining[remaining.countUntil(0)/4*4+4..$];
            
            assert(remaining.length%4 == 0);
            
            foreach (ref c; _typeTagString.content) {
                switch (c) {
                    case 'i':
                        _args ~= remaining[0..4].dup;
                        remaining = remaining[4..$];
                        break;
                    case 'f':
                        _args ~= remaining[0..4].dup;
                        remaining = remaining[4..$];
                        break;
                    case 's':
                        _args ~= remaining[0..remaining.countUntil(0)/4*4+4].dup;
                        remaining = remaining[remaining.countUntil(0)/4*4+4..$];
                        break;
                    case 'b':
                        _args ~= remaining[0..4].dup;
                        remaining = remaining[4..$];
                        break;
                    default:
                        assert(0);
                }
            }
        }
        
        unittest{
            ubyte[] buffer = [0x2f, 0x66, 0x6f, 0x6f, 0x0, 0x0, 0x0, 0x0, 0x2c, 0x69, 0x69, 0x73, 0x66, 0x66, 0x0, 0x0, 0x0, 0x0, 0x3, 0xe8, 0xff, 0xff, 0xff, 0xff, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x0, 0x0, 0x0, 0x3f, 0x9d, 0xf3, 0xb6, 0x40, 0xb5, 0xb2, 0x2d];
            auto message = Message(buffer);
        }
        
        ///
        T opCast(T:ubyte[])()const{
            return _opCast!(T)();
        }
        
        ///
        string toString()const
        in{
            assert(_args.length > 0);
        }body{
            return _opCast!string();
        }
        
        unittest{
            auto message = Message();
            message._addressPattern = [AddressPart("foo")];
            message._typeTagString = TypeTagString("s");
            import std.conv;
            message._args = [OscString("hoge").to!(ubyte[])];
            assert(message.to!string == "/foo,shoge");
        }
        
        ///
        const(AddressPattern) addressPattern()const{
            return _addressPattern;
        }
        
        ///
        const(TypeTagString) typeTagString()const{
            return _typeTagString;
        }
        
        ///
        TypeTag[] typeTags()const{
            import std.algorithm;
            import std.conv;
            import std.array;
            return _typeTagString.content.map!(c => c.to!TypeTag).array;
        }
        
        ///
        T arg(T:ubyte[])(in size_t index)const{
            return _args[index].dup;
        }

        ///
        T arg(T:int)(in size_t index)const{
            import std.bitmanip;
            return _args[index].peek!T();
        }

        ///
        T arg(T:float)(in size_t index)const{
            import std.bitmanip;
            return _args[index].peek!T();
        }

        ///
        T arg(T:string)(in size_t index)const{
            import std.conv:to;
            import std.algorithm;
            return _args[index].stripRight(0).map!(c => c.to!char).to!string;
        }
        
        ///
        void addressPattern(in string str){
            import std.array;
            import std.algorithm;
            _addressPattern = str.split("/")
                                 .filter!(a => a != "")
                                 .map!(pattern => AddressPart(pattern))
                                 .array;
        }
        unittest{
            auto message = Message();
            message.addressPattern = "/foo/bar";
            import std.stdio;
            import std.conv;
            assert(message._addressPattern == [AddressPart("foo"), AddressPart("bar")]);
        }
        
        ///
        void addressPattern(AddressPattern p){
            import std.array;
            import std.algorithm;
            _addressPattern = p;
        }
        
        ///
        void addValue(T)(T v){
            import std.conv;
            char c;
            static if(is(T == int)){
                import std.bitmanip;
                ubyte[] buffer = [0, 0, 0, 0];
                buffer.write!T(v, 0);
                _args ~= buffer;
                c = 'i';
            }else static if(is(T == float)){
                import std.bitmanip;
                ubyte[] buffer = [0, 0, 0, 0];
                buffer.write!T(v, 0);
                _args ~= buffer;
                c = 'f';
            }else static if(is(T == string)){
                _args ~= OscString(v).to!(ubyte[]);
                c = 's';
            }else static if(is(T == ubyte[])){
                _args ~= v;
                c = 'b';
            }
            
            _typeTagString.add(c);
        }
        
        ///
        size_t size()const{
            import std.array;
            return _addressPattern.size + 
                   _typeTagString.size + 
                   _args.join.length;
        }
        unittest{
            auto message = Message();
            message.addressPattern = [AddressPart("foo")];
            message.addValue(1000);
            message.addValue(-1);
            message.addValue("hello");
            message.addValue(1.234f);
            message.addValue(5.678f);
            assert(message.size == 40);
        }
    }//public

    private{
        AddressPattern _addressPattern;
        TypeTagString _typeTagString;
        ubyte[][] _args;
        
        T _opCast(T)()const{
            T b = [0, 0, 0, 0];
            import std.conv;
            import std.array;
            import std.algorithm;

            auto casterArgs = _args.map!(b => b.convert!T).join;
            auto seed = AddressPart();
            return  _addressPattern.fold!((a, b)=> a~b)(seed)
                                   .to!(T).dup
                 ~ _typeTagString.to!(T)
                 ~casterArgs;
        }
        
    }//private
}//struct Message


private T convert(T:ubyte[])(in ubyte[] b){
    return b.dup;
}
private T convert(T:string)(in ubyte[] b){
    import std.conv;
    return OscString!('\0')(b).content;
}

unittest{
    auto message = Message();
    message.addressPattern = [AddressPart("foo")];
    message.addValue(1000);
    message.addValue(-1);
    message.addValue("hello");
    message.addValue(1.234f);
    message.addValue(5.678f);

    import std.conv; 
    ubyte[] a = [0x2f, 0x66, 0x6f, 0x6f, 0x0, 0x0, 0x0, 0x0, 0x2c, 0x69, 0x69, 0x73, 0x66, 0x66, 0x0, 0x0, 0x0, 0x0, 0x3, 0xe8, 0xff, 0xff, 0xff, 0xff, 0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x0, 0x0, 0x0, 0x3f, 0x9d, 0xf3, 0xb6, 0x40, 0xb5, 0xb2, 0x2d];
    assert(message.to!(ubyte[]) == a);
}

unittest{
    auto ans = Message();
    ans.addressPattern = [AddressPart("foo")];
    ans.addValue(1000);
    ans.addValue(-1);
    ans.addValue("hello");
    ans.addValue(1.234f);
    ans.addValue(5.678f);

    ubyte[] a = [0x2f, 0x66, 0x6f, 0x6f,
                 0x0, 0x0, 0x0, 0x0,
                 0x2c, 0x69, 0x69, 0x73,
                 0x66, 0x66, 0x0, 0x0,
                 0x0, 0x0, 0x3, 0xe8,
                 0xff, 0xff, 0xff, 0xff,
                 0x68, 0x65, 0x6c, 0x6c,
                 0x6f, 0x0, 0x0, 0x0,
                 0x3f, 0x9d, 0xf3, 0xb6,
                 0x40, 0xb5, 0xb2, 0x2d];
    auto message = Message(a);
    assert(message == ans);
}
