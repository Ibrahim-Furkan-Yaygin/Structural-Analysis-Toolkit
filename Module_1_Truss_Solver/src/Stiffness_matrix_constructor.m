function [K_global, l_m_array_global] = Stiffness_matrix_constructor(truss_member_array, no_of_unique_nodes, E, Area, DOF, Length_global)

%STIFFNESS_MATRIX_CONSTRUCTOR Constructs the global stiffness matrix.
%   The function constructs the global stiffness matrix of the truss
%   structure using the element geometry, material properties, cross-
%   sectional area, and degrees of freedom.
%
%   Direction cosines are calculated from the nodal coordinates and used
%   to construct and assemble the element stiffness matrices into the
%   global stiffness matrix.
%
%   The global stiffness matrix is stored as a sparse matrix to reduce
%   memory usage and improve computational efficiency.
%
%   Inputs:
%       truss_member_array  - Truss member coordinates and numbering
%       no_of_unique_nodes  - Total number of unique nodes
%       E                   - Young's modulus
%       Area                - Cross-sectional area
%       DOF                 - Degrees of freedom per node
%       Length_global       - Length of each truss member
%
%   Outputs:
%       K_global          - Global stiffness matrix
%       l_m_array_global  - Direction cosines of each element

for i = 1:length(truss_member_array)
    [~, idx] = sort(truss_member_array{i}(3,:));
    truss_member_array{i} = truss_member_array{i}(:,idx);
end

% constructing stiffness matrix of each element:
% initializing the global stiffness matrix in sparse form to save memory
K_global = sparse(zeros(no_of_unique_nodes*DOF));

% initializing the global direction cosines array
l_m_array_global{2,length(truss_member_array)}= []; 

for i= 1:length(truss_member_array)
    

    % here l and m are direction cosines costheta and sintheta respectively
    l= (truss_member_array{i}(1,2) - truss_member_array{i}(1,1)) / Length_global(i);
    m= (truss_member_array{i}(2,2) - truss_member_array{i}(2,1)) / Length_global(i);
        
    %Constructing global direction cosines for postprocessing purposes.
    %Each column of this array represents an element. First row of a column
    % contains the direction cosines (l and m) and the second row contains 
    % node numbers of for that perticular element.
    l_m_array_global{1,i}= [l,m];
    l_m_array_global{2,i}= truss_member_array{i}(3,:);
    

    % Stiffnes matrix of an element:
    K_element= E*Area / Length_global(i) * [l^2 , l*m , -l^2 , -l*m ;
                                      l*m , m^2 , -l*m , -m^2 ;
                                     -l^2 , -l*m , l^2 , l*m ;
                                     -l*m , -m^2 , l*m , m^2 ];
    
    % These are the indices needed to add element stiffness matrices to global stiffness matrix:
    node_place = [(truss_member_array{i}(3,1)*2 - 1) (truss_member_array{i}(3,1)*2) ...
                  (truss_member_array{i}(3,2)*2 - 1) (truss_member_array{i}(3,2)*2)];

    K_global(node_place,node_place) = K_global(node_place,node_place) + K_element; % Assembling global stiffness matrix
end

end