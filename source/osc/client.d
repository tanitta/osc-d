module osc.client;

import std.socket;
import osc.message;
import osc.packet;
import osc.bundle;

///
class Client{
    public{
        ///
        this(ushort port){
            this(new InternetAddress ("localhost", port));
        }
        
        ///
        this(InternetAddress internetAddress){
            import std.socket;
            _address = internetAddress;
            _socket = new UdpSocket();
        }
        
        ///
        Client push(in Message message){
            const packet = Packet(message);
            push(packet);
            return this;
        }
        
        ///
        Client push(in Bundle bundle){
            const packet = Packet(bundle);
            push(packet);
            return this;
        }
        
        //TODO
        Client push(in Packet packet){
            import std.conv;
            ubyte[] b = packet.to!(ubyte[]);
            _socket.sendTo(b, _address);
            return this;
        }
    }
    private{
        Socket _socket;
        Address _address;
    }
}//class Client
