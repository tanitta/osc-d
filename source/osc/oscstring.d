module osc.oscstring;

T addNullSuffix(T:string)(T str){
    size_t nullCharacters = 4-str.length%4;
    import std.range;
    import std.conv;
    import std.algorithm;
    return str ~ ('\0'.repeat(nullCharacters).array).map!(c => cast(immutable(char))c).array;
}

T addNullSuffix(T:ubyte[])(T str){
    return cast(T)addNullSuffix(cast(string)str);
}

unittest{
    assert("osc".addNullSuffix == "osc\0");
}

/++
+/
struct OscString(char P){
    public{
        ///
        enum Prefix = P;
        
        ///
        this(in string str)
        in{
            import std.algorithm;
            assert(!str.canFind("\0"));
            assert(str != "");
        }out{
            assert(_data.length%4 == 0);
        }body{
            
            if(Prefix != '\0'){
                _data ~= Prefix;
            }
            
            foreach (ref c; str) {
                _data ~= c;
            }
            
            _data = _data.addNullSuffix;
        }
        
        unittest{
            import core.exception, std.exception;
            assertThrown!AssertError(OscString("\0string\0mixed\0null\0"));
            assertThrown!AssertError(OscString(""));
        }
    }//public

    private{
        ubyte[] _data;
    }//private
}//struct OscString

///
OscString!('\0') OscString(string str){
    return OscString!('\0')(str);
}

///
alias TypeTagString = OscString!(',');

///
alias AddressPart= OscString!('/');

///
template isOscString(S){
    enum bool isOscString = __traits(compiles, (){
        S oscString = OscString!(S.Prefix)();
    });
}

unittest{
    static assert(isOscString!(OscString!('a')));
    static assert(isOscString!(OscString!('\n')));
    static assert(isOscString!(TypeTagString));
    static assert(isOscString!(AddressPart));
    static assert(!isOscString!(string));
}

///
T to(T:string, O:OscString!(C), char C)(in O oscString){
    import std.conv:stdConvTo = to;
    import std.algorithm;
    return oscString._data.map!(c => c.stdConvTo!char).stdConvTo!string;
}

unittest{
    auto oscString = OscString!('\0')("osc");
    import std.stdio;
    assert(oscString.to!string == "osc\0");
}

unittest{
    auto oscString = OscString!('\0')("data");
    assert(oscString.to!string == "data\0\0\0\0");
}

///
string content(S)(in S oscString)if(isOscString!(S)){
    import std.string;
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
