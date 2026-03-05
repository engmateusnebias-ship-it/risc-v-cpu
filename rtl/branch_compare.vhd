library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Branch comparator for RV32I.
-- Evaluates branch condition based on funct3 and rs1/rs2 values.
entity branch_compare is
    Port (
        funct3       : in  std_logic_vector(2 downto 0);
        rs1          : in  std_logic_vector(31 downto 0);
        rs2          : in  std_logic_vector(31 downto 0);
        branch_taken : out std_logic
    );
end branch_compare;

architecture rtl of branch_compare is
begin
    -- VHDL-93/VHDL-2002 compatible combinational process (no process(all)).
    process(funct3, rs1, rs2)
        variable s1v, s2v : signed(31 downto 0);
        variable u1v, u2v : unsigned(31 downto 0);
    begin
        s1v := signed(rs1);
        s2v := signed(rs2);
        u1v := unsigned(rs1);
        u2v := unsigned(rs2);

        branch_taken <= '0';

        case funct3 is
            when "000" => -- BEQ
                if rs1 = rs2 then branch_taken <= '1'; end if;
            when "001" => -- BNE
                if rs1 /= rs2 then branch_taken <= '1'; end if;
            when "100" => -- BLT
                if s1v < s2v then branch_taken <= '1'; end if;
            when "101" => -- BGE
                if s1v >= s2v then branch_taken <= '1'; end if;
            when "110" => -- BLTU
                if u1v < u2v then branch_taken <= '1'; end if;
            when "111" => -- BGEU
                if u1v >= u2v then branch_taken <= '1'; end if;
            when others =>
                branch_taken <= '0';
        end case;
    end process;
end rtl;
