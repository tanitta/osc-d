static import osc;

void main() {
    auto server = new osc.Server(8000);
    while(true){
        import std.stdio;
        "popMessage".writeln;
        while(server.hasMessage){
            auto m = server.popMessage;
            foreach (int i, ref t; m.typeTags) {
                import std.conv;
                switch (t) {
                    case osc.TypeTag.Int:
                        m.args[i].to!int.writeln;
                        break;
                    case osc.TypeTag.Float:
                        m.args[i].to!float.writeln;
                        break;
                    case osc.TypeTag.String:
                        m.args[i].to!string.writeln;
                        break;
                    case osc.TypeTag.Blob:
                        m.args[i].to!(ubyte[]).writeln;
                        break;
                    default:
                        assert(0);
                }
            }
        }
        import std.datetime;
        import core.thread;
        Thread.sleep(1.dur!"seconds");
    }
}
