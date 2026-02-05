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
    a_int <= signed(A);
    b_int <= signed(B);
    a_u   <= unsigned(A);
    b_u   <= unsigned(B);

    process(a_int, b_int, a_u, b_u, alu_op)
    begin
        case alu_op is
            when "0000" =>  -- ADD (Add (signed addition))
                r_int <= a_int + b_int;
            when "0001" =>  -- SUB (Subtract (signed subtraction))
                r_int <= a_int - b_int;
            when "0010" =>  -- LUI (Load Upper Immediate)
                r_int <= b_int;
            when "0011" =>  -- SLL (Shift Left Logical)
                r_int <= shift_left(a_int, to_integer(b_u(4 downto 0)));
            when "0100" =>  -- SLT (Set on Less Than (signed comparison))
                if a_int < b_int then r_int <= to_signed(1, 32);
                else r_int <= to_signed(0, 32);
                end if;
            when "0101" =>  -- SLTU (Set on Less Than Unsigned (unsigned compare))
                if a_u < b_u then r_int <= to_signed(1, 32);
                else r_int <= to_signed(0, 32);
                end if;
            when "0110" =>  -- XOR (Bitwise Exclusive OR)
                r_int <= a_int xor b_int;
            when "0111" =>  -- SRL (Shift Right Logical (unsigned))
                r_int <= signed(shift_right(a_u, to_integer(b_u(4 downto 0))));
            when "1000" =>  -- SRA (Shift Right Arithmetic (signed))
                r_int <= shift_right(a_int, to_integer(b_u(4 downto 0)));
            when "1001" =>  -- OR (Bitwise OR)
                r_int <= a_int or b_int;
            when "1010" =>  -- AND (Bitwise AND)
                r_int <= a_int and b_int;
            when others =>
                r_int <= (others => '0');
        end case;
    end process;

    result <= std_logic_vector(r_int);
    zero   <= '1' when r_int = 0 else '0';
end Behavioral;
