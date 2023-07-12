library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity Top_Encryption is
Port ( data_in : in std_logic_vector(0 to 127);
           data_out : out std_logic_vector(0 to 127);
           flag_go: in std_logic;
           flag_done: out std_logic);
-- Port (
--           clk : in STD_LOGIC;
--           an : out STD_LOGIC_vector(3 downto 0);
--           seg : out STD_LOGIC_vector(0 to 6);
--           flag_go: in std_logic;
--           flag_done: out std_logic);
end Top_Encryption;

architecture Behavioral of Top_Encryption is

component SEG7_TEST is                 -- to be commented
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           data : in STD_LOGIC_vector(0 to 127);
           go:in std_logic;
           an : out STD_LOGIC_vector(3 downto 0);
           seg : out STD_LOGIC_vector(0 to 6));
end component;

component Sub_Encryption is
Port ( data_in : in std_logic_vector(0 to 127);
           data_out : out std_logic_vector(0 to 127);
           key_number: in integer;
           flag_go:in std_logic;
           flag_done: out std_logic);
end component;

type TwoByteArray is array (0 to 255) of STD_LOGIC_vector (0 to 7);

constant SBOX : TwoByteArray := (
x"63",x"7c",x"77",x"7b",x"f2",x"6b",x"6f",x"c5",x"30",x"01",x"67",x"2b",x"fe",x"d7",x"ab",x"76",
x"ca",x"82",x"c9",x"7d",x"fa",x"59",x"47",x"f0",x"ad",x"d4",x"a2",x"af",x"9c",x"a4",x"72",x"c0",
x"b7",x"fd",x"93",x"26",x"36",x"3f",x"f7",x"cc",x"34",x"a5",x"e5",x"f1",x"71",x"d8",x"31",x"15",
x"04",x"c7",x"23",x"c3",x"18",x"96",x"05",x"9a",x"07",x"12",x"80",x"e2",x"eb",x"27",x"b2",x"75",
x"09",x"83",x"2c",x"1a",x"1b",x"6e",x"5a",x"a0",x"52",x"3b",x"d6",x"b3",x"29",x"e3",x"2f",x"84",
x"53",x"d1",x"00",x"ed",x"20",x"fc",x"b1",x"5b",x"6a",x"cb",x"be",x"39",x"4a",x"4c",x"58",x"cf",
x"d0",x"ef",x"aa",x"fb",x"43",x"4d",x"33",x"85",x"45",x"f9",x"02",x"7f",x"50",x"3c",x"9f",x"a8",
x"51",x"a3",x"40",x"8f",x"92",x"9d",x"38",x"f5",x"bc",x"b6",x"da",x"21",x"10",x"ff",x"f3",x"d2",
x"cd",x"0c",x"13",x"ec",x"5f",x"97",x"44",x"17",x"c4",x"a7",x"7e",x"3d",x"64",x"5d",x"19",x"73",
x"60",x"81",x"4f",x"dc",x"22",x"2a",x"90",x"88",x"46",x"ee",x"b8",x"14",x"de",x"5e",x"0b",x"db",
x"e0",x"32",x"3a",x"0a",x"49",x"06",x"24",x"5c",x"c2",x"d3",x"ac",x"62",x"91",x"95",x"e4",x"79",
x"e7",x"c8",x"37",x"6d",x"8d",x"d5",x"4e",x"a9",x"6c",x"56",x"f4",x"ea",x"65",x"7a",x"ae",x"08",
x"ba",x"78",x"25",x"2e",x"1c",x"a6",x"b4",x"c6",x"e8",x"dd",x"74",x"1f",x"4b",x"bd",x"8b",x"8a",
x"70",x"3e",x"b5",x"66",x"48",x"03",x"f6",x"0e",x"61",x"35",x"57",x"b9",x"86",x"c1",x"1d",x"9e",
x"e1",x"f8",x"98",x"11",x"69",x"d9",x"8e",x"94",x"9b",x"1e",x"87",x"e9",x"ce",x"55",x"28",x"df",
x"8c",x"a1",x"89",x"0d",x"bf",x"e6",x"42",x"68",x"41",x"99",x"2d",x"0f",x"b0",x"54",x"bb",x"16");

type key is array (0 to 10) of STD_LOGIC_vector (0 to 127);

constant roundKey : key := (x"2b28ab097eaef7cf15d2154f16a6883c",x"a088232afa54a36cfe2c397617b13905",x"f27a5973c296355995b980f6f2437a7f",
x"3d471e6d8016237a47fe7e887d3e443b",x"efa8b6db4452710ba55b25ad417f3b00",x"d47cca11d183f2f9c69db815f887bcbc",x"6d11dbca880bf900a33e86937afd41fd"
,x"4e5f844e545fa6a6f7c94fdc0ef3b24f", x"eab5317fd28d2b8d73baf52921d2602f", x"ac19285777fad15c66dc2900f321416e",x"d0c9e1b614ee3f63f9250c0ca889c8a6");

--signal data_in: std_logic_vector(0 to 127):=x"328831E0435A3137F6309807A88DA234"; --to be commented
--signal data_out:std_logic_vector(0 to 127);               --to be commented
--signal reset:std_logic:='0';                             --to be commented

type data_array is array (0 to 11) of std_logic_vector(0 to 127);
signal data_all : data_array:=(data_in,
(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),(others=>'0'),
(others=>'0'),(others=>'0'),(others=>'0'));
signal flag_array : std_logic_vector (0 to 11):= "000000000000"; 

procedure final_round(
                data_in : in STD_LOGIC_vector (0 to 127);
                SBOX: in TwoByteArray;
                roundKey: in key;
                signal flag_done: out std_logic;
                signal data_out  : out STD_LOGIC_vector (0 to 127)) is
variable d0,d1,d2:  STD_LOGIC_vector (0 to 127);
begin
    d0:=data_in;
    --SUBBYTES
    for i in 0 to 15 loop
        d1(8*i to 8*i+7):=SBOX(16*to_integer(unsigned(d0(8*i to 8*i+3)))
               +to_integer(unsigned(d0(8*i+4 to 8*i+7))));
    end loop;
    --SHIFTROWS
    d2:=d1(0 to 31)&d1(40 to 63)&d1(32 to 39)&d1(80 to 95)&
    d1(64 to 79)&d1(120 to 127)&d1(96 to 119);
    
    --ADD ROUNDKEY
    data_out<=d2 xor roundKey(10);
    flag_done<='1';

end procedure;   
begin

--seg7 : SEG7_TEST port map (clk,reset,data_out,flag_array(9),an,seg); --to be comented
Sub_Encryption_1 : Sub_Encryption port map (data_in,data_all(1),1,flag_go,flag_array(1));
gen_Sub_Encryption:for j in 1 to 8 generate
        Sub_Encryption_i : Sub_Encryption port map (data_all(j),data_all(j+1),j+1,flag_array(j),flag_array(j+1));
end generate;


process
begin
    if flag_array(9) = '1' then
        final_round(data_all(9),SBOX,roundkey,flag_done,data_out);
    end if;    
end process;
end Behavioral;