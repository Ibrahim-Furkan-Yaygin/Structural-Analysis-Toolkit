function [stress_MPa, axial_forces, support_reactions, strain] = Post_processing(E, Area, u_global, l_m_array_global, Length_global, K_global, forces_global, truss_member_array_numbered)

%POST_PROCESSING Calculates and visualizes truss analysis results.
%   The function performs post-processing of the finite element solution
%   and calculates the axial force, stress, and strain for each truss
%   element. Support reaction forces are also calculated.
%
%   The function generates result visualizations for the analyzed truss,
%   including axial force, stress, and displacement results.
%
%   Inputs:
%       E                            - Young's modulus
%       Area                         - Cross-sectional area
%       u_global                     - Global nodal displacement vector
%       l_m_array_global             - Direction cosines of each element
%       Length_global                - Length of each truss member
%       K_global                     - Global stiffness matrix
%       forces_global                - Global force vector
%       truss_member_array_numbered  - Truss member coordinates and numbering
%
%   Outputs:
%       Calculated element stresses, strains, axial forces, support
%       reactions, and corresponding result figures.

% initializing vectors
strain= zeros(1,length(Length_global));
stress= zeros(1,length(Length_global));

% calculating strain and stresses of each truss member:
for i= 1:length(Length_global) %note that length(Length_global) is equal to the total number of truss members

    l= l_m_array_global{1,i}(1);
    m= l_m_array_global{1,i}(2);

    displacement_indices= l_m_array_global{2,i}(:)';
    ui= u_global(displacement_indices(1)*2 -1);
    vi= u_global(displacement_indices(1)*2);
    uj= u_global(displacement_indices(2)*2 -1);
    vj= u_global(displacement_indices(2)*2);

    strain(i) = 1/Length_global(i) * [-l -m l m] * [ui vi uj vj]';
    stress(i) = E* strain(i);
end

stress_MPa= stress/1e6; % stresses in MPa

axial_forces= stress*Area; % Unit is in Newton

support_reactions = K_global*u_global - forces_global; % Unit is in Newton

% Contour plots:

% axial force contour
color_map= jet(256);

axial_forces_normalized= normalize(axial_forces,"range"); % normalizing the vector for color mapping
color_map_indices_axial_forces= round(axial_forces_normalized*255)+1;
color_axial_forces= color_map(color_map_indices_axial_forces,:);

figure(4)
hold on
for d= 1:size(truss_member_array_numbered,2)
    truss_plot= truss_member_array_numbered{1,d};
    plot(truss_plot(1,:), truss_plot(2,:), '-o', 'LineWidth',2, 'MarkerSize',8, 'Color', color_axial_forces(d,:))
end

axis equal
xlabel('X [m]')
ylabel('Y [m]')
title('Axial Forces Contour')
clim([floor(min(axial_forces)), ceil(max(axial_forces))])
colormap(jet);
c_axial_force= colorbar;
c_axial_force.Label.FontSize = 16;
c_axial_force.FontSize= 14;
c_axial_force.Label.String = 'Axial Force [N]';

% stress contour
stress_global_MPa_normalized= normalize(stress_MPa,"range");
color_map_indices_stress= round(stress_global_MPa_normalized*255)+1;
color_stress= color_map(color_map_indices_stress,:);

figure(5)
hold on
for d= 1:size(truss_member_array_numbered,2)
    truss_plot= truss_member_array_numbered{1,d};
    plot(truss_plot(1,:), truss_plot(2,:), '-o', 'LineWidth',2, 'MarkerSize',8, 'Color', color_stress(d,:))
end

axis equal
xlabel('X [m]')
ylabel('Y [m]')
title('Stress Contour')
clim([floor(min(stress_MPa)), ceil(max(stress_MPa))])
colormap(jet);
c_axial_force= colorbar;
c_axial_force.Label.FontSize = 16;
c_axial_force.FontSize= 14;
c_axial_force.Label.String = 'Stress [MPa]';

% Displacement Contour

figure(6)

%Auto scale is determined as the number which multiplied with the maximum
% deformation gives 20% of length of avarage truss member length
L_average= mean(Length_global);
auto_scale = 20/100 * L_average * 1/max(abs(u_global));

for d= 1:size(truss_member_array_numbered,2)

    u_indices_first_node= [(truss_member_array_numbered{d}(3,1)*2 -1), truss_member_array_numbered{d}(3,1)*2];
    u_indices_second_node= [(truss_member_array_numbered{d}(3,2)*2 -1), truss_member_array_numbered{d}(3,2)*2];
    first_node_total_displacement= sqrt(u_global(u_indices_first_node(1))^2 + u_global(u_indices_first_node(2))^2);
    second_node_total_displacement= sqrt(u_global(u_indices_second_node(1))^2 + u_global(u_indices_second_node(2))^2);

    patch_x= [(truss_member_array_numbered{d}(1,1) + u_global(u_indices_first_node(1))*auto_scale), (truss_member_array_numbered{d}(1,2) + u_global(u_indices_second_node(1))*auto_scale)];
    patch_y= [(truss_member_array_numbered{d}(2,1) + u_global(u_indices_first_node(2))*auto_scale), (truss_member_array_numbered{d}(2,2) + u_global(u_indices_second_node(2))*auto_scale)];
    patch_c= [first_node_total_displacement, second_node_total_displacement];

    patch(patch_x,patch_y, patch_c, 'EdgeColor', 'interp', 'Marker', 'o', 'MarkerFaceColor','flat','LineWidth', 3)
end

axis equal
xlabel('X [m]')
ylabel('Y [m]')
title("Total Displacement Contour (autoscale: " + num2str(auto_scale) + "x)")
colormap(jet);
c_displacement= colorbar;
c_displacement.Label.FontSize = 16;
c_displacement.FontSize= 14;
c_displacement.Label.String = 'Displacement [m]';