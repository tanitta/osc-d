module osc.oscstring;

/++
+/
struct OscString(char P){
    public{
        enum Prefix = P;
        
        this(string str)
        out{
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
    auto oscString = OscString!('/')("hoge");
    assert(oscString.to!string == "/hoge\0\0\0");
}
