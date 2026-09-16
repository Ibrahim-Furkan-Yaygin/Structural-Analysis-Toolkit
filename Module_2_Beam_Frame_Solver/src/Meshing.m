function [all_elements_array_numbered, all_nodes_numbered, no_of_unique_nodes, beam_centerline_array_divided] = Meshing(beam_centerline_array, crossection_member_array, y_centroid, Crossection_coords_in_order)
%MESHING Generates the FEM mesh for the beam/frame structure.
%
%   INPUT:
%       beam_centerline_array       - Cell array containing the X-Y
%                                     coordinates of the beam/frame
%                                     centerlines.
%       crossection_member_array    - Cell array containing the
%                                     cross-section information for
%                                     each beam/frame member.
%       y_centroid                  - Y-coordinate of the cross-section
%                                     centroid.
%       Crossection_coords_in_order - Cross-section vertex coordinates
%                                     arranged in the correct order.
%
%   OUTPUT:
%       all_elements_array_numbered   - Array containing the generated
%                                       finite elements and their
%                                       corresponding node numbers.
%       all_nodes_numbered            - Array containing the generated
%                                       node coordinates and node numbers.
%       no_of_unique_nodes            - Total number of unique nodes in
%                                       the generated mesh.
%       beam_centerline_array_divided - Cell array containing the
%                                       beam/frame centerlines divided
%                                       into finite elements, together
%                                       with their node coordinates
%                                       and node numbers.
%
%   The function asks the user to specify the number of elements per
%   beam/frame member, generates equally spaced nodes along each member,
%   assigns node numbers, and creates the FEM mesh.

% Setting the number of elements for each beam/frame member
no_of_elements = str2num(input('Enter the number of elements per member (e.g., 5):\n','s'));

% Error check for number of divisions input
if isempty(no_of_elements) == 1
    error('Invalid input. The number of divisions must be a positive numeric integer.')
end

% Dividing each beam/frame member into specified number of elements

beam_centerline_array_divided = cell(length(beam_centerline_array),1); % preallocating cell array

for i= 1:length(beam_centerline_array)
    
    % sorting beam coords so that smaller x coord comes first. This is imported for the following process
    if beam_centerline_array{i}(1,1) == beam_centerline_array{i}(1,2) %if x's are equal than smaller y comes first
        beam_coords = beam_centerline_array{i};
        [~, sort_index] = sort(beam_coords(2, :));
        beam_coords = beam_coords(:,sort_index); 
    else %else smaller x comes first
        beam_coords = beam_centerline_array{i};
        [~, sort_index] = sort(beam_coords(1, :));
        beam_coords = beam_coords(:,sort_index); 
    end
    
    lengths = linspace(0, norm(beam_coords(:,2) - beam_coords(:,1)),  no_of_elements+1);
    theta = atand( (beam_coords(2,2)-beam_coords(2,1)) / (beam_coords(1,2)-beam_coords(1,1)) );
    node_x = lengths*cosd(theta) + beam_coords(1,1);
    node_y = lengths*sind(theta) + beam_coords(2,1);

    beam_centerline_array_divided{i}(1,:) = node_x;
    beam_centerline_array_divided{i}(2,:) = node_y;
end

%% Visualizing the corresponding mesh
figure(3)
hold on

% color for the mesh elements
color_temp= 1/256;
color= [203*color_temp, 214*color_temp , 255*color_temp];

for i= 1:length(beam_centerline_array)

    % rotation of the centerline:
    centerline_rotation = atand( (beam_centerline_array{i}(2,2)-beam_centerline_array{i}(2,1))/ (beam_centerline_array{i}(1,2)-beam_centerline_array{i}(1,1)) );

    for k= 1:(length(beam_centerline_array_divided{i})-1)

        x_centerline = [beam_centerline_array_divided{i}(1,k) beam_centerline_array_divided{i}(1,k) beam_centerline_array_divided{i}(1,k+1) beam_centerline_array_divided{i}(1,k+1)];
        y_centerline = [beam_centerline_array_divided{i}(2,k) beam_centerline_array_divided{i}(2,k) beam_centerline_array_divided{i}(2,k+1) beam_centerline_array_divided{i}(2,k+1)];
        z_centerline = [0 0 0 0]; % beams are assumed to be straight in x-y plane
        
        for j= 1:length(crossection_member_array)
        
            x_patch_start = [x_centerline(1)-(sind(centerline_rotation)*(crossection_member_array{j}(2,1)-y_centroid)) , x_centerline(2)-(sind(centerline_rotation)*(crossection_member_array{j}(2,2)-y_centroid))];
            x_patch_end = [x_centerline(3)-(sind(centerline_rotation)*(crossection_member_array{j}(2,2)-y_centroid)) , x_centerline(4)-(sind(centerline_rotation)*(crossection_member_array{j}(2,1)-y_centroid))];

            y_patch_start = [y_centerline(1)+(cosd(centerline_rotation)*(crossection_member_array{j}(2,1)-y_centroid)) , y_centerline(2)+(cosd(centerline_rotation)*(crossection_member_array{j}(2,2)-y_centroid))];
            y_patch_end = [y_centerline(3)+(cosd(centerline_rotation)*(crossection_member_array{j}(2,2)-y_centroid)) , y_centerline(4)+(cosd(centerline_rotation)*(crossection_member_array{j}(2,1)-y_centroid))];
                   
            z_patch_start = -1*[z_centerline(1)+crossection_member_array{j}(1,1), z_centerline(2)+crossection_member_array{j}(1,2)];
            z_patch_end = -1*[z_centerline(3)+crossection_member_array{j}(1,2), z_centerline(4)+crossection_member_array{j}(1,1)];        
            
            patch([x_patch_start x_patch_end], [z_patch_start z_patch_end], [y_patch_start y_patch_end], color);
        end
    end
    % last 2 patches to close front and back surfaces
    x_last_start = beam_centerline_array{i}(1,1) -1*sind(centerline_rotation) * (Crossection_coords_in_order(2,:) -y_centroid);
    y_last_start = beam_centerline_array{i}(2,1) + cosd(centerline_rotation) * (Crossection_coords_in_order(2,:) -y_centroid);
    z_last_start = -1*(beam_centerline_array{i}(3,1) + Crossection_coords_in_order(1,:));
    patch(x_last_start,z_last_start,y_last_start, color)

    x_last_end = beam_centerline_array{i}(1,end) -1*sind(centerline_rotation) * (Crossection_coords_in_order(2,:) -y_centroid);
    y_last_end = beam_centerline_array{i}(2,end) + cosd(centerline_rotation) * (Crossection_coords_in_order(2,:) -y_centroid);
    z_last_end = -1*(beam_centerline_array{i}(3,end) + Crossection_coords_in_order(1,:));
    patch(x_last_end,z_last_end,y_last_end, color)
end

%plot properties
x_limits= xlim;
y_limits= zlim;
z_limits= ylim;
x_limit_range= abs(x_limits(2)-x_limits(1));
y_limit_range= abs(y_limits(2)-y_limits(1));

if x_limit_range >= y_limit_range

    range= x_limit_range - y_limit_range;
    zlim([y_limits(1)-range/2 y_limits(2)+range/2]) % global y axis limits
else
    range= y_limit_range - x_limit_range;
    xlim([x_limits(1)-range/2 x_limits(2)+range/2]) % global x axis limits
end

ylim([z_limits(1)-abs(x_limit_range)/3 z_limits(2)+abs(x_limit_range)/3]) %global z axis limits
daspect([1 1 1])
view(45,25)
xlabel('X [m]');
ylabel('Z [m]');
zlabel('Y [m]');
ax = gca;
ax.YDir = 'reverse';
title('Meshed Geometry')

%% Numbering the nodes and constructing element array

% hardcoding this for same number of elements in each beam/frame member for now.
all_nodes = zeros(2,(no_of_elements+1)*length(beam_centerline_array_divided));
n= 1;
m= no_of_elements+1;

tolerance = 1e-8;  
for i= 1:length(beam_centerline_array_divided)
    % rounding all nodes to avoid floting point precision problems
    beam_centerline_array_divided{i}= round(beam_centerline_array_divided{i} / tolerance)* tolerance;
    all_nodes(:,n:m)= beam_centerline_array_divided{i};
    n= n+no_of_elements+1;
    m= m+no_of_elements+1;
end

[unique_nodes, ~, node_map]= unique(all_nodes', 'rows');
all_nodes_numbered= [all_nodes ;node_map'];
no_of_unique_nodes= size(unique_nodes,1);

% adding node numbers to the beam_centerline_array_divided cell array
n= 1;
m= no_of_elements+1;
for i= 1:length(beam_centerline_array_divided)
    % rounding all nodes to avoid floting point precision problems
    beam_centerline_array_divided{i}(3,:)= all_nodes_numbered(3,n:m);
    n= n+no_of_elements+1;
    m= m+no_of_elements+1;
end

% constructing elements cell array containing coordinates of each element and its number
all_elements_array_numbered = cell(1,(no_of_elements)*length(beam_centerline_array_divided));
k = 1;
h = 1;

for i= 1:length(beam_centerline_array_divided)
    for j=1:no_of_elements

        all_elements_array_numbered{k} = all_nodes_numbered(:,h:h+1);
        k= k+1;
        h= h+1;
    end
    h= h+1; % this is to skip duplucate node (end node of one member is start node of the other member)
end

end