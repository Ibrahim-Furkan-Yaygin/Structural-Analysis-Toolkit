# Structural Analysis Toolkit

A MATLAB-based finite element analysis toolkit for structural analysis.

The project is developed as a collection of independent modules, with each module focusing on a different type of structural analysis. The main goal of the toolkit is to implement finite element methods from scratch while keeping the analysis workflow clear, modular, and easy to verify.

## Modules

### Module 1 — 2D Truss Solver

A finite element solver for two-dimensional truss structures.

The module includes CAD-based geometry import, automatic node and element processing, global stiffness matrix assembly, boundary condition and load definition, structural solution, and post-processing.

[View Module 1 →](Module_1_Truss_Solver/)

### Module 2 — 2D Beam/Frame Solver

A finite element solver for two-dimensional beam and frame structures.

This module also supports CAD-based geometry import, beam geometry processing 
(including cross-section properties), meshing, finite element stiffness matrix assembly, 
boundary condition and load definition, structural solution, and post-processing.

[View Module 2 →](Module_2_Beam_Frame_Solver/)

---

## Project Structure

The toolkit is organized into separate modules so that each solver can be developed, tested, and documented independently.

```text
Structural-Analysis-Toolkit/
│
├── Module_1_Truss_Solver/
│   ├── README.md
│   ├── src/
│   └── Examples_and_Validation/
│
├── Module_2_Beam_Frame_Solver/
│   ├── README.md
│   ├── src/
│   └── Examples_and_Validation/
│
├── Documentation/
│   ├── Module_1_Truss_Solver/
│   │   └── Implementation.md
│   │
│   └── Module_2_Beam_Frame_Solver/
│       └── Implementation.md
│
└── LICENSE
```

## General Analysis Workflow

Although each module has its own formulation and implementation, the toolkit follows a general finite element analysis workflow:

```text
CAD Geometry
   ↓
Geometry / Model Processing
   ↓
Meshing
   ↓
Element Formulation
   ↓
Global Stiffness Matrix
   ↓
Boundary Conditions + Loads
   ↓
FE Solution
   ↓
Post-Processing
   ↓
Results
```

The modules also include visualization and verification steps to help check the model before interpreting the numerical results.

## Development Approach

The toolkit is developed with a focus on:

- Implementing finite element formulations directly in MATLAB
- Keeping each solver as an independent module
- Using CAD geometry as an input
- Providing visual checks during the analysis process
- Comparing selected results with established FEA software for validation
- Expanding the toolkit gradually through independent modules

## Planned Development

Future development may include:

- 2D plane stress analysis
- Composite laminate analysis
- 3D truss analysis
- Additional CAD geometry import capabilities
- Additional finite element formulations
- Expanded validation cases

## Requirements

- MATLAB
- A compatible CAD software that is able to export drawings in .DXF format

Specific requirements and instructions for each solver are provided in their respective module directories.

## Documentation

Implementation details are provided separately for each module.

- [Module 1 — Truss Solver Documentation](Documentation/Module_1_Truss_Solver/Implementation.md)
- [Module 2 — Beam/Frame Solver Documentation](Documentation/Module_2_Beam_Frame_Solver/Implementation.md)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.