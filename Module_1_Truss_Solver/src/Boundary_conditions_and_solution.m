function [u_global, forces_global, BC_fixed_support_user, BC_x_support_user, BC_y_support_user, force_nodes]= Boundary_conditions_and_solution(no_of_unique_nodes, DOF, K_global)

%BOUNDARY_CONDITIONS_AND_SOLUTION Applies boundary conditions and solves the FE system.
%   The function prompts the user to define the support conditions and
%   external loads, applies the corresponding boundary conditions to the
%   global stiffness matrix and force vector, and solves the resulting
%   finite element system for nodal displacements.
%
%   The function also checks the reduced stiffness matrix for singularity
%   to identify incompatible boundary conditions before attempting to
%   solve the system.
%
%   Inputs:
%       no_of_unique_nodes  - Total number of nodes in the truss
%       DOF                 - Degrees of freedom per node
%       K_global            - Global stiffness matrix
%
%   Outputs:
%       u_global               - Global nodal displacement vector
%       forces_global          - Global force vector
%       BC_fixed_support_user  - Nodes where fixed support conditions are applied
%       BC_x_support_user      - Nodes where roller supports that constrain X-direction are applied
%       BC_y_support_user      - Nodes where roller supports that constrain Y-direction are applied
%       force_nodes            - Nodes where external forces are applied

% Asking for user input for the support node numbers
fprintf('Use Figure 2 as a reference for node numbers.\n')
BC_fixed_support_user = str2num(input('Enter the node numbers for FIXED SUPPORTS (e.g., 1 3 5). Enter 0 if none:\n','s'));
BC_x_support_user = str2num(input('Enter the node numbers for ROLLER SUPPORTS constrained in X-direction (free in Y) (e.g., 1 2). Enter 0 if none:\n', 's'));
BC_y_support_user = str2num(input('Enter the node numbers for ROLLER SUPPORTS constrained in Y-direction (free in X) (e.g., 2 4). Enter 0 if none:\n', 's'));

if BC_fixed_support_user == 0
    BC_fixed_support_user= [];
elseif any(BC_fixed_support_user > no_of_unique_nodes)
    error('Maximum node number exceeded.')
end

if BC_x_support_user == 0
    BC_x_support_user= [];
elseif any(BC_x_support_user > no_of_unique_nodes)
    error('Maximum node number exceeded.')
end

if BC_y_support_user == 0
    BC_y_support_user= [];
elseif any(BC_y_support_user > no_of_unique_nodes)
    error('Maximum node number exceeded.')
end

BC_nodes_user = [BC_fixed_support_user, BC_x_support_user, BC_y_support_user];

% Constructing the node number indices for supports for B.C. applications 
if BC_fixed_support_user == 0
    BC_fixed_support_indices= [];
else
    j=1;
    BC_fixed_support_indices= zeros(1,length(BC_fixed_support_user)); % preallocating for efficiency
    for i= 1: length(BC_fixed_support_user)
        
        BC_fixed_support_indices(j) = BC_fixed_support_user(i)*2 - 1;
        BC_fixed_support_indices(j+1) = BC_fixed_support_user(i)*2;
        j=j+2;
    end
end

if BC_x_support_user == 0
    BC_x_support_indices = [];
else
    BC_x_support_indices = zeros(1,length(BC_x_support_user));
    for i = 1:length(BC_x_support_user)
        BC_x_support_indices(i) = BC_x_support_user(i)*2 - 1;
    end
end

if BC_y_support_user == 0
    BC_y_support_indices= [];
else
    BC_y_support_indices = zeros(1,length(BC_y_support_user));
    for i = 1:length(BC_y_support_user)
        BC_y_support_indices(i) = BC_y_support_user(i)*2;
    end
end

total_indices = 1:(no_of_unique_nodes*DOF);

% This is indices used to get the stiffness matrix with the applied boundary conditions
BC_indices = setdiff(total_indices,[BC_fixed_support_indices BC_x_support_indices BC_y_support_indices]);

% matrix after applying the boundary conditions
K_global_BC_applied = [K_global(BC_indices,BC_indices)];

% Checking if the K matrix obtained from the B.C's is valid
if rank(full(K_global_BC_applied))< size(K_global_BC_applied,1)
    fprintf('Please check boundary conditions. The global stiffness matrix is singular. Possible rigid body motion or mechanism exists.\n')
    error('Boundary conditions')
end

% Asking user for the force inputs
force_nodes = str2num(input('Enter the node numbers where external forces are applied (e.g., 2 4):\n', 's'));
force_nodes = sort(force_nodes); % incase user enters nodes without order

forces_global = zeros(no_of_unique_nodes*2,1);
for i= 1:length(force_nodes)
    fprintf('Enter force components Fx and Fy for Node %d, respectively (e.g. 100 -50). Use 0 for non existent component.\n',force_nodes(i));
    forces = str2num(input('','s'));
    forces_global((force_nodes(i)*2 - 1):force_nodes(i)*2,1) = forces;
end

% applying B.C.'s to force vector as well:
forces_global_BC_applied = [forces_global(BC_indices,1)];

% preallocating displacement vector
u_global= zeros(no_of_unique_nodes*DOF,1);

% finding displacements:
u_global(BC_indices,1) = K_global_BC_applied \ forces_global_BC_applied;

end