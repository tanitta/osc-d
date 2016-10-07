module osc.server;

import std.socket;
import std.container;
import core.thread;
import osc.message;
import osc.packet;
import osc.bundle;

/++
+/
class Server{
    public{
        ///
        this(ushort port){
            this(new InternetAddress ("localhost", port));
        }
        
        ///
        this(InternetAddress internetAddress){
            import std.socket;
            auto socket = new UdpSocket();
            socket.bind (internetAddress);
            auto _thread = new Thread(() => receive(socket)).start;
        }
        
        ///
        ~this(){
        }
        const(Message) popMessage(){
            const(Message) m = _messages[0];
            _messages = _messages[1..$];
            return m;
        }
        
        bool hasMessage()const{
            return _messages.length != 0;
        }
    }//public

    private{
        const(Message)[] _messages = [];
        Thread _thread;
        
        void receive(Socket socket){
            ubyte[512] recvRaw;
            while(true){
                size_t l = socket.receive(recvRaw);
                _messages ~= Packet(recvRaw[0..l]).messages;
            }
        }
    }//private
}//class Server

private{
    const(Message)[] messages(in Packet packet){
        const(Message)[] list;
        if(packet.hasMessage){
            list ~= packet.message;
        }
        if(packet.hasBundle){
            list = messagesRecur(packet.bundle);
        }
        return list;
        
    }
    
    const(Message)[] messagesRecur(in Bundle bundle){
        const(Message)[] list;
        foreach (ref element; bundle.elements) {
            if(element.hasMessage){
                list ~= element.message;
            }
            if(element.hasBundle){
                list ~= element.bundle.messagesRecur;
            }
        }
        return list;
    }
}
