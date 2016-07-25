module osc.packet;

import osc.message;
import osc.bundle;
/++
+/
//TODO support for bundle
struct Packet {
    public{
        ///
        this(Message message){
            _hasMessage = true;
        }

        ///
        this(Bundle bundle){
            _hasBundle = true;
        }
        
        ///
        this(in ubyte[] packet){
            _hasBundle = packet[0] == 0x23;
            _hasMessage= packet[0] != 0x23;
            
            if(_hasBundle){
                _bundle = Bundle(packet);
            }
        }

        ///
        string toString()const{
            return _opCast!string;
        }

        ///
        ubyte[] opCast(T:ubyte[])()const{
            return _opCast!T;
        }

    }//public

    private{
        bool _hasMessage;
        bool _hasBundle;

        Bundle _bundle;
        Message _message;

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
