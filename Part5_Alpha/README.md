# Part5 Alpha Guide

## Alpha-1: Leaky ReLU

**Type:** Software training + Hardware modification

**Description:** Implementation of Leaky ReLU activation function in hardware with corresponding software training. No change in how this section is ran.

**Key Hardware Modification:**
- `verilog/sfu.v` - Modified SFU module implementing Leaky ReLU instead of standard ReLU

---

## Alpha-2: Cosine Annealing Learning Rate Scheduler

**Type:** Software-only implementation

**Description:** Implementation of Cosine Annealing learning rate scheduler for improved training convergence. No change in how this section is ran.

---

## Alpha-3: Activation-Aware Pruning

**Type:** Software training + Hardware testbench

**Description:** Implementation of activation-aware pruning with hardware testbench for validation. No changes in how this section is ran.

**Key Hardware File:**
- `sim/core_tb.v` - Testbench with pruning-specific validation

---

## Alpha-4: Add Layers (Gradual Channel Squeeze)

**Type:** Software-only implementation

**Description:** Addition of gradual channel squeeze layers to avoid sudden channel reduction in the VGG16 quantized model. No changes in how this section is ran.

---

## Summary Table

| Alpha | Type | Hardware | Software | Key Feature |
|-------|------|----------|----------|-------------|
| Alpha-1 | Hardware + Software | (sfu.v) | (Leaky_ReLU.ipynb) | Leaky ReLU activation |
| Alpha-2 | Software-only | - | (Cosine_Annealing_LR_Scheduler.ipynb) | Cosine Annealing LR |
| Alpha-3 | Hardware + Software | (core_tb.v) | (Activation_Aware_Pruning.ipynb) | Activation-aware pruning |
| Alpha-4 | Software-only | - | (Add_Layers.ipynb) | Gradual channel squeeze |
