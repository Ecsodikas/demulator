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

}

pure ushort getRegisterAF(Cpu cpu)
{
    ushort ra = cast(ushort) cpu.registers.a;
    ushort rf = cast(ushort) cpu.registers.f.fromFlags;
    return cast(ushort)(ra << 8 | rf);
}

pure Cpu setRegisterAF(Cpu cpu, ushort val)
{
    Cpu nCpu = cpu;
    nCpu.registers.a = cast(ushort)((val & 0xFF00) >> 8);

    Flags fl;
    nCpu.registers.f = fl.fromRegister(cast(ushort)(val & 0xFF));
    return nCpu;
}

pure ushort getRegisterBC(Cpu cpu)
{
    ushort rb = cast(ushort) cpu.registers.b;
    ushort rc = cast(ushort) cpu.registers.c;
    return cast(ushort)(rb << 8 | rc);
}

pure Cpu setRegisterBC(Cpu cpu, ushort val)
{
    Cpu nCpu = cpu;
    nCpu.registers.b = cast(ushort)((val & 0xFF00) >> 8);
    nCpu.registers.c = cast(ushort)(val & 0xFF);
    return nCpu;
}

pure ushort getRegisterDE(Cpu cpu)
{
    ushort rd = cast(ushort) cpu.registers.d;
    ushort re = cast(ushort) cpu.registers.e;
    return cast(ushort)(rd << 8 | re);
}

pure Cpu setRegisterDE(Cpu cpu, ushort val)
{
    Cpu nCpu = cpu;
    nCpu.registers.d = cast(ushort)((val & 0xFF00) >> 8);
    nCpu.registers.e = cast(ushort)(val & 0xFF);
    return nCpu;
}

pure ushort getRegisterHL(Cpu cpu)
{
    ushort rh = cast(ushort) cpu.registers.h;
    ushort rl = cast(ushort) cpu.registers.l;
    return cast(ushort)(rh << 8 | rl);
}

pure Cpu setRegisterHL(Cpu cpu, ushort val)
{
    Cpu nCpu = cpu;
    nCpu.registers.h = cast(ushort)((val & 0xFF00) >> 8);
    nCpu.registers.l = cast(ushort)(val & 0xFF);
    return nCpu;
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
