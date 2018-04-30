library verilog;
use verilog.vl_types.all;
entity lc3_control is
    generic(
        FETCH0          : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi0, Hi0, Hi0);
        FETCH1          : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi0, Hi0, Hi1);
        FETCH2          : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi0, Hi1, Hi0);
        DECODE          : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi0, Hi1, Hi1);
        BRANCH0         : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi1, Hi0, Hi0);
        ADD0            : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi1, Hi0, Hi1);
        STORE0          : vl_logic_vector(0 to 4) := (Hi0, Hi0, Hi1, Hi1, Hi1);
        STORE1          : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi0, Hi0, Hi0);
        STORE2          : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi0, Hi0, Hi1);
        JSR0            : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi0, Hi1, Hi0);
        JSR1            : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi0, Hi1, Hi1);
        AND0            : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi1, Hi0, Hi0);
        NOT0            : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi1, Hi0, Hi1);
        JMP0            : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi1, Hi1, Hi0);
        LD0             : vl_logic_vector(0 to 4) := (Hi0, Hi1, Hi1, Hi1, Hi1);
        LD1             : vl_logic_vector(0 to 4) := (Hi1, Hi0, Hi0, Hi0, Hi0);
        LD2             : vl_logic_vector(0 to 4) := (Hi1, Hi0, Hi0, Hi0, Hi1);
        BR              : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi0);
        ADD             : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi0, Hi1);
        LD              : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi0);
        ST              : vl_logic_vector(0 to 3) := (Hi0, Hi0, Hi1, Hi1);
        JSR             : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi0);
        \AND\           : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi0, Hi1);
        LDR             : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi0);
        STR             : vl_logic_vector(0 to 3) := (Hi0, Hi1, Hi1, Hi1);
        RTI             : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi0);
        \NOT\           : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi0, Hi1);
        LDI             : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi0);
        STI             : vl_logic_vector(0 to 3) := (Hi1, Hi0, Hi1, Hi1);
        JMP             : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi0, Hi0);
        RES             : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi0, Hi1);
        LEA             : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi1, Hi0);
        TRAP            : vl_logic_vector(0 to 3) := (Hi1, Hi1, Hi1, Hi1)
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        IR              : in     vl_logic_vector(15 downto 0);
        N               : in     vl_logic;
        Z               : in     vl_logic;
        P               : in     vl_logic;
        aluControl      : out    vl_logic_vector(1 downto 0);
        enaALU          : out    vl_logic;
        SR1             : out    vl_logic_vector(2 downto 0);
        SR2             : out    vl_logic_vector(2 downto 0);
        DR              : out    vl_logic_vector(2 downto 0);
        regWE           : out    vl_logic;
        selPC           : out    vl_logic_vector(1 downto 0);
        enaMARM         : out    vl_logic;
        selMAR          : out    vl_logic;
        selEAB1         : out    vl_logic;
        selEAB2         : out    vl_logic_vector(1 downto 0);
        enaPC           : out    vl_logic;
        ldPC            : out    vl_logic;
        ldIR            : out    vl_logic;
        ldMAR           : out    vl_logic;
        ldMDR           : out    vl_logic;
        selMDR          : out    vl_logic;
        memWE           : out    vl_logic;
        flagWE          : out    vl_logic;
        enaMDR          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of FETCH0 : constant is 1;
    attribute mti_svvh_generic_type of FETCH1 : constant is 1;
    attribute mti_svvh_generic_type of FETCH2 : constant is 1;
    attribute mti_svvh_generic_type of DECODE : constant is 1;
    attribute mti_svvh_generic_type of BRANCH0 : constant is 1;
    attribute mti_svvh_generic_type of ADD0 : constant is 1;
    attribute mti_svvh_generic_type of STORE0 : constant is 1;
    attribute mti_svvh_generic_type of STORE1 : constant is 1;
    attribute mti_svvh_generic_type of STORE2 : constant is 1;
    attribute mti_svvh_generic_type of JSR0 : constant is 1;
    attribute mti_svvh_generic_type of JSR1 : constant is 1;
    attribute mti_svvh_generic_type of AND0 : constant is 1;
    attribute mti_svvh_generic_type of NOT0 : constant is 1;
    attribute mti_svvh_generic_type of JMP0 : constant is 1;
    attribute mti_svvh_generic_type of LD0 : constant is 1;
    attribute mti_svvh_generic_type of LD1 : constant is 1;
    attribute mti_svvh_generic_type of LD2 : constant is 1;
    attribute mti_svvh_generic_type of BR : constant is 1;
    attribute mti_svvh_generic_type of ADD : constant is 1;
    attribute mti_svvh_generic_type of LD : constant is 1;
    attribute mti_svvh_generic_type of ST : constant is 1;
    attribute mti_svvh_generic_type of JSR : constant is 1;
    attribute mti_svvh_generic_type of \AND\ : constant is 1;
    attribute mti_svvh_generic_type of LDR : constant is 1;
    attribute mti_svvh_generic_type of STR : constant is 1;
    attribute mti_svvh_generic_type of RTI : constant is 1;
    attribute mti_svvh_generic_type of \NOT\ : constant is 1;
    attribute mti_svvh_generic_type of LDI : constant is 1;
    attribute mti_svvh_generic_type of STI : constant is 1;
    attribute mti_svvh_generic_type of JMP : constant is 1;
    attribute mti_svvh_generic_type of RES : constant is 1;
    attribute mti_svvh_generic_type of LEA : constant is 1;
    attribute mti_svvh_generic_type of TRAP : constant is 1;
end lc3_control;
