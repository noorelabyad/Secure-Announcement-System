----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2023 01:40:18 PM
-- Design Name: 
-- Module Name: displayEncrypted - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity displayEncrypted is
    Port ( data_in : in STD_LOGIC_VECTOR (0 to 127);
           flagDoneReceiving : in STD_LOGIC;
           flagDoneConverting : out STD_LOGIC;
           data_out : out string (1 to 32) := (others => NUL));
end displayEncrypted;

architecture Behavioral of displayEncrypted is

begin

process (flagDoneReceiving)
begin
    if (flagDoneReceiving = '1') then
    for i in 1 to 32 loop
        case data_in(4*(i-1) to 4*(i-1)+3) is
            when x"0" => data_out (i) <= '0';
            when x"1" => data_out (i) <= '1';
            when x"2" => data_out (i) <= '2';
            when x"3" => data_out (i) <= '3';
            when x"4" => data_out (i) <= '4';
            when x"5" => data_out (i) <= '5';
            when x"6" => data_out (i) <= '6';
            when x"7" => data_out (i) <= '7';
            when x"8" => data_out (i) <= '8';
            when x"9" => data_out (i) <= '9';
            when x"A" => data_out (i) <= 'A';
            when x"B" => data_out (i) <= 'B';
            when x"C" => data_out (i) <= 'C';
            when x"D" => data_out (i) <= 'D';
            when x"E" => data_out (i) <= 'E';
            when x"F" => data_out (i) <= 'F';
            
            when others => data_out (i) <= ' ';
            
          end case;
          
    end loop;
    flagDoneConverting <= '1';
    end if;
end process;

end Behavioral;
