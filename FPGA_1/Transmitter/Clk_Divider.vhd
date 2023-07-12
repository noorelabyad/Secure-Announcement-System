library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
  
entity Clk_Divider is
port ( clk,reset: in std_logic;
       clock_out: out std_logic);
end Clk_Divider;
  
architecture Behavioral of Clk_Divider is
constant baud_rate : integer := 9600;
constant clk_freq : integer := 100000000; 
signal count : integer := 0;
signal tmp : std_logic := '0';
  
begin
  
process(clk,reset)
begin
    if(reset='1') then
        count <= 0;
        tmp <= '0';
    elsif(clk'event and clk='1') then
        count <=count+1;
        if (count = (clk_freq / baud_rate) -1 ) then
            tmp <= NOT tmp;
            count <= 0;
        end if;
    end if;
    clock_out <= tmp;
end process;
  
end Behavioral;