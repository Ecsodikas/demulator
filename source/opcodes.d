module opcodes;

import cpu;
import instructionset;

pure Cpu executeInstructionPrefixed(Cpu cpu, ubyte opcode)
{
    switch (opcode)
    {
    case 0x00:
        return cpu;
    default:
        assert(0);
    }
}

pure Cpu executeInstruction(Cpu cpu, ubyte opcode)
{
    switch (opcode)
    {
    case 0x00:
        return nop(cpu);
    default:
        assert(0);
    }
}
