function [U_global, F_global, Table_support_reactions] = Boundary_Conditions_and_solution(K_global, all_elements_array_numbered, all_nodes_numbered, no_of_unique_nodes, beam_centerline_array_divided)
%BOUNDARY_CONDITIONS_AND_SOLUTION Applies boundary conditions and solves the FEM system.
%
%   INPUT:
%       K_global                    - Global stiffness matrix of the
%                                     beam/frame structure.
%       all_elements_array_numbered - Array containing the FEM elements
%                                     and their corresponding node
%                                     numbers.
%       all_nodes_numbered          - Array containing the FEM node
%                                     coordinates and node numbers.
%       no_of_unique_nodes          - Total number of unique nodes in
%                                     the FEM mesh.
%       beam_centerline_array_divided - Cell array containing the
%                                        meshed beam/frame centerlines
%                                        and their node information.
%
%   OUTPUT:
%       U_global                   - Global displacement vector
%                                    containing nodal translations and
%                                    rotations.
%       F_global                   - Global force vector containing the
%                                    applied nodal and equivalent
%                                    distributed loads.
%       Table_support_reactions    - Table containing the calculated
%                                    support reaction forces and moments.
%
%   The function allows the user to define support boundary conditions
%   and applied loads through the Command Window and the FEM nodes
%   shown in Figure 4. The selected boundary conditions and loads are
%   then applied to the global stiffness matrix and force vector.
%
%   The resulting system is checked for rank deficiency before solving.
%   If the system is not singular, the reduced system is solved to
%   obtain the unknown nodal displacements and rotations. The support
%   reactions are then calculated from the global stiffness and force
%   vectors.

%% Making a figure for user inputs
figure(4)
hold on

for i= 1:length(all_elements_array_numbered)

    x1= all_elements_array_numbered{i}(1,1);
    x2= all_elements_array_numbered{i}(1,2);
    y1= all_elements_array_numbered{i}(2,1);
    y2= all_elements_array_numbered{i}(2,2);

    plot([x1 x2],[y1 y2],'-', 'LineWidth',2 , 'Marker', '.', 'MarkerSize', 20, 'Color', 'b');
end

% figure properties
x_limits= xlim;
y_limits= ylim;
x_limit_range= x_limits(2)-x_limits(1);
y_limit_range= y_limits(2)-y_limits(1);
xlim([x_limits(1)-abs(x_limit_range)*0.20 x_limits(2)+abs(x_limit_range)*0.20])
ylim([y_limits(1)-abs(y_limit_range)*0.20 y_limits(2)+abs(y_limit_range)*0.20])
axis equal
xlabel('X [m]')
ylabel('Y [m]')
title('Boundary Conditions of the Meshed Structure')

legend_handles = []; % Legends for B.C. symbols
legend_names= {};

% These are used for B.C. symbols
bounding_box_figure4 = [min(all_nodes_numbered(1:2,:)'); max(all_nodes_numbered(1:2,:)')];
biggest_length_structure = max(diff(bounding_box_figure4));

%% Taking user inputs for support boundary conditions
fixed_support_coords = [];
roller_support_x_coords = [];
roller_support_y_coords = [];

plot_fixed= [];
plot_support_x= [];
plot_support_y= [];

% Asking user input for fixed supports
fprintf('Select nodes for FIXED SUPPORTS in Figure 4. Press "Enter" when finished (or to skip if none):\n');
fixed_support_coords= ginput();
if ~isempty(fixed_support_coords)
    fixed_support_index= dsearchn(all_nodes_numbered(1:2,:)' , fixed_support_coords);
    fixed_support_nodes= all_nodes_numbered(3 , fixed_support_index);
    fixed_support_nodes= unique(fixed_support_nodes(:).'); % removing repeated inputs
    fprintf('You entered %d fixed supports.\n\n', length(fixed_support_nodes));

    % Plotting the fixed support symbols
    fixed_support_coords= all_nodes_numbered(1:2,fixed_support_index);
    fixed_sup_triangle_H = 0.05*biggest_length_structure;
    fixed_sup_triangle_W = fixed_sup_triangle_H;
    for i=1:length(fixed_support_nodes)
        node_x= fixed_support_coords(1,i);
        node_y= fixed_support_coords(2,i);
        triangle_X = [node_x, node_x-fixed_sup_triangle_W/2, node_x+fixed_sup_triangle_W/2];
        triangle_y = [node_y, node_y-fixed_sup_triangle_H, node_y-fixed_sup_triangle_H];
        plot_fixed = patch(triangle_X, triangle_y, 'r', 'EdgeColor', 'k');
    end
else
    fprintf('No fixed supports are assigned.\n\n');
end

if ~isempty(plot_fixed) % legends for fixed support
    legend_handles(end+1) = plot_fixed;
    legend_names{end+1} = 'Fixed support';
    legend(legend_handles, legend_names)
    legend('Location','eastoutside')
end

% Asking user input for roller supports
fprintf('Select nodes for ROLLER SUPPORTS constrained in X-direction (free in Y) in Figure 4. Press "Enter" when finished (or to skip if none):\n');
roller_support_x_coords= ginput();
if ~isempty(roller_support_x_coords)
    roller_support_x_index= dsearchn(all_nodes_numbered(1:2,:)' , roller_support_x_coords);
    roller_support_x_nodes= all_nodes_numbered(3 , roller_support_x_index);
    roller_support_x_nodes= unique(roller_support_x_nodes(:).'); % removing repeated inputs
    fprintf('You entered %d roller-x supports.\n\n', length(roller_support_x_nodes));

    % Plotting the roller-x support symbols
    roller_support_x_coords= all_nodes_numbered(1:2,roller_support_x_index);
    radius = 0.025*biggest_length_structure;
    circle_resolution = 20; %node points of circle symbol
    theta = linspace(0, 2*pi, circle_resolution+1);
    theta(end) = []; % deleting duplicate at the end
    for i=1:length(roller_support_x_nodes)
        node_x= roller_support_x_coords(1,i);
        node_y= roller_support_x_coords(2,i);
        center_x = node_x + radius;
        circle_x = center_x + radius*cos(theta);
        circle_y = node_y + radius*sin(theta);
        plot_support_x = patch(circle_x, circle_y, 'c', 'EdgeColor', 'k');
    end    
else
    fprintf('No roller-x supports are assigned.\n\n');
end

if ~isempty(plot_support_x)
    legend_handles(end+1) = plot_support_x;
    legend_names{end+1} = 'Y-free Roller Support';
    legend(legend_handles, legend_names)
    legend('Location','eastoutside')
end

fprintf('Select nodes for ROLLER SUPPORTS constrained in Y-direction (free in X) in Figure 4. Press "Enter" when finished (or to skip if none):\n');
roller_support_y_coords= ginput();
if ~isempty(roller_support_y_coords)
    roller_support_y_index= dsearchn(all_nodes_numbered(1:2,:)' , roller_support_y_coords);
    roller_support_y_nodes= all_nodes_numbered(3 , roller_support_y_index);
    roller_support_y_nodes= unique(roller_support_y_nodes(:).'); % removing repeated inputs
    fprintf('You entered %d roller-y supports.\n\n', length(roller_support_y_nodes));

    % Plotting the roller-x support symbols
    roller_support_y_coords= all_nodes_numbered(1:2,roller_support_y_index);
    radius = 0.025*biggest_length_structure;
    circle_resolution = 20; %node points of circle symbol
    theta = linspace(0, 2*pi, circle_resolution+1);
    theta(end) = []; % deleting duplicate at the end
    for i=1:length(roller_support_y_nodes)
        node_x= roller_support_y_coords(1,i);
        node_y= roller_support_y_coords(2,i);
        center_y = node_y + radius;
        circle_x = node_x + radius*cos(theta);
        circle_y = center_y + radius*sin(theta);
        plot_support_y = patch(circle_x, circle_y, 'm', 'EdgeColor', 'k');
    end  
else
    fprintf('No roller-y supports are assigned.\n\n');
end

if ~isempty(plot_support_y)
    legend_handles(end+1) = plot_support_y;
    legend_names{end+1} = 'X-free Roller support';
    legend(legend_handles, legend_names)
    legend('Location','eastoutside')
end

%% Constructing the B.C. applied stiffness matrix

DOF = 3; % degree of freedom of each node (for bar-beam element)

% Constructing the node number indices for supports for B.C. applications
BC_fixed_support_indices= [];
BC_x_support_indices= [];
BC_y_support_indices= [];

if isempty(fixed_support_coords)
    %do nothing
else
    for i= 1:length(fixed_support_nodes)
        node = fixed_support_nodes(i);
        indices = [(node*DOF - 2),(node*DOF - 1),(node*DOF)];
        BC_fixed_support_indices= [BC_fixed_support_indices, indices];
    end
end

if isempty(roller_support_x_coords)
    %do nothing
else
    for i= 1:length(roller_support_x_nodes)
        node = roller_support_x_nodes(i);
        indices = node*DOF-2;
        BC_x_support_indices = [BC_x_support_indices, indices];
    end
end

if isempty(roller_support_y_coords)
    %do nothing
else
    for i= 1:length(roller_support_y_nodes)
        node = roller_support_y_nodes(i);
        indices = node*DOF-1;
        BC_y_support_indices = [BC_y_support_indices, indices];
    end
end

total_indices = 1:(no_of_unique_nodes*DOF);
BC_applied_indices = [BC_fixed_support_indices BC_x_support_indices BC_y_support_indices];
BC_indices= setdiff(total_indices, BC_applied_indices); % leftover stiffness matrix indices after the B.C.'s

% matrix after applying the boundary conditions
K_global_BC_applied = [K_global(BC_indices,BC_indices)];

% Checking if the K matrix obtained from the B.C's is valid
if rank(full(K_global_BC_applied))< size(K_global_BC_applied,1)
    fprintf('Please check boundary conditions. The global stiffness matrix is singular. Possible rigid body motion or mechanism exists.\n')
    error('Boundary conditions')
end

%% Taking user inputs for the applied forces
F_global = zeros(DOF*no_of_unique_nodes,1);

force_coords= [];
moment_coords= [];

plot_force= [];
plot_moment= [];

% Asking user input for nodal forces
fprintf('Select nodes for applied FORCES in Figure 4. Press "Enter" when finished (or to skip if none):\n');
force_coords= ginput();
if ~isempty(force_coords)
    force_index= dsearchn(all_nodes_numbered(1:2,:)' , force_coords);
    force_nodes= all_nodes_numbered(3 , force_index);
    force_nodes= unique(force_nodes(:).'); % removing repeated inputs
end

if ~isempty(force_coords)
    fprintf('\nYou have entered %d forces.',length(force_nodes))
    force_components= zeros(length(force_nodes),2);
    for i= 1:length(force_nodes)
        fprintf('\nEnter force components Fx and Fy for Force #%d, respectively (e.g. 100 -50). Use 0 for non existent component:\n',i)
        force_components(i,:) = str2num(input('','s'));
    end

    % Plotting the force symbols
    scale_force= zeros(size(force_components,1),1)';
    force_coords = all_nodes_numbered(1:2,force_index);
    for i= 1:size(force_components,1)
        force_magnitude= sqrt(force_components(i,1)^2 + force_components(i,2)^2);
        scale_force(i)= biggest_length_structure* 10/100 * 1/force_magnitude;
        node_x = force_coords(1,i);
        node_y = force_coords(2,i);
        plot_force = quiver(node_x, node_y, scale_force(i)*force_components(i,1), scale_force(i)*force_components(i,2),'LineWidth',3,'MaxHeadSize', 2,'Color','r');
    end
else
    fprintf('No nodal forces are assigned.\n')
end

if ~isempty(plot_force)
    legend_handles(end+1) = plot_force;
    legend_names{end+1} = 'Applied Force';
    legend(legend_handles, legend_names)
    legend('Location','eastoutside')
end

% Adding user inputed forces to global force vector
if ~isempty(force_coords)
    for i = 1: length(force_nodes)
        index_force = [force_nodes(i)*DOF - 2, force_nodes(i)*DOF - 1];
        F_global(index_force) =  F_global(index_force) + force_components(i,:)';
    end
end

% Asking user input for moments
fprintf('\nSelect nodes for applied MOMENTS in Figure 4. Press "Enter" when finished (or to skip if none):\n');
moment_coords= ginput();
if ~isempty(moment_coords)
    moment_index= dsearchn(all_nodes_numbered(1:2,:)' , moment_coords);
    moment_nodes= all_nodes_numbered(3 , moment_index);
    moment_nodes= unique(moment_nodes(:).'); % removing repeated inputs
end

if ~isempty(moment_coords)
    fprintf('\nYou have entered %d moments.',length(moment_nodes))
    moment_values= zeros(length(moment_nodes),1);
    for i= 1:length(moment_nodes)
        fprintf('\nEnter moment value for Moment #%d (counterclockwise is positive):\n',i)
        moment_user(i) = str2num(input('','s'));
    end

    % plotting moment symbols
    moment_coords= all_nodes_numbered(1:2, moment_index);
    r = 0.05*biggest_length_structure; %radius of the moment arc symbol
    theta = linspace(-pi/2, pi/2, 20);  %angle range of moment arc symbol
    for i=1:length(moment_nodes)
        
        node_x= moment_coords(1,i);
        node_y= moment_coords(2,i);
        arc_x= node_x + r*cos(theta);
        arc_y= node_y + r*sin(theta);
        plot_moment= plot(arc_x, arc_y,'g-', 'LineWidth', 2);

        if moment_user(i) > 0
            arrow_line_x= [node_x, node_x + r/3*cosd(45)];
            arrow_line_1y= [node_y + r, node_y + r + r/3*sind(45)];
            arrow_line_2y= [node_y + r, node_y + r - r/3*sind(45)];
        else     
            arrow_line_x= [node_x, node_x + r/4*cosd(45)];
            arrow_line_1y= [node_y - r, node_y - r + r/3*sind(45)];
            arrow_line_2y= [node_y - r, node_y - r - r/3*sind(45)];
        end
        plot([arrow_line_x arrow_line_x],[arrow_line_1y arrow_line_2y], 'g-', 'LineWidth',2)
    end
else
    fprintf('No nodal moments are assigned.\n')
end

if ~isempty(plot_moment)
    legend_handles(end+1) = plot_moment;
    legend_names{end+1} = 'Applied Moment';
    legend(legend_handles, legend_names)
    legend('Location','eastoutside')
end

% Adding user inputed moments to global force vector
if ~isempty(moment_coords)
    for i = 1: length(moment_nodes)
        index_moment = moment_nodes(i)*DOF;
        F_global(index_moment) =  F_global(index_moment) + moment_user(i)';
    end
end

% Distributed loads: 
no_of_distributed_force= [];
user_distributed_force_all= [];
distributed_force_nodes_all= [];
no_of_distributed_force= str2num(input('\nEnter the amount of DISTRIBUTED LOADS you want to apply (e.g. 2). Press "Enter" when finished (or to skip if none):\n','s'));

if ~isempty(no_of_distributed_force)
    for i= 1:no_of_distributed_force
        
        user_distributed_force = str2num(input(sprintf('\nEnter the value for distributed force #%d components qx and qy (e.g. 100 50). Use 0 for non existent component.\n', i),'s'));

        fprintf('Select exactly 2 nodes on same beam/frame member to define the start and end points of the distributed load. Press [Enter] to confirm:\n');
        disributed_force_coords= ginput();
        % error check if user entered more than 2 nodes
        if size(disributed_force_coords,1) > 2 
            error('More than 2 nodes are selected.') 
        end
        distributed_force_index= dsearchn(all_nodes_numbered(1:2,:)' , disributed_force_coords);
        distributed_force_nodes_user= all_nodes_numbered(3 , distributed_force_index);
        distributed_force_nodes_user= unique(distributed_force_nodes_user(:).'); % removing repeated inputs
        disributed_force_coords= all_nodes_numbered(1:2, distributed_force_index);
        
        % error check to see if user selected nodes on same beam/frame member
        for j= 1:length(beam_centerline_array_divided)
            check_node(j,1) = any(all(beam_centerline_array_divided{j}(1:2,:) == disributed_force_coords(:,1),1));
            check_node(j,2) = any(all(beam_centerline_array_divided{j}(1:2,:) == disributed_force_coords(:,2),1));
        end

        if ~any(all(check_node == [1, 1], 2))
            error('Selected nodes for distributed load do not exist on the same member')
        else
            member_index = dsearchn(check_node, [1 1]);
        end
        
        % saving each node number where distributed force is applied to
        member_nodes= beam_centerline_array_divided{member_index}(3,:);
        [~, node_index] = ismember(distributed_force_nodes_user', member_nodes', 'rows');
        node_index= sort(node_index);
        distributed_force_nodes_all = beam_centerline_array_divided{member_index}(:, node_index(1):node_index(2)); % getting all nodes between the user inputed nodes

        % plotting distributed force symbols

        % sorting the coords so that node selection order does not effect arrow position calculations
        if disributed_force_coords(1,1) == disributed_force_coords(1,2) %if x's are equal than smaller y comes first
            [~, sort_index] = sort(disributed_force_coords(2, :));
            disributed_force_coords = disributed_force_coords(:,sort_index);
        else %else smaller x comes first
            [~, sort_index] = sort(disributed_force_coords(1, :));
            disributed_force_coords = disributed_force_coords(:,sort_index);
        end

        length_distributed_region = norm(disributed_force_coords(:,2)'- disributed_force_coords(:,1)');
        arrow_spacing = 0.05*biggest_length_structure;
        no_of_arrows= max(2, floor(length_distributed_region/arrow_spacing));
        theta= atand((disributed_force_coords(2,2)-disributed_force_coords(2,1))/(disributed_force_coords(1,2)-disributed_force_coords(1,1))); % angle of the frame member where distributed load is acting on
        length_arrow_space= linspace(0,length_distributed_region, no_of_arrows);
        x_arrow = disributed_force_coords(1,1) + length_arrow_space*cosd(theta);
        y_arrow= disributed_force_coords(2,1) + length_arrow_space*sind(theta);
        force_vector_normalized = user_distributed_force / norm(user_distributed_force);
        arrow_magnitude_x= ones(1,no_of_arrows) * biggest_length_structure*0.08 * force_vector_normalized(1);
        arrow_magnitude_y= ones(1,no_of_arrows) * biggest_length_structure*0.08 * force_vector_normalized(2);

        plot_distributed_force = quiver(x_arrow, y_arrow, arrow_magnitude_x , arrow_magnitude_y ,'off',"LineWidth",1 ,"Color",[0.627, 0.188, 0.659]);
        legend_handles(end+1) = plot_distributed_force;
        legend_names{end+1} = 'Distributed Load';
        legend(legend_handles, legend_names)
        legend('Location','eastoutside')

        % saving the values of each distributed force at the end of the loop
        user_distributed_force_global{i} = user_distributed_force';
        distributed_force_nodes_global{i} = distributed_force_nodes_all;
    end
end

% Adding user defined distributed forces to global force vector
if ~isempty(no_of_distributed_force)
    for i= 1:length(distributed_force_nodes_global)

        for j= 1:(size(distributed_force_nodes_global{i},2)-1)

            element_coords_and_nodes = distributed_force_nodes_global{i}(:,j:j+1);

            % sorting node numbers of the element for correct theta value calculation
            [~, index] = sort(element_coords_and_nodes(3,:));
            element_coords_and_nodes = element_coords_and_nodes(:,index);

            x1= element_coords_and_nodes(1,1);
            x2= element_coords_and_nodes(1,2);
            y1= element_coords_and_nodes(2,1);
            y2= element_coords_and_nodes(2,2);
            node1 = element_coords_and_nodes(3,1);
            node2 = element_coords_and_nodes(3,2);

            theta= atand( (y2-y1) / (x2-x1) );
            L= norm(element_coords_and_nodes(1:2,1) - element_coords_and_nodes(1:2,2));

            transformation_matrix = [cosd(theta) sind(theta) 0;
                -sind(theta) cosd(theta) 0;
                0           0           1];

            local_forces = transformation_matrix * [user_distributed_force_global{i} ; 0];
            qx= local_forces(1);
            qy= local_forces(2);

            % equivalent axial nodal forces
            F_axial_local = [qx * L / 2 ; qx * L / 2];
            % equivalent shear nodal forces
            F_shear_local = [qy * L / 2 ; qy * L / 2];
            % equivalent nodal moments
            F_shear_moment_local = [qy * L^2 / 12 ; -1*qy * L^2 / 12];

            F_local_coords_node1 = [F_axial_local(1);F_shear_local(1);F_shear_moment_local(1)];
            F_local_coords_node2 = [F_axial_local(2);F_shear_local(2);F_shear_moment_local(2)];

            F_global_coords_node1 = transformation_matrix' * F_local_coords_node1;
            F_global_coords_node2 = transformation_matrix' * F_local_coords_node2;

            % assigning these values to global F vector

            node1_indices = [node1*DOF - 2 , node1*DOF - 1 , node1*DOF];
            F_global(node1_indices) = F_global(node1_indices) + F_global_coords_node1;

            node2_indices = [node2*DOF - 2 , node2*DOF - 1 , node2*DOF];
            F_global(node2_indices) = F_global(node2_indices) + F_global_coords_node2;
        end
    end
end
% getting rid of numerical noise due to floting point accuracy
F_global(abs(F_global) < 1e-6)= 0;

%% Solution
U_global = zeros(DOF*no_of_unique_nodes,1);
F_global_BC_applied = F_global(BC_indices);

U_global(BC_indices) = K_global_BC_applied \ F_global_BC_applied;

%% Reaction forces
Reaction_forces = K_global*U_global - F_global;
Reaction_forces(abs(Reaction_forces)< 1e-8) = 0; % getting rid of floting point accuracy noises

% Creating a table for reaction forces

if isempty(fixed_support_coords)
    i=0;
else
    for i= 1:length(fixed_support_nodes)
        sup_names(i) = "Fixed Support";
        sup_x_y{i} = all_nodes_numbered(1:2, all_nodes_numbered(3,:) == fixed_support_nodes(i))';
        if size(sup_x_y{i},1) == 2 % if the support is at the junction of beams, it gets same cordinate more than once. So it is deleted here.
            sup_x_y{i}(2,:) = [];
        end
        Rx(i)= Reaction_forces(fixed_support_nodes(i)*3-2);
        Ry(i)= Reaction_forces(fixed_support_nodes(i)*3-1);
        M(i)= Reaction_forces(fixed_support_nodes(i)*3);
    end
end

if isempty(roller_support_x_coords)
    j=i;
else
    n= 1;
    for j= (i+1):(i+length(roller_support_x_nodes))
        sup_names(j) = "Roller-X Support";
        sup_x_y{j} = all_nodes_numbered(1:2, all_nodes_numbered(3,:) == roller_support_x_nodes(n))';
        if size(sup_x_y{j},1) == 2 % if the support is at the junction of beams, it gets same cordinate more than once. So it is deleted here.
            sup_x_y{j}(2,:) = [];
        end
        Rx(j)= Reaction_forces(roller_support_x_nodes(n)*3-2);
        Ry(j)= 0;
        M(j)= 0;
        n= n+1;
    end
end

if isempty(roller_support_y_coords)
    %do nothing
else
    n=1;
    for k= (j+1):(j+length(roller_support_y_nodes))
        sup_names(k) = "Roller-Y Support";
        sup_x_y{k} = all_nodes_numbered(1:2, all_nodes_numbered(3,:) == roller_support_y_nodes(n))';
        if size(sup_x_y{k},1) == 2 % if the support is at the junction of beams, it gets same cordinate more than once. So it is deleted here.
            sup_x_y{k}(2,:) = [];
        end
        Rx(k)= 0;
        Ry(k)= Reaction_forces(roller_support_y_nodes(n)*3-1);
        M(k)= 0;
        n= n+1;
    end
end

Table_support_reactions= table(sup_names', sup_x_y', Rx', Ry', M', ...
    'VariableNames', ["Support Type", "Support Position (x,y)", "Rx [N]", "Ry [N]", "Moment [Nm]"]);