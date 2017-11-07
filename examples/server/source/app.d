static import osc;

void main() {
    auto server = new osc.Server(8000);
    while(true){
        import std.stdio;
        auto ms = server.popMessages;
        foreach (m; ms) {
            foreach (int i, ref t; m.typeTags) {
                import std.conv;
                switch (t) {
                    case osc.TypeTag.Int:
                        m.arg!int(i).writeln;
                        break;
                    case osc.TypeTag.Float:
                        m.arg!float(i).writeln;
                        break;
                    case osc.TypeTag.String:
                        m.arg!string(i).writeln;
                        break;
                    case osc.TypeTag.Blob:
                        m.arg!(ubyte[])(i).writeln;
                        break;
                    default:
                        assert(0);
                }
            }
        }
        import std.datetime;
        import core.thread;
        Thread.sleep(10.dur!"msecs");
    }
}
