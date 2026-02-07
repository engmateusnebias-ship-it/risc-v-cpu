library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu_control is
end tb_alu_control;

architecture sim of tb_alu_control is
    constant clk_period : time := 10 ns;

    signal alu_op_ctrl        : std_logic_vector(1 downto 0);
    signal funct3             : std_logic_vector(2 downto 0);
    signal funct7             : std_logic_vector(6 downto 0);
    signal alu_control_signal : std_logic_vector(3 downto 0);
begin
    uut: entity work.alu_control
        port map (
            alu_op_ctrl        => alu_op_ctrl,
            funct3             => funct3,
            funct7             => funct7,
            alu_control_signal => alu_control_signal
        );

    stim_proc: process
    begin
        -- R-type: SLT
        alu_op_ctrl <= "10"; funct3 <= "010"; funct7 <= "0000000"; wait for clk_period;
        assert alu_control_signal = "0100" report "SLT failed" severity error;

        -- R-type: SLTU
        alu_op_ctrl <= "10"; funct3 <= "011"; funct7 <= "0000000"; wait for clk_period;
        assert alu_control_signal = "0101" report "SLTU failed" severity error;

        -- I-type: SLTIU
        alu_op_ctrl <= "00"; funct3 <= "011"; funct7 <= "0000000"; wait for clk_period;
        assert alu_control_signal = "0101" report "SLTIU failed" severity error;

        -- I-type: XORI
        alu_op_ctrl <= "00"; funct3 <= "100"; funct7 <= "0000000"; wait for clk_period;
        assert alu_control_signal = "0110" report "XORI failed" severity error;

        -- I-type: SLLI
        alu_op_ctrl <= "00"; funct3 <= "001"; funct7 <= "0000000"; wait for clk_period;
        assert alu_control_signal = "0011" report "SLLI failed" severity error;

        -- Branch: BNE
        alu_op_ctrl <= "01"; funct3 <= "001"; funct7 <= "0000000"; wait for clk_period;
        assert alu_control_signal = "0001" report "BNE failed" severity error;

        -- Branch: BLT
        alu_op_ctrl <= "01"; funct3 <= "100"; funct7 <= "0000000"; wait for clk_period;
        assert alu_control_signal = "0001" report "BLT failed" severity error;

        -- Branch: BGE
        alu_op_ctrl <= "01"; funct3 <= "101"; funct7 <= "0000000"; wait for clk_period;
        assert alu_control_signal = "0001" report "BGE failed" severity error;

        -- Invalid funct3
        alu_op_ctrl <= "00"; funct3 <= "110"; funct7 <= "1111111"; wait for clk_period;
        assert alu_control_signal /= "1111" report "Invalid funct7 not detected" severity warning;

        report "All ALU control tests passed." severity note;
        wait;
    end process;
end sim;
