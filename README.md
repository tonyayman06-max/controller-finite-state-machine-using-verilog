# Verilog FSM Controller

A finite-state-machine controller for a simple 8-bit accumulator-based CPU, written in Verilog, along with a randomized testbench.

## Files

| File | Description |
|---|---|
| `controller.v` | The controller module: an 8-state FSM that sequences instruction fetch, operand fetch, ALU operation, and store/branch phases, plus a combinational instruction decoder and ALU. |
| `controller_tb.v` | Testbench that instantiates the controller, drives a clock, applies reset, and runs 10,000 cycles of randomized stimulus while monitoring all outputs. |

## Module: `controller`

### Parameters

| Parameter | Default | Description |
|---|---|---|
| `width` | 8 | Data width of `in_a`, `in_b`, and (width+1 bits) `alu_out` |
| `op_width` | 3 | Width of the opcode field |

### Ports

**Inputs**
- `clk`, `rst` — clock and synchronous reset
- `zero` — zero flag, used for the skip-if-zero instruction
- `opcode [op_width-1:0]` — instruction opcode
- `phase` — external phase value loaded into the state register when `rd_phase` is asserted
- `rd_phase` — when high, loads `cs` from `phase` instead of incrementing
- `in_a [width-1:0]`, `in_b [width-1:0]` — ALU operands

**Outputs**
- `sel`, `rd`, `ld_ir`, `halt`, `inc_pc`, `ld_ac`, `ld_pc`, `wr`, `data_e` — control signals for the surrounding datapath
- `alu_out [width:0]` — ALU result

### Instruction Set (decoded from `opcode`)

| Opcode | Mnemonic (inferred) | ALU Result | Flags |
|---|---|---|---|
| `000` | HLT | `in_a` | HLT=1 |
| `001` | SKZ | `in_a` | SKZ=1 |
| `010` | ADD | `in_a + in_b` | ALUOP=1 |
| `011` | AND | `in_a & in_b` | ALUOP=1 |
| `100` | XOR | `in_a ^ in_b` | ALUOP=1 |
| `101` | MOV/LD | `in_b` | ALUOP=1 |
| `110` | STO | `in_a` | STO=1 |
| `111` | JMP | `in_a` | JMP=1 |

### FSM States

The FSM cycles through 8 states, held in the `cs` register:

1. `INST_ADDR` (000) — present instruction address (`sel=1`)
2. `INST_FETCH` (001) — read instruction (`sel=1, rd=1`)
3. `INST_LOAD` (010) — latch instruction into IR (`ld_ir=1`)
4. `IDLE` (011) — idle/hold state
5. `OP_ADDR` (100) — present operand address (`sel=0`); asserts `halt` if `HLT`
6. `OP_FETCH` (101) — read operand if `ALUOP`
7. `ALU_OP` (110) — perform ALU op; conditionally increments PC (`SKZ && zero`), loads PC on `JMP`, asserts `data_e` on `STO`
8. `STORE` (111) — write back result; asserts `wr`/`ld_ac`/`data_e` depending on instruction type

State advances on every clock edge (`cs <= cs + 1`) unless:
- `rd_phase` is asserted, in which case `cs` is loaded directly from `phase` (used to jump into/resync a specific phase), or
- `rst` is asserted (and `rd_phase` is low), which resets `cs` to `INST_ADDR`.

> **Note:** The `default` case in the output-decode `case` statement assigns to `ns`, a signal that is otherwise unused in this module — this looks like a leftover/bug from an earlier design iteration and does not affect `cs` other than leaving outputs unassigned in unreachable states.

## Testbench: `controller_tb`

- Instantiates `controller` with `width=8`, `op_width=3`.
- Generates a free-running clock with a 10-time-unit period (`#5` half-period).
- Applies reset for 4 clock cycles at startup.
- Uses `$monitor` to continuously print all output signals.
- Runs `generate_stim`, which drives 10,000 iterations of randomized `in_a`, `in_b`, `opcode`, `phase`, `rd_phase`, and `zero`, holding each set of values for 10 clock cycles.
- Runs for an additional 30 cycles after stimulus completes, then calls `$finish`.
- Contains a commented-out `golden_model` task, apparently intended as a reference-model scaffold for self-checking (not currently implemented — the testbench is currently monitor-only, with no automated pass/fail checking).

## Running the Simulation

Using **Icarus Verilog**:

```bash
iverilog -o controller_sim controller.v controller_tb.v
vvp controller_sim
```

Using **ModelSim/QuestaSim**:

```bash
vlog controller.v controller_tb.v
vsim -c controller_tb -do "run -all"
```

Output is printed via `$monitor` for every signal change, showing the state of all control signals and `alu_out` over time.

## Known Limitations / Ideas for Improvement

- The testbench has no self-checking/scoreboard logic (the golden model is stubbed out and commented). Waveforms or `$monitor` output must currently be checked manually.
- The unused `ns` assignment in the `default` branch of the output-decode block should probably be removed or replaced with proper default output assignments to avoid inferred latches in synthesis.
- Consider adding assertions (e.g., SystemVerilog assertions) to check that outputs match expected values per state/opcode combination.
