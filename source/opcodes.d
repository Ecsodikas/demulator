module opcodes;

pure Cpu executeInstruction(Cpu cpu, ubyte opcode)
{
    switch (opcode)
    {
    case 0x0F:
        return cpu;
    default:
        assert(0);
    }
}
