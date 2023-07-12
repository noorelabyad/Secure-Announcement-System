-- Test
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2023 12:41:01 PM
-- Design Name: 
-- Module Name: VGA - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Receive_Decrypt_Display is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           Rx    : in  STD_LOGIC;
           vgaRed : out STD_LOGIC_VECTOR (3 downto 0);
           vgaGreen : out STD_LOGIC_VECTOR (3 downto 0);
           vgaBlue : out STD_LOGIC_VECTOR (3 downto 0);
           Hsync : out STD_LOGIC;
           Vsync : out STD_LOGIC);
end Receive_Decrypt_Display;

architecture Behavioral of Receive_Decrypt_Display is

component ASCII_to_Alpha is
    Port ( data_in : in STD_LOGIC_VECTOR (0 to 127);
           flagDoneDecryption : in STD_LOGIC;
           flagDoneConverting : out STD_LOGIC;
           data_out : out string (1 to 16) := (others => NUL));
end component;

component Clock_Divider is
port ( clk,reset: in std_logic;
       clock_out: out std_logic);
end component;

component Receiver is
    Port (
        clk  : in  STD_LOGIC;
        Rx    : in  STD_LOGIC;
        flagDoneReceiving    : out  STD_LOGIC;
        Received_Data : out STD_LOGIC_VECTOR(0 to 127)
    );
end component;

component wrapper is
  Port (
    clk: in std_logic;
    xCoord: in std_logic_vector(11 downto 0);
    yCoord: in std_logic_vector(11 downto 0);
    pixOn: out std_logic
   );
end component;

component Decryption is
    Port ( data_in : in STD_LOGIC_vector (0 to 127);
           flagDoneReceiving : in STD_LOGIC;
           flagDoneDecryption : out STD_LOGIC;
           data_out : out STD_LOGIC_vector (0 to 127));
end component;

component displayEncrypted is
    Port ( data_in : in STD_LOGIC_VECTOR (0 to 127);
           flagDoneReceiving : in STD_LOGIC;
           flagDoneConverting : out STD_LOGIC;
           data_out : out string (1 to 32) := (others => NUL));
end component;

signal Clock_Out : STD_LOGIC;
signal Video_Out : STD_LOGIC := '0';
signal h : integer range 0 to 800 := 0;
signal v : integer range 0 to 525 := 0;
signal displayTextout1: string (1 to 16) := (others => NUL);
signal displayTextout2: string (1 to 32) := (others => NUL);
signal intermediateData1, intermediateData2: STD_LOGIC_vector (0 to 127);
signal Received_Data : STD_LOGIC_VECTOR (0 to 127) := (others => '0');

    
-- results
signal d1, d2, d3, d4 : std_logic := '0';
signal flagDoneReceiving : std_logic := '0';
signal flagDoneDecryption : std_logic := '0';
signal flagDoneConverting1, flagDoneConverting2  : std_logic := '0';

signal x1 : integer range -256 to 640 := 200;
signal x2 : integer range -256 to 640 := 230;
signal x3 : integer range -256 to 640 := 200;
signal x4 : integer range -256 to 640 := 180;

begin

CD : Clock_Divider port map (clk, reset, Clock_Out);

RX1 : Receiver port map (clk, Rx, flagDoneReceiving, Received_Data);

Decrypt : Decryption port map (Received_Data, flagDoneReceiving, flagDoneDecryption, intermediateData1);
ascii : ASCII_to_Alpha port map (intermediateData1,flagDoneDecryption,flagDoneConverting1,displayTextout1);

DE : displayEncrypted port map (Received_Data, flagDoneReceiving,flagDoneConverting2, displayTextout2);


textElement1: entity work.Pixel_On_Text
	generic map (
		textLength => 25
	)
	port map(
		clk => Clock_Out,
		displayText => "The Decrypted Message is:",
		position => (x1, 220),
		horzCoord => h,
		vertCoord => v,
		pixel => d1
	);

textElement2: entity work.Pixel_On_Text
	generic map (
		textLength => 16
	)
	port map(
		clk => Clock_Out,
		displayText => displayTextout1,
		position => (x2, 240),
		horzCoord => h,
		vertCoord => v,
		pixel => d2
	);
	
textElement3: entity work.Pixel_On_Text
	generic map (
		textLength => 25
	)
	port map(
		clk => Clock_Out,
		displayText => "The Encrypted Message is:",
		position => (x3, 180),
		horzCoord => h,
		vertCoord => v,
		pixel => d3
	);
	
textElement4: entity work.Pixel_On_Text
	generic map (
		textLength => 32
	)
	port map(
		clk => Clock_Out,
		displayText => displayTextout2,
		position => (x4, 200),
		horzCoord => h,
		vertCoord => v,
		pixel => d4
	);



----------------------------------------------------------------------------------------
-- Process 1
----------------------------------------------------------------------------------------
HL_Position : process (Clock_Out, reset, flagDoneConverting1, flagDoneConverting2)
begin
    if (flagDoneConverting1 = '1' and flagDoneConverting2 = '1') then
        if (reset = '1') then
            h <= 0;
        elsif (rising_edge(Clock_Out)) then
                if (h = 799) then
                    h <= 0;
                else
                    h <= h + 1;
                end if;
        end if;
    end if;         
end process;       

----------------------------------------------------------------------------------------
-- Process 2
----------------------------------------------------------------------------------------
VL_Position : process (Clock_Out, reset, h, flagDoneConverting1, flagDoneConverting2)
begin
    if (flagDoneConverting1 = '1' and flagDoneConverting2 = '1') then
        if (reset = '1') then
            v <= 0;
        elsif (rising_edge(Clock_Out)) then
                if (h = 799) then
                    if (v = 525) then
                       v <= 0;
			           x2 <= x2 + 1;
		               if (x2 = 640) then x2 <= -128; end if;
                    else
                        v <= v + 1;
                    end if;
                end if;
        end if; 
    end if;        
end process; 

----------------------------------------------------------------------------------------
-- Process 3
----------------------------------------------------------------------------------------
HL_Sync : process (Clock_Out, reset, h, flagDoneConverting1, flagDoneConverting2)
begin
    if (flagDoneConverting1 = '1' and flagDoneConverting2 = '1') then
        if (reset = '1') then
            Hsync <= '1';
        elsif (rising_edge(Clock_Out)) then
                if (h > 655 and h < 752) then
                    Hsync <= '0';
                else
                    Hsync <= '1';
                end if;
        end if; 
    end if;        
end process;

----------------------------------------------------------------------------------------
-- Process 4
----------------------------------------------------------------------------------------
VL_Sync : process (Clock_Out, reset, v, flagDoneConverting1, flagDoneConverting2)
begin
    if (flagDoneConverting1 = '1' and flagDoneConverting2 = '1') then
        if (reset = '1') then
            Vsync <= '1';
        elsif (rising_edge(Clock_Out)) then
                if (v > 489 and v < 492) then
                    Vsync <= '0';
                else
                    Vsync <= '1';
                end if;
        end if;
    end if;         
end process;

----------------------------------------------------------------------------------------
-- Process 5
----------------------------------------------------------------------------------------
Display : process (Clock_Out, reset, h, v, flagDoneConverting1, flagDoneConverting2)
begin
    if (flagDoneConverting1 = '1' and flagDoneConverting2 = '1') then
        if (reset = '1') then
            Video_Out <= '0';
        elsif (rising_edge(Clock_Out)) then
                if (v < 490 and h < 656) then
                    Video_Out <= '1';
                else
                    Video_Out <= '0';
                end if;
        end if; 
    end if;        
end process;

----------------------------------------------------------------------------------------
-- Process 6
----------------------------------------------------------------------------------------
process (Video_Out, flagDoneConverting1, flagDoneConverting2, flagDoneReceiving)
begin
if (flagDoneReceiving = '1') then
    if (flagDoneConverting1 = '1' and flagDoneConverting2 = '1') then
        if (Video_Out = '1') then
            if (d1 = '1') then
                vgaRed <= "1111";
                vgaBlue <= "0000";
                vgaGreen <= "0000"; 
            end if;
            if (d2 = '1') then
                vgaRed <= "1111";
                vgaBlue <= "1111";
                vgaGreen <= "1111"; 
            end if;
            if (d3 = '1') then
                vgaRed <= "1111";
                vgaBlue <= "0000";
                vgaGreen <= "0000"; 
            end if;
            if (d4 = '1') then
                vgaRed <= "1111";
                vgaBlue <= "1111";
                vgaGreen <= "1111"; 
            end if;
            if (d1 = '0' and d3 = '0' and d4 = '0' and d2 = '0') then
                vgaRed <= "0000";
                vgaBlue <= "0000";
                vgaGreen <= "0000"; 
            end if;
        end if;    
    else
        vgaRed <= "0000";
        vgaBlue <= "0000";
        vgaGreen <= "0000";
   end if;
else
        vgaRed <= "0000";
        vgaBlue <= "0000";
        vgaGreen <= "0000";
end if;
end process;    

   
end Behavioral;
