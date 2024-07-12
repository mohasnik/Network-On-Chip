
# Network-on-Chip (NoC) Project

## Overview

This repository contains the RTL design and implementation of a 4x4 Network-on-Chip (NoC) with a mesh topology with a complete high-level SystemVerilog testing. The project is part of the Core-Based Embedded System Design course. It covers the detailed SystemVerilog design of each module, including buffer units, routing units, switch allocators, switches, routers, and nodes, along with high-level testing scenarios.

## Table of Contents

1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Modules Description](#modules-description)
   - [Buffer Unit](#buffer-unit)
   - [Routing Unit](#routing-unit)
   - [Switch Allocator](#switch-allocator)
   - [Switch](#switch)
   - [Router](#router)
   - [Node](#node)
4. [Testing and Simulation](#testing-and-simulation)
   - [Primitive Components Testing](#primitive-components-testing)
   - [Router Testing](#router-testing)
   - [Whole NOC Testing](#whole-noc-testing)
5. [Results](#results)
6. [Contributing](#contributing)
7. [License](#license)

## Introduction

This project implements a Network-on-Chip (NoC) with a mesh topology, designed to facilitate efficient data transfer across a chip. The design is modular, allowing for scalability and flexibility in various embedded system applications. The NoC is designed parametrically to create different sizes of networks, with the current implementation focusing on a 4x4 grid. Moreover, using SystemVerilog facilities, the entire NoC is tested in different scenarios.

## Project Structure

The project is organized into the following directories:

- `src/`: Contains the SystemVerilog source files for all modules.
- `include/`: Includes common definitions and utility files.
- `testbenches/`: Contains testbenches for individual modules and the entire system.
- `docs/`: Documentation and reports related to the project.

## Interfaces Description

The NoC project uses several key interfaces to facilitate communication between different modules. These interfaces are defined in `interfaces.sv` and are crucial for ensuring modularity and reusability of the code. Below are the descriptions of each interface:

### 1. ReqAckIO Interface

The `ReqAckIO` interface is designed to manage the request-acknowledge handshaking mechanism, which is essential for synchronous communication between modules. This interface is used in BufferUnit, Router, Switch, and Node modules.

### 2. ReqGntIO Interface

The `ReqGntIO` interface is used for managing request-grant handshaking, specifically between buffer units and the switch allocator.

### 3. FifoIO Interface

The `FifoIO` interface encapsulates the signals required for FIFO operations, including reading and writing data, as well as managing buffer status.


## Modules Description

### Buffer Unit

The Buffer Unit is a critical component that manages the reception, storage, and forwarding of data packets. It uses a FIFO for storing packets and handles the request-acknowledge handshaking mechanism.


**File:** `Buffer_Unit.sv`

### Routing Unit

The Routing Unit determines the output port for each packet based on its destination address using a combinational design. It employs an X-Y routing algorithm to decide the appropriate path for data packets.

**File:** `Routing_Unit.sv`

### Switch Allocator

The Switch Allocator resolves conflicts when multiple input channels request the same output channel. It uses a priority-based arbitration mechanism, prioritizing local, west, north, east, and south ports in that order.

**File:** `Switch_Allocator.sv`

### Switch

The Switch module connects input buffers to output ports based on the arbitration results from the Switch Allocator. It ensures that data packets are routed correctly across the network.

**File:** `Switch.sv`

### Router

The Router integrates buffer units, a routing unit, a switch allocator, and switches. It routes data packets between five ports (local, west, north, east, and south) based on their destination addresses.

**File:** `Router.sv`

### Node

The Node module is used for testing purposes. It injects packets into the network and receives packets from the local output channel of routers. Nodes simulate the behavior of local processing elements in a real system.

**File:** `Node.sv`

## Testing and Simulation

### Primitive Components Testing

Each component is tested independently to reduce the risk of errors in the complete system. Testbenches for individual modules are available in the `testbenches/primitive/` directory.

**Files:**
- `Buffer_TB.sv`
- `FIFO_TB.sv`
- `RoutingUnit_TB.sv`

### Router Testing

The functionality of the Router is verified using a comprehensive testbench that injects packets from different ports and checks the routing correctness. The testbench ensures that packets are routed to the correct output ports without conflicts.

**File:** `Router_TB.sv`

### Whole NOC Testing

A high-level simulation of the entire 4x4 NoC is performed using nodes that generate and receive packets. The simulation verifies the correct operation of the entire network and ensures that data is transferred efficiently across the chip.

To verify the functionality of the entire Network-On-Chip (NoC), a local node module, Node, is created. This module is responsible for sending and receiving packets during simulation. Nodes utilize an array of mailboxes for high-level communication, where each node has a unique mailbox corresponding to its index.

When a node generates a packet destined for a random destination node, it sends the packet details through its mailbox to the destination node. This ensures that the destination node is aware of the incoming packets during the test simulation. Upon arrival of a packet at a node, the node iterates over its mailbox queue to verify if the packet is expected. If the packet is not found in the mailbox, it indicates that the packet was routed incorrectly, which triggers an error.

Each node operates independently, sending and receiving packets, and synchronization is achieved through the high-level communication provided by the mailboxes. Additionally, the mailbox ensures a finite number of packets in-flight for each node, which is beneficial for debugging and testing purposes. The number of simultaneous in-flight packets can be modified by changing the size of the mailboxes in NOC_TB.sv.

This approach ensures that all nodes can communicate effectively, allowing for thorough testing of the NoC's functionality.


**File:** `NOC_TB.sv`

## Results

The project includes detailed logs of the simulation results, demonstrating the successful routing of packets across the NoC. The logs can be found in the `logs/` directory, with separate files for router and NOC simulations.

## Contributing

Contributions to this project are welcome. Please follow the standard GitHub workflow for submitting pull requests. Ensure that all new code includes appropriate testbenches and documentation.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
