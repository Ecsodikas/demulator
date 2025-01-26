module cpu;

import std.typecons;

const ubyte ZERO_FLAG_BYTE_POSITION = 7;
const ubyte SUBTRACT_FLAG_BYTE_POSITION = 6;
const ubyte HALF_CARRY_FLAG_BYTE_POSITION = 5;
const ubyte CARRY_FLAG_BYTE_POSITION = 4;

enum Register
{
    A,
    B,
    C,
    D,
    E,
    F,
    H,
    L
}

struct Flags
{
    bool zero;
    bool subtract;
    bool halfCarry;
    bool carry;

    pure ubyte fromFlags()
    {
        return (this.zero ? 1 : 0) << ZERO_FLAG_BYTE_POSITION |
            (this.subtract ? 1 : 0) << SUBTRACT_FLAG_BYTE_POSITION |
            (this.halfCarry ? 1 : 0) << HALF_CARRY_FLAG_BYTE_POSITION |
            (this.carry ? 1 : 0) << CARRY_FLAG_BYTE_POSITION;
    }

    pure static Flags fromRegister(ubyte register)
    {
        Flags f;

        f.zero = ((register >> ZERO_FLAG_BYTE_POSITION) & 0b1) == 1;
        f.subtract = ((register >> SUBTRACT_FLAG_BYTE_POSITION) & 0b1) != 0;
        f.halfCarry = ((register >> HALF_CARRY_FLAG_BYTE_POSITION) & 0b1) == 1;
        f.carry = ((register >> CARRY_FLAG_BYTE_POSITION) & 0b1) == 1;

        return f;
    }
}

struct Registers
{
    ubyte a;
    ubyte b;
    ubyte c;
    ubyte d;
    ubyte e;
    Flags f;
    ubyte h;
    ubyte l;
}

struct Cpu
{
    Registers registers;
    ushort pc;
    //ubyte[0xFFFF] memory;

    pure ushort getAF()
    {
        ushort ra = cast(ushort) this.registers.a;
        ushort rf = cast(ushort) this.registers.f.fromFlags;
        return cast(ushort)(ra << 8 | rf);
    }

    pure Cpu setAF(ushort val)
    {
        Cpu nCpu = this;
        nCpu.registers.a = cast(ushort)((val & 0xFF00) >> 8);

        Flags fl;
        nCpu.registers.f = fl.fromRegister(cast(ushort)(val & 0xFF));
        return nCpu;
    }

    pure ushort getBC()
    {
        ushort rb = cast(ushort) this.registers.b;
        ushort rc = cast(ushort) this.registers.c;
        return cast(ushort)(rb << 8 | rc);
    }

    pure Cpu setBC(ushort val)
    {
        Cpu nCpu = this;
        nCpu.registers.b = cast(ushort)((val & 0xFF00) >> 8);
        nCpu.registers.c = cast(ushort)(val & 0xFF);
        return nCpu;
    }

    pure ushort getDE()
    {
        ushort rd = cast(ushort) this.registers.d;
        ushort re = cast(ushort) this.registers.e;
        return cast(ushort)(rd << 8 | re);
    }

    pure Cpu setDE(ushort val)
    {
        Cpu nCpu = this;
        nCpu.registers.d = cast(ushort)((val & 0xFF00) >> 8);
        nCpu.registers.e = cast(ushort)(val & 0xFF);
        return nCpu;
    }

    pure ushort getHL()
    {
        ushort rh = cast(ushort) this.registers.h;
        ushort rl = cast(ushort) this.registers.l;
        return cast(ushort)(rh << 8 | rl);
    }

    pure Cpu setHL(ushort val)
    {
        Cpu nCpu = this;
        nCpu.registers.h = cast(ushort)((val & 0xFF00) >> 8);
        nCpu.registers.l = cast(ushort)(val & 0xFF);
        return nCpu;
    }
}

pure ubyte getRegisterValue(Cpu cpu, Register r)
{
    switch (r)
    {
    case Register.A:
        return cpu.registers.a;
    case Register.B:
        return cpu.registers.b;
    case Register.C:
        return cpu.registers.c;
    case Register.D:
        return cpu.registers.d;
    case Register.E:
        return cpu.registers.e;
    case Register.F:
        return cpu.registers.f.fromFlags;
    case Register.H:
        return cpu.registers.h;
    case Register.L:
        return cpu.registers.l;
    default:
        assert(0);
    }
}

pure Cpu setRegisterValue(Cpu cpu, Register r, ubyte value)
{
    Cpu nCpu = cpu;

    switch (r)
    {
    case Register.A:
        nCpu.registers.a = value;
        break;
    case Register.B:
        nCpu.registers.b = value;
        break;
    case Register.C:
        nCpu.registers.c = value;
        break;
    case Register.D:
        nCpu.registers.d = value;
        break;
    case Register.E:
        nCpu.registers.e = value;
        break;
    case Register.F:
        nCpu.registers.f = Flags.fromRegister(value);
        break;
    case Register.H:
        nCpu.registers.h = value;
        break;
    case Register.L:
        nCpu.registers.l = value;
        break;
    default:
        assert(0);
    }

    return nCpu;
}

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

pure bool bit(Cpu cpu, Register r, ubyte b)
{
    //TODO
    return bt(cast(ulong) cpu.getRegisterValue(r), cast(ulong) b);
}

pure Cpu cpl(Cpu cpu)
{
    Cpu nCpu = cpu;
    Flags f;
    nCpu.registers.f = f;
    nCpu.registers.a = cast(ubyte)~nCpu.registers.a;

    return nCpu;
}

pure Cpu rrla(Cpu cpu)
{

    Cpu nCpu = cpu;
    Flags f;
    nCpu.registers.f = f;

    import core.bitop;

    nCpu.registers.a = rol(nCpu.registers.a, 1);

    return nCpu;
}

pure Cpu rrca(Cpu cpu)
{

    Cpu nCpu = cpu;
    Flags f;
    nCpu.registers.f = f;

    import core.bitop;

    nCpu.registers.a = ror(nCpu.registers.a, 1);

    return nCpu;
}

// We have to test this thing. Nobody know what this is doing. Even the gods.
pure Cpu rla(Cpu cpu)
{
    Cpu nCpu = cpu;
    ushort cFlag = nCpu.registers.f.carry ? 1 : 0;
    ushort newA = cast(ushort)((nCpu.registers.a << 1) + cFlag);

    Flags f;
    f.carry = newA > 0xFF;
    nCpu.registers.f = f;
    nCpu.registers.a = cast(ubyte) newA;

    return nCpu;
}

pure Cpu rra(Cpu cpu)
{
    Cpu nCpu = cpu;
    ushort cFlag = nCpu.registers.f.carry ? 1 : 0;
    ushort newA = cast(ushort)((nCpu.registers.a >> 1)
            + (cFlag << 7)
            + (
                (nCpu.registers.a & 1) << 8
            ));

    Flags f;
    f.carry = newA > 0xFF;
    nCpu.registers.f = f;
    nCpu.registers.a = cast(ubyte) newA;

    return nCpu;
}

pure Cpu scf(Cpu cpu)
{
    Cpu nCpu = cpu;

    nCpu.registers.f.carry = true;

    return nCpu;
}

pure Cpu ccf(Cpu cpu)
{
    Cpu nCpu = cpu;

    nCpu.registers.f.carry = !nCpu.registers.f.carry;

    return nCpu;
}

pure Cpu and(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = getRegisterValue(nCpu, r);
    ubyte aValue = nCpu.registers.a;
    ubyte result = targetValue & aValue;

    Flags f;
    f.zero = result == 0;
    f.subtract = false;
    f.halfCarry = false;
    f.carry = false;

    nCpu.registers.f = f;
    nCpu.registers.a = result;

    return nCpu;
}

pure Cpu or(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = getRegisterValue(nCpu, r);
    ubyte aValue = nCpu.registers.a;
    ubyte result = targetValue | aValue;

    Flags f;
    f.zero = result == 0;
    f.subtract = false;
    f.halfCarry = false;
    f.carry = false;

    nCpu.registers.f = f;
    nCpu.registers.a = result;

    return nCpu;
}

pure Cpu xor(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = getRegisterValue(nCpu, r);
    ubyte aValue = nCpu.registers.a;
    ubyte result = targetValue ^ aValue;

    Flags f;
    f.zero = result == 0;
    f.subtract = false;
    f.halfCarry = false;
    f.carry = false;

    nCpu.registers.f = f;
    nCpu.registers.a = result;

    return nCpu;
}

pure Cpu inc(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = 1;
    ubyte regValue = getRegisterValue(cpu, r);
    Tuple!(bool, ubyte) resultT = overflowingAdd(regValue, targetValue);
    bool isOverflow = resultT[0];
    ubyte result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = false;
    f.halfCarry = ((targetValue & 0xF) + (regValue & 0xF)) > 0xF;
    f.carry = isOverflow;

    return nCpu
        .setRegisterValue(Register.F, f.fromFlags)
        .setRegisterValue(r, result);
}

pure Cpu dec(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = 1;
    ubyte regValue = getRegisterValue(cpu, r);
    Tuple!(bool, ubyte) resultT = underflowingSub(regValue, targetValue);
    bool isOverflow = resultT[0];
    ubyte result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = true;
    f.halfCarry = ((targetValue & 0xF) + (regValue & 0xF)) > 0xF;
    f.carry = isOverflow;

    return nCpu
        .setRegisterValue(Register.F, f.fromFlags)
        .setRegisterValue(r, result);
}

pure Cpu cp(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = getRegisterValue(nCpu, r);
    ubyte aValue = nCpu.registers.a;
    Tuple!(bool, ubyte) resultT = underflowingSub(aValue, targetValue);
    bool isOverflow = resultT[0];
    ubyte result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = true;
    f.halfCarry = ((targetValue & 0xF) + (aValue & 0xF)) > 0xF;
    f.carry = isOverflow;

    nCpu.registers.f = f;

    return nCpu;
}

pure Cpu sub(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = getRegisterValue(nCpu, r);
    ubyte aValue = nCpu.registers.a;
    Tuple!(bool, ubyte) resultT = underflowingSub(aValue, targetValue);
    bool isOverflow = resultT[0];
    ubyte result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = true;
    f.halfCarry = ((targetValue & 0xF) + (aValue & 0xF)) > 0xF;
    f.carry = isOverflow;

    nCpu.registers.f = f;
    nCpu.registers.a = result;

    return nCpu;
}

pure Cpu subc(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = getRegisterValue(nCpu, r);
    ubyte aValue = nCpu.registers.a;
    Tuple!(bool, ubyte) resultT = underflowingSub(aValue, targetValue);
    bool isOverflow = resultT[0];
    ubyte result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = true;
    f.halfCarry = ((targetValue & 0xF) + (aValue & 0xF)) > 0xF;
    f.carry = isOverflow;

    nCpu.registers.f = f;
    nCpu.registers.a = isOverflow ? cast(ubyte)(result - 0b00010000) : result;
    return nCpu;
}

pure Cpu addc(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = getRegisterValue(nCpu, r);
    ubyte aValue = nCpu.registers.a;
    Tuple!(bool, ubyte) resultT = overflowingAdd(aValue, targetValue);
    bool isOverflow = resultT[0];
    ubyte result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = false;
    f.halfCarry = ((targetValue & 0xF) + (aValue & 0xF)) > 0xF;
    f.carry = isOverflow;

    nCpu.registers.f = f;
    nCpu.registers.a = isOverflow ? cast(ubyte)(result + 0b00010000) : result;

    return nCpu;
}

pure Cpu addhl(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;

    ubyte targetValue = getRegisterValue(nCpu, r);
    ushort hlValue = nCpu.getHL;
    Tuple!(bool, ushort) resultT = overflowingAdd16(hlValue, targetValue);
    bool isOverflow = resultT[0];
    ushort result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = false;
    f.halfCarry = targetValue + (hlValue & 0xFF) > 0xFF;
    f.carry = isOverflow;

    nCpu.registers.f = f;
    nCpu = nCpu.setHL(result);

    return nCpu;
}

pure Cpu add(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte targetValue = getRegisterValue(nCpu, r);
    ubyte aValue = nCpu.registers.a;
    Tuple!(bool, ubyte) resultT = overflowingAdd(aValue, targetValue);
    bool isOverflow = resultT[0];
    ubyte result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = false;
    f.halfCarry = ((targetValue & 0xF) + (aValue & 0xF)) > 0xF;
    f.carry = isOverflow;

    nCpu.registers.f = f;
    nCpu.registers.a = result;

    return nCpu;
}

unittest
{
    Cpu rt;

    rt.registers.a = 1;
    rt.registers.b = 2;
    rt.registers.c = 3;
    rt.registers.d = 4;
    rt.registers.e = 5;
    rt.registers.h = 6;
    rt.registers.l = 7;

    assert(getRegisterValue(rt, Register.A) == 1);
    assert(getRegisterValue(rt, Register.B) == 2);
    assert(getRegisterValue(rt, Register.C) == 3);
    assert(getRegisterValue(rt, Register.D) == 4);
    assert(getRegisterValue(rt, Register.E) == 5);
    assert(getRegisterValue(rt, Register.H) == 6);
    assert(getRegisterValue(rt, Register.L) == 7);

    rt = rt.setRegisterValue(Register.A, 123);
    assert(getRegisterValue(rt, Register.A) == 123);

    Cpu c0;

    c0.registers.a = 100;
    c0.registers.b = 198;

    Cpu res0 = add(c0, Register.B);

    assert(res0.registers.a == 42);
    assert(res0.registers.f.carry == true);

    Cpu c1;

    c1 = c1.setHL(255);
    c1.registers.b = 1;

    Cpu res1 = addhl(c1, Register.B);
    assert(res1.getHL() == 256);
    assert(res1.registers.h == 1);
    assert(res1.registers.l == 0);
    assert(res1.registers.f.halfCarry == true);

    Cpu c2;

    c2.registers.a = 10;
    c2.registers.b = 8;

    Cpu res2 = sub(c2, Register.B);

    assert(res2.registers.a == 2);
    Cpu res3 = sub(res2, Register.B);
    assert(res3.registers.f.carry);
    assert(res3.registers.a == 250);

    Cpu c3;
    c3.registers.a = 0b01001000;
    c3.registers.b = 0b11000001;

    Cpu res4 = and(c3, Register.B);
    assert(res4.registers.a == 0b01000000);

    Cpu c4;
    c4.registers.d = 5;
    Cpu res5 = inc(c4, Register.D);
    res5 = dec(res5, Register.D);

    assert(res5.registers.d == 5);

    Cpu c5;
    c5.registers.f.carry = true;
    Cpu res6 = c5.ccf();

    assert(res6.registers.f.carry == false);
    res6 = res6.ccf();
    assert(res6.registers.f.carry == true);

}
