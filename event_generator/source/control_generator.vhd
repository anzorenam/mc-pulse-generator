library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_generator is
port(gclk,srst_done,init_done: in std_logic;
s_flag,valid_event,delay_done,dram_ack: in std_logic;
hit_pattern: in std_logic_vector (15 downto 0);
urnd0,urnd1,urnd2,urnd3: in unsigned (15 downto 0);
urnd4,urnd5,urnd6,urnd7: in unsigned (15 downto 0);
urnd8,urnd9,urnda,urndb: in unsigned (15 downto 0);
urndc,urndd,urnde,urndf: in unsigned (15 downto 0);
din_rand: out unsigned (19 downto 0);
busy,make_delay,rd_en: out std_logic;
generator_sel: out std_logic_vector (15 downto 0);
ctrl_rand: out std_logic_vector (3 downto 0));
end control_generator;

architecture x of control_generator is
signal w,mux_select,hit_preg0,hit_preg1: std_logic_vector (15 downto 0);

signal nhit_reg0,nhit_reg1,nhits: unsigned (5 downto 0);
type state is (s0,check_data,wait_event,gen_random0,gen_random1,gen_random2,gen_random3,gen_random4,gen_random5,gen_random6,gen_random7,gen_random8,wait_valid,wait_delay,done,u1);
signal presente,futuro: state;

type unsigned_array is array (0 to 16) of unsigned (5 downto 0);
signal nhits_aux: unsigned_array;

begin

process(gclk)
begin
  if rising_edge(gclk) then
    if srst_done='1' then
      presente<=s0;
    else
      presente<=futuro;
    end if;
  end if;
end process;

process(gclk)
begin
  if rising_edge(gclk) then
    if srst_done='1' then
      hit_preg0<=(others=>'0');
      nhit_reg0<=(others=>'0');
    else
      hit_preg0<=hit_preg1;
      nhit_reg0<=nhit_reg1;
    end if;
  end if;
end process;

process(presente,init_done,nhits,hit_pattern,s_flag,nhits,dram_ack,nhit_reg0,nhit_reg1,hit_preg0,hit_preg1,mux_select,valid_event,delay_done,w)
begin
  busy<='1';
  ctrl_rand<="0000";
  rd_en<='0';
  make_delay<='0';
  nhit_reg1<=nhit_reg0;
  hit_preg1<=hit_preg0;
  w<=(others=>'0');
  generator_sel<=(others=>'0');
  case presente is
    when s0=>
      busy<='0';
      ctrl_rand<="0001";
      if init_done='1' then
        futuro<=check_data;
      else
        futuro<=s0;
      end if;
    when check_data=>
      busy<='0';
      if s_flag='1' then
        futuro<=wait_event;
      else
        futuro<=check_data;
      end if;
    when wait_event=>
      busy<='0';
      if nhits/="00000" then
        futuro<=gen_random0;
      else
        futuro<=check_data;
      end if;
    when gen_random0=>
      hit_preg1<=hit_pattern;
      generator_sel<=hit_pattern;
      ctrl_rand<="0010";
      futuro<=gen_random1;
    when gen_random1=>
      generator_sel<=hit_pattern;
      ctrl_rand<="0011";
      futuro<=gen_random2;
    when gen_random2=>
      ctrl_rand<="0100";
      w<=mux_select xor hit_preg1;
      futuro<=gen_random3;
    when gen_random3=>
      hit_preg1<=w;
      if dram_ack='1' then
        futuro<=gen_random4;
      else
        futuro<=gen_random3;
      end if;
    when gen_random4=>
      rd_en<='1';
      futuro<=gen_random5;
    when gen_random5=>
      ctrl_rand<="0101";
      futuro<=gen_random6;
    when gen_random6=>
      nhit_reg1<=nhit_reg0+1;
      if nhit_reg1=nhits then
        futuro<=gen_random7;
      else
        futuro<=gen_random2;
      end if;
    when gen_random7=>
      generator_sel<=hit_pattern;
      ctrl_rand<="0110";
      futuro<=gen_random8;
    when gen_random8=>
      generator_sel<=hit_pattern;
      ctrl_rand<="0111";
      futuro<=wait_valid;
    when wait_valid=>
      busy<='0';
      if valid_event='1' then
        futuro<=wait_delay;
      else
        futuro<=wait_valid;
      end if;
    when wait_delay=>
      busy<='0';
      make_delay<='1';
      if delay_done='1' then
        futuro<=done;
      else
        futuro<=wait_delay;
      end if;
    when done=>
      busy<='0';
      ctrl_rand<="1000";
      futuro<=check_data;
    when others=>
      futuro<=s0;
  end case;
end process;

nhits_aux(0)<="00000";

gen: for j in 1 to 16 generate
  nhits_aux(j)<=nhits_aux(j-1)+1 when (hit_pattern(j-1)='1') else nhits_aux(j-1);
end generate;

nhits<=nhits_aux(16);

process(gclk)
begin
  if rising_edge(gclk) then
    if w(15)='1' then
      mux_select<="1000000000000000";
    elsif w(14)='1' then
      mux_select<="0100000000000000";
    elsif w(13)='1' then
      mux_select<="0010000000000000";
    elsif w(12)='1' then
      mux_select<="0001000000000000";
    elsif w(11)='1' then
      mux_select<="0000100000000000";
    elsif w(10)='1' then
      mux_select<="0000010000000000";
    elsif w(9)='1' then
      mux_select<="0000001000000000";
    elsif w(8)='1' then
      mux_select<="0000000100000000";
    elsif w(7)='1' then
      mux_select<="0000000010000000";
    elsif w(6)='1' then
      mux_select<="0000000001000000";
    elsif w(5)='1' then
      mux_select<="0000000000100000";
    elsif w(4)='1' then
      mux_select<="0000000000010000";
    elsif w(3)='1' then
      mux_select<="0000000000001000";
    elsif w(2)='1' then
      mux_select<="0000000000000100";
    elsif w(1)='1' then
      mux_select<="0000000000000010";
    elsif w(0)='1' then
      mux_select<="0000000000000001";
    else
      mux_select<="0000000000000000";
    end if;
  end if;
end process;

with mux_select select
  din_rand<="11110000000000000000"+urndf when "1000000000000000",
  "11100000000000000000"+urnde when "0100000000000000",
  "11010000000000000000"+urndd when "0010000000000000",
  "11000000000000000000"+urndc when "0001000000000000",
  "10110000000000000000"+urndb when "0000100000000000",
  "10100000000000000000"+urnda when "0000010000000000",
  "10010000000000000000"+urnd9 when "0000001000000000",
  "10000000000000000000"+urnd8 when "0000000100000000",
  "01110000000000000000"+urnd7 when "0000000010000000",
  "01100000000000000000"+urnd6 when "0000000001000000",
  "01010000000000000000"+urnd5 when "0000000000100000",
  "01000000000000000000"+urnd4 when "0000000000010000",
  "00110000000000000000"+urnd3 when "0000000000001000",
  "00100000000000000000"+urnd2 when "0000000000000100",
  "00010000000000000000"+urnd1 when "0000000000000010",
  "00000000000000000000"+urnd0 when "0000000000000001",
  (others=>'0') when others;

end x;
