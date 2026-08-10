function [Length_global] = plot_truss(truss_member_array, no_of_unique_nodes)

%PLOT_TRUSS Plots the truss geometry with element and node numbering.
%   The function generates two figures for visualizing the imported truss
%   geometry.
%
%   The first figure displays the truss geometry with element numbering.
%   The second figure displays the geometry with node numbering.
%
%   Node labels are automatically positioned to improve readability and
%   reduce overlap with connected truss members.
%
%   The function also calculates the length of each truss member for latter
%   computations.
%
%   Inputs:
%       truss_member_array  - Truss member coordinates and connectivity
%       no_of_unique_nodes  - Total number of unique nodes
%
%   Outputs:
%       Length_global  - Length of each truss member
%       Displayed Figures 1 and 2

%Calculating the lengths of each truss member. This is used for various
% purposes throughout the program.
%Initializing global length vector
Length_global = zeros(1,length(truss_member_array));

for i= 1:length(truss_member_array)
    Length= sqrt( (truss_member_array{i}(1,1)-truss_member_array{i}(1,2))^2 + (truss_member_array{i}(2,1) - truss_member_array{i}(2,2))^2 );
    Length_global(i)= Length; % global length vector for post processing
end

figure(1)
hold on

for d= 1:size(truss_member_array,2)
    truss_plot= truss_member_array{1,d};
    plot3(truss_plot(1,:), truss_plot(2,:), truss_plot(3,:) , '-', 'LineWidth',2 , 'Marker', '.', 'MarkerSize', 30, 'Color', 'b')

    if truss_plot(1,2) > truss_plot(1,1)

        dx= truss_plot(1,2) - truss_plot(1,1);
        dy= truss_plot(2,2) - truss_plot(2,1);
        angle_element= atan2d(dy,dx);

    elseif truss_plot(1,2) < truss_plot(1,1)
        
        dx= truss_plot(1,1) - truss_plot(1,2);
        dy= truss_plot(2,1) - truss_plot(2,2);
        angle_element= atan2d(dy,dx);

    else % condition where truss_plot(1,2) == truss_plot(1,1)
        
        if truss_plot(2,2) > truss_plot(2,1)

            dx= truss_plot(1,1) - truss_plot(1,2);
            dy= truss_plot(2,1) - truss_plot(2,2);
            angle_element= atan2d(dy,dx);

        else % condition where truss_plot(2,1) > truss_plot(2,2)

            dx= truss_plot(1,2) - truss_plot(1,1);
            dy= truss_plot(2,2) - truss_plot(2,1);
            angle_element= atan2d(dy,dx);

        end
    end
    element_number_x_cord= (truss_plot(1,1)+truss_plot(1,2)) / 2 + 5/100*Length_global(d)*cosd(angle_element+90);
    element_number_y_cord= (truss_plot(2,1)+truss_plot(2,2)) / 2 + 5/100*Length_global(d)*sind(angle_element+90);
    text(element_number_x_cord,element_number_y_cord, num2str(d),'Color','r', 'FontSize', 14)
end

axis equal
xlabel('X [m]')
ylabel('Y [m]')
zlabel('Z [m]')
title('Imported Geometry With Element Numbering')

figure(2)
hold on

for d= 1:size(truss_member_array,2)
    truss_plot= truss_member_array{1,d};
    plot3(truss_plot(1,:), truss_plot(2,:), truss_plot(3,:) , '-', 'LineWidth',2 , 'Marker', '.', 'MarkerSize', 30, 'Color', 'b')
end

% The following is the algorithm that is built to display the node numberings on the plot.
% It is built to show node numbers such that the numbers themselfs do not
% coincide with any of the truss member lines.
% The main logic of the algorithm is the following:
% 1- Calculate the angles of the truss members connected to the node
% 2- Check the biggest angle gap between these truss members
% 3- Place the node number text at the biggest angle gap with an offset in that direction.
    
for i= 1: no_of_unique_nodes
    angles=[];
    angles_diff= [];

    for j= 1:length(truss_member_array)
        
        truss_node_coords= truss_member_array{j};
        if truss_node_coords(3,1) == i
            
            dx= truss_node_coords(1,2) - truss_node_coords(1,1);
            dy= truss_node_coords(2,2) - truss_node_coords(2,1);
            angle_node= atan2d(dy, dx);
            angles= [angles, angle_node];
            node_coords_i= truss_node_coords(:,1);

        elseif truss_node_coords(3,2) == i

            dx= truss_node_coords(1,1) - truss_node_coords(1,2);
            dy= truss_node_coords(2,1) - truss_node_coords(2,2);
            angle_node= atan2d(dy, dx);
            angles= [angles, angle_node];
            node_coords_i= truss_node_coords(:,2);
        end
    end

    if length(angles) == 1 % if node is connected to one truss member only

        offset= 0.1*mean(Length_global);
        text(node_coords_i(1,1)+ offset*cosd(angles+180), node_coords_i(2,1)+ offset*sind(angles+180), num2str(i),'Color','r', 'FontSize', 14)

    else % node is connected to multiple members -> find best suitable angle
        
        angles= sort(angles);
        angles= angles +360; % making angles positive for the following calculation to work
        for k= 1:length(angles)-1
            
            diff= angles(k+1)-angles(k);
            angles_diff = [angles_diff, diff];
        end

        offset= 0.1*mean(Length_global);
        diff= 360 - (angles(end)-angles(1));
        angles_diff = [angles_diff, diff];
        [max_diff, max_index] = max(angles_diff);
        angle_best= angles(max_index) + max_diff/2;
        text(node_coords_i(1,1)+ offset*cosd(angle_best), node_coords_i(2,1)+ offset*sind(angle_best), num2str(i),'Color','r', 'FontSize', 14)
    end
end

axis equal
xlabel('X [m]')
ylabel('Y [m]')
zlabel('Z [m]')
title('Imported Geometry With Node Numbering')

end