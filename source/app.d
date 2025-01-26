import std.stdio;
import core.bitop;
import cpu;

void main()
{

    ubyte a = 0b00000001;
    writefln("%b", cast(ubyte)~a);
}
