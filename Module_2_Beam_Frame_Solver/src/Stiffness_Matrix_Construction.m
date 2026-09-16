function [K_global] = Stiffness_Matrix_Construction(all_elements_array_numbered, no_of_unique_nodes, Area, Iz, E)
%STIFFNESS_MATRIX_CONSTRUCTION Constructs the global stiffness matrix.
%
%   INPUT:
%       all_elements_array_numbered - Array containing the FEM elements
%                                     and their corresponding node
%                                     numbers.
%       no_of_unique_nodes          - Total number of unique nodes in
%                                     the FEM mesh.
%       Area                        - Cross-sectional area of the
%                                     beam/frame members.
%       Iz                          - Second moment of area of the
%                                     cross-section about the global z-axis.
%       E                           - Young's modulus of the material.
%
%   OUTPUT:
%       K_global                    - Global stiffness matrix of the
%                                     beam/frame structure.
%
%   The function constructs the local stiffness matrix for each
%   Euler-Bernoulli beam/frame element, transforms it into the global
%   coordinate system, and assembles the element matrices into the
%   global stiffness matrix.

% Using bar-beam elements
DOF= 3;

% Sorting node numbers of each element for transformation matrix calculations
all_elements_array_ordered= cell(1,length(all_elements_array_numbered));

for i = 1:length(all_elements_array_numbered)
    [~, idx] = sort(all_elements_array_numbered{i}(3,:));
    all_elements_array_ordered{i} = all_elements_array_numbered{i}(:,idx);
end

% initializing the global stiffness matrix in sparse form to save memory
K_global = sparse(zeros(no_of_unique_nodes*DOF));

for i= 1:length(all_elements_array_ordered)
    
    x1= all_elements_array_ordered{i}(1,1);
    x2= all_elements_array_ordered{i}(1,2);
    y1= all_elements_array_ordered{i}(2,1);
    y2= all_elements_array_ordered{i}(2,2);
    n1= all_elements_array_ordered{i}(3,1); % first node number of the element
    n2= all_elements_array_ordered{i}(3,2); % second node number of the element

    theta= atand((y2-y1) / (x2-x1)); % angle of the element w.r.t global x-y
    L= sqrt((y2-y1)^2 + (x2-x1)^2); % length of the element
    
    % transformation for between local and global coordinates:
    transformation_matrix = [ cosd(theta) sind(theta) 0 0 0 0;
                             -sind(theta) cosd(theta) 0 0 0 0;
                             0 0 1 0 0 0;
                             0 0 0 cosd(theta) sind(theta) 0;
                             0 0 0 -sind(theta) cosd(theta) 0;
                             0 0 0 0 0 1];

    % stiffnes matrix of an element in local coords.:
    a1= E * Area / L;
    a2= E * Iz / L^3;
    
    K_element_local= [ a1 0 0 -a1 0 0;
                 0 12*a2 6*L*a2 0 -12*a2 6*L*a2;
                 0 6*L*a2 4*L^2*a2 0 -6*L*a2 2*L^2*a2;
                 -a1 0 0 a1 0 0;
                 0 -12*a2 -6*L*a2 0 12*a2 -6*L*a2;
                 0 6*L*a2 2*L^2*a2 0 -6*L*a2 4*L^2*a2];
    
    % stiffness matrix of an element in global coords.:
    K_element_global= transformation_matrix' * K_element_local * transformation_matrix;

    % the indices needed to add element stiffness matrices to global stiffness matrix:
    node_place = [(n1*DOF - 2) (n1*DOF - 1) (n1*DOF) (n2*DOF - 2) (n2*DOF - 1) (n2*DOF)];
    
    % Assembling global stiffness matrix:
    K_global(node_place,node_place) = K_global(node_place,node_place) + K_element_global; 
end

end