function [] = Boundary_condition_visualization(truss_member_array_numbered, BC_fixed_support_nodes, BC_roller_support_x_nodes, BC_roller_support_y_nodes, force_nodes_user, forces_global, Length_global)

%BOUNDARY_CONDITIONS_AND_SOLUTION Plots the geometry with the applied boundary conditions and external loads.
%   
%   Inputs:
%       truss_member_array_numbered  - Truss member coordinates and numbering    
%       BC_fixed_support_nodes       - Nodes where fixed support conditions are applied
%       BC_roller_support_x_nodes    - Nodes where roller supports that constrain X-direction are applied
%       BC_roller_support_y_nodes    - Nodes where roller supports that constrain Y-direction are applied
%       force_nodes_user             - Nodes where external forces are applied
%       forces_global                - Global force vector
%       Length_global  - Length of each truss member
%
%   Outputs:
%       The plot with applied boundary conditions and external loads.

figure(3)
hold on
for d= 1:size(truss_member_array_numbered,2)
    truss_plot= truss_member_array_numbered{1,d};
    plot(truss_plot(1,:), truss_plot(2,:), '-', 'LineWidth',2 , 'Marker', '.', 'MarkerSize',25, 'Color', 'k')
end

%% fixed support icon
plot_fixed=[];
for i= BC_fixed_support_nodes

    for j= 1:length(truss_member_array_numbered)

        truss_member_coords= truss_member_array_numbered{j};

        if truss_member_coords(3,1) == i

            node_coords_i= truss_member_coords(:,1);
            break
        elseif truss_member_coords(3,2) == i

            node_coords_i= truss_member_coords(:,2);
            break
        end

    end
   
    offset= 0.05*mean(Length_global);
    plot_fixed = plot(node_coords_i(1,1), node_coords_i(2,1) - offset,'Marker', '^', 'MarkerSize', 12,'Color','r','LineWidth',4);
end

%% roller support Y free icon
plot_y_free=[];
for i= BC_roller_support_y_nodes

    for j= 1:length(truss_member_array_numbered)

        truss_member_coords= truss_member_array_numbered{j};

        if truss_member_coords(3,1) == i

            node_coords_i= truss_member_coords(:,1);
            break
        elseif truss_member_coords(3,2) == i

            node_coords_i= truss_member_coords(:,2);
            break
        end
    end
   
    offset= 0.05*mean(Length_global);
    plot_y_free =  plot(node_coords_i(1,1) + offset, node_coords_i(2,1),'Marker', 'o', 'MarkerSize', 12,'Color','c','LineWidth',4);
end

%% roller support X free icon
plot_x_free=[];
for i= BC_roller_support_x_nodes

    for j= 1:length(truss_member_array_numbered)

        truss_member_coords= truss_member_array_numbered{j};

        if truss_member_coords(3,1) == i

            node_coords_i= truss_member_coords(:,1);
            break
        elseif truss_member_coords(3,2) == i

            node_coords_i= truss_member_coords(:,2);
            break
        end
    end
   
    offset= 0.05*mean(Length_global);
    plot_x_free = plot(node_coords_i(1,1), node_coords_i(2,1) - offset,'Marker', 'o', 'MarkerSize', 12,'Color','b','LineWidth',4);
end

%% Plotting forces

force_user= zeros(length(force_nodes_user),2);

for i= 1:length(force_nodes_user) 
    force_user(i,1)= forces_global(force_nodes_user(i)*2 -1 , 1);
    force_user(i,2)= forces_global(force_nodes_user(i)*2, 1);
end

f= 1;
scale_force= zeros(size(force_user,1),1)';
plot_force=[];

for i= 1:size(force_user,1)
    force_magnitude= sqrt(force_user(i,1)^2 + force_user(i,2)^2);
    scale_force(i)= mean(Length_global)* 40/100 * 1/force_magnitude;
end

for i= force_nodes_user
    
    for j= 1:length(truss_member_array_numbered)

        truss_member_coords= truss_member_array_numbered{j};

        if truss_member_coords(3,1) == i

            node_coords_i= truss_member_coords(:,1);
            break
        elseif truss_member_coords(3,2) == i

            node_coords_i= truss_member_coords(:,2);
            break
        end
    end

    plot_force = quiver(node_coords_i(1,1), node_coords_i(2,1), scale_force(f)*force_user(f,1), scale_force(f)*force_user(f,2),'LineWidth',3,'MaxHeadSize', 2,'Color','r');
    f= f+1;
end
    
axis equal
xlabel('X [m]')
ylabel('Y [m]')
zlabel('Z [m]')
title('Geometry with Boundary Conditions Applied')

legend_handles = [];
legend_names= {};

if ~isempty(plot_fixed)
    legend_handles(end+1) = plot_fixed;
    legend_names{end+1} = 'Fixed support';
end

if ~isempty(plot_y_free)
    legend_handles(end+1) = plot_y_free;
    legend_names{end+1} = 'Y-free Roller Support';
end

if ~isempty(plot_x_free)
    legend_handles(end+1) = plot_x_free;
    legend_names{end+1} = 'X-free Roller support';
end

if ~isempty(plot_force)
    legend_handles(end+1) = plot_force;
    legend_names{end+1} = 'Applied Force';
end

legend(legend_handles, legend_names)