library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_TX is
    Port (
        clk  : in  STD_LOGIC;
        flag_go : in  STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(0 to 127) ; 
        Tx   : out STD_LOGIC
    );
end UART_TX;

architecture Behavioral of UART_TX is

constant baud_rate : integer := 9600;
constant clk_freq : integer := 100000000; 

signal reset : std_logic:= '0'; 
signal clk_out : std_logic;
signal counter : integer range 0 to 129 := 0; -- bits : (1 start, 128 data,1 stop)

   
component Clk_Divider is
port ( clk,reset: in std_logic;
       clock_out: out std_logic);
end component;
    
    
begin

baud_clk: Clk_Divider port map (clk,reset,clk_out);


    
process(clk_out)
begin

if rising_edge(clk_out) then
	if flag_go = '1' then
        if counter =0 then
            Tx <= '0';
            counter<=counter+1;
        elsif counter>0 and counter<129 then
            Tx <=data_in(counter-1);
            counter<=counter+1;
        elsif counter =129 then
            Tx <= '1';
            counter<=0;
        else
            counter<=0;
        end if;
     
    else
        Tx <= '1'; 
        counter <= 0;    
    end if;
end if;	

end process;

end Behavioral;
