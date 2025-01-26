module util;

import std.typecons;

pure Tuple!(bool, ubyte) overflowingAdd(ubyte a, ubyte b)
{
    ushort result = a + b;
    bool isOverflowing = result > 0b11111111;
    return tuple(isOverflowing, cast(ubyte) result);
}

pure Tuple!(bool, ushort) overflowingAdd16(ushort a, ubyte b)
{
    uint result = a + b;
    bool isOverflowing = result > 0xFFFF;
    return tuple(isOverflowing, cast(ushort) result);
}

pure Tuple!(bool, ubyte) underflowingSub(ubyte a, ubyte b)
{
    ubyte result = cast(ubyte)(a - b);
    bool isUnderflowing = a < result;
    return tuple(isUnderflowing, result);
}
