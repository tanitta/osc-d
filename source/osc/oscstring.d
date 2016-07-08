module osc.oscstring;

/++
+/
struct OscString(char P){
    public{
        ///
        enum Prefix = P;
        
        ///
        this(in string str)
        in{
            import std.string;
            assert(str.replace("\0", "") == str);
        }out{
            assert(_data.length%4 == 0);
        }body{
            
            if(Prefix != '\0'){
                _data ~= Prefix;
            }
            
            foreach (ref c; str) {
                _data ~= c;
            }
            
            size_t nullCharacters = 4-_data.length%4;
            import std.range;
            _data ~= '\0'.repeat(nullCharacters).array;
        }
        unittest{
            import core.exception, std.exception;
            assertThrown!AssertError(OscString("\0string\0mixed\0null\0"));
        }
    }//public

    private{
        char[] _data;
    }//private
}//struct OscString

///
OscString!('\0') OscString(string str){
    return OscString!('\0')(str);
}

///
alias TypeTagString = OscString!(',');

///
alias AddressPattern = OscString!('/');

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
    static assert(isOscString!(AddressPattern));
    static assert(!isOscString!(string));
}

string to(T, O)(in O oscString)if(isOscString!(O) && is(T == string)){
    import std.conv:stdConvTo = to;
    string dataWithNull = oscString._data.stdConvTo!string;
    return dataWithNull;
}
unittest{
    auto oscString = OscString!('\0')("osc");
    assert(oscString.to!string == "osc\0");
}

unittest{
    auto oscString = OscString!('\0')("data");
    assert(oscString.to!string == "data\0\0\0\0");
}
