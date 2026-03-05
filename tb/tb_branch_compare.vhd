library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_branch_compare is
end tb_branch_compare;

architecture tb of tb_branch_compare is
    signal funct3 : std_logic_vector(2 downto 0);
    signal rs1, rs2 : std_logic_vector(31 downto 0);
    signal taken : std_logic;

    procedure check(cond : boolean; msg : string) is
    begin
        assert cond report msg severity failure;
    end procedure;
begin
    dut: entity work.branch_compare
        port map (
            funct3       => funct3,
            rs1          => rs1,
            rs2          => rs2,
            branch_taken => taken
        );

    process
    begin
        -- BEQ
        funct3 <= "000"; rs1 <= x"00000005"; rs2 <= x"00000005";
        wait for 1 ns; check(taken='1', "BEQ equal failed");
        rs2 <= x"00000006";
        wait for 1 ns; check(taken='0', "BEQ not-equal failed");

        -- BLT signed: -1 < 1
        funct3 <= "100"; rs1 <= x"FFFFFFFF"; rs2 <= x"00000001";
        wait for 1 ns; check(taken='1', "BLT signed failed");

        -- BLTU unsigned: 0xFFFFFFFF < 1 is false
        funct3 <= "110";
        wait for 1 ns; check(taken='0', "BLTU unsigned failed");

        report "tb_branch_compare PASSED" severity note;
        wait;
    end process;
end tb;
