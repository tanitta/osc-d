osc-d
====

[![Dub version](https://img.shields.io/dub/v/osc-d.svg)](https://code.dlang.org/packages/osc-d)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/tanitta/osc-d/blob/master/LICENSE)
[![Build Status](https://travis-ci.org/tanitta/osc-d.svg?branch=master)](https://travis-ci.org/tanitta/osc-d)

##Description

A implemention of Open Sound Control in D programming language.

##Examples

###Server

```
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
```

###Client

```
static import osc;

void main() {
    auto client = new osc.Client(8000);
    auto message = osc.Message();
    
    message.addressPattern = "/foo";
    message.addValue(1000);
    message.addValue(-1);
    message.addValue("hello");
    message.addValue(1.234f);
    message.addValue(5.678f);
    
    client.push(message);
}
```
