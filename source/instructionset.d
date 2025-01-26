module instructionset;

import std.typecons;

import cpu;
import util;

pure Cpu swap(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte rVal = nCpu.getRegisterValue(r);
    ubyte ln = rVal && 0x0F;
    ubyte rn = rVal && 0xF0;
    ubyte n = cast(ubyte)((ln << 4) | (rn >> 4));

    return nCpu.setRegisterValue(r, n);
}

pure Cpu sla(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte rVal = nCpu.getRegisterValue(r);
    ubyte signVal = rVal & 0b10000000;
    rVal = cast(ubyte)(rVal << 1);
    nCpu = setRegisterValue(nCpu, r, (rVal | signVal));

    return nCpu;
}

pure Cpu sra(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte rVal = nCpu.getRegisterValue(r);
    ubyte signVal = rVal & 0b10000000;
    rVal = rVal >> 1;
    nCpu = setRegisterValue(nCpu, r, (rVal | signVal));

    return nCpu;
}

pure Cpu srl(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ubyte rVal = nCpu.getRegisterValue(r);
    rVal = rVal >> 1;
    nCpu = setRegisterValue(nCpu, r, rVal);

    return nCpu;
}

pure Cpu set(Cpu cpu, Register r, ubyte b)
{
    Cpu nCpu = cpu;
    ubyte rVal = nCpu.getRegisterValue(r);
    rVal = cast(ubyte)(rVal | (1 << b));
    nCpu = setRegisterValue(nCpu, r, rVal);

    return nCpu;
}

pure Cpu reset(Cpu cpu, Register r, ubyte b)
{
    Cpu nCpu = cpu;
    ubyte rVal = nCpu.getRegisterValue(r);
    rVal = (rVal & (1 << b));
    nCpu = setRegisterValue(nCpu, r, rVal);

    return nCpu;
}

pure Cpu bit(Cpu cpu, Register r, ubyte b)
{
    Cpu nCpu = cpu;

    ubyte rVal = nCpu.getRegisterValue(r);
    ubyte test = rVal & (1 << b);

    Flags f;
    f.zero = test == 0;

    nCpu.registers.f = f;

    return nCpu;
}

pure Cpu cpl(Cpu cpu)
{
    Cpu nCpu = cpu;
    Flags f;
    nCpu.registers.f = f;
    nCpu.registers.a = cast(ubyte)~nCpu.registers.a;

    return nCpu;
}

pure Cpu rlc(Cpu cpu, Register r)
{

    Cpu nCpu = cpu;
    Flags f;
    nCpu.registers.f = f;

    import core.bitop;

    ubyte rVal = getRegisterValue(cpu, r);
    return setRegisterValue(nCpu, r, rol(rVal, 1));
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

pure Cpu rrc(Cpu cpu, Register r)
{

    Cpu nCpu = cpu;
    Flags f;
    nCpu.registers.f = f;

    import core.bitop;

    ubyte rVal = getRegisterValue(cpu, r);
    return setRegisterValue(nCpu, r, ror(rVal, 1));
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

pure Cpu rl(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ushort cFlag = nCpu.registers.f.carry ? 1 : 0;
    ubyte rVal = getRegisterValue(cpu, r);
    ushort newA = cast(ushort)((rVal << 1) + cFlag);

    Flags f;
    f.carry = newA > 0xFF;
    nCpu.registers.f = f;

    return setRegisterValue(nCpu, r, cast(ubyte) newA);
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

pure Cpu rr(Cpu cpu, Register r)
{
    Cpu nCpu = cpu;
    ushort cFlag = nCpu.registers.f.carry ? 1 : 0;
    ubyte rVal = getRegisterValue(cpu, r);
    ushort newA = cast(ushort)((rVal >> 1)
            + (cFlag << 7)
            + (
                (rVal & 1) << 8
            ));

    Flags f;
    f.carry = newA > 0xFF;
    nCpu.registers.f = f;

    return setRegisterValue(cpu, r, cast(ubyte) newA);
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
    ushort hlValue = nCpu.getRegisterHL;
    Tuple!(bool, ushort) resultT = overflowingAdd16(hlValue, targetValue);
    bool isOverflow = resultT[0];
    ushort result = resultT[1];

    Flags f;
    f.zero = result == 0;
    f.subtract = false;
    f.halfCarry = targetValue + (hlValue & 0xFF) > 0xFF;
    f.carry = isOverflow;

    nCpu.registers.f = f;
    nCpu = nCpu.setRegisterHL(result);

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

    c1 = c1.setRegisterHL(255);
    c1.registers.b = 1;

    Cpu res1 = addhl(c1, Register.B);
    assert(res1.getRegisterHL() == 256);
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
