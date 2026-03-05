library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Minimal trap/exception unit for the RV32I single-cycle core.
-- This design uses a fixed trap vector (TRAP_VECTOR) and does not implement CSRs.
-- Supported trap sources:
--  - illegal instruction (decoder)
--  - ECALL / EBREAK
--  - misaligned load/store
--  - misaligned instruction fetch (PC[1:0] != 00)
entity trap_unit is
    Generic (
        TRAP_VECTOR : std_logic_vector(31 downto 0) := x"00000080"
    );
    Port (
        pc                 : in  std_logic_vector(31 downto 0);
        illegal_insn       : in  std_logic;
        ecall              : in  std_logic;
        ebreak             : in  std_logic;
        misaligned_ls      : in  std_logic; -- from LSU, for load or store
        misaligned_fetch   : in  std_logic;

        trap_taken         : out std_logic;
        trap_target        : out std_logic_vector(31 downto 0);
        trap_cause         : out std_logic_vector(3 downto 0) -- small, project-defined
    );
end trap_unit;

architecture rtl of trap_unit is
begin
    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(pc, illegal_insn, ecall, ebreak, misaligned_ls, misaligned_fetch)
    begin
        trap_taken  <= '0';
        trap_target <= TRAP_VECTOR;
        trap_cause  <= "0000";

        if misaligned_fetch = '1' then
            trap_taken <= '1';
            trap_cause <= "0001";
        elsif misaligned_ls = '1' then
            trap_taken <= '1';
            trap_cause <= "0010";
        elsif illegal_insn = '1' then
            trap_taken <= '1';
            trap_cause <= "0011";
        elsif ecall = '1' then
            trap_taken <= '1';
            trap_cause <= "0100";
        elsif ebreak = '1' then
            trap_taken <= '1';
            trap_cause <= "0101";
        end if;
    end process;
end rtl;
