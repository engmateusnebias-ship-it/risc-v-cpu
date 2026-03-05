library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Unit test for control_unit (RV32I decoder).
entity tb_control_unit is
end tb_control_unit;

architecture tb of tb_control_unit is
    signal instr : std_logic_vector(31 downto 0);

    signal reg_write      : std_logic;
    signal alu_src_a_pc   : std_logic;
    signal alu_src_b_imm  : std_logic;
    signal alu_op_ctrl    : std_logic_vector(1 downto 0);
    signal is_branch      : std_logic;
    signal is_jal         : std_logic;
    signal is_jalr        : std_logic;
    signal wb_sel         : std_logic_vector(1 downto 0);
    signal mem_re         : std_logic;
    signal mem_we         : std_logic;
    signal mem_size       : std_logic_vector(1 downto 0);
    signal mem_unsigned   : std_logic;
    signal fence_nop      : std_logic;
    signal ecall          : std_logic;
    signal ebreak         : std_logic;
    signal illegal_insn   : std_logic;

    procedure check(cond : boolean; msg : string) is
    begin
        assert cond report msg severity failure;
    end procedure;

begin
    dut: entity work.control_unit
        port map (
            instr         => instr,
            reg_write     => reg_write,
            alu_src_a_pc  => alu_src_a_pc,
            alu_src_b_imm => alu_src_b_imm,
            alu_op_ctrl   => alu_op_ctrl,
            is_branch     => is_branch,
            is_jal        => is_jal,
            is_jalr       => is_jalr,
            wb_sel        => wb_sel,
            mem_re        => mem_re,
            mem_we        => mem_we,
            mem_size      => mem_size,
            mem_unsigned  => mem_unsigned,
            fence_nop     => fence_nop,
            ecall         => ecall,
            ebreak        => ebreak,
            illegal_insn  => illegal_insn
        );

    stim: process
    begin
        -- ADD x1, x2, x3  (funct7=0, rs2=3, rs1=2, funct3=0, rd=1, opcode=0x33)
        instr <= x"003100B3";
        wait for 1 ns;
        check(reg_write='1' and alu_op_ctrl="10" and alu_src_b_imm='0', "ADD decode failed");

        -- ADDI x1, x2, 1 (imm=1, rs1=2, funct3=0, rd=1, opcode=0x13)
        instr <= x"00110093";
        wait for 1 ns;
        check(reg_write='1' and alu_op_ctrl="00" and alu_src_b_imm='1', "ADDI decode failed");

        -- LB x1, 0(x2) (funct3=000, opcode=0x03)
        instr <= x"00010083";
        wait for 1 ns;
        check(mem_re='1' and wb_sel="01" and mem_size="00" and mem_unsigned='0', "LB decode failed");

        -- LHU x1, 0(x2) (funct3=101)
        instr <= x"00015083";
        wait for 1 ns;
        check(mem_re='1' and mem_size="01" and mem_unsigned='1', "LHU decode failed");

        -- SB x3, 0(x2) (funct3=000, opcode=0x23)
        instr <= x"00310023";
        wait for 1 ns;
        check(mem_we='1' and mem_size="00", "SB decode failed");

        -- BEQ x1, x2, +0 (opcode=0x63)
        instr <= x"00208063";
        wait for 1 ns;
        check(is_branch='1' and illegal_insn='0', "BEQ decode failed");

        -- JAL x1, 0 (opcode=0x6F)
        instr <= x"000000EF";
        wait for 1 ns;
        check(is_jal='1' and wb_sel="10" and reg_write='1', "JAL decode failed");

        -- JALR x1, x2, 0 (opcode=0x67, funct3=000)
        instr <= x"000100E7";
        wait for 1 ns;
        check(is_jalr='1' and wb_sel="10" and alu_src_b_imm='1', "JALR decode failed");

        -- LUI x1, 0x1 (opcode=0x37)
        instr <= x"000010B7";
        wait for 1 ns;
        check(reg_write='1' and alu_op_ctrl="11" and alu_src_b_imm='1', "LUI decode failed");

        -- AUIPC x1, 0x1 (opcode=0x17)
        instr <= x"00001097";
        wait for 1 ns;
        check(reg_write='1' and alu_src_a_pc='1' and alu_src_b_imm='1', "AUIPC decode failed");

        -- FENCE (opcode=0x0F)
        instr <= x"0000000F";
        wait for 1 ns;
        check(fence_nop='1', "FENCE decode failed");

        -- ECALL (0x00000073)
        instr <= x"00000073";
        wait for 1 ns;
        check(ecall='1' and illegal_insn='0', "ECALL decode failed");

        -- Illegal CSR op (0x00200073)
        instr <= x"00200073";
        wait for 1 ns;
        check(illegal_insn='1', "Illegal instruction decode failed");

        report "tb_control_unit PASSED" severity note;
        wait;
    end process;
end tb;
