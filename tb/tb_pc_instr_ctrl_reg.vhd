library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Deprecated integration testbench from early project iterations.
-- Kept as a placeholder to avoid build errors; use tb_cpu and unit-level benches instead.
entity tb_pc_instr_ctrl_reg is
end tb_pc_instr_ctrl_reg;

architecture tb of tb_pc_instr_ctrl_reg is
begin
    process
    begin
        report "tb_pc_instr_ctrl_reg: deprecated/ignored (placeholder)." severity note;
        wait;
    end process;
end tb;
