library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity single_generator is
generic(init_seed: natural:= 1;
bin_width: natural:= 10;
urnd_width: natural:= 14;
onehot_width: natural:= 1024);
port(p0,p1,p2,p3: in std_logic;
grst,make_event: in std_logic;
pulse_event: out std_logic);
end single_generator;

architecture x of single_generator is
signal make_delay: std_logic;
signal ctrl_rand: std_logic_vector(2 downto 0);
signal binary_aux: unsigned(bin_width-1 downto 0);
signal onehot_aux: std_logic_vector(onehot_width-1 downto 0);

component control_generator is
port(gclk,grst: in std_logic;
make_event: in std_logic;
make_delay: out std_logic;
ctrl_rand: out std_logic_vector(2 downto 0));
end component;

component density_generator is
generic(init_seed: natural;
bin_width: natural;
urnd_width: natural);
port(gclk: in std_logic;
ctrl_rand: in std_logic_vector(2 downto 0);
binary_random: out unsigned (bin_width-1 downto 0));
end component;

component bin_onehot is
generic(bin_width: natural;
onehot_width: natural);
port(gclk: std_logic;
ctrl_rand: std_logic_vector(2 downto 0);
binary: in unsigned(bin_width-1 downto 0);
onehot: out std_logic_vector (onehot_width-1 downto 0));
end component;

component pulse_delay is
generic(onehot_width: natural);
port (p0,p1,p2,p3: in std_logic;
make_delay: in std_logic;
ctrl_rand: in std_logic_vector (2 downto 0);
w_pattern: in std_logic_vector (onehot_width-1 downto 0);
pulse_out: out std_logic);
end component;

begin

control: control_generator
port map(gclk=>p0,
         grst=>grst,
         make_event=>make_event,
         make_delay=>make_delay,
         ctrl_rand=>ctrl_rand
);

rand: density_generator
generic map(init_seed=>init_seed,
bin_width=>bin_width,
urnd_width=>urnd_width)
port map(gclk=>p0,
         ctrl_rand=>ctrl_rand,
         binary_random=>binary_aux
);

deco: bin_onehot
generic map(bin_width=>bin_width,
onehot_width=>onehot_width)
port map(gclk=>p0,
         ctrl_rand=>ctrl_rand,
         binary=>binary_aux,
         onehot=>onehot_aux
);

delay: pulse_delay
generic map(onehot_width=>onehot_width)
port map(p0=>p0,
         p1=>p1,
         p2=>p2,
         p3=>p3,
         make_delay=>make_delay,
         ctrl_rand=>ctrl_rand,
         w_pattern=>onehot_aux,
         pulse_out=>pulse_event
);

end x;
