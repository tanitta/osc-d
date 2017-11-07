module osc.oscstring;

///
T addNullSuffix(T:string)(T str){
    size_t nullCharacters = 4-str.length%4;
    if(nullCharacters == 0)return str;
    import std.range;
    import std.conv;
    import std.algorithm;
    return str ~ ('\0'.repeat(nullCharacters).array).map!(c => cast(immutable(char))c).array;
}

///
T addNullSuffix(T:ubyte[])(T str){
    return cast(T)addNullSuffix(cast(string)str);
}

unittest{
    assert("osc".addNullSuffix == "osc\0");
    assert("data".addNullSuffix == "data\0\0\0\0");
    assert(",iisff".addNullSuffix == ",iisff\0\0");
    assert(",i".addNullSuffix == ",i\0\0");
}

/++
+/
struct OscString(char P){
    public{
        ///
        enum Prefix = P;
        
        ///
        this(in int v){
            import std.bitmanip;
            ubyte[] buffer = [0, 0, 0, 0];
            buffer.write!int(v, 0);
            this(buffer);
        }
        
        ///
        this(in float v){
            import std.bitmanip;
            ubyte[] buffer = [0, 0, 0, 0];
            buffer.write!float(v, 0);
            this(buffer);
        }
        
        ///
        this(in string str)
        in{
            import std.algorithm;
            assert(!str.canFind("\0"));
            assert(str != "");
        }out{
            assert(_data.length%4 == 0);
        }body{
            import std.conv;
            import std.algorithm;
            import std.array;
            ubyte[] arr = str.map!(c => c.to!char.to!ubyte).array;
            this(arr);
        }
        unittest{
            import core.exception, std.exception;
            assertThrown!AssertError(OscString("\0string\0mixed\0null\0"));
            assertThrown!AssertError(OscString(""));
        }
        
        ///
        this(in ubyte[] arr)
        in{
            import std.algorithm;
            // assert(!arr.canFind(null));
            assert(arr.length > 0);
        }body{
            if(Prefix != '\0'){
                import std.conv;
                _data = Prefix.to!ubyte ~ _data;
            }
            
            foreach (ref c; arr) {
                _data ~= c;
            }
            _data = _data.addNullSuffix;
        }
        ///
        string toString()const{
            import std.conv:to;
            import std.algorithm;
            return _data.stripRight(0).map!(c => c.to!char).to!string;
        }

        unittest{
            ubyte[] buffer = [0x66, 0x6f, 0x6f];
            import std.stdio;
            import std.conv;
            assert(OscString!('\0')(buffer).to!string == "foo");
            assert(OscString!('\0')(buffer).size == 4);
        }

        unittest{
            auto oscString = OscString!('\0')("osc");
            import std.stdio;
            import std.conv;
            assert(oscString.to!string == "osc");
        }

        unittest{
            import std.conv;
            auto oscString = OscString!('\0')("data");
            assert(oscString.to!string == "data");
        }
        
        ///
        ubyte[] opCast(T:ubyte[])()const{
            return _data.dup;
        }
        
        ///
        T opCast(T:int)()const if(Prefix == '\0'){
            import std.bitmanip;
            return _data.peek!T();
        }
        
        ///
        T opCast(T:float)()const if(Prefix == '\0'){
            import std.bitmanip;
            return _data.peek!T();
        }

        T opBinary(string op:"~", T)(in T rhs)const{
            import std.algorithm;
            import std.conv;
            ubyte[] stripedLhsData = this._data.dup.stripRight(0);
            ubyte[] stripedRhsData = rhs._data.dup.stripRight(0);
            T result;
            result._data = (stripedLhsData ~ stripedRhsData).addNullSuffix;
            return result;
        }
        
        unittest{
            const oscStringLhs = OscString!('/')("foo");
            const oscStringRhs = OscString!('/')("barbaz");
            import std.stdio;
            import std.conv;
            assert((oscStringLhs ~ oscStringRhs).to!string == "/foo/barbaz");
        }
        // T convert(T)(in AddressPattern pattern){
        //     string joinedString = pattern.map!(p => p.to!string).reduce!((a, b)=>a~b);
        //     return OscString;
        // }

        ///
        bool isEmpty()const{
            import std.algorithm;
            import std.conv;
            ubyte prefix = P.to!ubyte;
            if(prefix != 0){
                return _data.length == 0;
            }else{
                return _data.stripLeft(prefix).length == 0;
            }
        }
        
        ///
        size_t size()const{
            return _data.length;
        }
        
        unittest{
            import std.conv;
            auto oscString = OscString!('\0')("data");
            assert(oscString.size == 8);
        }

    }//public

    private{
        ubyte[] _data;
    }//private
}//struct OscString
        

unittest{
    const ubyte[] buffer = [0x00, 0x00, 0x6f, 0x00];
    import std.conv;
    assert(OscString!('\0')(buffer).to!int == 28416);
}

unittest{
    const ubyte[] buffer = [0x3f, 0x9d, 0xf3, 0xb6];
    import std.conv;
    import std.math;
    assert(approxEqual(OscString!('\0')(buffer).to!float, 1.234));
}

///
OscString!('\0') OscString(T)(in T v){
    return OscString!('\0')(v);
}

///
template isOscString(S){
    enum bool isOscString = __traits(compiles, (){
        S oscString = OscString!(S.Prefix)();
    });
}

unittest{
    static assert(isOscString!(OscString!('a')));
    static assert(isOscString!(OscString!('\n')));
    static assert(!isOscString!(string));
}

///
string content(S)(in S oscString)if(isOscString!(S)){
    import std.string;
    import std.conv;
    string str = oscString.to!string.replace("\0", "");
    if(S.Prefix != '\0'){
        return str[1..$];
    }else{
        return str;
    }
    // return oscString._data
}

unittest{
    import std.string;
    assert(OscString!('\0')("data").content == "data");
    assert(OscString!('/')("data").content == "data");
}
