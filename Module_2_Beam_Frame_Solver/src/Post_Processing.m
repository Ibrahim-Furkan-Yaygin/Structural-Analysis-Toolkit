function [beam_moment_distribution, beam_shear_distribution, beam_axial_distribution] = Post_Processing(E, Iz, Area, y_centroid, U_global, beam_centerline_array_divided, beam_centerline_array, all_elements_array_numbered, crossection_member_array, Crossection_coords_in_order)
%POST_PROCESSING Calculates internal force distributions and plots FEM results.
%
%   INPUT:
%       E                          - Young's modulus of the material.
%       Iz                         - Second moment of area of the
%                                    cross-section used for bending.
%       Area                       - Cross-sectional area of the
%                                    beam/frame members.
%       y_centroid                 - Y-coordinate of the cross-section
%                                    centroid.
%       U_global                   - Global displacement vector
%                                    containing nodal translations and
%                                    rotations.
%       beam_centerline_array_divided - Cell array containing the
%                                        meshed beam/frame centerlines
%                                        and their node information.
%       beam_centerline_array       - Cell array containing the original
%                                     beam/frame centerline coordinates.
%       all_elements_array_numbered - Array containing the FEM elements
%                                     and their corresponding node
%                                     numbers.
%       crossection_member_array    - Cell array containing the
%                                     cross-section information for
%                                     each beam/frame member.
%       Crossection_coords_in_order - Cross-section vertex coordinates
%                                     arranged in the correct order.
%
%   OUTPUT:
%       beam_moment_distribution   - Bending moment distribution for
%                                    the beam/frame elements.
%       beam_shear_distribution    - Shear force distribution for the
%                                    beam/frame elements.
%       beam_axial_distribution    - Axial force distribution for the
%                                    beam/frame elements.
%
%   The function calculates the bending moment, shear force, and axial
%   force distributions using the FEM displacement results. It also
%   plots the internal force diagrams and the deformed structure with
%   the corresponding displacement contour.

%% Axial, Shear and Moment distributions along beam members
DOF = 3;
beam_moment_distribution = cell(1,length(beam_centerline_array_divided));
beam_shear_distribution = cell(1,length(beam_centerline_array_divided));
beam_axial_distribution = cell(1,length(beam_centerline_array_divided));

for i=1:length(beam_centerline_array_divided)
    k= 1;
    for j= 1:(size(beam_centerline_array_divided{i},2)-1)

        element_coords = beam_centerline_array_divided{i}(:,j:j+1);
        [~, index]= sort(element_coords(3,:)); % sorting the element coords w.r.t its node number for correct rotation angle calculation
        element_coords = element_coords(:,index);

        x1= element_coords(1,1); % coords of the element
        x2= element_coords(1,2);
        y1= element_coords(2,1);
        y2= element_coords(2,2);
        node1 = element_coords(3,1);
        node2 = element_coords(3,2);

        theta= atand( (y2-y1) / (x2-x1) ); % rotation of the element w.r.t global x-y
        L= norm(element_coords(1:2,1) - element_coords(1:2,2)); % length of the element

        transformation_matrix = [cosd(theta) sind(theta) 0 0 0 0;
                                 -sind(theta) cosd(theta) 0 0 0 0;
                                 0 0 1 0 0 0;
                                 0 0 0 cosd(theta) sind(theta) 0;
                                 0 0 0 -sind(theta) cosd(theta) 0;
                                 0 0 0 0 0 1];

        U_local= transformation_matrix* U_global([node1*DOF-2 node1*DOF-1 node1*DOF node2*DOF-2 node2*DOF-1 node2*DOF]);

        % Moment distribution
        x= 0;
        B = [(-6/L^2 + 12*x/L^3) (-4/L + 6*x/L^2) (6/L^2 - 12*x/L^3) (-2/L + 6*x/L^2)]; % strain displacement matrix B
        beam_moment_distribution{i}(k) = E * Iz * B * [U_local(2) U_local(3) U_local(5) U_local(6)]';
        x= L;
        B = [(-6/L^2 + 12*x/L^3) (-4/L + 6*x/L^2) (6/L^2 - 12*x/L^3) (-2/L + 6*x/L^2)]; % strain displacement matrix B
        beam_moment_distribution{i}(k+1) = E * Iz * B * [U_local(2) U_local(3) U_local(5) U_local(6)]';

        % Shear Force Distribution
        B_shear = [12/L^3 6/L^2 -12/L^3 6/L^2];
        beam_shear_distribution{i}(k) = E * Iz * B_shear * [U_local(2) U_local(3) U_local(5) U_local(6)]'; % first nodal value of element
        beam_shear_distribution{i}(k+1) = beam_shear_distribution{i}(k); % second nodal value of element

        % Axial Force Distribution
        beam_axial_distribution{i}(k) = E * Area / L * (U_local(4) - U_local(1));
        beam_axial_distribution{i}(k+1) =beam_axial_distribution{i}(k) ;

        k= k+2;
    end
    % getting rid of numerical noise
    beam_moment_distribution{i}(abs(beam_moment_distribution{i}(:)) < 1e-5) = 0;
    beam_shear_distribution{i}(abs(beam_shear_distribution{i}(:)) < 1e-5) = 0;
    beam_axial_distribution{i}(abs(beam_axial_distribution{i}(:)) < 1e-5) = 0;
end

%% Plotting the moment, shear and axial force distributions over beam members

% Constructing autoscale for the plots plot
length_beams= zeros(1,length(beam_centerline_array));
for i=1:length(beam_centerline_array)
    length_beams(i)= norm(beam_centerline_array{i}(1:2,1) - beam_centerline_array{i}(1:2,2));
end
%scale for distribution plot
scale_moment= 0.15*mean(length_beams);
scale_shear_axial = 0.1*mean(length_beams);

% Calculating the positions of the distribution lines
moment_location = cell(1,length(beam_centerline_array_divided));
shear_location = cell(1,length(beam_centerline_array_divided));
axial_location = cell(1,length(beam_centerline_array_divided));

for i=1:length(beam_centerline_array_divided)

    moment_normalized = beam_moment_distribution{i}/max(abs(beam_moment_distribution{i})) * scale_moment;
    shear_normalized = beam_shear_distribution{i}/max(abs(beam_shear_distribution{i})) * scale_shear_axial;
    axial_normalized = beam_axial_distribution{i}/max(abs(beam_axial_distribution{i})) * scale_shear_axial;

    theta= atand((beam_centerline_array_divided{i}(2,2)-beam_centerline_array_divided{i}(2,1))/(beam_centerline_array_divided{i}(1,2)-beam_centerline_array_divided{i}(1,1)));

    transformation = [cosd(theta) -sind(theta);
                      sind(theta)  cosd(theta)];
    k= 1;
    for j= 1:(size(beam_centerline_array_divided{i},2)-1)
        
        x_node1= beam_centerline_array_divided{i}(1,j);
        y_node1= beam_centerline_array_divided{i}(2,j);
        x_node2= beam_centerline_array_divided{i}(1,j+1);
        y_node2= beam_centerline_array_divided{i}(2,j+1);

        moment_location{i}(:,k)= [x_node1; y_node1] + transformation * [0 ; -moment_normalized(k)];
        moment_location{i}(:,k+1)= [x_node2; y_node2] + transformation * [0 ; -moment_normalized(k+1)];

        shear_location{i}(:,k)= [x_node1; y_node1] + transformation * [0 ; -shear_normalized(k)];
        shear_location{i}(:,k+1)= [x_node2; y_node2] + transformation * [0 ; -shear_normalized(k+1)];
        
        axial_location{i}(:,k)= [x_node1; y_node1] + transformation * [0 ; -axial_normalized(k)];
        axial_location{i}(:,k+1)= [x_node2; y_node2] + transformation * [0 ; -axial_normalized(k+1)];

        k= k+2;
    end
end

% plotting the figures
fig1 = figure(5); % used in moment distribution
ax1 = axes('Parent', fig1);
hold(ax1, 'on');
title(ax1, 'Moment Distribution Diagram')

for i = 1:length(all_elements_array_numbered)
    x1 = all_elements_array_numbered{i}(1,1);
    x2 = all_elements_array_numbered{i}(1,2);
    y1 = all_elements_array_numbered{i}(2,1);
    y2 = all_elements_array_numbered{i}(2,2);
    structure = plot(ax1, [x1 x2], [y1 y2], '-', 'LineWidth', 4, 'Color', 'b');
    structure.Tag = 'Wireframe';
end

x_limits= xlim;
y_limits= ylim;
x_limit_range= x_limits(2)-x_limits(1);
y_limit_range= y_limits(2)-y_limits(1);
xlim([x_limits(1)-abs(x_limit_range)*0.20 x_limits(2)+abs(x_limit_range)*0.20])
ylim([y_limits(1)-abs(y_limit_range)*0.20 y_limits(2)+abs(y_limit_range)*0.20])
axis(ax1, 'equal');
xlabel('X [m]')
ylabel('Y [m]')

% Copying wireframe of the structure to not plot it again for every distribution plot
fig2 = figure(6); % used in shear distribution
ax2 = copyobj(ax1, fig2); 
title(ax2, 'Shear Force Distribution Diagram')

fig3 = figure(7); % used in shear distribution
ax3 = copyobj(ax1, fig3); 
title(ax3, 'Axial Force Distribution Diagram')

% Moment distribution diagram
for i = 1:length(moment_location)
    % using a patch to grey out areas between distribution lines and the structure
    x_moment= moment_location{i}(1,:);
    y_moment= moment_location{i}(2,:);
    x_beam= fliplr(beam_centerline_array_divided{i}(1,:));
    y_beam= fliplr(beam_centerline_array_divided{i}(2,:));
    patch(ax1, [x_moment x_beam], [y_moment y_beam], [0.851 0.851 0.851], 'LineStyle', 'none', 'HitTest', 'off')
    
    % moment distribution lines
    moment_plot = plot(ax1, moment_location{i}(1,:), moment_location{i}(2,:), '-r', 'LineWidth', 2);
    moment_plot.Tag = 'MomentDiagram';
    moment_plot.UserData = beam_moment_distribution{i};
end
uistack(findobj(ax1, 'Tag', 'Wireframe'), 'top'); % taking wireframe to the top layer to avoid line breaks due to patch
legend(ax1, moment_plot,'Moment Distribution','Location','eastoutside')
curser_click1 = datacursormode(fig1); % using a custom function to be able to see distribution values upon clicking on the diagram lines
set(curser_click1, 'Enable', 'on', 'UpdateFcn', @clickDataTip);

% Shear distribution diagram
for i = 1:length(shear_location)
    % using a patch to grey out areas between distribution lines and the structure
    x_shear= shear_location{i}(1,:);
    y_shear= shear_location{i}(2,:);
    x_beam= fliplr(beam_centerline_array_divided{i}(1,:));
    y_beam= fliplr(beam_centerline_array_divided{i}(2,:));
    patch(ax2, [x_shear x_beam], [y_shear y_beam], [0.851 0.851 0.851], 'LineStyle', 'none', 'HitTest', 'off')

    % shear distribution lines
    shear_plot = plot(ax2, shear_location{i}(1,:), shear_location{i}(2,:), '-r', 'LineWidth', 2);
    shear_plot.Tag = 'ShearDiagram';
    shear_plot.UserData = beam_shear_distribution{i};
end
uistack(findobj(ax2, 'Tag', 'Wireframe'), 'top'); % taking wireframe to the top layer to avoid line breaks due to patch
legend(ax2, shear_plot,'Shear Force Distribution','Location','eastoutside')
curser_click2 = datacursormode(fig2); 
set(curser_click2, 'Enable', 'on', 'UpdateFcn', @clickDataTip);

% Axial distribution diagram
for i = 1:length(axial_location)
    % using a patch to grey out areas between distribution lines and the structure
    x_axial= axial_location{i}(1,:);
    y_axial= axial_location{i}(2,:);
    x_beam= fliplr(beam_centerline_array_divided{i}(1,:));
    y_beam= fliplr(beam_centerline_array_divided{i}(2,:));
    patch(ax3, [x_axial x_beam], [y_axial y_beam], [0.851 0.851 0.851], 'LineStyle', 'none', 'HitTest', 'off')

    % axial distribution lines
    axial_plot = plot(ax3, axial_location{i}(1,:), axial_location{i}(2,:), '-r', 'LineWidth', 2);
    axial_plot.Tag = 'AxialForceDiagram';
    axial_plot.UserData = beam_axial_distribution{i};    
end
uistack(findobj(ax3, 'Tag', 'Wireframe'), 'top'); % taking wireframe to the top layer to avoid line breaks due to patch
legend(ax3, axial_plot,'Axial Force Distribution','Location','eastoutside')
curser_click3 = datacursormode(fig3); 
set(curser_click3, 'Enable', 'on', 'UpdateFcn', @clickDataTip);

%% Plotting the deformed structure
figure(8)
hold on

%scale for deformation plot
auto_scale = 0.15*mean(length_beams)*1/max(abs(U_global)); % autoscale is set such that the maximum displacement is scaled to look like 15% of the mean beam length

for i= 1:length(beam_centerline_array) % for every beam element (i) the loop is repeated

    % rotation of the centerline:
    centerline_rotation = atand( (beam_centerline_array{i}(2,2)-beam_centerline_array{i}(2,1))/ (beam_centerline_array{i}(1,2)-beam_centerline_array{i}(1,1)) );
    
    for k= 1:(size(beam_centerline_array_divided{i},2)-1) % k is the element number

        x_centerline = [beam_centerline_array_divided{i}(1,k) beam_centerline_array_divided{i}(1,k) beam_centerline_array_divided{i}(1,k+1) beam_centerline_array_divided{i}(1,k+1)];
        y_centerline = [beam_centerline_array_divided{i}(2,k) beam_centerline_array_divided{i}(2,k) beam_centerline_array_divided{i}(2,k+1) beam_centerline_array_divided{i}(2,k+1)];
        z_centerline = [0 0 0 0]; % beams are assumed to be straight in x-y plane
        
        node1= beam_centerline_array_divided{i}(3,k);
        node2= beam_centerline_array_divided{i}(3,k+1);

        nodal_rotation1= U_global(node1*DOF) * 360/(2*pi) * auto_scale;
        nodal_rotation2= U_global(node2*DOF) * 360/(2*pi) * auto_scale;

        for j= 1:length(crossection_member_array)
        
            x_patch_start = [x_centerline(1)-(sind(centerline_rotation+nodal_rotation1)*(crossection_member_array{j}(2,1)-y_centroid)) + U_global(node1*DOF-2)*auto_scale, x_centerline(2)-(sind(centerline_rotation+nodal_rotation1)*(crossection_member_array{j}(2,2)-y_centroid)) + U_global(node1*DOF-2)*auto_scale];
            x_patch_end = [x_centerline(3)-(sind(centerline_rotation+nodal_rotation2)*(crossection_member_array{j}(2,2)-y_centroid)) + U_global(node2*DOF-2)*auto_scale, x_centerline(4)-(sind(centerline_rotation+nodal_rotation2)*(crossection_member_array{j}(2,1)-y_centroid)) + U_global(node2*DOF-2)*auto_scale];
        
            y_patch_start = [y_centerline(1)+(cosd(centerline_rotation+nodal_rotation1)*(crossection_member_array{j}(2,1)-y_centroid)) + U_global(node1*DOF-1)*auto_scale, y_centerline(2)+(cosd(centerline_rotation+nodal_rotation1)*(crossection_member_array{j}(2,2)-y_centroid)) + U_global(node1*DOF-1)*auto_scale];
            y_patch_end = [y_centerline(3)+(cosd(centerline_rotation+nodal_rotation2)*(crossection_member_array{j}(2,2)-y_centroid)) + U_global(node2*DOF-1)*auto_scale, y_centerline(4)+(cosd(centerline_rotation+nodal_rotation2)*(crossection_member_array{j}(2,1)-y_centroid)) + U_global(node2*DOF-1)*auto_scale];
                   
            z_patch_start = -1*[z_centerline(1)+crossection_member_array{j}(1,1), z_centerline(2)+crossection_member_array{j}(1,2)];
            z_patch_end = -1*[z_centerline(3)+crossection_member_array{j}(1,2), z_centerline(4)+crossection_member_array{j}(1,1)];        
            
            color_patch_start = [sqrt(U_global(node1*DOF-2)^2 + U_global(node1*DOF-1)^2) sqrt(U_global(node1*DOF-2)^2 + U_global(node1*DOF-1)^2)];
            color_pacth_end = [sqrt(U_global(node2*DOF-2)^2 + U_global(node2*DOF-1)^2) sqrt(U_global(node2*DOF-2)^2 + U_global(node2*DOF-1)^2)];
           
            patch([x_patch_start x_patch_end], [z_patch_start z_patch_end], [y_patch_start y_patch_end], [color_patch_start color_pacth_end]);
        end
    end
    % last 2 patches to close front and back surfaces
    node_last_start = beam_centerline_array_divided{i}(3,1);
    node_last_end = beam_centerline_array_divided{i}(3,end);
    nodal_rotation_last_start = U_global(node_last_start*DOF) * 360/(2*pi) * auto_scale;
    nodal_rotation_last_end = U_global(node_last_end*DOF) * 360/(2*pi) * auto_scale;
    
    color_patch__last_start = sqrt(U_global(node_last_start*DOF-2)^2 + U_global(node_last_start*DOF-1)^2) * ones(1,size(Crossection_coords_in_order,2));
    color_patch__last_end = sqrt(U_global(node_last_end*DOF-2)^2 + U_global(node_last_end*DOF-1)^2) * ones(1,size(Crossection_coords_in_order,2));
    
    x_last_start = beam_centerline_array_divided{i}(1,1) -1*sind(centerline_rotation+nodal_rotation_last_start) * (Crossection_coords_in_order(2,:) -y_centroid) + U_global(node_last_start*DOF-2)*auto_scale;
    y_last_start = beam_centerline_array_divided{i}(2,1) + cosd(centerline_rotation+nodal_rotation_last_start) * (Crossection_coords_in_order(2,:) -y_centroid) + U_global(node_last_start*DOF-1)*auto_scale;
    z_last_start = -1*(beam_centerline_array{i}(3,1) + Crossection_coords_in_order(1,:));
    patch(x_last_start,z_last_start,y_last_start, color_patch__last_start)
    
    x_last_end = beam_centerline_array_divided{i}(1,end) -1*sind(centerline_rotation+nodal_rotation_last_end) * (Crossection_coords_in_order(2,:) -y_centroid) + U_global(node_last_end*DOF-2)*auto_scale;
    y_last_end = beam_centerline_array_divided{i}(2,end) + cosd(centerline_rotation+nodal_rotation_last_end) * (Crossection_coords_in_order(2,:) -y_centroid) + U_global(node_last_end*DOF-1)*auto_scale;
    z_last_end = -1*(beam_centerline_array{i}(3,end) + Crossection_coords_in_order(1,:));
    patch(x_last_end,z_last_end,y_last_end, color_patch__last_end)
end

%plot properties
colormap(jet);
colorbar
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
title("Total Deformation Contour (autoscale: " + num2str(round(auto_scale)) + "x)")
c_displacement= colorbar;
c_displacement.Label.FontSize = 16;
c_displacement.FontSize= 14;
c_displacement.Label.String = 'Displacement [m]';

end

function output_txt = clickDataTip(~, event_obj) % custom function for distribution data tips
    position = event_obj.Position;
    targetLine = event_obj.Target;
    
    if strcmp(targetLine.Tag, 'Wireframe') % if curser is at wireframe of the structure
        output_txt = {['X: ', num2str(position(1), '%.2f'), ' m'], ...
                      ['Y: ', num2str(position(2), '%.2f'), ' m']};
                  
    elseif strcmp(targetLine.Tag, 'MomentDiagram') && ~isempty(targetLine.UserData) % if curser is at the moment distribution diagram
        xData = targetLine.XData;
        realValues = targetLine.UserData;
        
        [~, idx] = min(abs(xData - position(1))); % Tıklanan X'e en yakın değeri bulur
        val = realValues(idx);
        
        output_txt = {['Moment: ', num2str(val, '%.2f'), ' Nm']};

    elseif strcmp(targetLine.Tag, 'ShearDiagram') && ~isempty(targetLine.UserData) % if curser is at the shear distribution diagram
        xData = targetLine.XData;
        realValues = targetLine.UserData;
        
        [~, idx] = min(abs(xData - position(1))); % Tıklanan X'e en yakın değeri bulur
        val = realValues(idx);
        
        output_txt = {['Shear Force: ', num2str(val, '%.2f'), ' N']};

    elseif strcmp(targetLine.Tag, 'AxialForceDiagram') && ~isempty(targetLine.UserData) % if curser is at the axial force distribution diagram
        xData = targetLine.XData;
        realValues = targetLine.UserData;
        
        [~, idx] = min(abs(xData - position(1))); % Tıklanan X'e en yakın değeri bulur
        val = realValues(idx);
        
        output_txt = {['Axial Force: ', num2str(val, '%.2f'), ' N']};

    else % Other
        
        output_txt = {['X: ', num2str(position(1), '%.2f')], ['Y: ', num2str(position(2), '%.2f')]};
    end
end