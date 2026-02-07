library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
    Port (
        clk       : in  std_logic;                          -- Clock signal
        rst       : in  std_logic;                          -- Synchronous reset
        enable    : in  std_logic;                          -- Enable signal (e.g., for stalling)
        next_pc   : in  std_logic_vector(31 downto 0);      -- Next PC value (PC + 4 or branch target)
        pc        : out std_logic_vector(31 downto 0)       -- Current PC value
    );
end program_counter;

architecture rtl of program_counter is
    signal pc_reg : std_logic_vector(31 downto 0) := (others => '0');
begin

    -- Output assignment
    pc <= pc_reg;

    -- Synchronous PC update
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_reg <= (others => '0');                  -- Reset PC to 0
            elsif enable = '1' then
                pc_reg <= next_pc;                          -- Update PC if enabled
            end if;
        end if;
    end process;

end rtl;
