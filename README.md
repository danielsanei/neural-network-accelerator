# ECE 284 Final Project: VGG16 Neural Network Accelerator

## Project Overview

This project implements a hardware accelerator for VGG16 neural network inference with quantization-aware training. The design progresses through multiple optimization stages, from a vanilla implementation to advanced SIMD operations and reconfigurable architectures, culminating in several alpha optimizations for improved performance and accuracy.

## Project Structure

### Part 1: Vanilla Implementation

**Core Components:**
- **Hardware:** Basic systolic array architecture with MAC (Multiply-Accumulate) units, FIFOs, and SRAM
- **Software:** VGG16 quantization-aware training with 8-bit precision
- **Synthesis:** FPGA implementation report

**Key Features:**
- 16x16 MAC array for parallel computation
- Basic ReLU activation function in SFU (Special Function Unit)
- L0 buffer and OFIFO for data management
- Hardware testbench validation

### Part 2: SIMD Optimization

**Core Components:**
- **Hardware:** Enhanced architecture supporting SIMD operations
- **Software:** 2-bit quantization-aware training for reduced memory footprint

**Key Features:**
- SIMD-style parallel processing
- Ultra-low precision (2-bit) quantization
- Improved throughput via parallel data processing
- Partial sum accumulation

### Part 3: Reconfigurable Architecture

**Core Components:**
- **Hardware:** Reconfigurable datapath with enhanced flexibility
- **Software:** 4-bit quantization for balanced accuracy/efficiency

**Key Features:**
- Dynamic reconfiguration capabilities
- Input FIFO (IFIFO) for improved data flow
- 4-bit quantization balancing precision and resource usage
- Flexible MAC array configuration

### Part 4: Poster & Documentation

Contains project poster and progress documentation illustrating the design methodology, results, and architectural decisions.

### Part 5: Alpha Optimizations

Four distinct optimization approaches building on the base architecture:

#### Alpha-1: Leaky ReLU
- **Type:** Hardware + Software
- **Description:** Replaces standard ReLU with Leaky ReLU to prevent dying neuron problem
- **Modified:** `sfu.v` hardware module

#### Alpha-2: Cosine Annealing Learning Rate Scheduler
- **Type:** Software-only
- **Description:** Implements cosine annealing LR scheduler for improved training convergence
- **Benefits:** Better model accuracy through adaptive learning rates

#### Alpha-3: Activation-Aware Pruning
- **Type:** Hardware + Software
- **Description:** Intelligent pruning based on activation patterns
- **Modified:** Enhanced testbench for pruning validation
- **Benefits:** Reduced computational complexity with minimal accuracy loss

#### Alpha-4: Gradual Channel Squeeze
- **Type:** Software-only
- **Description:** Adds intermediate layers to avoid sudden channel reduction
- **Benefits:** Smoother information flow through the network

### Part 6: Final Report

Comprehensive documentation of the entire project, including methodology, results, and analysis.

### Part 7: Progress Report

Interim progress documentation tracking development milestones.

## Hardware Architecture

### Core Components

- **MAC Tile:** Systolic array of multiply-accumulate units
- **MAC Array:** 16x16 array of MAC units for parallel computation
- **FIFOs:** Multi-level FIFO structures (depth-64) with various mux configurations
- **SRAM:** 32-bit wide, 2048-word deep memory
- **SFU:** Special Function Unit for activation functions
- **L0 Buffer:** Level-0 buffer for data staging
- **Core/Corelet:** Top-level integration modules

### Key Files

- `core.v` - Top-level accelerator module
- `mac_tile.v`, `mac_array.v`, `mac_row.v`, `mac.v` - MAC hierarchy
- `sfu.v` - Activation function unit
- `l0.v` - L0 buffer management
- `ofifo.v`, `ififo.v` - Output/Input FIFO controllers
- `sram_32b_w2048.v` - Memory module

## Software Components

### VGG16 Quantization-Aware Training

Each part includes:
- Jupyter notebooks for training (`VGG16_Quantization_Aware_Training.ipynb`)
- Custom quantized layers (`quant_layer.py`)
- Modified VGG16 architecture (`vgg_quant.py` variants)

### Quantization Levels

- **Part 1:** 8-bit quantization (baseline)
- **Part 2:** 2-bit quantization (ultra-low precision)
- **Part 3:** 4-bit quantization (balanced approach)

## Simulation & Testing

Each hardware implementation includes:
- **Testbench:** `core_tb.v` for functional verification
- **Datafiles:** Activation and weight data for testing
- **Filelist:** Verilog module compilation order
- **VCD Output:** Waveform files for debugging

## Running Simulations

Navigate to respective `hardware/sim/` directories and run:
```bash
vvp core_tb.out  # Run compiled simulation
```

## Technologies Used

- **HDL:** Verilog
- **ML Framework:** PyTorch (for quantization-aware training)
- **Simulation:** Icarus Verilog / VVP
- **Target:** FPGA implementation

## Project Highlights

✓ Progressive optimization strategy from baseline to advanced implementations  
✓ Multiple quantization schemes (8-bit, 4-bit, 2-bit)  
✓ SIMD and reconfigurable architecture exploration  
✓ Hardware-software co-design approach  
✓ Comprehensive testing and validation  
✓ Multiple alpha optimizations for improved performance

---

*ECE 284 - Hardware Accelerators for Machine Learning*