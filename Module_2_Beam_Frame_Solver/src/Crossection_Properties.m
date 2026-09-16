function [Iy_centroid, Ix_centroid, Ixy_centroid, crossection_area, y_centroid, crossection_member_array, Crossection_coords_in_order] = Crossection_Properties(crossection_member_array_numbered)
%CROSSECTION_PROPERTIES Calculates the geometric properties of the cross-section
%   and plots the imported cross-section.
%
%   INPUT:
%       crossection_member_array_numbered - Cell array containing the
%                                           imported cross-section
%                                           coordinates and member
%                                           numbering information.
%
%   OUTPUT:
%       Iy_centroid              - Second moment of area about the
%                                  centroidal y-axis.
%       Ix_centroid              - Second moment of area about the
%                                  centroidal x-axis.
%       Ixy_centroid             - Product of inertia about the
%                                  centroidal axes.
%       crossection_area         - Cross-sectional area.
%       y_centroid               - Local Y-coordinate of the cross-section
%                                  centroid.
%       crossection_member_array    - Processed cross-section data used
%                                     for the beam/frame model.
%       Crossection_coords_in_order - Cross-section vertex coordinates
%                                     arranged in the correct order.

%% Creating a polygon of the crossection
% initializing vectors
x_poly = zeros(1,length(crossection_member_array_numbered));
y_poly = zeros(1,length(crossection_member_array_numbered));
node_number = zeros(1,length(crossection_member_array_numbered));

x_poly(1) = crossection_member_array_numbered{1}(1,1);
y_poly(1) = crossection_member_array_numbered{1}(2,1);
node_number(1) = crossection_member_array_numbered{1}(3,1);
x_poly(2) = crossection_member_array_numbered{1}(1,2);
y_poly(2) = crossection_member_array_numbered{1}(2,2);
node_number(2) = crossection_member_array_numbered{1}(3,2);

crossection_member_array_numbered{1} = [];

loop_check= 0;
j= 3;

while loop_check == 0
    
if node_number(end) == node_number(1)        
    break
end

    for i= 2:length(crossection_member_array_numbered)

        if isempty(crossection_member_array_numbered{i}) == 1

            % do nothing
        else
            
            node_check1= crossection_member_array_numbered{i}(3,1);
            node_check2= crossection_member_array_numbered{i}(3,2);
   
            if node_number(j-1) == node_check1
                
                x_poly(j) = crossection_member_array_numbered{i}(1,2);
                y_poly(j) = crossection_member_array_numbered{i}(2,2);
                node_number(j)= crossection_member_array_numbered{i}(3,2);
                crossection_member_array_numbered{i} = [];
                break

            elseif  node_number(j-1) == node_check2
                
                x_poly(j) = crossection_member_array_numbered{i}(1,1);
                y_poly(j) = crossection_member_array_numbered{i}(2,1);
                node_number(j)= crossection_member_array_numbered{i}(3,1);
                crossection_member_array_numbered{i} = [];
                break
            end
        end
    end
    j= j+1;
end

figure(1)
crossection_polygon = polyshape(x_poly,y_poly);
% moving CAD coordinates to positive quadrant
crossection_polygon.Vertices(:,1) = crossection_polygon.Vertices(:,1) - min(crossection_polygon.Vertices(:,1));
crossection_polygon.Vertices(:,2) = crossection_polygon.Vertices(:,2) - min(crossection_polygon.Vertices(:,2));
plot(crossection_polygon)
title('Imported Cross Section')
xlabel('Local X [m]')
ylabel('Local Y [m]')
axis equal

Crossection_coords_in_order = crossection_polygon.Vertices; % crossection vertices in clockwise order
Crossection_coords_in_order = Crossection_coords_in_order'; % making first row x values and second row y values

% redefining crossection_member_array with the polygon coords because the
% polyshape function automatically removes intermidate vertices along a line
crossection_member_array= cell(1,size(Crossection_coords_in_order,2));
for i=1:(size(Crossection_coords_in_order,2) - 1)

    crossection_member_array{i}(:,1:2) = Crossection_coords_in_order(:,i:i+1);
end
crossection_member_array{end}(:,1) = Crossection_coords_in_order(:,end);
crossection_member_array{end}(:,2) = Crossection_coords_in_order(:,1);

%% Calculating moment of inertia
Iy = 0;
Ix = 0;
Ixy = 0;

x_poly= Crossection_coords_in_order(1,:); % redefining these since we moved the crossection to positive quadrant
y_poly= Crossection_coords_in_order(2,:);

for i= 1:(length(x_poly) - 1)

    % note that last value of x_poly and y_poly is equal to their first value
    shoelace = (x_poly(i)*y_poly(i+1) - x_poly(i+1)*y_poly(i)); 

    Iy = Iy + shoelace * (x_poly(i)^2 + x_poly(i)*x_poly(i+1) + x_poly(i+1)^2);
    Ix = Ix + shoelace * (y_poly(i)^2 + y_poly(i)*y_poly(i+1) + y_poly(i+1)^2);
    Ixy = Ixy + shoelace * (x_poly(i)*y_poly(i+1) + 2*x_poly(i)*y_poly(i) + 2*x_poly(i+1)*y_poly(i+1) + x_poly(i+1)*y_poly(i));
end

% taking absolute values becase if the polygon vertices are not arranged in counter-clockwise fashion, 
% the moment of area results will be in negative due to the assumption of the above formulas

% Moment of area values with respect to local x-y axis
Iy = abs(Iy)/12; % these values are in m^4
Ix = abs(Ix)/12;
Ixy = abs(Ixy)/24;

% Now using parallel axis theorem to find centroidal values
crossection_area = area(crossection_polygon);
[x_centroid, y_centroid] = centroid(crossection_polygon);

Iy_centroid = Iy - crossection_area * x_centroid^2;
Ix_centroid = Ix - crossection_area * y_centroid^2;
Ixy_centroid = Ixy - crossection_area * x_centroid*y_centroid;

end