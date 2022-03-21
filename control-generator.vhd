library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_generator is
port(gclk,grst: in std_logic;
make_event: in std_logic;
make_delay: out std_logic;
ctrl_rand: out std_logic_vector (2 downto 0));
end control_generator;

architecture x of control_generator is
type state is (clear_init,wait_event,gen_random0,gen_random1,gen_random2,gen_random3,wait_delay,done);
signal presente,futuro: state;

begin

process(gclk)
begin
  if rising_edge(gclk) then
    if grst='0' then
      presente<=clear_init;
    else
      presente<=futuro;
    end if;
  end if;
end process;

process(presente,make_event)
begin
  make_delay<='0';
  ctrl_rand<="000";
  case presente is
    when clear_init=>
      ctrl_rand<="001";
      futuro<=wait_event;
    when wait_event=>
      if make_event='1' then
        futuro<=gen_random0;
      else
        futuro<=wait_event;
      end if;
    when gen_random0=>
      ctrl_rand<="010";
      futuro<=gen_random1;
    when gen_random1=>
      futuro<=gen_random2;
    when gen_random2=>
      ctrl_rand<="011";
      futuro<=gen_random3;
    when gen_random3=>
      ctrl_rand<="100";
      futuro<=wait_delay;
    when wait_delay=>
      make_delay<='1';
      if make_event='1' then
        futuro<=wait_delay;
      elsif make_event='0' then
        futuro<=done;
      end if;
    when done=>
      ctrl_rand<="101";
      futuro<=wait_event;
    when others=>
      futuro<=wait_event;
  end case;
end process;

end x;
