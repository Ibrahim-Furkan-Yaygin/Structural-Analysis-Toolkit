# Module 2 - 2D Beam/Frame Solver

The 2D Beam/Frame Solver is the second module of the Structural Analysis Toolkit. It is developed in MATLAB for the finite element analysis of 2D beam and frame structures.

Unlike the truss solver, which only considers axial deformation, this module uses beam/frame elements that can carry both axial and bending loads. The solver imports the structural geometry from DXF files, creates the finite element mesh, applies boundary conditions and loads interactively, and calculates nodal displacements, support reactions, and internal force distributions.

## Features

- 2D beam and frame finite element analysis (Euler-Bernoulli beam/frame formulation)
- Import of beam/frame centerline geometry from DXF files
- Import of beam cross-section geometry from a separate DXF file
- Visualization of the imported cross-section and the extruded 3D beam/frame geometry
- Automatic meshing based on user-selected number of elements per member
- Visualization of the meshed structure
- Interactive selection of supports and loads
- Fixed and roller boundary conditions
- Point forces and nodal moments
- Distributed loads defined in the global coordinate system
- Singular stiffness matrix check
- Nodal displacement results
- Support reaction calculations
- Axial force, shear force, and bending moment diagrams
- Deformed structure visualization with contour mapping

## Formulation

The solver uses the standard 2D Euler-Bernoulli beam/frame element formulation.

Each node has three degrees of freedom:

- Translation in the global $x$ direction
- Translation in the global $y$ direction
- Rotation about the $z$ axis

Each beam/frame element therefore has six degrees of freedom.

The element stiffness matrix is formulated in the local coordinate system and transformed into the global coordinate system according to the orientation of each member. The transformed element matrices are then assembled into the global stiffness matrix.

The global system is solved in the following form:

$$
\mathbf{K}\mathbf{U} = \mathbf{F}
$$

where $\mathbf{K}$ is the global stiffness matrix, $\mathbf{U}$ is the nodal displacement vector, and $\mathbf{F}$ is the global load vector.

After solving the system, the solver calculates the nodal displacements, support reactions, and internal force distributions.

The detailed beam/frame formulation, element stiffness matrix, coordinate transformation, and internal force recovery are described in the [module documentation](Documentation/README.md).

## Workflow

The general workflow of the solver is:

1. Import the beam/frame centerline and cross-section geometry from DXF files.
2. Display the imported geometry for visual inspection.
3. Ask the user to define the number of finite elements for beam/frame members.
4. Generate and display the finite element mesh.
5. Select supports interactively.
6. Apply point forces and nodal moments.
7. Apply distributed loads to selected members.
8. Assemble and solve the global finite element system.
9. Calculate nodal displacements and support reactions.
10. Calculate axial force, shear force, and bending moment distributions.
11. Display the deformed structure and internal force diagrams.

## CAD / DXF Geometry Import

The solver uses two separate DXF files to define the structure:

- **Beam/frame centerline:** defines the location and shape of the beam/frame members.
- **Beam cross-section:** defines the cross-section that is used for the beam/frame members.

The centerline geometry is imported and processed to create the beam/frame members. Straight members are supported, including members with different orientations in the global coordinate system.

The cross-section is imported separately for cross-section property calculations and is also used to create an extruded visualization of the structure.

The DXF files are specified in the main MATLAB script before running the solver.

More details about the required DXF geometry and the import process are given in the [module documentation](Documentation/README.md).

## Example & Validation

A complete portal frame example is included in the `Examples_and_Validation` folder.

The example demonstrates the complete workflow, starting from CAD geometry import and meshing and continuing through boundary condition and load definition, solution, post-processing, and validation.

The FEM results are compared with an independent analytical solution based on the force method and the unit-load method.

The validation includes:

- Support reaction forces
- Horizontal nodal displacement at a corner point
- Bending moment distribution
- Shear force distribution
- Axial force distribution

See [`Examples_and_Validation`](Examples_and_Validation/2D_Portal_Frame/README.md) for the complete example and analytical solution.

## Limitations

The current version of the solver has the following limitations:

- Only 2D beam and frame structures are supported.
- The beam/frame members are straight.
- The cross-section is same and constant along each member.
- Euler-Bernoulli beam theory is used (Shear deformation is not included).
- The current implementation uses linear elastic material behavior.
- Geometric nonlinearity is not considered.
- Material nonlinearity is not considered.
- The same number of finite elements is currently used for each beam/frame member.
- The current CAD import workflow is based on DXF export files only.

## Requirements

- MATLAB
- A CAD software capable of exporting DXF files in the supported format.

No additional software or MATLAB toolbox is required to run the solver.

## How to Run

1. Open MATLAB.
2. Open the Module 2 folder.
3. Open the main MATLAB script.
4. Set the file names or paths for the beam/frame centerline and cross-section DXF files in the main script manually.
5. Set the Modulus of Elasticity of your problem in main script manually.
6. Run the main script.
7. Check the imported geometry shown in the MATLAB figures.
8. Enter the desired number of finite elements for each beam/frame member in the Command Window.
9. Select the required supports and loads when prompted.
10. Review the mesh and boundary condition/load figures.
11. Check the displacement, reaction, and internal force results.

The exact interaction steps and input requirements are described in the [module documentation](Documentation/README.md).

For a complete worked example, see: [`Examples_and_Validation`](Examples_and_Validation/2D_Portal_Frame/README.md)

## Documentation

Detailed information about the implementation and the required inputs is provided in the `Documentation` folder.

The documentation covers topics such as:

- DXF geometry requirements
- Geometry import
- Beam/frame element formulation
- Coordinate transformation
- Mesh generation
- Boundary condition input
- Point force and moment input
- Distributed load input
- Solver and singularity checks
- Post-processing and internal force recovery

## License

This project is licensed under the MIT License. See the [`LICENSE`](../LICENSE) file for more information.
