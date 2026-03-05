library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_load_store_unit is
end tb_load_store_unit;

architecture tb of tb_load_store_unit is
    signal addr : std_logic_vector(31 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal is_load, is_store : std_logic;
    signal rs2_store_data : std_logic_vector(31 downto 0);
    signal mem_rdata_raw : std_logic_vector(31 downto 0);
    signal mem_wdata : std_logic_vector(31 downto 0);
    signal mem_wstrb : std_logic_vector(3 downto 0);
    signal load_result : std_logic_vector(31 downto 0);
    signal misaligned : std_logic;

    procedure check(cond : boolean; msg : string) is
    begin
        assert cond report msg severity failure;
    end procedure;
begin
    dut: entity work.load_store_unit
        port map (
            addr           => addr,
            funct3         => funct3,
            is_load        => is_load,
            is_store       => is_store,
            rs2_store_data => rs2_store_data,
            mem_rdata_raw  => mem_rdata_raw,
            mem_wdata      => mem_wdata,
            mem_wstrb      => mem_wstrb,
            load_result    => load_result,
            misaligned     => misaligned
        );

    process
    begin
        -- Store byte at addr+1
        is_store <= '1'; is_load <= '0';
        funct3 <= "000"; -- SB
        addr <= x"00000001";
        rs2_store_data <= x"000000AA";
        mem_rdata_raw <= x"11223344";
        wait for 1 ns;
        check(mem_wstrb="0010" and mem_wdata(15 downto 8)=x"AA", "SB lane1 failed");
        check(misaligned='0', "SB should not misalign");

        -- Store halfword misaligned
        funct3 <= "001"; -- SH
        addr <= x"00000001";
        wait for 1 ns;
        check(misaligned='1', "SH misalign detect failed");

        -- Load byte signed (LB) from lane3 of 0x80xxxxxx -> sign extend
        is_store <= '0'; is_load <= '1';
        funct3 <= "000"; -- LB
        addr <= x"00000003";
        mem_rdata_raw <= x"80FFFFFF";
        wait for 1 ns;
        check(load_result(31 downto 8)=x"FFFFFF" and load_result(7 downto 0)=x"80", "LB sign extend failed");

        -- Load byte unsigned (LBU)
        funct3 <= "100"; -- LBU
        wait for 1 ns;
        check(load_result(31 downto 8)=x"000000" and load_result(7 downto 0)=x"80", "LBU zero extend failed");

        -- Load word misaligned
        funct3 <= "010"; -- LW
        addr <= x"00000002";
        wait for 1 ns;
        check(misaligned='1', "LW misalign detect failed");

        report "tb_load_store_unit PASSED" severity note;
        wait;
    end process;
end tb;
