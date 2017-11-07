module osc.interceptor;
import std.stdio;
import std.typetuple;

enum Osc;

template isOsc(alias T){
    enum isOsc = staticIndexOf!(Osc, __traits(getAttributes, T)) != -1;
}

template oscMembers(C){
    private{
        enum members = __traits(allMembers, C);
        string memberName(in string m){
            import std.conv;
            // return __traits(identifier, C) ~ "." ~m;
            return m;
        }
    }
    import std.algorithm;

    enum oscMembers = {
        string[] result = [];
        foreach (m; members) {
            // mixin("alias mi = "~__traits(identifier, C)~"."~memberName(m)~";");
            // mixin("bool f = isOsc!")
            if(isOsc!m){
                // result ~= memberName(m);
            }
        }
        return result;
    }();
}




class Hoge {
    @Osc int v;
    // enum isOsc = staticIndexOf!(Osc, __traits(getAttributes, v)) != -1;
    enum f = isOsc!(v);
    // enum b = __traits(allMembers, Hoge);
    enum m = oscMembers!(typeof(this));
}

unittest{
    // Hoge.f.writeln;
    // Hoge.m.writeln;
    // typeid(typeof(Hoge.v)).writeln;
}

