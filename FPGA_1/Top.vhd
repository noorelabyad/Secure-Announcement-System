library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Top is
    Port ( clk : in STD_LOGIC;
           ps2_clk : in STD_LOGIC;
           ps2_data : in STD_LOGIC;
           Tx: out std_logic);
end Top;

architecture Behavioral of Top is

COMPONENT ps2_keyboard_to_ascii IS
  GENERIC(
      clk_freq                  : INTEGER := 100_000_000; --system clock frequency in Hz
      ps2_debounce_counter_size : INTEGER := 9);         --set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
  PORT(
      clk        : IN  STD_LOGIC;                     --system clock input
      ps2_clk    : IN  STD_LOGIC;                     --clock signal from PS2 keyboard
      ps2_data   : IN  STD_LOGIC;                     --data signal from PS2 keyboard
      ascii_new  : OUT STD_LOGIC;                     --output flag indicating new ASCII value
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); --ASCII value
END COMPONENT;

component Top_Encryption is
Port ( data_in : in std_logic_vector(0 to 127);
           data_out : out std_logic_vector(0 to 127);
           flag_go: in std_logic;
           flag_done: out std_logic);
end component;

component UART_TX is
    Port (clk: in std_logic;
    flag_go: in std_logic;
    data_in: in std_logic_vector(127 downto 0) ;
    Tx: out std_logic );
end component;


signal ascii_new:std_logic;
signal ascii_code :  STD_LOGIC_VECTOR(0 to 6);
signal data,data_encrypted :STD_LOGIC_VECTOR(0 to 127):=(others=>'0');
signal flag_matrix_done,flag_encrypt_done:std_logic:='0';
signal reset :std_logic:='0';


begin

Keyboard : ps2_keyboard_to_ascii port map(clk,ps2_clk,ps2_data,ascii_new,ascii_code);
Encryption : Top_Encryption port map (data,data_encrypted,flag_matrix_done,flag_encrypt_done);
Tx1: UART_TX port map(clk,flag_encrypt_done,data_encrypted,Tx);


process(ascii_new)
variable counter: integer range 0 to 16:=0;
begin
if rising_edge(ascii_new) then
    
        if counter<16 then
            data(8*counter to 8*counter+7)<='0' & ascii_code;
            counter:=counter+1;
        end if; 
        if counter=16 then 
            flag_matrix_done<='1' after 100 us;
            counter:=0;
        end if;
end if;
end process;

end Behavioral;
