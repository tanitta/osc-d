osc
====

#Description
A implemention of Open Sound Control in D programming language.
Client is still a work in progress.

#Example

```
// Server

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
                    default:
                        break;
                }
            }
        }
        import std.datetime;
        import core.thread;
        Thread.sleep(1.dur!"seconds");
    }
}
```
