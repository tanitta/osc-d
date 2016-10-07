module osc.packet;

import osc.message;
import osc.bundle;

//TODO support for bundle
/++
+/
struct Packet {
    public{
        ///
        this(in Message message){
            _hasMessage = true;
            _message = message;
        }

        ///
        this(in Bundle bundle){
            _hasBundle = true;
            _bundle = bundle;
        }
        
        ///
        this(in ubyte[] packet){
            _hasBundle = packet[0] == 0x23;
            _hasMessage= packet[0] != 0x23;
            
            if(_hasBundle){
                _bundle = Bundle(packet);
            }
            if(_hasMessage){
                _message = Message(packet);
            }
        }

        ///
        string toString()const{
            return _opCast!string;
        }

        ///
        T opCast(T:ubyte[])()const{
            return _opCast!(ubyte[])();
        }

        ///
        const(Bundle) bundle()const{
            return _bundle;
        }
        
        ///
        const(Message) message()const{
            return _message;
        }
        
        bool hasMessage()const{return _hasMessage;}
        bool hasBundle()const{return _hasBundle;}
    }//public

    private{
        bool _hasMessage;
        bool _hasBundle;

        const Bundle _bundle;
        const Message _message;

        T _opCast(T)()const{
            import std.conv;
            T r;
            if(_hasMessage){
                r = _message.to!T;
            }else if(_hasBundle){
                r = _bundle.to!T;
            }
            return r;
        }
    }//private
}//struct Packet
unittest{
    //TODO
    Message message = Message();
    message.addressPattern = "/foo";
    message.addValue(1000);
    message.addValue(-1);
    message.addValue("hello");
    message.addValue(1.234f);
    message.addValue(5.678f);
    Packet packet = Packet(message);
    import std.conv;
    ubyte[] b = packet.to!(ubyte[]);
    assert(b.length != 0);
}
