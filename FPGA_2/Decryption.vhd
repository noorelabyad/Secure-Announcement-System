----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2023 02:53:01 PM
-- Design Name: 
-- Module Name: Decryption - Behavioral
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

entity Decryption is
    Port ( data_in : in STD_LOGIC_vector (0 to 127);
           flagDoneReceiving : in STD_LOGIC;
           flagDoneDecryption : out STD_LOGIC;
           data_out : out STD_LOGIC_vector (0 to 127));
end Decryption;

architecture Behavioral of Decryption is
---------------------------------------------
-- Add Round Key
---------------------------------------------
type key is array (0 to 10) of STD_LOGIC_vector (0 to 127);

constant roundKey : key := (x"2b28ab097eaef7cf15d2154f16a6883c", x"a088232afa54a36cfe2c397617b13905", x"f27a5973c296355995b980f6f2437a7f",
x"3d471e6d8016237a47fe7e887d3e443b", x"efa8b6db4452710ba55b25ad417f3b00", x"d47cca11d183f2f9c69db815f887bcbc", x"6d11dbca880bf900a33e86937afd41fd"
,x"4e5f844e545fa6a6f7c94fdc0ef3b24f", x"eab5317fd28d2b8d73baf52921d2602f", x"ac19285777fad15c66dc2900f321416e", x"d0c9e1b614ee3f63f9250c0ca889c8a6");

---------------------------------------------
-- Inverse Mix Columns
---------------------------------------------
type lookupTable is array (0 to 255) of STD_LOGIC_vector (0 to 7);
type twoBytseArray is array (0 to 127) of STD_LOGIC_vector (0 to 7);

constant multiply_by_9 : lookupTable := (
x"00",x"09",x"12",x"1b",x"24",x"2d",x"36",x"3f",x"48",x"41",x"5a",x"53",x"6c",x"65",x"7e",x"77",
x"90",x"99",x"82",x"8b",x"b4",x"bd",x"a6",x"af",x"d8",x"d1",x"ca",x"c3",x"fc",x"f5",x"ee",x"e7",
x"3b",x"32",x"29",x"20",x"1f",x"16",x"0d",x"04",x"73",x"7a",x"61",x"68",x"57",x"5e",x"45",x"4c",
x"ab",x"a2",x"b9",x"b0",x"8f",x"86",x"9d",x"94",x"e3",x"ea",x"f1",x"f8",x"c7",x"ce",x"d5",x"dc",
x"76",x"7f",x"64",x"6d",x"52",x"5b",x"40",x"49",x"3e",x"37",x"2c",x"25",x"1a",x"13",x"08",x"01",
x"e6",x"ef",x"f4",x"fd",x"c2",x"cb",x"d0",x"d9",x"ae",x"a7",x"bc",x"b5",x"8a",x"83",x"98",x"91",
x"4d",x"44",x"5f",x"56",x"69",x"60",x"7b",x"72",x"05",x"0c",x"17",x"1e",x"21",x"28",x"33",x"3a",
x"dd",x"d4",x"cf",x"c6",x"f9",x"f0",x"eb",x"e2",x"95",x"9c",x"87",x"8e",x"b1",x"b8",x"a3",x"aa",	
x"ec",x"e5",x"fe",x"f7",x"c8",x"c1",x"da",x"d3",x"a4",x"ad",x"b6",x"bf",x"80",x"89",x"92",x"9b",	
x"7c",x"75",x"6e",x"67",x"58",x"51",x"4a",x"43",x"34",x"3d",x"26",x"2f",x"10",x"19",x"02",x"0b",
x"d7",x"de",x"c5",x"cc",x"f3",x"fa",x"e1",x"e8",x"9f",x"96",x"8d",x"84",x"bb",x"b2",x"a9",x"a0",
x"47",x"4e",x"55",x"5c",x"63",x"6a",x"71",x"78",x"0f",x"06",x"1d",x"14",x"2b",x"22",x"39",x"30",
x"9a",x"93",x"88",x"81",x"be",x"b7",x"ac",x"a5",x"d2",x"db",x"c0",x"c9",x"f6",x"ff",x"e4",x"ed",
x"0a",x"03",x"18",x"11",x"2e",x"27",x"3c",x"35",x"42",x"4b",x"50",x"59",x"66",x"6f",x"74",x"7d",	
x"a1",x"a8",x"b3",x"ba",x"85",x"8c",x"97",x"9e",x"e9",x"e0",x"fb",x"f2",x"cd",x"c4",x"df",x"d6",
x"31",x"38",x"23",x"2a",x"15",x"1c",x"07",x"0e",x"79",x"70",x"6b",x"62",x"5d",x"54",x"4f",x"46");


constant multiply_by_B : lookupTable := (
x"00",x"0b",x"16",x"1d",x"2c",x"27",x"3a",x"31",x"58",x"53",x"4e",x"45",x"74",x"7f",x"62",x"69",
x"b0",x"bb",x"a6",x"ad",x"9c",x"97",x"8a",x"81",x"e8",x"e3",x"fe",x"f5",x"c4",x"cf",x"d2",x"d9",
x"7b",x"70",x"6d",x"66",x"57",x"5c",x"41",x"4a",x"23",x"28",x"35",x"3e",x"0f",x"04",x"19",x"12",
x"cb",x"c0",x"dd",x"d6",x"e7",x"ec",x"f1",x"fa",x"93",x"98",x"85",x"8e",x"bf",x"b4",x"a9",x"a2",
x"f6",x"fd",x"e0",x"eb",x"da",x"d1",x"cc",x"c7",x"ae",x"a5",x"b8",x"b3",x"82",x"89",x"94",x"9f",
x"46",x"4d",x"50",x"5b",x"6a",x"61",x"7c",x"77",x"1e",x"15",x"08",x"03",x"32",x"39",x"24",x"2f",
x"8d",x"86",x"9b",x"90",x"a1",x"aa",x"b7",x"bc",x"d5",x"de",x"c3",x"c8",x"f9",x"f2",x"ef",x"e4",
x"3d",x"36",x"2b",x"20",x"11",x"1a",x"07",x"0c",x"65",x"6e",x"73",x"78",x"49",x"42",x"5f",x"54",
x"f7",x"fc",x"e1",x"ea",x"db",x"d0",x"cd",x"c6",x"af",x"a4",x"b9",x"b2",x"83",x"88",x"95",x"9e",
x"47",x"4c",x"51",x"5a",x"6b",x"60",x"7d",x"76",x"1f",x"14",x"09",x"02",x"33",x"38",x"25",x"2e",
x"8c",x"87",x"9a",x"91",x"a0",x"ab",x"b6",x"bd",x"d4",x"df",x"c2",x"c9",x"f8",x"f3",x"ee",x"e5",
x"3c",x"37",x"2a",x"21",x"10",x"1b",x"06",x"0d",x"64",x"6f",x"72",x"79",x"48",x"43",x"5e",x"55",
x"01",x"0a",x"17",x"1c",x"2d",x"26",x"3b",x"30",x"59",x"52",x"4f",x"44",x"75",x"7e",x"63",x"68",
x"b1",x"ba",x"a7",x"ac",x"9d",x"96",x"8b",x"80",x"e9",x"e2",x"ff",x"f4",x"c5",x"ce",x"d3",x"d8",
x"7a",x"71",x"6c",x"67",x"56",x"5d",x"40",x"4b",x"22",x"29",x"34",x"3f",x"0e",x"05",x"18",x"13",
x"ca",x"c1",x"dc",x"d7",x"e6",x"ed",x"f0",x"fb",x"92",x"99",x"84",x"8f",x"be",x"b5",x"a8",x"a3");

constant multiply_by_D : lookupTable := (
x"00",x"0d",x"1a",x"17",x"34",x"39",x"2e",x"23",x"68",x"65",x"72",x"7f",x"5c",x"51",x"46",x"4b",
x"d0",x"dd",x"ca",x"c7",x"e4",x"e9",x"fe",x"f3",x"b8",x"b5",x"a2",x"af",x"8c",x"81",x"96",x"9b",
x"bb",x"b6",x"a1",x"ac",x"8f",x"82",x"95",x"98",x"d3",x"de",x"c9",x"c4",x"e7",x"ea",x"fd",x"f0",
x"6b",x"66",x"71",x"7c",x"5f",x"52",x"45",x"48",x"03",x"0e",x"19",x"14",x"37",x"3a",x"2d",x"20",
x"6d",x"60",x"77",x"7a",x"59",x"54",x"43",x"4e",x"05",x"08",x"1f",x"12",x"31",x"3c",x"2b",x"26",
x"bd",x"b0",x"a7",x"aa",x"89",x"84",x"93",x"9e",x"d5",x"d8",x"cf",x"c2",x"e1",x"ec",x"fb",x"f6",
x"d6",x"db",x"cc",x"c1",x"e2",x"ef",x"f8",x"f5",x"be",x"b3",x"a4",x"a9",x"8a",x"87",x"90",x"9d",
x"06",x"0b",x"1c",x"11",x"32",x"3f",x"28",x"25",x"6e",x"63",x"74",x"79",x"5a",x"57",x"40",x"4d",
x"da",x"d7",x"c0",x"cd",x"ee",x"e3",x"f4",x"f9",x"b2",x"bf",x"a8",x"a5",x"86",x"8b",x"9c",x"91",
x"0a",x"07",x"10",x"1d",x"3e",x"33",x"24",x"29",x"62",x"6f",x"78",x"75",x"56",x"5b",x"4c",x"41",
x"61",x"6c",x"7b",x"76",x"55",x"58",x"4f",x"42",x"09",x"04",x"13",x"1e",x"3d",x"30",x"27",x"2a",
x"b1",x"bc",x"ab",x"a6",x"85",x"88",x"9f",x"92",x"d9",x"d4",x"c3",x"ce",x"ed",x"e0",x"f7",x"fa",
x"b7",x"ba",x"ad",x"a0",x"83",x"8e",x"99",x"94",x"df",x"d2",x"c5",x"c8",x"eb",x"e6",x"f1",x"fc",
x"67",x"6a",x"7d",x"70",x"53",x"5e",x"49",x"44",x"0f",x"02",x"15",x"18",x"3b",x"36",x"21",x"2c",
x"0c",x"01",x"16",x"1b",x"38",x"35",x"22",x"2f",x"64",x"69",x"7e",x"73",x"50",x"5d",x"4a",x"47",
x"dc",x"d1",x"c6",x"cb",x"e8",x"e5",x"f2",x"ff",x"b4",x"b9",x"ae",x"a3",x"80",x"8d",x"9a",x"97");

constant multiply_by_E : lookupTable := (
x"00",x"0e",x"1c",x"12",x"38",x"36",x"24",x"2a",x"70",x"7e",x"6c",x"62",x"48",x"46",x"54",x"5a",
x"e0",x"ee",x"fc",x"f2",x"d8",x"d6",x"c4",x"ca",x"90",x"9e",x"8c",x"82",x"a8",x"a6",x"b4",x"ba",
x"db",x"d5",x"c7",x"c9",x"e3",x"ed",x"ff",x"f1",x"ab",x"a5",x"b7",x"b9",x"93",x"9d",x"8f",x"81",
x"3b",x"35",x"27",x"29",x"03",x"0d",x"1f",x"11",x"4b",x"45",x"57",x"59",x"73",x"7d",x"6f",x"61",
x"ad",x"a3",x"b1",x"bf",x"95",x"9b",x"89",x"87",x"dd",x"d3",x"c1",x"cf",x"e5",x"eb",x"f9",x"f7",
x"4d",x"43",x"51",x"5f",x"75",x"7b",x"69",x"67",x"3d",x"33",x"21",x"2f",x"05",x"0b",x"19",x"17",
x"76",x"78",x"6a",x"64",x"4e",x"40",x"52",x"5c",x"06",x"08",x"1a",x"14",x"3e",x"30",x"22",x"2c",
x"96",x"98",x"8a",x"84",x"ae",x"a0",x"b2",x"bc",x"e6",x"e8",x"fa",x"f4",x"de",x"d0",x"c2",x"cc",
x"41",x"4f",x"5d",x"53",x"79",x"77",x"65",x"6b",x"31",x"3f",x"2d",x"23",x"09",x"07",x"15",x"1b",
x"a1",x"af",x"bd",x"b3",x"99",x"97",x"85",x"8b",x"d1",x"df",x"cd",x"c3",x"e9",x"e7",x"f5",x"fb",
x"9a",x"94",x"86",x"88",x"a2",x"ac",x"be",x"b0",x"ea",x"e4",x"f6",x"f8",x"d2",x"dc",x"ce",x"c0",
x"7a",x"74",x"66",x"68",x"42",x"4c",x"5e",x"50",x"0a",x"04",x"16",x"18",x"32",x"3c",x"2e",x"20",
x"ec",x"e2",x"f0",x"fe",x"d4",x"da",x"c8",x"c6",x"9c",x"92",x"80",x"8e",x"a4",x"aa",x"b8",x"b6",
x"0c",x"02",x"10",x"1e",x"34",x"3a",x"28",x"26",x"7c",x"72",x"60",x"6e",x"44",x"4a",x"58",x"56",
x"37",x"39",x"2b",x"25",x"0f",x"01",x"13",x"1d",x"47",x"49",x"5b",x"55",x"7f",x"71",x"63",x"6d",
x"d7",x"d9",x"cb",x"c5",x"ef",x"e1",x"f3",x"fd",x"a7",x"a9",x"bb",x"b5",x"9f",x"91",x"83",x"8d");

constant matrix : std_logic_vector (0 to 127) := x"0e0b0d09090e0b0d0d090e0b0b0d090e";

---------------------------------------------
-- Inverse SubBytes
---------------------------------------------
type TwoByteArraySB is array (0 to 255) of STD_LOGIC_vector (0 to 7);

constant inverseSBox : TwoByteArraySB := (
x"52",x"09",x"6a",x"d5",x"30",x"36",x"a5",x"38",x"bf",x"40",x"a3",x"9e",x"81",x"f3",x"d7",x"fb",
x"7c",x"e3",x"39",x"82",x"9b",x"2f",x"ff",x"87",x"34",x"8e",x"43",x"44",x"c4",x"de",x"e9",x"cb",
x"54",x"7b",x"94",x"32",x"a6",x"c2",x"23",x"3d",x"ee",x"4c",x"95",x"0b",x"42",x"fa",x"c3",x"4e",
x"08",x"2e",x"a1",x"66",x"28",x"d9",x"24",x"b2",x"76",x"5b",x"a2",x"49",x"6d",x"8b",x"d1",x"25",
x"72",x"f8",x"f6",x"64",x"86",x"68",x"98",x"16",x"d4",x"a4",x"5c",x"cc",x"5d",x"65",x"b6",x"92",
x"6c",x"70",x"48",x"50",x"fd",x"ed",x"b9",x"da",x"5e",x"15",x"46",x"57",x"a7",x"8d",x"9d",x"84",
x"90",x"d8",x"ab",x"00",x"8c",x"bc",x"d3",x"0a",x"f7",x"e4",x"58",x"05",x"b8",x"b3",x"45",x"06",
x"d0",x"2c",x"1e",x"8f",x"ca",x"3f",x"0f",x"02",x"c1",x"af",x"bd",x"03",x"01",x"13",x"8a",x"6b",
x"3a",x"91",x"11",x"41",x"4f",x"67",x"dc",x"ea",x"97",x"f2",x"cf",x"ce",x"f0",x"b4",x"e6",x"73",
x"96",x"ac",x"74",x"22",x"e7",x"ad",x"35",x"85",x"e2",x"f9",x"37",x"e8",x"1c",x"75",x"df",x"6e",
x"47",x"f1",x"1a",x"71",x"1d",x"29",x"c5",x"89",x"6f",x"b7",x"62",x"0e",x"aa",x"18",x"be",x"1b",
x"fc",x"56",x"3e",x"4b",x"c6",x"d2",x"79",x"20",x"9a",x"db",x"c0",x"fe",x"78",x"cd",x"5a",x"f4",
x"1f",x"dd",x"a8",x"33",x"88",x"07",x"c7",x"31",x"b1",x"12",x"10",x"59",x"27",x"80",x"ec",x"5f",
x"60",x"51",x"7f",x"a9",x"19",x"b5",x"4a",x"0d",x"2d",x"e5",x"7a",x"9f",x"93",x"c9",x"9c",x"ef",
x"a0",x"e0",x"3b",x"4d",x"ae",x"2a",x"f5",x"b0",x"c8",x"eb",x"bb",x"3c",x"83",x"53",x"99",x"61",
x"17",x"2b",x"04",x"7e",x"ba",x"77",x"d6",x"26",x"e1",x"69",x"14",x"63",x"55",x"21",x"0c",x"7d");


---------------------------------------------
-- General
---------------------------------------------
signal finished : std_logic_vector (0 to 127);
signal flagFinished : std_logic;


procedure ISR (
    variable dataIn : in STD_LOGIC_vector (0 to 127);
    variable row_1_SR, row_2_SR, row_3_SR, row_4_SR : inout STD_LOGIC_vector (0 to 31);
    variable dataOut : out STD_LOGIC_vector (0 to 127)) is
    begin   
    row_1_SR := dataIn (0 to 31);
    row_2_SR := dataIn (32 to 63);
    row_3_SR := dataIn (64 to 95);
    row_4_SR := dataIn (96 to 127);   
    dataOut := row_1_SR &
                row_2_SR (24 to 31)& row_2_SR (0 to 23) & 
                row_3_SR (16 to 31) & row_3_SR (0 to 15) &
                row_4_SR (8 to 31) & row_4_SR (0 to 7);
end procedure;

procedure ISB (
    variable dataIn : in STD_LOGIC_vector (0 to 127);
    variable twoBytes : inout std_logic_vector (0 to 7);
    variable rowSB, columnSB : inout integer range 0 to 16;
    variable dataOut : out STD_LOGIC_vector (0 to 127)) is
    begin   
        for i in 0 to 15 loop
        twoBytes := dataIn(8*i to 8*i+7);
        rowSB := to_integer(unsigned(twoBytes(0 to 3)));
        columnSB := to_integer(unsigned(twoBytes(4 to 7)));
        dataOut(8*i to 8*i+7) := inverseSBox(16*rowSB + columnSB);
    end loop;
end procedure;

procedure IMC (
variable dataIn : in STD_LOGIC_vector (0 to 127);
variable value1, value2, value3, value4 : inout std_logic_vector (0 to 7);
variable dataClmn, matrixRow : inout std_logic_vector (0 to 31);
variable data2Bytes, matrix2Bytes : inout std_logic_vector (0 to 7);
variable rowIMC, columnIMC : inout integer range 0 to 16;
variable dataOut : out STD_LOGIC_vector (0 to 127)) is
begin
for k in 0 to 3 loop
            matrixRow := matrix (32*k to 32*k+31);       
            for j in 0 to 3 loop
                dataClmn := dataIn (8*j to 8*j+7) & dataIn (8*j+32 to 8*j+39) &
                            dataIn (8*j+64 to 8*j+71) & dataIn (8*j+96 to 8*j+103);
                
                data2Bytes := dataClmn(0 to 7);
                matrix2Bytes := matrixRow(0 to 7);
                rowIMC := to_integer(unsigned(data2Bytes(0 to 3)));
                columnIMC := to_integer(unsigned(data2Bytes(4 to 7))); 
                case matrix2Bytes is
                    when x"09" => value1 := multiply_by_9 (16*rowIMC+columnIMC);
                    when x"0b" => value1 := multiply_by_B (16*rowIMC+columnIMC);
                    when x"0d" => value1 := multiply_by_D (16*rowIMC+columnIMC);
                    when x"0e" => value1 := multiply_by_E (16*rowIMC+columnIMC);
                   when others => value1 := x"00";
                end case;
                
                data2Bytes := dataClmn(8 to 15);
                matrix2Bytes := matrixRow(8 to 15);
                rowIMC := to_integer(unsigned(data2Bytes(0 to 3)));
                columnIMC := to_integer(unsigned(data2Bytes(4 to 7)));
                case matrix2Bytes is
                    when x"09" => value2 := multiply_by_9 (16*rowIMC+columnIMC);
                    when x"0b" => value2 := multiply_by_B (16*rowIMC+columnIMC);
                    when x"0d" => value2 := multiply_by_D (16*rowIMC+columnIMC);
                    when x"0e" => value2 := multiply_by_E (16*rowIMC+columnIMC);
                    when others => value2 := x"00";
                end case;
                
                data2Bytes := dataClmn(16 to 23);
                matrix2Bytes := matrixRow(16 to 23);
                rowIMC := to_integer(unsigned(data2Bytes(0 to 3)));
                columnIMC := to_integer(unsigned(data2Bytes(4 to 7)));
                case matrix2Bytes is
                    when x"09" => value3 := multiply_by_9 (16*rowIMC+columnIMC);
                    when x"0b" => value3 := multiply_by_B (16*rowIMC+columnIMC);
                    when x"0d" => value3 := multiply_by_D (16*rowIMC+columnIMC);
                    when x"0e" => value3 := multiply_by_E (16*rowIMC+columnIMC);
                    when others => value3 := x"00";
                end case;
                
                data2Bytes := dataClmn(24 to 31);
                matrix2Bytes := matrixRow(24 to 31);
                rowIMC := to_integer(unsigned(data2Bytes(0 to 3)));
                columnIMC := to_integer(unsigned(data2Bytes(4 to 7))); 
                case matrix2Bytes is
                    when x"09" => value4 := multiply_by_9 (16*rowIMC+columnIMC);
                    when x"0b" => value4 := multiply_by_B (16*rowIMC+columnIMC);
                    when x"0d" => value4 := multiply_by_D (16*rowIMC+columnIMC);
                    when x"0e" => value4 := multiply_by_E (16*rowIMC+columnIMC);
                    when others => value4 := x"00";
                end case;
                dataOut (8*j+32*k to 8*j+7+32*k) := value1 xor value2 xor value3 xor value4;
                end loop;
                
            end loop;
end procedure;


begin

process
    variable finalResult, dataIMC, dataISR, dataRK, dataSB : STD_LOGIC_vector (0 to 127);
    variable row_1_SR, row_2_SR, row_3_SR, row_4_SR : STD_LOGIC_VECTOR (0 to 31);
    variable value1, value2, value3, value4 : std_logic_vector (0 to 7);
    variable dataClmn, matrixRow : std_logic_vector (0 to 31);
    variable data2Bytes, matrix2Bytes : std_logic_vector (0 to 7);
    variable result : std_logic_vector (0 to 31);
    variable rowIMC, columnIMC : integer range 0 to 16;
    variable c : integer range 0 to 16 := 0;
    variable twoBytes : std_logic_vector (0 to 7);
    variable rowSB, columnSB : integer range 0 to 16;
    variable stepOne : STD_LOGIC := '1';
    variable firstProcessDone : STD_LOGIC := '0';
    variable secondProcessDone : STD_LOGIC := '0';
begin
if flagDoneReceiving = '1' then
    if (stepOne = '1') then
        dataRK := data_in xor roundKey (10);
        ---------------------------------------------
        -- Inverse Shift Rows
        ---------------------------------------------
        ISR(dataRK, row_1_SR, row_2_SR, row_3_SR, row_4_SR, dataISR);
        ---------------------------------------------
        -- Inverse SubBytes
        --------------------------------------------- 
        ISB(dataISR, twoBytes, rowSB, columnSB, dataSB);     
        firstProcessDone := '1';
    end if;

    if (firstProcessDone = '1') then
        for i in 1 to 9 loop
            ---------------------------------------------
            -- Add Round Key
            ---------------------------------------------
            dataRK := dataSB xor roundKey(10-i);
            ---------------------------------------------
            -- Inverse Mix Columns
            ---------------------------------------------
            IMC(dataRK, value1, value2, value3, value4, dataClmn, matrixRow, 
                data2Bytes, matrix2Bytes, rowIMC, columnIMC, dataIMC);
            ---------------------------------------------
            -- Inverse Shift Rows
            ---------------------------------------------
            ISR(dataIMC, row_1_SR, row_2_SR, row_3_SR, row_4_SR, dataISR);
            ---------------------------------------------
            -- Inverse SubBytes
            --------------------------------------------- 
            ISB(dataISR, twoBytes, rowSB, columnSB, dataSB); 
        end loop;   
        data_out <= dataSB xor roundKey(0);
        flagDoneDecryption <= '1'; 
        wait;
    end if;

end if;    
end process;


end Behavioral;
