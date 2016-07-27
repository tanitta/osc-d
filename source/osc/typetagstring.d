module osc.typetagstring;
import osc.oscstring;

///
alias TypeTagString = OscString!(',');

///
void add(T:TypeTagString)(ref T oscString, char t){
    if(oscString.isEmpty){
        oscString = TypeTagString(t);
    }else{
        oscString = TypeTagString(oscString.content ~ t);
    }
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
