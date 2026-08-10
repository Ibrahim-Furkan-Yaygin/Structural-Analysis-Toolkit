clc; clear; close all; format long;

unit_convert= 1000; % unit conversion from mm to meter, It is hard coded for now, it is used in the parser function
DOF= 2; % degree of freedom of each node of the bar element in 2D truss analysis

E= 2e+11; % Young's Modulus in Pascal
Area=  0.06*0.06; % Area in meter^2

%Reading .dxf file
truss_member_array = DXF_parser_truss('Warren_Truss.dxf',unit_convert);

%Node numbering and connectivity
[truss_member_array_numbered, unique_nodes] = Node_numbering_and_connectivity(truss_member_array);
no_of_unique_nodes= size(unique_nodes,1);

%Getting a plot of the geometry
[Length_global] = plot_truss(truss_member_array_numbered, no_of_unique_nodes);

%Construction of stiffness matrices
% note that you can use spy(K_global) to see the bandwidth of the global stiffness matrix
[K_global, l_m_array_global] = Stiffness_matrix_constructor(truss_member_array_numbered, no_of_unique_nodes, E, Area, DOF, Length_global);

%Applying boundary conditions and solving for displacements
[u_global, forces_global, BC_fixed, BC_y_free, BC_x_free, force_nodes] = Boundary_conditions_and_solution(no_of_unique_nodes, DOF, K_global);

%Visualizing applied boundary conditions
Boundary_condition_visualization(truss_member_array_numbered, BC_fixed, BC_x_free, BC_y_free, force_nodes, forces_global, Length_global)

%Post processing
[stress_global_MPa, axial_forces, support_reactions, strain_global] = Post_processing(E, Area, u_global, l_m_array_global, Length_global, K_global, forces_global, truss_member_array_numbered);

%% Creating tables for the solution data

format shortG % Showing less significant figures for table data

fprintf('\n\n============================================================\n')
fprintf('==================== Element Results =======================\n')
fprintf('============================================================\n\n')
threshold= 1e-8; % This threshold is used show values very close to 0 as 0.
axial_forces(abs(axial_forces)<threshold) = 0;
stress_global_MPa(abs(stress_global_MPa)<threshold) = 0;
threshold_strain= 1e-12;
strain_global(abs(strain_global)<threshold_strain) = 0;
Table_stress_strain= table((1:size(truss_member_array,2))', axial_forces', stress_global_MPa', strain_global', ...
    'VariableNames', ["Element no." "Axial Force [N]" "Axial Stress [MPa]" "Strain"]);
disp(Table_stress_strain);
fprintf('Refer to Figure 1 for element numbering and member locations.\n\n')


fprintf('\n============================================================\n')
fprintf('==================== Node Displacements ====================\n')
fprintf('============================================================\n\n')
Ux= deal(u_global(1:2:no_of_unique_nodes*DOF));
Uy= deal(u_global(2:2:no_of_unique_nodes*DOF));
U_total= sqrt(Ux.^2 + Uy.^2);
Ux(abs(Ux) < threshold) = 0; % Showing very small displacements as 0
Uy(abs(Uy) < threshold) = 0;
U_total(abs(U_total) < threshold) = 0;
Table_displacements= table((1:no_of_unique_nodes)', Ux*1000, Uy*1000, U_total*1000, ...
    'VariableNames', ["Node no.", "Ux [mm]", "Uy [mm]", "U_total [mm]"]);
disp(Table_displacements);
fprintf('Refer to Figure 2 for node numbering.\n\n')

fprintf('\n============================================================\n')
fprintf('==================== Support Reactions =====================\n')
fprintf('============================================================\n\n')
BC_nodes_user= [BC_fixed, BC_y_free, BC_x_free];
Table_support_reactions= table(BC_nodes_user', support_reactions((BC_nodes_user*2 -1)), support_reactions((BC_nodes_user*2)), ...
    'VariableNames', ["Support Node no.", "Rx [N]", "Ry [N]"]);
disp(Table_support_reactions);
fprintf('Refer to Figure 2 for node numbering.\n\n')

fprintf('Please check Figure 3 to verify the applied loads and boundary conditions visually.\n')