library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity tb_instruction_memory is
end tb_instruction_memory;

architecture sim of tb_instruction_memory is

    signal addr        : std_logic_vector(31 downto 0) := (others => '0');
    signal instruction : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

    function to_hex_string(slv: std_logic_vector) return string is
        variable result : string(1 to slv'length/4);
        variable temp   : std_logic_vector(3 downto 0);
        variable hexval : integer;
    begin
        for i in 0 to slv'length/4 - 1 loop
            temp := slv(slv'high - i*4 downto slv'high - i*4 - 3);
            hexval := to_integer(unsigned(temp));
            case hexval is
                when 0  => result(i+1) := '0';
                when 1  => result(i+1) := '1';
                when 2  => result(i+1) := '2';
                when 3  => result(i+1) := '3';
                when 4  => result(i+1) := '4';
                when 5  => result(i+1) := '5';
                when 6  => result(i+1) := '6';
                when 7  => result(i+1) := '7';
                when 8  => result(i+1) := '8';
                when 9  => result(i+1) := '9';
                when 10 => result(i+1) := 'A';
                when 11 => result(i+1) := 'B';
                when 12 => result(i+1) := 'C';
                when 13 => result(i+1) := 'D';
                when 14 => result(i+1) := 'E';
                when others => result(i+1) := 'F';
            end case;
        end loop;
        return result;
    end function;

begin

    uut: entity work.instruction_memory
        port map (
            addr        => addr,
            instruction => instruction
        );

    stim_proc: process
    begin
        for i in 0 to 21 loop  -- 22 instructions in program.mem
            addr <= std_logic_vector(to_unsigned(i * 4, 32));
            wait for clk_period;
            report "Instruction at " & integer'image(i*4) & ": " & to_hex_string(instruction);
        end loop;

        report "Instruction memory test completed." severity note;
        wait;
    end process;

end sim;
