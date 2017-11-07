module osc.typetagstring;
import osc.oscstring;

///
alias TypeTagString = OscString!(',');

///
ref T add(T:TypeTagString)(ref T oscString, char t){
    if(oscString.isEmpty){
        import std.conv;
        oscString = TypeTagString(t.to!string);
    }else{
        import std.algorithm;
        oscString = TypeTagString(oscString.content ~ t);
    }
    return oscString;
}

unittest{
    TypeTagString s;
    s.add('i')
     .add('i')
     .add('s')
     .add('f')
     .add('f');
    assert(s.size == 8);
}

unittest{
    TypeTagString s;
    s.add('i');
    assert(s.size == 4);
}

/++
+/
enum TypeTag {
    Int    = 'i', 
    Float  = 'f', 
    String = 's', 
    Blob   = 'b', 
}//enum TypeTag

unittest{
    static assert(isOscString!(TypeTagString));
}
