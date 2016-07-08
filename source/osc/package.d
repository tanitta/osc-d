module osc;
import osc.oscstring;

/++
+/
struct Packet {
    public{
    }//public

    private{
        Message _message;
        Bundle _bundle;
    }//private
}//struct Packet

/++
+/
struct Bundle {
    public{
    }//public

    private{
        immutable string _prefix = "#bundle";
        // _timeTag
        //first size
        //first content
        
        //secont size
        //secont content 
    }//private
}//struct Bundle

/++
+/
struct BundleElement {
    public{
    }//public

    private{
        //size
        //content 
    }//private
}//struct BundleElement

/++
+/
struct Message {
    public{
    }//public

    private{
        // address pattern
        // type tag string
        // args
    }//private
}//struct Message

/++
+/
enum TypeTag {
    Int    = "i",
    Float  = "f",
    String = "s",
    Blob   = "b" 
}//enum TypeTag


/++
+/
class Client {
    public{
    }//public

    private{
    }//private
}//class Client

/++
+/
class Server {
    public{
    }//public

    private{
    }//private
}//class Server
