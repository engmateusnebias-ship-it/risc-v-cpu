library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_alu_control is
end tb_alu_control;

architecture tb of tb_alu_control is
    signal opcode      : std_logic_vector(6 downto 0);
    signal alu_op_ctrl : std_logic_vector(1 downto 0);
    signal funct3      : std_logic_vector(2 downto 0);
    signal funct7      : std_logic_vector(6 downto 0);
    signal alu_sig     : std_logic_vector(3 downto 0);

    procedure check(cond : boolean; msg : string) is
    begin
        assert cond report msg severity failure;
    end procedure;
begin
    dut: entity work.alu_control
        port map (
            opcode             => opcode,
            alu_op_ctrl        => alu_op_ctrl,
            funct3             => funct3,
            funct7             => funct7,
            alu_control_signal => alu_sig
        );

    stim: process
    begin
        -- R-type ADD
        opcode <= "0110011"; alu_op_ctrl <= "10"; funct3 <= "000"; funct7 <= "0000000";
        wait for 1 ns;
        check(alu_sig="0000", "R-type ADD failed");

        -- R-type SUB
        funct7 <= "0100000";
        wait for 1 ns;
        check(alu_sig="0001", "R-type SUB failed");

        -- I-type ANDI
        opcode <= "0010011"; alu_op_ctrl <= "00"; funct3 <= "111"; funct7 <= "0000000";
        wait for 1 ns;
        check(alu_sig="1010", "I-type ANDI failed");

        -- LOAD must force ADD (even if funct3=010)
        opcode <= "0000011"; alu_op_ctrl <= "00"; funct3 <= "010";
        wait for 1 ns;
        check(alu_sig="0000", "LOAD force ADD failed");

        -- STORE must force ADD
        opcode <= "0100011"; funct3 <= "000";
        wait for 1 ns;
        check(alu_sig="0000", "STORE force ADD failed");

        -- AUIPC must force ADD
        opcode <= "0010111";
        wait for 1 ns;
        check(alu_sig="0000", "AUIPC force ADD failed");

        -- LUI must pass B
        opcode <= "0110111"; alu_op_ctrl <= "11";
        wait for 1 ns;
        check(alu_sig="0010", "LUI pass B failed");

        report "tb_alu_control PASSED" severity note;
        wait;
    end process;
end tb;
