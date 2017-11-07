module osc.server;

import std.socket;
import std.container;
import core.thread;
import core.sync.mutex;
import osc.message;
import osc.packet;
import osc.bundle;


/++
+/
class PullServer {
    public{
        this(ushort port){
            this(new InternetAddress ("localhost", port));
        }

        ///
        this(InternetAddress internetAddress){
            import std.socket;
            _socket = new UdpSocket();
            _socket.bind (internetAddress);
        }

        const(Message)[] receive(){
            // while(true){
            const(Message)[] messages;
            size_t l;
            do{
                ubyte[512] recvRaw;
                l = _socket.receive(recvRaw);
                if(l>0){
                    messages ~= Packet(recvRaw[0..l]).messages;
                }
            }while(l>0);
            return messages;
        }
    }//public

    private{
        UdpSocket _socket;
    }//private
}//class PullServer

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
            _messages = new Messages;
            auto socket = new UdpSocket();
            socket.bind (internetAddress);
            auto _thread = new Thread(() => receive(socket)).start;
        }
        
        ///
        ~this(){
        }

        const(Message)[] popMessages(){
            // const(Message) m = _messages[0];
            // _messages = _messages[1..$];
            return _messages.popMessages;
        }

        void close(){
            _thread.join;
        }
        
        // bool hasMessage()const{
        //     auto numMessages = _messages.length;
        //
        //     return _messages.length != 0;
        // }
    }//public

    private{
        Messages _messages;
        Thread _thread;
        
        void receive(Socket socket){
            ubyte[512] recvRaw;
            while(true){
                size_t l = socket.receive(recvRaw);
                _messages.pushMessages(Packet(recvRaw[0..l]).messages);
            }
        }
    }//private
}//class Server

/++
+/
private class Messages {
    public{
        Mutex mtx;
        this(){
            mtx = new Mutex();
        }

        const(Message)[] popMessages(){
            mtx.lock; scope(exit)mtx.unlock;
            const(Message)[] result = cast(const(Message)[])(_contents);
            _contents = [];
            return result;
        }

        void pushMessages(const(Message)[] messages){
            mtx.lock;
            _contents ~= cast(const(Message)[])messages;
            mtx.unlock;
        }
    }//public

    private{
        const(Message)[] _contents;
    }//private
}//class Messages

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
