module osc.timetag;
import std.datetime;

/++
+/
struct TimeTag {
    public{
        ///
        this(in SysTime utcSysTime, in bool isImmediately = false){
            if(isImmediately){
                _data = [0, 0, 0, 0, 0, 0, 0, 1];
            }else{
                _data = generatedTimeTagData(utcSysTime);
            }
        }
        
        ///
        this(in ubyte[] timeTag){
            _data = timeTag;
        }
        
        ///
        string toString()const{
            import std.conv:to;
            import std.algorithm;
            return _data.map!(c => c.to!char).to!string;
        }
        
        ///
        ubyte[] opCast(T:ubyte[])()const{
            return _data.dup;
        }
        
        ///
        size_t size()const{
            return 8;
        }
    }//public

    private{
        ubyte[] generatedTimeTagData(in SysTime utcSysTime)const{
            immutable origin = DateTime(1900, 1, 1);
            immutable timeStamp = utcSysTime - SysTime(origin, UTC());
            
            immutable integer = timeStamp.total!"seconds";
            immutable fraction = (timeStamp.total!"nsecs"%(10^^9));
            
            import std.bitmanip;
            import std.conv;
            ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0];
            buffer.write!uint(integer.to!uint, 0);
            buffer.write!uint(fraction.to!uint, 4);
            return buffer;
        }
        
        const ubyte[] _data;
    }//private
}//struct TimeTag
unittest{
    //should generate TimeTag from arbitrary SysTime in UTC.
    import std.bitmanip;
    import std.conv;
    auto timeTag = TimeTag(SysTime(DateTime(1900, 1, 2), UTC()));
    ubyte[] tomorrow = [0, 0, 0, 0, 0, 0, 0, 0];
    tomorrow.write!uint(60*60*24, 0);
    assert(timeTag.to!(ubyte[]) == tomorrow);
}
