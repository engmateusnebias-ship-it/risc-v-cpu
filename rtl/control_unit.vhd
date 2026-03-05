library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Control Unit for a single-cycle RV32I core.
-- Decodes the instruction and generates control signals for the datapath, LSU, and trap unit.
entity control_unit is
    Port (
        instr           : in  std_logic_vector(31 downto 0);

        -- Datapath control
        reg_write       : out std_logic;
        alu_src_a_pc    : out std_logic;  -- '1' selects PC as ALU A input (AUIPC), '0' selects rs1
        alu_src_b_imm   : out std_logic;  -- '1' selects immediate as ALU B input, '0' selects rs2
        alu_op_ctrl     : out std_logic_vector(1 downto 0); -- fed to alu_control

        -- PC control intent (final decision done in cpu.vhd)
        is_branch       : out std_logic;
        is_jal          : out std_logic;
        is_jalr         : out std_logic;

        -- Writeback selection
        -- 00: ALU result
        -- 01: Load result
        -- 10: PC+4 (JAL/JALR)
        -- 11: Reserved (currently maps to ALU result)
        wb_sel          : out std_logic_vector(1 downto 0);

        -- Memory access intent (raw, before LSU expansion)
        mem_re          : out std_logic;
        mem_we          : out std_logic;

        -- LSU decode (based on funct3)
        mem_size        : out std_logic_vector(1 downto 0); -- 00=byte, 01=half, 10=word
        mem_unsigned    : out std_logic; -- for loads only: 1=zero-extend (LBU/LHU)

        -- Trap / special
        fence_nop       : out std_logic; -- FENCE / FENCE.I treated as NOP (decoded)
        ecall           : out std_logic;
        ebreak          : out std_logic;
        illegal_insn    : out std_logic
    );
end control_unit;

architecture rtl of control_unit is
    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);

    -- Helper
    function is_valid_shift_imm(f3 : std_logic_vector(2 downto 0); f7 : std_logic_vector(6 downto 0)) return boolean is
    begin
        if f3 = "001" and f7 = "0000000" then
            return true; -- SLLI
        elsif f3 = "101" and (f7 = "0000000" or f7 = "0100000") then
            return true; -- SRLI/SRAI
        else
            return false;
        end if;
    end function;
begin
    opcode <= instr(6 downto 0);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);

	-- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
	process(instr, opcode, funct3, funct7)
        variable ill : std_logic;
        variable ms  : std_logic_vector(1 downto 0);
        variable mu  : std_logic;
    begin
        -- Defaults
        reg_write     <= '0';
        alu_src_a_pc  <= '0';
        alu_src_b_imm <= '0';
        alu_op_ctrl   <= "00";

        is_branch     <= '0';
        is_jal        <= '0';
        is_jalr       <= '0';

        wb_sel        <= "00";

        mem_re        <= '0';
        mem_we        <= '0';
        mem_size      <= "10"; -- word by default
        mem_unsigned  <= '0';

        fence_nop     <= '0';
        ecall         <= '0';
        ebreak        <= '0';
        illegal_insn  <= '0';

        ill := '0';
        ms  := "10";
        mu  := '0';

        case opcode is
            when "0110011" => -- R-type ALU
                reg_write   <= '1';
                alu_op_ctrl <= "10";
                wb_sel      <= "00";
                -- Basic validation (funct3/funct7 combos handled in alu_control)
                -- If alu_control outputs invalid, trap_unit can optionally treat as illegal (not done here).
            when "0010011" => -- I-type ALU immediate
                reg_write     <= '1';
                alu_src_b_imm <= '1';
                alu_op_ctrl   <= "00";
                wb_sel        <= "00";

                -- Validate shift-immediate encodings
                if funct3 = "001" or funct3 = "101" then
                    if not is_valid_shift_imm(funct3, funct7) then
                        ill := '1';
                    end if;
                end if;

            when "0000011" => -- LOADS
                reg_write     <= '1';
                alu_src_b_imm <= '1';
                alu_op_ctrl   <= "00"; -- alu_control will force ADD for load/store based on opcode
                mem_re        <= '1';
                wb_sel        <= "01";

                -- Size and signedness by funct3
                case funct3 is
                    when "000" => ms := "00"; mu := '0'; -- LB
                    when "001" => ms := "01"; mu := '0'; -- LH
                    when "010" => ms := "10"; mu := '0'; -- LW
                    when "100" => ms := "00"; mu := '1'; -- LBU
                    when "101" => ms := "01"; mu := '1'; -- LHU
                    when others => ill := '1';
                end case;

            when "0100011" => -- STORES
                alu_src_b_imm <= '1';
                alu_op_ctrl   <= "00"; -- force ADD
                mem_we        <= '1';

                case funct3 is
                    when "000" => ms := "00"; -- SB
                    when "001" => ms := "01"; -- SH
                    when "010" => ms := "10"; -- SW
                    when others => ill := '1';
                end case;

            when "1100011" => -- BRANCH
                is_branch     <= '1';
                alu_op_ctrl   <= "01"; -- not used for compare, but kept for legacy
                -- validate funct3
                case funct3 is
                    when "000" | "001" | "100" | "101" | "110" | "111" =>
                        null; -- BEQ/BNE/BLT/BGE/BLTU/BGEU
                    when others =>
                        ill := '1';
                end case;

            when "1101111" => -- JAL
                reg_write   <= '1';
                is_jal      <= '1';
                wb_sel      <= "10"; -- PC+4

            when "1100111" => -- JALR
                reg_write     <= '1';
                is_jalr       <= '1';
                alu_src_b_imm <= '1'; -- rs1 + imm for target
                wb_sel        <= "10"; -- PC+4
                -- funct3 must be 000
                if funct3 /= "000" then
                    ill := '1';
                end if;

            when "0110111" => -- LUI
                reg_write     <= '1';
                alu_src_b_imm <= '1';
                alu_op_ctrl   <= "11"; -- LUI path in ALU (pass B)
                wb_sel        <= "00";

            when "0010111" => -- AUIPC
                reg_write     <= '1';
                alu_src_a_pc  <= '1';
                alu_src_b_imm <= '1';
                alu_op_ctrl   <= "00"; -- ADD
                wb_sel        <= "00";

            when "0001111" => -- FENCE / FENCE.I
                fence_nop <= '1'; -- treated as NOP (no memory ordering in this simple core)

            when "1110011" => -- SYSTEM (ECALL/EBREAK only in this simple core)
                -- Note: In RV32I, ECALL and EBREAK are fixed 32-bit encodings.
                -- ECALL  = 0x00000073
                -- EBREAK = 0x00100073
                if instr = x"00000073" then
                    ecall <= '1';
                elsif instr = x"00100073" then
                    ebreak <= '1';
                else
                    ill := '1'; -- CSR operations not implemented in this core
                end if;

            when others =>
                ill := '1';
        end case;

        mem_size     <= ms;
        mem_unsigned <= mu;

        illegal_insn <= ill;
    end process;
end rtl;
