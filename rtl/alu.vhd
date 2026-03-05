library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
        A      : in  std_logic_vector(31 downto 0);
        B      : in  std_logic_vector(31 downto 0);
        alu_op : in  std_logic_vector(3 downto 0);
        result : out std_logic_vector(31 downto 0);
        zero   : out std_logic
    );
end alu;

architecture Behavioral of alu is
    signal a_int, b_int : signed(31 downto 0);
    signal a_u, b_u     : unsigned(31 downto 0);
    signal r_int        : signed(31 downto 0);
begin
    -- Convert input vectors to signed and unsigned types
    a_int <= signed(A);
    b_int <= signed(B);
    a_u   <= unsigned(A);
    b_u   <= unsigned(B);

    -- ALU operation logic
    process(a_int, b_int, a_u, b_u, alu_op)
    begin
        r_int <= (others => '0');  -- Default output to avoid undefined values

        case alu_op is
            when "0000" =>  -- ADD (signed)
                r_int <= a_int + b_int;
            when "0001" =>  -- SUB (signed)
                r_int <= a_int - b_int;
            when "0010" =>  -- LUI (load upper immediate)
                r_int <= b_int;
            when "0011" =>  -- SLL (logical left shift)
                r_int <= shift_left(a_int, to_integer(b_u(4 downto 0)));
            when "0100" =>  -- SLT (set if less than, signed)
                if a_int < b_int then
                    r_int <= to_signed(1, 32);
                else
                    r_int <= to_signed(0, 32);
                end if;
            when "0101" =>  -- SLTU (set if less than, unsigned)
                if a_u < b_u then
                    r_int <= to_signed(1, 32);
                else
                    r_int <= to_signed(0, 32);
                end if;
            when "0110" =>  -- XOR (bitwise)
                r_int <= a_int xor b_int;
            when "0111" =>  -- SRL (logical right shift)
                r_int <= signed(shift_right(a_u, to_integer(b_u(4 downto 0))));
            when "1000" =>  -- SRA (arithmetic right shift)
                r_int <= shift_right(a_int, to_integer(b_u(4 downto 0)));
            when "1001" =>  -- OR (bitwise)
                r_int <= a_int or b_int;
            when "1010" =>  -- AND (bitwise)
                r_int <= a_int and b_int;
            when others =>
                null;  -- No operation, keep default zero
        end case;
    end process;

    -- Output result and zero flag
    result <= std_logic_vector(r_int);
    zero   <= '1' when r_int = to_signed(0, 32) else '0';
end Behavioral;
