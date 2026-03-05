library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu is
end tb_alu;

architecture sim of tb_alu is
    signal A, B       : std_logic_vector(31 downto 0);
    signal alu_op     : std_logic_vector(3 downto 0);
    signal result     : std_logic_vector(31 downto 0);
    signal zero       : std_logic;

    component alu
        Port (
            A      : in  std_logic_vector(31 downto 0);
            B      : in  std_logic_vector(31 downto 0);
            alu_op : in  std_logic_vector(3 downto 0);
            result : out std_logic_vector(31 downto 0);
            zero   : out std_logic
        );
    end component;
begin
    uut: alu
        port map (
            A      => A,
            B      => B,
            alu_op => alu_op,
            result => result,
            zero   => zero
        );

    stimulus: process
    begin
        -- ADD: 5 + 3 = 8
        A <= std_logic_vector(to_signed(5, 32));
        B <= std_logic_vector(to_signed(3, 32));
        alu_op <= "0000"; wait for 10 ns;
        assert result = std_logic_vector(to_signed(8, 32))
            report "ADD failed" severity error;
        assert zero = '0'
            report "ADD zero flag incorrect" severity error;

        -- SUB: 10 - 10 = 0
        A <= std_logic_vector(to_signed(10, 32));
        B <= std_logic_vector(to_signed(10, 32));
        alu_op <= "0001"; wait for 10 ns;
        assert result = std_logic_vector(to_signed(0, 32))
            report "SUB failed" severity error;
        assert zero = '1'
            report "SUB zero flag incorrect" severity error;

        -- LUI: B = 0x12340000
        A <= (others => '0');
        B <= x"12340000";
        alu_op <= "0010"; wait for 10 ns;
        assert result = x"12340000"
            report "LUI failed" severity error;

        -- SLL: 1 << 3 = 8
        A <= std_logic_vector(to_signed(1, 32));
        B <= std_logic_vector(to_signed(3, 32));
        alu_op <= "0011"; wait for 10 ns;
        assert result = std_logic_vector(to_signed(8, 32))
            report "SLL failed" severity error;

        -- SLT: 5 < 10 = 1
        A <= std_logic_vector(to_signed(5, 32));
        B <= std_logic_vector(to_signed(10, 32));
        alu_op <= "0100"; wait for 10 ns;
        assert result = std_logic_vector(to_signed(1, 32))
            report "SLT failed" severity error;

        -- SLTU: 5 < 10 = 1 (unsigned)
        A <= std_logic_vector(to_unsigned(5, 32));
        B <= std_logic_vector(to_unsigned(10, 32));
        alu_op <= "0101"; wait for 10 ns;
        assert result = std_logic_vector(to_signed(1, 32))
            report "SLTU failed" severity error;

        -- XOR: 0xF0F0F0F0 xor 0x0F0F0F0F = 0xFFFFFFFF
        A <= x"F0F0F0F0";
        B <= x"0F0F0F0F";
        alu_op <= "0110"; wait for 10 ns;
        assert result = x"FFFFFFFF"
            report "XOR failed" severity error;

        -- SRL: 0x80000000 >> 1 = 0x40000000
        A <= x"80000000";
        B <= std_logic_vector(to_unsigned(1, 32));
        alu_op <= "0111"; wait for 10 ns;
        assert result = x"40000000"
            report "SRL failed" severity error;

        -- SRA: -4 >> 1 = -2
        A <= std_logic_vector(to_signed(-4, 32));
        B <= std_logic_vector(to_unsigned(1, 32));
        alu_op <= "1000"; wait for 10 ns;
        assert result = std_logic_vector(to_signed(-2, 32))
            report "SRA failed" severity error;

        -- OR: 0xF0F0F0F0 or 0x0F0F0F0F = 0xFFFFFFFF
        A <= x"F0F0F0F0";
        B <= x"0F0F0F0F";
        alu_op <= "1001"; wait for 10 ns;
        assert result = x"FFFFFFFF"
            report "OR failed" severity error;

        -- AND: 0xF0F0F0F0 and 0x0F0F0F0F = 0x00000000
        A <= x"F0F0F0F0";
        B <= x"0F0F0F0F";
        alu_op <= "1010"; wait for 10 ns;
        assert result = x"00000000"
            report "AND failed" severity error;
        assert zero = '1'
            report "AND zero flag incorrect" severity error;

        report "All ALU tests passed." severity note;
        wait;
    end process;
end sim;
