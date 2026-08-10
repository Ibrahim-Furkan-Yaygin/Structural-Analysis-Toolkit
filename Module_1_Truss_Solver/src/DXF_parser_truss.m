function [truss_member_array_unique] = DXF_parser_truss(filename, unit_convert)

%DXF_PARSER Imports a 2D truss geometry from a DXF file into MATLAB.
%   The function reads the geometry of a truss structure exported from a
%   CAD program in DXF format and converts it into a truss member cell
%   array.
%
%   Each cell corresponds to one truss member and contains the coordinates
%   of its two end nodes in the following format:
%
%       [x1  x2
%        y1  y2
%        z1  z2]
%
%   The function supports LINE and POLYLINE entities.
%   (Note that LWPOLYLINE entities are planned be supported in later versions)
%
%   Inputs:
%       filename      - Name or path of the DXF file to be imported.
%       unit_convert  - Unit conversion constant
%
%   Outputs:
%       truss_member_array_unique  - Cell array containing the coordinates of each
%                                    imported truss member.

%% Collecting the node coordinates from .dxt files

dxf_file = fopen(filename, 'r'); % here 'r' is the permission type for dfx file format reading

if dxf_file == -1
    error('Unable to open .dxf file. Check the name or the location of the file.')
end

a= 1; %loop variable for closed polylines
aa= 1; %loop variable for closed polylines array row
b= 1; %loop variable for open polylines
bb= 1; %loop variable for open polylines array row
cc= 1; %loop variabes for line array row

xyz_array= {[];[];[]}; % preallocating array for x,y and z coordinates for plotting section

while ~feof(dxf_file) %checking if the end of the file is reached after a previous operation

dxf_line = fgetl(dxf_file); %reading dxf file line by line and storing it in dxf_file variable
    
    if strcmp(dxf_line, 'POLYLINE') %if the reading is at 'POLYLINE' in .dxf file
        
        for z= 1:19 % skipping the lines in the .dxf file till the code that determines whether the polyline is closed or open                
            dxf_line = fgetl(dxf_file); %checking if the polyline is stored as a closed loop or not
        end
            
        closed_ring_check = strtrim(dxf_line);

        if closed_ring_check == '70' %condition when the polyline is a closed loop

            while ~strcmp(dxf_line, 'SEQEND')

                dxf_line = fgetl(dxf_file);

                if strcmp(dxf_line, 'AcDb2dVertex') % obtaining node points of the polylines in closed loop

                    fgetl(dxf_file); %ignoring the line '10' in .dxf file
                    x_closed = str2double(fgetl(dxf_file)); % x coordinate of the polyline node
                    fgetl(dxf_file); %ignoring the line '20' in .dxf file
                    y_closed = str2double(fgetl(dxf_file)); % y coordinate of the polyline node
                    fgetl(dxf_file); %ignoring the line '30' in .dxf file
                    z_closed = str2double(fgetl(dxf_file)); % z coordinate of the polyline node
                    
                    xyz_matrix_closed(:,a)= [x_closed;y_closed;z_closed]; 
                    a=a+1;
                end
            end
            
            xyz_array{1,aa}= xyz_matrix_closed/unit_convert; %1st row of this array stores closed loop polyline nodes in each element
            aa= aa+1;
            a=1;

        else % Condition when the polyline is a open loop
            
            while ~strcmp(dxf_line, 'SEQEND')

                dxf_line = fgetl(dxf_file);

                if length(dxf_line) == length('AcDb2dVertex') % obtaining node points of polylines in open loop

                    fgetl(dxf_file); %ignoring the line '10' in .dxf file
                    x_open = str2double(fgetl(dxf_file)); % x coordinate of the polyline node
                    fgetl(dxf_file); %ignoring the line '20' in .dxf file
                    y_open = str2double(fgetl(dxf_file)); % y coordinate of the polyline node
                    fgetl(dxf_file); %ignoring the line '30' in .dxf file
                    z_open = str2double(fgetl(dxf_file)); % z coordinate of the polyline node

                    xyz_matrix_open(:,b)= [x_open;y_open;z_open]; 
                    b=b+1;
                end
            end
            xyz_array{2,bb}= xyz_matrix_open/unit_convert; % 2nd row of this array stores open loop polyline nodes in each element
            bb= bb+1;
            b=1;            
        end

    elseif strcmp(dxf_line, 'AcDbLine') %if the reading is at 'AcDbLine' in .dxf file which means the CAD exported that part of the truss as LINE
        
        fgetl(dxf_file); %ignoring the line '10' in .dxf file
        x_line1 = str2double(fgetl(dxf_file)); % x coordinate of the line at starting node
        fgetl(dxf_file); %ignoring the line '20' in .dxf file
        y_line1 = str2double(fgetl(dxf_file)); % y coordinate of the line at starting node
        fgetl(dxf_file); %ignoring the line '30' in .dxf file
        z_line1 = str2double(fgetl(dxf_file)); % z coordinate of the line at starting node
        fgetl(dxf_file); %ignoring the line '11' in .dxf file
        x_line2 = str2double(fgetl(dxf_file)); % x coordinate of the line at starting node        
        fgetl(dxf_file); %ignoring the line '21' in .dxf file
        y_line2 = str2double(fgetl(dxf_file)); % y coordinate of the line at starting node
        fgetl(dxf_file); %ignoring the line '31' in .dxf file
        z_line2 = str2double(fgetl(dxf_file)); % z coordinate of the line at starting node

        xyz_matrix_line = [x_line1, x_line2; y_line1, y_line2; z_line1, z_line2];

        xyz_array{3,cc} = xyz_matrix_line/unit_convert; % 3rd row of this array stores node points of lines
        cc= cc+1;

    elseif strcmp(dxf_line, 'LWPOLYLINE ') %if the CAD sofware you are using exports .dxf using LWPOLYLINE format
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %This format is not supported at the moment%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

%% Element deduplication

% here an array is built to store each truss member nodes.
% every element in these arrays corresponds to start and end nodes of a
% truss member in x, y and z coordinates.

% array for the truss members from closed polyline entities from .dxt file
ee= 1; % loop variable for the array

if isempty(xyz_array{1,1})

member_array_polyline_closed = {};

else
    for e= 1:size(xyz_array,2)
        if ~isempty(xyz_array{1,e})

            member_matrix_polyline_closed= xyz_array{1,e};

            for f= 1: size(xyz_array{1,e},2) - 1

                member_array_polyline_closed{ee} = member_matrix_polyline_closed(1:3,f:f+1);
                ee= ee+1;
            end

            member_array_polyline_closed{ee} = [member_matrix_polyline_closed(1:3, 1) member_matrix_polyline_closed(1:3, f+1)];
            ee= ee+1;
        end
    end
end

% array for the truss members from open polyline entities from .dxt file
ee= 1; % loop variable for the array

if isempty(xyz_array{2,1})
    
member_array_polyline_open = {};

else 
    for e= 1:size(xyz_array,2)
        if ~isempty(xyz_array{2,e})

            member_matrix_polyline_open= xyz_array{2,e};

            for f= 1: size(xyz_array{2,e},2) - 1

                member_array_polyline_open{ee} = member_matrix_polyline_open(1:3,f:f+1);
                ee= ee+1;
            end
        end
    end
end

% array for the truss members from LINE entities from .dxt file
ee= 1;%loop variable for the array

if isempty(xyz_array{3,1})

member_array_line= {};

else
    for e= 1:size(xyz_array,2)

        if ~isempty(xyz_array{3,e})
            member_array_line{e} = xyz_array{3,e};
            e=e+1;
        end
    end
end

% Constructing the final truss member array
truss_member_array= [member_array_polyline_closed member_array_polyline_open member_array_line];

% deduplucation of the members:
% 1- transforming the array matrices into flat row vectors and finding unique vectors
%   1.1- Here rows of each element are sorted from smaller to bigger before flattening to
%        filter out the members that could have start and end points swapped
% 2- transform the unique row vectors back to array format

truss_member_array_sorted = cellfun(@(x) sort(x,2), truss_member_array, 'UniformOutput', false);
truss_member_array_flat= cellfun(@(x) reshape(x,1,[]), truss_member_array_sorted, 'UniformOutput', false);
truss_member_array_flat = vertcat(truss_member_array_flat{:});
[~, idx] = unique(truss_member_array_flat, 'rows', 'stable');
truss_member_array_unique = truss_member_array(idx);