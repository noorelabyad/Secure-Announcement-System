
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity Sub_Encryption is
Port ( data_in : in std_logic_vector(0 to 127);
           data_out : out std_logic_vector(0 to 127);
           key_number: in integer;
           flag_go:in std_logic;
           flag_done: out std_logic);
end Sub_Encryption;

architecture Behavioral of Sub_Encryption is


type TwoByteArray is array (0 to 255) of STD_LOGIC_vector (0 to 7);
type TwoByteArray2 is array (0 to 15) of STD_LOGIC_vector (0 to 7);
type TwoByteArray3 is array (0 to 3) of STD_LOGIC_vector (0 to 31);

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

constant look_up2 : TwoByteArray := (x"00",x"02",x"04",x"06",x"08",x"0a",x"0c",x"0e",x"10",x"12",x"14",x"16"
,x"18",x"1a",x"1c",x"1e",x"20",x"22",x"24",x"26",x"28",x"2a",x"2c",x"2e",x"30",x"32",x"34",x"36",x"38",
x"3a",x"3c",x"3e",x"40",x"42",x"44",x"46",x"48",x"4a",x"4c",x"4e",x"50",x"52",x"54",x"56",x"58",x"5a",
x"5c",x"5e",x"60",x"62",x"64",x"66",x"68",x"6a",x"6c",x"6e",x"70",x"72",x"74",x"76",x"78",x"7a",x"7c",
x"7e",x"80",x"82",x"84",x"86",x"88",x"8a",x"8c",x"8e",x"90",x"92",x"94",x"96",x"98",x"9a",x"9c",x"9e",
x"a0",x"a2",x"a4",x"a6",x"a8",x"aa",x"ac",x"ae",x"b0",x"b2",x"b4",x"b6",x"b8",x"ba",x"bc",x"be",x"c0",
x"c2",x"c4",x"c6",x"c8",x"ca",x"cc",x"ce",x"d0",x"d2",x"d4",x"d6",x"d8",x"da",x"dc",x"de",x"e0",x"e2",
x"e4",x"e6",x"e8",x"ea",x"ec",x"ee",x"f0",x"f2",x"f4",x"f6",x"f8",x"fa",x"fc",x"fe",x"1b",x"19",x"1f",
x"1d",x"13",x"11",x"17",x"15",x"0b",x"09",x"0f",x"0d",x"03",x"01",x"07",x"05",x"3b",x"39",x"3f",x"3d",
x"33",x"31",x"37",x"35",x"2b",x"29",x"2f",x"2d",x"23",x"21",x"27",x"25",x"5b",x"59",x"5f",x"5d",x"53",
x"51",x"57",x"55",x"4b",x"49",x"4f",x"4d",x"43",x"41",x"47",x"45",x"7b",x"79",x"7f",x"7d",x"73",x"71",
x"77",x"75",x"6b",x"69",x"6f",x"6d",x"63",x"61",x"67",x"65",x"9b",x"99",x"9f",x"9d",x"93",x"91",x"97",
x"95",x"8b",x"89",x"8f",x"8d",x"83",x"81",x"87",x"85",x"bb",x"b9",x"bf",x"bd",x"b3",x"b1",x"b7",x"b5",
x"ab",x"a9",x"af",x"ad",x"a3",x"a1",x"a7",x"a5",x"db",x"d9",x"df",x"dd",x"d3",x"d1",x"d7",x"d5",x"cb",
x"c9",x"cf",x"cd",x"c3",x"c1",x"c7",x"c5",x"fb",x"f9",x"ff",x"fd",x"f3",x"f1",x"f7",x"f5",x"eb",x"e9",
x"ef",x"ed",x"e3",x"e1",x"e7",x"e5");

constant look_up3 :TwoByteArray:=(x"00",x"03",x"06",x"05",x"0c",x"0f",x"0a",x"09",x"18",x"1b",x"1e",
x"1d",x"14",x"17",x"12",x"11",x"30",x"33",x"36",x"35",x"3c",x"3f",x"3a",x"39",x"28",x"2b",x"2e",x"2d",
x"24",x"27",x"22",x"21",x"60",x"63",x"66",x"65",x"6c",x"6f",x"6a",x"69",x"78",x"7b",x"7e",x"7d",x"74",
x"77",x"72",x"71",x"50",x"53",x"56",x"55",x"5c",x"5f",x"5a",x"59",x"48",x"4b",x"4e",x"4d",x"44",x"47",
x"42",x"41",x"c0",x"c3",x"c6",x"c5",x"cc",x"cf",x"ca",x"c9",x"d8",x"db",x"de",x"dd",x"d4",x"d7",x"d2",
x"d1",x"f0",x"f3",x"f6",x"f5",x"fc",x"ff",x"fa",x"f9",x"e8",x"eb",x"ee",x"ed",x"e4",x"e7",x"e2",x"e1",
x"a0",x"a3",x"a6",x"a5",x"ac",x"af",x"aa",x"a9",x"b8",x"bb",x"be",x"bd",x"b4",x"b7",x"b2",x"b1",x"90",
x"93",x"96",x"95",x"9c",x"9f",x"9a",x"99",x"88",x"8b",x"8e",x"8d",x"84",x"87",x"82",x"81",x"9b",x"98",
x"9d",x"9e",x"97",x"94",x"91",x"92",x"83",x"80",x"85",x"86",x"8f",x"8c",x"89",x"8a",x"ab",x"a8",x"ad",
x"ae",x"a7",x"a4",x"a1",x"a2",x"b3",x"b0",x"b5",x"b6",x"bf",x"bc",x"b9",x"ba",x"fb",x"f8",x"fd",x"fe",
x"f7",x"f4",x"f1",x"f2",x"e3",x"e0",x"e5",x"e6",x"ef",x"ec",x"e9",x"ea",x"cb",x"c8",x"cd",x"ce",x"c7",
x"c4",x"c1",x"c2",x"d3",x"d0",x"d5",x"d6",x"df",x"dc",x"d9",x"da",x"5b",x"58",x"5d",x"5e",x"57",x"54",
x"51",x"52",x"43",x"40",x"45",x"46",x"4f",x"4c",x"49",x"4a",x"6b",x"68",x"6d",x"6e",x"67",x"64",x"61",
x"62",x"73",x"70",x"75",x"76",x"7f",x"7c",x"79",x"7a",x"3b",x"38",x"3d",x"3e",x"37",x"34",x"31",x"32",
x"23",x"20",x"25",x"26",x"2f",x"2c",x"29",x"2a",x"0b",x"08",x"0d",x"0e",x"07",x"04",x"01",x"02",x"13",
x"10",x"15",x"16",x"1f",x"1c",x"19",x"1a");

type key is array (0 to 10) of STD_LOGIC_vector (0 to 127);

constant roundKey : key := (x"2b28ab097eaef7cf15d2154f16a6883c",x"a088232afa54a36cfe2c397617b13905",x"f27a5973c296355995b980f6f2437a7f",
x"3d471e6d8016237a47fe7e887d3e443b",x"efa8b6db4452710ba55b25ad417f3b00",x"d47cca11d183f2f9c69db815f887bcbc",x"6d11dbca880bf900a33e86937afd41fd"
,x"4e5f844e545fa6a6f7c94fdc0ef3b24f", x"eab5317fd28d2b8d73baf52921d2602f", x"ac19285777fad15c66dc2900f321416e",x"d0c9e1b614ee3f63f9250c0ca889c8a6");

---------7SEG-----------------------------------
signal reset,d0_done:std_logic:='0'; 

-------MIXCOLUMNS-------------------------------
constant data_in123 : std_logic_vector(0 to 127):=x"02030101010203010101020303010102";
signal col1,col2,col3,col4,row1,row2,row3,row4:std_logic_vector(0 to 31);
signal a:TwoByteArray2;
signal col,row:TwoByteArray3;
------------------------------------------------

procedure prepare_element (
                data : STD_LOGIC_vector (0 to 127);
                row,col : in STD_LOGIC_vector(0 to 31);
                col_no: in integer;
                look_up2,look_up3: in TwoByteArray;
                signal element: out std_logic_vector(0 to 7)) is
variable part_i,whole_i: std_logic_vector(0 to 7):=(others=>'0');                
begin   
    for i in 0 to 3 loop
        case row (8*i to 8*i+7) is
            when x"01"=> part_i:= data(8*(col_no+4*i) to 8*(col_no+4*i)+7);
            when x"02"=> part_i:= look_up2(16*to_integer(unsigned(data(8*(col_no+4*i) to 8*(col_no+4*i)+3)))
                    +to_integer(unsigned(data(8*(col_no+4*i)+4 to 8*(col_no+4*i)+7))));
            when x"03"=> part_i:= look_up3(16*to_integer(unsigned(data(8*(col_no+4*i) to 8*(col_no+4*i)+3)))
                    +to_integer(unsigned(data(8*(col_no+4*i)+4 to 8*(col_no+4*i)+7))));
            when others=>
        end case;
        whole_i:=whole_i xor part_i;
    end loop;
    element<=whole_i;    
end procedure;  
---------------------------------------------------------

begin                       

process
variable d0,d1,d2,d3: STD_LOGIC_vector (0 to 127);

begin
if flag_go = '1' then

    --XOR CIPHERKEY
    if key_number=1 then
        d0:=data_in xor roundKey(0);
    else
        d0:=data_in;
    end if;
    
    
    --SUBBYTES
    for i in 0 to 15 loop
        d1(8*i to 8*i+7):=SBOX(16*to_integer(unsigned(d0(8*i to 8*i+3)))
               +to_integer(unsigned(d0(8*i+4 to 8*i+7))));
    end loop;
    --SHIFTROWS
    d2:=d1(0 to 31)&d1(40 to 63)&d1(32 to 39)&d1(80 to 95)&
    d1(64 to 79)&d1(120 to 127)&d1(96 to 119);
    
    --MIXCOLOUMNS
    
    col1<=d2(0 to 7) & d2(32 to 39) & d2(64 to 71) & d2(96 to 103);
    col2<=d2(8 to 15) & d2(40 to 47) & d2(72 to 79) & d2(104 to 111);
    col3<=d2(16 to 23) & d2(48 to 55) & d2(80 to 87) & d2(112 to 119);
    col4<=d2(24 to 31) & d2(56 to 63) & d2(88 to 95) & d2(120 to 127);
    row1<=data_in123(0 to 31); row2<=data_in123(32 to 63);row3<=data_in123(64 to 95);row4<=data_in123(96 to 127);
    col<=(col1,col2,col3,col4);
    row<=(row1,row2,row3,row4);
    
    for j in 0 to 3 loop
        for i in 0 to 3 loop
            prepare_element(d2,row(j),col(i),i,look_up2,look_up3,a(i+4*j));
        end loop;
    end loop;
    d3:=a(0)&a(1)&a(2)&a(3)&a(4)&a(5)&a(6)&a(7)&a(8)&a(9)&a(10)&a(11)&a(12)&a(13)&a(14)&a(15);
    --ADD ROUNDKEY
    d0:=d3 xor roundKey(key_number);
    
    
    data_out<=d0;
    flag_done<= '1';

end if;
end process;

end Behavioral;
