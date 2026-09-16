function [] = Plot_Beam(beam_centerline_array, crossection_member_array, y_centroid, Crossection_coords_in_order)
%PLOT_BEAM Creates a 3D visualization of the beam/frame geometry.
%
%   INPUT:
%       beam_centerline_array       - Cell array containing the X-Y
%                                     coordinates of the beam/frame
%                                     centerlines.
%       crossection_member_array    - Cell array containing the
%                                     cross-section coordinates
%                                     associated with each member.
%       y_centroid                  - Y-coordinate of the cross-section
%                                     centroid.
%       Crossection_coords_in_order - Cross-section vertex coordinates
%                                     arranged in the correct order.
%
%   The function creates a 3D representation of the beam/frame structure
%   by extruding the cross-section along the beam centerlines. The
%   cross-section is positioned so that the beam centerline passes through
%   its centroid and is rotated according to the orientation of each
%   beam/frame member.
%
%   The generated geometry is plotted for visual verification of the
%   imported beam/frame and cross-section geometry.

figure(2)
hold on

% color for the geometry
color_temp= 1/256;
color= [170*color_temp, 218*color_temp , 250*color_temp];

for i= 1:length(beam_centerline_array)

    x_centerline = [beam_centerline_array{i}(1,1) beam_centerline_array{i}(1,1) beam_centerline_array{i}(1,2) beam_centerline_array{i}(1,2)];
    y_centerline = [beam_centerline_array{i}(2,1) beam_centerline_array{i}(2,1) beam_centerline_array{i}(2,2) beam_centerline_array{i}(2,2)];
    z_centerline = [beam_centerline_array{i}(3,1) beam_centerline_array{i}(3,1) beam_centerline_array{i}(3,2) beam_centerline_array{i}(3,2)];

    % rotation of the centerline:
    centerline_rotation = atand( (beam_centerline_array{i}(2,2)-beam_centerline_array{i}(2,1))/ (beam_centerline_array{i}(1,2)-beam_centerline_array{i}(1,1)) );

    for j= 1:length(crossection_member_array)
    
        x_patch_start = [x_centerline(1)-(sind(centerline_rotation)*(crossection_member_array{j}(2,1)-y_centroid)) , x_centerline(2)-(sind(centerline_rotation)*(crossection_member_array{j}(2,2)-y_centroid))];
        x_patch_end = [x_centerline(3)-(sind(centerline_rotation)*(crossection_member_array{j}(2,2)-y_centroid)) , x_centerline(4)-(sind(centerline_rotation)*(crossection_member_array{j}(2,1)-y_centroid))];

        y_patch_start = [y_centerline(1)+(cosd(centerline_rotation)*(crossection_member_array{j}(2,1)-y_centroid)) , y_centerline(2)+(cosd(centerline_rotation)*(crossection_member_array{j}(2,2)-y_centroid))];
        y_patch_end = [y_centerline(3)+(cosd(centerline_rotation)*(crossection_member_array{j}(2,2)-y_centroid)) , y_centerline(4)+(cosd(centerline_rotation)*(crossection_member_array{j}(2,1)-y_centroid))];
               
        z_patch_start = -1*[z_centerline(1)+crossection_member_array{j}(1,1), z_centerline(2)+crossection_member_array{j}(1,2)];
        z_patch_end = -1*[z_centerline(3)+crossection_member_array{j}(1,2), z_centerline(4)+crossection_member_array{j}(1,1)];        
        
        patch([x_patch_start x_patch_end], [z_patch_start z_patch_end], [y_patch_start y_patch_end], color);
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
title('Imported Geometry')

end