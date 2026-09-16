clc; clear; close all; format shortG;

unit_convert= 1000; % unit conversion from mm to meter, It is hard coded for now, it is used in the parser function

E= 2e+11; % Young's Modulus in Pascal

%Reading .dxf file for beam centerline
[beam_centerline_array] = DXF_Parser_Beam('beam_centerline_validation_example.DXF',unit_convert);

%Reading .dxf file for crossection
[~, crossection_member_array_numbered] = DXF_Parser_Beam('crossection_validation_example.DXF',unit_convert);

%Calculating crossection properties
[Iy, Iz, Izy, Area, y_centroid, crossection_member_array, Crossection_coords_in_order] = Crossection_Properties(crossection_member_array_numbered);

%Getting a plot of the imported geometry
Plot_Beam(beam_centerline_array, crossection_member_array, y_centroid, Crossection_coords_in_order);

%Meshing
[all_elements_array_numbered, all_nodes_numbered, no_of_unique_nodes, beam_centerline_array_divided] = Meshing(beam_centerline_array, crossection_member_array, y_centroid, Crossection_coords_in_order);

%Constructing global stiffness matrix
K_global = Stiffness_Matrix_Construction(all_elements_array_numbered, no_of_unique_nodes, Area, Iz, E);

%Boundary condition aplication and solution
[U_global, F_global, Table_support_reactions] = Boundary_Conditions_and_solution(K_global, all_elements_array_numbered, all_nodes_numbered, no_of_unique_nodes, beam_centerline_array_divided);

%Post Processing
[distribution_moment, distribution_shear, distribution_axial] = Post_Processing(E, Iz, Area, y_centroid, U_global, beam_centerline_array_divided, beam_centerline_array, all_elements_array_numbered, crossection_member_array, Crossection_coords_in_order);

%%

fprintf('\n\n============================================================\n')
fprintf('=================== Solution Complete ======================\n')
fprintf('============================================================\n\n')

fprintf('\n=========================================\n')
fprintf('=========== Support Reactions ===========\n')
fprintf('=========================================\n\n')

disp(Table_support_reactions);

fprintf('Refer to Figure 4 for position coords of the supports.\n\n')

fprintf('View Figures 5, 6, 7 and 8 to see the Moment, Shear Force, Axial Force distribution and Total Deformation plots, respectively.\n\n')