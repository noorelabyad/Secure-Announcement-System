----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2023 02:55:33 PM
-- Design Name: 
-- Module Name: Baud_Clock_Divider - Behavioral
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

entity Baud_Clock_Divider is
  Port (clk : in STD_LOGIC;
        baudClock : inout STD_LOGIC);
end Baud_Clock_Divider;

architecture Behavioral of Baud_Clock_Divider is

constant baudRate : integer := 9600;
constant oneMHz : integer := 100000000;

begin


    process (clk)
        variable counterCD : integer range 0 to ((oneMHz / baudRate) - 1) := 0;
    begin
        if rising_edge(clk) then
            if counterCD = ((oneMHz / baudRate) - 1) then
                baudClock <= not baudClock;
                counterCD := 0;
            else
                counterCD := counterCD + 1;
            end if;
        end if;
    end process;

end Behavioral;
