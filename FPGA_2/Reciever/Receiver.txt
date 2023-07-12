library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Receiver is
    Port (
        clk  : in  STD_LOGIC;
        Rx    : in  STD_LOGIC;
        flagDoneReceiving : out STD_LOGIC;
        Received_Data : out STD_LOGIC_VECTOR(0 to 127)
    );
end Receiver;

architecture Behavioral of Receiver is
    signal  baudClock :   STD_LOGIC;
    signal counter : integer range 0 to 129 := 0; -- 1 start bit + 8 data bits + 1 stop bit
    signal dataByte : STD_LOGIC_VECTOR(0 to 127);
    
    component Baud_Clock_Divider is
      Port (clk : in STD_LOGIC;
            baudClock : inout STD_LOGIC);
    end component;
    
begin
 
    
    BD : Baud_Clock_Divider port map (clk, baudClock);

    
    process (baudClock)
    begin
       
        if rising_edge(baudClock) then
            if counter = 0 then
                if Rx = '0' then
                    counter <= counter + 1;
                end if;
            elsif counter >= 1 and counter <= 128 then
                dataByte(counter - 1) <= Rx;
                counter <= counter + 1;
            elsif counter = 129 then
                counter <= 0;
                Received_Data <= dataByte;
                flagDoneReceiving <= '1';
            end if;
        end if;
    end process;

end Behavioral;
