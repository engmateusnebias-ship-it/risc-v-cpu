library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    Port (
        addr       : in  std_logic_vector(31 downto 0);     -- Address from PC
        instruction: out std_logic_vector(31 downto 0)      -- Instruction at that address
    );
end instruction_memory;

architecture rtl of instruction_memory is

    -- Define memory size (e.g., 256 words of 32 bits)
    type mem_array is array (0 to 255) of std_logic_vector(31 downto 0);
    signal rom : mem_array := (
        -- Example program: manually initialized instructions
        0  => x"00000013",  -- NOP (ADDI x0, x0, 0)
        1  => x"00500113",  -- ADDI x2, x0, 5
        2  => x"00208293",  -- ADDI x5, x1, 2
        3  => x"00B50433",  -- ADD x8, x10, x11
        4  => x"0000006F",  -- JAL x0, 0 (infinite loop)
        others => (others => '0')
    );

    signal word_addr : integer range 0 to 255;

begin

    -- Convert byte address to word index (assuming word-aligned addresses)
    word_addr <= to_integer(unsigned(addr(9 downto 2)));

    -- Asynchronous read
    instruction <= rom(word_addr);

end rtl;
